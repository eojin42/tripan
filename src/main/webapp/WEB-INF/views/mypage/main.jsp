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
    .dashboard-content { display:flex; flex-direction:column; gap:28px; padding-top:20px; }
    .welcome-title { font-size:24px; font-weight:800; margin:0; }
    .welcome-title span { color:var(--sky-blue); }
    .section-header { margin-bottom:16px; }
    .section-title  { font-size:17px; font-weight:800; display:flex; align-items:center; gap:8px; margin:0 0 5px; }
    .section-title i { font-size:17px; color:var(--sky-blue); }
    .section-subtitle { font-size:13px; color:var(--text-gray); font-weight:500; margin:0; }
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
    .middle-banner-grid { display:grid; grid-template-columns:2fr 1fr; gap:20px; }
    .upcoming-banner {
      background:var(--grad-main); border-radius:20px; padding:22px 28px;
      display:flex; align-items:center; gap:20px; color:white;
      box-shadow:0 12px 28px rgba(137,207,240,.35);
      cursor:pointer; transition:transform .3s var(--bounce); height:100%;
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
      border:1px solid var(--border-light); box-shadow:0 4px 16px rgba(0,0,0,.02); height:100%;
    }
    .upcoming-none-icon {
      width:50px; height:50px; border-radius:14px;
      background:var(--sky-blue-light); flex-shrink:0;
      display:flex; align-items:center; justify-content:center;
      color:var(--sky-blue); font-size:22px;
    }
    .upcoming-none-text h4 { font-size:13px; font-weight:700; color:var(--text-gray); margin:0 0 5px; }
    .upcoming-none-text p  { font-size:17px; font-weight:800; color:var(--text-black); margin:0; }
    
    /* ── 미니 지도 ── */
    .map-header { display:flex; justify-content:space-between; align-items:center; margin-bottom:16px; }
    .map-header h3 { margin:0; font-size:17px; font-weight:800; display:flex; align-items:center; gap:8px; }
    .map-header h3 i { color:var(--sky-blue); }
    .btn-view-map {
      font-size:13px; font-weight:700; color:var(--sky-blue); background:white;
      padding:7px 14px; border-radius:8px; border:1px solid var(--sky-blue);
      cursor:pointer; transition:.2s; text-decoration:none;
    }
    .btn-view-map:hover { background:var(--sky-blue); color:white; }
    #mini-map-wrap { background:#F8FAFC; border-radius:16px; padding:12px; overflow:hidden; }
    #mini-map-svg { width:100%; height:auto; display:block; }
    .mini-region { fill:#EDF2F7; stroke:white; stroke-width:0.5; transition:fill .3s; cursor:default; }
    .mini-region.visited { fill:rgba(137,207,240,.65); }
    .mini-visited-tag {
      font-size:10px; font-weight:800; padding:3px 10px;
      border-radius:20px; background:rgba(137,207,240,.15); color:var(--sky-blue);
    }
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
    .user-list { display:flex; flex-direction:column; gap:8px; max-height:320px; overflow-y:auto; }
    .user-item {
      display:flex; align-items:center; gap:12px; padding:12px 14px;
      border-radius:14px; background:#F8FAFC; border:1px solid var(--border-light); transition:.2s;
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
    .badge-grid {
      display:grid; grid-template-columns:repeat(3,1fr); gap:12px;
      max-height:360px; overflow-y:auto; padding:2px;
    }
    .badge-item {
      display:flex; flex-direction:column; align-items:center; justify-content:center;
      gap:10px; padding:20px 12px; background:#F8FAFC;
      border-radius:16px; border:1.5px solid var(--border-light);
      cursor:pointer; transition:all .25s var(--bounce); position:relative;
    }
    .badge-item:hover { border-color:var(--sky-blue); background:var(--sky-blue-light); transform:translateY(-3px); box-shadow:0 8px 20px rgba(137,207,240,.2); }
    .badge-item.active { border-color:var(--sky-blue); background:var(--sky-blue-light); box-shadow:0 4px 16px rgba(137,207,240,.25); }
    .badge-item.active::after {
      content:'장착 중'; position:absolute; top:8px; right:8px;
      font-size:9px; font-weight:800; color:var(--sky-blue);
      background:rgba(137,207,240,.25); padding:2px 7px; border-radius:20px;
    }
    .badge-icon { width:36px; height:36px; color:var(--sky-blue); stroke:var(--sky-blue); flex-shrink:0; }
    .badge-item img.badge-icon { object-fit:contain; }
    .badge-name { font-size:11px; font-weight:800; color:var(--text-dark); text-align:center; line-height:1.3; word-break:keep-all; }
    .modal-loading { display:flex; flex-direction:column; align-items:center; padding:30px; gap:12px; color:var(--text-gray); font-size:13px; font-weight:600; }
    .spin { width:28px; height:28px; border:3px solid rgba(137,207,240,.2); border-top-color:var(--sky-blue); border-radius:50%; animation:sp .7s linear infinite; }
    @keyframes sp { to { transform:rotate(360deg); } }
    .modal-empty { text-align:center; padding:30px 20px; color:var(--text-gray); }
    .modal-empty i { font-size:32px; display:block; margin-bottom:8px; opacity:.25; color:var(--sky-blue); }
    .modal-empty p { font-size:13px; font-weight:600; margin:0; }
    @media(max-width:1024px){
      .mypage-container { grid-template-columns:1fr; gap:24px; }
      .sidebar { position:relative; top:0; }
      .summary-grid { grid-template-columns:repeat(2,1fr); }
    }
    @media(max-width:480px){ .summary-grid { grid-template-columns:repeat(2,1fr); } }
    /* ── 마이페이지 전용 채팅 플로팅 버튼 & 미니 모달 ── */
    .mypage-chat-fab-container {
        position: fixed; bottom: 40px; right: 40px; z-index: 9990;
    }
    .mypage-chat-fab {
        width: 64px; height: 64px; border-radius: 50%;
        background: var(--grad-main); color: white; font-size: 28px;
        border: none; box-shadow: 0 8px 24px rgba(255, 182, 193, 0.5);
        cursor: pointer; transition: transform 0.3s var(--bounce);
        display: flex; justify-content: center; align-items: center;
    }
    .mypage-chat-fab:hover { transform: translateY(-5px) scale(1.05); }
    .mypage-chat-badge {
        position: absolute; top: -2px; right: -2px;
        background: #FF6B6B; color: white; font-size: 11px; font-weight: 900;
        width: 22px; height: 22px; border-radius: 50%;
        display: flex; justify-content: center; align-items: center; border: 2px solid white;
    }
    .mypage-chat-mini-modal {
        position: absolute; bottom: 85px; right: 0; width: 340px;
        background: white; border-radius: 20px;
        box-shadow: 0 12px 36px rgba(0,0,0,0.15); border: 1px solid var(--border-light);
        display: none; flex-direction: column; overflow: hidden;
        transform-origin: bottom right; animation: popUp 0.3s var(--bounce) forwards;
    }
    .mypage-chat-mini-modal.active { display: flex; }
    @keyframes popUp {
        0% { opacity: 0; transform: scale(0.8); }
        100% { opacity: 1; transform: scale(1); }
    }
    .mini-modal-header {
        display: flex; justify-content: space-between; align-items: center;
        padding: 18px 20px; border-bottom: 1px solid var(--border-light); background: #F8FAFC;
    }
    .mini-modal-header h4 { margin: 0; font-size: 15px; font-weight: 800; color: var(--text-black); }
    .btn-view-all {
        background: var(--sky-blue-light); border: none; color: var(--sky-blue);
        font-size: 11px; font-weight: 800; cursor: pointer; padding: 6px 12px; border-radius: 12px; transition: 0.2s;
    }
    .btn-view-all:hover { background: var(--sky-blue); color: white; }
    .mini-modal-body { padding: 12px; max-height: 320px; overflow-y: auto; }
  </style>
</head>
<body>

<jsp:include page="/WEB-INF/views/layout/header.jsp"/>

<main class="mypage-container">
  <jsp:include page="/WEB-INF/views/layout/mypage_sidebar.jsp">
    <jsp:param name="activeMenu" value="main"/>
  </jsp:include>

  <div class="dashboard-content">

    <h2 class="welcome-title">반가워요, <span>${sessionScope.loginUser.nickname}</span>님!</h2>

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
        <div class="summary-card" style="cursor:pointer;" onclick="location.href='${pageContext.request.contextPath}/mypage/schedule'">
          <i class="bi bi-clock-history"></i>
          <div class="summary-value" id="val-history">-</div>
          <div class="summary-label">완료한 일정</div>
        </div>
      </div>
    </div>

    <div class="middle-banner-grid">
      <div id="upcoming-area"></div>
      
    </div>

    <!-- 나의 여행 지도 (D3.js 미니 지도) -->
    <div class="clean-card">
      <div class="map-header">
        <h3><i class="bi bi-map"></i> 나의 여행 지도</h3>
        <a href="${pageContext.request.contextPath}/mypage/map" class="btn-view-map">
          <i class="bi bi-arrow-right"></i> 전체 보기
        </a>
      </div>
      <div style="display:grid; grid-template-columns:1fr 160px; gap:16px; align-items:center;">
        <div id="mini-map-wrap">
          <svg id="mini-map-svg" viewBox="0 0 380 480" xmlns="http://www.w3.org/2000/svg"></svg>
        </div>
        <div style="display:flex; flex-direction:column; gap:12px;">
          <div style="text-align:center; padding:16px; background:#F8FAFC; border-radius:14px;">
            <div style="font-size:32px; font-weight:900; color:var(--text-black);" id="mini-visited-cnt">-</div>
            <div style="font-size:11px; color:var(--text-gray); font-weight:700;">/ 17 지역 방문</div>
            <div style="height:6px; background:#E2E8F0; border-radius:4px; margin-top:8px; overflow:hidden;">
              <div id="mini-progress" style="height:100%; background:var(--grad-main); border-radius:4px; width:0%; transition:width .6s ease;"></div>
            </div>
          </div>
          <div id="mini-visited-tags" style="display:flex; flex-wrap:wrap; gap:6px;"></div>
        </div>
      </div>
    </div>

  </div>
</main>

<!-- 팔로우 모달 -->
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

<!-- 배지 모달 -->
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

<script src="https://cdnjs.cloudflare.com/ajax/libs/d3/7.8.5/d3.min.js"></script>
<script src="${pageContext.request.contextPath}/dist/js/mypage/main.js"></script>



</body>
</html>
