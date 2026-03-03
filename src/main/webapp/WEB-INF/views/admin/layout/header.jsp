<%@ page contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<%-- ▼ 폰트 + CSS --%>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Sora:wght@600;700;800&family=Noto+Sans+KR:wght@400;500;700;900&display=swap" rel="stylesheet">
<link rel="stylesheet" href="${pageContext.request.contextPath}/dist/css/admin.css">

<style>
  /* 1. 관리자 헤더를 메인 템플릿처럼 둥글고 떠있게(Floating) 변경 */
  .top-navbar {
    position: fixed; 
    top: 20px; 
    left: 50%; 
    transform: translateX(-50%); 
    width: 95%; 
    max-width: 1400px; 
    height: 72px;
    background: rgba(255, 255, 255, 0.85); 
    backdrop-filter: blur(24px); 
    -webkit-backdrop-filter: blur(24px);
    border-radius: 100px; /* 헤더를 동그랗게 만들어줍니다 */
    box-shadow: 0 8px 32px rgba(45, 55, 72, 0.05);
    display: flex; 
    align-items: center; 
    justify-content: space-between;
    padding: 0 28px; 
    z-index: 1000;
    border: 1px solid rgba(255, 255, 255, 0.7);
  }

  /* 2. 메인 페이지의 비행기 로고 스타일 가져오기 */
  .brand-logo { 
    font-size: 24px; font-weight: 900; letter-spacing: -0.5px;
    display: flex; align-items: center; text-decoration: none;
    color: #2D3748;
  }
  .brand-logo .trip { color: #2D3748; } /* 관리자용은 바탕이 밝으므로 어두운 색 유지 */
  .brand-logo .an {
    background: linear-gradient(to right, #89CFF0, #FFB6C1); /* 메인 CSS의 var(--logo-line-gradient) */
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
    display: inline-block;
  }
  .logo-text-wrapper { position: relative; display: inline-block; padding-bottom: 4px; line-height: 1; }
  .logo-track { position: absolute; left: 0; bottom: 0; width: 100%; height: 3px; }
  .logo-line {
    width: 100%; height: 100%; border-radius: 2px; 
    background: linear-gradient(to right, #89CFF0, #FFB6C1); 
    transform-origin: left center; transform: scaleX(0); 
    animation: drawLine 1.5s cubic-bezier(0.4, 0, 0.2, 1) forwards; animation-delay: 0.2s;
  }
  .logo-plane {
    position: absolute; bottom: -6px; left: -15px; width: 16px; height: 16px;
    fill: #89CFF0; transform: rotate(90deg); opacity: 0;
    animation: flyPlane 1.5s cubic-bezier(0.4, 0, 0.2, 1) forwards; animation-delay: 0.2s; pointer-events: none;
  }
  
  /* SUPER 뱃지 스타일 */
  .super-badge {
    font-size: 11px;
    font-weight: 800;
    background: #2D3748;
    color: white;
    padding: 3px 8px;
    border-radius: 12px;
    margin-left: 8px;
    letter-spacing: 0.5px;
  }

  @keyframes drawLine { 0% { transform: scaleX(0); } 100% { transform: scaleX(1); } }
  @keyframes flyPlane {
    0% { left: -15px; opacity: 0; transform: rotate(90deg) scale(0.5); }
    10% { opacity: 1; transform: rotate(90deg) scale(1); }
    90% { left: 100%; opacity: 1; transform: rotate(90deg) scale(1); }
    100% { left: 100%; opacity: 0; transform: rotate(90deg) scale(0.2); } 
  }
  
  /* nav-left 레이아웃 조정 */
  .nav-left { display: flex; align-items: center; gap: 20px; }
  .nav-menu { display: flex; align-items: center; gap: 16px; list-style: none; margin: 0; padding: 0; }
</style>

<nav class="top-navbar">
  <div class="nav-left">
    <a href="${pageContext.request.contextPath}/admin/dashboard" class="brand-logo">
      <div class="logo-text-wrapper">
        <span class="trip">Trip</span><span class="an">an</span> 
        <div class="logo-track">
          <div class="logo-line"></div>
          <svg class="logo-plane" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
            <path d="M22,16v-2l-8.5-5V3.5C13.5,2.67 12.83,2 12,2s-1.5,0.67-1.5,1.5V9L2,14v2l8.5-2.5V19L8.5,20.5V22L12,21l3.5,1v-1.5L13.5,19v-5.5L22,16z" /> [cite: 32]
          </svg>
        </div>
      </div>
      <span class="super-badge">SUPER</span>
    </a>
    
    <div class="nav-sep" style="width: 1px; height: 24px; background: #E2E8F0; margin: 0 8px;"></div>

    <ul class="nav-menu">
      <li class="nav-item ${param.activePage == 'dashboard' ? 'active' : ''}"
        onclick="location.href='${pageContext.request.contextPath}/admin'">Dashboard</li>

      <li class="nav-item has-dd ${param.activePage == 'stats' ? 'active' : ''}">
        통계 및 정산
        <div class="dropdown-panel">
          <a href="${pageContext.request.contextPath}/admin/settlement">
            <span class="dp-icon">📊</span>전체 매출 현황
          </a>
          <a href="${pageContext.request.contextPath}/admin/accomsales">
            <span class="dp-icon">🏨</span>숙소별 매출 통계
          </a>
        </div>
      </li>

      <li class="nav-item has-dd ${param.activePage == 'partner' ? 'active' : ''}">
        파트너사 관리
        <div class="dropdown-panel">
          <a href="#"><span class="dp-icon">🤝</span>파트너 목록</a>
          <a href="#"><span class="dp-icon">📝</span>계약 관리</a>
          <a href="#"><span class="dp-icon">💰</span>정산 내역</a>
        </div>
      </li>

      <li class="nav-item ${param.activePage == 'booking' ? 'active' : ''}"
        onclick="location.href='${pageContext.request.contextPath}/admin/bookings'">예약 내역</li>

      <li class="nav-item ${param.activePage == 'cs' ? 'active' : ''}"
        onclick="location.href='${pageContext.request.contextPath}/admin/cs'">회원/CS 관리</li>
    </ul>
  </div>

  <div class="nav-right" style="display: flex; align-items: center; gap: 12px;">
    <div class="search-box">
      <svg viewBox="0 0 24 24" width="16" height="16" fill="none" stroke="currentColor" stroke-width="2"><circle cx="11" cy="11" r="8"></circle><line x1="21" y1="21" x2="16.65" y2="16.65"></line></svg>
      <input type="text" placeholder="메뉴 검색...">
    </div>

    <button class="icon-btn" title="메인 서비스로 이동"
      onclick="location.href='${pageContext.request.contextPath}/'">
      <svg viewBox="0 0 24 24" width="18" height="18" fill="none" stroke="currentColor" stroke-width="2"><path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"></path><polyline points="9 22 9 12 15 12 15 22"></polyline></svg>
    </button>

    <button class="icon-btn" title="알림">
      <svg viewBox="0 0 24 24" width="18" height="18" fill="none" stroke="currentColor" stroke-width="2"><path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9"></path><path d="M13.73 21a2 2 0 0 1-3.46 0"></path></svg>
      <span class="notif-badge">3</span>
    </button>

    <div class="profile-wrapper">
      <button class="profile-btn" style="border:none; background:none; display:flex; align-items:center; gap:8px; cursor:pointer;">
        <div class="avatar" style="width:32px; height:32px; border-radius:50%; background:#2D3748; color:white; display:flex; align-items:center; justify-content:center; font-weight:bold;">M</div>
        <div class="profile-text" style="text-align:left; line-height:1.2;">
          <span class="profile-name" style="display:block; font-size:13px; font-weight:700; color:#2D3748;">Manager</span>
          <span class="profile-role" style="display:block; font-size:11px; color:#718096;">Super Admin</span>
        </div>
        <svg class="chevron-icon" viewBox="0 0 24 24" width="14" height="14" fill="none" stroke="currentColor" stroke-width="2"><polyline points="6 9 12 15 18 9"></polyline></svg>
      </button>
      <div class="profile-dropdown">
        <div class="pd-header">
          <div class="pd-name">관리자 (Manager)</div>
          <div class="pd-email">admin@tripan.co.kr</div>
        </div>
        <a href="#">👤 내 프로필</a>
        <a href="#">⚙️ 환경설정</a>
        <a href="#">🔒 보안 설정</a>
        <div class="pd-sep"></div>
        <a href="${pageContext.request.contextPath}/logout" class="pd-danger">🚪 로그아웃</a>
      </div>
    </div>
  </div>
</nav>