<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"   uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt"  %>
<%@ taglib prefix="fn"  uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>${tripDto.tripName} - Tripan 워크스페이스</title>
  <%-- CSS 로드 순서 중요: responsive.css는 반드시 마지막 --%>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/dist/css/trip/trip.css">
  <link rel="preconnect" href="https://cdn.jsdelivr.net">
  <link href="https://cdn.jsdelivr.net/gh/orioncactus/pretendard/dist/web/variable/pretendardvariable.css" rel="stylesheet">
  <%-- WebSocket: SockJS + STOMP --%>
  <script src="https://cdn.jsdelivr.net/npm/sockjs-client@1/dist/sockjs.min.js"></script>
  <script src="https://cdn.jsdelivr.net/npm/stompjs@2.3.3/lib/stomp.min.js"></script>
  <%-- 카카오맵 SDK: appkey는 JSP EL로 주입, services·clusterer 함께 로드 --%>
  <script src="//dapi.kakao.com/v2/maps/sdk.js?appkey=${kakaoMapKey}&libraries=services,clusterer&autoload=false"></script>
</head>
<body>

<%-- ══════════ HTML ══════════ --%>

<%-- 탑바 --%>
<div class="ws-topbar">
  <a href="${pageContext.request.contextPath}/" class="ws-topbar__back" title="홈으로">
    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round"><line x1="19" y1="12" x2="5" y2="12"/><polyline points="12 19 5 12 12 5"/></svg>
  </a>

  <div class="ws-topbar__info">
    <%-- 썸네일 원형 이미지 --%>
    <c:if test="${not empty tripDto.thumbnailUrl}">
      <img class="ws-thumb-circle"
        src="${pageContext.request.contextPath}${tripDto.thumbnailUrl}"
        alt="${tripDto.tripName}"
        onerror="this.src='${pageContext.request.contextPath}/dist/images/logo.png'">
    </c:if>
    <c:if test="${empty tripDto.thumbnailUrl}">
      <img class="ws-thumb-circle"
        src="${pageContext.request.contextPath}/dist/images/logo.png"
        alt="${tripDto.tripName}">
    </c:if>
    <div class="ws-topbar__text-area">
    <div class="ws-topbar__title-wrap">
      <div class="ws-topbar__title">${tripDto.tripName}</div>
      <%-- 상태 배지 --%>
      <c:choose>
        <c:when test="${tripDto.status == 'ONGOING'}">
          <span class="trip-status-badge ongoing">✈️ 진행중</span>
        </c:when>
        <c:when test="${tripDto.status == 'COMPLETED'}">
          <span class="trip-status-badge completed">✅ 완료된 여행</span>
        </c:when>
        <c:otherwise>
          <span class="trip-status-badge planning">📋 계획중</span>
        </c:otherwise>
      </c:choose>
    </div>
    <div class="ws-topbar__sub">
      <%-- 도시 칩 (파랑 강조) --%>
      <c:if test="${not empty tripDto.cities}">
        <c:forEach var="city" items="${tripDto.cities}">
          <span class="ws-city-chip-em">${fn:escapeXml(city)}</span>
        </c:forEach>
      </c:if>
      <%-- 날짜+박수 하나로 합친 pill --%>
      <span class="ws-date-nights-pill">
        ${fn:replace(tripDto.startDate, '-', '.')} ~ ${fn:replace(tripDto.endDate, '-', '.')} &nbsp;·&nbsp; ${tripNights}
      </span>
      <%-- 상세 버튼 강조 --%>
      <button class="ws-detail-btn-v2" onclick="openModal('tripInfoModal')" title="여행 정보">
        <svg width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
        상세
      </button>
    </div>
    </div><%-- /ws-topbar__text-area --%>
  </div>

    <div class="ws-topbar__actions">
      <div class="live-badge">
        <span class="live-dot"></span>
        실시간 동기화
      </div>
      <%-- 저장 상태 표시 --%>
      <div id="wsSaveStatus" class="ws-save-status" data-state="connected">● 연결됨</div>

      <%-- [DB] trip_member 테이블 → role/invitation_status 기반 렌더 --%>
      <div class="avatar-group" title="동행자" onclick="openModal('memberModal')" style="cursor:pointer">
        <c:forEach var="m" items="${tripDto.members}">
          <c:choose>
            <c:when test="${m.role == 'OWNER'}">
              <div class="avatar role-owner" title="${m.nickname} (방장)">${fn:substring(m.nickname,0,2)}</div>
            </c:when>
            <c:when test="${m.invitationStatus == 'PENDING'}">
              <div class="avatar role-pending" title="${m.nickname} (초대 대기중)">${fn:substring(m.nickname,0,2)}</div>
            </c:when>
            <c:otherwise>
              <div class="avatar" title="${m.nickname} (편집자)">${fn:substring(m.nickname,0,2)}</div>
            </c:otherwise>
          </c:choose>
        </c:forEach>
        <div class="avatar avatar-add" onclick="event.stopPropagation();openModal('memberModal')" title="동행자 관리">+</div>
      </div>

      <%-- 뷰 토글 --%>
      <div class="view-toggle" id="viewToggle">
        <button class="view-toggle-btn" id="vBtn-edit" onclick="setViewMode('edit')" title="편집 전체 보기">
          <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round"><rect x="3" y="3" width="18" height="18" rx="2"/><line x1="3" y1="9" x2="21" y2="9"/><line x1="3" y1="15" x2="21" y2="15"/></svg>
          편집
        </button>
        <button class="view-toggle-btn active" id="vBtn-split" onclick="setViewMode('split')" title="분할 보기">
          <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round"><rect x="3" y="3" width="18" height="18" rx="2"/><line x1="12" y1="3" x2="12" y2="21"/></svg>
          분할
        </button>
        <button class="view-toggle-btn" id="vBtn-map" onclick="setViewMode('map')" title="지도 전체 보기">
          <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round"><polygon points="1 6 1 22 8 18 16 22 23 18 23 2 16 6 8 2 1 6"/><line x1="8" y1="2" x2="8" y2="18"/><line x1="16" y1="6" x2="16" y2="22"/></svg>
          지도
        </button>
      </div>

      <div class="ws-tabs">
        <button class="ws-tab active" onclick="switchPanel('schedule', this)">📅 일정</button>
        <button class="ws-tab" onclick="switchPanel('checklist', this)">✅ 체크</button>
        <button class="ws-tab" onclick="switchPanel('expense', this)">💸 가계부</button>
        <button class="ws-tab" onclick="switchPanel('vote', this)">🗳️ 투표</button>
      </div>

      <button class="notif-btn" id="notifBtn" onclick="toggleNotif()" title="알림">
        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9"/><path d="M13.73 21a2 2 0 0 1-3.46 0"/></svg>
        <span class="notif-dot" id="notifDot"></span>
      </button>
      <button class="btn-save" onclick="showToast('💾 저장되었어요!')">저장</button>
    </div>
