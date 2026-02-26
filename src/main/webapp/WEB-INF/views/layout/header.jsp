<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt"%>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Tripan - 힙한 실시간 소셜 여행 플래너</title>
  <link rel="preconnect" href="https://cdn.jsdelivr.net">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/gh/orioncactus/pretendard@v1.3.8/dist/web/static/pretendard.css">
  <style>
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

    .reveal {
      opacity: 0;
      transform: translateY(50px) scale(0.95);
      transition: all 0.7s var(--bounce);
    }
    .reveal.active { opacity: 1; transform: translateY(0) scale(1); }
    .delay-100 { transition-delay: 100ms; }
    .delay-200 { transition-delay: 200ms; }
    .delay-300 { transition-delay: 300ms; }

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
    .hero-img img { filter: saturate(1.2) contrast(1.1); } 
    
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
    
    .list-img { 
      position: relative; width: 100%; aspect-ratio: 4/5; overflow: hidden; 
      margin-bottom: 20px; border-radius: var(--radius-lg); 
      box-shadow: 0 8px 24px rgba(0,0,0,0.06);
    }
    .list-img img { transition: transform 0.5s var(--bounce); }
    
    .list-item:hover .list-img { transform: translateY(-10px); box-shadow: 0 16px 32px rgba(255, 107, 107, 0.15); }
    .list-item:hover .list-img img { transform: scale(1.08); }
    
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
    
    .author-info { display: flex; align-items: center; gap: 8px; font-size: 13px; font-weight: 700; color: var(--text-dark); }
    .author-pic { width: 28px; height: 28px; border-radius: 50%; background: #ccc; border: 2px solid white; outline: 2px solid var(--pop-yellow); }

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
  <!-- 공통 네비게이션 바 -->
  <nav id="navbar">
    <div class="nav-left">
      <a href="/" class="logo">Tripan</a>
      <ul class="nav-menu">
        <li><a href="#">커뮤니티 피드</a></li>
        <li><a href="#">숙소 트렌드</a></li>
        <li><a href="#">나의 여행기</a></li>
      </ul>
    </div>
    <div class="nav-right">
      <div class="search-bar">
        <input type="text" placeholder="핫플, 숙소, 유저 검색">
      </div>
      <sec:authorize access="isAnonymous()">
        <a href="${pageContext.request.contextPath}/member/login" class="btn-login">로그인</a>
      </sec:authorize>
      <sec:authorize access="isAuthenticated()">
        <a href="${pageContext.request.contextPath}/member/logout" class="btn-login" style="background: var(--vivid-coral);">로그아웃</a>
      </sec:authorize>
    </div>
  </nav>