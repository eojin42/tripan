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
    
    /* 지도 마우스 호버 애니메이션 */
    .mini-region {
      transition: all 0.3s ease; /* 부드러운 전환 효과 */
      cursor: pointer;
    }
    .mini-region:hover {
      fill-opacity: 0.6; /* 살짝 투명해지는 효과 */
      stroke: var(--sky-blue); /* 테두리가 하늘색으로 변함 */
      stroke-width: 1.5px;
    }

    /* 마우스 따라다니는 지역 이름 툴팁 */
    #map-tooltip {
      position: absolute;
      background: rgba(45, 55, 72, 0.85); /* 진한 회색 배경 */
      color: white;
      padding: 6px 12px;
      border-radius: 8px;
      font-size: 13px;
      font-weight: 700;
      pointer-events: none; /* 마우스 이벤트 무시 (지도 클릭을 방해하지 않음) */
      opacity: 0;
      transition: opacity 0.2s ease;
      z-index: 10000;
      box-shadow: 0 4px 12px rgba(0,0,0,0.1);
    }
    
    /* 지도 위 버튼 컨트롤 (저장, 확대/축소) */
    .map-controls {
      position: absolute;
      top: 15px;
      right: 15px;
      display: flex;
      flex-direction: column;
      gap: 8px;
      z-index: 10;
    }
    .btn-map-control {
      background: white;
      border: 1px solid var(--border-light);
      border-radius: 8px;
      padding: 8px 12px;
      font-size: 13px;
      font-weight: 700;
      color: var(--text-dark);
      cursor: pointer;
      box-shadow: 0 2px 8px rgba(0,0,0,0.05);
      transition: all 0.2s;
    }
    .btn-map-control:hover { background: var(--sky-blue); color: white; }
    
    /* 지도 컨테이너 상대 위치 설정 (버튼 배치를 위해) */
    #mini-map-wrap {
      position: relative;
      background: #F8FAFC; 
      border-radius: 16px; 
      overflow: hidden; 
    }
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
  </div>
  <div id="mini-map-wrap">
    <div class="map-controls">
      <button class="btn-map-control" id="btn-zoom-in"><i class="bi bi-zoom-in"></i> 확대</button>
      <button class="btn-map-control" id="btn-zoom-out"><i class="bi bi-zoom-out"></i> 축소</button>
      <button class="btn-map-control" id="btn-zoom-reset"><i class="bi bi-arrow-counterclockwise"></i> 초기화</button>
      <button class="btn-map-control" id="btn-save-image" style="margin-top:10px; border-color:var(--sky-blue); color:var(--sky-blue);">
        <i class="bi bi-camera"></i> 이미지 저장
      </button>
    </div>
    
    <svg id="mini-map-svg" viewBox="0 0 500 550" style="width:100%; height:auto;" xmlns="http://www.w3.org/2000/svg"></svg>
  </div>
</div>

<div class="modal-overlay" id="detailModal" onclick="closeModalByOverlay('detailModal', event)">
  <div class="custom-modal">
    <div class="modal-body" style="display:flex; flex-direction:column; gap:12px;">
      <input type="hidden" id="modal-sigungu">
      
      <label>지도 색상</label>
      <input type="color" id="modal-color" value="#89CFF0" style="width:100%; height:40px; border-radius:8px; border:none; cursor:pointer;">
      
      <div style="display:flex; gap:10px;">
        </div>
      
      <label>추억 사진 등록</label>
      <input type="file" id="modal-photo" accept="image/*" style="width:100%; padding:8px; border-radius:8px; border:1px solid #ddd; font-size:12px;">
      
      <label>여행 메모</label>
      <textarea id="modal-memo" rows="3" style="width:100%; padding:8px; border-radius:8px; border:1px solid #ddd;"></textarea>
      
      <button id="btn-save-region" style="background:var(--sky-blue); color:white; border:none; padding:12px; border-radius:12px; font-weight:800; cursor:pointer; margin-top:10px;">
        저장하기
      </button>
    </div>
  </div>
</div>
<div id="map-tooltip"></div>
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