</div>

<%-- 메인 레이아웃 --%>
<div class="ws-layout" id="wsLayout">

  <%-- ── 사이드바 ── --%>
  <aside class="ws-sidebar" id="wsSidebar">

    <%-- 리사이저 핸들 --%>
    <div class="ws-resizer" id="wsResizer" title="드래그로 크기 조절 / 더블클릭으로 초기화"></div>
	
	

    <%-- 일정 패널 --%>
    <div class="sidebar-panel active" id="panel-schedule">
      <div class="schedule-scroll" id="scheduleScroll">

        <%-- [DB] trip_day + itinerary_item --%>
        <c:forEach var="day" items="${tripDto.days}" varStatus="ds">
        <div class="day-section" id="day-${day.dayNumber}">
          <div class="day-header">
            <div class="day-badge">
              <span class="day-num">${day.dayNumber}</span>
              <span>DAY</span>
            </div>
            <span class="day-date">${day.tripDate}</span>
            <button class="btn-add-place" onclick="openAddPlace(${day.dayNumber})">+ 장소</button>
          </div>
          <div class="place-list" id="places-${day.dayNumber}"
               data-day="${day.dayNumber}"
               ondragover="onListDragOver(event)"
               ondrop="onListDrop(event)"
               ondragleave="onListDragLeave(event)">
            <c:forEach var="item" items="${day.items}" varStatus="is">
            <div class="place-card" draggable="true"
              data-day="${day.dayNumber}"
              data-id="${item.itemId}"
              data-order="${item.visitOrder}"
              data-name="${fn:escapeXml(item.placeName)}"
              data-memo="${fn:escapeXml(not empty item.memo ? item.memo : '')}"
              data-imgurl="${fn:escapeXml(not empty item.imageUrl ? item.imageUrl : '')}"
              data-images="[<c:forEach var='img' items='${item.images}' varStatus='s'>&quot;${fn:escapeXml(img.imageUrl)}&quot;<c:if test='${!s.last}'>,</c:if></c:forEach>]"
              data-address="${fn:escapeXml(not empty item.address ? item.address : '')}"
              data-category="${fn:escapeXml(not empty item.category ? item.category : 'ETC')}"
              data-lat="${not empty item.latitude ? item.latitude : 0}"
              data-lng="${not empty item.longitude ? item.longitude : 0}"
              ondragstart="onCardDragStart(event, this)"
              ondragend="onCardDragEnd(event, this)">
              <div class="place-num">${is.index + 1}</div>
              <div class="place-info">
				  <div class="place-name">${fn:escapeXml(item.placeName)}</div>
				  <c:if test="${not empty item.address}">
				    <div class="place-addr">${fn:escapeXml(item.address)}</div>
				  </c:if>
				  
				  <div class="place-chips" style="display: flex; align-items: center; gap: 6px; flex-wrap: wrap; margin-top: 4px;">
				    
				    <c:if test="${not empty item.category}">
				      <span class="place-type-badge">${item.category}</span>
				    </c:if>
				
				    <c:if test="${not empty item.startTime}">
				      <span class="place-chip time">⏰ ${item.startTime}</span>
				    </c:if>
				    <c:if test="${not empty item.memo}">
				      <span class="place-chip memo">📝 메모</span>
				    </c:if>
				    <c:if test="${not empty item.images && item.images.size() > 0}">
				      <span class="place-chip img">📷 사진 </span>
				    </c:if>
				  </div>
				</div>
              <div class="place-actions">
                <button class="place-action-btn" onclick="openMemo(this)" title="메모/사진">📝</button>
                <button class="place-action-btn" onclick="removePlace(this)" title="삭제">🗑</button>
              </div>
            </div>
            </c:forEach>
          </div>
          <div class="drop-zone"
               id="drop-${day.dayNumber}"
               data-day="${day.dayNumber}"
               onclick="openAddPlace(${day.dayNumber})"
               ondragover="onDropZoneDragOver(event)"
               ondragleave="onDropZoneDragLeave(event)"
               ondrop="onDropZoneDrop(event)">
            <span>+ 장소 추가 또는 드래그</span>
          </div>
        </div>
        </c:forEach>

      </div><%-- /schedule-scroll --%>
    </div><%-- /panel-schedule --%>

    <%-- 체크리스트 패널 --%>
    <div class="sidebar-panel" id="panel-checklist">
      <div class="checklist-panel-inner">

        <%-- 상단 헤더 --%>
        <div class="cl-top">
          <div class="checklist-header">
            <span class="checklist-title">✅ 여행 준비물</span>
            <button class="btn-add-check" onclick="openCheckModal()">+ 추가</button>
          </div>
          <div class="checklist-progress">
            <div class="checklist-progress-bar-bg">
              <div class="checklist-progress-bar" id="checkProgressBar" style="width:0%"></div>
            </div>
            <span class="checklist-progress-txt" id="checkProgressTxt">0 / 0 완료</span>
          </div>
        </div>

        <%-- 본문: JS 동적 렌더 --%>
        <div class="cl-body">
          <div class="check-categories-grid" id="checkGrid">
            <%-- 초기 빈 상태 --%>
            <div id="checkEmpty" style="grid-column:1/-1;text-align:center;padding:40px 20px;color:#A0AEC0;">
              <div style="font-size:36px;margin-bottom:10px;">📋</div>
              <div style="font-size:14px;font-weight:600;margin-bottom:4px;">준비물이 없어요</div>
              <div style="font-size:12px;">+ 추가 버튼으로 항목을 만들어보세요</div>
            </div>
          </div>
        </div>

      </div>
    </div>

    <%-- 가계부 패널 --%>
    <div class="sidebar-panel" id="panel-expense">
      <div class="expense-panel-inner">

        <%-- 총액 카드 [DB] expense 테이블 SUM --%>
        <div class="expense-summary">
          <div class="expense-summary__label">총 지출</div>
          <div class="expense-summary__amount" id="summaryAmt">₩ 0</div>
          <div class="expense-summary__split">${fn:length(tripDto.members)}인 기준</div>
          <div class="expense-summary__per" id="summaryPer">1인당 약 ₩ 0</div>
        </div>

        <%-- 카테고리별 지출 - JS 동적 렌더 --%>
        <div class="expense-cats" id="expenseCats">
          <%-- 초기: 로딩 상태 --%>
          <div class="expense-cat" style="grid-column:1/-1;justify-content:center;padding:16px;">
            <span style="color:#A0AEC0;font-size:13px;">로딩 중…</span>
          </div>
        </div>

        <%-- 최근 지출 내역 - JS로 동적 로드 (GET /api/trip/{tripId}/expense) --%>
        <div class="expense-section-head">
          <span class="expense-list-title">최근 지출 내역</span>
          <button class="expense-list-more" onclick="showToast('전체 내역 기능 준비 중')">전체 보기 →</button>
        </div>
        <div id="expenseList">
          <div class="expense-empty-msg" style="text-align:center;padding:20px;color:#999;font-size:13px">
            지출 내역을 불러오는 중...
          </div>
        </div>

        <button class="btn-add-expense" onclick="openModal('addExpenseModal')">
          <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
          지출 추가
        </button>

        <%-- 정산 현황 - JS로 동적 로드 (POST /api/trip/{tripId}/settlement/calculate) --%>
        <div class="settle-section">
          <div class="settle-head">
            <span class="settle-title">
              <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round"><line x1="12" y1="1" x2="12" y2="23"/><path d="M17 5H9.5a3.5 3.5 0 0 0 0 7h5a3.5 3.5 0 0 1 0 7H6"/></svg>
              정산 현황
            </span>
          </div>
          <div id="settleList">
            <div style="text-align:center;padding:16px;color:#999;font-size:13px">정산 내역을 불러오는 중...</div>
          </div>
        </div>

      </div>
    </div>

    <%-- 투표 패널 --%>
    <div class="sidebar-panel" id="panel-vote">
      <div class="vote-panel-inner">

        <div class="vote-panel-head">
          <span class="vote-panel-title">🗳️ 동행자 투표</span>
          <button class="btn-new-vote" onclick="openVoteModal()">+ 투표 만들기</button>
        </div>

        <%-- 빈 상태 / JS 동적 렌더 --%>
        <div class="vote-cards-grid" id="voteGrid">
          <div class="vote-empty-state">
            <div style="font-size:40px;margin-bottom:12px;">🗳️</div>
            <div style="font-size:14px;font-weight:700;color:#4A5568;margin-bottom:6px;">투표가 없어요</div>
            <div style="font-size:12px;line-height:1.6;">+ 투표 만들기로<br>동행자들의 의견을 모아보세요</div>
          </div>
        </div>

      </div>
    </div>

    <%-- 편집 모드: 좌측 추천 사이드바 --%>
    <div class="edit-recommend-panel" id="editRecommendPanel">
      <%-- 편집모드 추천 패널 리사이저 --%>
      <div class="edit-rp-resizer" id="editRpResizer" title="드래그로 크기 조절"></div>

      <%-- 헤더 + 검색바 + 탭 --%>
      <div class="rp-header">
      
        <div class="rp-searchbar">
          <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" style="flex-shrink:0;color:var(--light)"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
          <input type="text" class="rp-search-input" placeholder="장소 이름으로 검색…" id="rpSearchInput" oninput="searchRpCards(this.value)">
          <button class="rp-search-clear" id="rpSearchClear" onclick="clearRpSearch()" style="display:none">✕</button>
        </div>
        <div class="rp-tabs">
          <button class="rp-tab active" id="rpTab-suggest" onclick="switchRpTab('suggest',this)">추천 장소</button>
          <button class="rp-tab" id="rpTab-summary" onclick="switchRpTab('summary',this)">일정 요약</button>
          <button class="rp-tab" id="rpTab-weather" onclick="switchRpTab('weather',this); loadWeatherIfNeeded();">날씨</button>
        </div>
      </div>

      <%-- ── 탭: 추천 장소 ── --%>
      <div class="rp-pane active" id="rpPane-suggest">
        <div class="rp-filter">
          <button class="rp-filter-btn active" onclick="filterRec(this,'all')">전체</button>
          <button class="rp-filter-btn" onclick="filterRec(this,'RESTAURANT')">🍽 맛집</button>
          <button class="rp-filter-btn" onclick="filterRec(this,'ACCOMMODATION')">🏨 숙소</button>
          <button class="rp-filter-btn" onclick="filterRec(this,'TOUR')">🏔 관광</button>
          <button class="rp-filter-btn" onclick="filterRec(this,'CULTURE')">🎭 문화</button>
          <button class="rp-filter-btn" onclick="filterRec(this,'LEISURE')">🏄 레포츠</button>
          <button class="rp-filter-btn" onclick="filterRec(this,'SHOPPING')">🛍️ 쇼핑</button>
          <button class="rp-filter-btn" onclick="filterRec(this,'FESTIVAL')">🎉 축제</button>
        </div>

        <%-- ✅ 카드는 workspace.recommend.js가 동적 렌더 --%>
        <div class="rp-cards" id="rpCards">
          <div id="rpCardsLoading" style="text-align:center;padding:32px 20px;color:#A0AEC0;">
            <div style="font-size:32px;margin-bottom:8px;">🗺️</div>
            <div style="font-size:13px;">추천 장소를 불러오는 중...</div>
          </div>
        <div class="rp-no-result" id="rpNoResult" style="display:none;">검색 결과가 없어요 🔍</div>
        </div><%-- /rp-cards --%>
      </div><%-- /rp-pane active --%>

      <%-- ── 탭: 일정 요약 ── --%>
      <div class="rp-pane" id="rpPane-summary">
        <div class="rp-summary-wrap">
          <%-- Day별 타임라인 — JS renderDaySummary()로 채워짐 --%>
          <div class="rp-day-accordion" id="rpDayAccordion"></div>
        </div>
      </div>

      <%-- ── 탭: 날씨 ── --%>
      <div class="rp-pane" id="rpPane-weather">
        <%-- 날씨 v2: JS가 이 안에 검색창 + 지도 주입 --%>
      </div>

    </div><%-- /edit-recommend-panel --%>

    <%-- Day별 추가 선택 미니 팝업 --%>
    <div class="day-picker-popup" id="dayPickerPopup" style="display:none;">
      <div class="dpp-title">어느 날에 추가할까요?</div>
      <div class="dpp-days" id="dppDays">
        <c:forEach var="day" items="${tripDto.days}">
          <button class="dpp-btn" onclick="addRecToDay(${day.dayNumber})">DAY ${day.dayNumber}<br><span>${day.tripDate}</span></button>
        </c:forEach>
      </div>
      <button class="dpp-cancel" onclick="closeDayPicker()">취소</button>
    </div>

    <%-- 너비 상태바 --%>
    <div class="sidebar-width-bar">
      <span class="sidebar-width-label" id="sidebarWidthLabel">360px</span>
      <div class="sidebar-width-btns">
        <button class="sidebar-width-btn" onclick="setSidebarWidth(280)" title="좁게">좁게</button>
        <button class="sidebar-width-btn" onclick="setSidebarWidth(520)" title="기본">기본</button>
        <button class="sidebar-width-btn" onclick="setSidebarWidth(680)" title="넓게">넓게</button>
        <button class="sidebar-width-btn" onclick="setSidebarWidth(860)" title="최대">최대</button>
      </div>
    </div>

  </aside>

  <%-- ── 지도 영역 ── --%>
  <div class="ws-map-area">

    <%-- 지도 검색바 --%>
   <div class="map-search-bar">
      <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
      <input type="text" placeholder="장소, 주소 검색…" id="mapSearchInput" oninput="debounceMapSearch()" autocomplete="off">
      <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" style="color:var(--light);cursor:pointer" onclick="mapSearch()"><line x1="22" y1="2" x2="11" y2="13"/><polygon points="22 2 15 22 11 13 2 9 22 2"/></svg>
    </div>

    <ul id="mapSearchResults"></ul>
    
	<div id="kakaoMap" style="width:100%; height:100%; min-height:600px; position:relative; z-index:1;"></div>

    <%-- 지도 컨트롤 버튼 --%>
    <div class="map-overlay-controls">
      <button class="map-ctrl-btn" title="내 위치" onclick="mapMoveToMyLocation()">📍</button>
      <button class="map-ctrl-btn" title="전체 핀 보기" onclick="mapFitAll()">🗺️</button>
      <button class="map-ctrl-btn" title="확대" onclick="mapZoomIn()">+</button>
      <button class="map-ctrl-btn" title="축소" onclick="mapZoomOut()">−</button>
    </div>

    <%-- 범례 --%>
    <%-- ✅ 범례는 JS가 Day 수에 맞게 동적 렌더 --%>
    <div class="map-legend" id="mapLegend"></div>

  </div>
