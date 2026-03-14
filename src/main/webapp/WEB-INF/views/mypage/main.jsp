<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
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
      --sky:#89CFF0; --sky-light:#E6F4FF; --pink:#FFB6C1;
      --grad:linear-gradient(135deg,var(--sky),var(--pink));
      --bg:#F0F8FF; --white:#fff;
      --text:#2D3748; --dark:#4A5568; --muted:#718096;
      --border:#E2E8F0; --radius:20px;
      --bounce:cubic-bezier(0.34,1.56,0.64,1);
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

    /* ── 요약 그리드 ── */
    .summary-grid{display:grid;grid-template-columns:repeat(4,1fr);gap:12px;}
    .summary-card{background:#fff;border-radius:16px;padding:20px 14px;
      box-shadow:0 4px 16px rgba(0,0,0,.02);border:1px solid var(--border);
      display:flex;flex-direction:column;align-items:center;justify-content:center;
      transition:transform .3s var(--bounce);}
    .summary-card:hover{transform:translateY(-4px);box-shadow:0 8px 24px rgba(137,207,240,.1);border-color:var(--sky);}
    .summary-card i{font-size:22px;color:var(--sky);margin-bottom:10px;}
    .summary-value{font-size:26px;font-weight:900;color:var(--text);margin-bottom:5px;line-height:1;}
    .summary-label{font-size:12px;color:var(--muted);font-weight:600;}

    /* ── 다가오는 일정 배너 ── */
    .upcoming-banner{background:var(--grad);border-radius:20px;padding:22px 28px;
      display:flex;align-items:center;gap:20px;color:#fff;
      box-shadow:0 12px 28px rgba(137,207,240,.35);cursor:pointer;
      transition:transform .3s var(--bounce);}
    .upcoming-banner:hover{transform:translateY(-3px);}
    .upcoming-banner>i{font-size:34px;flex-shrink:0;}
    .up-lbl{font-size:11px;font-weight:700;opacity:.85;margin-bottom:4px;}
    .up-name{font-size:18px;font-weight:900;margin-bottom:4px;}
    .up-date{font-size:12px;opacity:.85;display:flex;align-items:center;gap:5px;}
    .up-dday{font-size:34px;font-weight:900;flex-shrink:0;letter-spacing:-1px; margin-left: auto;}
    .upcoming-none{background:#fff;border-radius:20px;padding:22px 28px;
      display:flex;align-items:center;gap:20px;border:1px solid var(--border);}
    .upcoming-none-icon{width:50px;height:50px;border-radius:14px;background:var(--sky-light);
      flex-shrink:0;display:flex;align-items:center;justify-content:center;color:var(--sky);font-size:22px;}
    .upcoming-none-text h4{font-size:13px;font-weight:700;color:var(--muted);margin:0 0 5px;}
    .upcoming-none-text p{font-size:17px;font-weight:800;color:var(--text);margin:0;}

    /* ── 숙소 카드 ── */
    .accom-grid{display:grid;grid-template-columns:repeat(3,1fr);gap:14px;}
    .accom-card{border-radius:14px;overflow:hidden;border:1px solid var(--border);
      background:#fff;transition:transform .25s var(--bounce),box-shadow .25s;cursor:pointer;}
    .accom-card:hover{transform:translateY(-4px);box-shadow:0 10px 28px rgba(137,207,240,.18);}
    .accom-thumb{width:100%;height:110px;object-fit:cover;background:linear-gradient(135deg,#E6F4FF,#FFE4E8);
      display:flex;align-items:center;justify-content:center;color:var(--sky);font-size:28px;}
    .accom-thumb img{width:100%;height:100%;object-fit:cover;}
    .accom-info{padding:10px 12px 12px;}
    .accom-name{font-size:13px;font-weight:800;color:var(--text);margin-bottom:3px;
      white-space:nowrap;overflow:hidden;text-overflow:ellipsis;}
    .accom-loc{font-size:11px;color:var(--muted);font-weight:600;display:flex;align-items:center;gap:4px;}
    .accom-price{font-size:13px;font-weight:900;color:var(--sky);margin-top:6px;}
    .accom-price span{font-size:11px;font-weight:600;color:var(--muted);}

    /* ── 관심 목록 ── */
    .wish-list{display:flex;flex-direction:column;gap:10px;}
    .wish-item{display:flex;align-items:center;gap:14px;padding:12px 14px;
      border-radius:14px;border:1px solid var(--border);background:#fff;
      transition:.2s;cursor:pointer;}
    .wish-item:hover{border-color:var(--sky);background:var(--sky-light);}
    .wish-thumb{width:52px;height:52px;border-radius:10px;object-fit:cover;flex-shrink:0;
      background:linear-gradient(135deg,#E6F4FF,#FFE4E8);
      display:flex;align-items:center;justify-content:center;color:var(--sky);font-size:20px;}
    .wish-thumb img{width:100%;height:100%;object-fit:cover;border-radius:10px;}
    .wish-info{flex:1;min-width:0;}
    .wish-name{font-size:13px;font-weight:800;color:var(--text);white-space:nowrap;overflow:hidden;text-overflow:ellipsis;}
    .wish-meta{font-size:11px;color:var(--muted);font-weight:600;margin-top:2px;}
    .wish-price{font-size:13px;font-weight:900;color:var(--sky);flex-shrink:0;}
    .btn-heart{background:none;border:none;font-size:18px;color:#FC8181;cursor:pointer;flex-shrink:0;padding:0;}

    /* ── 빈 상태 ── */
    .empty-state{text-align:center;padding:32px 20px;color:var(--muted);}
    .empty-state i{font-size:30px;display:block;margin-bottom:8px;opacity:.2;color:var(--sky);}
    .empty-state p{font-size:13px;font-weight:600;margin:0;}

    /* ── 섹션 더보기 링크 ── */
    .section-more{font-size:13px;font-weight:700;color:var(--sky);text-decoration:none;
      background:var(--sky-light);padding:6px 14px;border-radius:20px;transition:.2s;}
    .section-more:hover{background:var(--sky);color:#fff;}
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
    .user-item{display:flex;align-items:center;gap:12px;padding:12px 14px;
      border-radius:14px;background:#F8FAFC;border:1px solid var(--border);transition:.2s;margin-bottom:8px;}
    .user-item:hover{background:#EFF6FF;border-color:rgba(137,207,240,.3);}
    .user-pic{width:42px;height:42px;border-radius:50%;flex-shrink:0;background:var(--grad);overflow:hidden;
      display:flex;align-items:center;justify-content:center;color:#fff;font-weight:800;font-size:14px;}
    .user-pic img{width:100%;height:100%;object-fit:cover;}

    @media(max-width:1024px){.mypage-container{grid-template-columns:1fr;}.sidebar{position:relative;top:0;}.summary-grid{grid-template-columns:repeat(2,1fr);}}
    @media(max-width:600px){.accom-grid{grid-template-columns:repeat(2,1fr);}}
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

    <!-- 여행 요약 -->
    <div>
      <div class="section-head">
        <div>
          <h3 class="section-title"><i class="bi bi-bar-chart-line"></i> 여행 요약</h3>
          <p class="section-subtitle">지금까지의 나의 여행 발자취</p>
        </div>
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

    <!-- 다가오는 일정 -->
    <div>
      <div class="section-head">
        <h3 class="section-title"><i class="bi bi-calendar-heart"></i> 다가오는 일정</h3>
        <a href="${pageContext.request.contextPath}/mypage/schedule" class="section-more">전체 보기</a>
      </div>
      <p class="section-subtitle">설레는 다음 여행까지 얼마나 남았을까요?</p>
      <div id="upcoming-area">
        <div class="skeleton" style="height:88px;border-radius:20px;"></div>
      </div>
    </div>

    <!-- 최근 본 숙소 -->
    <div>
      <div class="section-head">
        <h3 class="section-title"><i class="bi bi-eye"></i> 최근 본 숙소</h3>
       <a href="${pageContext.request.contextPath}/mypage/bookmark" 
   class="section-more" onclick="sessionStorage.setItem('bookmarkTab','recent')">더 보기</a>
      </div>
      <p class="section-subtitle">다시 확인하고 싶은 숙소</p>
      <div id="recent-accom-area">
        <div class="accom-grid">
          <div class="skeleton" style="height:160px;border-radius:14px;"></div>
          <div class="skeleton" style="height:160px;border-radius:14px;"></div>
          <div class="skeleton" style="height:160px;border-radius:14px;"></div>
        </div>
      </div>
    </div>

    <!-- 관심 목록 -->
    <div>
      <div class="section-head">
        <h3 class="section-title"><i class="bi bi-heart"></i> 나의 관심 목록</h3>
        <a href="${pageContext.request.contextPath}/mypage/bookmark" class="section-more">전체 보기</a>
      </div>
      <p class="section-subtitle">찜해둔 숙소를 빠르게 확인하세요</p>
      <div class="clean-card" style="padding:16px;">
        <div id="wish-list-area">
          <div class="skeleton" style="height:70px;border-radius:12px;margin-bottom:10px;"></div>
          <div class="skeleton" style="height:70px;border-radius:12px;margin-bottom:10px;"></div>
          <div class="skeleton" style="height:70px;border-radius:12px;"></div>
        </div>
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

<script src="${pageContext.request.contextPath}/dist/js/mypage/main.js"></script>
</body>
</html>
