/**
 * home.js — Tripan 메인 홈 전용 스크립트
 * - Reveal (스크롤 애니메이션)
 * - 캐러셀 좌우 화살표
 * - 히어로 시차 스크롤 (parallax)
 */

(function () {
  'use strict';

  /* ══════════════════════════════════════════
     1. Reveal 스크롤 애니메이션
  ══════════════════════════════════════════ */
  const revealEls = document.querySelectorAll('.reveal');

  const revealObserver = new IntersectionObserver(
    (entries) => {
      entries.forEach((entry) => {
        if (entry.isIntersecting) {
          entry.target.classList.add('active');
          revealObserver.unobserve(entry.target); // 한 번만 발동
        }
      });
    },
    { threshold: 0.12, rootMargin: '0px 0px -40px 0px' }
  );

  revealEls.forEach((el) => {
    // 히어로 내부는 페이지 로드 시 이미 active 처리됐으므로 skip
    if (!el.classList.contains('active')) {
      revealObserver.observe(el);
    }
  });

  /* ══════════════════════════════════════════
     2. 캐러셀 화살표
  ══════════════════════════════════════════ */
  document.querySelectorAll('.carousel-wrapper').forEach((wrapper) => {
    const list = wrapper.querySelector('.horizontal-list');
    const prevBtn = wrapper.querySelector('.nav-arrow.prev');
    const nextBtn = wrapper.querySelector('.nav-arrow.next');

    if (!list) return;

    const SCROLL_AMOUNT = 320;

    if (prevBtn) {
      prevBtn.addEventListener('click', () => {
        list.scrollBy({ left: -SCROLL_AMOUNT, behavior: 'smooth' });
      });
    }

    if (nextBtn) {
      nextBtn.addEventListener('click', () => {
        list.scrollBy({ left: SCROLL_AMOUNT, behavior: 'smooth' });
      });
    }

    // 화살표 가시성 업데이트
    function updateArrows() {
      if (prevBtn) prevBtn.style.opacity = list.scrollLeft <= 0 ? '0.3' : '1';
      if (nextBtn) {
        const atEnd = list.scrollLeft + list.clientWidth >= list.scrollWidth - 4;
        nextBtn.style.opacity = atEnd ? '0.3' : '1';
      }
    }

    list.addEventListener('scroll', updateArrows, { passive: true });
    updateArrows();
  });

  /* ══════════════════════════════════════════
     3. 히어로 패럴랙스 (가벼운 시차)
  ══════════════════════════════════════════ */
  const heroBg = document.getElementById('heroBg');

  if (heroBg) {
    window.addEventListener('scroll', () => {
      const scrollY = window.scrollY;
      // 히어로 높이의 절반까지만 작동
      const heroHeight = heroBg.parentElement.offsetHeight;
      if (scrollY < heroHeight) {
        heroBg.style.transform = `translateY(${scrollY * 0.3}px)`;
      }
    }, { passive: true });
  }

  /* ══════════════════════════════════════════
     4. 위젯 카드 진입 애니메이션
     (widget-section 은 reveal 클래스로 처리되지만
      추가로 카드 자체에 페이드인 효과 부여)
  ══════════════════════════════════════════ */
  const widgetCard = document.querySelector('.trip-widget');
  if (widgetCard) {
    widgetCard.style.opacity = '0';
    widgetCard.style.transform = 'translateY(24px)';
    widgetCard.style.transition = 'opacity 0.7s ease, transform 0.7s cubic-bezier(0.34, 1.56, 0.64, 1)';

    // 약간의 딜레이 후 페이드인 (히어로 로드 후 자연스럽게)
    setTimeout(() => {
      widgetCard.style.opacity = '1';
      widgetCard.style.transform = 'translateY(0)';
    }, 300);
  }

})();
