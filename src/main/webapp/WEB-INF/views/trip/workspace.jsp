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
              data-name="${fn:escapeXml(item.placeName)}"
              data-memo="${fn:escapeXml(not empty item.memo ? item.memo : '')}"
              data-imgurl="${fn:escapeXml(not empty item.imageUrl ? item.imageUrl : '')}"
              ondragstart="onCardDragStart(event, this)"
              ondragend="onCardDragEnd(event, this)">
              <div class="place-num">${is.index + 1}</div>
              <div class="place-info">
                <div class="place-name">${fn:escapeXml(item.placeName)}</div>
                <c:if test="${not empty item.address}">
                  <div class="place-addr">${fn:escapeXml(item.address)}</div>
                </c:if>
                <div class="place-chips">
                  <c:if test="${not empty item.startTime}">
                    <span class="place-chip time">⏰ ${item.startTime}</span>
                  </c:if>
                  <c:if test="${not empty item.memo}">
                    <span class="place-chip memo">📝 메모</span>
                  </c:if>
                  <c:if test="${not empty item.imageUrl}">
                    <span class="place-chip img">🖼 사진</span>
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
          <div id="voteEmpty" style="text-align:center;padding:40px 20px;color:#A0AEC0;">
            <div style="font-size:36px;margin-bottom:10px;">🗳️</div>
            <div style="font-size:14px;font-weight:600;margin-bottom:4px;">투표가 없어요</div>
            <div style="font-size:12px;">+ 투표 만들기로 의견을 모아보세요</div>
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
          <button class="rp-tab" id="rpTab-weather" onclick="switchRpTab('weather',this)">날씨</button>
        </div>
      </div>

      <%-- ── 탭: 추천 장소 ── --%>
      <div class="rp-pane active" id="rpPane-suggest">
        <div class="rp-filter">
          <button class="rp-filter-btn active" onclick="filterRec(this,'all')">전체</button>
          <button class="rp-filter-btn" onclick="filterRec(this,'stay')">🏨 숙소</button>
          <button class="rp-filter-btn" onclick="filterRec(this,'tour')">🏔 관광</button>
          <button class="rp-filter-btn" onclick="filterRec(this,'eat')">🍽 맛집</button>
          <button class="rp-filter-btn" onclick="filterRec(this,'cafe')">☕ 카페</button>
        </div>

        <div class="rp-cards" id="rpCards">

          <div class="rp-card" data-cat="stay" data-name="스테이 밤편지">
            <div class="rp-card-img-wrap">
              <img class="rp-card-thumb-img" src="https://images.unsplash.com/photo-1566073771259-6a8506099945?w=400&q=80&auto=format&fit=crop" alt="스테이 밤편지" loading="lazy" onerror="this.style.display='none'">
              <span class="rp-card-cat-badge">🏨 숙소</span>
            </div>
            <div class="rp-card-info">
              <div class="rp-card-name">스테이 밤편지</div>
              <div class="rp-card-addr">서귀포 남원읍 · 오션뷰 독채</div>
              <div class="rp-card-meta-row">
                <span class="rp-meta-item">🕐 체크인 15:00</span>
                <span class="rp-meta-item">⏱ 1박</span>
              </div>
              <div class="rp-card-foot">
                <span class="rp-badge purple">🏨 숙소</span>
                <button class="rp-add-btn" onclick="event.stopPropagation();openAddToDay('스테이 밤편지','서귀포 남원읍')">+ 일정 추가</button>
              </div>
            </div>
          </div>
          <div class="rp-card" data-cat="stay" data-name="제주 한옥 스테이">
            <div class="rp-card-img-wrap">
              <img class="rp-card-thumb-img" src="https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=400&q=80&auto=format&fit=crop" alt="제주 한옥 스테이" loading="lazy" onerror="this.style.display='none'">
              <span class="rp-card-cat-badge">🏨 숙소</span>
            </div>
            <div class="rp-card-info">
              <div class="rp-card-name">제주 한옥 스테이</div>
              <div class="rp-card-addr">제주시 애월읍 · 한옥 감성</div>
              <div class="rp-card-meta-row">
                <span class="rp-meta-item">🕐 체크인 15:00</span>
                <span class="rp-meta-item">⏱ 1박</span>
              </div>
              <div class="rp-card-foot">
                <span class="rp-badge purple">🏨 숙소</span>
                <button class="rp-add-btn" onclick="event.stopPropagation();openAddToDay('제주 한옥 스테이','제주시 애월읍')">+ 일정 추가</button>
              </div>
            </div>
          </div>
          <div class="rp-card" data-cat="tour" data-name="한라산 영실 코스">
            <div class="rp-card-img-wrap">
              <img class="rp-card-thumb-img" src="https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?w=400&q=80&auto=format&fit=crop" alt="한라산 영실 코스" loading="lazy" onerror="this.style.display='none'">
              <span class="rp-card-cat-badge">🥾 트레킹</span>
            </div>
            <div class="rp-card-info">
              <div class="rp-card-name">한라산 영실 코스</div>
              <div class="rp-card-addr">서귀포시 · 영실~윗세오름</div>
              <div class="rp-card-meta-row">
                <span class="rp-meta-item">🕐 05:00~12:00</span>
                <span class="rp-meta-item">⏱ 3~4시간</span>
              </div>
              <div class="rp-card-foot">
                <span class="rp-badge blue">🥾 트레킹</span>
                <button class="rp-add-btn" onclick="event.stopPropagation();openAddToDay('한라산 영실 코스','서귀포시 해안동')">+ 일정 추가</button>
              </div>
            </div>
          </div>
          <div class="rp-card" data-cat="tour" data-name="협재해수욕장">
            <div class="rp-card-img-wrap">
              <img class="rp-card-thumb-img" src="https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=400&q=80&auto=format&fit=crop" alt="협재해수욕장" loading="lazy" onerror="this.style.display='none'">
              <span class="rp-card-cat-badge">🏖 해수욕</span>
            </div>
            <div class="rp-card-info">
              <div class="rp-card-name">협재해수욕장</div>
              <div class="rp-card-addr">제주시 한림읍 · 에메랄드 바다</div>
              <div class="rp-card-meta-row">
                <span class="rp-meta-item">🕐 연중무휴</span>
                <span class="rp-meta-item">⏱ 1~2시간</span>
              </div>
              <div class="rp-card-foot">
                <span class="rp-badge pink">🏖 해수욕</span>
                <button class="rp-add-btn" onclick="event.stopPropagation();openAddToDay('협재해수욕장','제주시 한림읍')">+ 일정 추가</button>
              </div>
            </div>
          </div>
          <div class="rp-card" data-cat="tour" data-name="비자림">
            <div class="rp-card-img-wrap">
              <img class="rp-card-thumb-img" src="https://images.unsplash.com/photo-1448375240586-882707db888b?w=400&q=80&auto=format&fit=crop" alt="비자림" loading="lazy" onerror="this.style.display='none'">
              <span class="rp-card-cat-badge">🌳 자연</span>
            </div>
            <div class="rp-card-info">
              <div class="rp-card-name">비자림</div>
              <div class="rp-card-addr">제주시 구좌읍 · 수령 500~800년</div>
              <div class="rp-card-meta-row">
                <span class="rp-meta-item">🕐 09:00~18:00</span>
                <span class="rp-meta-item">⏱ 1~2시간</span>
              </div>
              <div class="rp-card-foot">
                <span class="rp-badge green">🌳 자연</span>
                <button class="rp-add-btn" onclick="event.stopPropagation();openAddToDay('비자림','제주시 구좌읍')">+ 일정 추가</button>
              </div>
            </div>
          </div>
          <div class="rp-card" data-cat="tour" data-name="성산일출봉">
            <div class="rp-card-img-wrap">
              <img class="rp-card-thumb-img" src="https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?w=400&q=80&auto=format&fit=crop" alt="성산일출봉" loading="lazy" onerror="this.style.display='none'">
              <span class="rp-card-cat-badge">🏔 관광</span>
            </div>
            <div class="rp-card-info">
              <div class="rp-card-name">성산일출봉</div>
              <div class="rp-card-addr">서귀포시 성산읍 · 유네스코 세계유산</div>
              <div class="rp-card-meta-row">
                <span class="rp-meta-item">🕐 07:00~20:00</span>
                <span class="rp-meta-item">⏱ 1.5시간</span>
              </div>
              <div class="rp-card-foot">
                <span class="rp-badge blue">🏔 관광</span>
                <button class="rp-add-btn" onclick="event.stopPropagation();openAddToDay('성산일출봉','서귀포시 성산읍')">+ 일정 추가</button>
              </div>
            </div>
          </div>
          <div class="rp-card" data-cat="eat" data-name="돔베고기 연구소">
            <div class="rp-card-img-wrap">
              <img class="rp-card-thumb-img" src="https://images.unsplash.com/photo-1529543544282-ea669407fca3?w=400&q=80&auto=format&fit=crop" alt="돔베고기 연구소" loading="lazy" onerror="this.style.display='none'">
              <span class="rp-card-cat-badge">🍽 맛집</span>
            </div>
            <div class="rp-card-info">
              <div class="rp-card-name">돔베고기 연구소</div>
              <div class="rp-card-addr">제주시 연동 · 현지인 단골맛집</div>
              <div class="rp-card-meta-row">
                <span class="rp-meta-item">🕐 11:30~21:00 (월 휴무)</span>
                <span class="rp-meta-item">⏱ 1~1.5시간</span>
              </div>
              <div class="rp-card-foot">
                <span class="rp-badge pink">🍽 맛집</span>
                <button class="rp-add-btn" onclick="event.stopPropagation();openAddToDay('돔베고기 연구소','제주시 연동')">+ 일정 추가</button>
              </div>
            </div>
          </div>
          <div class="rp-card" data-cat="eat" data-name="갈치조림 골목">
            <div class="rp-card-img-wrap">
              <img class="rp-card-thumb-img" src="https://images.unsplash.com/photo-1498654896293-37aec27f0cf3?w=400&q=80&auto=format&fit=crop" alt="갈치조림 골목" loading="lazy" onerror="this.style.display='none'">
              <span class="rp-card-cat-badge">🍽 맛집</span>
            </div>
            <div class="rp-card-info">
              <div class="rp-card-name">갈치조림 골목</div>
              <div class="rp-card-addr">서귀포시 서홍동 · 제주 향토 해산물</div>
              <div class="rp-card-meta-row">
                <span class="rp-meta-item">🕐 11:00~21:00</span>
                <span class="rp-meta-item">⏱ 1시간</span>
              </div>
              <div class="rp-card-foot">
                <span class="rp-badge pink">🍽 맛집</span>
                <button class="rp-add-btn" onclick="event.stopPropagation();openAddToDay('갈치조림 골목','서귀포시 서홍동')">+ 일정 추가</button>
              </div>
            </div>
          </div>
          <div class="rp-card" data-cat="cafe" data-name="카페 이음">
            <div class="rp-card-img-wrap">
              <img class="rp-card-thumb-img" src="https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?w=400&q=80&auto=format&fit=crop" alt="카페 이음" loading="lazy" onerror="this.style.display='none'">
              <span class="rp-card-cat-badge">☕ 카페</span>
            </div>
            <div class="rp-card-info">
              <div class="rp-card-name">카페 이음</div>
              <div class="rp-card-addr">서귀포시 대정읍 · 마라도 오션뷰</div>
              <div class="rp-card-meta-row">
                <span class="rp-meta-item">🕐 10:00~19:00 (화 휴무)</span>
                <span class="rp-meta-item">⏱ 1~1.5시간</span>
              </div>
              <div class="rp-card-foot">
                <span class="rp-badge purple">☕ 카페</span>
                <button class="rp-add-btn" onclick="event.stopPropagation();openAddToDay('카페 이음','서귀포시 대정읍')">+ 일정 추가</button>
              </div>
            </div>
          </div>
          <div class="rp-card" data-cat="cafe" data-name="카페 숨비소리">
            <div class="rp-card-img-wrap">
              <img class="rp-card-thumb-img" src="https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=400&q=80&auto=format&fit=crop" alt="카페 숨비소리" loading="lazy" onerror="this.style.display='none'">
              <span class="rp-card-cat-badge">☕ 카페</span>
            </div>
            <div class="rp-card-info">
              <div class="rp-card-name">카페 숨비소리</div>
              <div class="rp-card-addr">서귀포시 성산읍 · 일출봉 뷰</div>
              <div class="rp-card-meta-row">
                <span class="rp-meta-item">🕐 09:00~18:00 (수 휴무)</span>
                <span class="rp-meta-item">⏱ 1시간</span>
              </div>
              <div class="rp-card-foot">
                <span class="rp-badge blue">☕ 카페</span>
                <button class="rp-add-btn" onclick="event.stopPropagation();openAddToDay('카페 숨비소리','서귀포시 성산읍')">+ 일정 추가</button>
              </div>
            </div>
          </div>
        <div class="rp-no-result" id="rpNoResult">검색 결과가 없어요 🔍</div>
        </div><%-- /rp-cards --%>
      </div>

      <%-- ── 탭: 일정 요약 ── --%>
      <div class="rp-pane" id="rpPane-summary">
        <div class="rp-summary-wrap">
          <%-- Day별 타임라인 — JS renderDaySummary()로 채워짐 --%>
          <div class="rp-day-accordion" id="rpDayAccordion"></div>
        </div>
      </div>

      <%-- ── 탭: 날씨 ── --%>
      <div class="rp-pane" id="rpPane-weather">
        <div class="rp-weather">

          <%-- 오늘(첫날) 메인 카드 --%>
          <div class="rp-weather-main">
            <div class="rp-weather-main-icon">🌤</div>
            <div class="rp-weather-main-info">
              <div class="rp-weather-main-city">📍 ${not empty tripDto.cities ? tripDto.cities[0] : '여행지'}</div>
              <div class="rp-weather-main-temp">14°</div>
              <div class="rp-weather-main-desc">구름 조금, 바람 약함</div>
            </div>
            <div class="rp-weather-main-side">
              <div class="rp-weather-main-hi">최고 17°</div>
              <div class="rp-weather-main-lo">최저 9°</div>
              <div class="rp-weather-main-rain">🌧 강수 10%</div>
            </div>
          </div>

          <%-- 4일 예보 --%>
          <div class="rp-weather-forecast">

            <div class="rp-weather-row">
              <span class="rp-wr-day">3/10 화</span>
              <span class="rp-wr-icon">🌤</span>
              <span class="rp-wr-desc">구름 조금</span>
              <span class="rp-wr-temp">17° <span>/ 9°</span></span>
              <span class="rp-rain-pill low">☔ 10%</span>
            </div>

            <div class="rp-weather-row">
              <span class="rp-wr-day">3/11 수</span>
              <span class="rp-wr-icon">⛅</span>
              <span class="rp-wr-desc">흐림</span>
              <span class="rp-wr-temp">13° <span>/ 8°</span></span>
              <span class="rp-rain-pill mid">☔ 20%</span>
            </div>

            <div class="rp-weather-row rp-weather-row--warn">
              <span class="rp-wr-day">3/12 목</span>
              <span class="rp-wr-icon">🌧</span>
              <span class="rp-wr-desc">비 예보</span>
              <span class="rp-wr-temp">11° <span>/ 7°</span></span>
              <span class="rp-rain-pill high">☔ 70%</span>
            </div>

            <div class="rp-weather-row">
              <span class="rp-wr-day">3/13 금</span>
              <span class="rp-wr-icon">🌤</span>
              <span class="rp-wr-desc">맑음</span>
              <span class="rp-wr-temp">15° <span>/ 10°</span></span>
              <span class="rp-rain-pill low">☔ 5%</span>
            </div>

          </div>
        </div>
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
      <input type="text" placeholder="장소, 주소 검색…" id="mapSearchInput">
      <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" style="color:var(--light);cursor:pointer" onclick="showToast('🗺️ 카카오맵 연동 후 검색 가능')"><line x1="22" y1="2" x2="11" y2="13"/><polygon points="22 2 15 22 11 13 2 9 22 2"/></svg>
    </div>

    <%-- 지도 컨테이너 (Kakao API 연동 전: 더미 지도) --%>
    <div id="kakaoMap">
      <div class="dummy-map">
        <%-- 더미 핀들 --%>
        <div class="map-pin" style="position:absolute;top:30%;left:35%">
          <div class="map-pin__bubble">1 공항</div>
          <div class="map-pin__tail"></div>
        </div>
        <div class="map-pin" style="position:absolute;top:55%;left:28%">
          <div class="map-pin__bubble" style="background:linear-gradient(135deg,#C2B8D9,#E0BBC2)">2 숙소</div>
          <div class="map-pin__tail" style="background:var(--orchid)"></div>
        </div>
        <div class="map-pin" style="position:absolute;top:42%;left:55%">
          <div class="map-pin__bubble">3 식당</div>
          <div class="map-pin__tail"></div>
        </div>
        <div class="map-pin" style="position:absolute;top:25%;left:65%">
          <div class="map-pin__bubble" style="background:linear-gradient(135deg,#C2B8D9,#E0BBC2)">Day2 성산일출봉</div>
          <div class="map-pin__tail" style="background:var(--orchid)"></div>
        </div>
        <div class="map-pin" style="position:absolute;top:65%;left:60%">
          <div class="map-pin__bubble" style="background:linear-gradient(135deg,#A8C8E1,#89CFF0)">Day3 우도</div>
          <div class="map-pin__tail" style="background:var(--ice)"></div>
        </div>
        <svg width="80" height="80" viewBox="0 0 24 24" fill="none" stroke="#A0AEC0" stroke-width="1"><circle cx="12" cy="10" r="3"/><path d="M12 21.7C17.3 17 20 13 20 10a8 8 0 1 0-16 0c0 3 2.7 6.9 8 11.7z"/></svg>
        <p>카카오맵 API 연동 후 실제 지도가 표시됩니다</p>
      </div>
    </div>

    <%-- 지도 컨트롤 버튼 --%>
    <div class="map-overlay-controls">
      <button class="map-ctrl-btn" title="내 위치" onclick="showToast('📍 내 위치 기능 연동 예정')">📍</button>
      <button class="map-ctrl-btn" title="전체 핀 보기" onclick="showToast('🗺️ 전체 경로 보기')">🗺️</button>
      <button class="map-ctrl-btn" title="확대" onclick="showToast('+')">+</button>
      <button class="map-ctrl-btn" title="축소" onclick="showToast('-')">−</button>
    </div>

    <%-- 범례 --%>
    <div class="map-legend">
      <div class="legend-item"><div class="legend-dot" style="background:linear-gradient(135deg,#89CFF0,#FFB6C1)"></div>Day 1</div>
      <div class="legend-item"><div class="legend-dot" style="background:linear-gradient(135deg,#C2B8D9,#E0BBC2)"></div>Day 2</div>
      <div class="legend-item"><div class="legend-dot" style="background:linear-gradient(135deg,#A8C8E1,#89CFF0)"></div>Day 3</div>
    </div>

  </div>