</div>

<%-- ══════════ MODALS ══════════ --%>

<%-- ✨ 추천 장소 모달 (기존 장소 추가 모달 리브랜딩) --%>
<div class="modal-overlay" id="addPlaceModal">
  <div class="modal-box" style="width:min(660px,96vw);">
    <div class="modal-box__head">
      <span class="modal-box__title">🏢 추천 장소</span>
      <button class="modal-close-btn" onclick="closeModal('addPlaceModal')">✕</button>
    </div>
    <div class="modal-box__body">
      
      <%-- 추천 안내 배너 --%>
      <div class="recommend-banner">
        <div class="recommend-banner-icon">✈️</div>
        <div class="recommend-banner-text">
          <strong>Tripan이 픽한 요즘 뜨는 핫플들을 모아봤어요!</strong>
          <span>찾으시는 장소가 안 보인다면, <b>상단 지도 검색창</b>에서 바로 추가할 수 있어요</span>
        </div>
      </div>

      <div class="place-type-tabs">
        <button class="place-type-tab active" onclick="selectPlaceType(this,'all')">🔍 전체</button>
        <button class="place-type-tab" onclick="selectPlaceType(this,'RESTAURANT')">🍽️ 맛집</button>
        <button class="place-type-tab" onclick="selectPlaceType(this,'ACCOMMODATION')">🏨 숙소</button>
        <button class="place-type-tab" onclick="selectPlaceType(this,'TOUR')">🏔️ 관광</button>
        <button class="place-type-tab" onclick="selectPlaceType(this,'CULTURE')">🎭 문화</button>
        <button class="place-type-tab" onclick="selectPlaceType(this,'LEISURE')">🏄 레포츠</button>
        <button class="place-type-tab" onclick="selectPlaceType(this,'SHOPPING')">🛍️ 쇼핑</button>
        <button class="place-type-tab" onclick="selectPlaceType(this,'my')">⭐ 나만의</button>
      </div>
      
      <div class="search-input-wrap">
        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
        <input type="text" placeholder="추천 장소 내에서 검색…" id="placeSearchInput" oninput="searchPlace(this.value)">
      </div>
      
      <div class="place-results" id="placeResults">
        <div style="text-align:center;padding:40px 20px;color:#A0AEC0;">
          <div style="font-size:32px;margin-bottom:10px;">✨</div>
          <div style="font-size:14px;font-weight:700;color:#4A5568;margin-bottom:4px;">카테고리를 선택해 보세요!</div>
          <div style="font-size:12px;">Tripan이 엄선한 멋진 장소들을 추천해 드립니다.</div>
        </div>
      </div>

    </div>
  </div>
