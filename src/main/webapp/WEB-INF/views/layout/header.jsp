<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Tripan - 감성 파스텔 여행 플래너</title>
  
  <link rel="preconnect" href="https://cdn.jsdelivr.net">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/gh/orioncactus/pretendard@v1.3.8/dist/web/static/pretendard.css">
  
  <link rel="stylesheet" href="/dist/css/main.css">
</head>
<body>

  <nav id="navbar">
    
    <div style="display: flex; align-items: center; gap: 32px; flex: 1;">
      
      <div class="nav-logo" style="flex: none;">
        <a href="${pageContext.request.contextPath}/" class="brand-logo" id="logoText">
          <div class="logo-text-wrapper">
            <span class="trip">Tri</span><span class="an">pan</span>
            <div class="logo-track">
              <div class="logo-line"></div>
              <svg class="logo-plane" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                <path d="M22,16v-2l-8.5-5V3.5C13.5,2.67 12.83,2 12,2s-1.5,0.67-1.5,1.5V9L2,14v2l8.5-2.5V19L8.5,20.5V22L12,21l3.5,1v-1.5L13.5,19v-5.5L22,16z" />
              </svg>
            </div>
          </div>
          <span class="logo-dot">.</span>
        </a>
      </div>

      <div class="header-search">
        <svg class="search-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
          <circle cx="11" cy="11" r="8"></circle><line x1="21" y1="21" x2="16.65" y2="16.65"></line>
        </svg>
        <input type="text" placeholder="핫플, 숙소, 유저 검색">
      </div>
      
    </div>
    
    <div style="display: flex; align-items: center; gap: 24px; justify-content: flex-end; flex: 2;">
      
      <div class="nav-menu-wrapper" style="flex: none;">
        <ul class="nav-menu">
          
          <li class="nav-item">
            <a href="#" class="nav-link">AI 플래너</a>
            <div class="dropdown-menu">
              <a href="#">✨ 일정 만들기 (동선 추천)</a>
              <a href="#">📝 준비물 체크리스트</a>
            </div>
          </li>
          
          <li class="nav-item">
            <a href="#" class="nav-link">숙소·맛집 추천</a>
            <div class="dropdown-menu">
              <a href="#">🏨 지역별 숙소 검색</a>
              <a href="#">🎁 할인 및 쿠폰 혜택</a>
            </div>
          </li>
          
          <li class="nav-item">
            <a href="${pageContext.request.contextPath}/community/feed" class="nav-link">커뮤니티 피드</a>
            <div class="dropdown-menu">
              <a href="#">💬 실시간 지역 채팅방</a>
              <a href="#">📋 자유 게시판 (정보 공유)</a>
              <a href="#">🎉 지역별 축제 및 행사</a>
            </div>
          </li>
          
          <li class="nav-item">
            <a href="#" class="nav-link">가계부·N빵</a>
            <div class="dropdown-menu">
              <a href="#">💸 여행 가계부 작성</a>
              <a href="#">🙋 고객센터 및 FAQ</a>
            </div>
          </li>
          
        </ul>
      </div>
      
      <div class="nav-right" style="flex: none; justify-content: flex-end;">
        <button type="button" class="btn-login" onclick="location.href='${pageContext.request.contextPath}/member/login'">로그인</button>
      </div>
      
    </div>
    
  </nav>