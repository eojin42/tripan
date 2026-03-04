<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

  <footer class="reveal">
    <div class="footer-top">
      <div class="footer-company-info">
        <div class="brand-logo" style="font-size: 30px; margin-bottom: 16px;">
          <div class="logo-text-wrapper">
            <span class="trip" style="color: var(--text-black); text-shadow: none;">Tri</span><span class="an">pan</span>
            <div class="logo-track">
              <div class="logo-line"></div>
              <svg class="logo-plane" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                <path d="M22,16v-2l-8.5-5V3.5C13.5,2.67 12.83,2 12,2s-1.5,0.67-1.5,1.5V9L2,14v2l8.5-2.5V19L8.5,20.5V22L12,21l3.5,1v-1.5L13.5,19v-5.5L22,16z" />
              </svg>
            </div>
          </div>
          <span class="logo-dot">.</span>
        </div>
        <p class="footer-desc">함께 노는 여행 플래너 & 정산 솔루션</p>
        <p class="footer-address">
          주식회사 스프링 (Tripan Project)<br>
          서울특별시 강남구 테헤란로 123, 4층<br>
          대표: 조장님 | 사업자등록번호: 123-45-67890<br>
          고객센터: 1588-0000
        </p>
      </div>

      <div class="footer-links">
        <div class="footer-links-col">
          <strong>SERVICE</strong>
          <a href="#">AI 추천 일정 만들기</a>
          <a href="#">실시간 공동 편집 가이드</a>
          <a href="#">여행 가계부 & N빵 정산</a>
          <a href="#">소셜 여행기 커뮤니티</a>
        </div>
        <div class="footer-links-col">
          <strong>PARTNERS</strong>
          <a href="#">입점사(숙소/티켓) 관리자 센터</a>
          <a href="#">B2B 제휴 및 수수료 안내</a>
          <a href="#">광고 및 마케팅 문의</a>
        </div>
        <div class="footer-links-col">
          <strong>SUPPORT</strong>
          <a href="#">고객센터 (FAQ)</a>
          <a href="#">공지사항</a>
          <a href="#">이용약관</a>
          <a href="#">개인정보처리방침</a>
        </div>
      </div>
    </div>

    <div class="footer-bottom">
      <p>© 2026 SPRING Corp. / Tripan Project. All rights reserved.</p>
      <div class="social-links">
        <a href="#" aria-label="Instagram">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="2" y="2" width="20" height="20" rx="5" ry="5"></rect><path d="M16 11.37A4 4 0 1 1 12.63 8 4 4 0 0 1 16 11.37z"></path><line x1="17.5" y1="6.5" x2="17.51" y2="6.5"></line></svg>
        </a>
        <a href="#" aria-label="YouTube">
          <svg viewBox="0 0 24 24" fill="currentColor"><path d="M23.498 6.186a3.016 3.016 0 0 0-2.122-2.136C19.505 3.545 12 3.545 12 3.545s-7.505 0-9.377.505A3.017 3.017 0 0 0 .502 6.186C0 8.07 0 12 0 12s0 3.93.502 5.814a3.016 3.016 0 0 0 2.122 2.136c1.871.505 9.376.505 9.376.505s7.505 0 9.377-.505a3.015 3.015 0 0 0 2.122-2.136C24 15.93 24 12 24 12s0-3.93-.502-5.814zM9.545 15.568V8.432L15.818 12l-6.273 3.568z"/></svg>
        </a>
        <a href="#" aria-label="X (Twitter)">
          <svg viewBox="0 0 24 24" fill="currentColor"><path d="M18.244 2.25h3.308l-7.227 8.26 8.502 11.24H16.17l-5.214-6.817L4.99 21.75H1.68l7.73-8.835L1.254 2.25H8.08l4.713 6.231zm-1.161 17.52h1.833L7.084 4.126H5.117z"/></svg>
        </a>
      </div>
    </div>
  </footer>

  <script>
    document.addEventListener("DOMContentLoaded", () => {
      // 네비게이션 스크롤 효과
      const navbar = document.getElementById('navbar');
      const logoText = document.getElementById('logoText');
      
      window.addEventListener('scroll', () => {
        if (window.scrollY > 30) {
          if (navbar) navbar.classList.add('scrolled');
          if (logoText) logoText.querySelector('.trip').style.color = 'var(--text-black)';
        } else {
          if (navbar) navbar.classList.remove('scrolled');
          if (logoText) logoText.querySelector('.trip').style.color = 'white';
        }
      });

      // 히어로 이미지 패럴랙스 효과
      const heroBg = document.getElementById('heroBg');
      if (heroBg) {
        window.addEventListener('scroll', () => {
          heroBg.style.transform = `translateY(${window.scrollY * 0.25}px)`;
        });
      }

      // 스크롤 페이드인 애니메이션
      const reveals = document.querySelectorAll('.reveal');
      const revealOptions = { threshold: 0.15, rootMargin: "0px 0px -50px 0px" };
      const revealOnScroll = new IntersectionObserver((entries, observer) => {
        entries.forEach(entry => {
          if (entry.isIntersecting) {
            entry.target.classList.add('active');
            observer.unobserve(entry.target);
          }
        });
      }, revealOptions);
      reveals.forEach(reveal => revealOnScroll.observe(reveal));
      
      setTimeout(() => {
        document.querySelectorAll('.hero-overlay .reveal').forEach(el => el.classList.add('active'));
      }, 100);

      // 가로형 캐러셀 슬라이드 기능
      const carousels = document.querySelectorAll('.carousel-wrapper');
      carousels.forEach(wrapper => {
        const list = wrapper.querySelector('.horizontal-list');
        const prevBtn = wrapper.querySelector('.nav-arrow.prev');
        const nextBtn = wrapper.querySelector('.nav-arrow.next');
        
        if (prevBtn && nextBtn && list) {
          prevBtn.addEventListener('click', () => list.scrollBy({ left: -320, behavior: 'smooth' }));
          nextBtn.addEventListener('click', () => list.scrollBy({ left: 320, behavior: 'smooth' }));
        }
      });
    });
  </script>
</body>
</html>