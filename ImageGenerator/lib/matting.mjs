import sharp from 'sharp';

// D65 CIELAB. Chroma separates warm fabric from a neutral white/shadow background.
export function lab(r, g, b) {
  const linear = value => {
    const v = value / 255;
    return v <= 0.04045 ? v / 12.92 : ((v + 0.055) / 1.055) ** 2.4;
  };
  const R = linear(r);
  const G = linear(g);
  const B = linear(b);
  const f = value => value > 0.008856 ? Math.cbrt(value) : 7.787 * value + 16 / 116;
  const x = f((0.4124564 * R + 0.3575761 * G + 0.1804375 * B) / 0.95047);
  const y = f(0.2126729 * R + 0.7151522 * G + 0.072175 * B);
  const z = f((0.0193339 * R + 0.119192 * G + 0.9503041 * B) / 1.08883);
  return [116 * y - 16, 500 * (x - y), 200 * (y - z)];
}

export function colorDistances(data, background, total) {
  const distance = new Float32Array(total);
  for (let i = 0; i < total; i++) {
    const fg = lab(...data.subarray(i * 4, i * 4 + 3));
    const bg = lab(...background.subarray(i * 3, i * 3 + 3));
    distance[i] = Math.hypot(2.55 * (fg[0] - bg[0]), 6 * (fg[1] - bg[1]), 6 * (fg[2] - bg[2]));
  }
  return distance;
}

function neighbours(i, width, total) {
  const x = i % width;
  return [x > 0 ? i - 1 : -1, x < width - 1 ? i + 1 : -1, i - width, i + width]
    .filter(j => j >= 0 && j < total);
}

