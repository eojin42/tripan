<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<aside class="sidebar">
  <div class="sidebar-header">
    <button class="hamburger-btn" onclick="toggleSidebar()" title="메뉴 접기/펼치기">
      <svg viewBox="0 0 24 24"><line x1="3" y1="6" x2="21" y2="6"/><line x1="3" y1="12" x2="21" y2="12"/><line x1="3" y1="18" x2="21" y2="18"/></svg>
    </button>
    <a href="${pageContext.request.contextPath}/partner/main" class="brand-logo" style="text-decoration:none;">
      <span class="trip" style="font-weight: 900; font-size: 24px; color: var(--text);">Trip</span>
      <span class="an" style="font-weight: 900; font-size: 24px; background: linear-gradient(to right, var(--primary), var(--secondary)); -webkit-background-clip: text; -webkit-text-fill-color: transparent;">an</span> 
      <span class="super-badge" style="font-size: 10px; font-weight: 800; background: var(--secondary); color: white; padding: 3px 6px; border-radius: 6px; margin-left: 8px;">PARTNER</span>
    </a>
  </div>
  
  <div class="sidebar-menu">
    <div class="menu-label">Analytics</div>
    <a href="?tab=dashboard" class="menu-item ${activeTab == 'dashboard' ? 'active' : ''}" data-tooltip="대시보드">
      <svg class="menu-icon" viewBox="0 0 24 24"><rect x="3" y="3" width="7" height="7"></rect><rect x="14" y="3" width="7" height="7"></rect><rect x="14" y="14" width="7" height="7"></rect><rect x="3" y="14" width="7" height="7"></rect></svg>
      <span class="menu-text">운영 현황 요약</span>
    </a>
    <a href="?tab=stats" class="menu-item ${activeTab == 'stats' ? 'active' : ''}" data-tooltip="매출 통계">
      <svg class="menu-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M3 3v18h18"/><path d="M18 17V9"/><path d="M13 17V5"/><path d="M8 17v-3"/></svg>
      <span class="menu-text">매출 통계 분석</span>
    </a>

    <div class="menu-label">Property Management</div>
    <a href="?tab=info" class="menu-item ${activeTab == 'info' ? 'active' : ''}" data-tooltip="숙소 프로필 관리">
      <svg class="menu-icon" viewBox="0 0 24 24"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"></path></svg>
      <span class="menu-text">숙소 프로필 관리</span>
    </a>
    <a href="?tab=facility" class="menu-item ${activeTab == 'facility' ? 'active' : ''}" data-tooltip="공통 시설 관리">
      <svg class="menu-icon" viewBox="0 0 24 24"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"></path><circle cx="9" cy="7" r="4"></circle><path d="M23 21v-2a4 4 0 0 0-3-3.87"></path><path d="M16 3.13a4 4 0 0 1 0 7.75"></path></svg>
      <span class="menu-text">공통 시설 및 규정</span>
    </a>

    <div class="menu-label">Inventory & Sales</div>
    <a href="?tab=room" class="menu-item ${activeTab == 'room' ? 'active' : ''}" data-tooltip="객실 관리">
      <svg class="menu-icon" viewBox="0 0 24 24"><path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"></path></svg>
      <span class="menu-text">객실 정보 등록</span>
    </a>
    <a href="?tab=calendar" class="menu-item ${activeTab == 'calendar' ? 'active' : ''}" data-tooltip="예약 캘린더">
      <svg class="menu-icon" viewBox="0 0 24 24"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"></rect><line x1="16" y1="2" x2="16" y2="6"></line><line x1="8" y1="2" x2="8" y2="6"></line><line x1="3" y1="10" x2="21" y2="10"></line></svg>
      <span class="menu-text">판매 스케줄 관리</span>
    </a>

    <div class="menu-label">Customer Service</div>
    <a href="?tab=booking" class="menu-item ${activeTab == 'booking' ? 'active' : ''}" data-tooltip="예약 내역">
      <svg class="menu-icon" viewBox="0 0 24 24"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path><polyline points="14 2 14 8 20 8"></polyline></svg>
      <span class="menu-text">예약 확정 및 취소</span>
    </a>
    <a href="?tab=review" class="menu-item ${activeTab == 'review' ? 'active' : ''}" data-tooltip="리뷰 관리">
      <svg class="menu-icon" viewBox="0 0 24 24"><path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"></path></svg>
      <span class="menu-text">리뷰 관리</span>
    </a>
    <a href="?tab=coupon" class="menu-item ${activeTab == 'coupon' ? 'active' : ''}" data-tooltip="쿠폰 발행">
      <svg class="menu-icon" viewBox="0 0 24 24"><path d="M20.59 13.41l-7.17 7.17a2 2 0 0 1-2.83 0L2 12V2h10l8.59 8.59a2 2 0 0 1 0 2.82z"></path></svg>
      <span class="menu-text">숙소 전용 쿠폰</span>
    </a>

    <div class="menu-label">Settlement</div>
    <a href="?tab=settle" class="menu-item ${activeTab == 'settle' ? 'active' : ''}" data-tooltip="정산 확인">
      <svg class="menu-icon" viewBox="0 0 24 24"><line x1="18" y1="20" x2="18" y2="10"></line><line x1="12" y1="20" x2="12" y2="4"></line><line x1="6" y1="20" x2="6" y2="14"></line></svg>
      <span class="menu-text">정산 대금 조회</span>
    </a>
    
    <div class="menu-label" style="margin-top: 16px;">Management</div>
    <a href="?tab=new_apply" class="menu-item ${activeTab == 'new_apply' ? 'active' : ''}" data-tooltip="새 숙소 추가">
      <svg class="menu-icon" viewBox="0 0 24 24"><path d="M12 5v14M5 12h14" stroke="currentColor" stroke-width="2" stroke-linecap="round"></path></svg>
      <span class="menu-text">새 숙소 추가 신청</span>
    </a>
    
  </div>
</aside>