</div>

<%-- ══════════ MODALS ══════════ --%>

<%-- 장소 추가 모달 --%>
<div class="modal-overlay" id="addPlaceModal">
  <div class="modal-box">
    <div class="modal-box__head">
      <span class="modal-box__title">📍 장소 추가</span>
      <button class="modal-close-btn" onclick="closeModal('addPlaceModal')">✕</button>
    </div>
    <div class="modal-box__body">
      <div class="place-type-tabs">
        <button class="place-type-tab active" onclick="selectPlaceType(this,'all')">🔍 전체</button>
        <button class="place-type-tab" onclick="selectPlaceType(this,'eat')">🍽️ 맛집</button>
        <button class="place-type-tab" onclick="selectPlaceType(this,'tour')">🏔️ 관광</button>
        <button class="place-type-tab" onclick="selectPlaceType(this,'stay')">🏨 숙소</button>
        <button class="place-type-tab" onclick="selectPlaceType(this,'my')">⭐ 나만의</button>
      </div>
      <div class="search-input-wrap">
        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
        <input type="text" placeholder="장소명, 주소 검색…" id="placeSearchInput" oninput="searchPlace(this.value)">
      </div>
      <div class="place-results" id="placeResults">
        <div class="place-result-item" onclick="addPlaceToDay(this, '협재해수욕장', '제주시 한림읍')">
          <div class="place-result-icon">🏖️</div>
          <div><div class="place-result-name">협재해수욕장</div><div class="place-result-addr">제주시 한림읍 협재리</div></div>
        </div>
        <div class="place-result-item" onclick="addPlaceToDay(this, '한라산 어리목 코스', '제주시 해안동')">
          <div class="place-result-icon">🏔️</div>
          <div><div class="place-result-name">한라산 어리목 코스</div><div class="place-result-addr">제주시 해안동</div></div>
        </div>
        <div class="place-result-item" onclick="addPlaceToDay(this, '제주 올레시장', '제주시 이도2동')">
          <div class="place-result-icon">🛒</div>
          <div><div class="place-result-name">제주 올레시장</div><div class="place-result-addr">제주시 이도2동</div></div>
        </div>
        <div class="place-result-item" onclick="addPlaceToDay(this, '카페 봄날', '서귀포시 중문동')">
          <div class="place-result-icon">☕</div>
          <div><div class="place-result-name">카페 봄날</div><div class="place-result-addr">서귀포시 중문동</div></div>
        </div>
      </div>
    </div>
  </div>
