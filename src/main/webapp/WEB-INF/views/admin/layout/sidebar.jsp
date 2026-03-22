<%@ page contentType="text/html; charset=UTF-8"%>

<%-- 모바일 딤드 배경 — 사이드바 열릴 때 뒤를 덮음 --%>
<div class="sidebar-backdrop" id="sidebarBackdrop" onclick="closeMobileSidebar()"></div>

<aside class="sidebar" id="sidebar">

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
    <a href="${pageContext.request.contextPath}/admin/main"
       class="menu-item ${param.activePage == 'dashboard' ? 'active' : ''}"
       onclick="closeMobileSidebar()">
      <svg class="menu-icon" viewBox="0 0 24 24"><rect x="3" y="3" width="7" height="7"></rect><rect x="14" y="3" width="7" height="7"></rect><rect x="14" y="14" width="7" height="7"></rect><rect x="3" y="14" width="7" height="7"></rect></svg>
      <span class="menu-text">대시보드</span>
    </a>
    
    <div class="menu-label">Sales</div>
    <a href="${pageContext.request.contextPath}/admin/settlement/main"
       class="menu-item ${param.activePage == 'stats' ? 'active' : ''}"
       onclick="closeMobileSidebar()">
      <svg class="menu-icon" viewBox="0 0 24 24"><line x1="18" y1="20" x2="18" y2="10"></line><line x1="12" y1="20" x2="12" y2="4"></line><line x1="6" y1="20" x2="6" y2="14"></line></svg>
      <span class="menu-text">통계 및 정산</span>
    </a>

    <div class="menu-label">Management</div>

    <%-- 파트너사 관리 (has-sub) --%>
    <div class="menu-item has-sub ${param.activePage == 'partners' || param.activePage == 'partner-apply' ? 'active open' : ''}"
         onclick="toggleSubMenu(this)">
      <svg class="menu-icon" viewBox="0 0 24 24"><rect x="2" y="7" width="20" height="14" rx="2" ry="2"></rect><path d="M16 21V5a2 2 0 0 0-2-2h-4a2 2 0 0 0-2 2v16"></path></svg>
      <span class="menu-text">파트너사 관리</span>
      <svg class="chevron-down" viewBox="0 0 24 24"><polyline points="6 9 12 15 18 9"></polyline></svg>
    </div>
    <div class="sub-menu ${param.activePage == 'partners' || param.activePage == 'partner-apply' ? 'open' : ''}">
      <a href="${pageContext.request.contextPath}/admin/partner/main"
         class="sub-item ${param.activePage == 'partners' ? 'active' : ''}"
         onclick="event.stopPropagation(); closeMobileSidebar()">파트너사 관리</a>
      <a href="${pageContext.request.contextPath}/admin/partner/apply"
         class="sub-item ${param.activePage == 'partner-apply' ? 'active' : ''}"
         onclick="event.stopPropagation(); closeMobileSidebar()">입점 승인 관리</a>
    </div>

    <%-- 회원 관리 (has-sub) — Management 탭 --%>
    <div class="menu-item has-sub ${param.activePage == 'members' || param.activePage == 'dormant' ? 'active open' : ''}"
         onclick="toggleSubMenu(this)">
      <svg class="menu-icon" viewBox="0 0 24 24"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"></path><circle cx="9" cy="7" r="4"></circle><path d="M23 21v-2a4 4 0 0 0-3-3.87"></path><path d="M16 3.13a4 4 0 0 1 0 7.75"></path></svg>
      <span class="menu-text">회원 관리</span>
      <svg class="chevron-down" viewBox="0 0 24 24"><polyline points="6 9 12 15 18 9"></polyline></svg>
    </div>
    <div class="sub-menu ${param.activePage == 'members' || param.activePage == 'dormant' ? 'open' : ''}">
      <a href="${pageContext.request.contextPath}/admin/member/main"
         class="sub-item ${param.activePage == 'members' ? 'active' : ''}"
         onclick="event.stopPropagation(); closeMobileSidebar()">일반 회원 관리</a>
      <a href="${pageContext.request.contextPath}/admin/member/dormant"
         class="sub-item ${param.activePage == 'dormant' ? 'active' : ''}"
         onclick="event.stopPropagation(); closeMobileSidebar()">휴면 회원 관리</a>
    </div>

    <a href="${pageContext.request.contextPath}/admin/reservations"
       class="menu-item ${param.activePage == 'booking' ? 'active' : ''}"
       onclick="closeMobileSidebar()">
      <svg class="menu-icon" viewBox="0 0 24 24"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"></rect><line x1="16" y1="2" x2="16" y2="6"></line><line x1="8" y1="2" x2="8" y2="6"></line><line x1="3" y1="10" x2="21" y2="10"></line></svg>
      <span class="menu-text">전체 예약 관리</span>
    </a>

    <div class="menu-label">Promotion</div>
    <div class="menu-item has-sub ${param.activePage == 'coupon' || param.activePage == 'point' ? 'active open' : ''}"
         onclick="toggleSubMenu(this)">
      <svg class="menu-icon" viewBox="0 0 24 24"><path d="M20 12V22H4V12"/><path d="M22 7H2v5h20V7z"/><path d="M12 22V7"/><path d="M12 7H7.5a2.5 2.5 0 0 1 0-5C11 2 12 7 12 7z"/><path d="M12 7h4.5a2.5 2.5 0 0 0 0-5C13 2 12 7 12 7z"/></svg>
      <span class="menu-text">쿠폰/포인트 관리</span>
      <svg class="chevron-down" viewBox="0 0 24 24"><polyline points="6 9 12 15 18 9"></polyline></svg>
    </div>
    <div class="sub-menu ${param.activePage == 'coupon' || param.activePage == 'point' ? 'open' : ''}">
      <a href="${pageContext.request.contextPath}/admin/coupon/main"
         class="sub-item ${param.activePage == 'coupon' ? 'active' : ''}"
         onclick="event.stopPropagation(); closeMobileSidebar()">쿠폰 관리</a>
      <a href="${pageContext.request.contextPath}/admin/point"
         class="sub-item ${param.activePage == 'point' ? 'active' : ''}"
         onclick="event.stopPropagation(); closeMobileSidebar()">포인트 관리</a>
    </div>

    <div class="menu-label">Operation & CS</div>
    <a href="${pageContext.request.contextPath}/admin/banners"
       class="menu-item ${param.activePage == 'banner' ? 'active' : ''}"
       onclick="closeMobileSidebar()">
      <svg class="menu-icon" viewBox="0 0 24 24"><rect x="3" y="3" width="18" height="18" rx="2" ry="2"></rect><circle cx="8.5" cy="8.5" r="1.5"></circle><polyline points="21 15 16 10 5 21"></polyline></svg>
      <span class="menu-text">배너/기획전 관리</span>
    </a>
    <div class="menu-item has-sub ${param.activePage == 'cs' || param.activePage == 'reports' || param.activePage == 'chatrooms' ? 'active open' : ''}"
         onclick="toggleSubMenu(this)">
      <svg class="menu-icon" viewBox="0 0 24 24"><path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"></path></svg>
      <span class="menu-text">CS 관리</span>
      <svg class="chevron-down" viewBox="0 0 24 24"><polyline points="6 9 12 15 18 9"></polyline></svg>
    </div>
    <div class="sub-menu ${param.activePage == 'cs' || param.activePage == 'reports' || param.activePage == 'chatrooms' ? 'open' : ''}">
      <a href="${pageContext.request.contextPath}/admin/cs"
         class="sub-item ${param.activePage == 'cs' ? 'active' : ''}"
         onclick="event.stopPropagation(); closeMobileSidebar()">1:1 문의 관리</a>
      <a href="${pageContext.request.contextPath}/admin/report/main"
         class="sub-item ${param.activePage == 'reports' ? 'active' : ''}"
         onclick="event.stopPropagation(); closeMobileSidebar()">유저/게시물 신고 관리</a>
      <a href="${pageContext.request.contextPath}/admin/chat/rooms"
         class="sub-item ${param.activePage == 'chatrooms' ? 'active' : ''}"
         onclick="event.stopPropagation(); closeMobileSidebar()">채팅방 관리</a>
    </div>

  </div>
