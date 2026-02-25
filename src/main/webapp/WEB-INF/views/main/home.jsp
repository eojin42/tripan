<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt"%>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Tripan - 힙한 실시간 소셜 여행 플래너</title>
  <link rel="preconnect" href="https://cdn.jsdelivr.net">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/gh/orioncactus/pretendard@v1.3.8/dist/web/static/pretendard.css">
  <style>
    /* --- 팝(Pop) & 다이내믹 소셜 디자인 시스템 --- */
    :root {
      --bg-white: #FFFFFF;
      --bg-light: #F4F7F6;
      --text-black: #111111;
      --text-dark: #333333;
      --text-gray: #888888;
      --vivid-coral: #FF6B6B;
      --electric-blue: #4D96FF;
      --pop-yellow: #FFD93D;
      --border-light: #EEEEEE;
      --radius-sm: 16px;
      --radius-lg: 32px;
      --font-sans: 'Pretendard', sans-serif;
      /* 통통 튀는 바운스 애니메이션 베지어 곡선 */
      --bounce: cubic-bezier(0.68, -0.55, 0.26, 1.55);
    }

    * { margin: 0; padding: 0; box-sizing: border-box; }
    body { 
      background-color: var(--bg-white); 
      color: var(--text-black); 
      font-family: var(--font-sans); 
      line-height: 1.5; 
      -webkit-font-smoothing: antialiased;
      overflow-x: hidden;
    }
    a { text-decoration: none; color: inherit; transition: color 0.3s ease; }
    ul { list-style: none; }
    img { width: 100%; height: 100%; object-fit: cover; display: block; }

    /* --- 다이내믹 페이드인 애니메이션 --- */
    .reveal {
      opacity: 0;
      transform: translateY(50px) scale(0.95);
      transition: all 0.7s var(--bounce);
    }
    .reveal.active { opacity: 1; transform: translateY(0) scale(1); }
    .delay-100 { transition-delay: 100ms; }
    .delay-200 { transition-delay: 200ms; }
    .delay-300 { transition-delay: 300ms; }

    /* --- 플로팅 네비게이션 --- */
    nav {
      position: fixed; top: 16px; left: 5%; right: 5%; height: 72px;
      background: rgba(255, 255, 255, 0.85);
      backdrop-filter: blur(16px); -webkit-backdrop-filter: blur(16px);
      border-radius: 36px;
      box-shadow: 0 8px 32px rgba(0, 0, 0, 0.08);
      display: flex; align-items: center; justify-content: space-between;
      padding: 0 32px; z-index: 1000; transition: all 0.4s ease;
      border: 1px solid rgba(255, 255, 255, 0.5);
    }
    nav.scrolled {
      top: 0; left: 0; right: 0; border-radius: 0;
      background: rgba(255, 255, 255, 0.98);
    }
    
    .nav-left { display: flex; align-items: center; gap: 32px; }
    .logo { 
      font-size: 26px; font-weight: 900; 
      letter-spacing: -1px; text-transform: uppercase;
      background: linear-gradient(135deg, var(--vivid-coral), var(--electric-blue));
      -webkit-background-clip: text; -webkit-text-fill-color: transparent;
    }
    
    .nav-menu { display: flex; gap: 32px; font-size: 16px; font-weight: 700; }
    .nav-menu a { position: relative; color: var(--text-dark); }
    .nav-menu a:hover { color: var(--electric-blue); }
    
    /* --- 트렌디한 검색바 --- */
    .nav-right { display: flex; align-items: center; gap: 16px; }
    .search-bar {
      display: flex; align-items: center; background: var(--bg-light); 
      border-radius: 36px; padding: 12px 24px; width: 280px; 
      transition: all 0.4s var(--bounce); border: 2px solid transparent;
    }
    .search-bar:focus-within { 
      background: var(--bg-white); border-color: var(--vivid-coral); 
      box-shadow: 0 8px 24px rgba(255, 107, 107, 0.2); width: 340px; 
    }
    .search-bar input { 
      border: none; background: transparent; outline: none; 
      width: 100%; margin-left: 12px; font-size: 15px; font-weight: 600; font-family: var(--font-sans); color: var(--text-black);
    }
    
    .btn-login {
      padding: 12px 32px; background: var(--text-black); color: var(--bg-white);
      border-radius: 36px; font-size: 15px; font-weight: 800;
      transition: all 0.3s var(--bounce);
    }
    .btn-login:hover {
      background: var(--electric-blue); transform: translateY(-4px) scale(1.05);
      box-shadow: 0 10px 20px rgba(77, 150, 255, 0.3);
    }

    /* --- 메인 히어로 --- */
    main { padding-top: 0; } 
    .hero { 
      position: relative; width: 100%; height: 95vh; overflow: hidden;
      border-bottom-left-radius: 48px; border-bottom-right-radius: 48px;
    }
    .hero-img { width: 100%; height: 100%; }
    .hero-img img { filter: saturate(1.2) contrast(1.1); } /* 팝한 느낌을 위해 채도/대비 증가 */
    
    .hero-overlay {
      position: absolute; inset: 0; 
      background: linear-gradient(to top, rgba(17, 17, 17, 0.8) 0%, rgba(17, 17, 17, 0) 60%);
      display: flex; flex-direction: column; justify-content: flex-end; align-items: center;
      padding-bottom: 12vh; color: white; text-align: center;
    }
    .hero-label { 
      display: inline-block; background: var(--vivid-coral); color: white;
      font-size: 14px; font-weight: 800; padding: 6px 16px; border-radius: 20px;
      margin-bottom: 24px; letter-spacing: 1px;
      box-shadow: 0 4px 16px rgba(255, 107, 107, 0.4);
    }
    .hero-title { font-size: 56px; font-weight: 900; line-height: 1.2; margin-bottom: 16px; letter-spacing: -1px; }
    .hero-subtitle { font-size: 18px; font-weight: 500; opacity: 0.9; }

    /* --- 섹션 공통 --- */
    section { max-width: 1400px; margin: 120px auto; padding: 0 5%; }
    .section-header { display: flex; justify-content: space-between; align-items: flex-end; margin-bottom: 40px; }
    .section-header h2 { font-size: 32px; font-weight: 900; color: var(--text-black); letter-spacing: -0.5px; }
    .section-header p { font-size: 16px; font-weight: 600; color: var(--text-gray); }
    .btn-more { font-weight: 800; color: var(--electric-blue); font-size: 15px; cursor: pointer; }

    /* --- 스크롤 리스트 (릴스/스토리 감성) --- */
    .horizontal-list { display: flex; gap: 24px; overflow-x: auto; padding-bottom: 32px; scroll-snap-type: x mandatory; }
    .horizontal-list::-webkit-scrollbar { height: 8px; }
    .horizontal-list::-webkit-scrollbar-thumb { background: #ddd; border-radius: 10px; }
    .horizontal-list::-webkit-scrollbar-track { background: var(--bg-light); border-radius: 10px; }
    
    .list-item { min-width: 300px; flex: 0 0 auto; scroll-snap-align: start; cursor: pointer; position: relative; }
    
    /* 썸네일 (세로형 4:5 비율로 트렌디하게) */
    .list-img { 
      position: relative; width: 100%; aspect-ratio: 4/5; overflow: hidden; 
      margin-bottom: 20px; border-radius: var(--radius-lg); 
      box-shadow: 0 8px 24px rgba(0,0,0,0.06);
    }
    .list-img img { transition: transform 0.5s var(--bounce); }
    
    /* 호버 효과 (통통 튀는 바운스) */
    .list-item:hover .list-img { transform: translateY(-10px); box-shadow: 0 16px 32px rgba(255, 107, 107, 0.15); }
    .list-item:hover .list-img img { transform: scale(1.08); }
    
    /* 카드 내부 떠있는 정보 (좋아요/담아오기 뱃지) */
    .floating-badge {
      position: absolute; top: 16px; right: 16px;
      background: rgba(255, 255, 255, 0.9); backdrop-filter: blur(4px);
      padding: 6px 12px; border-radius: 20px; font-size: 13px; font-weight: 800;
      color: var(--vivid-coral); display: flex; align-items: center; gap: 4px;
      box-shadow: 0 4px 12px rgba(0,0,0,0.1);
    }
    
    .list-info .tag { font-size: 13px; font-weight: 800; color: var(--electric-blue); margin-bottom: 8px; display: block; }
    .list-info h4 { font-size: 20px; font-weight: 800; margin-bottom: 8px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; color: var(--text-black); letter-spacing: -0.5px; }
    .list-info .desc { font-size: 14px; font-weight: 600; color: var(--text-gray); margin-bottom: 12px; }
    
    /* 프로필 작성자 썸네일 효과 */
    .author-info { display: flex; align-items: center; gap: 8px; font-size: 13px; font-weight: 700; color: var(--text-dark); }
    .author-pic { width: 28px; height: 28px; border-radius: 50%; background: #ccc; border: 2px solid white; outline: 2px solid var(--pop-yellow); }

    /* 가로형 넓은 카드 (숙소 추천용) */
    .stay-card { min-width: 360px; }
    .stay-card .list-img { aspect-ratio: 16/10; border-radius: var(--radius-sm); }
    .stay-price { font-size: 18px; font-weight: 900; color: var(--vivid-coral); margin-top: 8px; }

    /* --- Footer --- */
    footer { border-top: 1px solid var(--border-light); padding: 80px 5% 60px; background: var(--bg-light); color: var(--text-dark); }
    .footer-top { display: flex; justify-content: space-between; margin-bottom: 60px; }
    .footer-brand { 
      font-size: 24px; font-weight: 900; letter-spacing: -1px; margin-bottom: 16px;
      background: linear-gradient(135deg, var(--vivid-coral), var(--electric-blue));
      -webkit-background-clip: text; -webkit-text-fill-color: transparent;
    }
    .footer-links { display: flex; gap: 60px; }
    .footer-links ul { display: flex; flex-direction: column; gap: 12px; font-weight: 600; }
    .footer-links strong { color: var(--text-black); font-size: 14px; margin-bottom: 8px; display: block; font-weight: 900; }
    .footer-bottom { display: flex; justify-content: space-between; align-items: center; border-top: 2px solid var(--bg-white); padding-top: 24px; font-weight: 700; font-size: 13px; }
  </style>
</head>
<body>

  <nav id="navbar">
    <div class="nav-left">
      <a href="#" class="logo">Tripan</a>
      <ul class="nav-menu">
        <li><a href="#">커뮤니티 피드</a></li>
        <li><a href="#">숙소 트렌드</a></li>
        <li><a href="#">나의 여행기</a></li>
      </ul>
    </div>
    <div class="nav-right">
      <div class="search-bar">
        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#333" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="8"></circle><line x1="21" y1="21" x2="16.65" y2="16.65"></line></svg>
        <input type="text" placeholder="핫플, 숙소, 유저 검색">
      </div>
      <a href="#" class="btn-login">로그인</a>
    </div>
  </nav>

  <main>
    <div class="hero">
      <div class="hero-img">
        <img src="https://images.unsplash.com/photo-1523482580672-f109ba8cb9be?auto=format&fit=crop&w=1920&q=80" alt="Active Travel">
      </div>
      <div class="hero-overlay">
        <span class="hero-label reveal">Tripan Social Collab</span>
        <h2 class="hero-title reveal delay-100">놀면서 짜는<br>진짜 우리만의 여행</h2>
        <p class="hero-subtitle reveal delay-200">구글 문서처럼 동시에 편집하고, 인스타처럼 공유하는 실시간 여행 플래너</p>
      </div>
    </div>

    <section>
      <div class="section-header reveal">
        <div>
          <h2>실시간 인기 피드 🔥</h2>
          <p>지금 이 순간 가장 많이 담겨진 여행 코스</p>
        </div>
        <div class="btn-more">전체보기 ➔</div>
      </div>
      
      <div class="horizontal-list">
        <div class="list-item reveal">
          <div class="list-img">
            <div class="floating-badge">❤️ 890</div>
            <img src="https://images.unsplash.com/photo-1493246507139-91e8fad9978e?auto=format&fit=crop&w=600&q=80" alt="Trip 1">
          </div>
          <div class="list-info">
            <span class="tag">#오사카 #가성비</span>
            <h4>오사카 3박4일 미친 동선</h4>
            <p class="desc">담아오기 1,204회 기록 돌파!</p>
            <div class="author-info">
              <div class="author-pic"><img src="https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=100&q=80"></div>
              @travel_holic
            </div>
          </div>
        </div>
        
        <div class="list-item reveal delay-100">
          <div class="list-img">
            <div class="floating-badge">❤️ 750</div>
            <img src="https://images.unsplash.com/photo-1506929562872-bb421503ef21?auto=format&fit=crop&w=600&q=80" alt="Trip 2">
          </div>
          <div class="list-info">
            <span class="tag">#제주도 #오션뷰카페</span>
            <h4>제주 동쪽 감성 숙소 투어</h4>
            <p class="desc">담아오기 980회 돌파!</p>
            <div class="author-info">
              <div class="author-pic"><img src="https://images.unsplash.com/photo-1524504388940-b1c1722653e1?auto=format&fit=crop&w=100&q=80"></div>
              @jeju_vibe
            </div>
          </div>
        </div>
        
        <div class="list-item reveal delay-200">
          <div class="list-img">
            <div class="floating-badge">❤️ 620</div>
            <img src="https://images.unsplash.com/photo-1512453979798-5ea266f8880c?auto=format&fit=crop&w=600&q=80" alt="Trip 3">
          </div>
          <div class="list-info">
            <span class="tag">#다낭 #먹방투어</span>
            <h4>다낭 4박 5일 1인 50컷</h4>
            <p class="desc">가성비 끝판왕 N빵 정산 내역 공개</p>
            <div class="author-info">
              <div class="author-pic"><img src="https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?auto=format&fit=crop&w=100&q=80"></div>
              @n_bread_master
            </div>
          </div>
        </div>
        
        <div class="list-item reveal delay-300">
          <div class="list-img">
            <div class="floating-badge">❤️ 540</div>
            <img src="https://images.unsplash.com/photo-1476514525535-07fb3b4ae5f1?auto=format&fit=crop&w=600&q=80" alt="Trip 4">
          </div>
          <div class="list-info">
            <span class="tag">#스위스 #렌터카</span>
            <h4>스위스 알프스 드라이브</h4>
            <p class="desc">인생샷 보장하는 로드트립 코스</p>
            <div class="author-info">
              <div class="author-pic"><img src="https://images.unsplash.com/photo-1438761681033-6461ffad8d80?auto=format&fit=crop&w=100&q=80"></div>
              @world_driver
            </div>
          </div>
        </div>
      </div>
    </section>

    <section>
      <div class="section-header reveal">
        <div>
          <h2>최근 살펴본 핫플 숙소 ✨</h2>
          <p>내 취향에 딱 맞는 테마 추천 리스트</p>
        </div>
      </div>
      
      <div class="horizontal-list">
        <div class="list-item stay-card reveal">
          <div class="list-img"><img src="https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?auto=format&fit=crop&w=600&q=80" alt="Stay 1"></div>
          <div class="list-info">
            <h4>스테이 폴라리스 (강릉)</h4>
            <p class="desc">오션뷰 · 인피니티 풀</p>
            <p class="stay-price">₩ 180,000 ~</p>
          </div>
        </div>
        <div class="list-item stay-card reveal delay-100">
          <div class="list-img"><img src="https://images.unsplash.com/photo-1566073771259-6a8506099945?auto=format&fit=crop&w=600&q=80" alt="Stay 2"></div>
          <div class="list-info">
            <h4>루나 부티크 펜션 (남해)</h4>
            <p class="desc">프라이빗 바베큐 · 독채 풀빌라</p>
            <p class="stay-price">₩ 240,000 ~</p>
          </div>
        </div>
        <div class="list-item stay-card reveal delay-200">
          <div class="list-img"><img src="https://images.unsplash.com/photo-1582719508461-905c673771fd?auto=format&fit=crop&w=600&q=80" alt="Stay 3"></div>
          <div class="list-info">
            <h4>포레스트 캐빈 (가평)</h4>
            <p class="desc">감성 글램핑 · 불멍 화로대</p>
            <p class="stay-price">₩ 150,000 ~</p>
          </div>
        </div>
      </div>
    </section>

    <section>
      <div class="section-header reveal">
        <div>
          <h2>Tripan TOP 10 🏆</h2>
          <p>예약 평점이 증명하는 믿고 가는 스테이</p>
        </div>
      </div>
      
      <div class="horizontal-list">
        <div class="list-item stay-card reveal">
          <div class="list-img">
            <div class="floating-badge" style="background: var(--text-black); color: var(--pop-yellow);">👑 TOP 1</div>
            <img src="https://images.unsplash.com/photo-1571003123894-1f0594d2b5d9?auto=format&fit=crop&w=600&q=80" alt="Top 1">
          </div>
          <div class="list-info">
            <h4>아만 스위트 리저브 (제주)</h4>
            <p class="desc">⭐ 4.9 · 리뷰 1,204개</p>
          </div>
        </div>
        
        <div class="list-item stay-card reveal delay-100">
          <div class="list-img">
            <div class="floating-badge">TOP 2</div>
            <img src="https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?auto=format&fit=crop&w=600&q=80" alt="Top 2">
          </div>
          <div class="list-info">
            <h4>그랜드 앰배서더 풀빌라 (부산)</h4>
            <p class="desc">⭐ 4.8 · 리뷰 890개</p>
          </div>
        </div>
        
        <div class="list-item stay-card reveal delay-200">
          <div class="list-img">
            <div class="floating-badge">TOP 3</div>
            <img src="https://images.unsplash.com/photo-1445019980597-93fa8acb246c?auto=format&fit=crop&w=600&q=80" alt="Top 3">
          </div>
          <div class="list-info">
            <h4>신라 더 파크 호텔 (서울)</h4>
            <p class="desc">⭐ 4.8 · 리뷰 750개</p>
          </div>
        </div>
      </div>
    </section>
  </main>

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