</div>

<%-- 메모 & 첨부 모달 --%>
<%-- 메모 & 이미지 모달 --%>
<div class="modal-overlay" id="memoModal">
  <div class="modal-box" style="max-width:460px;">
    <div class="modal-box__head">
      <span class="modal-box__title">📝 메모 & 사진</span>
      <button class="modal-close-btn" onclick="closeModal('memoModal')">✕</button>
    </div>
    <div class="modal-box__body">
      <%-- 장소명 --%>
      <div style="font-size:13px;font-weight:800;color:#4A5568;margin-bottom:12px;padding:8px 12px;background:#F8FAFC;border-radius:8px;border-left:3px solid #89CFF0;" id="memoPlaceName">—</div>
      <input type="hidden" id="memoItemId" value="">

      <%-- 메모 입력 --%>
      <div class="form-group" style="margin-bottom:14px;">
        <label class="form-label-sm">메모</label>
        <textarea class="form-textarea" id="memoText"
          placeholder="브레이크타임 주의, 예약 필수, 주차 가능 등 메모를 입력하세요…"
          style="min-height:80px;"></textarea>
      </div>

      <%-- 이미지 업로드 --%>
      <div class="form-group" style="margin-bottom:16px;">
        <label class="form-label-sm">사진 첨부 <span style="font-weight:400;color:#A0AEC0">(최대 3장 · JPG/PNG/WEBP · 5MB)</span></label>
        <div class="memo-img-grid" id="memoImgGrid">
          <%-- JS로 렌더 --%>
        </div>
        <input type="file" id="memoImgInput" accept="image/*" multiple style="display:none" onchange="onMemoImgSelect(event)">
      </div>

      <button class="btn-primary" id="btnSaveMemo" onclick="saveMemo()">
        <span id="saveMemoTxt">저장</span>
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
        <span id="inviteLinkText">https://tripan.kr/invite/abc123xyz</span>
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
            <option value="서류 & 결제">📋 서류 &amp; 결제</option>
            <option value="의류 & 용품">👗 의류 &amp; 용품</option>
            <option value="의약품">💊 의약품</option>
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
        <label class="form-label-sm">후보지 <span style="color:#A0AEC0;font-weight:400">(최소 2개)</span></label>
      </div>
      <div id="voteOptions">
        <input type="text" class="form-input vote-opt-input" placeholder="후보 1" style="margin-bottom:8px">
        <input type="text" class="form-input vote-opt-input" placeholder="후보 2" style="margin-bottom:8px">
      </div>
      <button class="btn-add-vote-opt" onclick="addVoteOption()">+ 후보 추가</button>
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
        <input type="date" class="form-input" id="exp-date" value="2026-03-10">
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

