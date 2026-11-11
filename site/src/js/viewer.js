// =====================================================================
//  PousadaGuides — leitor de PDF (PDF.js auto-hospedado)
//  Rolagem contínua, renderização preguiçosa, sumário, links vivos,
//  texto selecionável, zoom (botões, Ctrl+roda, pinça) e link por página.
// =====================================================================
import * as pdfjsLib from '../vendor/pdfjs/pdf.min.mjs';

pdfjsLib.GlobalWorkerOptions.workerSrc = new URL('../vendor/pdfjs/pdf.worker.min.mjs', import.meta.url).href;

const $ = (id) => document.getElementById(id);
const body = document.body;
const stage = $('stage');
const pagesEl = $('pages');
const pageInput = $('pageInput');
const CSS_UNITS = 96 / 72;
const GAP = 18;
const ZOOM_STEPS = [50, 67, 75, 90, 100, 110, 125, 150, 175, 200, 250, 300, 400];
const MAX_FIT_WIDTH = 980;
const WIDE = matchMedia('(min-width: 1180px)');
const NARROW = matchMedia('(max-width: 760px)');

let doc = null;
let numPages = 0;
let baseW = 595, baseH = 842;     // tamanho da página em pt (scale 1)
let scale = 1;                    // px CSS por pt
let fitMode = true;
let cur = 1;
const pageEls = [];
const jobs = new Map();           // página -> { scale, task, cancelled }
let outlineItems = [];            // { page, top, el, li }
let activeEntry = null;

// ------------------------------------------------------------------ utilidades
const clamp = (v, a, b) => Math.min(b, Math.max(a, v));
const padTop = () => parseFloat(getComputedStyle(pagesEl).paddingTop) || 0;
const pageH = () => Math.floor(baseH * scale);
const pageW = () => Math.floor(baseW * scale);
const pageTop = (n) => padTop() + (n - 1) * (pageH() + GAP);

const toastEl = $('toast');
let toastTimer;
function toast(msg) {
  toastEl.textContent = msg;
  toastEl.classList.add('show');
  clearTimeout(toastTimer);
  toastTimer = setTimeout(() => toastEl.classList.remove('show'), 2600);
}

async function copyText(text) {
  try { await navigator.clipboard.writeText(text); return true; } catch {
    const ta = Object.assign(document.createElement('textarea'), { value: text });
    ta.style.cssText = 'position:fixed;opacity:0';
    document.body.appendChild(ta); ta.select();
    const ok = document.execCommand('copy'); ta.remove(); return ok;
  }
}

// ------------------------------------------------------------------ sumário (painel)
function setToc(open) {
  body.classList.toggle('toc-open', open);
  $('btnToc').setAttribute('aria-expanded', String(open));
  $('tocScrim').hidden = !open || WIDE.matches;
  if (WIDE.matches && doc) setTimeout(() => fitMode && applyScale(fitScale()), 320);
  if (open) scrollTocToActive();
}
$('btnToc').addEventListener('click', () => setToc(!body.classList.contains('toc-open')));
$('tocScrim').addEventListener('click', () => setToc(false));
if (WIDE.matches) setToc(true);

// outros guias
try {
  const nav = JSON.parse(body.dataset.nav || '[]');
  $('otherGuides').innerHTML = nav.map((g) =>
    `<a href="../${g.id}/" class="${g.id === body.dataset.id ? 'current' : ''}"><span class="mono">#${g.num}</span> ${g.title}</a>`).join('');
} catch { /* ignore */ }

// ------------------------------------------------------------------ download menu
const dlBtn = $('btnDl'), dlMenu = $('dlMenu');
function setDl(open) { dlMenu.hidden = !open; dlBtn.setAttribute('aria-expanded', String(open)); }
dlBtn.addEventListener('click', (e) => { e.stopPropagation(); setDl(dlMenu.hidden); });
document.addEventListener('click', (e) => { if (!dlMenu.hidden && !e.target.closest('.dl')) setDl(false); });

