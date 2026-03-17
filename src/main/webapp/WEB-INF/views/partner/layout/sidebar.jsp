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
    <a href="${pageContext.request.contextPath}/partner/main?tab=dashboard" 
       class="menu-item ${activeTab == 'dashboard' ? 'active' : ''}" style="text-decoration:none;">
      <svg class="menu-icon" viewBox="0 0 24 24"><rect x="3" y="3" width="7" height="7"></rect><rect x="14" y="3" width="7" height="7"></rect><rect x="14" y="14" width="7" height="7"></rect><rect x="3" y="14" width="7" height="7"></rect></svg>
      <span class="menu-text">대시보드</span>
    </a>

    <div class="menu-label">My Place</div>
    <a href="${pageContext.request.contextPath}/partner/main?tab=room" 
       class="menu-item ${activeTab == 'room' ? 'active' : ''}" style="text-decoration:none;">
      <svg class="menu-icon" viewBox="0 0 24 24"><path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"></path></svg>
      <span class="menu-text">숙소 및 객실 관리</span>
    </a>
    <a href="${pageContext.request.contextPath}/partner/main?tab=info" 
       class="menu-item ${activeTab == 'info' ? 'active' : ''}" style="text-decoration:none;">
      <svg class="menu-icon" viewBox="0 0 24 24"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"></path></svg>
      <span class="menu-text">파트너 정보 관리</span>
    </a>

    <div class="menu-label">Operation</div>
    <a href="${pageContext.request.contextPath}/partner/main?tab=booking" 
       class="menu-item ${activeTab == 'booking' ? 'active' : ''}" style="text-decoration:none;">
      <svg class="menu-icon" viewBox="0 0 24 24"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"></rect><line x1="16" y1="2" x2="16" y2="6"></line><line x1="8" y1="2" x2="8" y2="6"></line><line x1="3" y1="10" x2="21" y2="10"></line></svg>
      <span class="menu-text">예약 관리</span>
    </a>
    <a href="${pageContext.request.contextPath}/partner/main?tab=review" 
       class="menu-item ${activeTab == 'review' ? 'active' : ''}" style="text-decoration:none;">
      <svg class="menu-icon" viewBox="0 0 24 24"><path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"></path></svg>
      <span class="menu-text">리뷰 관리</span>
    </a>
    <a href="${pageContext.request.contextPath}/partner/main?tab=support" 
       class="menu-item ${activeTab == 'support' ? 'active' : ''}" style="text-decoration:none;">
      <svg class="menu-icon" viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"></circle><path d="M9.09 9a3 3 0 0 1 5.83 1c0 2-3 3-3 3"></path><line x1="12" y1="17" x2="12.01" y2="17"></line></svg>
      <span class="menu-text">1:1 기술 지원</span>
    </a>

    <div class="menu-label">Finance</div>
    <a href="${pageContext.request.contextPath}/partner/main?tab=settle" 
       class="menu-item ${activeTab == 'settle' ? 'active' : ''}" style="text-decoration:none;">
      <svg class="menu-icon" viewBox="0 0 24 24"><line x1="18" y1="20" x2="18" y2="10"></line><line x1="12" y1="20" x2="12" y2="4"></line><line x1="6" y1="20" x2="6" y2="14"></line></svg>
      <span class="menu-text">정산 내역</span>
    </a>
    <a href="${pageContext.request.contextPath}/partner/main?tab=stats" 
       class="menu-item ${activeTab == 'stats' ? 'active' : ''}" style="text-decoration:none;">
      <svg class="menu-icon" viewBox="0 0 24 24"><path d="M21.21 15.89A10 10 0 1 1 8 2.83"></path><path d="M22 12A10 10 0 0 0 12 2v10z"></path></svg>
      <span class="menu-text">매출 통계</span>
    </a>

    <div class="menu-label">System</div>
    <a href="${pageContext.request.contextPath}/partner/main?tab=notice" 
       class="menu-item ${activeTab == 'notice' ? 'active' : ''}" style="text-decoration:none;">
      <svg class="menu-icon" viewBox="0 0 24 24"><path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9"></path><path d="M13.73 21a2 2 0 0 1-3.46 0"></path></svg>
      <span class="menu-text">공지사항</span>
    </a>
    <a href="${pageContext.request.contextPath}/partner/main?tab=settings" 
       class="menu-item ${activeTab == 'settings' ? 'active' : ''}" style="text-decoration:none;">
      <svg class="menu-icon" viewBox="0 0 24 24"><circle cx="12" cy="12" r="3"></circle><path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 0 1 0 2.83 2 2 0 0 1-2.83 0l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-2 2 2 2 0 0 1-2-2v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 0 1-2.83 0 2 2 0 0 1 0-2.83l.06-.06a1.65 1.65 0 0 0 .33-1.82 1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1-2-2 2 2 0 0 1 2-2h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 0 1 0-2.83 2 2 0 0 1 2.83 0l.06.06a1.65 1.65 0 0 0 1.82.33H9a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 2-2 2 2 0 0 1 2 2v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 0 1 2.83 0 2 2 0 0 1 0 2.83l-.06.06a1.65 1.65 0 0 0-.33 1.82V9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 2 2 2 2 0 0 1-2 2h-.09a1.65 1.65 0 0 0-1.51 1z"></path></svg>
      <span class="menu-text">계정 설정</span>
    </a>
  </div>
</aside>