<%@ page contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<header class="top-header">
  
  <div class="header-left" style="display: flex; align-items: center; gap: 12px;">
    <%-- 모바일 전용 햄버거 버튼 (768px 이하에서만 표시) --%>
    <button class="mobile-menu-btn hamburger-btn" onclick="openMobileSidebar()" title="메뉴 열기" style="flex-shrink:0;">
      <svg viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round">
        <line x1="3" y1="12" x2="21" y2="12"></line>
        <line x1="3" y1="6" x2="21" y2="6"></line>
        <line x1="3" y1="18" x2="21" y2="18"></line>
      </svg>
    </button>
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

    <div class="notif-wrapper" style="position: relative; display: flex; align-items: center;">
      <button class="icon-btn" title="알림" onclick="toggleNotifDropdown(event)">
        <svg viewBox="0 0 24 24" width="18" height="18" fill="none" stroke="currentColor" stroke-width="2"><path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9"></path><path d="M13.73 21a2 2 0 0 1-3.46 0"></path></svg>
        <span class="notif-badge" style="display:none;">0</span>
      </button>

      <div id="notifDropdown" style="display:none; position:absolute; top:calc(100% + 15px); right:-10px; width:300px; background:#fff; border-radius:14px; box-shadow:0 10px 30px rgba(0,0,0,0.1); border:1px solid #E2E8F0; z-index:9999; overflow:hidden;">
        <div style="padding:14px 18px; border-bottom:1px solid #E2E8F0; display:flex; justify-content:space-between; align-items:center;">
          <span style="font-weight:800; font-size:14px; color:#2D3748;">🔔 알림</span>
          <button onclick="clearNotifs(event)" style="background:none; border:none; font-size:11px; color:#718096; cursor:pointer; font-weight:600;">모두 읽음</button>
        </div>
        <div id="notifList" style="max-height:340px; overflow-y:auto; display:flex; flex-direction:column;">
          <div id="emptyNotif" style="padding:30px 20px; text-align:center; color:#A0AEC0;">
            <i class="bi bi-bell-slash" style="font-size:24px; opacity:0.5; display:block; margin-bottom:8px;"></i>
            <span style="font-size:12px; font-weight:600;">새로운 알림이 없습니다.</span>
          </div>
        </div>
      </div>
    </div>

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
		<a href="#" onclick="document.getElementById('adminLogoutForm').submit(); return false;" class="pd-danger">🚪 로그아웃</a>
		<form id="adminLogoutForm" action="${pageContext.request.contextPath}/member/logout" method="post" style="display:none;">
		    <sec:csrfInput/>
		</form>
      </div>
    </div>
  </div>
</header>

<script>
      // 종 모양 클릭 시 열고 닫기
      function toggleNotifDropdown(e) {
        e.stopPropagation();
        var dropdown = document.getElementById('notifDropdown');
        dropdown.style.display = (dropdown.style.display === 'none' || dropdown.style.display === '') ? 'block' : 'none';
      }

      // 모두 읽음 처리
      function clearNotifs(e) {
        e.stopPropagation();
        var notifList = document.getElementById('notifList');
        notifList.innerHTML = `
          <div id="emptyNotif" style="padding:30px 20px; text-align:center; color:#A0AEC0;">
            <i class="bi bi-bell-slash" style="font-size:24px; opacity:0.5; display:block; margin-bottom:8px;"></i>
            <span style="font-size:12px; font-weight:600;">새로운 알림이 없습니다.</span>
          </div>
        `;
        var badge = document.querySelector('.notif-badge');
        if(badge) {
            badge.textContent = '0';
            badge.style.display = 'none';
        }
      }

      // 알림창 바깥을 클릭하면 자동으로 닫히게 설정
      document.addEventListener('click', function(e) {
        var dropdown = document.getElementById('notifDropdown');
        if (dropdown && dropdown.style.display === 'block') {
          var wrapper = document.querySelector('.notif-wrapper');
          if (wrapper && !wrapper.contains(e.target)) {
            dropdown.style.display = 'none';
          }
        }
      });
    </script>