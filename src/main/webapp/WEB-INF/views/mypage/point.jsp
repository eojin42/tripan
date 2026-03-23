<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Tripan - 포인트 내역</title>
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/gh/orioncactus/pretendard@v1.3.8/dist/web/static/pretendard.css">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
  <style>
    :root {
      --sky:#89CFF0; --sky-light:#E6F4FF; --pink:#FFB6C1;
      --grad:linear-gradient(135deg,var(--sky),var(--pink));
      --bg:#F0F8FF; --white:#fff;
      --text:#2D3748; --dark:#4A5568; --muted:#718096;
      --border:#E2E8F0; --radius:20px;
      --bounce:cubic-bezier(0.34,1.56,0.64,1);
      --green:#48BB78; --green-light:#F0FFF4;
      --red:#FC8181; --red-light:#FFF5F5;
    }
    *{box-sizing:border-box;}
    body{background:var(--bg);color:var(--text);font-family:'Pretendard',sans-serif;margin:0;padding:0;
      background-image:radial-gradient(at 0% 0%,rgba(137,207,240,.15) 0,transparent 50%),
                       radial-gradient(at 100% 100%,rgba(255,182,193,.15) 0,transparent 50%);
      background-attachment:fixed;}

    .mypage-container{max-width:1400px;width:90%;margin:120px auto 80px;
      display:grid;grid-template-columns:280px 1fr;gap:40px;align-items:start;}

    /* ── 공통 카드 ── */
    .glass-card{background:rgba(255,255,255,.65);backdrop-filter:blur(20px);
      border:1px solid rgba(255,255,255,.8);border-radius:var(--radius);padding:24px;
      box-shadow:0 12px 32px rgba(45,55,72,.04);}
    .clean-card{background:var(--white);border:1px solid var(--border);
      border-radius:var(--radius);padding:24px;box-shadow:0 4px 20px rgba(0,0,0,.02);}

    /* ── 사이드바 ── */
    .sidebar{position:sticky;top:120px;display:flex;flex-direction:column;gap:20px;}
    .profile-widget{text-align:center;}
    .profile-avatar{width:88px;height:88px;border-radius:50%;border:4px solid #fff;
      box-shadow:0 8px 16px rgba(137,207,240,.3);margin:0 auto 14px;overflow:hidden;background:#fff;}
    .profile-avatar img{width:100%;height:100%;object-fit:cover;}
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

    /* ── 메인 콘텐츠 ── */
    .dashboard-content{display:flex;flex-direction:column;gap:28px;padding-top:20px;}
    .welcome-title{font-size:24px;font-weight:800;margin:0;}
    .welcome-title span{color:var(--sky);}
    .section-title{font-size:17px;font-weight:800;display:flex;align-items:center;gap:8px;margin:0 0 5px;}
    .section-title i{font-size:17px;color:var(--sky);}
    .section-subtitle{font-size:13px;color:var(--muted);font-weight:500;margin:0 0 16px;}
    .section-head{display:flex;justify-content:space-between;align-items:center;margin-bottom:5px;}

    /* ── 스켈레톤 ── */
    .skeleton{background:linear-gradient(90deg,#f0f0f0 25%,#e0e0e0 50%,#f0f0f0 75%);
      background-size:200% 100%;animation:shimmer 1.2s infinite;border-radius:8px;}
    @keyframes shimmer{0%{background-position:200% 0}100%{background-position:-200% 0}}

    /* ── 모달 ── */
    .modal-overlay{position:fixed;inset:0;background:rgba(0,0,0,.4);backdrop-filter:blur(4px);
      display:flex;align-items:center;justify-content:center;z-index:9999;opacity:0;visibility:hidden;transition:.3s;}
    .modal-overlay.active{opacity:1;visibility:visible;}
    .custom-modal{background:#fff;width:90%;max-width:420px;border-radius:24px;padding:28px;
      box-shadow:0 20px 40px rgba(0,0,0,.1);transform:translateY(20px);transition:.4s var(--bounce);}
    .modal-overlay.active .custom-modal{transform:translateY(0);}
    .modal-header{display:flex;justify-content:space-between;align-items:center;margin-bottom:18px;}
    .modal-header h3{margin:0;font-size:17px;font-weight:800;}
    .btn-close{background:none;border:none;font-size:22px;color:var(--muted);cursor:pointer;}

    /* ── 포인트 요약 배너 ── */
    .point-banner{
      background:var(--grad);border-radius:var(--radius);padding:28px 32px;
      display:flex;align-items:center;justify-content:space-between;
      color:#fff;box-shadow:0 12px 28px rgba(137,207,240,.35);}
    .point-banner-left{display:flex;flex-direction:column;gap:6px;}
    .point-banner-label{font-size:13px;font-weight:700;opacity:.88;}
    .point-banner-value{font-size:40px;font-weight:900;letter-spacing:-1px;line-height:1;}
    .point-banner-value small{font-size:18px;font-weight:700;margin-left:4px;}
    .point-banner-sub{font-size:12px;opacity:.8;display:flex;align-items:center;gap:5px;}
    .point-banner-icon{font-size:64px;opacity:.25;}

    /* ── 포인트 요약 카드 3개 ── */
    .point-summary-grid{display:grid;grid-template-columns:repeat(3,1fr);gap:14px;}
    .point-summary-card{background:#fff;border-radius:16px;padding:20px 18px;
      border:1px solid var(--border);box-shadow:0 4px 16px rgba(0,0,0,.02);
      display:flex;flex-direction:column;gap:6px;
      transition:transform .3s var(--bounce);}
    .point-summary-card:hover{transform:translateY(-4px);box-shadow:0 8px 24px rgba(137,207,240,.1);border-color:var(--sky);}
    .point-summary-card .ps-icon{width:40px;height:40px;border-radius:12px;
      display:flex;align-items:center;justify-content:center;font-size:18px;margin-bottom:4px;}
    .ps-icon.earn{background:var(--green-light);color:var(--green);}
    .ps-icon.use{background:var(--red-light);color:var(--red);}
    .ps-icon.expire{background:#FFFBEB;color:#F6AD55;}
    .ps-label{font-size:12px;color:var(--muted);font-weight:600;}
    .ps-value{font-size:22px;font-weight:900;color:var(--text);}
    .ps-value small{font-size:13px;font-weight:700;color:var(--muted);}

    /* ── 필터 탭 & 검색 ── */
    .point-filter-row{display:flex;align-items:center;justify-content:space-between;gap:12px;flex-wrap:wrap;}
    .tab-group{display:flex;gap:8px;}
    .tab-btn{background:#fff;border:1px solid var(--border);color:var(--dark);
      padding:8px 18px;border-radius:20px;font-size:13px;font-weight:700;
      cursor:pointer;transition:.2s;font-family:inherit;}
    .tab-btn:hover{border-color:var(--sky);color:var(--sky);}
    .tab-btn.active{background:var(--grad);color:#fff;border-color:transparent;
      box-shadow:0 4px 12px rgba(137,207,240,.3);}
    .point-search-box{display:flex;align-items:center;gap:8px;background:#fff;
      border:1px solid var(--border);border-radius:20px;padding:8px 16px;transition:.2s;}
    .point-search-box:focus-within{border-color:var(--sky);box-shadow:0 0 0 3px rgba(137,207,240,.15);}
    .point-search-box input{border:none;outline:none;font-size:13px;font-family:inherit;
      color:var(--text);background:transparent;width:160px;}
    .point-search-box i{color:var(--muted);font-size:14px;}

    /* ── 포인트 내역 리스트 ── */
    .point-list{display:flex;flex-direction:column;gap:10px;}
    .point-item{
      display:flex;align-items:center;gap:16px;
      padding:16px 20px;border-radius:16px;
      background:#fff;border:1px solid var(--border);
      transition:.2s;cursor:default;}
    .point-item:hover{border-color:rgba(137,207,240,.4);background:#FAFCFF;
      box-shadow:0 4px 16px rgba(137,207,240,.08);}
    .point-item-icon{width:44px;height:44px;border-radius:12px;flex-shrink:0;
      display:flex;align-items:center;justify-content:center;font-size:20px;}
    .pi-icon-earn{background:var(--green-light);color:var(--green);}
    .pi-icon-use{background:var(--red-light);color:var(--red);}
    .pi-icon-expire{background:#FFFBEB;color:#F6AD55;}
    .point-item-info{flex:1;min-width:0;}
    .pi-title{font-size:14px;font-weight:800;color:var(--text);
      white-space:nowrap;overflow:hidden;text-overflow:ellipsis;}
    .pi-date{font-size:12px;color:var(--muted);font-weight:500;margin-top:3px;}
    .point-item-amount{font-size:16px;font-weight:900;flex-shrink:0;text-align:right;}
    .amount-earn{color:var(--green);}
    .amount-use{color:var(--red);}
    .amount-expire{color:#F6AD55;}
    .pi-badge{font-size:10px;font-weight:700;padding:3px 8px;border-radius:20px;flex-shrink:0;}
    .badge-earn{background:var(--green-light);color:var(--green);}
    .badge-use{background:var(--red-light);color:var(--red);}
    .badge-expire{background:#FFFBEB;color:#F6AD55;}

    /* ── 페이지네이션 ── */
    .pagination{display:flex;justify-content:center;align-items:center;gap:6px;margin-top:8px;}
    .page-btn{width:36px;height:36px;border-radius:10px;border:1px solid var(--border);
      background:#fff;color:var(--dark);font-size:13px;font-weight:700;cursor:pointer;
      display:flex;align-items:center;justify-content:center;transition:.2s;font-family:inherit;}
    .page-btn:hover{border-color:var(--sky);color:var(--sky);}
    .page-btn.active{background:var(--grad);color:#fff;border-color:transparent;
      box-shadow:0 4px 12px rgba(137,207,240,.3);}
    .page-btn:disabled{opacity:.4;cursor:default;}

    /* ── 빈 상태 ── */
    .empty-state{text-align:center;padding:48px 20px;color:var(--muted);}
    .empty-state i{font-size:36px;display:block;margin-bottom:12px;opacity:.2;color:var(--sky);}
    .empty-state p{font-size:14px;font-weight:600;margin:0;}

    /* ── 반응형 ── */
    @media(max-width:1024px){
      .mypage-container{grid-template-columns:1fr;}
      .sidebar{position:relative;top:0;}
      .point-summary-grid{grid-template-columns:repeat(3,1fr);}
    }
    @media(max-width:600px){
      .point-summary-grid{grid-template-columns:1fr;}
      .point-filter-row{flex-direction:column;align-items:flex-start;}
    }
  </style>
</head>
<body>

<jsp:include page="/WEB-INF/views/layout/header.jsp"/>

<main class="mypage-container">
  <jsp:include page="/WEB-INF/views/layout/mypage_sidebar.jsp">
    <jsp:param name="activeMenu" value="point"/>
  </jsp:include>

  <div class="dashboard-content">

    <h2 class="welcome-title"><span>포인트</span> 내역</h2>

    <!-- 보유 포인트 배너 -->
    <div class="point-banner">
      <div class="point-banner-left">
        <div class="point-banner-label">💰 현재 보유 포인트</div>
        <div class="point-banner-value">
          <span id="total-point">-</span><small>P</small>
        </div>
        <div class="point-banner-sub">
          <i class="bi bi-calendar3"></i>
          <span>이번 달 적립 <strong id="banner-month-earn">-</strong> P · 사용 <strong id="banner-month-use">-</strong> P</span>
        </div>
      </div>
      <i class="bi bi-coin point-banner-icon"></i>
    </div>

    <!-- 이번 달 요약 -->
    <div>
      <div class="section-head">
        <div>
          <h3 class="section-title"><i class="bi bi-bar-chart-line"></i> 이번 달 포인트 요약</h3>
          <p class="section-subtitle">이번 달 포인트 적립 및 사용 현황</p>
        </div>
      </div>
      <div class="point-summary-grid" style="grid-template-columns:repeat(2,1fr);">
        <div class="point-summary-card">
          <div class="ps-icon earn"><i class="bi bi-plus-circle-fill"></i></div>
          <div class="ps-label">이번 달 적립</div>
          <div class="ps-value"><span id="month-earn">-</span><small> P</small></div>
        </div>
        <div class="point-summary-card">
          <div class="ps-icon use"><i class="bi bi-dash-circle-fill"></i></div>
          <div class="ps-label">이번 달 사용</div>
          <div class="ps-value"><span id="month-use">-</span><small> P</small></div>
        </div>
      </div>
    </div>

    <!-- 포인트 내역 목록 -->
    <div>
      <div class="section-head">
        <div>
          <h3 class="section-title"><i class="bi bi-list-ul"></i> 포인트 내역</h3>
          <p class="section-subtitle">전체 포인트 적립·사용·소멸 이력</p>
        </div>
      </div>

      <!-- 필터 탭 + 검색 -->
      <div class="point-filter-row" style="margin-bottom:16px;">
        <div class="tab-group">
          <button class="tab-btn active" data-filter="all" onclick="filterPoints('all', this)">전체</button>
          <button class="tab-btn" data-filter="earn" onclick="filterPoints('earn', this)">적립</button>
          <button class="tab-btn" data-filter="use" onclick="filterPoints('use', this)">사용</button>
          <button class="tab-btn" data-filter="expire" onclick="filterPoints('expire', this)">소멸</button>
        </div>
        <div class="point-search-box">
          <i class="bi bi-search"></i>
          <input type="text" id="point-search" placeholder="내역 검색..." oninput="searchPoints()">
        </div>
      </div>

      <div class="clean-card" style="padding:20px;">
        <div class="point-list" id="point-list-area">
          <!-- 스켈레톤 로딩 -->
          <div class="skeleton" style="height:74px;border-radius:16px;"></div>
          <div class="skeleton" style="height:74px;border-radius:16px;"></div>
          <div class="skeleton" style="height:74px;border-radius:16px;"></div>
          <div class="skeleton" style="height:74px;border-radius:16px;"></div>
          <div class="skeleton" style="height:74px;border-radius:16px;"></div>
        </div>

        <!-- 페이지네이션 -->
        <div class="pagination" id="pagination-area" style="margin-top:20px;display:none;"></div>
      </div>
    </div>

  </div>
</main>

<!-- 팔로우 모달 -->
<div class="modal-overlay" id="followModal" onclick="if(event.target.id==='followModal')closeModal('followModal')">
  <div class="custom-modal">
    <div class="modal-header">
      <h3 id="follow-modal-title">팔로워</h3>
      <button class="btn-close" onclick="closeModal('followModal')">✕</button>
    </div>
    <div id="follow-modal-body"><div style="text-align:center;padding:30px;color:var(--muted);">불러오는 중...</div></div>
  </div>
</div>

<jsp:include page="/WEB-INF/views/layout/footer.jsp"/>

<script>
const ctxPath = '${pageContext.request.contextPath}';
</script>
<script src="${pageContext.request.contextPath}/dist/js/mypage/point.js"></script>
</body>
</html>