<%-- 알림 dim --%>
<div class="notif-dd-dim" id="notifDim" onclick="closeNotif()"></div>

<%-- 알림 드롭다운 --%>
<div class="notif-dropdown" id="notifDropdown">
  <div class="notif-dd-head">
    <span class="notif-dd-title">🔔 알림</span>
    <button class="notif-dd-clear" onclick="clearAllNotif()">모두 읽음</button>
  </div>
  <div class="notif-list" id="notifList">

    <%-- 알림 목록 - JS에서 동적 렌더 --%>
    <div id="notifList">
      <div style="text-align:center;padding:20px;color:#999;font-size:13px">알림을 불러오는 중...</div>
    </div>

  </div>
</div>

<%-- 토스트 --%>
<div class="toast-wrap" id="toastWrap"></div>



<%-- ══════════════════════════════════════════════════
     JS: TRIP_ID, 체크리스트, 투표, 알림, 가계부
════════════════════════════════════════════════== --%>
<script>
var TRIP_ID  = ${tripId};
var CTX_PATH = '${pageContext.request.contextPath}';

/* ══════════════════════════════════════════════
   페이지 로드
══════════════════════════════════════════════ */
document.addEventListener('DOMContentLoaded', function() {
  loadExpenseList();
  loadChecklist();
  loadVotes();
  loadNotifList();
});

/* ══════════════════════════════════════════════
   📝 메모 & 이미지 (장소별)
══════════════════════════════════════════════ */
var _memoImages = [];  // { base64: '...', file: File }

function openMemo(btn) {
  var card = btn.closest('.place-card');
  var itemId   = card.dataset.id   || '';
  var itemName = card.dataset.name || '장소';
  var memo     = card.dataset.memo || '';
  var imgUrl   = card.dataset.imgurl || '';

  document.getElementById('memoItemId').value  = itemId;
  document.getElementById('memoPlaceName').textContent = itemName;
  document.getElementById('memoText').value    = memo;
  _memoImages = [];
  renderMemoImgGrid(imgUrl ? [{ src: imgUrl, existing: true }] : []);
  openModal('memoModal');
}

function renderMemoImgGrid(imgs) {
  var grid = document.getElementById('memoImgGrid');
  var html = '';
  imgs.forEach(function(img, idx) {
    var src = img.base64 || img.src || '';
    html += '<div style="position:relative;">'
      + '<img src="' + src + '" class="memo-img-thumb" onclick="previewMemoImg('' + src + '')">'
      + '<button onclick="removeMemoImg(' + idx + ')" style="position:absolute;top:2px;right:2px;width:20px;height:20px;border-radius:50%;background:#FC8181;border:1.5px solid white;color:white;font-size:10px;font-weight:700;cursor:pointer;display:flex;align-items:center;justify-content:center;">✕</button>'
      + '</div>';
  });
  if (imgs.length < 3) {
    html += '<div class="memo-img-add" onclick="document.getElementById('memoImgInput').click()">'
      + '<span style="font-size:22px;">📷</span><span>추가</span></div>';
  }
  grid.innerHTML = html;
}

function onMemoImgSelect(event) {
  var files = Array.from(event.target.files);
  var remain = 3 - _memoImages.length;
  files.slice(0, remain).forEach(function(file) {
    if (file.size > 5 * 1024 * 1024) { showToast('⚠️ 5MB 이하 이미지만 가능해요'); return; }
    var reader = new FileReader();
    reader.onload = function(e) {
      _memoImages.push({ base64: e.target.result, file: file });
      renderMemoImgGrid(_memoImages);
    };
    reader.readAsDataURL(file);
  });
  event.target.value = '';
}

function removeMemoImg(idx) {
  _memoImages.splice(idx, 1);
  renderMemoImgGrid(_memoImages);
}

function previewMemoImg(src) {
  window.open(src, '_blank');
}

function saveMemo() {
  var itemId = document.getElementById('memoItemId').value;
  var memo   = document.getElementById('memoText').value.trim();
  if (!itemId) { showToast('⚠️ 저장할 장소가 없어요'); return; }

  var btnTxt = document.getElementById('saveMemoTxt');
  btnTxt.textContent = '저장 중…';

  var imageBase64 = _memoImages.length > 0 ? _memoImages[0].base64 : null;

  fetch(CTX_PATH + '/api/itinerary/' + itemId + '/memo', {
    method: 'PATCH',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ memo: memo, imageBase64: imageBase64 })
  })
  .then(function(r) { return r.ok ? r.json() : Promise.reject(r.status); })
  .then(function(data) {
    btnTxt.textContent = '저장';
    if (data.success) {
      // 카드의 data 속성 업데이트
      var card = document.querySelector('.place-card[data-id="' + itemId + '"]');
      if (card) {
        card.dataset.memo   = memo;
        card.dataset.imgurl = data.imageUrl || '';
        // 칩 업데이트
        var chips = card.querySelector('.place-chips');
        var memoChip = chips.querySelector('.place-chip.memo');
        var imgChip  = chips.querySelector('.place-chip.img');
        if (memo && !memoChip) chips.insertAdjacentHTML('beforeend', '<span class="place-chip memo">📝 메모</span>');
        if (!memo && memoChip) memoChip.remove();
        if (data.imageUrl && !imgChip) chips.insertAdjacentHTML('beforeend', '<span class="place-chip img">🖼 사진</span>');
        if (!data.imageUrl && imgChip) imgChip.remove();
      }
      closeModal('memoModal');
      showToast('✅ 메모가 저장됐어요');
    } else {
      showToast('⚠️ ' + (data.message || '저장 실패'));
    }
  })
  .catch(function(err) {
    btnTxt.textContent = '저장';
    showToast('⚠️ 서버 오류 (' + err + ')');
  });
}

/* ══════════════════════════════════════════════
   ✅ 체크리스트
══════════════════════════════════════════════ */
function loadChecklist() {
  fetch(CTX_PATH + '/api/trip/' + TRIP_ID + '/checklist')
    .then(function(r) { return r.ok ? r.json() : Promise.reject(r.status); })
    .then(function(list) { renderChecklist(list); })
    .catch(function() {
      document.getElementById('checkGrid').innerHTML =
        '<div style="grid-column:1/-1;text-align:center;padding:20px;color:#bbb;font-size:13px">체크리스트를 불러오지 못했어요</div>';
    });
}

function renderChecklist(list) {
  var grid = document.getElementById('checkGrid');
  if (!list || list.length === 0) {
    grid.innerHTML = '<div id="checkEmpty" style="grid-column:1/-1;text-align:center;padding:40px 20px;color:#A0AEC0;">'
      + '<div style="font-size:36px;margin-bottom:10px;">📋</div>'
      + '<div style="font-size:14px;font-weight:600;margin-bottom:4px;">준비물이 없어요</div>'
      + '<div style="font-size:12px;">+ 추가 버튼으로 항목을 만들어보세요</div></div>';
    updateCheckProgress(0, 0);
    return;
  }

  // 카테고리별 그룹핑
  var groups = {};
  list.forEach(function(item) {
    var cat = item.category || '기타';
    if (!groups[cat]) groups[cat] = [];
    groups[cat].push(item);
  });

  var total = list.length;
  var checked = list.filter(function(i) { return i.isChecked === 1 || i.isChecked === true; }).length;
  updateCheckProgress(checked, total);

  var catEmoji = {
    '서류 & 결제': '📋', '의류 & 용품': '👗', '의약품': '💊',
    '전자기기': '📱', '기타': '📦'
  };

  var html = '';
  Object.keys(groups).forEach(function(cat) {
    var emoji = catEmoji[cat] || '📦';
    html += '<div class="check-category" id="cat-' + encodeURIComponent(cat) + '">'
      + '<div class="check-cat-label">'
      + '<span class="check-cat-label-left">' + emoji + ' ' + cat + '</span>'
      + '</div>';
    groups[cat].forEach(function(item) {
      var done = (item.isChecked === 1 || item.isChecked === true) ? ' done' : '';
      var mgrHtml = item.checkManager
        ? '<span class="check-by">' + item.checkManager + '</span>' : '';
      html += '<div class="check-item' + done + '" id="ci-' + item.checklistId + '">'
        + '<input type="checkbox" id="chk' + item.checklistId + '"'
        + (done ? ' checked' : '')
        + ' onchange="toggleCheckItem(' + item.checklistId + ',this)">'
        + '<label for="chk' + item.checklistId + '">' + item.itemName + '</label>'
        + mgrHtml
        + '<button class="check-item-del" onclick="event.stopPropagation();deleteCheckItem(' + item.checklistId + ')" title="삭제">✕</button>'
        + '</div>';
    });
    html += '</div>';
  });

  // 카테고리 추가 버튼
  html += '<button class="check-category-add-card" onclick="openCheckModal()">'
    + '<span style="font-size:22px">+</span><span>항목 추가</span></button>';
  grid.innerHTML = html;
}

