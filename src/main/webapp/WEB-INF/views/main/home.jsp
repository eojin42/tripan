<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<jsp:include page="../layout/header.jsp" />

<link rel="stylesheet" href="${pageContext.request.contextPath}/dist/css/home.css">

<main>

  <%-- ══════════════════════════════════════════════
       HERO SECTION
  ══════════════════════════════════════════════ --%>
  <div class="hero">
    <div class="hero-img" id="heroBg">
      <img src="https://images.unsplash.com/photo-1507525428034-b723cf961d3e?q=80&w=2073&auto=format&fit=crop"
           alt="차분한 파스텔톤 해변">
    </div>
    <div class="hero-overlay">
      <p class="hero-eyebrow reveal active delay-100">여행 플래너 Tripan</p>
      <h2 class="hero-title reveal active delay-100">
        다음 여행을,<br>더 가볍고 선명하게
      </h2>
      <p class="hero-subtitle reveal active delay-200">
        일정은 같이, 정산은 쉽게 — 여행의 처음부터 끝까지 한 곳에서
      </p>
    </div>
  </div>

  <%-- ══════════════════════════════════════════════
       메인 여행 위젯
  ══════════════════════════════════════════════ --%>
  <section class="widget-section reveal">
    <div class="widget-container">

      <%-- ─────────────────────────────────────
           A. 비로그인 — 정사각형 + 구름 애니메이션
           [무료로 시작하기] → /start → 로그인 → 홈 리다이렉트
      ───────────────────────────────────── --%>
      <c:if test="${widgetType == 'GUEST'}">
        <div class="trip-widget guest-widget">
          <div class="widget-accent accent-brand"></div>

          <div class="widget-visual guest-visual">
            <img
              src="${pageContext.request.contextPath}/dist/images/logo.png"
              alt="Tripan 로고"
              class="guest-logo-img"
            >
          </div>

          <div class="widget-body">
            <p class="widget-eyebrow">Travel Planner</p>
            <h3 class="widget-title">함께 만드는 여행,<br>정리는 더 간단하게</h3>
            <p class="widget-desc">
              여행 일정을 같이 짜고, 지출을 자동으로 정산하세요.<br>
              복잡한 엑셀 없이 한 화면에서 모두 해결됩니다.
            </p>
            <div class="widget-actions">
              <%-- /start 엔드포인트: session에 redirectAfterLogin="/" 설정 후 로그인 페이지로 이동 --%>
              <a href="${pageContext.request.contextPath}/start" class="btn-widget-primary">
                무료로 시작하기 →
              </a>
            </div>
          </div>
        </div>
      </c:if>

      <%-- ─────────────────────────────────────
           B. 로그인 · 여행 없음
      ───────────────────────────────────── --%>
      <c:if test="${widgetType == 'EMPTY'}">
        <div class="trip-widget empty-widget">
          <div class="widget-accent accent-empty"></div>
          <div class="widget-body centered">
            <img src="${pageContext.request.contextPath}/dist/images/logo.png" alt="Tripan" class="empty-icon">
            <p class="widget-eyebrow">${loginNickname}님, 환영해요</p>
            <h3 class="widget-title">아직 만들어진 여행이 없네요</h3>
            <p class="widget-desc">첫 여행을 만들고 일정과 지출을 한 번에 관리해보세요</p>
            <div class="widget-actions centered">
              <a href="${pageContext.request.contextPath}/trip/trip_create" class="btn-widget-primary">
                ＋ 새 여행 만들기
              </a>
            </div>
          </div>
        </div>
      </c:if>

      <%-- ─────────────────────────────────────
           C. PLANNING (예정된 여행)
      ───────────────────────────────────── --%>
      <c:if test="${widgetType == 'PLANNING'}">
        <div class="trip-widget planning-widget">
          <div class="widget-accent accent-planning"></div>
          <div class="widget-thumb">
            <c:choose>
              <c:when test="${not empty representativeTrip.thumbnailUrl}">
                <img src="${representativeTrip.thumbnailUrl}" alt="${representativeTrip.tripName}">
              </c:when>
              <c:otherwise>
                <div class="thumb-placeholder planning-bg">🌅</div>
              </c:otherwise>
            </c:choose>
            <span class="widget-badge planning-badge">예정된 여행</span>
          </div>
          <div class="widget-body">
            <p class="widget-eyebrow">다가오는 여행</p>
            <h3 class="widget-title">${representativeTrip.tripName}</h3>
            <div class="widget-meta-row">
              <span class="meta-chip">
                <svg width="14" height="14" viewBox="0 0 16 16" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                  <path d="M8 1.5A4.5 4.5 0 0 1 12.5 6c0 3-4.5 8-4.5 8S3.5 9 3.5 6A4.5 4.5 0 0 1 8 1.5Z"/>
                  <circle cx="8" cy="6" r="1.5"/>
                </svg>
                ${representativeTrip.citiesStr}
              </span>
              <span class="meta-chip">
                <svg width="14" height="14" viewBox="0 0 16 16" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                  <rect x="1.5" y="2.5" width="13" height="12" rx="2"/>
                  <path d="M1.5 6.5h13M5 1v3M11 1v3"/>
                </svg>
                ${representativeTrip.startDate} ~ ${representativeTrip.endDate}
              </span>
            </div>
            <div class="dday-row">
              <c:choose>
                <c:when test="${dday == 0}">
                  <span class="dday-badge dday-today">D-Day!</span>
                  <span class="dday-label">오늘 드디어 출발이에요 🎉</span>
                </c:when>
                <c:when test="${dday <= 7}">
                  <span class="dday-badge dday-soon">D-${dday}</span>
                  <span class="dday-label">막바지 준비 중이시겠군요</span>
                </c:when>
                <c:otherwise>
                  <span class="dday-badge">D-${dday}</span>
                  <span class="dday-label">기대되는 여행이 기다리고 있어요</span>
                </c:otherwise>
              </c:choose>
            </div>
            <div class="widget-actions">
              <a href="${pageContext.request.contextPath}/trip/${representativeTrip.tripId}/workspace"
                 class="btn-widget-primary">여행으로 가기 →</a>
              <a href="${pageContext.request.contextPath}/trip/my_trips"
                 class="btn-widget-secondary">내 여행 전체보기</a>
            </div>
          </div>
        </div>
      </c:if>

      <%-- ─────────────────────────────────────
           D. ONGOING (진행 중)
      ───────────────────────────────────── --%>
      <c:if test="${widgetType == 'ONGOING'}">
        <div class="trip-widget ongoing-widget">
          <div class="widget-accent accent-ongoing"></div>
          <div class="widget-thumb">
            <c:choose>
              <c:when test="${not empty representativeTrip.thumbnailUrl}">
                <img src="${representativeTrip.thumbnailUrl}" alt="${representativeTrip.tripName}">
              </c:when>
              <c:otherwise>
                <div class="thumb-placeholder ongoing-bg">🌊</div>
              </c:otherwise>
            </c:choose>
            <span class="widget-badge ongoing-badge">
              <span class="live-dot"></span>여행 중
            </span>
          </div>
          <div class="widget-body">
            <p class="widget-eyebrow">지금 진행 중인 여행</p>
            <h3 class="widget-title">${representativeTrip.tripName}</h3>
            <div class="widget-meta-row">
              <span class="meta-chip">
                <svg width="14" height="14" viewBox="0 0 16 16" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                  <path d="M8 1.5A4.5 4.5 0 0 1 12.5 6c0 3-4.5 8-4.5 8S3.5 9 3.5 6A4.5 4.5 0 0 1 8 1.5Z"/>
                  <circle cx="8" cy="6" r="1.5"/>
                </svg>
                ${representativeTrip.citiesStr}
              </span>
              <span class="meta-chip">
                <svg width="14" height="14" viewBox="0 0 16 16" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                  <rect x="1.5" y="2.5" width="13" height="12" rx="2"/>
                  <path d="M1.5 6.5h13M5 1v3M11 1v3"/>
                </svg>
                ${representativeTrip.startDate} ~ ${representativeTrip.endDate}
              </span>
            </div>
            <p class="widget-desc">일정과 지출을 지금 바로 확인하고 정산도 놓치지 마세요</p>
            <div class="widget-actions">
              <a href="${pageContext.request.contextPath}/trip/${representativeTrip.tripId}/workspace"
                 class="btn-widget-primary">지금 여행 보기 →</a>
              <a href="${pageContext.request.contextPath}/trip/my_trips"
                 class="btn-widget-secondary">내 여행 전체보기</a>
            </div>
          </div>
        </div>
      </c:if>

      <%-- ─────────────────────────────────────
           E. COMPLETED (모두 완료)
      ───────────────────────────────────── --%>
      <c:if test="${widgetType == 'COMPLETED'}">
        <div class="trip-widget completed-widget">
          <div class="widget-accent accent-complete"></div>
          <div class="widget-thumb">
            <c:choose>
              <c:when test="${not empty representativeTrip.thumbnailUrl}">
                <img src="${representativeTrip.thumbnailUrl}" alt="${representativeTrip.tripName}">
              </c:when>
              <c:otherwise>
                <div class="thumb-placeholder completed-bg">🏞️</div>
              </c:otherwise>
            </c:choose>
            <span class="widget-badge completed-badge">완료된 여행</span>
          </div>
          <div class="widget-body">
            <p class="widget-eyebrow">마지막으로 다녀온 여행</p>
            <h3 class="widget-title">${representativeTrip.tripName}</h3>
            <div class="widget-meta-row">
              <span class="meta-chip">
                <svg width="14" height="14" viewBox="0 0 16 16" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                  <path d="M8 1.5A4.5 4.5 0 0 1 12.5 6c0 3-4.5 8-4.5 8S3.5 9 3.5 6A4.5 4.5 0 0 1 8 1.5Z"/>
                  <circle cx="8" cy="6" r="1.5"/>
                </svg>
                ${representativeTrip.citiesStr}
              </span>
              <span class="meta-chip">
                <svg width="14" height="14" viewBox="0 0 16 16" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                  <rect x="1.5" y="2.5" width="13" height="12" rx="2"/>
                  <path d="M1.5 6.5h13M5 1v3M11 1v3"/>
                </svg>
                ${representativeTrip.startDate} ~ ${representativeTrip.endDate}
              </span>
            </div>
            <p class="widget-desc">다음 목적지를 정하고 새로운 여행을 만들어보세요</p>
            <div class="widget-actions">
              <a href="${pageContext.request.contextPath}/trip/trip_create"
                 class="btn-widget-primary">＋ 새 여행 만들기</a>
              <a href="${pageContext.request.contextPath}/trip/my_trips"
                 class="btn-widget-secondary">지난 여행 보기</a>
            </div>
          </div>
        </div>
      </c:if>

    </div>
  </section>

  <%-- ══════════════════════════════════════════════
       피드 섹션 — API 연동 (디자인 기존 그대로)
  ══════════════════════════════════════════════ --%>
  <section>
    <div class="feed-header reveal">
      <div>
        <h2 style="font-size: 28px; font-weight: 900; margin-bottom: 8px;">실시간 인기 피드 🔥</h2>
        <p style="font-size: 15px; font-weight: 600; color: var(--text-dark);">지금 이 순간 가장 많이 담겨진 여행 코스</p>
      </div>
      <button class="btn-more" onclick="location.href='${pageContext.request.contextPath}/feed/feed_list'">전체보기 →</button>
    </div>
    <div class="carousel-wrapper reveal">
      <button class="nav-arrow prev">←</button>
      <div class="horizontal-list" id="homeFeedList">
        <%-- JS로 채워짐 --%>
      </div>
      <button class="nav-arrow next">→</button>
    </div>
  </section>

  <section>
    <div class="feed-header reveal">
      <div>
        <h2 style="font-size: 28px; font-weight: 900; margin-bottom: 8px;">최근 살펴본 핫플 리스트 👀</h2>
        <p style="font-size: 15px; font-weight: 600; color: var(--text-dark);">나의 동선에 맞춰 추천된 감성 숙소</p>
      </div>
      <button class="btn-more" onclick="location.href='${pageContext.request.contextPath}/curation/magazine_list'">더보기 →</button>
    </div>
    <div class="carousel-wrapper reveal">
      <button class="nav-arrow prev">←</button>
      <div class="horizontal-list">
        <div class="list-item stay-card">
          <div class="list-img"><img src="https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?auto=format&fit=crop&w=600&q=80" alt="Gangneung"></div>
          <div class="list-info">
            <h4>스테이 폴라리스 (강릉)</h4>
            <p class="desc">오션뷰 · 인피니티 풀</p>
            <p class="stay-price">₩ 180,000 ~ <span>⭐ 4.9</span></p>
          </div>
        </div>
        <div class="list-item stay-card">
          <div class="list-img"><img src="https://images.unsplash.com/photo-1566073771259-6a8506099945?auto=format&fit=crop&w=600&q=80" alt="Namhae"></div>
          <div class="list-info">
            <h4>루나 부티크 펜션 (남해)</h4>
            <p class="desc">프라이빗 바베큐 · 독채 풀빌라</p>
            <p class="stay-price">₩ 240,000 ~ <span>⭐ 4.8</span></p>
          </div>
        </div>
        <div class="list-item stay-card">
          <div class="list-img"><img src="https://images.unsplash.com/photo-1582719508461-905c673771fd?auto=format&fit=crop&w=600&q=80" alt="Gapyeong"></div>
          <div class="list-info">
            <h4>포레스트 캐빈 (가평)</h4>
            <p class="desc">감성 글램핑 · 불멍 화로대</p>
            <p class="stay-price">₩ 150,000 ~ <span>⭐ 4.7</span></p>
          </div>
        </div>
        <div class="list-item stay-card">
          <div class="list-img"><img src="https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?auto=format&fit=crop&w=600&q=80" alt="Seoul"></div>
          <div class="list-info">
            <h4>신라 파크뷰 호텔 (서울)</h4>
            <p class="desc">시티뷰 · 라운지 억세스</p>
            <p class="stay-price">₩ 420,000 ~ <span>⭐ 4.9</span></p>
          </div>
        </div>
      </div>
      <button class="nav-arrow next">→</button>
    </div>
  </section>

  <section>
    <div class="feed-header reveal">
      <div>
        <h2 style="font-size: 28px; font-weight: 900; margin-bottom: 8px;">Tripan TOP 10 🏆</h2>
        <p style="font-size: 15px; font-weight: 600; color: var(--text-dark);">유저 평점이 증명하는 믿고 가는 스테이</p>
      </div>
      <button class="btn-more" onclick="location.href='${pageContext.request.contextPath}/curation/place_list'">랭킹 전체보기 →</button>
    </div>
    <div class="carousel-wrapper reveal">
      <button class="nav-arrow prev">←</button>
      <div class="horizontal-list">
        <div class="list-item stay-card">
          <div class="list-img">
            <div class="floating-badge" style="background: var(--text-black); color: var(--point-yellow);">👑 TOP 1</div>
            <img src="https://images.unsplash.com/photo-1571003123894-1f0594d2b5d9?auto=format&fit=crop&w=600&q=80" alt="Top 1">
          </div>
          <div class="list-info">
            <h4>아만 스위트 리저브 (제주)</h4>
            <p class="desc">⭐ 4.9 · 리뷰 1,204개</p>
          </div>
        </div>
        <div class="list-item stay-card">
          <div class="list-img">
            <div class="floating-badge" style="color: var(--text-black); background: var(--bg-white);">TOP 2</div>
            <img src="https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?auto=format&fit=crop&w=600&q=80" alt="Top 2">
          </div>
          <div class="list-info">
            <h4>그랜드 앰배서더 풀빌라</h4>
            <p class="desc">⭐ 4.8 · 리뷰 890개</p>
          </div>
        </div>
        <div class="list-item stay-card">
          <div class="list-img">
            <div class="floating-badge" style="color: var(--text-black); background: var(--bg-white);">TOP 3</div>
            <img src="https://images.unsplash.com/photo-1445019980597-93fa8acb246c?auto=format&fit=crop&w=600&q=80" alt="Top 3">
          </div>
          <div class="list-info">
            <h4>신라 더 파크 호텔 (서울)</h4>
            <p class="desc">⭐ 4.8 · 리뷰 750개</p>
          </div>
        </div>
      </div>
      <button class="nav-arrow next">→</button>
    </div>
  </section>