// ------------------------------------------------------------------ escala / layout
function fitScale() {
  const avail = stage.clientWidth - (NARROW.matches ? 16 : 48);
  return clamp(Math.min(avail, MAX_FIT_WIDTH) / baseW, 0.25, 5);
}

function layout() {
  const w = pageW(), h = pageH();
  pagesEl.style.setProperty('--gap', GAP + 'px');
  for (const el of pageEls) {
    el.style.width = w + 'px';
    el.style.height = h + 'px';
  }
}

function updateZoomLabel() {
  $('btnFit').textContent = Math.round((scale / CSS_UNITS) * 100) + '%';
  $('btnFit').title = fitMode ? 'Ajustado à largura' : 'Ajustar à largura (0)';
}

// muda a escala mantendo fixo o ponto (ax, ay) da área visível
function applyScale(next, ax = stage.clientWidth / 2, ay = 0) {
  next = clamp(next, 0.25, 6);
  if (!pageEls.length) { scale = next; return; }
  const oldH = pageH(), oldW = pageW(), pt = padTop();
  const cy = stage.scrollTop + ay - pt;
  const idx = clamp(Math.floor(cy / (oldH + GAP)), 0, numPages - 1);
  const fy = (cy - idx * (oldH + GAP)) / oldH;
  const el = pageEls[idx];
  const fx = (stage.scrollLeft + ax - el.offsetLeft) / oldW;

  scale = next;
  layout();
  const h = pageH(), w = pageW();
  stage.scrollTop = pt + idx * (h + GAP) + fy * h - ay;
  stage.scrollLeft = el.offsetLeft + fx * w - ax;
  updateZoomLabel();
  invalidateAll();
  schedule();
}

function zoomBy(dir, ax, ay) {
  fitMode = false;
  const pct = (scale / CSS_UNITS) * 100;
  const step = dir > 0 ? ZOOM_STEPS.find((z) => z > pct + 1) : [...ZOOM_STEPS].reverse().find((z) => z < pct - 1);
  if (step) applyScale((step / 100) * CSS_UNITS, ax, ay);
}
function zoomFit() { fitMode = true; applyScale(fitScale()); }

$('btnZoomIn').addEventListener('click', () => zoomBy(1));
$('btnZoomOut').addEventListener('click', () => zoomBy(-1));
$('btnFit').addEventListener('click', zoomFit);

let resizeTimer;
addEventListener('resize', () => {
  clearTimeout(resizeTimer);
  resizeTimer = setTimeout(() => {
    if (!WIDE.matches) $('tocScrim').hidden = !body.classList.contains('toc-open');
    else $('tocScrim').hidden = true;
    if (fitMode && doc) applyScale(fitScale()); else schedule();
  }, 120);
});

// Ctrl + roda do mouse / pinça do trackpad
stage.addEventListener('wheel', (e) => {
  if (!e.ctrlKey && !e.metaKey) return;
  e.preventDefault();
  fitMode = false;
  const r = stage.getBoundingClientRect();
  applyScale(scale * Math.exp(-e.deltaY * 0.0022), e.clientX - r.left, e.clientY - r.top);
}, { passive: false });

// pinça no celular (pré-visualiza com transform e re-renderiza no fim)
let pinch = null;
const touchDist = (t) => Math.hypot(t[0].clientX - t[1].clientX, t[0].clientY - t[1].clientY);
stage.addEventListener('touchstart', (e) => {
  if (e.touches.length !== 2) return;
  const r = stage.getBoundingClientRect();
  const mx = (e.touches[0].clientX + e.touches[1].clientX) / 2 - r.left;
  const my = (e.touches[0].clientY + e.touches[1].clientY) / 2 - r.top;
  pinch = { d: touchDist(e.touches), s: scale, ax: mx, ay: my, ratio: 1 };
  pagesEl.style.transformOrigin = `${stage.scrollLeft + mx}px ${stage.scrollTop + my}px`;
}, { passive: true });
stage.addEventListener('touchmove', (e) => {
  if (!pinch || e.touches.length !== 2) return;
  e.preventDefault();
  pinch.ratio = clamp(touchDist(e.touches) / pinch.d, 0.4 / pinch.s, 6 / pinch.s);
  pagesEl.style.transform = `scale(${pinch.ratio})`;
}, { passive: false });
stage.addEventListener('touchend', (e) => {
  if (!pinch || e.touches.length >= 2) return;
  const { s, ratio, ax, ay } = pinch;
  pinch = null;
  pagesEl.style.transform = '';
  pagesEl.style.transformOrigin = '';
  if (Math.abs(ratio - 1) > 0.02) { fitMode = false; applyScale(s * ratio, ax, ay); }
});