function updateCheckProgress(checked, total) {
  var pct = total === 0 ? 0 : Math.round(checked / total * 100);
  document.getElementById('checkProgressBar').style.width = pct + '%';
  document.getElementById('checkProgressTxt').textContent = checked + ' / ' + total + ' 완료';
}

function openCheckModal() {
  document.getElementById('chk-itemName').value = '';
  document.getElementById('chk-manager').value = '';
  document.getElementById('chk-category').value = '서류 & 결제';
  document.getElementById('chk-categoryNew').style.display = 'none';
  document.getElementById('chk-category').style.display = '';
  openModal('addCheckModal');
}

function toggleCustomCategory() {
  var sel = document.getElementById('chk-category');
  var inp = document.getElementById('chk-categoryNew');
  var btn = document.getElementById('btnToggleCat');
  if (inp.style.display === 'none') {
    inp.style.display = ''; sel.style.display = 'none';
    inp.focus(); if(btn){btn.textContent='선택으로';btn.classList.add('active');}
  } else {
    inp.style.display = 'none'; sel.style.display = '';
    if(btn){btn.textContent='직접입력';btn.classList.remove('active');}
  }
}

function submitCheckItem() {
  var itemName = document.getElementById('chk-itemName').value.trim();
  if (!itemName) { alert('항목 이름을 입력해주세요'); return; }

  var selEl = document.getElementById('chk-category');
  var newEl = document.getElementById('chk-categoryNew');
  var category = (newEl.style.display !== 'none' && newEl.value.trim())
    ? newEl.value.trim() : selEl.value;
  var manager = document.getElementById('chk-manager').value.trim();

  fetch(CTX_PATH + '/api/trip/' + TRIP_ID + '/checklist', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ itemName: itemName, category: category, checkManager: manager || null })
  })
  .then(function(r) { return r.json(); })
  .then(function(data) {
    if (data.success) {
      closeModal('addCheckModal');
      loadChecklist();
      showToast('✅ ' + itemName + ' 추가됨!');
    } else {
      alert(data.message || '추가 실패');
    }
  })
  .catch(function() { alert('서버 오류가 발생했어요'); });
}

function toggleCheckItem(checklistId, checkbox) {
  var row = document.getElementById('ci-' + checklistId);
  if (row) row.classList.toggle('done', checkbox.checked);

  // 낙관적 업데이트 후 서버 동기화
  fetch(CTX_PATH + '/api/trip/' + TRIP_ID + '/checklist/' + checklistId + '/toggle', {
    method: 'PATCH'
  })
  .then(function(r) { return r.json(); })
  .then(function() { loadChecklist(); })
  .catch(function() { loadChecklist(); }); // 실패시 롤백
}

function deleteCheckItem(checklistId) {
  if (!confirm('항목을 삭제할까요?')) return;
  fetch(CTX_PATH + '/api/trip/' + TRIP_ID + '/checklist/' + checklistId, {
    method: 'DELETE'
  })
  .then(function() { loadChecklist(); showToast('🗑 항목이 삭제됐어요'); });
}

/* ══════════════════════════════════════════════
   🗳️ 투표
══════════════════════════════════════════════ */
function loadVotes() {
  fetch(CTX_PATH + '/api/trip/' + TRIP_ID + '/vote')
    .then(function(r) { return r.ok ? r.json() : Promise.reject(r.status); })
    .then(function(rows) { renderVotes(rows); })
    .catch(function() {
      document.getElementById('voteGrid').innerHTML =
        '<div style="text-align:center;padding:20px;color:#bbb;font-size:13px">투표를 불러오지 못했어요</div>';
    });
}

function renderVotes(rows) {
  var grid = document.getElementById('voteGrid');
  if (!rows || rows.length === 0) {
    grid.innerHTML = '<div id="voteEmpty" style="text-align:center;padding:40px 20px;color:#A0AEC0;">'
      + '<div style="font-size:36px;margin-bottom:10px;">🗳️</div>'
      + '<div style="font-size:14px;font-weight:600;margin-bottom:4px;">투표가 없어요</div>'
      + '<div style="font-size:12px;">+ 투표 만들기로 의견을 모아보세요</div></div>';
    return;
  }

  // voteId 기준으로 그룹핑 (서버에서 candidate별 row 반환)
  var votes = {};
  rows.forEach(function(r) {
    if (!votes[r.voteId]) {
      votes[r.voteId] = { voteId: r.voteId, title: r.title, totalVotes: r.totalVotes, candidates: [] };
    }
    votes[r.voteId].candidates.push(r);
  });

  var html = '';
  Object.values(votes).forEach(function(v) {
    var total = parseInt(v.totalVotes) || 0;
    html += '<div class="vote-card">'
      + '<div class="vote-card__emoji">🗳️</div>'
      + '<div class="vote-card__title">' + v.title + '</div>'
      + '<div class="vote-card__sub"><span>' + total + '명 참여</span></div>';

    v.candidates.forEach(function(c) {
      var cnt = parseInt(c.voteCount) || 0;
      var pct = total === 0 ? 0 : Math.round(cnt / total * 100);
      html += '<div class="vote-option">'
        + '<div class="vote-option__top">'
        + '<span class="vote-option__name">' + c.candidateName + '</span>'
        + '<span class="vote-option__pct">' + pct + '%</span>'
        + '</div>'
        + '<div class="vote-bar-bg"><div class="vote-bar-fill" style="width:' + pct + '%"></div></div>'
        + '</div>';
    });

    html += '<div class="vote-card__divider"></div>'
      + '<div style="display:flex;gap:6px;flex-wrap:wrap;">';
    v.candidates.forEach(function(c) {
      html += '<button class="btn-vote" style="flex:1;font-size:12px;"'
        + ' onclick="castVote(' + v.voteId + ',' + c.candidateId + ',this)">'
        + c.candidateName + '</button>';
    });
    html += '</div>'
      + '<button class="btn-vote" style="background:transparent;color:#FC8181;border:1px solid #FED7D7;font-size:11px;margin-top:6px;"'
      + ' onclick="deleteVote(' + v.voteId + ')">🗑 투표 삭제</button>'
      + '</div>';
  });

  grid.innerHTML = html;
}

function openVoteModal() {
  document.getElementById('vote-title').value = '';
  var opts = document.getElementById('voteOptions');
  opts.innerHTML = '<input type="text" class="form-input vote-opt-input" placeholder="후보 1" style="margin-bottom:8px">'
    + '<input type="text" class="form-input vote-opt-input" placeholder="후보 2" style="margin-bottom:8px">';
  openModal('createVoteModal');
}

function addVoteOption() {
  var opts = document.getElementById('voteOptions');
  var count = opts.querySelectorAll('.vote-opt-input').length + 1;
  var inp = document.createElement('input');
  inp.type = 'text'; inp.className = 'form-input vote-opt-input';
  inp.placeholder = '후보 ' + count; inp.style.marginBottom = '8px';
  opts.appendChild(inp);
}

