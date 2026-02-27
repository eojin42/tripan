<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<%-- ✨ 스프링 시큐리티 태그 라이브러리 --%>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Tripan - 감성 파스텔 여행 플래너</title>
  
  <link rel="preconnect" href="https://cdn.jsdelivr.net">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/gh/orioncactus/pretendard@v1.3.8/dist/web/static/pretendard.css">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/dist/css/main.css">
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
                <path d="M22,16v-2l-8.5-5V3.5C13.5,2.67 12.83,2 12,2s-1.5,0.67-1.5,1.5V9L2,14v2l8.5-2.5V19L8.5,20.5V22L12,21l3.5,1v-1.5L13.5,19v-5.5L22,16z"></path>
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
            <a href="#" class="nav-link">여행 플래너</a>
            <div class="dropdown-menu">
              <a href="#">AI 맞춤형 일정 자동 생성</a>
              <a href="#">실시간 일정 공동 편집</a>
              <a href="#">동행자 목적지 투표</a>
              <a href="#">준비물 체크리스트</a>
            </div>
          </li>
          
          <li class="nav-item">
            <a href="#" class="nav-link">숙소 예약</a>
            <div class="dropdown-menu">
              <a href="#">지역별 숙소 검색</a>
              <a href="#">할인 및 쿠폰 혜택</a>
              <a href="#">최근 본 숙소 추천</a>
            </div>
          </li>
          
          <li class="nav-item">
            <a href="${pageContext.request.contextPath}/community/feed" class="nav-link">커뮤니티</a>
            <div class="dropdown-menu">
              <a href="#">소셜 여행기 피드</a>
              <a href="#">실시간 지역 채팅방</a>
              <a href="#">자유 게시판 (정보 공유)</a>
              <a href="#">지역별 축제 및 행사</a>
            </div>
          </li>
          
          <li class="nav-item">
            <a href="#" class="nav-link">가계부·안내</a>
            <div class="dropdown-menu">
              <a href="#">실시간 여행 가계부</a>
              <a href="#">Tripan 이용 가이드</a>
              <a href="#">자주 묻는 질문 (FAQ)</a>
              <a href="#">1:1 문의 게시판</a>
            </div>
          </li>
          
        </ul>
      </div>
      
      <div class="nav-right" style="flex: none; justify-content: flex-end;">
        
        <%-- 비로그인 상태 --%>
        <sec:authorize access="isAnonymous()">
          <button type="button" class="btn-login" onclick="location.href='${pageContext.request.contextPath}/member/login'">로그인</button>
        </sec:authorize>
        
        <%-- 로그인 상태 --%>
        <sec:authorize access="isAuthenticated()">
          <div class="nav-item user-profile-item" style="height: 100%; display: flex; align-items: center;">
             <a href="#" class="nav-link" style="display:flex; align-items:center; gap:8px; padding: 6px 16px;">
               <img src="${pageContext.request.contextPath}/uploads/member/${sessionScope.loginUser.profilePhoto}" alt="profile" 
                    style="width: 32px; height: 32px; border-radius: 50%; object-fit: cover; border: 2px solid var(--border-light);">
               <span style="font-weight: 800; color: var(--text-black);">${sessionScope.loginUser.nickname}님</span>
             </a>
             
             <div class="dropdown-menu" style="left: auto; right: 0; transform-origin: top right; transform: translateY(10px) scale(0.95);">
               <a href="#">마이페이지 홈</a>
               <a href="#">나의 여행 지도 (국토 정복)</a>
               <a href="#">내 여행 일정 / 동행 코스</a>
               <a href="#">내 쿠폰 및 저장(찜)</a>
               <a href="#">내 활동 배지 / 칭호</a>
               <hr style="border: none; border-top: 1px solid rgba(255, 255, 255, 0.4); margin: 8px 0;">
	              <form action="${pageContext.request.contextPath}/member/logout" method="post" style="margin: 0; display: block;">
                   <sec:csrfInput/> <button type="submit" style="width: 100%; text-align: left; padding: 12px 16px; border-radius: 12px; color: var(--error-pink); font-size: 14px; font-weight: 600; cursor: pointer; transition: all 0.2s; background: transparent; border: none; font-family: var(--font-sans);">
                        로그아웃
                   </button>
               </form>
             </div>
          </div>
          
          <style>
            .user-profile-item:hover .dropdown-menu {
              transform: translateY(0) scale(1) !important;
              opacity: 1 !important;
              visibility: visible !important;
              pointer-events: auto !important;
            }
          </style>
        </sec:authorize>
        
      </div>
    </div>
  </nav>

</body>
</html>