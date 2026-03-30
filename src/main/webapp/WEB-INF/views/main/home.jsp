<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"  uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<jsp:include page="../layout/header.jsp" />

<link rel="stylesheet" href="${pageContext.request.contextPath}/dist/css/home.css">

<main>

  <%-- ══════════════════════════════════════════════
       HERO CAROUSEL SECTION — DB 연동
  ══════════════════════════════════════════════ --%>
  <div class="hero hero-carousel" id="heroCarousel">

    <div class="carousel-track">

      <%-- DB 배너가 있으면 DB에서, 없으면 기본 슬라이드 --%>
      <c:choose>
        <c:when test="${not empty banners}">
          <c:forEach var="banner" items="${banners}" varStatus="vs">
            <div class="carousel-slide ${vs.first ? 'active' : ''}">
              <div class="hero-img">
                <c:choose>
				  <c:when test="${banner.imageUrl.startsWith('http')}">
				    <img src="${banner.imageUrl}" alt="${banner.bannerName}">
				  </c:when>
				  <c:otherwise>
				    <img src="${pageContext.request.contextPath}/uploads/banner/${banner.imageUrl}" alt="${banner.bannerName}">
				  </c:otherwise>
				</c:choose>
              </div>
              <div class="hero-overlay">
                <p class="hero-eyebrow">${banner.eyebrowText}</p>
                <h2 class="hero-title">${banner.mainTitle}</h2>
                <p class="hero-subtitle">${banner.subTitle}</p>
              </div>
            </div>
          </c:forEach>
        </c:when>
        <c:otherwise>
          <%-- DB 배너 없을 때 기본 슬라이드 3개 --%>
          <div class="carousel-slide active">
            <div class="hero-img">
              <img src="https://images.unsplash.com/photo-1507525428034-b723cf961d3e?q=80&w=2073&auto=format&fit=crop" alt="해변">
            </div>
            <div class="hero-overlay">
              <p class="hero-eyebrow">여행 플래너 Tripan</p>
              <h2 class="hero-title">다음 여행을,<br>더 가볍고 선명하게</h2>
              <p class="hero-subtitle">일정은 같이, 정산은 쉽게 - 여행의 처음부터 끝까지 한 곳에서</p>
            </div>
          </div>
          <div class="carousel-slide">
            <div class="hero-img">
              <img src="https://images.unsplash.com/photo-1469474968028-56623f02e42e?q=80&w=2074&auto=format&fit=crop" alt="산">
            </div>
            <div class="hero-overlay">
              <p class="hero-eyebrow">일정 관리</p>
              <h2 class="hero-title">함께라서 더 좋은<br>여행 일정 플래너</h2>
              <p class="hero-subtitle">팀원과 실시간으로 일정을 함께 짜고 공유하세요</p>
            </div>
          </div>
          <div class="carousel-slide">
            <div class="hero-img">
              <img src="https://images.unsplash.com/photo-1476514525535-07fb3b4ae5f1?q=80&w=2070&auto=format&fit=crop" alt="호수">
            </div>
            <div class="hero-overlay">
              <p class="hero-eyebrow">정산 기능</p>
              <h2 class="hero-title">복잡한 여행 경비,<br>자동으로 정산</h2>
              <p class="hero-subtitle">누가 얼마를 썼는지 한눈에 - 엑셀 없이 깔끔하게</p>
            </div>
          </div>
        </c:otherwise>
      </c:choose>

    </div><%-- /carousel-track --%>

    <%-- 좌우 화살표 --%>
    <button class="carousel-arrow carousel-prev" id="carouselPrev" aria-label="이전 슬라이드">
      <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
        <polyline points="15 18 9 12 15 6"/>
      </svg>
    </button>
    <button class="carousel-arrow carousel-next" id="carouselNext" aria-label="다음 슬라이드">
      <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
        <polyline points="9 18 15 12 9 6"/>
      </svg>
    </button>

    <%-- 인디케이터 도트 — 슬라이드 수만큼 동적 생성 --%>
    <div class="carousel-dots" id="carouselDots">
      <c:choose>
        <c:when test="${not empty banners}">
          <c:forEach var="banner" items="${banners}" varStatus="vs">
            <button class="dot ${vs.first ? 'active' : ''}"
                    data-index="${vs.index}"
                    aria-label="슬라이드 ${vs.index + 1}"></button>
          </c:forEach>
        </c:when>
        <c:otherwise>
          <button class="dot active" data-index="0" aria-label="슬라이드 1"></button>
          <button class="dot"        data-index="1" aria-label="슬라이드 2"></button>
          <button class="dot"        data-index="2" aria-label="슬라이드 3"></button>
        </c:otherwise>
      </c:choose>
    </div>

  </div><%-- /hero-carousel --%>

  <style>
    /* ── 캐러셀 오버라이드 ── */
	.hero-carousel { position: relative; overflow: hidden; height: 500px; }
	.carousel-track { position: relative; height: 100%; }

    /* 이미지 꽉 채우기 (안 나오는 문제 해결) */
    .hero-img { position: absolute; inset: 0; width: 100%; height: 100%; z-index: 1; }
    .hero-img img { width: 100%; height: 100%; object-fit: cover;
      filter: brightness(0.8) saturate(1.1) contrast(0.95); }

    /* 슬라이드 — opacity 크로스페이드 방식 */
    .carousel-slide {
      display: block;
      opacity: 0;
      position: absolute; inset: 0; width: 100%; height: 100%;
      pointer-events: none;
      transition: opacity 0.7s ease-in-out;
    }
    .carousel-slide.active {
      opacity: 1;
      position: relative;
      pointer-events: auto;
    }
    /* 텍스트 슬라이드인 효과 */
    .carousel-slide .hero-overlay {
      transform: translateY(14px);
      opacity: 0;
      transition: opacity 0.55s ease 0.2s, transform 0.55s ease 0.2s;
    }
    .carousel-slide.active .hero-overlay {
      transform: translateY(0);
      opacity: 1;
    }

    /* 화살표 */
    .carousel-arrow {
      position: absolute; top: 50%; transform: translateY(-50%); z-index: 10;
      background: rgba(255,255,255,0.18); backdrop-filter: blur(6px);
      -webkit-backdrop-filter: blur(6px);
      border: 1.5px solid rgba(255,255,255,0.4);
      color: #fff; width: 44px; height: 44px; border-radius: 50%;
      cursor: pointer; display: flex; align-items: center; justify-content: center;
      transition: background 0.2s;
    }
    .carousel-arrow:hover { background: rgba(255,255,255,0.35); }
    .carousel-prev { left: 20px; }
    .carousel-next { right: 20px; }

    /* 인디케이터 도트 */
    .carousel-dots {
      position: absolute; bottom: 22px; left: 50%; transform: translateX(-50%);
      display: flex; gap: 8px; z-index: 10;
    }
    .dot {
      width: 8px; height: 8px; border-radius: 50%;
      background: rgba(255,255,255,0.45); border: none; cursor: pointer;
      padding: 0; transition: background 0.25s, transform 0.25s;
    }
    .dot.active { background: #fff; transform: scale(1.3); }
  </style>

  <script>
  (function () {
    var slides  = document.querySelectorAll('#heroCarousel .carousel-slide');
    var dots    = document.querySelectorAll('#heroCarousel .dot');
    var current = 0;
    var timer;
    var isAnimating = false;

    // 슬라이드 1개면 화살표/도트 숨기기
    if (slides.length <= 1) {
      var prev = document.getElementById('carouselPrev');
      var next = document.getElementById('carouselNext');
      var dotsWrap = document.getElementById('carouselDots');
      if (prev) prev.style.display = 'none';
      if (next) next.style.display = 'none';
      if (dotsWrap) dotsWrap.style.display = 'none';
      return;
    }

    function goTo(idx) {
      if (isAnimating || idx === current) return;
      isAnimating = true;

      var prev = current;
      current = (idx + slides.length) % slides.length;

      // 이전 슬라이드 페이드 아웃
      slides[prev].classList.remove('active');
      dots[prev].classList.remove('active');

      // 다음 슬라이드 페이드 인
      slides[current].classList.add('active');
      dots[current].classList.add('active');

      setTimeout(function () { isAnimating = false; }, 750);
    }

    function startAuto() { timer = setInterval(function () { goTo(current + 1); }, 4500); }
    function resetAuto()  { clearInterval(timer); startAuto(); }

    document.getElementById('carouselNext').addEventListener('click', function () { goTo(current + 1); resetAuto(); });
    document.getElementById('carouselPrev').addEventListener('click', function () { goTo(current - 1); resetAuto(); });
    dots.forEach(function (dot) {
      dot.addEventListener('click', function () { goTo(parseInt(this.dataset.index)); resetAuto(); });
    });

    startAuto();
  })();
  </script>

  <%-- ══════════════════════════════════════════════
       메인 여행 위젯
  ══════════════════════════════════════════════ --%>
  <section class="widget-section reveal">
    <div class="widget-container">

      <%-- A. 비로그인 --%>
      <c:if test="${widgetType == 'GUEST'}">
        <div class="trip-widget guest-widget">
          <div class="widget-accent accent-brand"></div>
          <div class="widget-visual guest-visual">
            <img src="${pageContext.request.contextPath}/dist/images/logo.png" alt="Tripan 로고" class="guest-logo-img">
          </div>
          <div class="widget-body">
            <p class="widget-eyebrow">Travel Planner</p>
            <h3 class="widget-title">함께 만드는 여행,<br>정리는 더 간단하게</h3>
            <p class="widget-desc">
              여행 일정을 같이 짜고, 지출을 자동으로 정산하세요.<br>
              복잡한 엑셀 없이 한 화면에서 모두 해결됩니다.
            </p>
            <div class="widget-actions">
              <a href="${pageContext.request.contextPath}/start" class="btn-widget-primary">무료로 시작하기 →</a>
            </div>
          </div>
        </div>
      </c:if>

      <%-- B. 로그인 · 여행 없음 --%>
      <c:if test="${widgetType == 'EMPTY'}">
        <div class="trip-widget empty-widget">
          <div class="widget-accent accent-empty"></div>
          <div class="widget-body centered">
            <img src="${pageContext.request.contextPath}/dist/images/logo.png" alt="Tripan" class="empty-icon">
            <p class="widget-eyebrow">${loginNickname}님, 환영해요</p>
            <h3 class="widget-title">아직 만들어진 여행이 없네요</h3>
            <p class="widget-desc">첫 여행을 만들고 일정과 지출을 한 번에 관리해보세요</p>
            <div class="widget-actions centered">
              <a href="${pageContext.request.contextPath}/trip/trip_create" class="btn-widget-primary">＋ 새 여행 만들기</a>
            </div>
          </div>
        </div>
      </c:if>

      <%-- C. PLANNING --%>
      <c:if test="${widgetType == 'PLANNING'}">
        <div class="trip-widget planning-widget">
          <div class="widget-accent accent-planning"></div>
          <div class="widget-thumb">
            <c:choose>
              <c:when test="${not empty representativeTrip.thumbnailUrl}">
                <img src="${representativeTrip.thumbnailUrl}" alt="${representativeTrip.tripName}">
              </c:when>
              <c:otherwise><div class="thumb-placeholder planning-bg">🌅</div></c:otherwise>
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
              <a href="${pageContext.request.contextPath}/trip/${representativeTrip.tripId}/workspace" class="btn-widget-primary">여행으로 가기 →</a>
              <a href="${pageContext.request.contextPath}/trip/my_trips" class="btn-widget-secondary">내 여행 전체보기</a>
            </div>
          </div>
        </div>
      </c:if>

      <%-- D. ONGOING --%>
      <c:if test="${widgetType == 'ONGOING'}">
        <div class="trip-widget ongoing-widget">
          <div class="widget-accent accent-ongoing"></div>
          <div class="widget-thumb">
            <c:choose>
              <c:when test="${not empty representativeTrip.thumbnailUrl}">
                <img src="${representativeTrip.thumbnailUrl}" alt="${representativeTrip.tripName}">
              </c:when>
              <c:otherwise><div class="thumb-placeholder ongoing-bg">🌊</div></c:otherwise>
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
              <a href="${pageContext.request.contextPath}/trip/${representativeTrip.tripId}/workspace" class="btn-widget-primary">지금 여행 보기 →</a>
              <a href="${pageContext.request.contextPath}/trip/my_trips" class="btn-widget-secondary">내 여행 전체보기</a>
            </div>
          </div>
        </div>
      </c:if>

      <%-- E. COMPLETED --%>
      <c:if test="${widgetType == 'COMPLETED'}">
        <div class="trip-widget completed-widget">
          <div class="widget-accent accent-complete"></div>
          <div class="widget-thumb">
            <c:choose>
              <c:when test="${not empty representativeTrip.thumbnailUrl}">
                <img src="${representativeTrip.thumbnailUrl}" alt="${representativeTrip.tripName}">
              </c:when>
              <c:otherwise><div class="thumb-placeholder completed-bg">🏞️</div></c:otherwise>
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
              <a href="${pageContext.request.contextPath}/trip/trip_create" class="btn-widget-primary">＋ 새 여행 만들기</a>
              <a href="${pageContext.request.contextPath}/trip/my_trips" class="btn-widget-secondary">지난 여행 보기</a>
            </div>
          </div>
        </div>
      </c:if>

    </div>
  </section>

  <%-- ══ 실시간 인기 피드 ══ --%>
  <section>
    <div class="feed-header reveal">
      <div>
        <h2 class="section-header-title">실시간 인기 피드 🗺️</h2>
        <p class="section-header-sub">지금 이 순간 가장 많이 담겨진 여행 코스</p>
      </div>
      <button class="btn-more" onclick="location.href='${pageContext.request.contextPath}/feed/feed_list'">전체보기 →</button>
    </div>
    <div class="carousel-wrapper reveal">
      <button class="nav-arrow prev">←</button>
      <div class="horizontal-list" id="homeFeedList"></div>
      <button class="nav-arrow next">→</button>
    </div>
  </section>

	<%-- ══ 인기 숙소 — 매거진 인스타 그리드 ══ --%>
<section class="mg-insta-section reveal" style="margin-bottom: 80px;">
  <div class="feed-header">
    <div>
      <h2 class="section-header-title">지금 가장 핫한 숙소 🔥</h2>
      <p class="section-header-sub">Tripan 유저들이 실시간으로 가장 많이 찜한 인기 숙소들을 모았습니다.</p>
    </div>
    <button class="btn-more" onclick="location.href='${pageContext.request.contextPath}/accommodation/list'">더보기 →</button>
  </div>

  <c:choose>
    <c:when test="${not empty popularList}">
      <div class="mg-insta-grid">

        <%-- 첫 번째 카드 — 크게 (2행 차지) --%>
        <c:forEach var="stay" items="${popularList}" varStatus="vs">
          <c:if test="${vs.index == 0}">
            <a class="mg-ig-card mg-ig-card--big"
               href="${pageContext.request.contextPath}/accommodation/detail/${stay.placeId}">
              <img src="${fn:startsWith(stay.imageUrl, 'http') ? stay.imageUrl : pageContext.request.contextPath += stay.imageUrl}"
                   onerror="this.src='https://images.unsplash.com/photo-1611892440504-42a792e24d32?w=600'" alt="${stay.name}">
              <div class="mg-ig-overlay">
                <span class="mg-ig-tag">🔥 POPULAR</span>
                <h3 class="mg-ig-title">${stay.name}</h3>
                <p class="mg-ig-desc">
                  ★ ${stay.avgRating != null && stay.avgRating > 0 ? stay.avgRating : '0.0'}
                  &nbsp;·&nbsp; ${stay.region}
                  &nbsp;·&nbsp; ₩<fmt:formatNumber value="${stay.minPrice}" pattern="#,###"/> /박
                </p>
              </div>
            </a>
          </c:if>
        </c:forEach>

        <%-- 나머지 카드 4개 (index 1~4) --%>
        <c:forEach var="stay" items="${popularList}" varStatus="vs">
          <c:if test="${vs.index >= 1 && vs.index <= 4}">
            <a class="mg-ig-card"
               href="${pageContext.request.contextPath}/accommodation/detail/${stay.placeId}">
              <img src="${fn:startsWith(stay.imageUrl, 'http') ? stay.imageUrl : pageContext.request.contextPath += stay.imageUrl}"
                   onerror="this.src='https://images.unsplash.com/photo-1611892440504-42a792e24d32?w=600'" alt="${stay.name}">
              <div class="mg-ig-overlay">
                <span class="mg-ig-tag">#${vs.index + 1}</span>
                <h3 class="mg-ig-title">${stay.name}</h3>
                <p class="mg-ig-desc">
                  ★ ${stay.avgRating != null && stay.avgRating > 0 ? stay.avgRating : '0.0'}
                  &nbsp;·&nbsp; ₩<fmt:formatNumber value="${stay.minPrice}" pattern="#,###"/> /박
                </p>
              </div>
            </a>
          </c:if>
        </c:forEach>

      </div>
    </c:when>
    <c:otherwise>
      <div style="text-align:center; padding:60px 0; color:#8E8E93; font-weight:600;">
        현재 등록된 추천 숙소가 없습니다.
      </div>
    </c:otherwise>
  </c:choose>
</section>

  <%-- ══ TOP 10 ══ --%>
  <section class="home-top10-section reveal">
    <div class="feed-header">
	  <div>
	    <h2 class="section-header-title">지금 뜨는 장소 ✨</h2>
	    <p class="section-header-sub">실시간 조회수 · 좋아요 기준 TOP 10</p>
	  </div>
	  <button class="btn-more" onclick="location.href='${pageContext.request.contextPath}/curation/place_list?sort=views'">전체보기 →</button>
	</div>
    <c:choose>
      <c:when test="${not empty top10Places}">
        <div class="carousel-wrapper">
          <button class="nav-arrow prev">←</button>
          <div class="horizontal-list top10-hlist">
            <c:forEach var="p" items="${top10Places}" varStatus="vs">
              <a class="top10-card"
                 href="${pageContext.request.contextPath}/curation/detail?id=${p.placeId}">
                <div class="top10-card-img">
                  <img src="${p.imageUrl}" alt="${fn:escapeXml(p.placeName)}"
                       onerror="this.src='${pageContext.request.contextPath}/dist/images/logo.png'">
                  <div class="top10-card-stats-overlay">
                    <span>&#128065; ${p.viewCount != null ? p.viewCount : 0}</span>
                    <span>&#10084; ${p.likeCount != null ? p.likeCount : 0}</span>
                  </div>
                </div>
                <div class="top10-card-body">
                  <div class="top10-card-name">${fn:escapeXml(p.placeName)}</div>
                  <div class="top10-card-cat">
                    <c:choose>
                      <c:when test="${p.category == 'TOUR'}">관광지</c:when>
                      <c:when test="${p.category == 'RESTAURANT'}">음식점</c:when>
                      <c:when test="${p.category == 'ACCOMMODATION'}">숙박</c:when>
                      <c:when test="${p.category == 'CULTURE'}">문화시설</c:when>
                      <c:when test="${p.category == 'LEISURE'}">레포츠</c:when>
                      <c:when test="${p.category == 'SHOPPING'}">쇼핑</c:when>
                      <c:when test="${p.category == 'FESTIVAL'}">축제</c:when>
                      <c:otherwise>${p.category}</c:otherwise>
                    </c:choose>
                  </div>
                </div>
              </a>
            </c:forEach>
          </div>
          <button class="nav-arrow next">→</button>
        </div>
      </c:when>
      <c:otherwise>
        <div style="padding:60px;text-align:center;color:#8E8E93;font-size:15px;font-weight:600;">
          아직 랭킹 데이터가 없습니다
        </div>
      </c:otherwise>
    </c:choose>
  </section>

</main>

<jsp:include page="/WEB-INF/views/main/chat.jsp" />

<script>
  /* home.js에서 사용할 전역 변수 */
  var HOME_CP = '${pageContext.request.contextPath}';
</script>
<script src="${pageContext.request.contextPath}/dist/js/home.js"></script>
<jsp:include page="../layout/footer.jsp" />