</div>

<%-- ═══════════════════════════════════════════════════════
     환영 모달 (1회성) - workspace에 첫 진입 시만 표시
     showWelcome=true AND isOwner=true  → 여행 생성자 환영
     showWelcome=true AND isOwner=false → 초대받은 동행자 환영
═══════════════════════════════════════════════════════ --%>
<c:if test="${showWelcome}">
<div class="modal-overlay" id="welcomeModal" style="z-index:3000;">
  <div class="welcome-modal-box">
    <div class="welcome-modal-glow"></div>

    <%-- 여행 생성자 환영 --%>
    <c:if test="${isOwner}">
      <div class="welcome-icon">✈️</div>
      <h2 class="welcome-title">여행 만들기 완료!</h2>
      <p class="welcome-subtitle">
        <strong>${fn:escapeXml(tripDto.tripName)}</strong><br>
        여행 플랜이 만들어졌어요 🎉<br>
        지금 바로 일정을 채워보세요!
      </p>
      <div class="welcome-info-row">
        <span class="welcome-chip">📅 ${fn:substring(tripDto.startDate,0,10)} ~ ${fn:substring(tripDto.endDate,0,10)}</span>
        <span class="welcome-chip">🗺️ ${not empty tripDto.cities ? tripDto.cities[0] : '여행지'}</span>
      </div>
      <div class="welcome-tips">
        <div class="welcome-tip-item"><span>1</span> 왼쪽 패널에서 장소를 추가하세요</div>
        <div class="welcome-tip-item"><span>2</span> 지도에서 동선을 확인하세요</div>
        <div class="welcome-tip-item"><span>3</span> 초대 링크로 동행자를 불러오세요</div>
      </div>
    </c:if>

    <%-- 초대받은 동행자 환영 --%>
    <c:if test="${!isOwner}">
      <div class="welcome-icon">🎉</div>
      <h2 class="welcome-title">여행에 합류했어요!</h2>
      <p class="welcome-subtitle">
        <strong>${fn:escapeXml(tripDto.tripName)}</strong><br>
        여행에 초대됐어요 ✈️<br>
        함께 멋진 여행을 만들어보세요!
      </p>
      <div class="welcome-info-row">
        <span class="welcome-chip">📅 ${fn:substring(tripDto.startDate,0,10)} ~ ${fn:substring(tripDto.endDate,0,10)}</span>
        <span class="welcome-chip">👥 ${fn:length(tripDto.members)}명 동행</span>
      </div>
      <div class="welcome-tips">
        <div class="welcome-tip-item"><span>1</span> 일정을 확인하고 장소를 추가하세요</div>
        <div class="welcome-tip-item"><span>2</span> 체크리스트로 준비물을 챙기세요</div>
        <div class="welcome-tip-item"><span>3</span> 투표로 의견을 모아보세요</div>
      </div>
    </c:if>

    <button class="welcome-btn" onclick="closeWelcomeModal()">
      🚀 시작하기
    </button>
  </div>