function submitVote() {
  var title = document.getElementById('vote-title').value.trim();
  if (!title) { alert('투표 제목을 입력해주세요'); return; }

  var candidates = Array.from(document.querySelectorAll('.vote-opt-input'))
    .map(function(i) { return i.value.trim(); })
    .filter(function(v) { return v.length > 0; });

  if (candidates.length < 2) { alert('후보지를 2개 이상 입력해주세요'); return; }

  fetch(CTX_PATH + '/api/trip/' + TRIP_ID + '/vote', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ title: title, candidates: candidates })
  })
  .then(function(r) { return r.json(); })
  .then(function(data) {
    if (data.success) {
      closeModal('createVoteModal');
      loadVotes();
      showToast('🗳️ 투표가 생성됐어요!');
    } else {
      alert(data.message || '투표 생성 실패');
    }
  });
}

function castVote(voteId, candidateId, btn) {
  fetch(CTX_PATH + '/api/trip/' + TRIP_ID + '/vote/' + voteId + '/cast', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ candidateId: candidateId })
  })
  .then(function(r) { return r.json(); })
  .then(function(data) {
    if (data.success) {
      showToast('✅ 투표 완료!');
      loadVotes();
    } else {
      showToast('⚠️ ' + (data.message || '이미 투표하셨어요'));
    }
  });
}

function deleteVote(voteId) {
  if (!confirm('투표를 삭제할까요?')) return;
  fetch(CTX_PATH + '/api/trip/' + TRIP_ID + '/vote/' + voteId, { method: 'DELETE' })
    .then(function() { loadVotes(); showToast('🗑 투표 삭제됨'); });
}

/* ══════════════════════════════════════════════
   🔔 알림
══════════════════════════════════════════════ */
var _notifOpen = false;

function toggleNotif() {
  _notifOpen = !_notifOpen;
  document.getElementById('notifDropdown').classList.toggle('active', _notifOpen);
  document.getElementById('notifDim').classList.toggle('active', _notifOpen);
  if (_notifOpen) loadNotifList();
}
function closeNotif() {
  _notifOpen = false;
  document.getElementById('notifDropdown').classList.remove('active');
  document.getElementById('notifDim').classList.remove('active');
}

function loadNotifList() {
  fetch(CTX_PATH + '/api/notification?tripId=' + TRIP_ID)
    .then(function(r) { return r.ok ? r.json() : Promise.reject(r.status); })
    .then(function(list) {
      var typeIcon = { INVITE: '✉️', ACCEPT: '✅', SYSTEM: '🔔', VOTE: '🗳️', COMMENT: '💬' };
      var unreadCount = list.filter(function(n) { return n.isRead === 0; }).length;

      // 알림 뱃지 업데이트
      var dot = document.getElementById('notifDot');
      if (dot) dot.style.display = unreadCount > 0 ? 'block' : 'none';

      var html = list.length === 0
        ? '<div style="text-align:center;padding:32px 20px;color:#A0AEC0;">'
          + '<div style="font-size:32px;margin-bottom:8px;">🔔</div>'
          + '<div style="font-size:13px;">새 알림이 없어요</div></div>'
        : list.map(function(n) {
            var icon   = typeIcon[n.type] || '🔔';
            var unread = (n.isRead === 0) ? ' unread' : '';
            var dot2   = (n.isRead === 0) ? '<div class="notif-item-unread-dot"></div>' : '';
            return '<div class="notif-item' + unread + '" onclick="markNotifRead(' + n.notificationId + ',this)">'
              + '<div class="notif-item-icon">' + icon + '</div>'
              + '<div class="notif-item-info">'
              + '<div class="notif-item-text">' + n.message + '</div>'
              + '<div class="notif-item-time">' + n.timeAgo + '</div>'
              + '</div>' + dot2 + '</div>';
          }).join('');

      document.getElementById('notifList').innerHTML = html;
    })
    .catch(function() {
      document.getElementById('notifList').innerHTML =
        '<div style="text-align:center;padding:16px;color:#bbb;font-size:13px">알림을 불러오지 못했어요</div>';
    });
}

function markNotifRead(notifId, el) {
  if (el) el.classList.remove('unread');
  var dot = el ? el.querySelector('.notif-item-unread-dot') : null;
  if (dot) dot.remove();
  fetch(CTX_PATH + '/api/notification/' + notifId + '/read', { method: 'PATCH' });
  // 뱃지 업데이트
  var remaining = document.querySelectorAll('.notif-item.unread').length;
  var badge = document.getElementById('notifDot');
  if (badge) badge.style.display = remaining > 0 ? 'block' : 'none';
}

function clearAllNotif() {
  fetch(CTX_PATH + '/api/notification/read-all?tripId=' + TRIP_ID, { method: 'PATCH' })
    .then(function() {
      loadNotifList();
      showToast('🔔 모두 읽음 처리됐어요');
    });
}

/* ══════════════════════════════════════════════
   💸 가계부
══════════════════════════════════════════════ */
function loadExpenseList() {
  var catIcon = { FOOD:'🍽️', ACCOMMODATION:'🏨', TRANSPORT:'🚗', TOUR:'🎯', CAFE:'☕', SHOPPING:'🛍️', ETC:'📦' };
  var catName = { FOOD:'식비', ACCOMMODATION:'숙소', TRANSPORT:'교통', TOUR:'관광', CAFE:'카페', SHOPPING:'쇼핑', ETC:'기타' };
  var catColor = {
    ACCOMMODATION:'linear-gradient(135deg,#89CFF0,#B5D8F7)',
    FOOD:'linear-gradient(135deg,#FFB6C1,#FFCDD5)',
    TRANSPORT:'linear-gradient(135deg,#C2B8D9,#D9C8E8)',
    TOUR:'linear-gradient(135deg,#A8C8E1,#BFD9ED)',
    CAFE:'linear-gradient(135deg,#F6C9A0,#FADA9C)',
    SHOPPING:'linear-gradient(135deg,#A8E6CF,#B5EDD6)',
    ETC:'linear-gradient(135deg,#D5D8DC,#E8EAED)'
  };

  function renderEmptyCats() {
    var el = document.getElementById('expenseCats');
    if (!el) return;
    var order = ['ACCOMMODATION','FOOD','TRANSPORT','TOUR'];
    el.innerHTML = order.map(function(k) {
      return '<div class="expense-cat">'
        + '<span class="expense-cat__icon">' + catIcon[k] + '</span>'
        + '<span class="expense-cat__name">' + catName[k] + '</span>'
        + '<span class="expense-cat__amt" style="color:#CBD5E0;">₩ 0</span>'
        + '<div class="expense-cat__bar"><div class="expense-cat__bar-fill" style="width:0%"></div></div>'
        + '</div>';
    }).join('');
  }

  fetch(CTX_PATH + '/api/trip/' + TRIP_ID + '/expense')
    .then(function(r) { return r.ok ? r.json() : Promise.reject(r.status); })
    .then(function(list) {
      /* ── 카테고리별 집계 ── */
      var catTotals = {};
      var grandTotal = 0;
      if (list && list.length > 0) {
        list.forEach(function(e) {
          var k = (e.category || 'ETC').toUpperCase();
          catTotals[k] = (catTotals[k] || 0) + (e.amount || 0);
          grandTotal += (e.amount || 0);
        });
      }

      /* ── 총액 업데이트 ── */
      var amtEl = document.getElementById('summaryAmt');
      var perEl = document.getElementById('summaryPer');
      if (amtEl) amtEl.textContent = '₩ ' + grandTotal.toLocaleString();
      var memberCnt = Math.max(document.querySelectorAll('.ws-topbar__actions .avatar').length, 1);
      if (perEl) perEl.textContent = '1인당 약 ₩ ' + Math.round(grandTotal / memberCnt).toLocaleString();

      /* ── 카테고리 카드 렌더 ── */
      var catsEl = document.getElementById('expenseCats');
      if (catsEl) {
        var sortedCats = Object.keys(catTotals).sort(function(a,b){ return catTotals[b]-catTotals[a]; });
        var top4 = sortedCats.slice(0, 4);
        if (top4.length === 0) {
          renderEmptyCats();
        } else {
          var maxAmt = catTotals[top4[0]] || 1;
          catsEl.innerHTML = top4.map(function(k) {
            var pct = Math.round(catTotals[k] / maxAmt * 100);
            var bg  = catColor[k] || catColor.ETC;
            return '<div class="expense-cat">'
              + '<span class="expense-cat__icon">' + (catIcon[k]||'📦') + '</span>'
              + '<span class="expense-cat__name">' + (catName[k]||'기타') + '</span>'
              + '<span class="expense-cat__amt">₩ ' + catTotals[k].toLocaleString() + '</span>'
              + '<div class="expense-cat__bar"><div class="expense-cat__bar-fill" style="width:' + pct + '%;background:' + bg + ';"></div></div>'
              + '</div>';
          }).join('');
        }
      }

      /* ── 지출 리스트 렌더 ── */
      var html = (!list || list.length === 0)
        ? '<div style="text-align:center;padding:24px 20px;color:#A0AEC0;">'
          + '<div style="font-size:32px;margin-bottom:8px;">💸</div>'
          + '<div style="font-size:13px;font-weight:600;margin-bottom:4px;">아직 지출 내역이 없어요</div>'
          + '<div style="font-size:12px;">+ 지출 추가 버튼으로 기록해보세요</div></div>'
        : list.slice(0,10).map(function(e) {
            var k    = (e.category||'ETC').toUpperCase();
            var icon = catIcon[k] || '📦';
            var cat  = catName[k] || '기타';
            var priv = e.isPrivate === 'Y' ? '<span class="expense-private-badge">🔒 나만 보기</span>' : '';
            var date = e.expenseDate ? e.expenseDate.substring(5).replace(/-/g,'/') : '';
            return '<div class="expense-item">'
              + '<div class="expense-item__icon-wrap">' + icon + '</div>'
              + '<div class="expense-item__info">'
              + '<div class="expense-item__name">' + (e.description||'') + priv + '</div>'
              + '<div class="expense-item__detail">'
              + '<span>' + date + '</span>'
              + '<span class="expense-payer-chip">💳 ' + (e.payerNickname||'알 수 없음') + '</span>'
              + '<span class="expense-cat-chip">' + icon + ' ' + cat + '</span>'
              + '</div></div>'
              + '<span class="expense-item__amt">₩ ' + (e.amount||0).toLocaleString() + '</span>'
              + '</div>';
          }).join('');
      document.getElementById('expenseList').innerHTML = html;
    })
    .catch(function(err) {
      console.warn('[Expense] 로드 실패:', err);
      renderEmptyCats();
      document.getElementById('expenseList').innerHTML =
        '<div style="text-align:center;padding:16px;color:#bbb;font-size:13px">지출 내역을 불러오지 못했어요</div>';
    });
}

