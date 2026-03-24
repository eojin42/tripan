<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<jsp:include page="../layout/header.jsp" />

<link rel="stylesheet" href="${pageContext.request.contextPath}/dist/css/curation/place_detail.css">

<div class="dt-page">

  <div class="dt-carousel-wrap">
    <div class="dt-carousel">
      <div class="dt-carousel-track" id="dtTrack">
        <c:choose>
          <%-- 1. 이미지가 있을 때 --%>
          <c:when test="${not empty place.images}">
            <c:forEach var="img" items="${place.images}">
              <div class="dt-carousel-slide">
                <img src="${img}" alt="${place.placeName}" 
                     onerror="this.src='${pageContext.request.contextPath}/dist/images/logo.png'">
              </div>
            </c:forEach>
          </c:when>

          <%-- 2. 이미지가 아예 없을 때 (로고 출력) --%>
          <c:otherwise>
            <div class="dt-carousel-slide">
              <img src="${pageContext.request.contextPath}/dist/images/logo.png" alt="${place.placeName}">
            </div>
          </c:otherwise>
        </c:choose>
      </div>
      <button class="dt-carousel-btn prev" onclick="slideMove(-1)">&#10094;</button>
      <button class="dt-carousel-btn next" onclick="slideMove(1)">&#10095;</button>
      <div class="dt-carousel-counter" id="dtCounter">1 / ${fn:length(place.images) > 0 ? fn:length(place.images) : 1}</div>
    </div>

    <%-- 썸네일 (이미지가 2장 이상일 때만 표시) --%>
    <c:if test="${fn:length(place.images) > 1}">
      <div class="dt-thumb-row">
        <c:forEach var="img" items="${place.images}" varStatus="vs">
          <div class="dt-thumb ${vs.first ? 'active' : ''}" onclick="goSlide(${vs.index})">
            <img src="${img}" alt="썸네일" onerror="this.src='${pageContext.request.contextPath}/dist/images/logo.png'">
          </div>
        </c:forEach>
      </div>
    </c:if>
  </div>

  <div class="dt-container">

    <div class="dt-title-row">
      <div>
        <div class="dt-cat-badge">
          <svg width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round">
            <path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z"/>
            <circle cx="12" cy="10" r="3"/>
          </svg>
          ${place.category}
        </div>
        <div class="dt-name">${place.placeName}</div>
        <div class="dt-location">
          <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="#AAA" stroke-width="2.5" stroke-linecap="round">
            <path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z"/>
            <circle cx="12" cy="10" r="3"/>
          </svg>
          ${place.address}
        </div>
      </div>
    </div>

    <div class="dt-tabs">
      <button class="dt-tab active" onclick="scrollToSection('secInfo', this)">상세정보</button>
      <button class="dt-tab" onclick="scrollToSection('secNearby', this)">주변</button>
    </div>

    <div class="dt-body">
      <div class="dt-main">

        <section class="dt-section" id="secInfo">
          <div class="dt-section-title">상세정보</div>

          <c:if test="${not empty place.description}">
            <p class="dt-desc" id="dtDesc">${place.description}</p>
            <button class="dt-more-btn" id="dtMoreBtn" onclick="toggleDesc()">
              내용 더보기
              <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round">
                <polyline points="6 9 12 15 18 9"/>
              </svg>
            </button>
          </c:if>

          <div id="kakaoDetailMap" class="dt-map"></div>

          <div class="dt-info-grid">
            <c:if test="${not empty place.phoneNumber}">
              <div class="dt-info-row">
                <div class="dt-info-dot"></div>
                <div>
                  <div class="dt-info-label">문의 및 안내</div>
                  <div class="dt-info-value">${place.phoneNumber}</div>
                </div>
              </div>
            </c:if>
            <c:if test="${not empty place.address}">
              <div class="dt-info-row">
                <div class="dt-info-dot"></div>
                <div>
                  <div class="dt-info-label">주소</div>
                  <div class="dt-info-value">${place.address}</div>
                </div>
              </div>
            </c:if>
            <%-- 추가 정보(영업시간 등)가 DTO에 있다면 여기에 추가 --%>
          </div>
        </section>

        <section class="dt-section" id="secNearby">
          <div class="dt-section-title">주변 장소</div>
          <div class="dt-nearby-list" id="nearbyList">
            <div class="dt-nearby-empty">
              <div style="font-size:36px;margin-bottom:10px;">📍</div>
              <div>주변 장소를 불러오는 중입니다...</div>
            </div>
          </div>
        </section>

      </div><div class="dt-side">
        <div class="dt-side-panel">
          <div class="dt-side-meta">
            <strong>카테고리</strong>${place.category}
          </div>
          <div class="dt-side-divider"></div>
          <div class="dt-side-meta">
            <strong>주소</strong>${place.address}
          </div>
          <c:if test="${not empty place.phoneNumber}">
            <div class="dt-side-divider"></div>
            <div class="dt-side-meta">
              <strong>문의</strong>${place.phoneNumber}
            </div>
          </c:if>
        </div>
      </div>

    </div></div></div><jsp:include page="../layout/footer.jsp" />

<script>
  const PLACE_DATA = {
    placeId: ${place.placeId},
    name: '${fn:escapeXml(place.placeName)}',
    address: '${fn:escapeXml(place.address)}',
    lat: ${not empty place.latitude ? place.latitude : 0},
    lng: ${not empty place.longitude ? place.longitude : 0},
    imageCount: ${fn:length(place.images) > 0 ? fn:length(place.images) : 1},
    contextPath: '${pageContext.request.contextPath}'
  };
</script>
<script src="${pageContext.request.contextPath}/dist/js/curation/place_detail.js"></script>