</main>

<script>
/* ━━━ 실시간 인기피드 API 로딩 ━━━ */
(function(){
  var CP = '${pageContext.request.contextPath}';
  var container = document.getElementById('homeFeedList');
  if (!container) return;

  function escHtml(s) {
    return String(s||'')
      .replace(/&/g,'&amp;').replace(/</g,'&lt;')
      .replace(/>/g,'&gt;').replace(/"/g,'&quot;');
  }

  function makeItem(t) {
    var thumb   = t.thumbnailUrl || '';
    var cities  = t.citiesStr || '';
    var name    = t.tripName || '여행';
    var scrap   = t.scrapCount || 0;
    var likes   = t.likeCount || 0;
    var leader  = t.leaderNickname || '트리패너';
    var profImg = t.leaderProfileImage || '';

    // 지역 태그 (최대 2개)
    var tags = cities
      ? cities.split(',').slice(0,2).map(function(c){ return '#'+c.trim(); }).filter(Boolean).join(' ')
      : '#국내여행';

    // 설명 (description이 있으면 사용, 없으면 담기수 표시)
    var desc = (t.description && t.description.trim())
      ? t.description.trim()
      : '🗂 ' + scrap + '회 담겨진 여행';

    // 썸네일
    var imgHtml = thumb
      ? '<img src="'+escHtml(thumb.startsWith('http')?thumb:CP+thumb)+'" alt="'+escHtml(name)+'" loading="lazy">'
      : '';

    // 프로필 이미지
    var avHtml = profImg
      ? '<img src="'+escHtml(profImg.startsWith('http')?profImg:CP+'/'+profImg)+'" alt="">'
      : '<img src="'+CP+'/dist/images/trip_icon.png" alt="">';

    return '<div class="list-item" onclick="location.href=\''+CP+'/feed/feed_detail?tripId='+t.tripId+'\'" style="cursor:pointer">'
      + '<div class="list-img">'
      + '<div class="floating-badge">❤️ '+likes+' &nbsp; 🗂 '+scrap+'</div>'
      + imgHtml
      + '</div>'
      + '<div class="list-info">'
      + '<span class="tag">'+escHtml(tags)+'</span>'
      + '<h4>'+escHtml(name)+'</h4>'
      + '<p class="desc">'+escHtml(desc)+'</p>'
      + '<div class="author-info">'
      + '<div class="author-pic">'+avHtml+'</div>'
      + '@'+escHtml(leader)
      + '</div>'
      + '</div>'
      + '</div>';
  }

  fetch(CP + '/feed/public-trips?page=0&size=8')
    .then(function(r){
      // 401/403이면 Security 설정 문제 → 빈 목록으로 graceful 처리
      if (!r.ok) {
        console.warn('[HomeFeed] API 응답 오류:', r.status, '— SecurityConfig에 /feed/public-trips permitAll 추가 필요');
        return [];
      }
      return r.json();
    })
    .then(function(list) {
      if (!list || !list.length) {
        container.innerHTML = '<div style="padding:40px;color:#999;font-size:14px;">공개된 여행이 아직 없어요.</div>';
        return;
      }
      container.innerHTML = list.slice(0, 8).map(makeItem).join('');
    })
    .catch(function(e){
      console.error('[HomeFeed] fetch 실패:', e);
      container.innerHTML = '';
    });
})();
</script>
<script src="${pageContext.request.contextPath}/dist/js/home.js"></script>
<jsp:include page="../layout/footer.jsp" />