</div>
</c:if>

<%-- 메모 & 첨부 모달 --%>
<%-- 메모 & 이미지 모달 --%>
<%-- 메모 & 이미지 모달 (View & Edit 겸용) --%>
<div class="modal-overlay" id="memoModal">
  <div class="modal-box" style="max-width: 420px; border-radius: 24px;">
    <div class="modal-box__head" style="border-bottom: none; padding-bottom: 10px;">
      <span class="modal-box__title" style="font-size: 18px; color: var(--dark);">✨ 장소 기록</span>
      <button class="modal-close-btn" onclick="closeModal('memoModal')">✕</button>
    </div>
    <div class="modal-box__body" style="padding-top: 0;">
      
      <%-- 장소명 헤더 --%>
      <div class="memo-modern-header">
        <span class="memo-icon">📍</span>
        <span id="memoPlaceName" class="memo-title-text">—</span>
      </div>
      <input type="hidden" id="memoItemId" value="">

      <%-- 텍스트 영역 --%>
      <div class="form-group" style="margin-bottom: 16px;">
        <textarea class="form-textarea modern-textarea" id="memoText"
          placeholder="이 장소에서의 기억이나 팁을 남겨보세요..."
          style="min-height: 90px;"></textarea>
      </div>

      <%-- 사진 썸네일 그리드 영역 --%>
      <div class="form-group" style="margin-bottom: 20px;">
        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 8px;">
          <label class="form-label-sm" style="margin-bottom: 0;">📸 사진</label>
          <label for="memoImgInput" class="btn-add-photo-sm">+ 추가</label>
        </div>
        
        <div class="memo-img-grid modern-grid" id="memoImgGrid">
        </div>
        <input type="file" id="memoImgInput" accept="image/*" multiple style="display:none" onchange="onMemoImgSelect(event)">
      </div>

      <button class="btn-primary" id="btnSaveMemo" onclick="saveMemo()" style="border-radius: 14px;">
        <span id="saveMemoTxt">기록 저장하기</span>
      </button>
    </div>
  </div>
</div>

<%-- 동행자 관리 모달 [DB] trip_member 테이블 --%>
<div class="modal-overlay" id="memberModal">
  <div class="modal-box">
    <div class="modal-box__head">
      <span class="modal-box__title">👥 동행자 관리</span>
      <button class="modal-close-btn" onclick="closeModal('memberModal')">✕</button>
    </div>
    <div class="modal-box__body">

      <%-- 현재 멤버 목록 --%>
      <label class="form-label-sm" style="margin-bottom:10px;display:block">현재 멤버 (${fn:length(tripDto.members)}명)</label>
      <div class="member-list">
        <c:forEach var="m" items="${tripDto.members}">
        <div class="member-row">
          <div class="member-avatar-lg
            <c:choose>
              <c:when test="${m.role == 'OWNER'}"> role-owner</c:when>
              <c:when test="${m.invitationStatus == 'PENDING'}"> role-pending</c:when>
            </c:choose>">${fn:substring(m.nickname,0,2)}</div>
          <div class="member-info">
            <div class="member-name">${m.nickname}</div>
            <div class="member-sub">
              <c:choose>
                <c:when test="${m.role == 'OWNER'}">나 · 방장</c:when>
                <c:when test="${m.invitationStatus == 'PENDING'}">${m.nickname} · 초대 대기 중</c:when>
                <c:otherwise>${m.nickname} · 편집자</c:otherwise>
              </c:choose>
            </div>
          </div>
          <c:choose>
            <c:when test="${m.role == 'OWNER'}">
              <span class="member-role-badge owner">👑 방장</span>
            </c:when>
            <c:when test="${m.invitationStatus == 'PENDING'}">
              <span class="member-role-badge pending">⏳ 대기중</span>
              <div class="member-actions">
                <button class="member-act-btn cancel" onclick="showToast('초대 취소됨')">취소</button>
              </div>
            </c:when>
            <c:otherwise>
              <span class="member-role-badge editor">✏️ 편집자</span>
              <div class="member-actions">
                <button class="member-act-btn change" onclick="showToast('권한 변경 기능 연동 예정')">권한</button>
                <button class="member-act-btn cancel" onclick="showToast('강퇴 기능 연동 예정')">강퇴</button>
              </div>
            </c:otherwise>
          </c:choose>
        </div>
        </c:forEach>
      </div>

      <div class="invite-divider">초대하기</div>

      <div class="invite-method">
        <button class="invite-btn" onclick="showToast('카카오톡 공유 연동 예정')">
          <span class="invite-icon">💬</span>카카오톡
        </button>
        <button class="invite-btn" onclick="copyInviteLink()">
          <span class="invite-icon">🔗</span>링크 복사
        </button>
        <button class="invite-btn" onclick="showToast('아이디 검색 연동 예정')">
          <span class="invite-icon">🔍</span>아이디 검색
        </button>
      </div>
      <label class="form-label-sm" style="margin-top:12px;display:block">초대 링크</label>
      <div class="invite-link-box" style="margin-top:6px">
		  <%-- 동적 URL 생성 (서버 도메인 + /trip/invite/ + 초대코드) --%>
		  <span id="inviteLinkText">${pageContext.request.scheme}://${pageContext.request.serverName}:${pageContext.request.serverPort}${pageContext.request.contextPath}/trip/invite/${tripDto.inviteCode}</span>
		  <button class="btn-copy" onclick="copyInviteLink()">복사</button>
	  </div>
      <p style="font-size:12px;color:var(--light);margin-top:10px;line-height:1.6;">
        링크를 클릭한 사람은 즉시 ACCEPTED로 참여돼요.<br>
        아이디 검색 초대는 상대방 수락 후 ACCEPTED 처리됩니다.
      </p>
    </div>
  </div>
</div>

<%-- ══════════════════════════════════════════════════
     여행 정보 상세 모달
