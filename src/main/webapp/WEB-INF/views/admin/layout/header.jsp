<%@ page contentType="text/html; charset=UTF-8"%>
<header class="top-header">
  
  <div class="header-left" style="display: flex; align-items: center;">
    <a href="${pageContext.request.contextPath}/admin/dashboard" class="brand-logo">
      <div class="logo-text-wrapper">
        <span class="trip">Trip</span><span class="an">an</span> 
        <div class="logo-track">
          <div class="logo-line"></div>
          <svg class="logo-plane" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
            <path d="M22,16v-2l-8.5-5V3.5C13.5,2.67 12.83,2 12,2s-1.5,0.67-1.5,1.5V9L2,14v2l8.5-2.5V19L8.5,20.5V22L12,21l3.5,1v-1.5L13.5,19v-5.5L22,16z" />
          </svg>
        </div>
      </div>
      <span class="super-badge">ADMIN</span>
    </a>
  </div>

  <div class="nav-right" style="display: flex; align-items: center; gap: 12px;">
    
    <div class="search-box">
      <svg viewBox="0 0 24 24" width="16" height="16" fill="none" stroke="currentColor" stroke-width="2"><circle cx="11" cy="11" r="8"></circle><line x1="21" y1="21" x2="16.65" y2="16.65"></line></svg>
      <input type="text" placeholder="통합 검색...">
    </div>

    <button class="icon-btn" title="메인 서비스로 이동" onclick="location.href='${pageContext.request.contextPath}/'">
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
        <div class="pd-sep"></div>
        <a href="${pageContext.request.contextPath}/logout" class="pd-danger">🚪 로그아웃</a>
      </div>
    </div>
  </div>
</header>