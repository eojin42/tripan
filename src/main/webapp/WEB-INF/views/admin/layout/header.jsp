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

      <div id="notifDropdown" style="display:none; position:absolute; top:calc(100% + 15px); right:-10px; width:320px; background:#fff; border-radius:14px; box-shadow:0 10px 30px rgba(0,0,0,0.1); border:1px solid #E2E8F0; z-index:9999; overflow:hidden;">
        <div style="padding:14px 18px; border-bottom:1px solid #E2E8F0; display:flex; justify-content:space-between; align-items:center;">
          <span style="font-weight:800; font-size:14px; color:#2D3748;">🔔 알림</span>
          <button onclick="clearNotifs(event)" style="background:none; border:none; font-size:11px; color:#718096; cursor:pointer; font-weight:600;">모두 읽음</button>
        </div>

        <%-- 파트너 승인요청 섹션 --%>
        <div id="partnerNotifSection" style="display:none; border-bottom:1px solid #E2E8F0;">
          <div style="padding:8px 18px 4px; font-size:10px; font-weight:900; color:#A0AEC0; letter-spacing:0.5px; text-transform:uppercase;">파트너 승인 요청</div>
          <div id="partnerNotifList" style="display:flex; flex-direction:column;"></div>
          <div id="partnerNotifMore" style="display:none; padding:6px 18px 10px;">
            <a href="${pageContext.request.contextPath}/admin/partner/apply"
               style="font-size:11px; font-weight:700; color:#3B82F6; text-decoration:none;">
              + 더보기 — 입점 심사 페이지로 이동 →
            </a>
          </div>
        </div>

        <%-- 기존 채팅 알림 섹션 --%>
        <div id="chatNotifSection" style="display:none;">
          <div style="padding:8px 18px 4px; font-size:10px; font-weight:900; color:#A0AEC0; letter-spacing:0.5px; text-transform:uppercase;">1:1 채팅 상담</div>
          <div id="notifList" style="max-height:220px; overflow-y:auto; display:flex; flex-direction:column;"></div>
        </div>

        <div id="emptyNotif" style="padding:30px 20px; text-align:center; color:#A0AEC0;">
          <i class="bi bi-bell-slash" style="font-size:24px; opacity:0.5; display:block; margin-bottom:8px;"></i>
          <span style="font-size:12px; font-weight:600;">새로운 알림이 없습니다.</span>
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
  /* ── 알림 상태 ── */
  var _partnerNotifs    = [];   // [{id, name, createdAt}, ...]
  var _chatNotifCount   = 0;
  var _partnerDismissed = false; // 모두읽음 눌렀을 때 파트너 알림 숨김 여부

  /* ── 뱃지 숫자 갱신 ── */
  function _refreshBadge() {
    var chatCount    = _chatNotifCount;
    var partnerCount = _partnerDismissed ? 0 : _partnerNotifs.length;
    var total        = chatCount + partnerCount;
    var badge = document.querySelector('.notif-badge');
    if (badge) {
      badge.textContent = total > 99 ? '99+' : String(total);
      badge.style.display = total > 0 ? 'inline-flex' : 'none';
    }
  }

  /* ── 드롭다운 전체 렌더 ── */
  function _renderDropdown() {
    var partnerSection  = document.getElementById('partnerNotifSection');
    var partnerList     = document.getElementById('partnerNotifList');
    var partnerMore     = document.getElementById('partnerNotifMore');
    var chatSection     = document.getElementById('chatNotifSection');
    var emptyNotif      = document.getElementById('emptyNotif');

    var hasPartner = !_partnerDismissed && _partnerNotifs.length > 0;
    var hasChat    = _chatNotifCount > 0;

    /* 파트너 섹션 */
    partnerSection.style.display = hasPartner ? 'block' : 'none';
    if (hasPartner) {
      var MAX_SHOW = 3;
      var shown    = _partnerNotifs.slice(0, MAX_SHOW);
      partnerList.innerHTML = shown.map(function(p) {
        var dateStr = p.createdAt ? String(p.createdAt).substring(0, 10) : '';
        return '<a href="${pageContext.request.contextPath}/admin/partner/apply"'
          + ' style="display:flex;align-items:center;gap:10px;padding:10px 18px;text-decoration:none;'
          +         'transition:background 0.15s;border:none;cursor:pointer;"'
          + ' onmouseover="this.style.background=\'#F7F8FF\'" onmouseout="this.style.background=\'\'">'
          + '  <div style="width:34px;height:34px;border-radius:50%;background:linear-gradient(135deg,#FED7AA,#FCA5A5);'
          +               'display:flex;align-items:center;justify-content:center;flex-shrink:0;font-size:15px;">🏢</div>'
          + '  <div style="flex:1;min-width:0;">'
          + '    <div style="font-size:12px;font-weight:800;color:#2D3748;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;">'
          +       (p.partnerName || '파트너사') + '</div>'
          + '    <div style="font-size:11px;color:#C2410C;font-weight:700;margin-top:1px;">입점 심사 대기 중</div>'
          + '  </div>'
          + '  <span style="font-size:10px;color:#A0AEC0;flex-shrink:0;">' + dateStr + '</span>'
          + '</a>';
      }).join('');
      partnerMore.style.display = _partnerNotifs.length > MAX_SHOW ? 'block' : 'none';
    }

    /* 채팅 섹션 — 기존 cs.js가 notifList에 직접 DOM 추가하는 방식 유지 */
    chatSection.style.display = hasChat ? 'block' : 'none';

    /* 빈 상태 */
    emptyNotif.style.display = (!hasPartner && !hasChat) ? 'block' : 'none';
  }

  /* ── 파트너 승인요청 폴링 ── */
  function _fetchPartnerPending() {
    fetch('${pageContext.request.contextPath}/api/admin/partner/list')
      .then(function(r) { return r.ok ? r.json() : null; })
      .then(function(data) {
        if (!data) return;
        var list = Array.isArray(data.list) ? data.list : [];
        _partnerNotifs = list.filter(function(p) {
          return String(p.statusCode || '').toUpperCase() === 'PENDING';
        });
        if (!_partnerDismissed) {
          _refreshBadge();
          _renderDropdown();
        }
      })
      .catch(function() {});
  }

  /* ── cs.js에서 호출: 채팅 알림 수 업데이트 ── */
  window.updateChatNotifCount = function(count) {
    _chatNotifCount = count || 0;
    _refreshBadge();
    _renderDropdown();
  };

  /* ── 종 모양 클릭 시 열고 닫기 ── */
  function toggleNotifDropdown(e) {
    e.stopPropagation();
    var dropdown = document.getElementById('notifDropdown');
    var isOpen   = dropdown.style.display === 'block';
    dropdown.style.display = isOpen ? 'none' : 'block';
    if (!isOpen) _renderDropdown(); // 열 때 최신 렌더
  }

  /* ── 모두 읽음 처리 ── */
  function clearNotifs(e) {
    e.stopPropagation();
    _partnerDismissed = true;
    _chatNotifCount   = 0;

    // 채팅 notifList 비우기 (cs.js 쪽 연동)
    var notifList = document.getElementById('notifList');
    if (notifList) notifList.innerHTML = '';

    _refreshBadge();
    _renderDropdown();
  }

  /* ── 외부 클릭 시 닫기 ── */
  document.addEventListener('click', function(e) {
    var dropdown = document.getElementById('notifDropdown');
    if (dropdown && dropdown.style.display === 'block') {
      var wrapper = document.querySelector('.notif-wrapper');
      if (wrapper && !wrapper.contains(e.target)) {
        dropdown.style.display = 'none';
      }
    }
  });

  /* ── 초기 로드 + 30초 폴링 ── */
  _fetchPartnerPending();
  setInterval(_fetchPartnerPending, 30000);
</script>