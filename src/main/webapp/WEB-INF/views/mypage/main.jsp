<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Tripan - 마이페이지</title>
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/gh/orioncactus/pretendard@v1.3.8/dist/web/static/pretendard.css">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
  <style>
    :root {
      --sky-blue:#89CFF0; --sky-blue-light:#E6F4FF; --light-pink:#FFB6C1;
      --grad-main:linear-gradient(135deg,var(--sky-blue),var(--light-pink));
      --bg-page:#F0F8FF;
      --glass-bg:rgba(255,255,255,0.65); --glass-border:rgba(255,255,255,0.8);
      --text-black:#2D3748; --text-dark:#4A5568; --text-gray:#718096;
      --border-light:#E2E8F0; --radius-xl:24px;
      --bounce:cubic-bezier(0.34,1.56,0.64,1);
    }
    body {
      background-color:var(--bg-page); color:var(--text-black);
      font-family:'Pretendard',sans-serif; margin:0; padding:0;
      background-image:
        radial-gradient(at 0% 0%,rgba(137,207,240,.15) 0px,transparent 50%),
        radial-gradient(at 100% 100%,rgba(255,182,193,.15) 0px,transparent 50%);
      background-attachment:fixed;
    }

    .mypage-container {
      max-width:1400px; width:90%;
      margin:120px auto 80px;
      display:grid; grid-template-columns:280px 1fr;
      gap:40px; align-items:start;
    }

    .glass-card {
      background:var(--glass-bg); backdrop-filter:blur(20px); -webkit-backdrop-filter:blur(20px);
      border:1px solid var(--glass-border); border-radius:var(--radius-xl); padding:24px;
      box-shadow:0 12px 32px rgba(45,55,72,.04);
    }
    .clean-card {
      background:#fff; border:1px solid var(--border-light);
      border-radius:20px; padding:24px;
      box-shadow:0 4px 20px rgba(0,0,0,.02);
    }

    /* ── 사이드바 ── */
    .sidebar { position:sticky; top:120px; display:flex; flex-direction:column; gap:20px; }

    .profile-widget { text-align:center; }
    .profile-avatar {
      width:88px; height:88px; border-radius:50%;
      border:4px solid white; box-shadow:0 8px 16px rgba(137,207,240,.3);
      margin:0 auto 14px; overflow:hidden; background:white;
    }
    .profile-avatar img { width:100%; height:100%; object-fit:cover; }
    .profile-avatar-default {
      width:100%; height:100%; background:var(--grad-main);
      display:flex; align-items:center; justify-content:center;
      color:white; font-size:28px; font-weight:900;
    }
    .profile-name { font-size:20px; font-weight:900; margin-bottom:4px; }
    .profile-bio  { font-size:13px; color:var(--text-gray); margin-bottom:16px; line-height:1.4; }
    .btn-edit-profile {
      background:white; color:var(--text-dark); border:1px solid var(--border-light);
      padding:8px 16px; border-radius:20px; font-size:13px; font-weight:700;
      cursor:pointer; transition:all .2s; width:100%; font-family:inherit;
    }
    .btn-edit-profile:hover { background:var(--text-black); color:white; border-color:transparent; }

    .profile-stats {
      display:flex; justify-content:space-around;
      margin-top:20px; padding-top:20px;
      border-top:1px dashed rgba(45,55,72,.1);
    }
    .stat-box {
      display:flex; flex-direction:column; align-items:center;
      font-size:12px; color:var(--text-gray); font-weight:600;
      cursor:pointer; padding:4px 8px; border-radius:8px; transition:.2s; gap:2px;
    }
    .stat-box:hover { background:rgba(137,207,240,.1); color:var(--sky-blue); }
    .stat-box strong { font-size:18px; color:var(--text-black); font-weight:900; }

    /* ── 사이드 네비 (BI 아이콘) ── */
    .side-nav { list-style:none; padding:0; margin:0; display:flex; flex-direction:column; gap:6px; }
    .side-nav li { border-radius:16px; overflow:hidden; }
    .side-nav a {
      display:flex; align-items:center; gap:12px;
      padding:13px 20px; color:var(--text-dark);
      font-weight:700; font-size:14px; text-decoration:none; transition:all .3s;
    }
    .side-nav a i { font-size:16px; width:20px; text-align:center; flex-shrink:0; }
    .side-nav a:hover { background:rgba(255,255,255,.8); color:var(--sky-blue); padding-left:24px; }
    .side-nav li.active a {
      background:var(--grad-main); color:white;
      box-shadow:0 4px 12px rgba(137,207,240,.4);
    }
    .side-nav li.active a i { color:white; }

    /* ── 대시보드 메인 ── */
    .dashboard-content { display:flex; flex-direction:column; gap:28px; padding-top:20px; }
    .welcome-title { font-size:24px; font-weight:800; margin:0; }
    .welcome-title span { color:var(--sky-blue); }

    .section-header { margin-bottom:16px; }
    .section-title  { font-size:17px; font-weight:800; display:flex; align-items:center; gap:8px; margin:0 0 5px; }
    .section-title i { font-size:17px; color:var(--sky-blue); }
    .section-subtitle { font-size:13px; color:var(--text-gray); font-weight:500; margin:0; }

    /* ── 요약 카드 (작게) ── */
    .summary-grid { display:grid; grid-template-columns:repeat(4,1fr); gap:12px; }
    .summary-card {
      background:white; border-radius:16px; padding:20px 14px;
      box-shadow:0 4px 16px rgba(0,0,0,.02); border:1px solid var(--border-light);
      display:flex; flex-direction:column; align-items:center; justify-content:center;
      transition:transform .3s var(--bounce); cursor:default;
    }
    .summary-card:hover { transform:translateY(-4px); box-shadow:0 8px 24px rgba(137,207,240,.1); border-color:var(--sky-blue); }
    .summary-card i { font-size:22px; color:var(--sky-blue); margin-bottom:10px; }
    .summary-value { font-size:26px; font-weight:900; color:var(--text-black); margin-bottom:5px; line-height:1; }
    .summary-label { font-size:12px; color:var(--text-gray); font-weight:600; }

    /* ── 다가오는 여행 - 그라디언트 배너 ── */
    .upcoming-banner {
      background:var(--grad-main); border-radius:20px; padding:22px 28px;
      display:flex; align-items:center; gap:20px; color:white;
      box-shadow:0 12px 28px rgba(137,207,240,.35);
      cursor:pointer; transition:transform .3s var(--bounce);
    }
    .upcoming-banner:hover { transform:translateY(-3px); box-shadow:0 16px 36px rgba(137,207,240,.4); }
    .upcoming-banner > i  { font-size:34px; flex-shrink:0; }
    .up-info { flex:1; }
    .up-lbl  { font-size:11px; font-weight:700; opacity:.85; margin-bottom:4px; }
    .up-name { font-size:18px; font-weight:900; margin-bottom:4px; }
    .up-date { font-size:12px; opacity:.85; display:flex; align-items:center; gap:5px; }
    .up-dday { font-size:34px; font-weight:900; flex-shrink:0; letter-spacing:-1px; }

    .upcoming-none {
      background:white; border-radius:20px; padding:22px 28px;
      display:flex; align-items:center; gap:20px;
      border:1px solid var(--border-light); box-shadow:0 4px 16px rgba(0,0,0,.02);
    }
    .upcoming-none-icon {
      width:50px; height:50px; border-radius:14px;
      background:var(--sky-blue-light); flex-shrink:0;
      display:flex; align-items:center; justify-content:center;
      color:var(--sky-blue); font-size:22px;
    }
    .upcoming-none-text h4 { font-size:13px; font-weight:700; color:var(--text-gray); margin:0 0 5px; }
    .upcoming-none-text p  { font-size:17px; font-weight:800; color:var(--text-black); margin:0; }

    /* ── 지도 ── */
    .map-header { display:flex; justify-content:space-between; align-items:center; margin-bottom:16px; }
    .map-header h3 { margin:0; font-size:17px; font-weight:800; display:flex; align-items:center; gap:8px; }
    .map-header h3 i { color:var(--sky-blue); }
    .btn-download { font-size:13px; font-weight:700; color:var(--sky-blue); background:white; padding:7px 14px; border-radius:8px; border:1px solid var(--sky-blue); cursor:pointer; transition:.2s; font-family:inherit; }
    .btn-download:hover { background:var(--sky-blue); color:white; }
    .map-placeholder {
      width:100%; height:360px; background:#F8FAFC; border-radius:16px;
      display:flex; align-items:center; justify-content:center; flex-direction:column;
      color:var(--text-gray); font-weight:600; font-size:14px;
      border:2px dashed var(--border-light); gap:10px; box-sizing:border-box;
    }
    .map-placeholder i { font-size:36px; opacity:.2; color:var(--sky-blue); }

    /* ── 모달 ── */
    .modal-overlay {
      position:fixed; top:0; left:0; width:100%; height:100%;
      background:rgba(0,0,0,.4); backdrop-filter:blur(4px);
      display:flex; align-items:center; justify-content:center;
      z-index:9999; opacity:0; visibility:hidden; transition:.3s;
    }
    .modal-overlay.active { opacity:1; visibility:visible; }
    .custom-modal {
      background:white; width:90%; max-width:420px;
      border-radius:24px; padding:28px;
      box-shadow:0 20px 40px rgba(0,0,0,.1);
      transform:translateY(20px); transition:.4s var(--bounce);
    }
    .modal-overlay.active .custom-modal { transform:translateY(0); }
    .modal-header { display:flex; justify-content:space-between; align-items:center; margin-bottom:18px; }
    .modal-header h3 { margin:0; font-size:17px; font-weight:800; }
    .btn-close { background:none; border:none; font-size:22px; color:var(--text-gray); cursor:pointer; padding:0; line-height:1; }
    .btn-close:hover { color:var(--text-black); }

    /* 모달 - 팔로워/팔로잉 */
    .user-list { display:flex; flex-direction:column; gap:8px; max-height:320px; overflow-y:auto; }
    .user-item {
      display:flex; align-items:center; gap:12px; padding:12px 14px;
      border-radius:14px; background:#F8FAFC; border:1px solid var(--border-light);
      transition:.2s;
    }
    .user-item:hover { background:#EFF6FF; border-color:rgba(137,207,240,.3); }
    .user-pic {
      width:42px; height:42px; border-radius:50%; flex-shrink:0;
      background:var(--grad-main); overflow:hidden;
      display:flex; align-items:center; justify-content:center;
      color:white; font-weight:800; font-size:14px;
    }
    .user-pic img { width:100%; height:100%; object-fit:cover; }
    .user-name { font-size:14px; font-weight:700; color:var(--text-dark); }
    .user-id   { font-size:11px; color:var(--text-gray); margin-top:2px; }

    /* 모달 - 배지 */
    .badge-grid {
      display:grid; grid-template-columns:repeat(3,1fr); gap:12px;
      max-height:360px; overflow-y:auto; padding:2px;
    }
    .badge-item {
      display:flex; flex-direction:column; align-items:center; justify-content:center;
      gap:10px; padding:20px 12px; background:#F8FAFC;
      border-radius:16px; border:1.5px solid var(--border-light);
      cursor:pointer; transition:all .25s var(--bounce);
      position:relative;
    }
    .badge-item:hover {
      border-color:var(--sky-blue); background:var(--sky-blue-light);
      transform:translateY(-3px); box-shadow:0 8px 20px rgba(137,207,240,.2);
    }
    .badge-item.active {
      border-color:var(--sky-blue); background:var(--sky-blue-light);
      box-shadow:0 4px 16px rgba(137,207,240,.25);
    }
    .badge-item.active::after {
      content:'장착 중'; position:absolute; top:8px; right:8px;
      font-size:9px; font-weight:800; color:var(--sky-blue);
      background:rgba(137,207,240,.25); padding:2px 7px; border-radius:20px;
    }
    .badge-icon {
      width:36px; height:36px; color:var(--sky-blue); stroke:var(--sky-blue); flex-shrink:0;
    }
    .badge-item img.badge-icon { object-fit:contain; }
    .badge-name {
      font-size:11px; font-weight:800; color:var(--text-dark);
      text-align:center; line-height:1.3; word-break:keep-all;
    }

    /* 로딩 */
    .modal-loading { display:flex; flex-direction:column; align-items:center; padding:30px; gap:12px; color:var(--text-gray); font-size:13px; font-weight:600; }
    .spin { width:28px; height:28px; border:3px solid rgba(137,207,240,.2); border-top-color:var(--sky-blue); border-radius:50%; animation:sp .7s linear infinite; }
    @keyframes sp { to { transform:rotate(360deg); } }

    /* 빈 상태 */
    .modal-empty { text-align:center; padding:30px 20px; color:var(--text-gray); }
    .modal-empty i { font-size:32px; display:block; margin-bottom:8px; opacity:.25; color:var(--sky-blue); }
    .modal-empty p { font-size:13px; font-weight:600; margin:0; }

    @media(max-width:1024px){
      .mypage-container { grid-template-columns:1fr; gap:24px; }
      .sidebar { position:relative; top:0; }
      .summary-grid { grid-template-columns:repeat(2,1fr); }
    }
    @media(max-width:480px){
      .summary-grid { grid-template-columns:repeat(2,1fr); }
    }
  </style>
</head>
<body>

<jsp:include page="/WEB-INF/views/layout/header.jsp"/>

<main class="mypage-container">

<jsp:include page="/WEB-INF/views/layout/mypage_sidebar.jsp">
    <jsp:param name="activeMenu" value="schedule"/> </jsp:include>

  <div class="dashboard-content">

    <h2 class="welcome-title">반가워요, <span>${sessionScope.loginUser.nickname}</span>님!</h2>

    <!-- 여행 요약 -->
    <div>
      <div class="section-header">
        <h3 class="section-title"><i class="bi bi-bar-chart-line"></i> 여행 요약</h3>
        <p class="section-subtitle">지금까지의 나의 여행 발자취</p>
      </div>
      <div class="summary-grid">
        <div class="summary-card">
          <i class="bi bi-suitcase-lg"></i>
          <div class="summary-value" id="val-trips">-</div>
          <div class="summary-label">총 여행 횟수</div>
        </div>
        <div class="summary-card">
          <i class="bi bi-pin-map"></i>
          <div class="summary-value" id="val-regions">-</div>
          <div class="summary-label">방문 지역 수</div>
        </div>
        <div class="summary-card">
          <i class="bi bi-moon-stars"></i>
          <div class="summary-value" id="val-avgdays">-</div>
          <div class="summary-label">평균 여행 기간</div>
        </div>
        <!-- 일정 히스토리-->
        <div class="summary-card" style="cursor:pointer;" onclick="location.href='${pageContext.request.contextPath}/mypage/schedule'">
          <i class="bi bi-clock-history"></i>
          <div class="summary-value" id="val-history">-</div>
          <div class="summary-label">완료한 일정</div>
        </div>
      </div>
    </div>

    <!-- 다가오는 여행 배너 -->
    <div id="upcoming-area">
      <!-- JS로 렌더링 -->
    </div>

    <!-- 여행 지도 -->
    <div class="clean-card">
      <div class="map-header">
        <h3><i class="bi bi-map"></i> 나의 여행 지도</h3>
        <button class="btn-download"><i class="bi bi-download"></i> 이미지로 저장</button>
      </div>
      <div class="map-placeholder">
        <i class="bi bi-geo-alt"></i>
        이곳에 색칠된 대한민국 지도가 표시됩니다.
      </div>
    </div>

  </div>
</main>

<!-- ════ 팔로우 모달 ════ -->
<div class="modal-overlay" id="followModal" onclick="closeModalByOverlay('followModal', event)">
  <div class="custom-modal">
    <div class="modal-header">
      <h3 id="follow-modal-title">팔로워</h3>
      <button class="btn-close" onclick="closeModal('followModal')">✕</button>
    </div>
    <div id="follow-modal-body">
      <div class="modal-loading"><div class="spin"></div>불러오는 중...</div>
    </div>
  </div>
</div>

<!-- ════ 배지 모달 ════ -->
<div class="modal-overlay" id="badgeModal" onclick="closeModalByOverlay('badgeModal', event)">
  <div class="custom-modal" style="max-width:480px;">
    <div class="modal-header">
      <h3>획득한 배지</h3>
      <button class="btn-close" onclick="closeModal('badgeModal')">✕</button>
    </div>
    <div id="badge-modal-body">
      <div class="modal-loading"><div class="spin"></div>불러오는 중...</div>
    </div>
  </div>
</div>

<jsp:include page="/WEB-INF/views/layout/footer.jsp"/>

<script>
  // ─── 요약 통계 + 다가오는 여행 ───
  async function loadSummary() {
    try {
      const res = await fetch('/mypage/api/summary');
      if (!res.ok) throw new Error();
      const data = await res.json();

      // 통계 카드
      document.getElementById('val-trips').textContent   = data.totalTripCount   ?? 0;
      document.getElementById('val-regions').textContent = data.visitedRegionCount ?? 0;
      document.getElementById('val-avgdays').textContent = data.avgTripDays != null
        ? (Number.isInteger(data.avgTripDays) ? data.avgTripDays : data.avgTripDays.toFixed(1)) + '일'
        : '0일';
      document.getElementById('val-history').textContent = data.completedTripCount ?? 0;

      // 사이드바 통계
      if (data.member) {
        document.getElementById('stat-follower').textContent  = data.member.followerCount  ?? 0;
        document.getElementById('stat-following').textContent = data.member.followingCount ?? 0;
        document.getElementById('stat-badge').textContent     = data.member.badgeCount     ?? 0;
        // 아바타 이니셜
        var initEl = document.getElementById('avatar-initial');
        if (initEl && data.member.nickname) initEl.textContent = data.member.nickname.charAt(0);
      }

      // 다가오는 여행 배너
      renderUpcoming(data);

    } catch(e) {
      // API 실패 시 0으로 표시
      ['val-trips','val-regions','val-avgdays','val-history'].forEach(id => {
        document.getElementById(id).textContent = '0';
      });
      ['stat-follower','stat-following','stat-badge'].forEach(id => {
        document.getElementById(id).textContent = '0';
      });
      renderUpcoming(null);
    }
  }

  function renderUpcoming(data) {
    const area = document.getElementById('upcoming-area');
    let trip = null;

    // trips 배열에서 7일 내 일정 찾기
    if (data && data.upcomingTrip) {
      trip = data.upcomingTrip;
    }

    if (trip) {
      const dday = Math.ceil((new Date(trip.startDate) - new Date()) / 86400000);
      area.innerHTML =
        '<div class="upcoming-banner" onclick="location.href=\'/mypage/schedule\'">' +
          '<i class="bi bi-airplane-fill"></i>' +
          '<div class="up-info">' +
            '<div class="up-lbl">✈️ 다가오는 여행</div>' +
            '<div class="up-name">' + escHtml(trip.tripName) + '</div>' +
            '<div class="up-date">' +
              '<i class="bi bi-calendar3" style="font-size:11px"></i> ' +
              escHtml(formatDate(trip.startDate)) + ' ~ ' + escHtml(formatDate(trip.endDate)) +
              (trip.regionName ? ' · ' + escHtml(trip.regionName) : '') +
            '</div>' +
          '</div>' +
          '<div class="up-dday">D-' + dday + '</div>' +
        '</div>';
    } else {
      area.innerHTML =
        '<div class="upcoming-none">' +
          '<div class="upcoming-none-icon"><i class="bi bi-calendar3"></i></div>' +
          '<div class="upcoming-none-text">' +
            '<h4>다가오는 여행</h4>' +
            '<p>일주일 내 예정된 여행이 없어요</p>' +
          '</div>' +
        '</div>';
    }
  }

  // ─── 팔로우 모달 ───
  async function openFollowModal(type) {
    const modal = document.getElementById('followModal');
    const title = document.getElementById('follow-modal-title');
    const body  = document.getElementById('follow-modal-body');

    title.textContent = type === 'follower' ? '팔로워' : '팔로잉';
    body.innerHTML = '<div class="modal-loading"><div class="spin"></div>불러오는 중...</div>';
    modal.classList.add('active');
    document.body.style.overflow = 'hidden';

    try {
      const url  = type === 'follower' ? '/mypage/api/followers' : '/mypage/api/following';
      const res  = await fetch(url);
      if (!res.ok) throw new Error();
      const list = await res.json();

      if (!list || list.length === 0) {
        body.innerHTML = '<div class="modal-empty"><i class="bi bi-people"></i><p>' + (type === 'follower' ? '팔로워가' : '팔로잉이') + ' 없어요</p></div>';
        return;
      }

      body.innerHTML = '<div class="user-list">' +
        list.map(function(u) {
          return '<div class="user-item">' +
            '<div class="user-pic">' +
              (u.profileImage ? '<img src="' + escHtml(u.profileImage) + '" alt="">' : escHtml((u.nickname || '?').charAt(0))) +
            '</div>' +
            '<div>' +
              '<div class="user-name">' + escHtml(u.nickname || '') + '</div>' +
              '<div class="user-id">@' + escHtml(u.loginId || '') + '</div>' +
            '</div>' +
            (u.followingBack ? '<span style="margin-left:auto;font-size:10px;font-weight:800;color:var(--sky-blue);background:rgba(137,207,240,.15);padding:2px 8px;border-radius:20px;">맞팔</span>' : '') +
          '</div>';
        }).join('') +
        '</div>';
    } catch(e) {
      body.innerHTML = '<div class="modal-empty"><i class="bi bi-exclamation-circle"></i><p>불러오기에 실패했어요</p></div>';
    }
  }

  // ─── 배지 SVG 아이콘 매핑 ───
  var BADGE_SVGS = {
    'default':    '<svg class="badge-icon" fill="none" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" viewBox="0 0 24 24"><circle cx="12" cy="8" r="6"/><path d="M15.477 12.89L17 22l-5-3-5 3 1.523-9.11"/></svg>',
    'explorer':   '<svg class="badge-icon" fill="none" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" viewBox="0 0 24 24"><path d="M12 2L2 7l10 5 10-5-10-5zM2 17l10 5 10-5M2 12l10 5 10-5"/></svg>',
    'photo':      '<svg class="badge-icon" fill="none" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" viewBox="0 0 24 24"><path d="M23 19a2 2 0 0 1-2 2H3a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h4l2-3h6l2 3h4a2 2 0 0 1 2 2z"/><circle cx="12" cy="13" r="4"/></svg>',
    'food':       '<svg class="badge-icon" fill="none" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" viewBox="0 0 24 24"><path d="M18 8h1a4 4 0 0 1 0 8h-1"/><path d="M2 8h16v9a4 4 0 0 1-4 4H6a4 4 0 0 1-4-4V8z"/><line x1="6" y1="1" x2="6" y2="4"/><line x1="10" y1="1" x2="10" y2="4"/><line x1="14" y1="1" x2="14" y2="4"/></svg>',
    'mountain':   '<svg class="badge-icon" fill="none" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" viewBox="0 0 24 24"><path d="M8 3l4 8 5-5 5 15H2L8 3z"/></svg>',
    'map':        '<svg class="badge-icon" fill="none" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" viewBox="0 0 24 24"><polygon points="1 6 1 22 8 18 16 22 23 18 23 2 16 6 8 2 1 6"/><line x1="8" y1="2" x2="8" y2="18"/><line x1="16" y1="6" x2="16" y2="22"/></svg>',
    'star':       '<svg class="badge-icon" fill="none" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" viewBox="0 0 24 24"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/></svg>',
    'heart':      '<svg class="badge-icon" fill="none" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" viewBox="0 0 24 24"><path d="M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 0 0-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 0 0 0-7.78z"/></svg>',
    'sun':        '<svg class="badge-icon" fill="none" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" viewBox="0 0 24 24"><circle cx="12" cy="12" r="5"/><line x1="12" y1="1" x2="12" y2="3"/><line x1="12" y1="21" x2="12" y2="23"/><line x1="4.22" y1="4.22" x2="5.64" y2="5.64"/><line x1="18.36" y1="18.36" x2="19.78" y2="19.78"/><line x1="1" y1="12" x2="3" y2="12"/><line x1="21" y1="12" x2="23" y2="12"/><line x1="4.22" y1="19.78" x2="5.64" y2="18.36"/><line x1="18.36" y1="5.64" x2="19.78" y2="4.22"/></svg>'
  };

  function getBadgeSvg(b) {
    if (b.badgeImageUrl) {
      return '<img src="' + escHtml(b.badgeImageUrl) + '" alt="" class="badge-icon">';
    }
    var key = (b.badgeType || b.badgeCategory || '').toLowerCase();
    if (BADGE_SVGS[key]) return BADGE_SVGS[key];
    // 이름 기반 fallback
    var name = (b.badgeName || '');
    if (name.indexOf('탐험') !== -1 || name.indexOf('바다') !== -1) return BADGE_SVGS['explorer'];
    if (name.indexOf('포토') !== -1 || name.indexOf('사진') !== -1) return BADGE_SVGS['photo'];
    if (name.indexOf('맛집') !== -1 || name.indexOf('음식') !== -1) return BADGE_SVGS['food'];
    if (name.indexOf('산') !== -1 || name.indexOf('등산') !== -1) return BADGE_SVGS['mountain'];
    if (name.indexOf('지도') !== -1 || name.indexOf('정복') !== -1) return BADGE_SVGS['map'];
    if (name.indexOf('별') !== -1 || name.indexOf('스타') !== -1) return BADGE_SVGS['star'];
    return BADGE_SVGS['default'];
  }

  // ─── 배지 모달 ───
  async function openBadgeModal() {
    var modal = document.getElementById('badgeModal');
    var body  = document.getElementById('badge-modal-body');

    body.innerHTML = '<div class="modal-loading"><div class="spin"></div>불러오는 중...</div>';
    modal.classList.add('active');
    document.body.style.overflow = 'hidden';

    try {
      var res   = await fetch('/mypage/api/badges');
      if (!res.ok) throw new Error();
      var list  = await res.json();
      var earned = list.filter(function(b) { return b.earned; });

      if (!earned.length) {
        body.innerHTML = '<div class="modal-empty"><i class="bi bi-award"></i><p>아직 획득한 배지가 없어요</p></div>';
        return;
      }

      body.innerHTML = '<div class="badge-grid">' +
        earned.map(function(b) {
          return '<div class="badge-item' + (b.equipped ? ' active' : '') + '" onclick="equipBadge(' + b.badgeId + ', this)">' +
            getBadgeSvg(b) +
            '<span class="badge-name">' + escHtml(b.badgeName) + '</span>' +
          '</div>';
        }).join('') +
        '</div>';
    } catch(e) {
      body.innerHTML = '<div class="modal-empty"><i class="bi bi-exclamation-circle"></i><p>불러오기에 실패했어요</p></div>';
    }
  }

  async function equipBadge(badgeId, el) {
    try {
      var res = await fetch('/mypage/api/badges/' + badgeId + '/equip', { method: 'PUT' });
      if (!res.ok) throw new Error();
      document.querySelectorAll('.badge-item').forEach(function(item) {
        item.classList.remove('active');
      });
      el.classList.add('active');
    } catch(e) {
      alert('배지 장착에 실패했어요');
    }
  }

  // ─── 모달 닫기 ───
  function closeModal(id) {
    document.getElementById(id).classList.remove('active');
    document.body.style.overflow = 'auto';
  }
  function closeModalByOverlay(id, e) {
    if (e.target === document.getElementById(id)) closeModal(id);
  }

  // ─── 유틸 ───
  function formatDate(v) {
    if (!v) return '';
    return new Date(v).toLocaleDateString('ko-KR', { year: '2-digit', month: '2-digit', day: '2-digit' });
  }
  function escHtml(s) {
    if (!s) return '';
    return String(s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;');
  }

  // ─── 초기 로드 ───
  document.addEventListener('DOMContentLoaded', loadSummary);
</script>
</body>
</html>