════════════════════════════════════════════════== --%>
<div class="modal-overlay" id="tripInfoModal">
  <div class="modal-box" style="max-width:480px;">
    <div class="modal-box__head">
      <span class="modal-box__title">여행 정보</span>
      <button class="modal-close-btn" onclick="closeModal('tripInfoModal')">✕</button>
    </div>
    <div class="modal-box__body">

      <%-- ── 썸네일 + 제목/날짜 ── --%>
      <div class="trip-info-thumb-wrap">
        <img class="trip-info-thumb-circle"
          src="${not empty tripDto.thumbnailUrl ? pageContext.request.contextPath.concat(tripDto.thumbnailUrl) : pageContext.request.contextPath.concat('/dist/images/logo.png')}"
          alt="${tripDto.tripName}"
          onerror="this.src='${pageContext.request.contextPath}/dist/images/logo.png'">
        <div>
          <div class="trip-info-thumb-name">${fn:escapeXml(tripDto.tripName)}</div>
          <div class="trip-info-thumb-dates">
            ${fn:replace(tripDto.startDate, '-', '.')} ~ ${fn:replace(tripDto.endDate, '-', '.')}
            &nbsp;·&nbsp; ${tripNights}
          </div>
        </div>
      </div>

      <%-- ── 여행지 ── --%>
      <div class="trip-info-section">
        <div class="trip-info-label">여행지</div>
        <div class="trip-info-chips">
          <c:choose>
            <c:when test="${not empty tripDto.cities}">
              <c:forEach var="city" items="${tripDto.cities}">
                <span class="info-chip city-chip">${fn:escapeXml(city)}</span>
              </c:forEach>
            </c:when>
            <c:otherwise><span class="trip-info-empty">미설정</span></c:otherwise>
          </c:choose>
        </div>
      </div>

      <%-- ── 여행 유형 (뱃지) ── --%>
      <c:if test="${not empty tripDto.tripType}">
        <div class="trip-info-section">
          <div class="trip-info-label">여행 유형</div>
          <div class="trip-info-chips">
            <span class="info-chip type-chip">
              <c:choose>
                <c:when test="${tripDto.tripType == 'COUPLE'}">커플</c:when>
                <c:when test="${tripDto.tripType == 'FAMILY'}">가족</c:when>
                <c:when test="${tripDto.tripType == 'FRIENDS'}">친구</c:when>
                <c:when test="${tripDto.tripType == 'SOLO'}">혼자</c:when>
                <c:when test="${tripDto.tripType == 'BUSINESS'}">비즈니스</c:when>
              </c:choose>
            </span>
          </div>
        </div>
      </c:if>

      <%-- ── 테마 태그 ── --%>
      <c:if test="${not empty tripDto.tags}">
        <div class="trip-info-section">
          <div class="trip-info-label">여행 태그</div>
          <div class="trip-info-chips">
            <c:forEach var="tag" items="${tripDto.tags}">
              <span class="info-chip tag-chip">${fn:escapeXml(tag)}</span>
            </c:forEach>
          </div>
        </div>
      </c:if>

      <%-- ── 여행 설명 ── --%>
      <c:if test="${not empty tripDto.description}">
        <div class="trip-info-section">
          <div class="trip-info-label">여행 설명</div>
          <div class="trip-info-desc-box">
            <div class="trip-info-desc-text">${fn:escapeXml(tripDto.description)}</div>
          </div>
        </div>
      </c:if>

      <%-- ── 초대 코드 ── --%>
      <div class="trip-info-section">
        <div class="trip-info-label">초대 코드</div>
        <div class="trip-info-invite-code">${tripDto.inviteCode}</div>
      </div>

      <%-- ── 수정 버튼 ── --%>
      <button class="btn-trip-edit-open" onclick="closeModal('tripInfoModal'); openTripEditModal();">
        <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"/></svg>
        여행 정보 수정
      </button>
    </div>
  </div>
</div>

<%-- ══════════════════════════════════════════════════
     여행 수정 모달
════════════════════════════════════════════════== --%>
<div class="modal-overlay" id="tripEditModal">
  <div class="modal-box" style="max-width:520px;">
    <div class="modal-box__head">
      <span class="modal-box__title">여행 수정</span>
      <button class="modal-close-btn" onclick="closeModal('tripEditModal')">✕</button>
    </div>
    <div class="modal-box__body">

      <%-- 여행 제목 --%>
      <div class="edit-form-group">
        <label class="edit-form-label">여행 제목</label>
        <input type="text" id="editTripTitle" class="edit-form-input"
          value="${fn:escapeXml(tripDto.tripName)}" maxlength="30" placeholder="여행 제목을 입력하세요">
      </div>

      <%-- 여행 설명 --%>
      <div class="edit-form-group">
        <label class="edit-form-label">여행 설명 <span class="edit-form-opt">(선택)</span></label>
        <textarea id="editTripDesc" class="edit-form-textarea" maxlength="200"
          placeholder="이 여행에 대해 소개해 주세요">${fn:escapeXml(tripDto.description)}</textarea>
        <div class="edit-form-count"><span id="editDescCount">${fn:length(tripDto.description)}</span>/200</div>
      </div>

      <%-- 날짜 --%>
      <div class="edit-form-row">
        <div class="edit-form-group" style="flex:1;">
          <label class="edit-form-label">시작일</label>
          <input type="date" id="editStartDate" class="edit-form-input"
            value="${fn:substring(tripDto.startDate,0,10)}">
        </div>
        <div style="display:flex;align-items:flex-end;padding-bottom:10px;color:#A0AEC0;font-size:14px;">→</div>
        <div class="edit-form-group" style="flex:1;">
          <label class="edit-form-label">종료일</label>
          <input type="date" id="editEndDate" class="edit-form-input"
            value="${fn:substring(tripDto.endDate,0,10)}">
        </div>
      </div>
      <%-- 날짜 경고 메시지 --%>
      <div id="editDateWarning" class="edit-date-warning" style="display:none;"></div>

      <%-- 여행 유형 --%>
      <div class="edit-form-group">
        <label class="edit-form-label">여행 유형</label>
        <div class="edit-type-grid">
          <button class="edit-type-btn <c:if test='${tripDto.tripType == "COUPLE"}'>active</c:if>"
            onclick="selectEditType('COUPLE',this)">커플</button>
          <button class="edit-type-btn <c:if test='${tripDto.tripType == "FAMILY"}'>active</c:if>"
            onclick="selectEditType('FAMILY',this)">가족</button>
          <button class="edit-type-btn <c:if test='${tripDto.tripType == "FRIENDS"}'>active</c:if>"
            onclick="selectEditType('FRIENDS',this)">친구</button>
          <button class="edit-type-btn <c:if test='${tripDto.tripType == "SOLO"}'>active</c:if>"
            onclick="selectEditType('SOLO',this)">혼자</button>
          <button class="edit-type-btn <c:if test='${tripDto.tripType == "BUSINESS"}'>active</c:if>"
            onclick="selectEditType('BUSINESS',this)">비즈니스</button>
        </div>
        <input type="hidden" id="editTripType" value="${tripDto.tripType}">
      </div>

      <%-- 공개 여부 --%>
      <div class="edit-form-group">
        <label class="edit-form-label">공개 여부</label>
        <label class="edit-toggle-wrap">
          <input type="checkbox" id="editIsPublic" ${tripDto.isPublic == 1 ? 'checked' : ''}>
          <span class="edit-toggle-slider"></span>
          <span id="editPublicLabel" style="font-size:13px;font-weight:600;color:#4A5568;margin-left:10px;">
            ${tripDto.isPublic == 1 ? '공개 여행' : '비공개 여행'}
          </span>
        </label>
      </div>

      <%-- 저장 버튼 --%>
      <button class="btn-edit-save" id="btnEditSave" onclick="submitTripEdit()">
        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round"><polyline points="20 6 9 17 4 12"/></svg>
        저장하기
      </button>
    </div>
  </div>
