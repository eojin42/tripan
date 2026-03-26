<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<jsp:include page="../layout/header.jsp" />

<link rel="stylesheet" href="${pageContext.request.contextPath}/dist/css/curation/place_list.css">

<div class="pl-page">

  <aside class="pl-sidebar">
    <div class="pl-filter-header">
      <span class="pl-filter-title">검색필터</span>
      <button class="pl-filter-reset" onclick="resetFilters()">
        초기화
        <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor"
             stroke-width="2.5" stroke-linecap="round">
          <polyline points="1 4 1 10 7 10"/>
          <path d="M3.51 15a9 9 0 1 0 .49-3.5"/>
        </svg>
      </button>
    </div>

    <div class="pl-section-title">시/도</div>
    <div class="pl-region-grid" id="regionGrid">
      <button class="pl-region-btn ${region == '전체' || empty region ? 'active' : ''}"
              onclick="selectRegion(this, '전체')">전체</button>
      <c:forEach var="r" items="${regionList}">
        <button class="pl-region-btn ${r == region ? 'active' : ''}"
                onclick="selectRegion(this, '${r}')">${r}</button>
      </c:forEach>
    </div>
  </aside>

  <main class="pl-main">

    <div class="pl-topbar">
      <div class="pl-search-row">
        <div class="pl-search-box">
          <svg class="pl-search-ico" width="16" height="16" viewBox="0 0 24 24" fill="none"
               stroke="currentColor" stroke-width="2" stroke-linecap="round">
            <circle cx="11" cy="11" r="8"/>
            <line x1="21" y1="21" x2="16.65" y2="16.65"/>
          </svg>
          <input id="mainSearchInput" class="pl-search-input" type="text"
                 placeholder="장소명, 지역 검색"
                 value="${keyword}"
                 onkeyup="if(event.key==='Enter') fetchPlaces(true)">
          <button class="pl-search-btn" onclick="fetchPlaces(true)">검색</button>
        </div>
      </div>

      <div class="pl-cat-tabs" id="catTabs">
        <c:forEach var="cat" items="${categoryList}">
          <button class="pl-cat-tab ${cat.value == category ? 'active' : ''}"
                  onclick="selectCat(this, '${cat.value}')">${cat.label}</button>
        </c:forEach>
      </div>
    </div>

    <div class="pl-result-header">
      <div class="pl-result-count" id="resultCount">
        총 <em id="totalCount">${totalCount}</em>개의 장소
      </div>
      <div>
        <select class="pl-sort-select" id="sortSelect" onchange="fetchPlaces(true)">
          <option value="recent">최신순</option>
          <option value="views">조회순</option>
          <option value="likes">좋아요순</option>
        </select>
      </div>
    </div>
    <div class="pl-divider"></div>

    <div class="pl-grid" id="placeGrid">
      <c:choose>
        <c:when test="${not empty placeList}">
          <c:forEach var="p" items="${placeList}">
            <div class="pl-card" onclick="goDetail(${p.placeId})">

              <%-- 이미지가 있을 때만 이미지 영역 렌더링 --%>
              <c:if test="${not empty p.imageUrl}">
                <div class="pl-card-img-wrap">
                  <img class="pl-card-img"
                       src="${p.imageUrl}"
                       alt="${p.placeName}"
                       onerror="this.closest('.pl-card-img-wrap').style.display='none'">
                </div>
              </c:if>

              <div class="pl-card-body">
                <div class="pl-card-name">${p.placeName}</div>
                <div class="pl-card-loc">
                  <svg width="10" height="10" viewBox="0 0 24 24" fill="none"
                       stroke="#BDC7D3" stroke-width="2.5" stroke-linecap="round">
                    <path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z"/>
                    <circle cx="12" cy="10" r="3"/>
                  </svg>
                  ${p.address}
                </div>
                <div class="pl-card-stats">
                  <div class="pl-card-stat">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                      <path d="M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 0 0-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 0 0 0-7.78z"/>
                    </svg>
                    ${p.likeCount != null ? p.likeCount : 0}
                  </div>
                  <div class="pl-card-stat">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                      <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/>
                      <circle cx="12" cy="12" r="3"/>
                    </svg>
                    ${p.viewCount != null ? p.viewCount : 0}
                  </div>
                </div>
              </div>

            </div>
          </c:forEach>
        </c:when>
        <c:otherwise>
          <div class="pl-empty" id="emptyMsg">
            <div class="pl-empty-ico">🔍</div>
            <div class="pl-empty-msg">검색 결과가 없습니다</div>
          </div>
        </c:otherwise>
      </c:choose>
    </div>

    <div id="scrollSentinel" style="height:20px;"></div>
    <div id="loadingSpinner" class="pl-loading" style="display:none;">불러오는 중...</div>

  </main>
</div>

<jsp:include page="../layout/footer.jsp" />

<script>
  const PLACE_CONFIG = {
    contextPath:     '${pageContext.request.contextPath}',
    initialKeyword:  '${keyword}',
    initialCategory: '${category}',
    initialRegion:   '${region}'
  };
</script>
<script src="${pageContext.request.contextPath}/dist/js/curation/place_list.js"></script>