// ------------------------------------------------------------------ renderização
function invalidateAll() {
  for (const el of pageEls) delete el.dataset.scale;
}

function release(n) {
  const job = jobs.get(n);
  if (job) { job.cancelled = true; job.task?.cancel(); jobs.delete(n); }
  const el = pageEls[n - 1];
  if (!el || !el.classList.contains('ready')) return;
  el.querySelector('canvas')?.remove();
  el.querySelector('.textLayer')?.remove();
  el.querySelector('.linkLayer')?.remove();
  el.classList.remove('ready');
  delete el.dataset.scale;
}

async function renderPage(n) {
  const el = pageEls[n - 1];
  if (!el || el.dataset.scale === String(scale)) return;
  const prev = jobs.get(n);
  if (prev) { if (prev.scale === scale) return; prev.cancelled = true; prev.task?.cancel(); }
  const job = { scale, task: null, cancelled: false };
  jobs.set(n, job);

  try {
    const page = await doc.getPage(n);
    if (job.cancelled) return;
    const vp = page.getViewport({ scale });
    const dpr = Math.min(window.devicePixelRatio || 1, 2.5);
    const maxArea = 16_000_000;
    const out = vp.width * vp.height * dpr * dpr > maxArea ? Math.sqrt(maxArea / (vp.width * vp.height)) : dpr;

    const canvas = document.createElement('canvas');
    canvas.width = Math.floor(vp.width * out);
    canvas.height = Math.floor(vp.height * out);
    const ctx = canvas.getContext('2d', { alpha: false });
    job.task = page.render({ canvasContext: ctx, viewport: vp, transform: out !== 1 ? [out, 0, 0, out, 0, 0] : null });
    await job.task.promise;
    if (job.cancelled || jobs.get(n) !== job) return;

    el.querySelector('canvas')?.remove();
    el.prepend(canvas);
    el.classList.add('ready');
    el.dataset.scale = String(scale);
    jobs.delete(n);
    hideLoader();

    buildTextLayer(el, page, vp).catch(() => {});
    buildLinks(el, page, vp).catch(() => {});
  } catch (err) {
    if (err?.name === 'RenderingCancelledException') return;
    console.error('Falha ao renderizar página', n, err);
  }
}

async function buildTextLayer(el, page, vp) {
  el.querySelector('.textLayer')?.remove();
  const div = document.createElement('div');
  div.className = 'textLayer';
  el.style.setProperty('--scale-factor', vp.scale);
  el.style.setProperty('--user-unit', '1');
  el.style.setProperty('--total-scale-factor', vp.scale);
  el.appendChild(div);
  const tl = new pdfjsLib.TextLayer({ textContentSource: page.streamTextContent(), container: div, viewport: vp });
  await tl.render();
}

