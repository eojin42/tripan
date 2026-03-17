<%@ page contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<header class="top-header">
  
  <div class="header-left" style="display: flex; align-items: center; gap: 12px;">
    <a href="${pageContext.request.contextPath}/partner/apply" class="brand-logo" style="text-decoration: none;">
      <div class="logo-text-wrapper" style="display: flex; align-items: center;">
        <span class="trip" style="font-weight: 900; font-size: 24px; color: var(--text);">Trip</span>
        <span class="an" style="font-weight: 900; font-size: 24px; background: linear-gradient(to right, var(--primary), var(--secondary)); -webkit-background-clip: text; -webkit-text-fill-color: transparent;">an</span> 
      </div>
      <span class="super-badge" style="font-size: 10px; font-weight: 800; background: var(--secondary); color: white; padding: 3px 6px; border-radius: 6px; margin-left: 8px;">PARTNER</span>
    </a>
  </div>

  <div class="nav-right" style="display: flex; align-items: center; gap: 12px;">
    
    <div class="profile-wrapper" style="position: relative;">
      <button class="profile-btn" style="border:none; background:none; display:flex; align-items:center; gap:8px; cursor:pointer;" onclick="document.getElementById('partnerProfileDrop').classList.toggle('show')">
        <div class="avatar" style="width:32px; height:32px; border-radius:50%; background:#2D3748; color:white; display:flex; align-items:center; justify-content:center; font-weight:bold;">
          P
        </div>
        <div class="profile-text" style="text-align:left; line-height:1.2;">
          <span class="profile-name" style="display:block; font-size:13px; font-weight:700; color:#2D3748;">
            <c:out value="${not empty sessionScope.loginUser.nickname ? sessionScope.loginUser.nickname : '파트너'}" /> 님
          </span>
          <span class="profile-role" style="display:block; font-size:11px; color:#718096;">Tripan Partner</span>
        </div>
      </button>
      
      <div id="partnerProfileDrop" class="profile-dropdown" style="display: none; position: absolute; right: 0; top: 40px; background: white; border: 1px solid #eee; border-radius: 8px; box-shadow: 0 4px 12px rgba(0,0,0,0.1); padding: 10px; min-width: 120px;">
        <a href="${pageContext.request.contextPath}/member/logout" style="text-decoration: none; color: #EF4444; font-weight: 700; font-size: 13px; display: block; padding: 8px;">🚪 로그아웃</a>
      </div>
    </div>

  </div>
</header>

<style>
  .profile-dropdown.show { display: block !important; }
</style>