// PousadaGuides — home: compartilhar, revelar ao rolar e header fixo
(() => {
  const toast = document.getElementById('toast');
  let toastTimer;
  const showToast = (msg) => {
    if (!toast) return;
    toast.textContent = msg;
    toast.classList.add('show');
    clearTimeout(toastTimer);
    toastTimer = setTimeout(() => toast.classList.remove('show'), 2600);
  };

  const copy = async (text) => {
    try { await navigator.clipboard.writeText(text); return true; } catch {
      const ta = Object.assign(document.createElement('textarea'), { value: text });
      ta.style.cssText = 'position:fixed;opacity:0';
      document.body.appendChild(ta); ta.select();
      const ok = document.execCommand('copy'); ta.remove(); return ok;
    }
  };

  document.addEventListener('click', async (e) => {
    const btn = e.target.closest('[data-share]');
    if (!btn) return;
    const url = btn.dataset.share, title = btn.dataset.title || document.title;
    if (navigator.share && matchMedia('(pointer: coarse)').matches) {
      try { await navigator.share({ title, url }); return; } catch (err) { if (err.name === 'AbortError') return; }
    }
    showToast((await copy(url)) ? '🔗 Link copiado! É só colar e mandar.' : url);
  });

  // header com fundo ao rolar
  const header = document.querySelector('.site-header');
  const onScroll = () => header && header.classList.toggle('scrolled', scrollY > 12);
  addEventListener('scroll', onScroll, { passive: true });
  onScroll();

  // animações de entrada
  const els = document.querySelectorAll('.reveal');
  if (!('IntersectionObserver' in window)) return;
  document.documentElement.classList.add('has-js');
  const io = new IntersectionObserver((entries) => {
    for (const en of entries) if (en.isIntersecting) { en.target.classList.add('in'); io.unobserve(en.target); }
  }, { rootMargin: '200px 0px 100px 0px', threshold: 0 });
  els.forEach((el) => {
    io.observe(el);
    const r = el.getBoundingClientRect();
    if (r.top < window.innerHeight + 200) el.classList.add('in');
  });
})();