<script src="${pageContext.request.contextPath}/dist/js/mypage/main.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/d3/7.8.5/d3.min.js"></script>
<script>
document.addEventListener("DOMContentLoaded", function() {
	const svg = d3.select("#mini-map-svg");
    const width = 500, height = 550;
    
    const projection = d3.geoMercator()
        .center([127.5, 36.0])
        .scale(5200)
        .translate([width / 2, height / 2.1]);
    const path = d3.geoPath().projection(projection);

    // 시/군/구 단위 GeoJSON (신뢰할 수 있는 kostat 데이터)
    const geoJsonUrl = "https://raw.githubusercontent.com/southkorea/southkorea-maps/master/kostat/2013/json/skorea_municipalities_geo_simple.json";
    const tooltip = d3.select("#map-tooltip");
    let visitedDataMap = {}; 

    const g = svg.append("g");

    const zoom = d3.zoom()
        .scaleExtent([1, 8]) // 1배 ~ 8배까지 확대 가능
        .on("zoom", (event) => {
            g.attr("transform", event.transform);
        });
    svg.call(zoom);

    // 줌 컨트롤 버튼 이벤트
    d3.select("#btn-zoom-in").on("click", () => svg.transition().duration(300).call(zoom.scaleBy, 1.5));
    d3.select("#btn-zoom-out").on("click", () => svg.transition().duration(300).call(zoom.scaleBy, 0.75));
    d3.select("#btn-zoom-reset").on("click", () => svg.transition().duration(300).call(zoom.transform, d3.zoomIdentity));
    
    d3.json(geoJsonUrl).then(function(data) {
        // 지도 그리기
        const paths = svg.selectAll("path")
            .data(data.features)
            .enter().append("path")
            .attr("d", path)
            .attr("class", "mini-region")
            .attr("data-sigungu", d => d.properties.name)
            .style("fill", "#EDF2F7")
            .style("stroke", "#ffffff")
            .style("stroke-width", "0.5px")
            .on("mouseover", function(event, d) {
                // 마우스 올리면 툴팁 보이기
                tooltip.style("opacity", 1).text(d.properties.name);
                d3.select(this).style("fill-opacity", 0.7).style("stroke", "#89CFF0").style("stroke-width", "1.5px");
            })
            .on("mousemove", function(event) {
                // 마우스 따라 툴팁 위치 이동
                tooltip.style("left", (event.pageX + 15) + "px")
                       .style("top", (event.pageY - 20) + "px");
            })
            .on("mouseout", function() {
                tooltip.style("opacity", 0);
                d3.select(this).style("fill-opacity", 1).style("stroke", "#ffffff").style("stroke-width", "0.5px");
            })
            .on("click", function(event, d) {
                openDetailModal(d.properties.name, this);
            });

        // 서버에서 내 데이터 불러와서 색칠하기
        loadVisitedData();
    });

    function loadVisitedData() {
        fetch('${pageContext.request.contextPath}/mypage/api/visited-regions-data')
            .then(res => res.json())
            .then(list => {
                list.forEach(item => {
                    visitedDataMap[item.sigunguName] = item; // 캐싱해두기
                    // 데이터 기반 색상 칠하기
                    g.select(`path[data-sigungu="\${item.sigunguName}"]`)
                       .style("fill", item.colorCode || '#89CFF0')
                       .classed("visited", true);
                }).catch(err => console.error(err));
            });
    }
	
    // 모달 열기
    function openDetailModal(sigunguName, pathElement) {
        document.getElementById('modal-region-name').innerText = sigunguName + " 여행 기록";
        document.getElementById('modal-sigungu').value = sigunguName;
        
        // 기존에 저장된 데이터가 있다면 모달에 셋팅 (보기/수정 모드)
        const existingData = visitedDataMap[sigunguName];
        document.getElementById('modal-color').value = existingData?.colorCode || '#89CFF0';
        document.getElementById('modal-start').value = existingData?.startDate || '';
        document.getElementById('modal-end').value = existingData?.endDate || '';
        document.getElementById('modal-memo').value = existingData?.memo || '';
        document.getElementById('modal-photo').value = ''; // 사진 입력 초기화

        document.getElementById('detailModal').classList.add('active');
    }
    
    // 저장 버튼 이벤트
    document.getElementById('btn-save-region').addEventListener('click', function() {
    	const formData = new FormData();
        formData.append("sigunguName", document.getElementById('modal-sigungu').value);
        formData.append("colorCode", document.getElementById('modal-color').value);
        
        const sd = document.getElementById('modal-start').value;
        const ed = document.getElementById('modal-end').value;
        if(sd) formData.append("startDate", sd);
        if(ed) formData.append("endDate", ed);
        
        formData.append("memo", document.getElementById('modal-memo').value);

        // 사진 파일이 첨부되었으면 추가
        const photoFile = document.getElementById('modal-photo').files[0];
        if (photoFile) {
            formData.append("photo", photoFile);
        }

        const csrfToken = document.querySelector("meta[name='_csrf']")?.getAttribute("content");
        const csrfHeader = document.querySelector("meta[name='_csrf_header']")?.getAttribute("content");
        let headers = {};
        if (csrfToken && csrfHeader) headers[csrfHeader] = csrfToken;

        // FormData 전송 시 Content-Type은 브라우저가 자동으로 multipart/form-data로 설정합니다.
        fetch('${pageContext.request.contextPath}/mypage/api/visited-regions-save', {
            method: 'POST',
            headers: headers,
            body: formData
        }).then(res => {
            if(res.ok) {
                alert("저장되었습니다.");
                closeModal('detailModal');
                loadVisitedData(); 
            } else res.text().then(text => alert("오류 발생: " + text));
        }).catch(err => alert("서버 연결 실패"));
    });

    // 이미지로 저장하기 (html2canvas)
    document.getElementById("btn-save-image").addEventListener("click", function() {
        // 일시적으로 컨트롤 버튼들 숨기기 (깔끔한 캡처를 위해)
        const controls = document.querySelector('.map-controls');
        controls.style.display = 'none';

        html2canvas(document.getElementById("mini-map-wrap"), {
            backgroundColor: "#F8FAFC",
            scale: 2 // 고화질 캡처
        }).then(canvas => {
            controls.style.display = 'flex'; // 다시 보이기
            
            const link = document.createElement("a");
            link.download = "My_Tripan_Map.png";
            link.href = canvas.toDataURL("image/png");
            link.click();
        });
    });

    window.closeModal = function(id) { document.getElementById(id).classList.remove('active'); }
    window.closeModalByOverlay = function(id, e) { if (e.target.id === id) closeModal(id); }
});
</script>
</body>
</html>
