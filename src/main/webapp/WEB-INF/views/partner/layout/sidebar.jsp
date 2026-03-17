<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<aside class="sidebar">
  <div class="sidebar-header">
    <a href="${pageContext.request.contextPath}/partner/main" class="brand-logo" style="text-decoration:none;">
      <span class="trip" style="font-weight: 900; font-size: 24px; color: var(--text);">Trip</span>
      <span class="an" style="font-weight: 900; font-size: 24px; background: linear-gradient(to right, var(--primary), var(--secondary)); -webkit-background-clip: text; -webkit-text-fill-color: transparent;">an</span> 
      <span class="super-badge" style="font-size: 10px; font-weight: 800; background: var(--secondary); color: white; padding: 3px 6px; border-radius: 6px; margin-left: 8px;">PARTNER</span>
    </a>
  </div>
  
  <div class="sidebar-menu">
    <div class="menu-label">Analytics</div>
    <a href="?tab=dashboard" class="menu-item ${activeTab == 'dashboard' ? 'active' : ''}">
      <svg class="menu-icon" viewBox="0 0 24 24"><rect x="3" y="3" width="7" height="7"></rect><rect x="14" y="3" width="7" height="7"></rect><rect x="14" y="14" width="7" height="7"></rect><rect x="3" y="14" width="7" height="7"></rect></svg>
      <span class="menu-text">대시보드</span>
    </a>

    <div class="menu-label">My Place</div>
    <a href="?tab=room" class="menu-item ${activeTab == 'room' ? 'active' : ''}">
      <svg class="menu-icon" viewBox="0 0 24 24"><path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"></path></svg>
      <span class="menu-text">숙소 및 객실 관리</span>
    </a>
    <a href="?tab=calendar" class="menu-item ${activeTab == 'calendar' ? 'active' : ''}">
      <svg class="menu-icon" viewBox="0 0 24 24"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"></rect><line x1="16" y1="2" x2="16" y2="6"></line><line x1="8" y1="2" x2="8" y2="6"></line><line x1="3" y1="10" x2="21" y2="10"></line></svg>
      <span class="menu-text">예약 캘린더</span>
    </a>
    <a href="?tab=info" class="menu-item ${activeTab == 'info' ? 'active' : ''}">
      <svg class="menu-icon" viewBox="0 0 24 24"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"></path></svg>
      <span class="menu-text">파트너 정보 관리</span>
    </a>

    <div class="menu-label">Operation</div>
    <a href="?tab=booking" class="menu-item ${activeTab == 'booking' ? 'active' : ''}">
      <svg class="menu-icon" viewBox="0 0 24 24"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path><polyline points="14 2 14 8 20 8"></polyline></svg>
      <span class="menu-text">예약 내역 관리</span>
    </a>
    <a href="?tab=chat" class="menu-item ${activeTab == 'chat' ? 'active' : ''}">
      <svg class="menu-icon" viewBox="0 0 24 24"><path d="M21 11.5a8.38 8.38 0 0 1-.9 3.8 8.5 8.5 0 1 1-7.6-13.5 8.38 8.38 0 0 1 3.8.9L21 3z"></path></svg>
      <span class="menu-text">고객 채팅</span>
    </a>
    <a href="?tab=review" class="menu-item ${activeTab == 'review' ? 'active' : ''}">
      <svg class="menu-icon" viewBox="0 0 24 24"><path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"></path></svg>
      <span class="menu-text">리뷰 관리</span>
    </a>
    <a href="?tab=coupon" class="menu-item ${activeTab == 'coupon' ? 'active' : ''}">
      <svg class="menu-icon" viewBox="0 0 24 24"><path d="M20.59 13.41l-7.17 7.17a2 2 0 0 1-2.83 0L2 12V2h10l8.59 8.59a2 2 0 0 1 0 2.82z"></path></svg>
      <span class="menu-text">쿠폰 마케팅</span>
    </a>

    <div class="menu-label">Finance</div>
    <a href="?tab=settle" class="menu-item ${activeTab == 'settle' ? 'active' : ''}">
      <svg class="menu-icon" viewBox="0 0 24 24"><line x1="18" y1="20" x2="18" y2="10"></line><line x1="12" y1="20" x2="12" y2="4"></line><line x1="6" y1="20" x2="6" y2="14"></line></svg>
      <span class="menu-text">정산 내역</span>
    </a>
    <a href="?tab=tax" class="menu-item ${activeTab == 'tax' ? 'active' : ''}">
      <svg class="menu-icon" viewBox="0 0 24 24"><path d="M16 4h2a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2V6a2 2 0 0 1 2-2h2"></path></svg>
      <span class="menu-text">세무 자료 관리</span>
    </a>
  </div>
</aside>