async function buildLinks(el, page, vp) {
  el.querySelector('.linkLayer')?.remove();
  const annots = await page.getAnnotations({ intent: 'display' });
  const layer = document.createElement('div');
  layer.className = 'linkLayer';
  for (const a of annots) {
    if (a.subtype !== 'Link' || (!a.url && !a.dest)) continue;
    const [x1, y1, x2, y2] = vp.convertToViewportRectangle(a.rect);
    const link = document.createElement('a');
    Object.assign(link.style, {
      left: Math.min(x1, x2) + 'px', top: Math.min(y1, y2) + 'px',
      width: Math.abs(x2 - x1) + 'px', height: Math.abs(y2 - y1) + 'px',
    });
    if (a.url) {
      link.href = a.url;
      link.target = '_blank';
      link.rel = 'noopener noreferrer';
      link.title = a.url;
    } else {
      link.href = '#';
      link.title = 'Ir para a seção';
      link.addEventListener('click', (e) => { e.preventDefault(); goToDest(a.dest); });
    }
    layer.appendChild(link);
  }
  if (layer.childElementCount) el.appendChild(layer);
}

// decide o que renderizar com base na rolagem
let rafId = 0;
function schedule() {
  if (rafId) return;
  rafId = requestAnimationFrame(() => { rafId = 0; onFrame(); });
}

function onFrame() {
  if (!numPages) return;
  const h = pageH() + GAP, pt = padTop();
  const top = stage.scrollTop - pt, bottom = top + stage.clientHeight;
  const first = clamp(Math.floor(top / h) + 1, 1, numPages);
  const last = clamp(Math.floor(bottom / h) + 1, 1, numPages);

  for (let n = first; n <= last; n++) renderPage(n);
  if (last + 1 <= numPages) renderPage(last + 1);
  if (first - 1 >= 1) renderPage(first - 1);
  for (const el of pageEls) {
    const n = +el.dataset.n;
    if ((n < first - 3 || n > last + 3) && (el.classList.contains('ready') || jobs.has(n))) release(n);
  }

  const c = clamp(Math.floor((top + stage.clientHeight * 0.35) / h) + 1, 1, numPages);
  if (c !== cur) setCurrent(c);

  const max = stage.scrollHeight - stage.clientHeight;
  $('progressBar').style.width = (max > 0 ? (stage.scrollTop / max) * 100 : 0) + '%';
}

let mobileTimer;
function setCurrent(n) {
  cur = n;
  if (document.activeElement !== pageInput) pageInput.value = n;
  $('btnPrev').disabled = n <= 1;
  $('btnNext').disabled = n >= numPages;
  updateHash();
  highlightOutline();
  if (NARROW.matches) {
    const mp = $('mobilePage');
    mp.textContent = `${n} / ${numPages}`;
    mp.classList.add('show');
    clearTimeout(mobileTimer);
    mobileTimer = setTimeout(() => mp.classList.remove('show'), 1100);
  }
}

let hashTimer;
function updateHash() {
  clearTimeout(hashTimer);
  hashTimer = setTimeout(() => {
    const url = location.pathname + location.search + (cur > 1 ? `#p=${cur}` : '');
    history.replaceState(null, '', url);
  }, 250);
}

stage.addEventListener('scroll', schedule, { passive: true });

// ------------------------------------------------------------------ navegação
function goTo(n, topPt = null, flash = false) {
  n = clamp(Math.round(n) || 1, 1, numPages);
  let y = pageTop(n) - (NARROW.matches ? 8 : 12);
  if (topPt != null) y += Math.max(0, (baseH - topPt) * scale - 24);
  stage.scrollTo({ top: Math.max(0, y), behavior: 'auto' });
  setCurrent(n);
  schedule();
  if (flash) {
    const el = pageEls[n - 1];
    el.classList.remove('flash'); void el.offsetWidth; el.classList.add('flash');
  }
}

async function resolveDest(dest) {
  const exp = typeof dest === 'string' ? await doc.getDestination(dest) : dest;
  if (!Array.isArray(exp)) return null;
  const ref = exp[0];
  let page = null;
  if (ref && typeof ref === 'object') page = (await doc.getPageIndex(ref)) + 1;
  else if (Number.isInteger(ref)) page = ref + 1;
  const kind = exp[1]?.name;
  const top = kind === 'XYZ' ? exp[3] : (kind === 'FitH' || kind === 'FitBH') ? exp[2] : null;
  return page ? { page, top: typeof top === 'number' ? top : null } : null;
}

