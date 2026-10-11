import { imageDataURL as dataURL } from './image-format.js';

const $ = id => document.getElementById(id);
const numericFields = [
  ['ancho', 'Ancho (px)', 32, 4096, 1],
  ['alto', 'Alto (px)', 32, 4096, 1],
  ['escala', 'Escala', 0.01, 1, 0.01],
  ['posicion_vertical', 'Posición vertical', 0, 1, 0.01],
  ['tolerancia', 'Tolerancia', 0, 255, 0.1],
  ['recortar_borde', 'Recortar borde (px)', 0, 20, 1],
  ['rellenar_bordes', 'Rellenar mordidas (px)', 0, 40, 1],
  ['suavizar_contorno', 'Suavizar contorno (px)', 0, 20, 0.5],
  ['borde_suave', 'Borde suave (px)', 0, 100, 0.1],
];
const shadowFields = [
  ['opacidad', 'Opacidad', 0, 1, 0.01],
  ['desenfoque', 'Desenfoque (px)', 0, 200, 0.1],
  ['x', 'Desplazamiento X (px)', -4096, 4096, 1],
  ['y', 'Desplazamiento Y (px)', -4096, 4096, 1],
];
let cards = [];
let busy = false;
let ready = false;
let backgroundURL = null;

function createFields(fields, container, defaults, prefix = '') {
  for (const [key, title, min, max, step] of fields) {
    const label = document.createElement('label');
    label.textContent = title;
    const input = document.createElement('input');
    Object.assign(input, { type: 'number', id: `${prefix}${key}`, min, max, step, required: true });
    input.value = defaults[key];
    label.append(input);
    container.append(label);
  }
}

function updateButtons() {
  $('controls').disabled = busy || !ready;
  $('shadow-controls').disabled = !$('shadow-enabled').checked;
  $('generate').disabled = !cards.length || busy || !ready;
  $('download-all').disabled = busy || !cards.some(card => card.resultURL);
  for (const card of cards) {
    card.element.querySelector('.regenerate').disabled = busy || !ready;
    const download = card.element.querySelector('.download');
    download.hidden = busy || !card.resultURL;
  }
  $('count').textContent = cards.length
    ? `${cards.length} imagen(es) · ${cards.filter(card => card.resultURL).length} resultado(s)`
    : 'Todavía no cargaste imágenes.';
  $('empty').hidden = cards.length > 0;
}

function clearResult(card) {
  if (card.resultURL) {
    URL.revokeObjectURL(card.resultURL);
    card.resultURL = null;
  }
  card.element.querySelector('.download').removeAttribute('href');
  const slot = card.element.querySelector('.result-slot');
  const text = document.createElement('span');
  text.textContent = 'Sin generar';
  slot.replaceChildren(text);
}

function selectImages(files) {
  if (busy || !ready) {
    return;
  }
  for (const card of cards) {
    URL.revokeObjectURL(card.originalURL);
    clearResult(card);
  }
  $('grid').replaceChildren();
  cards = Array.from(files, file => {
    const element = $('card-template').content.firstElementChild.cloneNode(true);
    const originalURL = URL.createObjectURL(file);
    const card = { file, element, originalURL, resultURL: null };
    element.querySelector('.file-name').textContent = file.name;
    const original = element.querySelector('.original');
    original.src = originalURL;
    original.alt = `Original de ${file.name}`;
    element.querySelector('.regenerate').addEventListener('click', () => run([card]));
    $('grid').append(element);
    return card;
  });
  $('message').textContent = cards.length ? 'Ajustá las opciones y tocá Generar.' : '';
  updateButtons();
}


function readOptions() {
  const options = {};
  for (const [key] of numericFields) {
    options[key] = Number($(key).value);
  }
  options.recorte = $('recorte').value;
  options.quitar_huecos = $('quitar_huecos').checked;
  options.sombra_original = $('sombra_original').checked;
  options.sombra = false;
  if ($('shadow-enabled').checked) {
    options.sombra = {};
    for (const [key] of shadowFields) {
      options.sombra[key] = Number($(`shadow-${key}`).value);
    }
  }
  options.fondo = $('background-mode').value === 'color'
    ? $('solid-color').value
    : { degradado: [$('center-color').value, $('edge-color').value] };
  return options;
}