/* ══════════════════════════════════════════════
   🗓️ 일정 드래그앤드롭 (LexoRank 방식)
   - visitOrder: String (DB, zero-padded 6자리)
   - 같은 DAY 내 순서 변경 (실시간 삽입 표시)
   - 다른 DAY로 이동 (place-list 드롭)
   - 비어있는 DAY drop-zone으로 이동
   - 편집/분할 모드 모두 적용
══════════════════════════════════════════════ */
var _dragCard    = null;
var _dragDayFrom = null;

/* LexoRank: 인덱스 → zero-padded 6자리 문자열 */
function toLexoRank(idx) {
  return String(idx + 1).padStart(6, '0');
}

function onCardDragStart(e, el) {
  _dragCard    = el;
  _dragDayFrom = parseInt(el.dataset.day);
  e.dataTransfer.effectAllowed = 'move';
  e.dataTransfer.setData('text/plain', el.dataset.id || '');
  setTimeout(function() { if (_dragCard) _dragCard.classList.add('dragging'); }, 0);
}

function onCardDragEnd(e, el) {
  el.classList.remove('dragging');
  document.querySelectorAll('.place-card.drag-over').forEach(function(c) { c.classList.remove('drag-over'); });
  document.querySelectorAll('.drop-zone.dz-active').forEach(function(z) { z.classList.remove('dz-active'); });
  document.querySelectorAll('.place-list.list-drag-over').forEach(function(l) { l.classList.remove('list-drag-over'); });
  _dragCard = null;
}

/* ── 리스트 내 정렬 ── */
function onListDragOver(e) {
  if (e.target && e.target.classList && e.target.classList.contains('drop-zone')) return;
  e.preventDefault();
  if (!_dragCard) return;
  e.dataTransfer.dropEffect = 'move';
  var list = e.currentTarget;
  list.classList.add('list-drag-over');
  var after = getDragAfterElement(list, e.clientY);
  if (after == null) {
    list.appendChild(_dragCard);
  } else if (after !== _dragCard) {
    list.insertBefore(_dragCard, after);
  }
  refreshPlaceNums(list);
}

function onListDragLeave(e) {
  if (!e.currentTarget.contains(e.relatedTarget)) {
    e.currentTarget.classList.remove('list-drag-over');
  }
}

function onListDrop(e) {
  e.preventDefault();
  e.stopPropagation();
  if (!_dragCard) return;
  var list  = e.currentTarget;
  var dayTo = parseInt(list.dataset.day);
  list.classList.remove('list-drag-over');
  _dragCard.dataset.day = dayTo;
  refreshPlaceNums(list);
  persistPlaceOrder(list, dayTo);
  showToast('✅ 일정 순서가 변경됐어요');
}

/* ── 빈 DAY drop-zone (이름 없는 빈 day도 포함) ── */
function onDropZoneDragOver(e) {
  e.preventDefault();
  e.stopPropagation();
  if (!_dragCard) return;
  e.dataTransfer.dropEffect = 'move';
  e.currentTarget.classList.add('dz-active');
}

function onDropZoneDragLeave(e) {
  e.currentTarget.classList.remove('dz-active');
}

function onDropZoneDrop(e) {
  e.preventDefault();
  e.stopPropagation();
  e.currentTarget.classList.remove('dz-active');
  if (!_dragCard) return;
  var dayTo = parseInt(e.currentTarget.dataset.day);
  var list  = document.getElementById('places-' + dayTo);
  if (!list) return;
  _dragCard.dataset.day = dayTo;
  list.appendChild(_dragCard);
  refreshPlaceNums(list);
  persistPlaceOrder(list, dayTo);
  showToast('📍 DAY ' + dayTo + '로 이동됐어요');
}

/* ── Y 기준 삽입 위치 계산 ── */
function getDragAfterElement(container, y) {
  var items = Array.from(container.querySelectorAll('.place-card:not(.dragging)'));
  return items.reduce(function(closest, child) {
    var box    = child.getBoundingClientRect();
    var offset = y - box.top - box.height / 2;
    if (offset < 0 && offset > closest.offset) return { offset: offset, element: child };
    return closest;
  }, { offset: Number.NEGATIVE_INFINITY }).element;
}

/* ── 번호 갱신 (편집/분할 모두 적용) ── */
function refreshPlaceNums(list) {
  list.querySelectorAll('.place-card').forEach(function(card, i) {
    var n = card.querySelector('.place-num');
    if (n) n.textContent = i + 1;
    card.dataset.order = toLexoRank(i);
  });
}

/* ── 서버에 LexoRank 기반 순서 저장 ── */
function persistPlaceOrder(list, dayTo) {
  var cards = Array.from(list.querySelectorAll('.place-card'));
  var promises = cards.map(function(card, idx) {
    var itemId    = card.dataset.id;
    var visitOrder = toLexoRank(idx);
    if (!itemId) return Promise.resolve();
    card.dataset.order = visitOrder;
    return fetch(CTX_PATH + '/api/itinerary/' + itemId + '/move', {
      method: 'PATCH',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        dayNumber:   dayTo,
        visitOrder:  visitOrder
      })
    }).catch(function(err) { console.warn('[DnD] 저장 실패 itemId=' + itemId, err); });
  });
  Promise.all(promises).then(function() {
    console.log('[DnD] 전체 순서 저장 완료, dayTo=' + dayTo);
  });
}