async function goToDest(dest) {
  try {
    const r = await resolveDest(dest);
    if (r) goTo(r.page, r.top);
  } catch (e) { console.warn(e); }
}

$('btnPrev').addEventListener('click', () => goTo(cur - 1));
$('btnNext').addEventListener('click', () => goTo(cur + 1));
pageInput.addEventListener('focus', () => pageInput.select());
pageInput.addEventListener('keydown', (e) => {
  if (e.key === 'Enter') { goTo(parseInt(pageInput.value, 10), null, true); pageInput.blur(); }
  if (e.key === 'Escape') { pageInput.value = cur; pageInput.blur(); }
});
pageInput.addEventListener('blur', () => { pageInput.value = cur; });

function hashPage() {
  const m = location.hash.match(/(?:p|page|pagina)=(\d+)/i);
  return m ? parseInt(m[1], 10) : null;
}
addEventListener('hashchange', () => { const p = hashPage(); if (p && p !== cur) goTo(p, null, true); });

document.addEventListener('keydown', (e) => {
  if (e.target.closest('input, textarea, [contenteditable]')) return;
  if (e.ctrlKey || e.metaKey) {
    if (e.key === '+' || e.key === '=') { e.preventDefault(); zoomBy(1); }
    else if (e.key === '-') { e.preventDefault(); zoomBy(-1); }
    else if (e.key === '0') { e.preventDefault(); zoomFit(); }
    return;
  }
  if (e.altKey) return;
  switch (e.key) {
    case 'ArrowRight': case 'l': e.preventDefault(); goTo(cur + 1); break;
    case 'ArrowLeft': case 'h': e.preventDefault(); goTo(cur - 1); break;
    case 'Home': e.preventDefault(); goTo(1); break;
    case 'End': e.preventDefault(); goTo(numPages); break;
    case '+': case '=': zoomBy(1); break;
    case '-': zoomBy(-1); break;
    case '0': zoomFit(); break;
    case 's': case 'S': setToc(!body.classList.contains('toc-open')); break;
    case 'g': pageInput.focus(); e.preventDefault(); break;
    case 'Escape':
      setDl(false);
      if (!WIDE.matches) setToc(false);
      break;
  }
});

// ------------------------------------------------------------------ compartilhar
$('btnShare').addEventListener('click', async () => {
  const url = location.origin + location.pathname + (cur > 1 ? `#p=${cur}` : '');
  const title = `PousadaGuide #${body.dataset.num} — ${body.dataset.title}`;
  if (navigator.share && matchMedia('(pointer: coarse)').matches) {
    try { await navigator.share({ title, url }); return; } catch (err) { if (err.name === 'AbortError') return; }
  }
  const ok = await copyText(url);
  toast(ok ? (cur > 1 ? `🔗 Link da página ${cur} copiado!` : '🔗 Link do guia copiado!') : url);
});