async function run(selected) {
  if (busy || !ready || !$('settings').reportValidity()) {
    return;
  }
  const options = readOptions();
  const backgroundFile = $('background').files[0];
  busy = true;
  updateButtons();
  try {
    const configResponse = await fetch('/api/config', {
      method: 'POST', headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ destino: $('destination').value }),
    });
    const config = await configResponse.json();
    if (!configResponse.ok) throw new Error(config.error);
    $('destination').value = config.destino;
    const fondo = backgroundFile ? await dataURL(backgroundFile) : null;
    let completed = 0;
    for (const card of selected) {
      clearResult(card);
      const status = card.element.querySelector('.status');
      status.textContent = 'Procesando…';
      status.classList.remove('error');
      $('message').textContent = `Procesando ${completed + 1} de ${selected.length}…`;
      try {
        const imagen = await dataURL(card.file);
        const body = JSON.stringify({ imagen, fondo, opciones: options, destino: config.destino, nombre: card.file.name });
        if (new Blob([body]).size > 25 * 1024 * 1024) {
          throw new Error('La foto y el fondo juntos superan los 25 MB del pedido. Elegí archivos más chicos.');
        }
        const response = await fetch('/api/generar', {
          method: 'POST', headers: { 'Content-Type': 'application/json' }, body,
        });
        if (!response.ok) {
          const problem = await response.json();
          throw new Error(problem.error ?? 'No se pudo generar el mockup.');
        }
        card.resultURL = URL.createObjectURL(await response.blob());
        const image = document.createElement('img');
        image.src = card.resultURL;
        image.alt = `Mockup de ${card.file.name}`;
        card.element.querySelector('.result-slot').replaceChildren(image);
        const download = card.element.querySelector('.download');
        download.href = card.resultURL;
        download.download = `${card.file.name.replace(/\.[^.]+$/, '')}-mock.webp`;
        status.textContent = `Listo · Guardado en ${decodeURIComponent(response.headers.get('X-Saved-Path') ?? '')}`;
      } catch (error) {
        status.textContent = `Error: ${error.message}`;
        status.classList.add('error');
      }
      completed++;
      updateButtons();
    }
    $('message').textContent = 'Terminó el procesamiento. Podés descargar los resultados o ajustar y regenerar.';
  } catch (error) {
    $('message').textContent = `Error: ${error.message}`;
  } finally {
    busy = false;
    updateButtons();
  }
}

function showBackground() {
  if (backgroundURL) {
    URL.revokeObjectURL(backgroundURL);
    backgroundURL = null;
  }
  const file = $('background').files[0];
  $('background-preview').hidden = !file;
  $('color-settings').hidden = Boolean(file);
  $('background-image').removeAttribute('src');
  if (file) {
    backgroundURL = URL.createObjectURL(file);
    $('background-image').src = backgroundURL;
  }
}

$('images').addEventListener('change', event => selectImages(event.target.files));
$('background').addEventListener('change', showBackground);
$('clear-background').addEventListener('click', () => {
  $('background').value = '';
  showBackground();
});
$('background-mode').addEventListener('change', () => {
  $('solid-label').hidden = $('background-mode').value !== 'color';
  $('gradient-colors').hidden = $('background-mode').value !== 'gradient';
});
$('shadow-enabled').addEventListener('change', updateButtons);
$('settings').addEventListener('submit', event => {
  event.preventDefault();
  run(cards);
});
for (const name of ['dragenter', 'dragover']) {
  $('drop-zone').addEventListener(name, event => {
    event.preventDefault();
    if (!busy && ready) {
      $('drop-zone').classList.add('dragging');
    }
  });
}
$('drop-zone').addEventListener('dragleave', () => $('drop-zone').classList.remove('dragging'));
$('drop-zone').addEventListener('drop', event => {
  event.preventDefault();
  $('drop-zone').classList.remove('dragging');
  selectImages(event.dataTransfer.files);
});
$('download-all').addEventListener('click', async () => {
  if (busy) {
    return;
  }
  const downloads = cards.filter(card => card.resultURL);
  busy = true;
  updateButtons();
  try {
    for (const card of downloads) {
      card.element.querySelector('.download').click();
      await new Promise(resolve => setTimeout(resolve, 500));
    }
    $('message').textContent = 'Se solicitaron las descargas. Si tu navegador lo pide, permití descargar varios archivos.';
  } finally {
    busy = false;
    updateButtons();
  }
});
window.addEventListener('pagehide', () => {
  for (const card of cards) {
    URL.revokeObjectURL(card.originalURL);
    if (card.resultURL) {
      URL.revokeObjectURL(card.resultURL);
    }
  }
  if (backgroundURL) {
    URL.revokeObjectURL(backgroundURL);
  }
});

try {
  const response = await fetch('/api/opciones');
  if (!response.ok) {
    throw new Error('No se pudieron cargar los ajustes.');
  }
  const defaults = await response.json();
  $('recorte').value = defaults.recorte;
  const configResponse = await fetch('/api/config');
  if (!configResponse.ok) throw new Error('No se pudo leer la carpeta destino.');
  $('destination').value = (await configResponse.json()).destino;
  createFields(numericFields, $('numeric-controls'), defaults);
  createFields(shadowFields, $('shadow-fields'), defaults.sombra || {}, 'shadow-');
  $('sombra_original').checked = defaults.sombra_original;
  $('quitar_huecos').checked = defaults.quitar_huecos;
  $('shadow-enabled').checked = defaults.sombra !== false;
  if (typeof defaults.fondo === 'string') {
    $('solid-color').value = defaults.fondo;
  } else {
    $('background-mode').value = 'gradient';
    [$('center-color').value, $('edge-color').value] = defaults.fondo.degradado;
    $('background-mode').dispatchEvent(new Event('change'));
  }
  ready = true;
  $('message').textContent = '';
  updateButtons();
} catch (error) {
  $('message').textContent = `${error.message} Recargá la página con el servidor encendido.`;
}