</div>

<%-- ══════════════════════════════════════════════════
     체크리스트 항목 추가 모달
════════════════════════════════════════════════== --%>
<div class="modal-overlay" id="addCheckModal">
  <div class="modal-box" style="max-width:420px;">
    <div class="modal-box__head">
      <span class="modal-box__title">✅ 항목 추가</span>
      <button class="modal-close-btn" onclick="closeModal('addCheckModal')">✕</button>
    </div>
    <div class="modal-box__body">
      <div class="form-group" style="margin-bottom:14px;">
        <label class="form-label-sm">항목 이름 <span style="color:#FC8181">*</span></label>
        <input type="text" class="form-input" id="chk-itemName" placeholder="예: 여권, 충전기, 상비약…" maxlength="50">
      </div>
      <div class="form-group" style="margin-bottom:14px;">
        <label class="form-label-sm">카테고리</label>
        <div style="display:flex;gap:8px;align-items:center;">
          <select class="form-input" id="chk-category" style="flex:1;">
            <option value="필수품">🔑 필수품</option>
            <option value="의류">👗 의류</option>
            <option value="세면 & 화장품">🪞 세면 &amp; 화장품</option>
            <option value="비상약">💊 비상약</option>
            <option value="전자기기">📱 전자기기</option>
            <option value="기타">📦 기타</option>
          </select>
          <input type="text" class="form-input" id="chk-categoryNew" placeholder="직접 입력" style="flex:1;display:none;">
          <button class="btn-toggle-cat" id="btnToggleCat" onclick="toggleCustomCategory()">직접입력</button>
        </div>
      </div>
      <div class="form-group" style="margin-bottom:20px;">
        <label class="form-label-sm">담당자 <span style="font-weight:400;color:#A0AEC0">(선택)</span></label>
        <input type="text" class="form-input" id="chk-manager" placeholder="예: 나, 지민, 민준…" maxlength="20">
      </div>
      <button class="btn-primary" onclick="submitCheckItem()">추가하기</button>
    </div>
  </div>
</div>

<%-- ══════════════════════════════════════════════════
     투표 생성 모달
════════════════════════════════════════════════== --%>
<div class="modal-overlay" id="createVoteModal">
  <div class="modal-box" style="max-width:460px;">
    <div class="modal-box__head">
      <span class="modal-box__title">🗳️ 투표 만들기</span>
      <button class="modal-close-btn" onclick="closeModal('createVoteModal')">✕</button>
    </div>
    <div class="modal-box__body">
      <div class="form-group" style="margin-bottom:16px;">
        <label class="form-label-sm">투표 제목 <span style="color:#FC8181">*</span></label>
        <input type="text" class="form-input" id="vote-title"
          placeholder="예: Day2 저녁 어디서 먹을까요?" maxlength="100">
      </div>
      <div class="form-group" style="margin-bottom:8px;">
        <label class="form-label-sm">후보지 <span style="color:#A0AEC0;font-weight:400">(최소 2개, 최대 6개)</span></label>
      </div>
      <div id="voteOptions">
        <input type="text" class="form-input vote-opt-input" placeholder="후보 1" style="margin-bottom:8px">
        <input type="text" class="form-input vote-opt-input" placeholder="후보 2" style="margin-bottom:8px">
      </div>
      <button class="btn-add-vote-opt" onclick="addVoteOption()">+ 후보 추가</button>

      <%-- 마감일시 (선택) --%>
      <div class="form-group" style="margin-top:14px;margin-bottom:16px;">
        <label class="form-label-sm">마감일시 <span style="color:#A0AEC0;font-weight:400;">(선택)</span></label>
        <input type="datetime-local" class="form-input" id="vote-deadline"
          style="font-family:inherit;"
          min="${fn:substring(tripDto.startDate,0,10)}T00:00">
      </div>

      <button class="btn-primary" onclick="submitVote()">투표 만들기</button>
    </div>
  </div>
</div>

<%-- 지출 추가 모달 [DB] expense INSERT --%>
<div class="modal-overlay" id="addExpenseModal">
  <div class="modal-box expense-modal-box">
    <div class="modal-box__head">
      <span class="modal-box__title">💸 지출 추가</span>
      <button class="modal-close-btn" onclick="closeModal('addExpenseModal')">✕</button>
    </div>
    <div class="modal-box__body">

      <%-- 금액 + 항목명 --%>
      <div class="form-row">
        <div class="form-group">
          <label class="form-label-sm">항목명</label>
          <input type="text" class="form-input" placeholder="예: 흑돼지 맛집" id="exp-name">
        </div>
        <div class="form-group half">
          <label class="form-label-sm">금액 (₩)</label>
          <input type="number" class="form-input" placeholder="0" id="exp-amt">
        </div>
      </div>

      <%-- 카테고리 + 결제자 --%>
      <div class="form-row">
        <div class="form-group">
          <label class="form-label-sm">카테고리</label>
          <select class="form-select" id="exp-cat">
            <option value="FOOD">🍽️ 식비</option>
            <option value="ACCOMMODATION">🏨 숙소</option>
            <option value="TRANSPORT">🚗 교통</option>
            <option value="TOUR">🎯 관광</option>
            <option value="CAFE">☕ 카페</option>
            <option value="SHOPPING">🛍️ 쇼핑</option>
            <option value="ETC">📦 기타</option>
          </select>
        </div>
        <div class="form-group">
          <label class="form-label-sm">결제자 (payer)</label>
          <%-- [DB] trip_member 목록으로 동적 렌더 --%>
          <select class="form-select" id="exp-payer">
            <c:forEach var="m" items="${tripDto.members}">
              <c:if test="${m.invitationStatus == 'ACCEPTED' || m.role == 'OWNER'}">
                <option value="${m.memberId}">${m.nickname}</option>
              </c:if>
            </c:forEach>
          </select>
        </div>
      </div>

      <%-- 날짜 --%>
      <div class="form-group" style="margin-bottom:12px">
        <label class="form-label-sm">날짜</label>
        <input type="date" class="form-input" id="exp-date">
      </div>

      <%-- 🔒 나만 보기 [DB] expense.is_private --%>
      <div class="form-toggle-row">
        <div>
          <div class="form-toggle-label">🔒 나만 보기</div>
          <div class="form-toggle-sub">다른 동행자에게 이 지출이 표시되지 않아요</div>
        </div>
        <label class="toggle-switch">
          <input type="checkbox" id="exp-private">
          <span class="toggle-slider"></span>
        </label>
      </div>

      <button class="btn-primary" onclick="submitExpense()">지출 추가하기</button>
    </div>
  </div>