// Remove exterior neutral shadows even when a model or a morphological closing
// included them. An abrupt color step stops the flood at gray/white fabric.
export async function refineEdges(original, data, alpha, background, width, height, tolerance, keepShadow, smoothing = 0) {
  const total = width * height;
  const distance = colorDistances(original, background, total);
  const exterior = new Uint8Array(total);
  const queue = new Int32Array(total);
  const maximumStep = Math.max(2, Math.min(5, tolerance / 2));
  const darkening = i => {
    const ratios = [0, 1, 2].map(c => original[i * 4 + c] / Math.max(1, background[i * 3 + c]));
    const mean = (ratios[0] + ratios[1] + ratios[2]) / 3;
    return Math.max(...ratios) - Math.min(...ratios) <= 0.025 && mean >= 0.82 && mean <= 1
      ? 1 - mean : -1;
  };
  let tail = 0;
  const add = i => {
    if (!exterior[i]) {
      exterior[i] = 1;
      queue[tail++] = i;
    }
  };
  for (let i = 0; i < total; i++) {
    const x = i % width;
    if ((x === 0 || x === width - 1 || i < width || i >= total - width) && distance[i] <= tolerance) {
      add(i);
    }
  }
  for (let head = 0; head < tail; head++) {
    const i = queue[head];
    for (const j of neighbours(i, width, total)) {
      if (exterior[j]) {
        continue;
      }
      const flat = distance[j] <= tolerance;
      const gradual = darkening(j) >= 0 && [0, 1, 2].every(c =>
        Math.abs(original[j * 4 + c] - original[i * 4 + c]) <= maximumStep);
      if (flat || gradual) {
        add(j);
      }
    }
  }

  const shape = Buffer.alloc(total);
  for (let i = 0; i < total; i++) {
    shape[i] = !exterior[i] && alpha[i] >= 128 ? 255 : 0;
    data.set(original.subarray(i * 4, i * 4 + 3), i * 4);
    alpha[i] = shape[i];
  }
  // Discard small disconnected remnants after removing attached exterior blocks.
  // Closed interior white prints are never color-keyed.
  const seen = new Uint8Array(total);
  const pieces = [];
  let largest = 0;
  for (let i = 0; i < total; i++) {
    if (!shape[i] || seen[i]) {
      continue;
    }
    tail = 0;
    queue[tail++] = i;
    seen[i] = 1;
    for (let head = 0; head < tail; head++) {
      for (const j of neighbours(queue[head], width, total)) {
        if (shape[j] && !seen[j]) {
          seen[j] = 1;
          queue[tail++] = j;
        }
      }
    }
    largest = Math.max(largest, tail);
    pieces.push(queue.slice(0, tail));
  }
  for (const piece of pieces) {
    if (piece.length < largest * 0.03) {
      for (const i of piece) {
        shape[i] = alpha[i] = 0;
      }
    }
  }

  const raw = { raw: { width, height, channels: 1 } };
  if (smoothing > 0) {
    // Remove short protrusions and staircase dents without expanding the old
    // background. Matting below supplies subpixel coverage around this contour.
    const regular = await sharp(shape, raw).median(5)
      .blur(Math.max(0.3, Math.min(3, smoothing))).threshold(128)
      .extractChannel(0).raw().toBuffer();
    shape.set(regular);
    alpha.set(regular);
  }
  const geometry = smoothing > 0
    ? await sharp(shape, raw).blur(Math.max(0.3, Math.min(1.5, smoothing / 2)))
      .extractChannel(0).raw().toBuffer()
    : shape;
  // Sharp builds a 2 * radius + 1 kernel: radius 3 gives a three-pixel band.
  const core = await sharp(shape, raw).dilate(3).threshold(128).extractChannel(0).raw().toBuffer();
  const outside = await sharp(shape, raw).erode(3).threshold(128).extractChannel(0).raw().toBuffer();
  const nearest = seeds => {
    const owner = new Int32Array(total).fill(-1);
    const steps = new Uint8Array(total);
    tail = 0;
    for (let i = 0; i < total; i++) {
      if (seeds(i)) {
        owner[i] = i;
        queue[tail++] = i;
      }
    }
    for (let head = 0; head < tail; head++) {
      const i = queue[head];
      if (steps[i] >= 8) {
        continue;
      }
      for (const j of neighbours(i, width, total)) {
        if (owner[j] < 0) {
          owner[j] = owner[i];
          steps[j] = steps[i] + 1;
          queue[tail++] = j;
        }
      }
    }
    return owner;
  };
  const inner = nearest(i => core[i] > 127);
  const outer = nearest(i => outside[i] < 128 && exterior[i]);
  for (let i = 0; i < total; i++) {
    if (core[i] || !outside[i]) {
      continue;
    }
    alpha[i] = Math.min(alpha[i], geometry[i]);
    if (inner[i] < 0 || outer[i] < 0) {
      continue;
    }
    const f = inner[i];
    const b = outer[i];
    // RGB projection remains linear in coverage, unlike Lab luminance. Add
    // opponent chroma directions so neutral shadow cannot outweigh cream hue.
    const components = index => {
      const [r, g, blue] = original.subarray(index * 4, index * 4 + 3);
      return [r, g, blue, r - g, blue - (r + g) / 2];
    };
    const fg = components(f);
    const bg = components(b);
    const pixel = components(i);
    let dot = 0;
    let length = 0;
    for (let c = 0; c < 5; c++) {
      const weight = c < 3 ? 1 : 4;
      const direction = fg[c] - bg[c];
      dot += weight * (pixel[c] - bg[c]) * direction;
      length += weight * direction * direction;
    }
    if (length < 1) {
      continue;
    }
    const coverage = Math.min(1, Math.max(0, dot / length));
    alpha[i] = Math.round(Math.min(geometry[i] / 255, coverage) * 255);
    if (coverage > 0 && coverage < 1) {
      for (let c = 0; c < 3; c++) {
        const oldBackground = original[b * 4 + c];
        const value = oldBackground + (original[i * 4 + c] - oldBackground) / coverage;
        data[i * 4 + c] = Math.min(255, Math.max(0, Math.round(value)));
      }
    }
  }
  if (smoothing > 0) {
    // Color quantization must not turn the continuous matte back into teeth.
    // Average coverage only in the narrow band; newly covered pixels receive
    // foreground RGB, rather than bringing back the white photographic backdrop.
    const smoothAlpha = await sharp(Buffer.from(alpha), raw).blur(Math.min(1, Math.max(0.3, smoothing / 3)))
      .extractChannel(0).raw().toBuffer();
    for (let i = 0; i < total; i++) {
      if (!core[i] && outside[i] && inner[i] >= 0) {
        const coverage = Math.min(geometry[i], smoothAlpha[i]);
        if (alpha[i] < 32 && coverage > alpha[i]) {
          data.set(original.subarray(inner[i] * 4, inner[i] * 4 + 3), i * 4);
        }
        alpha[i] = coverage;
      }
    }
  }

  if (keepShadow) {
    // Retain soft original shadows as black alpha, never as opaque white RGB.
    for (let i = 0; i < total; i++) {
      if (exterior[i] && !outside[i]) {
        const amount = darkening(i);
        if (amount > 0.01) {
          alpha[i] = Math.round(amount * 255);
          data[i * 4] = data[i * 4 + 1] = data[i * 4 + 2] = 0;
        }
      }
    }
  }
}
