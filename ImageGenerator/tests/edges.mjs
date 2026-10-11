import assert from 'node:assert/strict';
import sharp from 'sharp';
import { lab, colorDistances, refineEdges } from '../lib/matting.mjs';
import { cutout, merge } from '../lib/mockup.mjs';

const width = 160;
const height = 180;
const total = width * height;
const background = new Float32Array(total * 3).fill(255);
const cream = [243, 236, 223];
const neutral = [236, 236, 236];
assert.ok(Math.abs(lab(255, 255, 255)[2]) < 0.001);
const colors = Buffer.from([...cream, 255, ...neutral, 255]);
const distances = colorDistances(colors, new Float32Array(6).fill(255), 2);
assert.ok(distances[0] > distances[1] * 2, 'Lab chroma distinguishes warm cream from neutral shadow');

for (const fabric of [cream, [222, 222, 222], [30, 30, 30], [115, 115, 115]]) {
  const original = Buffer.alloc(total * 4, 255);
  const mask = new Uint8Array(total);
  for (let y = 0; y < height; y++) {
    for (let x = 0; x < width; x++) {
      const i = y * width + x;
      // Soft neutral shadow extends left and below the garment.
      const shade = x >= 32 && x < 120 && y >= 40 && y < 150 ? 1 + (x % 4) : 0;
      for (let c = 0; c < 3; c++) {
        original[i * 4 + c] = 255 - shade;
      }
      if (x >= 40 && x < 120 && y >= 40 && y < 140) {
        original.set(fabric, i * 4);
      }
      // Model/closing wrongly keeps rectangular background blocks attached.
      if (x >= 32 && x < 120 && y >= 40 && y < 150) {
        mask[i] = 255;
      }
    }
  }
  const pixel = 80 * width + 39;
  for (let c = 0; c < 3; c++) {
    original[pixel * 4 + c] = Math.round((251 + fabric[c]) / 2);
  }
  const coarseMask = mask.slice();
  const data = Buffer.from(original);
  await refineEdges(original, data, mask, background, width, height, 8, false);
  assert.ok(mask[pixel] > 85 && mask[pixel] < 190, 'mixed edge gets continuous alpha');
  assert.equal(mask[80 * width + 35], 0, 'attached left white block removed');
  assert.equal(mask[145 * width + 70], 0, 'white strip under hem removed');
  assert.equal(mask[80 * width + 70], 255, 'fabric interior preserved');
  for (let c = 0; c < 3; c++) {
    assert.ok(Math.abs(data[pixel * 4 + c] - fabric[c]) < 15, 'edge RGB decontaminated');
  }
  const shadowData = Buffer.from(original);
  const shadowMask = mask.slice();
  await refineEdges(original, shadowData, shadowMask, background, width, height, 8, true, 3);
  const shadowPixel = 80 * width + 35;
  assert.ok(shadowMask[shadowPixel] > 0 && shadowMask[shadowPixel] < 20,
    'default original shadow stays translucent');
  assert.deepEqual([...shadowData.subarray(shadowPixel * 4, shadowPixel * 4 + 3)], [0, 0, 0],
    'original shadow has black RGB instead of retained white background');

  const smoothData = Buffer.from(original);
  await refineEdges(original, smoothData, coarseMask, background, width, height, 8, false, 3);
  const insideBand = 80 * width + 41;
  assert.ok(coarseMask[insideBand] > 128 && coarseMask[insideBand] < 255,
    'three-pixel band is continuous inside the edge (radius three, seven-pixel morphology kernel)');
  assert.equal(coarseMask[80 * width + 70], 255, 'smoothing preserves the interior');
  for (let c = 0; c < 3; c++) {
    assert.equal(smoothData[insideBand * 4 + c], fabric[c],
      'geometry smoothing does not darken opaque fabric RGB');
  }
  // Black-and-white prints inside the closed garment must not become holes.
  original.set([255, 255, 255], (80 * width + 70) * 4);
  const png = await sharp(original, { raw: { width, height, channels: 4 } }).png().toBuffer();
  const result = await sharp(await cutout(png, merge({ recorte: 'rapido', sombra_original: false })))
    .raw().toBuffer({ resolveWithObject: true });
  assert.ok(result.info.width >= 76 && result.info.width <= 84, 'default fast cutout retains garment width');
  assert.ok(result.info.height >= 96 && result.info.height <= 104, 'default fast cutout retains garment height');
  const center = (Math.floor(result.info.height / 2) * result.info.width + Math.floor(result.info.width / 2)) * 4;
  assert.equal(result.data[center + 3], 255, 'closed interior stays opaque');
  let whitePrint = false;
  for (let y = 10; y < result.info.height - 10; y++) {
    for (let x = 10; x < result.info.width - 10; x++) {
      const i = (y * result.info.width + x) * 4;
      if (result.data.subarray(i, i + 4).every(value => value === 255)) {
        whitePrint = true;
      }
    }
  }
  assert.ok(whitePrint, 'white print survives inside a closed garment');
}
console.log('PASS Lab chroma, continuous matting, RGB decontamination, attached blocks, hem, cream/white/black/washed gray, default fast geometry');
