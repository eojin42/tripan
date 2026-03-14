<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>나의 여행지도 - Tripan</title>
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/gh/orioncactus/pretendard@v1.3.8/dist/web/static/pretendard.css">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
  <script src="https://cdnjs.cloudflare.com/ajax/libs/d3/7.8.5/d3.min.js"></script>
  <script src="https://cdnjs.cloudflare.com/ajax/libs/html2canvas/1.4.1/html2canvas.min.js"></script>
  <style>
    :root {
      --sky:#89CFF0; --sky-light:#E6F4FF; --pink:#FFB6C1;
      --grad:linear-gradient(135deg,var(--sky),var(--pink));
      --bg:#F0F8FF; --white:#fff;
      --text:#2D3748; --dark:#4A5568; --muted:#718096;
      --border:#E2E8F0; --radius:20px;
      --bounce:cubic-bezier(0.34,1.56,0.64,1);
    }
    *{box-sizing:border-box;margin:0;padding:0;}
    body{background:var(--bg);color:var(--text);font-family:'Pretendard',sans-serif;
      background-image:radial-gradient(at 0% 0%,rgba(137,207,240,.15) 0,transparent 50%),
                       radial-gradient(at 100% 100%,rgba(255,182,193,.15) 0,transparent 50%);
      background-attachment:fixed;}

    /* ── 메인 레이아웃 (사이드바 + 컨텐츠) ── */
    .mypage-container{
      max-width:1400px;width:90%;margin:120px auto 80px;
      display:grid;grid-template-columns:280px 1fr;
      gap:40px;align-items:start;
    }
    .glass-card{background:rgba(255,255,255,.65);backdrop-filter:blur(20px);
      border:1px solid rgba(255,255,255,.8);border-radius:var(--radius);padding:24px;
      box-shadow:0 12px 32px rgba(45,55,72,.04);}
    .profile-widget{text-align:center;}
    .profile-avatar{width:88px;height:88px;border-radius:50%;border:4px solid #fff;
      box-shadow:0 8px 16px rgba(137,207,240,.3);margin:0 auto 14px;overflow:hidden;background:#fff;}
    .profile-avatar-default{width:100%;height:100%;background:var(--grad);
      display:flex;align-items:center;justify-content:center;color:#fff;font-size:28px;font-weight:900;}
    .profile-name{font-size:20px;font-weight:900;margin-bottom:4px;}
    .profile-bio{font-size:13px;color:var(--muted);margin-bottom:16px;line-height:1.4;}
    .btn-edit-profile{background:#fff;color:var(--dark);border:1px solid var(--border);
      padding:8px 16px;border-radius:20px;font-size:13px;font-weight:700;cursor:pointer;
      transition:.2s;width:100%;font-family:inherit;}
    .btn-edit-profile:hover{background:var(--text);color:#fff;border-color:transparent;}
    .profile-stats{display:flex;justify-content:space-around;margin-top:20px;padding-top:20px;
      border-top:1px dashed rgba(45,55,72,.1);}
    .stat-box{display:flex;flex-direction:column;align-items:center;font-size:12px;color:var(--muted);
      font-weight:600;cursor:pointer;padding:4px 8px;border-radius:8px;transition:.2s;gap:2px;}
    .stat-box:hover{background:rgba(137,207,240,.1);color:var(--sky);}
    .stat-box strong{font-size:18px;color:var(--text);font-weight:900;}
    .side-nav{list-style:none;padding:0;margin:0;display:flex;flex-direction:column;gap:6px;}
    .side-nav li{border-radius:16px;overflow:hidden;}
    .side-nav a{display:flex;align-items:center;gap:12px;padding:13px 20px;color:var(--dark);
      font-weight:700;font-size:14px;text-decoration:none;transition:all .3s;}
    .side-nav a i{font-size:16px;width:20px;text-align:center;flex-shrink:0;}
    .side-nav a:hover{background:rgba(255,255,255,.8);color:var(--sky);padding-left:24px;}
    .side-nav li.active a{background:var(--grad);color:#fff;box-shadow:0 4px 12px rgba(137,207,240,.4);}
    .side-nav li.active a i{color:#fff;}

    /* ── 커스텀 지도 아이콘 ── */
    /* 사이드바 a 태그 안 svg를 직접 쓰는 방식 - 별도 CSS 불필요 */
    .side-nav a svg.nav-icon {
      width: 16px; height: 16px;
      flex-shrink: 0;
      stroke: currentColor; fill: none;
      stroke-width: 1.8;
      stroke-linecap: round; stroke-linejoin: round;
    }

    /* ── 컨텐츠 영역 ── */
    .dashboard-content{display:flex;flex-direction:column;gap:24px;padding-top:20px;}

    /* ── 지도 카드 ── */
    .map-card{background:var(--white);border-radius:var(--radius);border:1px solid var(--border);
      box-shadow:0 4px 24px rgba(0,0,0,.03);overflow:hidden;}
    .map-card-header{padding:18px 24px;border-bottom:1px solid var(--border);
      display:flex;align-items:center;justify-content:space-between;flex-wrap:wrap;gap:10px;}
    .map-card-header h2{font-size:17px;font-weight:900;display:flex;align-items:center;gap:8px;margin:0;}
    .map-card-header h2 i{color:var(--sky);}
    .map-toolbar{display:flex;gap:8px;flex-wrap:wrap;}
    .btn-tool{height:34px;padding:0 12px;border-radius:10px;border:1.5px solid var(--border);
      background:var(--white);font-size:12px;font-weight:700;color:var(--muted);cursor:pointer;
      display:flex;align-items:center;gap:5px;transition:.2s;font-family:inherit;}
    .btn-tool:hover{border-color:var(--sky);color:var(--sky);}
    .btn-tool.primary{background:var(--grad);color:#fff;border:none;
      box-shadow:0 4px 12px rgba(137,207,240,.3);}
    .btn-tool.primary:hover{opacity:.88;color:#fff;}

    #map-container{position:relative;background:#F8FAFC;
      /* 지도가 잘리지 않도록 min-height 지정 */
      min-height:500px;
    }
    #mini-map-svg{width:100%;height:auto;display:block;}

    /* ── 툴팁 ── */
    #map-tooltip{position:fixed;background:rgba(45,55,72,.88);color:#fff;padding:6px 13px;
      border-radius:8px;font-size:13px;font-weight:700;pointer-events:none;
      opacity:0;transition:opacity .15s;z-index:10000;box-shadow:0 4px 12px rgba(0,0,0,.15);}

    /* ── 사이드 통계 패널 ── */
    .map-side{display:flex;flex-direction:column;gap:16px;}
    .panel-card{background:var(--white);border-radius:var(--radius);border:1px solid var(--border);
      padding:20px;box-shadow:0 4px 20px rgba(0,0,0,.02);}
    .panel-card h3{font-size:13px;font-weight:900;margin-bottom:14px;
      display:flex;align-items:center;gap:7px;color:var(--text);}
    .panel-card h3 i{color:var(--sky);}
    .stat-row{display:flex;justify-content:space-between;align-items:center;
      padding:9px 0;border-bottom:1px solid var(--border);}
    .stat-row:last-child{border:none;}
    .stat-label{font-size:12px;color:var(--muted);font-weight:600;}
    .stat-val{font-size:15px;font-weight:900;color:var(--text);}
    .progress-bar-wrap{background:#F0F8FF;border-radius:8px;height:8px;overflow:hidden;margin-top:12px;}
    .progress-bar-fill{height:100%;background:var(--grad);border-radius:8px;transition:width .6s ease;}
    .region-tag{display:inline-flex;align-items:center;gap:5px;padding:6px 10px;border-radius:10px;
      background:#F0F8FF;font-size:11px;font-weight:700;color:var(--sky);margin:3px;cursor:pointer;transition:.2s;}
    .region-tag:hover{background:var(--sky);color:#fff;}
    .region-dot{width:7px;height:7px;border-radius:50%;flex-shrink:0;}

    /* ── 지도+사이드 패널 그리드 ── */
    .map-layout{display:grid;grid-template-columns:1fr 280px;gap:20px;align-items:start;}

    /* ── 사이드바(aside) 높이를 오른쪽 콘텐츠에 맞춤 ── */
    .mypage-container { align-items: stretch; }
    aside.sidebar {
      align-self: start;
      position: sticky;
      top: 120px;
      display: flex;
      flex-direction: column;
      gap: 20px;
    }
    /* 프로필 카드 고정, 네비 카드가 나머지 공간 채움 */
    aside.sidebar .glass-card:first-child { flex-shrink: 0; }
    aside.sidebar .glass-card:last-child  { flex: 1; }

    /* ── 모달 ── */
    .modal-overlay{position:fixed;inset:0;background:rgba(0,0,0,.4);backdrop-filter:blur(5px);
      display:flex;align-items:center;justify-content:center;z-index:9999;
      opacity:0;visibility:hidden;transition:.25s;}
    .modal-overlay.active{opacity:1;visibility:visible;}
    .modal-box{background:#fff;width:90%;max-width:420px;border-radius:24px;padding:28px;
      box-shadow:0 20px 48px rgba(0,0,0,.12);transform:translateY(16px);
      transition:.35s var(--bounce);max-height:90vh;overflow-y:auto;}
    .modal-overlay.active .modal-box{transform:translateY(0);}
    .modal-title{font-size:17px;font-weight:900;margin-bottom:20px;
      display:flex;align-items:center;justify-content:space-between;}
    .modal-title-left{display:flex;align-items:center;gap:8px;}
    .modal-title i{color:var(--sky);}
    .btn-modal-close{background:none;border:none;font-size:20px;color:var(--muted);
      cursor:pointer;line-height:1;padding:0;}
    .btn-modal-close:hover{color:var(--text);}
    .form-group{display:flex;flex-direction:column;gap:6px;margin-bottom:14px;}
    .form-group label{font-size:11px;font-weight:800;color:var(--muted);
      text-transform:uppercase;letter-spacing:.5px;}
    .form-row{display:grid;grid-template-columns:1fr 1fr;gap:10px;}
    .form-group input,.form-group textarea{
      border:1.5px solid var(--border);border-radius:10px;padding:10px 13px;
      font-size:13px;font-family:inherit;outline:none;transition:.2s;background:#fff;color:var(--text);}
    .form-group input:focus,.form-group textarea:focus{
      border-color:var(--sky);box-shadow:0 0 0 3px rgba(137,207,240,.15);}
    .form-group input[type=color]{height:44px;padding:4px;cursor:pointer;}
    .form-group input[type=date]{color:var(--text);}
    .btn-save{width:100%;height:46px;background:var(--grad);color:#fff;border:none;
      border-radius:12px;font-size:14px;font-weight:800;cursor:pointer;margin-top:6px;
      box-shadow:0 6px 16px rgba(137,207,240,.35);transition:.2s;font-family:inherit;}
    .btn-save:hover{opacity:.88;}
    .btn-delete{width:100%;height:38px;background:none;color:#FC8181;border:1.5px solid #FECACA;
      border-radius:10px;font-size:13px;font-weight:700;cursor:pointer;margin-top:8px;
      font-family:inherit;transition:.2s;}
    .btn-delete:hover{background:#FFF5F5;}

    @media(max-width:1100px){
      .mypage-container{grid-template-columns:1fr;}
      .sidebar{position:relative;top:0;}
      .map-layout{grid-template-columns:1fr;}
    }
    @media(max-width:680px){
      .mypage-container{width:96%;}
    }
  </style>
</head>
<body>

<jsp:include page="/WEB-INF/views/layout/header.jsp"/>

<main class="mypage-container">

  <%-- 사이드바 include (activeMenu=map 전달) --%>
  <jsp:include page="/WEB-INF/views/layout/mypage_sidebar.jsp">
    <jsp:param name="activeMenu" value="map"/>
  </jsp:include>

  <%-- 컨텐츠 영역 --%>
  <div class="dashboard-content">

    <div class="map-layout">

      <!-- 지도 카드 -->
      <div class="map-card">
        <div class="map-card-header">
          <h2><i class="bi bi-map-fill"></i> 나의 여행지도</h2>
          <div class="map-toolbar">
            <button class="btn-tool" id="btn-zoom-in"><i class="bi bi-plus-lg"></i> 확대</button>
            <button class="btn-tool" id="btn-zoom-out"><i class="bi bi-dash-lg"></i> 축소</button>
            <button class="btn-tool" id="btn-zoom-reset"><i class="bi bi-arrow-counterclockwise"></i> 초기화</button>
            <button class="btn-tool primary" id="btn-save-image"><i class="bi bi-camera"></i> 저장</button>
          </div>
        </div>
        <div id="map-container">
          <%-- viewBox 세로를 600으로 키우고, 스크립트에서 scale/center 조정 --%>
          <svg id="mini-map-svg" viewBox="0 0 500 600" xmlns="http://www.w3.org/2000/svg"></svg>
        </div>
      </div>

      <!-- 사이드 통계 패널 -->
      <div class="map-side">
        <div class="panel-card">
          <h3><i class="bi bi-bar-chart-fill"></i> 여행 통계</h3>
          <div class="stat-row">
            <span class="stat-label">방문한 지역</span>
            <span class="stat-val"><span id="cnt-visited">0</span> 곳</span>
          </div>
          <div class="stat-row">
            <span class="stat-label">전체 시/군</span>
            <span class="stat-val">229 곳</span>
          </div>
          <div class="stat-row">
            <span class="stat-label">달성률</span>
            <span class="stat-val"><span id="cnt-pct">0</span>%</span>
          </div>
          <div class="progress-bar-wrap">
            <div class="progress-bar-fill" id="progress-fill" style="width:0%"></div>
          </div>
        </div>

        <div class="panel-card">
          <h3><i class="bi bi-pin-map-fill"></i> 방문 지역</h3>
          <div id="visited-tags">
            <span style="font-size:12px;color:var(--muted);line-height:1.6;">
              지도에서 지역을 클릭해 기록을 남겨보세요!
            </span>
          </div>
        </div>
      </div>

    </div><%-- /map-layout --%>
  </div><%-- /dashboard-content --%>

</main>

<div id="map-tooltip"></div>

<!-- 지역 기록 모달 -->
<div class="modal-overlay" id="detailModal" onclick="if(event.target===this)closeModal()">
  <div class="modal-box">
    <input type="hidden" id="modal-sigungu">

    <!-- ── 조회 뷰 ── -->
    <div id="modal-view" style="display:none;">
      <div class="modal-title">
        <div class="modal-title-left">
          <i class="bi bi-map" style="color:var(--sky);"></i>
          <span id="view-region-name"></span>
        </div>
        <button class="btn-modal-close" onclick="closeModal()">✕</button>
      </div>

      <div style="display:flex;align-items:center;gap:10px;margin-bottom:16px;">
        <div id="view-color-dot" style="width:18px;height:18px;border-radius:50%;flex-shrink:0;border:1px solid var(--border);"></div>
        <span id="view-color-label" style="font-size:13px;color:var(--muted);font-weight:600;"></span>
      </div>

      <div id="view-date-row" style="display:none;margin-bottom:14px;">
        <span style="font-size:11px;font-weight:800;color:var(--muted);text-transform:uppercase;letter-spacing:.5px;">여행 기간</span>
        <p id="view-date" style="font-size:14px;font-weight:700;color:var(--text);margin:5px 0 0;"></p>
      </div>

      <div id="view-memo-row" style="display:none;margin-bottom:16px;">
        <span style="font-size:11px;font-weight:800;color:var(--muted);text-transform:uppercase;letter-spacing:.5px;">여행 메모</span>
        <p id="view-memo" style="font-size:14px;color:var(--text);margin:5px 0 0;line-height:1.6;white-space:pre-wrap;"></p>
      </div>

      <%-- 다중 사진 표시 영역 --%>
      <div id="view-photos" style="display:none;margin-bottom:16px;">
        <span style="font-size:11px;font-weight:800;color:var(--muted);text-transform:uppercase;letter-spacing:.5px;">추억 사진</span>
        <div id="view-photo-list" style="display:flex;flex-wrap:wrap;gap:8px;margin-top:8px;"></div>
      </div>

      <div style="display:flex;gap:8px;margin-top:8px;">
        <button class="btn-save" onclick="switchToEdit()" style="flex:1;">
          <i class="bi bi-pencil"></i> 수정하기
        </button>
        <button class="btn-delete" id="btn-delete-region"
                style="flex:0 0 auto;width:auto;padding:0 18px;margin:0;">
          <i class="bi bi-trash3"></i>
        </button>
      </div>
    </div>

    <!-- ── 등록/수정 폼 ── -->
    <div id="modal-form" style="display:none;">
      <div class="modal-title">
        <div class="modal-title-left">
          <i class="bi bi-pencil-square" style="color:var(--sky);"></i>
          <span id="form-region-name"></span>
        </div>
        <button class="btn-modal-close" onclick="closeModal()">✕</button>
      </div>

      <div class="form-group">
        <label>지도 색상</label>
        <input type="color" id="modal-color" value="#89CFF0">
      </div>
      <div class="form-row">
        <div class="form-group">
          <label>여행 시작일</label>
          <input type="date" id="modal-start">
        </div>
        <div class="form-group">
          <label>여행 종료일</label>
          <input type="date" id="modal-end">
        </div>
      </div>
      <div class="form-group">
        <label>여행 메모</label>
        <textarea id="modal-memo" rows="3" placeholder="이 지역에서의 추억을 기록해보세요..."></textarea>
      </div>

      <%-- 수정 모드: 기존 사진 목록 + 개별 삭제 --%>
      <div id="form-existing-photos" style="display:none;margin-bottom:14px;">
        <span style="font-size:11px;font-weight:800;color:var(--muted);text-transform:uppercase;letter-spacing:.5px;">등록된 사진</span>
        <div id="form-photo-list" style="display:flex;flex-wrap:wrap;gap:8px;margin-top:8px;"></div>
      </div>

      <div class="form-group">
        <label>사진 추가 (여러 장 선택 가능)</label>
        <input type="file" id="modal-photo" accept="image/*" multiple>
      </div>

      <div style="display:flex;gap:8px;margin-top:4px;">
        <button id="btn-cancel-edit" class="btn-delete"
                style="flex:0 0 auto;width:auto;padding:0 16px;margin:0;display:none;"
                onclick="switchToView()">취소</button>
        <button class="btn-save" id="btn-save-region" style="flex:1;">저장하기</button>
      </div>
    </div>

  </div>
</div>
<div id="image-viewer-modal" style="display:none; position:fixed; inset:0; background:rgba(0,0,0,0.85); z-index:99999; justify-content:center; align-items:center; cursor:zoom-out; backdrop-filter:blur(4px);" onclick="this.style.display='none'">
  <img id="image-viewer-img" src="" style="max-width:90%; max-height:90%; border-radius:12px; box-shadow:0 10px 40px rgba(0,0,0,0.5); object-fit:contain;">
  <span style="position:absolute; top:20px; right:30px; color:white; font-size:30px; font-weight:bold; cursor:pointer;">&times;</span>
</div>
<script>
  const ctxPath = '${pageContext.request.contextPath}';
</script>
<script src="${pageContext.request.contextPath}/dist/js/mypage/map.js"></script>
</body>
</html>
