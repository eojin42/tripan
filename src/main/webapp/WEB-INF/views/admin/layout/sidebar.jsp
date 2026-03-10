<%@ page contentType="text/html; charset=UTF-8"%>
<aside class="sidebar">
  
  <div class="sidebar-header">
    <button class="hamburger-btn" onclick="toggleSidebar()" title="메뉴 접기/펴기">
      <svg viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round">
        <line x1="3" y1="12" x2="21" y2="12"></line>
        <line x1="3" y1="6" x2="21" y2="6"></line>
        <line x1="3" y1="18" x2="21" y2="18"></line>
      </svg>
    </button>
  </div>

  <div class="sidebar-menu">
    <div class="menu-label">Analytics</div>
    <a href="${pageContext.request.contextPath}/admin/main" class="menu-item ${param.activePage == 'dashboard' ? 'active' : ''}">
      <svg class="menu-icon" viewBox="0 0 24 24"><rect x="3" y="3" width="7" height="7"></rect><rect x="14" y="3" width="7" height="7"></rect><rect x="14" y="14" width="7" height="7"></rect><rect x="3" y="14" width="7" height="7"></rect></svg>
      <span class="menu-text">대시보드</span>
    </a>
    <a href="${pageContext.request.contextPath}/admin/settlement" class="menu-item ${param.activePage == 'stats' ? 'active' : ''}">
      <svg class="menu-icon" viewBox="0 0 24 24"><line x1="18" y1="20" x2="18" y2="10"></line><line x1="12" y1="20" x2="12" y2="4"></line><line x1="6" y1="20" x2="6" y2="14"></line></svg>
      <span class="menu-text">통계 및 정산</span>
    </a>

    <div class="menu-label">Management</div>
    <a href="${pageContext.request.contextPath}/admin/partners" class="menu-item ${param.activePage == 'partner' ? 'active' : ''}">
      <svg class="menu-icon" viewBox="0 0 24 24"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"></path><circle cx="9" cy="7" r="4"></circle><path d="M23 21v-2a4 4 0 0 0-3-3.87"></path><path d="M16 3.13a4 4 0 0 1 0 7.75"></path></svg>
      <span class="menu-text">파트너사 관리</span>
    </a>
    <a href="${pageContext.request.contextPath}/admin/bookings" class="menu-item ${param.activePage == 'booking' ? 'active' : ''}">
      <svg class="menu-icon" viewBox="0 0 24 24"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"></rect><line x1="16" y1="2" x2="16" y2="6"></line><line x1="8" y1="2" x2="8" y2="6"></line><line x1="3" y1="10" x2="21" y2="10"></line></svg>
      <span class="menu-text">전체 예약 관리</span>
    </a>

    <div class="menu-label">Operation & CS</div>
    <a href="${pageContext.request.contextPath}/admin/banners" class="menu-item ${param.activePage == 'banner' ? 'active' : ''}">
      <svg class="menu-icon" viewBox="0 0 24 24"><rect x="3" y="3" width="18" height="18" rx="2" ry="2"></rect><circle cx="8.5" cy="8.5" r="1.5"></circle><polyline points="21 15 16 10 5 21"></polyline></svg>
      <span class="menu-text">배너/기획전 관리</span>
    </a>
    
    <div class="menu-item has-sub ${param.activePage == 'cs' || param.activePage == 'members' || param.activePage == 'dormant' ? 'active open' : ''}" 
         onclick="toggleSubMenu(this)">
      <svg class="menu-icon" viewBox="0 0 24 24"><path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"></path></svg>
      <span class="menu-text">회원 및 CS 관리</span>
      <svg class="chevron-down" viewBox="0 0 24 24"><polyline points="6 9 12 15 18 9"></polyline></svg>
    </div>
    
    <div class="sub-menu ${param.activePage == 'cs' || param.activePage == 'members' || param.activePage == 'dormant' ? 'open' : ''}">
      <a href="${pageContext.request.contextPath}/admin/member/main" class="sub-item ${param.activePage == 'members' ? 'active' : ''}">일반 회원 관리</a>
      <a href="${pageContext.request.contextPath}/admin/member/dormant" class="sub-item ${param.activePage == 'dormant' ? 'active' : ''}">휴면 회원 관리</a>
      <a href="${pageContext.request.contextPath}/admin/cs" class="sub-item ${param.activePage == 'cs' ? 'active' : ''}">1:1 문의 관리</a>
      <a href="${pageContext.request.contextPath}/admin/reports" class="sub-item">신고 게시물 관리</a>
    </div>

  </div>
</aside>

<script>
  function toggleSidebar() {
    document.querySelector('.admin-layout').classList.toggle('collapsed');
  }

  function toggleSubMenu(element) {
    if(document.querySelector('.admin-layout').classList.contains('collapsed')) return;
    element.classList.toggle('open');
    let subMenu = element.nextElementSibling;
    if (subMenu && subMenu.classList.contains('sub-menu')) {
      subMenu.classList.toggle('open');
    }
  }
  
// 화면 크기에 따라 사이드바 자동 조절하는 함수
  function autoToggleSidebar() {
      // 사이드바를 감싸는 전체 레이아웃이나 body 선택
      const layout = document.querySelector('.admin-layout'); 
      
      if (!layout) return;

      // 화면 가로 넓이가 992px (보통 태블릿 사이즈) 이하로 줄어들면 사이드바를 닫는 클래스를 강제로 추가
      if (window.innerWidth <= 992) {
          layout.classList.add('collapsed'); 
      } else {
          // 화면 다시 커지면 클래스를 빼서 사이드바 열기
          layout.classList.remove('collapsed');
      }
  }

  // 이벤트 리스너 등록(화면이 처음 켜질 때 한 번 실행)
  window.addEventListener('DOMContentLoaded', autoToggleSidebar);

  // 사용자가 브라우저 창 크기를 마우스로 드래그해서 조절할 때마다 실행
  window.addEventListener('resize', autoToggleSidebar);
</script>