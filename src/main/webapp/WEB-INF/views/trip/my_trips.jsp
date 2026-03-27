<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"   uri="jakarta.tags.core" %>
<%@ taglib prefix="fn"  uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>나의 여행 - Tripan</title>
  <jsp:include page="/WEB-INF/views/layout/headerResources.jsp"/>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/dist/css/trip/trip.css">
  <link rel="preconnect" href="https://cdn.jsdelivr.net">
  <link href="https://cdn.jsdelivr.net/gh/orioncactus/pretendard/dist/web/variable/pretendardvariable.css" rel="stylesheet">
  <style>
    /* ─── 변수 ─── */
    :root {
      --blue:   #89CFF0;
      --pink:   #FFB6C1;
      --purple: #C2B8D9;
      --dark:   #1A202C;
      --mid:    #4A5568;
      --light:  #A0AEC0;
      --bg:     #F8FAFC;
      --white:  #FFFFFF;
      --border: #E2E8F0;
      --grad:   linear-gradient(135deg, #89CFF0, #FFB6C1);
      --shadow: 0 8px 30px rgba(0,0,0,.04);
      --glass-bg: rgba(255, 255, 255, 0.75);
      --glass-border: rgba(255, 255, 255, 0.6);
    }
    *, *::before, *::after {
      box-sizing: border-box; margin: 0; padding: 0;
      font-family: 'Pretendard Variable', 'Pretendard', -apple-system, sans-serif;
    }
    
    /* 💡 스크롤 설정 및 배경 그라데이션 */
    html, body {
      overflow: auto !important;
      height: auto !important;
      background: linear-gradient(180deg, #F4F9FA 0%, #FDF6F7 100%);
      min-height: 100vh;
      position: relative;
    }

    /* 💡 [감성 한 스푼] 배경 블러 도형 (움직임 추가) */
    .bg-blob {
      position: fixed;
      border-radius: 50%;
      filter: blur(80px);
      z-index: -1;
      opacity: 0.6;
      pointer-events: none;
      animation: floatBlob 10s infinite alternate ease-in-out;
    }
    .blob-1 { top: -10%; left: -10%; width: 500px; height: 500px; background: var(--blue); }
    .blob-2 { bottom: -10%; right: -5%; width: 600px; height: 600px; background: var(--pink); animation-delay: -3s; }
    .blob-3 { top: 40%; left: 60%; width: 400px; height: 400px; background: var(--purple); animation-delay: -6s; opacity: 0.4; }

    @keyframes floatBlob {
      0% { transform: translate(0, 0) scale(1); }
      100% { transform: translate(30px, 50px) scale(1.1); }
    }

    /* ─── 페이지 헤더 ─── */
    .mt-page {
      max-width: 1100px;
      margin: 0 auto;
      padding: 110px 24px 80px; 
      position: relative;
      z-index: 1;
    }
    .mt-header {
      display: flex;
      align-items: flex-end;
      justify-content: space-between;
      margin-bottom: 36px;
      gap: 16px;
      flex-wrap: wrap;
    }
    .mt-title {
      font-size: 32px; /* 폰트 살짝 키움 */
      font-weight: 900;
      color: var(--dark);
      letter-spacing: -0.5px;
      margin-top: 36px;
      text-shadow: 0 2px 10px rgba(0,0,0,0.02);
    }
    .mt-title span {
      background: var(--grad);
      -webkit-background-clip: text;
      -webkit-text-fill-color: transparent;
    }
    .mt-subtitle {
      font-size: 15px;
      color: var(--mid);
      margin-top: 8px;
      font-weight: 600;
    }

    /* ─── 통계 칩 (글래스모피즘) ─── */
    .mt-stats {
      display: flex;
      gap: 10px;
      flex-wrap: wrap;
    }
    .mt-stat-chip {
      display: inline-flex;
      align-items: center;
      gap: 6px;
      padding: 7px 16px;
      border-radius: 50px;
      font-size: 13px;
      font-weight: 800;
      background: var(--glass-bg);
      backdrop-filter: blur(10px);
      border: 1px solid var(--white);
      box-shadow: 0 4px 15px rgba(0,0,0,0.03);
    }
    .mt-stat-chip.ongoing  { color: #276749; }
    .mt-stat-chip.planning { color: #2B6CB0; }
    .mt-stat-chip.done     { color: var(--mid); }

    /* ─── 새 여행 버튼 ─── */
    .btn-new-trip {
      display: inline-flex;
      align-items: center;
      gap: 8px;
      padding: 12px 24px;
      background: var(--grad);
      color: white;
      border: none;
      border-radius: 50px;
      font-size: 14px;
      font-weight: 800;
      cursor: pointer;
      text-decoration: none;
      box-shadow: 0 6px 20px rgba(137,207,240,.4);
      transition: all .25s ease;
      white-space: nowrap;
    }
    .btn-new-trip:hover { transform: translateY(-3px); box-shadow: 0 10px 25px rgba(137,207,240,.6); }

    /* ─── 필터 탭 ─── */
    .mt-filter {
      display: flex;
      gap: 8px;
      margin-bottom: 28px;
      flex-wrap: wrap;
    }
    .mt-filter-btn {
      padding: 8px 20px;
      border-radius: 50px;
      border: 1.5px solid var(--white);
      background: var(--glass-bg);
      backdrop-filter: blur(8px);
      font-size: 13px;
      font-weight: 800;
      color: var(--mid);
      cursor: pointer;
      transition: all .2s;
      box-shadow: 0 4px 12px rgba(0,0,0,.02);
    }
    .mt-filter-btn.active,
    .mt-filter-btn:hover {
      background: var(--grad);
      color: white;
      border-color: transparent;
      box-shadow: 0 6px 15px rgba(137,207,240,.3);
    }

    /* ─── 빈 상태 (감성 업그레이드) ─── */
    .mt-empty {
      text-align: center;
      padding: 80px 24px;
      display: none;
      background: var(--glass-bg);
      backdrop-filter: blur(12px);
      border-radius: 24px;
      border: 1px solid var(--white);
      box-shadow: var(--shadow);
    }
    .mt-empty.show { display: block; }
    .mt-empty-icon { font-size: 64px; margin-bottom: 20px; animation: floatBlob 3s infinite alternate ease-in-out; }
    .mt-empty-title { font-size: 20px; font-weight: 900; color: var(--dark); margin-bottom: 10px; }
    .mt-empty-sub { font-size: 15px; color: var(--mid); margin-bottom: 28px; font-weight: 500; }

    /* ─── 카드 그리드 ─── */
    .mt-grid {
      display: grid;
      grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
      gap: 24px; /* 간격 살짝 넓힘 */
    }

    /* ─── 여행 카드 (글래스모피즘 적용) ─── */
    .trip-card {
      background: rgba(255, 255, 255, 0.8);
      backdrop-filter: blur(12px);
      border-radius: 24px;
      border: 1px solid var(--white);
      overflow: hidden;
      box-shadow: var(--shadow);
      cursor: pointer;
      transition: transform .3s ease, box-shadow .3s ease, border-color .3s ease;
      text-decoration: none;
      display: flex;
      flex-direction: column;
    }
    .trip-card:hover {
      transform: translateY(-8px);
      box-shadow: 0 20px 40px rgba(137,207,240,.15);
      border-color: rgba(137,207,240,.5);
    }

    /* 카드 상단 썸네일 영역 */
    .trip-card__thumb {
      position: relative;
      height: 180px; /* 썸네일 살짝 키움 */
      overflow: hidden;
      background: linear-gradient(135deg, #EDF2F7, #E2E8F0);
    }
    .trip-card__thumb img {
      width: 100%; height: 100%;
      object-fit: cover;
      transition: transform .5s ease;
    }
    .trip-card:hover .trip-card__thumb img { transform: scale(1.08); }

    /* 썸네일 없을 때 기본 배경 */
    .trip-card__thumb-default {
      width: 100%; height: 100%;
      display: flex;
      align-items: center;
      justify-content: center;
      font-size: 52px;
      background: linear-gradient(135deg, rgba(137,207,240,.2), rgba(255,182,193,.2));
    }

    /* 상태 배지 */
    .trip-card__status-badge { display: none; }
    .trip-card__status {
      position: absolute;
      top: 14px;
      left: 14px;
      padding: 5px 12px;
      border-radius: 50px;
      font-size: 11px;
      font-weight: 900;
      backdrop-filter: blur(8px);
      box-shadow: 0 4px 10px rgba(0,0,0,0.1);
    }
    .trip-card__status.ongoing  { background: rgba(72,187,120,.95);  color: white; }
    .trip-card__status.planning { background: rgba(255,255,255,.95); color: #2B6CB0; border: 1px solid rgba(137,207,240,.6); }
    .trip-card__status.done     { background: rgba(113,128,150,.95); color: white; }

    /* 내 역할 배지 */
    .trip-card__role {
      position: absolute;
      top: 14px;
      right: 14px;
      padding: 4px 10px;
      border-radius: 50px;
      font-size: 11px;
      font-weight: 800;
      background: rgba(0,0,0,.5);
      backdrop-filter: blur(4px);
      color: white;
    }

    /* ─── 카드 삭제 버튼 (방장 전용) ─── */
    .trip-card__delete-btn {
      position: absolute;
      bottom: 14px;
      right: 14px;
      width: 32px;
      height: 32px;
      border-radius: 50%;
      background: rgba(255, 90, 90, 0.85);
      backdrop-filter: blur(6px);
      border: 1.5px solid rgba(255,255,255,0.5);
      color: white;
      font-size: 14px;
      cursor: pointer;
      display: flex;
      align-items: center;
      justify-content: center;
      box-shadow: 0 2px 10px rgba(255,90,90,0.4);
      transition: all .2s ease;
      z-index: 2;
      opacity: 0;
      transform: scale(0.8);
    }
    .trip-card:hover .trip-card__delete-btn {
      opacity: 1;
      transform: scale(1);
    }
    .trip-card__delete-btn:hover {
      background: rgba(220, 38, 38, 0.95) !important;
      box-shadow: 0 4px 15px rgba(220,38,38,0.5) !important;
      transform: scale(1.12) !important;
    }

    /* 카드 본문 */
    .trip-card__body {
      padding: 20px 24px 16px;
      flex: 1;
      display: flex;
      flex-direction: column;
      gap: 12px;
    }
    .trip-card__name {
      font-size: 19px;
      font-weight: 900;
      color: var(--dark);
      letter-spacing: -0.3px;
      overflow: hidden;
      white-space: nowrap;
      text-overflow: ellipsis;
    }
    .trip-card__meta {
      display: flex;
      align-items: center;
      gap: 8px;
      flex-wrap: wrap;
    }
    .trip-card__date {
      font-size: 13px;
      font-weight: 700;
      color: var(--mid);
      display: flex;
      align-items: center;
      gap: 6px;
    }
    .trip-card__city {
      display: inline-flex;
      align-items: center;
      font-size: 12px;
      font-weight: 800;
      color: #2B6CB0;
      background: rgba(137,207,240,.15);
      padding: 4px 12px;
      border-radius: 8px;
      letter-spacing: 0.3px;
      border: 1px solid rgba(137,207,240,.3);
    }
    .trip-card__cities {
      display: flex;
      flex-wrap: wrap;
      gap: 6px;
    }

    /* 카드 하단 */
    .trip-card__footer {
      display: flex;
      align-items: center;
      justify-content: space-between;
      padding: 14px 24px;
      border-top: 1px solid rgba(226,232,240, 0.6);
      background: rgba(250, 251, 255, 0.4);
    }
    .trip-card__type {
      font-size: 13px;
      font-weight: 700;
      color: var(--mid);
    }
    .trip-card__members {
      display: flex;
      align-items: center;
      gap: 6px;
      font-size: 13px;
      color: var(--mid);
      font-weight: 700;
    }
    .member-count-icon {
      width: 24px; height: 24px;
      border-radius: 50%;
      background: var(--grad);
      display: inline-flex;
      align-items: center;
      justify-content: center;
      font-size: 11px;
      color: white;
      font-weight: 800;
      box-shadow: 0 2px 6px rgba(137,207,240,.4);
    }

    /* ─── 반응형 ─── */
    @media (max-width: 600px) {
      .mt-page { padding: 95px 16px 60px; }
      .mt-title { font-size: 24px; }
      .mt-grid { grid-template-columns: 1fr; }
      .mt-header { flex-direction: column; align-items: flex-start; }
      .bg-blob { opacity: 0.4; } /* 모바일에서는 배경 좀 더 연하게 */
    }
  </style>
</head>
<body>

<%-- 💡 [디자인 요소] 둥둥 떠다니는 파스텔 배경 도형 --%>
<div class="bg-blob blob-1"></div>
<div class="bg-blob blob-2"></div>
<div class="bg-blob blob-3"></div>

<header>
  <jsp:include page="/WEB-INF/views/layout/header.jsp"/>
</header>

<div class="mt-page">

  <%-- ── 페이지 헤더 ── --%>
  <div class="mt-header">
    <div>
      <div class="mt-title">✈️ <span>나의 여행</span></div>
      <div class="mt-subtitle">내가 계획하고 참여 중인 모든 여행을 한눈에</div>

      <%-- 통계 칩 --%>
      <div class="mt-stats" style="margin-top:16px;">
        <c:if test="${ongoingCount > 0}">
          <span class="mt-stat-chip ongoing">🟢 진행중 ${ongoingCount}</span>
        </c:if>
        <c:if test="${planningCount > 0}">
          <span class="mt-stat-chip planning">📋 계획중 ${planningCount}</span>
        </c:if>
        <c:if test="${completedCount > 0}">
          <span class="mt-stat-chip done">✅ 완료 ${completedCount}</span>
        </c:if>
      </div>
    </div>

    <a href="${pageContext.request.contextPath}/trip/trip_create" class="btn-new-trip">
      + 새 여행 만들기
    </a>
  </div>

  <%-- ── 필터 탭 ── --%>
  <div class="mt-filter">
    <button class="mt-filter-btn active" onclick="filterTrips('ALL', this)">전체 <c:out value="${fn:length(trips)}"/></button>
    <button class="mt-filter-btn" onclick="filterTrips('ONGOING', this)">진행중</button>
    <button class="mt-filter-btn" onclick="filterTrips('PLANNING', this)">계획중</button>
    <button class="mt-filter-btn" onclick="filterTrips('COMPLETED', this)">완료된 여행</button>
  </div>

  <%-- ── 빈 상태 ── --%>
  <div id="emptyState" class="mt-empty <c:if test='${empty trips}'>show</c:if>">
    <div class="mt-empty-icon">🗺️</div>
    <div class="mt-empty-title">아직 여행이 없어요</div>
    <div class="mt-empty-sub">새 여행을 만들거나 초대 링크로 참여해 보세요!</div>
    <a href="${pageContext.request.contextPath}/trip/trip_create" class="btn-new-trip">
      + 첫 여행 만들기
    </a>
  </div>

  <%-- ── 여행 카드 그리드 ── --%>
  <div class="mt-grid" id="tripGrid">
    <c:forEach var="trip" items="${trips}">
      <a class="trip-card" href="${pageContext.request.contextPath}/trip/${trip.tripId}/workspace"
         data-status="${trip.status}">

        <%-- 썸네일 --%>
        <div class="trip-card__thumb">
          <c:choose>
            <c:when test="${not empty trip.thumbnailUrl}">
              <img src="${pageContext.request.contextPath}${trip.thumbnailUrl}"
                   alt="${trip.tripName}"
                   onerror="this.src='${pageContext.request.contextPath}/dist/images/logo.png';this.style.objectFit='contain';this.style.padding='20px';">
            </c:when>
            <c:otherwise>
              <img src="${pageContext.request.contextPath}/dist/images/logo.png"
                   alt="기본 이미지"
                   style="object-fit:contain;padding:30px;">
            </c:otherwise>
          </c:choose>

          <%-- 상태 배지: SQL에서 날짜 계산 후 status 확정 --%>
          <c:choose>
            <c:when test="${trip.status == 'ONGOING'}">
              <span class="trip-card__status ongoing">✈️ 진행중</span>
            </c:when>
            <c:when test="${trip.status == 'COMPLETED'}">
              <span class="trip-card__status done">✅ 완료</span>
            </c:when>
            <c:otherwise>
              <span class="trip-card__status planning">📋 계획중</span>
            </c:otherwise>
          </c:choose>

          <%-- 내 역할 배지 --%>
          <c:if test="${not empty trip.leaderNickname}">
            <span class="trip-card__role">
              <c:choose>
                <c:when test="${trip.leaderNickname == 'OWNER'}">👑 방장</c:when>
                <c:otherwise>🧳 동행자</c:otherwise>
              </c:choose>
            </span>
          </c:if>

          <%-- 삭제 버튼 — 방장 전용, 호버 시 노출 --%>
          <c:if test="${trip.leaderNickname == 'OWNER'}">
            <button class="trip-card__delete-btn"
                    title="여행 삭제"
                    onclick="deleteMyTrip(${trip.tripId}, '${fn:escapeXml(trip.tripName)}', event)">
              🗑
            </button>
          </c:if>
        </div>

        <%-- 본문 --%>
        <div class="trip-card__body">
          <div class="trip-card__name">${fn:escapeXml(trip.tripName)}</div>

          <div class="trip-card__meta">
            <span class="trip-card__date">
              📅 ${trip.startDate} → ${trip.endDate}
            </span>
          </div>

          <%-- 도시 칩 --%>
          <c:if test="${not empty trip.cities}">
            <div class="trip-card__cities">
              <c:forEach var="city" items="${trip.cities}">
                <span class="trip-card__city">${fn:escapeXml(city)}</span>
              </c:forEach>
            </div>
          </c:if>
        </div>

        <%-- 푸터 --%>
        <div class="trip-card__footer">
          <span class="trip-card__type">
            <c:choose>
              <c:when test="${trip.tripType == 'COUPLE'}">💑 커플</c:when>
              <c:when test="${trip.tripType == 'FAMILY'}">👨‍👩‍👧 가족</c:when>
              <c:when test="${trip.tripType == 'FRIENDS'}">👫 친구</c:when>
              <c:when test="${trip.tripType == 'SOLO'}">🙋 혼자</c:when>
              <c:when test="${trip.tripType == 'BUSINESS'}">💼 비즈니스</c:when>
              <c:otherwise>✈️ 여행</c:otherwise>
            </c:choose>
          </span>

          <c:if test="${not empty trip.regionId}">
            <span class="trip-card__members">
              <span class="member-count-icon">👤</span>
              ${trip.regionId}명
            </span>
          </c:if>
        </div>

      </a>
    </c:forEach>
  </div><%-- /mt-grid --%>

</div><%-- /mt-page --%>

<script>
  /* ─── 여행 삭제 (방장 전용, my_trips 카드) ─── */
  function deleteMyTrip(tripId, tripName, event) {
    // 카드 링크 클릭 차단
    event.preventDefault();
    event.stopPropagation();

    var confirmed = confirm(
      '⚠️ 여행을 삭제하면 되돌릴 수 없습니다!\n\n' +
      '삭제 대상: ' + tripName + '\n\n' +
      '• 등록된 모든 일정 (장소·메모·사진)\n' +
      '• 체크리스트, 투표, 예산 내역\n' +
      '• 동행자 정보 및 초대 기록\n\n' +
      '위 데이터가 모두 삭제됩니다. 계속하시겠습니까?'
    );
    if (!confirmed) return;

    var ctx = '${pageContext.request.contextPath}';
    fetch(ctx + '/trip/' + tripId, {
      method: 'DELETE',
      headers: { 'Content-Type': 'application/json' }
    })
    .then(function(r) { return r.json(); })
    .then(function(d) {
      if (d.success) {
        alert('여행이 삭제되었습니다.');
        location.reload();
      } else {
        alert('삭제 실패: ' + (d.message || '오류가 발생했습니다.'));
      }
    })
    .catch(function() {
      alert('네트워크 오류가 발생했습니다. 다시 시도해 주세요.');
    });
  }
</script>

<script>
  /* 기능 유지: SQL에서 status 이미 계산됨 → 단순 필터만 처리 */
  function filterTrips(status, btn) {
    document.querySelectorAll('.mt-filter-btn').forEach(b => b.classList.remove('active'));
    btn.classList.add('active');
    const cards = document.querySelectorAll('.trip-card');
    let visible = 0;
    cards.forEach(function(card) {
      const show = status === 'ALL' || card.dataset.status === status;
      card.style.display = show ? '' : 'none';
      if (show) visible++;
    });
    document.getElementById('emptyState').classList.toggle('show', visible === 0);
  }
</script>
<footer>
  <jsp:include page="/WEB-INF/views/layout/footer.jsp"/>
</footer>
<script>
/* ★ 강퇴 알림 인라인 처리 (외부 파일 로드 불필요 — NoResourceFoundException 방지) */
(function () {
  var params = new URLSearchParams(window.location.search);
  if (params.get('kicked') === 'true') {
    // ① URL 정리 (뒤로가기 시 재표시 방지)
    if (history.replaceState) history.replaceState(null, '', window.location.pathname);
    // ② DOM 준비 후 alert
    function showKicked() {
      alert('🚨 방장에 의해 여행에서 강퇴되었습니다.\n이 여행방에는 다시 입장하실 수 없습니다.');
    }
    if (document.readyState === 'loading') {
      document.addEventListener('DOMContentLoaded', showKicked);
    } else {
      setTimeout(showKicked, 150);
    }
  }
})();
</script>

</body>
</html>