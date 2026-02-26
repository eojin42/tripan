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
    <div class="nav-logo">
      <a href="#" class="brand-logo" id="logoText">
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
    
    <div class="nav-menu-wrapper">
      <ul class="nav-menu">
        <li class="nav-item"><a href="#" class="nav-link">AI 플래너</a></li>
        <li class="nav-item"><a href="#" class="nav-link">숙소·맛집 추천</a></li>
        <li><a href="${pageContext.request.contextPath}/community/feed">커뮤니티 피드</a></li>
        <li class="nav-item"><a href="#" class="nav-link">가계부·N빵</a></li>
      </ul>
    </div>
    <div class="nav-right">
     	<button type="button" class="btn-login" onclick="location.href='${pageContext.request.contextPath}/member/login'">로그인 / 시작하기</button>
    </div>
  </nav>