</script>

<%-- JS 로드 순서 중요: ui.js가 showToast/openModal 등 공통 함수 제공 --%>
<script src="${pageContext.request.contextPath}/dist/js/trip/workspace.ui.js"></script>
<script src="${pageContext.request.contextPath}/dist/js/trip/workspace.notif.js"></script>
<script src="${pageContext.request.contextPath}/dist/js/trip/workspace.schedule.js"></script>
<script src="${pageContext.request.contextPath}/dist/js/trip/workspace.checklist.js"></script>
<script src="${pageContext.request.contextPath}/dist/js/trip/workspace.vote.js"></script>
<script src="${pageContext.request.contextPath}/dist/js/trip/workspace.expense.js"></script>
<script src="${pageContext.request.contextPath}/dist/js/trip/workspace.recommend.js"></script>
<%--
  카카오맵 API 연동 시 아래 주석을 해제하세요:
  <script src="//dapi.kakao.com/v2/maps/sdk.js?appkey=${kakaoAppKey}&libraries=services,clusterer"></script>
--%>
<script>
var _editTripType = '${tripDto.tripType}';
var _origStart    = '${fn:substring(tripDto.startDate,0,10)}';
var _origEnd      = '${fn:substring(tripDto.endDate,0,10)}';

function openTripEditModal() {
  // 현재 값으로 초기화
  document.getElementById('editTripTitle').value = '${fn:escapeXml(tripDto.tripName)}';
  document.getElementById('editTripDesc').value  = '${fn:escapeXml(tripDto.description)}';
  document.getElementById('editDescCount').textContent = document.getElementById('editTripDesc').value.length;
  document.getElementById('editStartDate').value = _origStart;
  document.getElementById('editEndDate').value   = _origEnd;
  document.getElementById('editTripType').value  = _editTripType;
  document.getElementById('editDateWarning').style.display = 'none';

  // 유형 버튼 active 복원
  document.querySelectorAll('.edit-type-btn').forEach(function(b) { b.classList.remove('active'); });
  document.querySelectorAll('.edit-type-btn').forEach(function(b) {
    if (b.textContent.trim() === getTripTypeLabel(_editTripType)) b.classList.add('active');
  });
  openModal('tripEditModal');
}

function getTripTypeLabel(type) {
  var map = { COUPLE:'커플', FAMILY:'가족', FRIENDS:'친구', SOLO:'혼자', BUSINESS:'비즈니스' };
  return map[type] || '';
}

function selectEditType(type, el) {
  _editTripType = type;
  document.getElementById('editTripType').value = type;
  document.querySelectorAll('.edit-type-btn').forEach(function(b) { b.classList.remove('active'); });
  el.classList.add('active');
}

document.addEventListener('DOMContentLoaded', function() {
  // 설명 글자수 카운터
  var descEl = document.getElementById('editTripDesc');
  if (descEl) descEl.addEventListener('input', function() {
    document.getElementById('editDescCount').textContent = this.value.length;
  });

  // 공개여부 토글 레이블
  var pubEl = document.getElementById('editIsPublic');
  if (pubEl) pubEl.addEventListener('change', function() {
    document.getElementById('editPublicLabel').textContent = this.checked ? '공개 여행' : '비공개 여행';
  });

  // 날짜 변경 → 경고 메시지 실시간
  var sEl = document.getElementById('editStartDate');
  var eEl = document.getElementById('editEndDate');
  if (sEl && eEl) {
    sEl.addEventListener('change', checkEditDateWarning);
    eEl.addEventListener('change', checkEditDateWarning);
  }
});

function checkEditDateWarning() {
  var newS   = document.getElementById('editStartDate').value;
  var newE   = document.getElementById('editEndDate').value;
  var warnEl = document.getElementById('editDateWarning');
  if (!newS || !newE) { warnEl.style.display='none'; return; }

  var os = new Date(_origStart); os.setHours(0,0,0,0);
  var oe = new Date(_origEnd);   oe.setHours(0,0,0,0);
  var ns = new Date(newS);       ns.setHours(0,0,0,0);
  var ne = new Date(newE);       ne.setHours(0,0,0,0);

  // 날짜 유효성
  if (ns > ne) {
    warnEl.innerHTML = '⚠️ 종료일이 시작일보다 빠를 수 없어요.';
    warnEl.className = 'edit-date-warning warn-error';
    warnEl.style.display = 'block';
    return;
  }

  // 겹치는지 확인 (새 기간이 기존 기간과 전혀 겹치지 않으면 장소 초기화 경고)
  var noOverlap = (ne < os) || (ns > oe);
  if (noOverlap) {
    warnEl.innerHTML = '🚨 기존 날짜와 겹치지 않아요. 저장 시 <strong>등록된 장소가 모두 초기화</strong>됩니다.';
    warnEl.className = 'edit-date-warning warn-danger';
    warnEl.style.display = 'block';
    return;
  }

  // 날짜가 줄어드는 경우 (종료일이 기존보다 앞으로)
  if (ne < oe || ns > os) {
    // 늘어나기만 하면 경고 없음
    var shrinks = ne < oe || ns > os;
    if (ne < oe) {
      warnEl.innerHTML = '📋 종료일이 줄었어요. <strong>삭제되는 날짜의 일정이 제거</strong>됩니다.';
      warnEl.className = 'edit-date-warning warn-caution';
      warnEl.style.display = 'block';
      return;
    }
    if (ns > os) {
      warnEl.innerHTML = '📋 시작일이 늦어졌어요. <strong>삭제되는 날짜의 일정이 제거</strong>됩니다.';
      warnEl.className = 'edit-date-warning warn-caution';
      warnEl.style.display = 'block';
      return;
    }
  }

  warnEl.style.display = 'none';
}

function submitTripEdit() {
  var title   = document.getElementById('editTripTitle').value.trim();
  var desc    = document.getElementById('editTripDesc').value.trim();
  var startD  = document.getElementById('editStartDate').value;
  var endD    = document.getElementById('editEndDate').value;
  var type    = document.getElementById('editTripType').value;
  var isPublic= document.getElementById('editIsPublic').checked ? 1 : 0;

  if (!title)          { alert('여행 제목을 입력해 주세요.'); return; }
  if (!startD || !endD){ alert('날짜를 입력해 주세요.'); return; }
  if (startD > endD)   { alert('종료일이 시작일보다 빠를 수 없어요.'); return; }

  // 경고 있으면 confirm
  var warn = document.getElementById('editDateWarning');
  if (warn.style.display !== 'none' && warn.className.includes('warn-danger')) {
    if (!confirm('등록된 장소가 모두 초기화됩니다. 계속 진행할까요?')) return;
  }
  if (warn.style.display !== 'none' && warn.className.includes('warn-caution')) {
    if (!confirm('삭제되는 날짜의 일정이 제거됩니다. 계속 진행할까요?')) return;
  }

  var btn = document.getElementById('btnEditSave');
  btn.disabled = true; btn.textContent = '저장 중…';

  fetch(CTX_PATH + '/trip/' + TRIP_ID, {
    method: 'PATCH',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      title:       title,
      tripName:    title,
      description: desc,
      startDate:   startD + 'T00:00:00',
      endDate:     endD   + 'T00:00:00',
      tripType:    type,
      isPublic:    isPublic,
      cities:      null
    })
  })
  .then(function(r) { return r.json(); })
  .then(function(d) {
    if (d.success) {
      closeModal('tripEditModal');
      location.reload();
    } else {
      alert('수정 실패: ' + (d.message || '오류가 발생했습니다.'));
      btn.disabled = false; btn.textContent = '저장하기';
    }
  })
  .catch(function(e) {
    alert('오류가 발생했습니다: ' + e.message);
    btn.disabled = false; btn.textContent = '저장하기';
  });
}

</script>

</body>
</html>
