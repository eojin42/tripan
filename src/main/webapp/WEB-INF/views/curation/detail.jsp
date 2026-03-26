<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<jsp:include page="../layout/header.jsp" />

<%-- 카카오 지도 SDK: workspace.jsp와 동일 방식 (autoload=false) --%>
<c:if test="${not empty kakaoAppKey}">
  <script src="//dapi.kakao.com/v2/maps/sdk.js?appkey=${kakaoAppKey}&libraries=services,clusterer&autoload=false"></script>
</c:if>

<link rel="stylesheet" href="${pageContext.request.contextPath}/dist/css/curation/place_detail.css">

<%-- ══ 라이트박스 ══ --%>
<div class="lb-overlay" id="lbOverlay" onclick="closeLightbox()">
  <button class="lb-close" onclick="closeLightbox()">✕</button>
  <button class="lb-nav lb-prev" onclick="lbMove(-1);event.stopPropagation()">&#10094;</button>
  <div class="lb-img-wrap" onclick="event.stopPropagation()">
    <img id="lbImg" src="" alt="">
  </div>
  <button class="lb-nav lb-next" onclick="lbMove(1);event.stopPropagation()">&#10095;</button>
  <div class="lb-counter" id="lbCounter"></div>
</div>

<div class="dt-page">

  <%-- ══ 캐러셀 ══ --%>
  <c:if test="${not empty place.images}">
    <div class="dt-hero">
      <div class="dt-carousel">
        <div class="dt-carousel-track" id="dtTrack">
          <c:forEach var="img" items="${place.images}" varStatus="vs">
            <div class="dt-carousel-slide" onclick="openLightbox(${vs.index})" title="클릭하여 크게 보기">
              <img src="${img}" alt="${place.placeName}"
                   onerror="this.closest('.dt-carousel-slide').style.display='none'">
            </div>
          </c:forEach>
        </div>
        <c:if test="${fn:length(place.images) > 1}">
          <button class="dt-caro-btn prev" onclick="slideMove(-1)">&#10094;</button>
          <button class="dt-caro-btn next" onclick="slideMove(1)">&#10095;</button>
          <div class="dt-caro-counter" id="dtCounter">1 / ${fn:length(place.images)}</div>
        </c:if>
        <div class="dt-zoom-hint">
          <svg width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M15 3h6v6M9 21H3v-6M21 3l-7 7M3 21l7-7"/></svg>
          크게 보기
        </div>
      </div>
      <c:if test="${fn:length(place.images) > 1}">
        <div class="dt-thumb-row">
          <c:forEach var="img" items="${place.images}" varStatus="vs">
            <div class="dt-thumb ${vs.first ? 'active' : ''}" onclick="goSlide(${vs.index})">
              <img src="${img}" alt="" onerror="this.closest('.dt-thumb').style.display='none'">
            </div>
          </c:forEach>
        </div>
      </c:if>
    </div>
  </c:if>

  <div class="dt-container">

    <%-- 헤더 --%>
    <header class="dt-header">
      <span class="dt-cat-badge">
        <c:choose>
          <c:when test="${place.category == 'TOUR'}">🗺 관광지</c:when>
          <c:when test="${place.category == 'RESTAURANT'}">🍽 음식점</c:when>
          <c:when test="${place.category == 'ACCOMMODATION'}">🛏 숙박</c:when>
          <c:when test="${place.category == 'CULTURE'}">🎨 문화시설</c:when>
          <c:when test="${place.category == 'LEISURE'}">🏄 레포츠</c:when>
          <c:when test="${place.category == 'SHOPPING'}">🛍 쇼핑</c:when>
          <c:when test="${place.category == 'FESTIVAL'}">🎉 축제</c:when>
          <c:otherwise>${place.category}</c:otherwise>
        </c:choose>
      </span>
      <h1 class="dt-title">${place.placeName}</h1>
      <div class="dt-header-meta">
        <p class="dt-address">
          <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round">
            <path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z"/>
            <circle cx="12" cy="10" r="3"/>
          </svg>
          ${place.address}
        </p>
        <div class="dt-stats">
          <span class="dt-stat">
            <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg>
            ${place.viewCount != null ? place.viewCount : 0}
          </span>
          <button class="dt-like-btn ${liked ? 'liked' : ''}"
                  id="likeBtn"
                  onclick="toggleLike()"
                  data-place-id="${place.placeId}"
                  data-liked="${liked}"
                  data-count="${likeCount}">
            <svg width="15" height="15" viewBox="0 0 24 24"
                 fill="${liked ? 'currentColor' : 'none'}"
                 stroke="currentColor" stroke-width="2" stroke-linecap="round">
              <path d="M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 0 0-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 0 0 0-7.78z"/>
            </svg>
            <span id="likeCount">${likeCount}</span>
          </button>
        </div>
      </div>
    </header>

    <%-- 축제 날짜 배너 --%>
    <c:if test="${place.category == 'FESTIVAL' and not empty festival and not empty festival.eventStartDate}">
      <div class="dt-fest-banner">
        <div class="dt-fest-dates">
          <div class="dt-fest-date-col">
            <span class="dt-fd-label">시작</span>
            <span class="dt-fd-val"><fmt:formatDate value="${festival.eventStartDate}" pattern="yyyy.MM.dd"/></span>
          </div>
          <span class="dt-fd-arr">→</span>
          <div class="dt-fest-date-col">
            <span class="dt-fd-label">종료</span>
            <span class="dt-fd-val"><fmt:formatDate value="${festival.eventEndDate}" pattern="yyyy.MM.dd"/></span>
          </div>
        </div>
        <c:if test="${not empty festival.festivalGrade}">
          <span class="dt-fest-grade">${festival.festivalGrade}</span>
        </c:if>
      </div>
    </c:if>

    <%-- ══ 설명 ══ --%>
    <c:if test="${not empty place.description}">
      <div class="dt-card dt-desc-card">
        <p class="dt-desc" id="dtDesc">${place.description}</p>
        <button class="dt-more-btn" id="dtMoreBtn" onclick="toggleDesc()">
          내용 더보기
          <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round"><polyline points="6 9 12 15 18 9"/></svg>
        </button>
      </div>
    </c:if>

    <%-- ══ 정보 카드 (아이콘 + 라벨 + 값) ══ --%>
    <c:choose>

      <%-- 축제 --%>
      <c:when test="${place.category == 'FESTIVAL' and not empty festival}">
        <div class="dt-info-grid">
          <c:if test="${not empty festival.eventPlace}">
            <div class="dt-card dt-ic"><span class="dt-ic-emoji">📍</span><div><div class="dt-ic-l">행사 장소</div><div class="dt-ic-v">${festival.eventPlace}</div></div></div>
          </c:if>
          <c:if test="${not empty festival.playTime}">
            <div class="dt-card dt-ic"><span class="dt-ic-emoji">🕐</span><div><div class="dt-ic-l">운영시간</div><div class="dt-ic-v">${festival.playTime}</div></div></div>
          </c:if>
          <c:if test="${not empty festival.usageFee}">
            <div class="dt-card dt-ic"><span class="dt-ic-emoji">🎟</span><div><div class="dt-ic-l">이용 요금</div><div class="dt-ic-v">${festival.usageFee}</div></div></div>
          </c:if>
          <c:if test="${not empty festival.spendTime}">
            <div class="dt-card dt-ic"><span class="dt-ic-emoji">⏱</span><div><div class="dt-ic-l">관람 소요</div><div class="dt-ic-v">${festival.spendTime}</div></div></div>
          </c:if>
          <c:if test="${not empty festival.sponsor1}">
            <div class="dt-card dt-ic"><span class="dt-ic-emoji">🏛</span><div><div class="dt-ic-l">주최</div><div class="dt-ic-v">${festival.sponsor1}</div></div></div>
          </c:if>
          <c:if test="${not empty festival.sponsor1Tel}">
            <div class="dt-card dt-ic"><span class="dt-ic-emoji">📞</span><div><div class="dt-ic-l">주최 문의</div><div class="dt-ic-v"><a href="tel:${festival.sponsor1Tel}">${festival.sponsor1Tel}</a></div></div></div>
          </c:if>
          <c:if test="${not empty place.phoneNumber}">
            <div class="dt-card dt-ic"><span class="dt-ic-emoji">☎</span><div><div class="dt-ic-l">장소 문의</div><div class="dt-ic-v"><a href="tel:${place.phoneNumber}">${place.phoneNumber}</a></div></div></div>
          </c:if>
        </div>
        <c:if test="${not empty festival.program}">
          <div class="dt-card dt-prog-card">
            <div class="dt-prog-title">📋 행사 프로그램</div>
            <div class="dt-prog-body">${festival.program}</div>
          </div>
        </c:if>
        <c:if test="${not empty festival.subEvent}">
          <div class="dt-card dt-prog-card">
            <div class="dt-prog-title">⭐ 부대 행사</div>
            <div class="dt-prog-body">${festival.subEvent}</div>
          </div>
        </c:if>
      </c:when>

      <%-- 비축제 공통 --%>
      <c:otherwise>
        <div class="dt-info-grid">
          <c:if test="${not empty place.phoneNumber}">
            <div class="dt-card dt-ic"><span class="dt-ic-emoji">📞</span><div><div class="dt-ic-l">문의</div><div class="dt-ic-v"><a href="tel:${place.phoneNumber}">${place.phoneNumber}</a></div></div></div>
          </c:if>
          <c:if test="${place.category == 'RESTAURANT' and not empty place.opentime}">
            <div class="dt-card dt-ic"><span class="dt-ic-emoji">🕐</span><div><div class="dt-ic-l">영업시간</div><div class="dt-ic-v">${place.opentime}</div></div></div>
          </c:if>
          <c:if test="${place.category == 'RESTAURANT' and not empty place.restdate}">
            <div class="dt-card dt-ic"><span class="dt-ic-emoji">🚫</span><div><div class="dt-ic-l">휴무일</div><div class="dt-ic-v">${place.restdate}</div></div></div>
          </c:if>
          <c:if test="${place.category == 'RESTAURANT' and not empty place.parking}">
            <div class="dt-card dt-ic"><span class="dt-ic-emoji">🅿</span><div><div class="dt-ic-l">주차</div><div class="dt-ic-v">${place.parking}</div></div></div>
          </c:if>
          <c:if test="${(place.category == 'TOUR' or place.category == 'CULTURE' or place.category == 'LEISURE') and not empty place.usetime}">
            <div class="dt-card dt-ic"><span class="dt-ic-emoji">🕐</span><div><div class="dt-ic-l">이용시간</div><div class="dt-ic-v">${place.usetime}</div></div></div>
          </c:if>
          <c:if test="${(place.category == 'TOUR' or place.category == 'CULTURE' or place.category == 'LEISURE') and not empty place.closedDays}">
            <div class="dt-card dt-ic"><span class="dt-ic-emoji">🚫</span><div><div class="dt-ic-l">휴무일</div><div class="dt-ic-v">${place.closedDays}</div></div></div>
          </c:if>
          <c:if test="${place.category == 'ACCOMMODATION' and not empty place.checkintime}">
            <div class="dt-card dt-ic"><span class="dt-ic-emoji">🔑</span><div><div class="dt-ic-l">체크인</div><div class="dt-ic-v">${place.checkintime}</div></div></div>
          </c:if>
          <c:if test="${place.category == 'ACCOMMODATION' and not empty place.checkouttime}">
            <div class="dt-card dt-ic"><span class="dt-ic-emoji">🏁</span><div><div class="dt-ic-l">체크아웃</div><div class="dt-ic-v">${place.checkouttime}</div></div></div>
          </c:if>
        </div>
      </c:otherwise>
    </c:choose>

    <%-- ══ 지도 ══ --%>
    <c:if test="${not empty place.latitude and not empty place.longitude
                  and place.latitude != 0 and place.longitude != 0}">
      <div class="dt-map-section">
        <div class="dt-section-label">위치</div>
        <div class="dt-card dt-map-card">
          <div id="kakaoDetailMap" class="dt-map"></div>
        </div>
      </div>
    </c:if>

    <%-- ══ 주변 장소 ══ --%>
    <div class="dt-nearby-section">
      <div class="dt-section-label">주변 장소</div>
      <div id="nearbyList">
        <div class="dt-nearby-loading">
          <div class="dt-dot"></div><div class="dt-dot"></div><div class="dt-dot"></div>
        </div>
      </div>
    </div>

  </div>
</div>

<jsp:include page="../layout/footer.jsp" />

<script>
  const PLACE_DATA = {
    placeId:     ${place.placeId},
    name:        '${fn:escapeXml(place.placeName)}',
    address:     '${fn:escapeXml(place.address)}',
    category:    '${fn:escapeXml(place.category)}',
    lat:         ${not empty place.latitude  ? place.latitude  : 0},
    lng:         ${not empty place.longitude ? place.longitude : 0},
    imageCount:  ${fn:length(place.images)},
    contextPath: '${pageContext.request.contextPath}',
    images:      [<c:forEach var="img" items="${place.images}" varStatus="vs">'${fn:escapeXml(img)}'<c:if test="${!vs.last}">,</c:if></c:forEach>]
  };
</script>
<script src="${pageContext.request.contextPath}/dist/js/curation/place_detail.js"></script>