</aside>

<script>
  const isMobile = () => window.innerWidth <= 768;

  /* 데스크탑: collapsed 토글 / 모바일: 드로어 열기/닫기 토글 */
  function toggleSidebar() {
    if (isMobile()) {
      const sidebar = document.getElementById('sidebar');
      if (sidebar.classList.contains('mobile-open')) {
        closeMobileSidebar();
      } else {
        openMobileSidebar();
      }
    } else {
      document.querySelector('.admin-layout').classList.toggle('collapsed');
    }
  }

  function openMobileSidebar() {
    document.getElementById('sidebar').classList.add('mobile-open');
    document.getElementById('sidebarBackdrop').classList.add('visible');
    document.body.style.overflow = 'hidden'; // 배경 스크롤 방지
  }

  function closeMobileSidebar() {
    if (!isMobile()) return;
    document.getElementById('sidebar').classList.remove('mobile-open');
    document.getElementById('sidebarBackdrop').classList.remove('visible');
    document.body.style.overflow = '';
  }

  function toggleSubMenu(element) {
    const layout = document.querySelector('.admin-layout');

    // 데스크탑 collapsed 상태면 먼저 열기
    if (!isMobile() && layout.classList.contains('collapsed')) {
      layout.classList.remove('collapsed');
    }

    element.classList.toggle('open');
    element.classList.toggle('active');
    const subMenu = element.nextElementSibling;
    if (subMenu && subMenu.classList.contains('sub-menu')) {
      subMenu.classList.toggle('open');
    }
  }

  /* 992px 이하 데스크탑 collapsed, 768px 이하는 드로어 방식이라 collapsed 불필요 */
  function autoToggleSidebar() {
    const layout = document.querySelector('.admin-layout');
    if (!layout) return;
    if (window.innerWidth <= 992 && window.innerWidth > 768) {
      layout.classList.add('collapsed');
    } else if (window.innerWidth > 992) {
      layout.classList.remove('collapsed');
    }
    // 768px 이하는 드로어 방식 — collapsed 건드리지 않음
    if (window.innerWidth > 768) {
      // 화면이 커지면 모바일 드로어 상태 초기화
      document.getElementById('sidebar').classList.remove('mobile-open');
      document.getElementById('sidebarBackdrop').classList.remove('visible');
      document.body.style.overflow = '';
    }
  }

  window.addEventListener('DOMContentLoaded', autoToggleSidebar);
  window.addEventListener('resize', autoToggleSidebar);
</script>
