<%@ page contentType="text/html; charset=UTF-8" %>

  <!-- 공통 푸터 영역 -->
  <footer class="reveal">
    <div class="footer-top">
      <div>
        <div class="footer-brand">Tripan</div>
        <p style="font-weight: 700;">함께 노는 여행 플래너 & 정산 솔루션</p>
      </div>
      <div class="footer-links">
        <ul>
          <li><strong>ABOUT</strong></li>
          <li><a href="#">SPRING 정책 및 약관</a></li>
          <li><a href="#">회사소개</a></li>
          <li><a href="#">제휴제안</a></li>
        </ul>
        <ul>
          <li><strong>SUPPORT</strong></li>
          <li><a href="#">고객센터</a></li>
          <li><a href="#">자주 묻는 질문</a></li>
        </ul>
        <ul>
          <li><strong>LEGAL</strong></li>
          <li><a href="#">이용약관</a></li>
          <li><a href="#">개인정보취급방침</a></li>
        </ul>
      </div>
    </div>
    <div class="footer-bottom">
      <p>© 2026 SPRING Corp. / Tripan Project</p>
      <div style="display: flex; gap: 24px;">
        <a href="#">Instagram</a>
        <a href="#">TikTok</a>
      </div>
    </div>
  </footer>

  <!-- 공통 스크립트 영역 -->
  <script>
    document.addEventListener("DOMContentLoaded", () => {
      // 플로팅 네비게이션 스크롤 효과
      const navbar = document.getElementById('navbar');
      window.addEventListener('scroll', () => {
        if (window.scrollY > 50) {
          navbar.classList.add('scrolled');
        } else {
          navbar.classList.remove('scrolled');
        }
      });

      // 바운스 페이드인 효과
      const reveals = document.querySelectorAll('.reveal');
      const revealOptions = {
        threshold: 0.15,
        rootMargin: "0px 0px -50px 0px"
      };

      const revealOnScroll = new IntersectionObserver((entries, observer) => {
        entries.forEach(entry => {
          if (!entry.isIntersecting) return;
          entry.target.classList.add('active');
          observer.unobserve(entry.target);
        });
      }, revealOptions);

      reveals.forEach(reveal => {
        revealOnScroll.observe(reveal);
      });
      
      setTimeout(() => {
        document.querySelectorAll('.hero-overlay .reveal').forEach(el => {
          el.classList.add('active');
        });
      }, 100);
    });
  </script>
</body>
</html>