// ------------------------------------------------------------------ sumário (outline)
async function buildOutline() {
  const list = $('tocList');
  let outline = null;
  try { outline = await doc.getOutline(); } catch { /* sem outline */ }
  if (!outline || !outline.length) {
    list.innerHTML = '<p class="muted toc-loading">Este PDF não tem sumário embutido.</p>';
    return;
  }
  const chev = '<svg class="ic" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="m9 6 6 6-6 6"/></svg>';
  const pending = [];

  const make = (items, depth) => {
    const ul = document.createElement('ul');
    for (const it of items) {
      const li = document.createElement('li');
      const row = document.createElement('div');
      row.className = 'toc-row';
      const hasKids = it.items && it.items.length > 0;
      if (hasKids) {
        const t = document.createElement('button');
        t.className = 'toc-toggle';
        t.type = 'button';
        t.setAttribute('aria-label', 'Expandir');
        t.innerHTML = chev;
        t.addEventListener('click', () => li.classList.toggle('open'));
        row.appendChild(t);
      } else {
        row.appendChild(Object.assign(document.createElement('span'), { className: 'toc-spacer' }));
      }
      const a = document.createElement('button');
      a.type = 'button';
      a.className = 'toc-link';
      const title = (it.title || '').replace(/\s+/g, ' ').trim();
      a.innerHTML = `<span class="t"></span><span class="pg"></span>`;
      a.querySelector('.t').textContent = title;
      row.appendChild(a);
      li.appendChild(row);

      const entry = { page: null, top: null, el: a, li };
      outlineItems.push(entry);
      if (it.dest) {
        pending.push(resolveDest(it.dest).then((r) => {
          if (r) { entry.page = r.page; entry.top = r.top; a.querySelector('.pg').textContent = r.page; }
        }).catch(() => {}));
        a.addEventListener('click', () => {
          if (entry.page) goTo(entry.page, entry.top); else goToDest(it.dest);
          if (!WIDE.matches) setToc(false);
        });
      } else if (it.url) {
        a.addEventListener('click', () => window.open(it.url, '_blank', 'noopener'));
      }
      if (hasKids) li.appendChild(make(it.items, depth + 1));
      ul.appendChild(li);
    }
    return ul;
  };

  list.innerHTML = '';
  list.appendChild(make(outline, 0));
  await Promise.all(pending);
  highlightOutline();
}

function highlightOutline() {
  if (!outlineItems.length) return;
  let best = null;
  for (const e of outlineItems) {
    if (e.page != null && e.page <= cur && (!best || e.page >= best.page)) best = e;
  }
  if (best === activeEntry) return;
  activeEntry?.el.classList.remove('active');
  activeEntry = best;
  if (!best) return;
  best.el.classList.add('active');
  let p = best.li.parentElement?.closest('li');
  while (p) { p.classList.add('open'); p = p.parentElement?.closest('li'); }
  scrollTocToActive();
}
function scrollTocToActive() {
  if (activeEntry && body.classList.contains('toc-open')) activeEntry.el.scrollIntoView({ block: 'nearest' });
}

// ------------------------------------------------------------------ carregamento
let loaderHidden = false;
function hideLoader() {
  if (loaderHidden) return;
  loaderHidden = true;
  const l = $('loader');
  l.classList.add('done');
  setTimeout(() => l.remove(), 400);
}

function showError(err) {
  console.error(err);
  $('loader')?.remove();
  $('error').hidden = false;
}

async function init() {
  const task = pdfjsLib.getDocument({ url: body.dataset.pdf, isEvalSupported: false, enableXfa: false });
  task.onProgress = ({ loaded, total }) => {
    const mb = (loaded / 1048576).toFixed(1);
    if (total) {
      const pct = Math.min(100, Math.round((loaded / total) * 100));
      $('loadBar').style.width = Math.max(4, pct) + '%';
      $('loadText').textContent = `baixando ${mb} / ${(total / 1048576).toFixed(1)} MB · ${pct}%`;
    } else {
      $('loadText').textContent = `baixando ${mb} MB…`;
    }
  };
  doc = await task.promise;
  numPages = doc.numPages;
  $('pageCount').textContent = numPages;
  $('loadText').textContent = 'renderizando…';
  $('loadBar').style.width = '100%';

  const first = await doc.getPage(1);
  const vp = first.getViewport({ scale: 1 });
  baseW = vp.width; baseH = vp.height;

  const frag = document.createDocumentFragment();
  for (let n = 1; n <= numPages; n++) {
    const el = document.createElement('div');
    el.className = 'page';
    el.dataset.n = n;
    el.setAttribute('role', 'img');
    el.setAttribute('aria-label', `Página ${n} de ${numPages}`);
    pageEls.push(el);
    frag.appendChild(el);
  }
  pagesEl.appendChild(frag);

  scale = fitScale();
  layout();
  updateZoomLabel();

  const start = hashPage();
  if (start && start > 1) goTo(start, null, true); else setCurrent(1);
  schedule();
  stage.focus({ preventScroll: true });

  buildOutline();
}

init().catch(showError);