</div>

<%-- 이미지 전체화면 뷰어 --%>
<div class="modal-overlay" id="imageViewerModal" style="z-index: 9999; background: rgba(0,0,0,0.85); backdrop-filter: blur(5px);" onclick="closeImageViewer()">
  <button class="viewer-close-btn" onclick="closeImageViewer()" style="position: absolute; top: 20px; right: 20px; background: rgba(255,255,255,0.2); border: none; border-radius: 50%; width: 40px; height: 40px; color: white; font-size: 20px; cursor: pointer; display: flex; align-items: center; justify-content: center; transition: background 0.2s;">✕</button>
  <img id="viewerImage" src="" style="max-width: 90vw; max-height: 85vh; border-radius: 16px; object-fit: contain; cursor: zoom-out; box-shadow: 0 10px 40px rgba(0,0,0,0.5);">
</div>

<%-- 알림 dim --%>
<div class="notif-dd-dim" id="notifDim" onclick="closeNotif()"></div>

<%-- 알림 드롭다운 --%>
<div class="notif-dropdown" id="notifDropdown">
  <div class="notif-dd-head">
    <span class="notif-dd-title">🔔 알림</span>
    <button class="notif-dd-clear" onclick="clearAllNotif()">모두 읽음</button>
  </div>
  
  <%-- 🌟 중복 ID 제거 및 깔끔하게 통합 --%>
  <div class="notif-list" id="notifList">
    <div style="text-align:center;padding:20px;color:#999;font-size:13px">알림을 불러오는 중...</div>
  </div>
</div>


<%-- 토스트 --%>
<div class="toast-wrap" id="toastWrap"></div>



<%-- ════════════════════════════════════════
     전역 변수 주입 (JSP EL)
════════════════════════════════════════ --%>
<script>
var TRIP_ID          = ${tripId};
var CTX_PATH         = '${pageContext.request.contextPath}';
var SHOW_WELCOME     = ${showWelcome};
/* ★ 현재 로그인 유저 ID — workspace_vote.js에서 myVotedCandidateId 서버 조회에 사용 */
var LOGIN_MEMBER_ID  = ${loginMemberId != null ? loginMemberId : 'null'};
// 날씨 모듈용 여행 정보
var TRIP_START_DATE = '${fn:substring(tripDto.startDate,0,10)}';
var TRIP_END_DATE   = '${fn:substring(tripDto.endDate,0,10)}';
var TRIP_CITIES     = [];
<c:forEach var="city" items="${tripDto.cities}">
  TRIP_CITIES.push('${fn:escapeXml(city)}');
</c:forEach>
</script>

<%-- ════════════════════════════════════════
     JS 로드 순서 — ui.js 반드시 첫 번째
════════════════════════════════════════ --%>
<script src="${pageContext.request.contextPath}/dist/js/trip/workspace.ui.js"></script>
<script src="${pageContext.request.contextPath}/dist/js/trip/workspace.notif.js"></script>
<script src="${pageContext.request.contextPath}/dist/js/trip/workspace.schedule.js"></script>
<script src="${pageContext.request.contextPath}/dist/js/trip/workspace.checklist.js"></script>
<script src="${pageContext.request.contextPath}/dist/js/trip/workspace.vote.js"></script>
<script src="${pageContext.request.contextPath}/dist/js/trip/workspace.expense.js"></script>
<script src="${pageContext.request.contextPath}/dist/js/trip/workspace.weather.js"></script>
<script src="${pageContext.request.contextPath}/dist/js/trip/workspace.recommend.js"></script>
<script src="${pageContext.request.contextPath}/dist/js/trip/workspace.summary.js"></script>
<script src="${pageContext.request.contextPath}/dist/js/trip/workspace.welcome.js"></script>
<script src="${pageContext.request.contextPath}/dist/js/trip/workspace.map.js"></script>
<script src="${pageContext.request.contextPath}/dist/js/trip/workspace.trip.js"></script>

<%-- 카카오맵 데이터 주입 및 KTO --%>
<script>
// 컨텍스트 경로 및 KTO/카카오 장소 구분 상수
window.PLACE_TYPE = {
    OFFICIAL: 'OFFICIAL', // KTO 공식 데이터
    CUSTOM: 'CUSTOM'      // 나만의 장소 (카카오/유저)
};


var KAKAO_APP_KEY = '${kakaoMapKey}';
var KAKAO_CITIES = [];
<c:forEach var="city" items="${tripDto.cities}">
  KAKAO_CITIES.push('${fn:escapeXml(city)}');
</c:forEach>

var KAKAO_PLACES = [];
<c:forEach var="day" items="${tripDto.days}" varStatus="ds">
  <c:forEach var="item" items="${day.items}" varStatus="is">
    <c:if test="${not empty item.latitude and item.latitude != 0}">
      KAKAO_PLACES.push({
        dayNum   : ${day.dayNumber},
        itemId   : ${item.itemId},
        name     : '${fn:escapeXml(item.placeName)}',
        lat      : ${item.latitude},
        lng      : ${item.longitude},
        order    : ${is.index + 1},
        category : '${fn:escapeXml(not empty item.category ? item.category : "ETC")}',
        address  : '${fn:escapeXml(not empty item.address ? item.address : "")}'
      });
    </c:if>
  </c:forEach>
</c:forEach>

var KAKAO_DAY_NUMS = [];
<c:forEach var="day" items="${tripDto.days}">
  KAKAO_DAY_NUMS.push(${day.dayNumber});
</c:forEach>
</script>




<%-- 여행 편집 데이터 주입 (workspace.trip.js 가 읽음) --%>
<script>
/* ③ 여행 편집 초기값 */
var TRIP_META = {
  tripName:    '${fn:escapeXml(tripDto.tripName)}',
  description: '${fn:escapeXml(tripDto.description)}',
  tripType:    '${tripDto.tripType}',
  origStart:   '${fn:substring(tripDto.startDate,0,10)}',
  origEnd:     '${fn:substring(tripDto.endDate,0,10)}'
};
</script>

<%-- 동기화 토스트 (우상단) --%>
<div id="wsToast" class="ws-toast"></div>

<%-- WebSocket 클라이언트 --%>
<script src="${pageContext.request.contextPath}/dist/js/trip/workspace.ws.js"></script>
<script>
  /* MY_NICK: TripController.workspace()에서 loginNickname 모델로 전달 */
  var MY_NICK = '${fn:escapeXml(loginNickname)}';

  document.addEventListener('DOMContentLoaded', function() {
    wsConnect(TRIP_ID, CTX_PATH, MY_NICK);
  });
</script>
<jsp:include page="/WEB-INF/views/layout/footerResources.jsp" />
</body>
</html>
