<%@ page contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<header class="top-header">
  
  <div class="header-left" style="display: flex; align-items: center; gap: 12px;">
  	<div class="property-switcher" style="position: relative;">
      <button class="property-btn" onclick="document.getElementById('propertyDrop').classList.toggle('show')" 
              style="border:1px solid #E2E8F0; background:#F8FAFC; padding:8px 16px; border-radius:10px; display:flex; align-items:center; gap:10px; cursor:pointer; font-weight:800; font-size:14px; color:#1E293B; transition:all 0.2s;">
        <span style="font-size:16px;">🏢</span> 
        <span id="currentProperty">쌍용스테이 제주 본점</span> 
        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round"><polyline points="6 9 12 15 18 9"></polyline></svg>
      </button>
      
      <div id="propertyDrop" class="profile-dropdown" style="display: none; position: absolute; left: 0; top: 48px; width: 240px; background: white; border: 1px solid #E2E8F0; border-radius: 14px; box-shadow: 0 10px 30px rgba(0,0,0,0.08); padding: 12px; z-index: 100;">
        <div style="padding: 4px 12px 8px; font-size: 11px; color: #94A3B8; font-weight: 800; letter-spacing: -0.5px;">운영 중인 숙소</div>
        
        <a href="#" class="dropdown-item" style="display:flex; align-items:center; gap:8px; padding:10px 12px; text-decoration:none; color:#1E293B; font-weight:800; font-size:13px; border-radius:8px; background:#F1F5F9; margin-bottom:4px;">
          <span style="color:var(--primary);">✓</span> 쌍용스테이 제주 본점
        </a>
        <a href="#" class="dropdown-item" style="display:block; padding:10px 12px 10px 28px; text-decoration:none; color:#64748B; font-weight:600; font-size:13px; border-radius:8px; transition:0.2s;">
          쌍용스테이 서울 2호점
        </a>
        <a href="#" class="dropdown-item" style="display:flex; justify-content:space-between; padding:10px 12px 10px 28px; text-decoration:none; color:#94A3B8; font-weight:600; font-size:13px; border-radius:8px;">
          <span>쌍용스테이 부산점</span>
          <span style="font-size:10px; background:#F1F5F9; padding:2px 6px; border-radius:4px; font-weight:800;">심사중</span>
        </a>
        
        <div style="border-top: 1px solid #F1F5F9; margin: 8px 0;"></div>
        
        <a href="?tab=new_apply" class="dropdown-item" style="display:block; padding:12px; text-decoration:none; color:var(--primary); font-weight:800; font-size:13px; border-radius:8px; text-align:center; background:var(--primary-10);">
          ➕ 새로운 숙소 추가하기
        </a>
      </div>
    </div>
  </div>

 <div class="nav-right" style="display: flex; align-items: center; gap: 12px;">
    <div class="profile-wrapper" style="position: relative;">
      <button class="profile-btn" style="border:none; background:none; display:flex; align-items:center; gap:8px; cursor:pointer;" onclick="document.getElementById('partnerProfileDrop').classList.toggle('show')">
        <div class="avatar" style="width:36px; height:36px; border-radius:50%; background:var(--primary); color:white; display:flex; align-items:center; justify-content:center; font-weight:900; font-size:16px;">P</div>
        <div class="profile-text" style="text-align:left; line-height:1.2;">
          <span class="profile-name" style="display:block; font-size:13px; font-weight:800; color:#1E293B;">
            <c:out value="${not empty sessionScope.loginUser.nickname ? sessionScope.loginUser.nickname : '파트너'}" /> 님
          </span>
          <span class="profile-role" style="display:block; font-size:11px; font-weight:600; color:#94A3B8;">Tripan Partner</span>
        </div>
      </button>
      
      <div id="partnerProfileDrop" class="profile-dropdown" style="display: none; position: absolute; right: 0; top: 48px; background: white; border: 1px solid #E2E8F0; border-radius: 12px; box-shadow: 0 10px 30px rgba(0,0,0,0.08); padding: 10px; width: 160px; z-index: 100;">
        <a href="#" style="display:block; padding:10px; color:#1E293B; font-weight:700; text-decoration:none; font-size:13px;">⚙️ 계정 설정</a>
        <form action="${pageContext.request.contextPath}/logout" method="post" style="margin:0;">
          <button type="submit" style="width:100%; text-align:left; padding:10px; border:none; background:none; color:#EF4444; font-weight:700; font-size:13px; cursor:pointer;">🚪 로그아웃</button>
        </form>
      </div>
    </div>
  </div>
</header>

<style>
  .profile-dropdown.show { display: block !important; }
</style>