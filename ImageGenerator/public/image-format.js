// El formato se decide por el contenido, aunque el archivo no tenga extensión ni MIME.
export function detectImageFormat(bytes) {
  if (bytes.length >= 8 && [0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a].every((value, i) => bytes[i] === value)) {
    return 'png';
  }
  if (bytes.length >= 3 && bytes[0] === 0xff && bytes[1] === 0xd8 && bytes[2] === 0xff) {
    return 'jpeg';
  }
  if (bytes.length >= 12 && [0x52, 0x49, 0x46, 0x46].every((value, i) => bytes[i] === value)
      && [0x57, 0x45, 0x42, 0x50].every((value, i) => bytes[i + 8] === value)) {
    return 'webp';
  }
  return null;
}

export async function imageDataURL(file) {
  if (file.size > 18 * 1024 * 1024) {
    throw new Error('La imagen es demasiado grande. El pedido completo tiene un límite de 25 MB.');
  }
  const format = detectImageFormat(new Uint8Array(await file.slice(0, 12).arrayBuffer()));
  if (!format) throw new Error('Elegí una imagen PNG, JPEG o WebP.');
  return new Promise((resolve, reject) => {
    const reader = new FileReader();
    reader.onload = () => resolve(reader.result);
    reader.onerror = () => reject(new Error('No se pudo leer el archivo. Volvé a elegirlo.'));
    reader.readAsDataURL(file.slice(0, file.size, `image/${format}`));
  });
}
