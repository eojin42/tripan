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
  <link rel="stylesheet" href="${pageContext.request.contextPath}/dist/css/trip/workspace.festival.css">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/dist/css/trip/workspace_expense_v2.css">
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
            <span class="trip-status-badge completed">✅ 여행 완료</span>
          </c:when>
          <c:otherwise>
            <span class="trip-status-badge planning">📋 계획중</span>
          </c:otherwise>
        </c:choose>
        <%-- 상세 버튼 — 항상 노출 --%>
        <button class="ws-detail-btn-v2" onclick="openModal('tripInfoModal')" title="여행 상세 정보">
          <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
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

	  <%-- 상단바 아바타 디자인 --%>
      <div class="avatar-group" title="동행자" onclick="openModal('memberModal')" style="cursor:pointer">
        <c:forEach var="m" items="${tripDto.members}" varStatus="avSt">
          <%-- 강퇴/거절 멤버는 제외 --%>
          <c:if test="${m.invitationStatus != 'DECLINED'}">
            <c:choose>
              <%-- '나'를 가장 눈에 띄게: scale 강조 + 선명한 텍스트 --%>
              <c:when test="${m.memberId == myMemberId}">
                <div class="avatar avatar-me" title="나 (${m.nickname})">${fn:substring(m.nickname,0,2)}</div>
              </c:when>
              <%-- 대기중 --%>
              <c:when test="${m.invitationStatus == 'PENDING'}">
                <div class="avatar role-pending" title="${m.nickname} (초대 대기중)">${fn:substring(m.nickname,0,2)}</div>
              </c:when>
              <%-- 방장 또는 일반 멤버: 유저별 고유 색상 클래스 --%>
              <c:otherwise>
                <div class="avatar avatar-color-${avSt.index % 6}<c:if test="${m.role == 'OWNER'}"> role-owner</c:if>" title="${m.nickname}<c:if test="${m.role == 'OWNER'}"> (방장)</c:if>">${fn:substring(m.nickname,0,2)}</div>
              </c:otherwise>
            </c:choose>
          </c:if>
        </c:forEach>
        <c:if test="${isOwner}">
          <div class="avatar avatar-add" onclick="event.stopPropagation();openModal('memberModal')" title="동행자 관리">+</div>
        </c:if>
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

    <%-- ═══════════════════════════════════════════
         가계부 패널 — 전면 개편 (P2P 정산 워크플로우)
    ═══════════════════════════════════════════ --%>
   <div class="sidebar-panel" id="panel-expense">

  <%-- ── 내부 탭바 ── --%>
  <div style="display:flex;flex-shrink:0;background:var(--white);border-bottom:1.5px solid var(--border);">
    <button class="exp-itab"
      onclick="switchExpTab('home', this)"
      style="flex:1;padding:13px 0;border:none;border-bottom:2.5px solid #89CFF0;
             background:transparent;font-family:'Pretendard',sans-serif;
             font-size:12px;font-weight:800;color:#2D3748;cursor:pointer;transition:all .18s;">
      🏠 홈
    </button>
    <button class="exp-itab"
      onclick="switchExpTab('list', this)"
      style="flex:1;padding:13px 0;border:none;border-bottom:2px solid transparent;
             background:transparent;font-family:'Pretendard',sans-serif;
             font-size:12px;font-weight:700;color:var(--light);cursor:pointer;transition:all .18s;">
      🧾 내역
    </button>
    <button class="exp-itab"
      onclick="switchExpTab('settle', this)"
      style="flex:1;padding:13px 0;border:none;border-bottom:2px solid transparent;
             background:transparent;font-family:'Pretendard',sans-serif;
             font-size:12px;font-weight:700;color:var(--light);cursor:pointer;transition:all .18s;">
      💸 정산
    </button>
  </div>

  <%-- ══════════════════════════════════
       탭 1: 홈 — 대시보드 (개편)
  ══════════════════════════════════ --%>
  <div class="exp-tab-pane" id="exp-tab-home" style="display:flex;flex-direction:column;overflow-y:auto;">

    <%-- ── 히어로 카드 ── --%>
    <div class="exp-home-hero">
      <div class="exp-home-hero__top">
        <span class="exp-home-hero__label">여행 총 지출</span>
      </div>
      <div class="exp-home-hero__amount" id="summaryAmt">₩ 0</div>

      <%-- 내 결제 / 내 부담 --%>
      <div class="exp-home-hero__stats">
        <div class="exp-home-hero__stat">
          <div class="exp-home-hero__stat-label">내가 결제</div>
          <div class="exp-home-hero__stat-val" id="myPaidAmt">₩ 0</div>
        </div>
        <div class="exp-home-hero__stat-divider"></div>
        <div class="exp-home-hero__stat">
          <div class="exp-home-hero__stat-label">내 부담</div>
          <div class="exp-home-hero__stat-val" id="myShareAmt">₩ 0</div>
        </div>
      </div>

      <%-- 받을 / 보낼 예정 --%>
      <div class="exp-home-hero__settle-row">
        <div class="exp-home-hero__settle-item exp-home-hero__settle-item--recv">
          <div class="exp-home-hero__settle-label">💚 받을 예정</div>
          <div class="exp-home-hero__settle-val" id="myReceiveAmt">₩ 0</div>
        </div>
        <div class="exp-home-hero__settle-item exp-home-hero__settle-item--send">
          <div class="exp-home-hero__settle-label">💸 보낼 예정</div>
          <div class="exp-home-hero__settle-val" id="mySendAmt">₩ 0</div>
        </div>
      </div>

      <%-- 나의 정산 상태 --%>
      <div id="myBalanceLine" class="exp-home-hero__balance"></div>
    </div>


    <%-- ── 카테고리별 지출 (가로 스크롤 카드형) ── --%>
    <div id="expenseCatsSection" style="display:none;padding:12px 16px 0;">
      <div class="exp-home-section-title">📊 카테고리별 지출</div>
      <div class="expense-cats" id="expenseCats" style="display:flex;gap:10px;overflow-x:auto;padding-bottom:8px;scrollbar-width:none;-webkit-overflow-scrolling:touch;"></div>
    </div>

    <%-- ── 정산 알림 칩 (내 지출 요약 위) ── --%>
    <div id="expSettleStatus" style="padding:0 16px 4px;"></div>

    <%-- ── 내 지출 요약 섹션 ── --%>
    <div id="expMySummarySection" style="display:none;padding:12px 16px 20px;">
      <div class="exp-home-section-title">📋 이번 여행 내 지출 요약</div>
      <div id="expMySummaryBody"></div>
    </div>

  </div><%-- /exp-tab-home --%>

  <%-- ══════════════════════════════════
       탭 2: 지출 내역 (카테고리 UI 개선)
  ══════════════════════════════════ --%>
  <div class="exp-tab-pane expense-panel-inner" id="exp-tab-list"
       style="display:none;flex-direction:column;">

    <div class="expense-section-head" style="padding:14px 16px 8px;">
      <span class="expense-list-title">지출 내역</span>
      <span id="expenseCount" style="font-size:11px;color:var(--light);font-weight:600;"></span>
    </div>

    <%-- JS가 동적으로 렌더 --%>
    <div id="expenseList" style="padding:0 8px;overflow-y:auto;flex:1;"></div>

    <%-- VIEWER 권한은 추가 버튼 숨김 --%>
    <c:if test="${memberRole != 'VIEWER'}">
      <button class="btn-add-expense" onclick="openModal('addExpenseModal')" style="margin:0 16px 16px;">
        <svg width="14" height="14" viewBox="0 0 24 24" fill="none"
             stroke="currentColor" stroke-width="2.5" stroke-linecap="round">
          <line x1="12" y1="5" x2="12" y2="19"/>
          <line x1="5"  y1="12" x2="19" y2="12"/>
        </svg>
        지출 추가
      </button>
    </c:if>

  </div><%-- /exp-tab-list --%>

  <%-- ══════════════════════════════════
       탭 3: 정산 — P2P 워크플로우 (전면 재설계)
  ══════════════════════════════════ --%>
  <div class="exp-tab-pane expense-panel-inner" id="exp-tab-settle"
       style="display:none;flex-direction:column;">

    <%-- ── 현황/완료 토글 버튼 (강조 디자인) ── --%>
    <div class="settle-view-toggle">
      <button id="settleBtnStatus" class="settle-view-btn active" onclick="switchSettleView('status')">
        📊 정산 현황
      </button>
      <button id="settleBtnDone" class="settle-view-btn" onclick="switchSettleView('done')">
        ✅ 완료 내역
      </button>
    </div>

    <%-- ── 정산 현황 뷰 ── --%>
    <div id="settleStatusView" style="overflow-y:auto;flex:1;">
      <%-- 내가 받을 정산 --%>
      <div id="settleRecvList" style="padding:0 12px;"></div>
      <%-- 내가 줘야 할 정산 --%>
      <div id="settleSendList" style="padding:0 12px;"></div>
      <%-- 빈 상태 --%>
      <div id="settleStatusEmpty" class="expense-empty-state" style="display:none;">
        <div class="expense-empty-state__emoji">💰</div>
        <div class="expense-empty-state__title">아직 정산할 내역이 없어요</div>
        <div class="expense-empty-state__sub">지출이 쌓이면 자동으로 정산 현황을 확인할 수 있어요</div>
        <div style="display:flex;gap:8px;flex-wrap:wrap;justify-content:center;">
          <button class="expense-empty-state__btn"
                  onclick="switchExpTab('list', document.querySelectorAll('.exp-itab')[1])">
            지출 내역 보기
          </button>
          <button class="expense-empty-state__btn expense-empty-state__btn--ghost"
                  onclick="_loadSettleTab()">
            새로고침
          </button>
        </div>
      </div>
    </div>

    <%-- ── 완료 내역 뷰 ── --%>
    <div id="settleDoneView" style="display:none;overflow-y:auto;flex:1;">
      <div id="settleDoneList" style="padding:0 12px;"></div>
      <%-- 완료 내역 없을 때 --%>
      <div id="settleDoneEmpty" style="display:none;text-align:center;padding:32px 20px;">
        <div style="font-size:36px;margin-bottom:12px;">📭</div>
        <div style="font-size:14px;font-weight:800;color:#2D3748;margin-bottom:6px;">정산 완료 내역이 없어요</div>
        <div style="font-size:12px;color:#A0AEC0;line-height:1.7;">정산 요청 후 상대방이 완료 처리하면<br>여기에 표시돼요</div>
      </div>
    </div>

  </div><%-- /exp-tab-settle --%>

</div><%-- /panel-expense --%>


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
          <button class="rp-tab" id="rpTab-festival" onclick="switchRpTab('festival',this); loadFestivalTabIfNeeded();">축제</button>
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

      <%-- ── 탭: 축제 ── --%>
      <div class="rp-pane" id="rpPane-festival">
        <div class="rp-pane-head">
          <div class="rp-pane-head__period">
            <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round"><rect x="3" y="4" width="18" height="18" rx="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
            <fmt:parseDate var="parsedStart" value="${fn:substring(tripDto.startDate,0,10)}" pattern="yyyy-MM-dd"/>
            <fmt:parseDate var="parsedEnd"   value="${fn:substring(tripDto.endDate,0,10)}"   pattern="yyyy-MM-dd"/>
            <fmt:formatDate var="fmtStart" value="${parsedStart}" pattern="M월 d일"/>
            <fmt:formatDate var="fmtEnd"   value="${parsedEnd}"   pattern="M월 d일"/>
            <strong style="color:#2D3748;">${fmtStart}부터 ${fmtEnd}</strong> 기간에 열리는 축제
          </div>
        </div>
        <div id="festivalRegionFilter" class="festival-region-filter"></div>
        <div id="festivalListWrap" class="festival-list-wrap">
          <div class="festival-empty">
            <div class="festival-empty__icon">🎉</div>
            <div class="festival-empty__msg">축제 탭을 클릭하면 로드돼요</div>
          </div>
        </div>
      </div><%-- /rpPane-festival --%>

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

<%-- 메모 & 이미지 모달 --%>
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
  <div class="modal-box mm-modal-box">
    <div class="modal-box__head mm-head">
      <div class="mm-head-inner">
        <div class="mm-head-icon">👥</div>
        <div>
          <div class="mm-head-title">동행자 관리</div>
          <div class="mm-head-sub">함께하는 여행 멤버를 관리해요</div>
        </div>
      </div>
      <button class="modal-close-btn" onclick="closeModal('memberModal')">✕</button>
    </div>
    <div class="modal-box__body mm-body">

      <%-- 1. 초대 링크 --%>
      <div class="mm-invite-section">
        <div class="mm-invite-label">
          <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round"><path d="M10 13a5 5 0 0 0 7.54.54l3-3a5 5 0 0 0-7.07-7.07l-1.72 1.71"/><path d="M14 11a5 5 0 0 0-7.54-.54l-3 3a5 5 0 0 0 7.07 7.07l1.71-1.71"/></svg>
          초대 링크
        </div>
        <div class="mm-invite-row">
          <input type="text" class="mm-invite-input" 
                 value="${pageContext.request.scheme}://${pageContext.request.serverName}:${pageContext.request.serverPort}${pageContext.request.contextPath}/trip/invite/${tripDto.inviteCode}" 
                 id="inviteLinkInput" readonly>
          <button type="button" class="mm-invite-btn" onclick="copyInviteLink()">
            <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round"><rect x="9" y="9" width="13" height="13" rx="2"/><path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1"/></svg>
            복사
          </button>
          <c:if test="${isOwner}">
            <button type="button" class="mm-invite-btn--refresh" onclick="refreshInviteCode()" title="초대링크 재발급">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><polyline points="23 4 23 10 17 10"/><polyline points="1 20 1 14 7 14"/><path d="M3.51 9a9 9 0 0 1 14.85-3.36L23 10M1 14l4.64 4.36A9 9 0 0 0 20.49 15"/></svg>
          </button>
          </c:if>
        </div>
      </div>
      <div class="mm-section-label">현재 멤버 <span class="mm-count">${fn:length(tripDto.members)}</span></div>
      <div class="member-list">
        <c:forEach var="m" items="${tripDto.members}" varStatus="mmSt">
          <%-- 강퇴/거절당한 유저는 리스트에 출력하지 않음 --%>
          <c:if test="${m.invitationStatus != 'DECLINED'}">
            <div class="member-row member-row-v2">
              
              <%-- 아바타 --%>
              <div class="member-avatar-lg mm-avatar-color-${mmSt.index % 6}<c:if test="${m.role == 'OWNER'}"> role-owner</c:if><c:if test="${m.memberId == myMemberId}"> mm-avatar-me</c:if>">
                <c:choose>
                  <c:when test="${not empty m.profileImage}">
                    <img src="<c:choose><c:when test="${fn:startsWith(m.profileImage, 'http')}">${m.profileImage}</c:when><c:otherwise>${pageContext.request.contextPath}/uploads/${m.profileImage}</c:otherwise></c:choose>" 
                         style="width:100%; height:100%; object-fit:cover; border-radius:50%;" 
                         onerror="this.style.display='none'; this.nextElementSibling.style.display='flex';">
                    <span style="display:none; font-weight:800; font-size:15px;">${fn:substring(m.nickname,0,2)}</span>
                  </c:when>
                  <c:otherwise>
                    <span style="font-weight:800; font-size:15px;">${fn:substring(m.nickname,0,2)}</span>
                  </c:otherwise>
                </c:choose>
              </div>

              <%-- 닉네임 및 상태 텍스트 --%>
              <div class="member-info">
                <div class="mm-member-name">
                  ${m.nickname}
                  <c:if test="${m.memberId == myMemberId}"><span class="mm-me-badge">나</span></c:if>
                </div>
                <div class="mm-member-sub">
                  <c:choose>
                    <c:when test="${m.role == 'OWNER'}"><span class="mm-role-dot owner"></span>방장</c:when>
                    <c:when test="${m.invitationStatus == 'PENDING'}"><span class="mm-role-dot pending"></span>초대 대기 중</c:when>
                    <c:when test="${m.role == 'VIEWER'}"><span class="mm-role-dot viewer"></span>읽기 전용</c:when>
                    <c:otherwise><span class="mm-role-dot editor"></span>편집자</c:otherwise>
                  </c:choose>
                </div>
              </div>

              <%-- 우측 컨트롤 패널 --%>
              <c:choose>
                <c:when test="${m.role == 'OWNER'}">
                  <span class="mm-badge-owner">
                    <svg width="11" height="11" viewBox="0 0 24 24" fill="currentColor"><path d="M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01L12 2z"/></svg>
                    방장
                  </span>
                </c:when>
                <c:when test="${m.invitationStatus == 'PENDING'}">
                  <span class="mm-badge-pending">⏳ 대기중</span>
                  <c:if test="${isOwner}">
                    <button onclick="onKickMember(${m.memberId})" class="mm-btn-kick">취소</button>
                  </c:if>
                </c:when>
                <c:otherwise>
                  <c:if test="${isOwner}">
                    <div style="display:flex; gap:6px; align-items:center;">
                      <select onchange="onChangeMemberRole(this, ${m.memberId})" class="mm-role-select">
                        <option value="EDITOR" ${m.role == 'EDITOR' ? 'selected' : ''}>✏️ 편집자</option>
                        <option value="VIEWER" ${m.role == 'VIEWER' ? 'selected' : ''}>👀 읽기전용</option>
                      </select>
                      <button onclick="onKickMember(${m.memberId})" class="mm-btn-kick">강퇴</button>
                    </div>
                  </c:if>
                  <c:if test="${!isOwner}">
                     <span class="mm-badge-role">${m.role == 'VIEWER' ? '👀 읽기전용' : '✏️ 편집자'}</span>
                  </c:if>
                </c:otherwise>
              </c:choose>
              
            </div>
          </c:if>
        </c:forEach>
      </div>
      <c:if test="${!isOwner}">
        <div class="mm-leave-wrap">
          <button onclick="onLeaveTrip()" class="mm-btn-leave">
            🚪 이 여행에서 나가기
          </button>
        </div>
      </c:if>

    </div>
  </div>
</div>
<%-- ══════════════════════════════════════════════════
     여행 정보 상세 모달
════════════════════════════════════════════════== --%>
<%-- ══════════════════════════════════════════════════
     여행 정보 상세 모달 (리디자인 v2)
     - 초대 코드 제거
     - 삭제 버튼 추가 (OWNER only + 2단계 경고)
════════════════════════════════════════════════== --%>
<div class="modal-overlay" id="tripInfoModal">
  <div class="modal-box tinfo-modal-box">

    <%-- ── 상단: 히어로 배너 ── --%>
    <c:choose>
      <c:when test="${empty tripDto.thumbnailUrl}">
        <div class="tinfo-hero is-default-bg">
      </c:when>
      <c:otherwise>
        <div class="tinfo-hero">
      </c:otherwise>
    </c:choose>
      <%-- 썸네일 이미지 --%>
      <c:choose>
        <c:when test="${empty tripDto.thumbnailUrl}">
          <img class="tinfo-hero-img is-default"
            src="${pageContext.request.contextPath}/dist/images/logo.png"
            alt="${fn:escapeXml(tripDto.tripName)}">
        </c:when>
        <c:otherwise>
          <img class="tinfo-hero-img"
            id="tinfoHeroImg"
            src="${pageContext.request.contextPath}${tripDto.thumbnailUrl}"
            alt="${fn:escapeXml(tripDto.tripName)}"
            onerror="this.classList.add('is-default');this.src='${pageContext.request.contextPath}/dist/images/logo.png';this.closest('.tinfo-hero').classList.add('is-default-bg')">
        </c:otherwise>
      </c:choose>
      <div class="tinfo-hero-overlay"></div>

      <%-- 닫기 버튼 --%>
      <button class="tinfo-close-btn" onclick="closeModal('tripInfoModal')">
        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>
      </button>

      <%-- 여행명 + 날짜 오버레이 --%>
      <div class="tinfo-hero-text">
        <c:choose>
          <c:when test="${tripDto.status == 'ONGOING'}"><span class="tinfo-status ongoing">✈️ 여행중</span></c:when>
          <c:when test="${tripDto.status == 'COMPLETED'}"><span class="tinfo-status completed">✅ 완료</span></c:when>
          <c:otherwise><span class="tinfo-status planning">📋 계획중</span></c:otherwise>
        </c:choose>
        <h2 class="tinfo-hero-title">${fn:escapeXml(tripDto.tripName)}</h2>
        <p class="tinfo-hero-dates">
          ${fn:replace(tripDto.startDate,'-','.')} → ${fn:replace(tripDto.endDate,'-','.')} &nbsp;·&nbsp; ${tripNights}
        </p>
      </div>

      <%-- 이미지 변경 버튼 — 우하단 (OWNER/EDITOR만) --%>
      <c:if test="${memberRole != 'VIEWER'}">
        <button class="tinfo-hero-edit-btn" onclick="closeModal('tripInfoModal'); openTripEditModal();" title="대표 이미지 변경">
          <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><rect x="3" y="3" width="18" height="18" rx="2"/><circle cx="8.5" cy="8.5" r="1.5"/><polyline points="21 15 16 10 5 21"/></svg>
          이미지 변경
        </button>
      </c:if>
    </div>

    <%-- ── 스크롤 바디 ── --%>
    <div class="tinfo-scroll-body">

      <%-- 1. 여행지 (이름 강조) --%>
      <c:if test="${not empty tripDto.cities}">
        <div class="tinfo-row-section">
          <div class="tinfo-row-label">
            <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z"/><circle cx="12" cy="10" r="3"/></svg>
            여행지
          </div>
          <div class="tinfo-city-chips">
            <c:forEach var="city" items="${tripDto.cities}">
              <span class="tinfo-city-chip">
                <svg width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z"/><circle cx="12" cy="10" r="3"/></svg>
                ${fn:escapeXml(city)}
              </span>
            </c:forEach>
          </div>
        </div>
      </c:if>

      <%-- 2. 동행자 (이름 + 프로필) --%>
      <div class="tinfo-row-section">
        <div class="tinfo-row-label">
          <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>
          동행자
        </div>
        <div class="tinfo-members-wrap">
          <c:forEach var="m" items="${tripDto.members}">
            <c:if test="${m.invitationStatus != 'DECLINED'}">
              <div class="tinfo-member-chip <c:if test='${m.invitationStatus == "PENDING"}'>pending</c:if>">
                <%-- 프로필 이미지 or 이니셜 아바타 --%>
                <div class="tinfo-member-chip-avatar <c:if test='${m.memberId == myMemberId}'>me</c:if>">
                  <c:choose>
                    <c:when test="${not empty m.profileImage}">
                      <img src="${pageContext.request.contextPath}${m.profileImage}"
                           alt="${m.nickname}"
                           onerror="this.style.display='none';this.nextElementSibling.style.display='flex'">
                      <span style="display:none">${fn:substring(m.nickname,0,1)}</span>
                    </c:when>
                    <c:otherwise>
                      <span>${fn:substring(m.nickname,0,1)}</span>
                    </c:otherwise>
                  </c:choose>
                </div>
                <div class="tinfo-member-chip-info">
                  <span class="tinfo-member-chip-name">
                    ${fn:escapeXml(m.nickname)}
                    <c:if test="${m.memberId == myMemberId}"><em class="tinfo-me-tag">나</em></c:if>
                  </span>
                  <span class="tinfo-member-chip-role">
                    <c:choose>
                      <c:when test="${m.role == 'OWNER'}">✨</c:when>
                      <c:when test="${m.invitationStatus == 'PENDING'}">⏳</c:when>
                      <c:when test="${m.role == 'EDITOR'}">✏️</c:when>
                      <c:otherwise>👀</c:otherwise>
                    </c:choose>
                    <c:choose>
                      <c:when test="${m.role == 'OWNER'}">방장</c:when>
                      <c:when test="${m.invitationStatus == 'PENDING'}">대기중</c:when>
                      <c:when test="${m.role == 'EDITOR'}">편집자</c:when>
                      <c:otherwise>읽기전용</c:otherwise>
                    </c:choose>
                  </span>
                </div>
              </div>
            </c:if>
          </c:forEach>
        </div>
      </div>

      <%-- 3. 여행 유형 & 공개 설정 (2열 행) --%>
      <div class="tinfo-row-section">
        <div class="tinfo-row-label">
          <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><circle cx="12" cy="12" r="10"/><line x1="2" y1="12" x2="22" y2="12"/><path d="M12 2a15.3 15.3 0 0 1 4 10 15.3 15.3 0 0 1-4 10 15.3 15.3 0 0 1-4-10 15.3 15.3 0 0 1 4-10z"/></svg>
          여행 설정
        </div>
        <div class="tinfo-setting-row">
          <div class="tinfo-setting-item">
            <span class="tinfo-setting-icon">
              <c:choose>
                <c:when test="${tripDto.tripType == 'COUPLE'}">💑</c:when>
                <c:when test="${tripDto.tripType == 'FAMILY'}">👨‍👩‍👧</c:when>
                <c:when test="${tripDto.tripType == 'FRIENDS'}">🤝</c:when>
                <c:when test="${tripDto.tripType == 'SOLO'}">🧳</c:when>
                <c:when test="${tripDto.tripType == 'BUSINESS'}">💼</c:when>
                <c:otherwise>✈️</c:otherwise>
              </c:choose>
            </span>
            <div>
              <div class="tinfo-setting-val">
                <c:choose>
                  <c:when test="${tripDto.tripType == 'COUPLE'}">커플</c:when>
                  <c:when test="${tripDto.tripType == 'FAMILY'}">가족</c:when>
                  <c:when test="${tripDto.tripType == 'FRIENDS'}">친구</c:when>
                  <c:when test="${tripDto.tripType == 'SOLO'}">혼자</c:when>
                  <c:when test="${tripDto.tripType == 'BUSINESS'}">비즈니스</c:when>
                  <c:otherwise>미설정</c:otherwise>
                </c:choose>
              </div>
              <div class="tinfo-setting-sub">여행 유형</div>
            </div>
          </div>
          <div class="tinfo-setting-item">
            <span class="tinfo-setting-icon">${tripDto.isPublic == 1 ? '🌐' : '🔒'}</span>
            <div>
              <div class="tinfo-setting-val">${tripDto.isPublic == 1 ? '공개' : '비공개'}</div>
              <div class="tinfo-setting-sub">공개 설정</div>
            </div>
          </div>
        </div>
      </div>

      <%-- 4. 여행 태그 --%>
      <c:if test="${not empty tripDto.tags}">
        <div class="tinfo-row-section">
          <div class="tinfo-row-label">
            <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M20.59 13.41l-7.17 7.17a2 2 0 0 1-2.83 0L2 12V2h10l8.59 8.59a2 2 0 0 1 0 2.82z"/><line x1="7" y1="7" x2="7.01" y2="7"/></svg>
            여행 태그
          </div>
          <div class="tinfo-tag-chips">
            <c:forEach var="tag" items="${tripDto.tags}">
              <span class="tinfo-tag-chip">${fn:escapeXml(tag)}</span>
            </c:forEach>
          </div>
        </div>
      </c:if>

      <%-- 5. 여행 설명 --%>
      <c:if test="${not empty tripDto.description}">
        <div class="tinfo-row-section">
          <div class="tinfo-row-label">
            <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><line x1="17" y1="10" x2="3" y2="10"/><line x1="21" y1="6" x2="3" y2="6"/><line x1="21" y1="14" x2="3" y2="14"/><line x1="17" y1="18" x2="3" y2="18"/></svg>
            여행 메모
          </div>
          <div class="tinfo-desc-box">
            <p class="tinfo-desc-text">${fn:escapeXml(tripDto.description)}</p>
          </div>
        </div>
      </c:if>

      <%-- 6. 액션 버튼 --%>
      <div class="tinfo-action-row">
        <c:if test="${memberRole != 'VIEWER'}">
          <button class="tinfo-btn-edit" onclick="closeModal('tripInfoModal'); openTripEditModal();">
            <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"/></svg>
            여행 정보 수정
          </button>
        </c:if>
        <c:if test="${isOwner}">
          <button id="btnDeleteTrip" class="tinfo-btn-delete" onclick="confirmDeleteTrip()">
            <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polyline points="3 6 5 6 21 6"/><path d="M19 6l-1 14a2 2 0 0 1-2 2H8a2 2 0 0 1-2-2L5 6"/><path d="M10 11v6"/><path d="M14 11v6"/><path d="M9 6V4a1 1 0 0 1 1-1h4a1 1 0 0 1 1 1v2"/></svg>
            여행 삭제
          </button>
        </c:if>
      </div>

    </div><%-- /tinfo-scroll-body --%>
  </div>
</div>

<%-- ══════════════════════════════════════════════════
     여행 수정 모달
════════════════════════════════════════════════== --%>
<div class="modal-overlay" id="tripEditModal">
  <div class="modal-box" style="max-width:520px;">
    <div class="modal-box__head">
      <span class="modal-box__title">✏️ 여행 정보 수정</span>
      <button class="modal-close-btn" onclick="closeModal('tripEditModal')">✕</button>
    </div>
    <div class="modal-box__body" style="max-height:80vh;overflow-y:auto;scrollbar-width:none;">

      <%-- ── 대표 이미지 변경 ── --%>
      <div class="edit-form-group">
        <label class="edit-form-label">대표 이미지</label>
        <div class="edit-thumb-wrap">
          <%-- 미리보기 원형 --%>
          <div class="edit-thumb-circle" onclick="document.getElementById('editThumbInput').click()" title="클릭하여 이미지 변경">
            <img id="editThumbPreview"
              src="${not empty tripDto.thumbnailUrl
                ? pageContext.request.contextPath.concat(tripDto.thumbnailUrl)
                : pageContext.request.contextPath.concat('/dist/images/logo.png')}"
              alt="대표 이미지"
              onerror="this.src='${pageContext.request.contextPath}/dist/images/logo.png'">
            <div class="edit-thumb-overlay">
              <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="2.5"><path d="M23 19a2 2 0 0 1-2 2H3a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h4l2-3h6l2 3h4a2 2 0 0 1 2 2z"/><circle cx="12" cy="13" r="4"/></svg>
              <span>변경</span>
            </div>
          </div>
          <div class="edit-thumb-right">
            <button type="button" class="edit-thumb-btn" onclick="document.getElementById('editThumbInput').click()">
              📷 이미지 선택
            </button>
            <input type="file" id="editThumbInput" accept="image/*" style="display:none" onchange="onEditThumbChange(event)">
            <button type="button" class="edit-thumb-reset" id="editThumbResetBtn" onclick="resetEditThumb()" style="display:none">기본으로 초기화</button>
            <p class="edit-thumb-hint">JPG · PNG · WEBP · 최대 5MB</p>
          </div>
        </div>
      </div>

      <%-- ── 제목 ── --%>
      <div class="edit-form-group">
        <label class="edit-form-label">여행 제목 <span style="color:#FC8181">*</span></label>
        <input type="text" id="editTripTitle" class="edit-form-input"
          placeholder="여행 제목을 입력하세요" maxlength="100"
          value="${fn:escapeXml(tripDto.tripName)}">
      </div>

      <%-- ── 날짜 ── --%>
      <div class="edit-form-row">
        <div style="flex:1;">
          <label class="edit-form-label">시작일</label>
          <input type="date" id="editStartDate" class="edit-form-input"
            onchange="checkEditDateWarning()"
            value="${fn:substring(tripDto.startDate,0,10)}">
        </div>
        <div style="flex:1;">
          <label class="edit-form-label">종료일</label>
          <input type="date" id="editEndDate" class="edit-form-input"
            onchange="checkEditDateWarning()"
            value="${fn:substring(tripDto.endDate,0,10)}">
        </div>
      </div>
      <div id="editDateWarning" class="edit-date-warning" style="display:none;"></div>

      <%-- ── 여행 유형 ── --%>
      <div class="edit-form-group">
        <label class="edit-form-label">여행 유형</label>
        <div class="edit-type-grid">
          <button class="edit-type-btn <c:if test='${tripDto.tripType == "COUPLE"}'>active</c:if>" onclick="selectEditType('COUPLE',this)">💑 커플</button>
          <button class="edit-type-btn <c:if test='${tripDto.tripType == "FAMILY"}'>active</c:if>" onclick="selectEditType('FAMILY',this)">👨‍👩‍👧 가족</button>
          <button class="edit-type-btn <c:if test='${tripDto.tripType == "FRIENDS"}'>active</c:if>" onclick="selectEditType('FRIENDS',this)">🤝 친구</button>
          <button class="edit-type-btn <c:if test='${tripDto.tripType == "SOLO"}'>active</c:if>" onclick="selectEditType('SOLO',this)">🧳 혼자</button>
          <button class="edit-type-btn <c:if test='${tripDto.tripType == "BUSINESS"}'>active</c:if>" onclick="selectEditType('BUSINESS',this)">💼 비즈니스</button>
        </div>
        <input type="hidden" id="editTripType" value="${tripDto.tripType}">
      </div>

      <%-- ── 태그 편집 ── --%>
      <div class="edit-form-group">
        <label class="edit-form-label">
          여행 태그
          <span class="edit-form-opt">이 여행의 분위기·테마 (최대 10개)</span>
        </label>
        <%-- 현재 태그 칩 렌더 --%>
        <div class="edit-tag-wrap" id="editTagWrap" onclick="document.getElementById('editTagInput').focus()">
          <c:forEach var="tag" items="${tripDto.tags}">
            <span class="edit-tag-chip" data-tag="${fn:escapeXml(tag)}">
              ${fn:escapeXml(tag)}
              <button type="button" onclick="removeEditTag(this)" title="삭제">✕</button>
            </span>
          </c:forEach>
          <input type="text" id="editTagInput" class="edit-tag-input"
            placeholder="태그 입력 후 Enter…" maxlength="15"
            onkeydown="handleEditTagInput(event)">
        </div>
        <%-- 빠른 태그 추가 --%>
        <div class="edit-tag-presets">
          <span class="edit-tag-preset" onclick="addEditTagPreset(this)">#힐링</span>
          <span class="edit-tag-preset" onclick="addEditTagPreset(this)">#맛집투어</span>
          <span class="edit-tag-preset" onclick="addEditTagPreset(this)">#우정여행</span>
          <span class="edit-tag-preset" onclick="addEditTagPreset(this)">#혼행</span>
          <span class="edit-tag-preset" onclick="addEditTagPreset(this)">#감성사진</span>
          <span class="edit-tag-preset" onclick="addEditTagPreset(this)">#쇼핑</span>
        </div>
      </div>

      <%-- ── 설명 ── --%>
      <div class="edit-form-group">
        <label class="edit-form-label">여행 설명 <span class="edit-form-opt">선택</span></label>
        <textarea id="editTripDesc" class="edit-form-textarea"
          placeholder="여행에 대해 간단히 적어보세요…" maxlength="500"
          oninput="document.getElementById('editDescCount').textContent=this.value.length"
          >${fn:escapeXml(tripDto.description)}</textarea>
        <div class="edit-form-count"><span id="editDescCount">${fn:length(tripDto.description)}</span> / 500</div>
      </div>

      <%-- ── 공개 여부 ── --%>
      <div class="edit-form-group">
        <label class="edit-form-label">공개 여부</label>
        <label class="edit-toggle-wrap">
          <input type="checkbox" id="editIsPublic" ${tripDto.isPublic == 1 ? 'checked' : ''}
            onchange="document.getElementById('editPublicLabel').textContent=this.checked?'공개 여행':'비공개 여행'">
          <span class="edit-toggle-slider"></span>
          <span id="editPublicLabel" style="font-size:13px;font-weight:600;color:#4A5568;margin-left:10px;">
            ${tripDto.isPublic == 1 ? '공개 여행' : '비공개 여행'}
          </span>
        </label>
      </div>

      <%-- ── 저장 버튼 ── --%>
      <button class="btn-edit-save" id="btnEditSave" onclick="submitTripEdit()">
        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polyline points="20 6 9 17 4 12"/></svg>
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
        <input type="text" class="form-input" id="chk-manager" placeholder="담당자를 입력해주세요." maxlength="20">
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

<%-- ══════════════════════════════
     지출 추가 모달 — 전면 재설계
     POST /api/trips/{tripId}/expenses
══════════════════════════════ --%>
<div class="modal-overlay" id="addExpenseModal">
  <div class="modal-box expense-modal-box-v2">

    <%-- ── 헤더 ── --%>
    <div class="exp-v2-header">
      <button class="exp-v2-close" onclick="closeModal('addExpenseModal')">✕</button>
      <span class="exp-v2-title">지출 등록</span>
      <div style="width:32px;"></div>
    </div>

    <div class="exp-v2-body" id="expV2Body">

      <%-- ── 1) 카테고리 가로 스크롤 칩 ── --%>
      <div class="exp-v2-cats-wrap">
        <div class="exp-v2-cats" id="expCatChips" ondragstart="return false;">
          <button class="exp-cat-chip active" data-val="FOOD"         onclick="selectExpCat('FOOD',this)">        🍽️ 식사</button>
          <button class="exp-cat-chip"        data-val="CAFE"         onclick="selectExpCat('CAFE',this)">        ☕ 카페</button>
          <button class="exp-cat-chip"        data-val="SNACK"        onclick="selectExpCat('ETC',this)">         🍩 간식</button>
          <button class="exp-cat-chip"        data-val="DRINK"        onclick="selectExpCat('ETC',this)">         🍺 술</button>
          <button class="exp-cat-chip"        data-val="TRANSPORT"    onclick="selectExpCat('TRANSPORT',this)">   🚗 교통</button>
          <button class="exp-cat-chip"        data-val="ACCOMMODATION" onclick="selectExpCat('ACCOMMODATION',this)">🏨 숙소</button>
          <button class="exp-cat-chip"        data-val="SHOPPING"     onclick="selectExpCat('SHOPPING',this)">    🛍️ 쇼핑</button>
          <button class="exp-cat-chip"        data-val="TOUR"         onclick="selectExpCat('TOUR',this)">        🎯 관광</button>
          <button class="exp-cat-chip"        data-val="ETC"          onclick="selectExpCat('ETC',this)">         📦 기타</button>
        </div>
        <input type="hidden" id="exp-cat" value="FOOD">
      </div>

      <%-- ── 2) 금액 입력 ── --%>
      <div class="exp-v2-amount-section">
        <div class="exp-v2-amount-label">얼마를 나눌까요?</div>
        <div class="exp-v2-amount-wrap">
          <span class="exp-v2-amount-prefix">₩</span>
          <input type="number" class="exp-v2-amount-input" id="exp-amt"
                 placeholder="0" min="0" step="1">
        </div>
      </div>

      <%-- ── 3) 항목명 + 날짜 ── --%>
      <div class="exp-v2-row">
        <div class="exp-v2-field">
          <label class="exp-v2-label">항목명 <span style="color:#FC8181">*</span></label>
          <input type="text" class="exp-v2-input" id="exp-name"
                 placeholder="어떤 지출인가요?" maxlength="100">
        </div>
        <div class="exp-v2-field" style="flex:0 0 120px;">
          <label class="exp-v2-label">날짜 <span style="color:#FC8181">*</span></label>
          <input type="date" class="exp-v2-input" id="exp-date">
        </div>
      </div>

      <%-- ── 4) 결제자 + 결제수단 ── --%>
      <div class="exp-v2-row">
        <div class="exp-v2-field">
          <label class="exp-v2-label">결제자 <span style="color:#FC8181">*</span></label>
          <div class="exp-payer-dropdown" id="expPayerDropdown">
            <button type="button" class="exp-payer-btn" onclick="togglePayerMenu()" id="expPayerBtn">
              <div class="exp-payer-btn__left">
                <div class="exp-payer-btn__avatar" id="expPayerBtnAvatar">나</div>
                <span id="expPayerBtnLabel">선택</span>
              </div>
              <svg class="exp-payer-btn__chevron" width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polyline points="6 9 12 15 18 9"/></svg>
            </button>
            <div class="exp-payer-menu" id="expPayerMenu">
              <c:forEach var="m" items="${tripDto.members}">
                <c:if test="${m.invitationStatus == 'ACCEPTED' || m.role == 'OWNER'}">
                  <div class="exp-payer-option${m.memberId == myMemberId ? ' selected' : ''}"
                       data-id="${m.memberId}"
                       onclick="selectPayer(${m.memberId},'${fn:escapeXml(m.nickname)}',${m.memberId == myMemberId})">
                    <div class="exp-payer-option__avatar">${fn:substring(m.nickname,0,2)}</div>
                    <span class="exp-payer-option__name">${fn:escapeXml(m.nickname)}</span>
                    <c:if test="${m.memberId == myMemberId}">
                      <span class="exp-payer-option__me">나</span>
                      <span class="exp-payer-option__check">✓</span>
                    </c:if>
                  </div>
                </c:if>
              </c:forEach>
            </div>
            <input type="hidden" id="exp-payer-value" value="${myMemberId}">
          </div>
        </div>
        <div class="exp-v2-field" style="flex:0 0 120px;">
          <label class="exp-v2-label">결제수단</label>
          <select class="exp-v2-input" id="exp-payment-type" style="cursor:pointer;">
            <option value="">미선택</option>
            <option value="카드">💳 카드</option>
            <option value="현금">💵 현금</option>
            <option value="계좌이체">🏦 이체</option>
          </select>
        </div>
      </div>

      <%-- ── 5) 분담자 목록 (카카오페이 스타일) ── --%>
      <div class="exp-v2-split-section">
        <div class="exp-v2-split-head">
          <span id="expSplitCount" class="exp-v2-split-count">친구 0명</span>
          <button type="button" class="exp-v2-edit-btn" onclick="openParticipantEditor()">✏️ 편집</button>
        </div>
        <%-- 분담자 리스트 — JS가 동적 렌더 --%>
        <div id="exp-split-list" class="exp-v2-split-list"></div>
        <%-- 1원 나머지 처리 안내 --%>
        <div id="exp-remainder-note" class="exp-v2-remainder-note" style="display:none;"></div>
      </div>

      <%-- ── 6) 메모 + 영수증 ── --%>
      <div class="exp-v2-extras">
        <input type="text" class="exp-v2-input" id="exp-memo"
               placeholder="📝 메모 (선택)" maxlength="200">
        <label class="exp-v2-receipt-btn" onclick="document.getElementById('exp-receipt').click()">
          📷 영수증 사진
        </label>
        <input type="file" id="exp-receipt" accept="image/*" style="display:none;"
               onchange="previewReceiptImage(this)">
      </div>
      <div id="exp-receipt-preview" style="display:none;margin:0 0 12px;"></div>

      <%-- ── 확인 버튼 ── --%>
      <button class="exp-v2-submit" id="expSubmitBtn" onclick="submitExpense()" disabled>확인</button>

    </div><%-- /exp-v2-body --%>
  </div>
</div><%-- /addExpenseModal --%>


<%-- ── 분담자 편집 모달 ── --%>
<div class="modal-overlay" id="participantEditorModal">
  <div class="modal-box" style="width:min(440px,96vw);max-height:85vh;overflow-y:auto;">
    <div class="modal-box__head">
      <span class="modal-box__title">함께 나눌 사람</span>
      <button class="modal-close-btn" onclick="closeModal('participantEditorModal')">✕</button>
    </div>
    <div class="modal-box__body">
      <p style="font-size:12px;color:var(--light);margin-bottom:14px;">워크스페이스 밖 친구도 추가할 수 있어요</p>
      <%-- 워크스페이스 멤버 목록 --%>
      <div id="peWsMembers"></div>
      <%-- 외부 추가 인원 --%>
      <div id="peExtraMembers" style="margin-top:12px;"></div>
      <%-- 이름 입력 추가 --%>
      <div class="pe-add-row">
        <input type="text" id="peExtraNameInput" class="form-input"
               placeholder="이름 입력 (예: 민수, 현장합류1)" maxlength="20"
               onkeydown="if(event.key==='Enter')addExtraPerson()">
        <button class="pe-add-btn" onclick="addExtraPerson()">추가</button>
      </div>
      <button class="btn-primary" style="margin-top:16px;" onclick="applyParticipants()">적용하기</button>
    </div>
  </div>
</div>


<%-- ══════════════════════════════
     지출 상세 모달 (메모/영수증 보기)
══════════════════════════════ --%>
<div class="modal-overlay" id="expenseDetailModal">
  <div class="modal-box" style="width:min(460px,96vw);max-height:85vh;overflow-y:auto;">
    <div class="modal-box__head">
      <span class="modal-box__title">지출 상세</span>
      <button class="modal-close-btn" onclick="closeModal('expenseDetailModal')">✕</button>
    </div>
    <div class="modal-box__body" id="expenseDetailBody"></div>
  </div>
</div>

<%-- ══════════════════════════════
     정산 상세 모달 (카카오페이 스타일)
══════════════════════════════ --%>
<div class="modal-overlay" id="settleDetailModal">
  <div class="modal-box settle-detail-modal" style="width:min(500px,96vw);max-height:88vh;overflow-y:auto;">
    <div class="modal-box__head">
      <span class="modal-box__title">📊 정산 상세</span>
      <button class="modal-close-btn" onclick="closeModal('settleDetailModal')">✕</button>
    </div>
    <div class="modal-box__body" id="settleDetailBody"></div>
  </div>
</div>




<%-- ══════════════════════════════
     카테고리 상세 모달
══════════════════════════════ --%>
<div class="modal-overlay" id="catDetailModal">
  <div class="modal-box" style="width:min(460px,96vw);max-height:85vh;overflow-y:auto;">
    <div class="modal-box__head">
      <span class="modal-box__title" id="catDetailTitle">카테고리 상세</span>
      <button class="modal-close-btn" onclick="closeModal('catDetailModal')">✕</button>
    </div>
    <div class="modal-box__body" id="catDetailBody"></div>
  </div>
</div>

<%-- ══════════════════════════════
     멤버 정산 상세 모달
══════════════════════════════ --%>
<div class="modal-overlay" id="memberSettleModal">
  <div class="modal-box" style="width:min(480px,96vw);max-height:88vh;overflow-y:auto;">
    <div class="modal-box__head">
      <span class="modal-box__title" id="memberSettleTitle">멤버 정산 현황</span>
      <button class="modal-close-btn" onclick="closeModal('memberSettleModal')">✕</button>
    </div>
    <div class="modal-box__body" id="memberSettleBody"></div>
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

/* 축제 탭 — 처음 클릭 시 1회만 로드 */
function loadFestivalTabIfNeeded() {
  if (typeof loadFestivalTab === 'function' && !window._festivalLoaded) {
    loadFestivalTab();
  }
}
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
<script src="${pageContext.request.contextPath}/dist/js/trip/workspace.festival.js"></script>

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

<%--  전역 변수 설정 및 뷰어 권한 철통 통제 --%>
<script>
  var MY_MEMBER_ID = ${myMemberId};
  var MY_ROLE = '${memberRole}';

  //  알림창에 닉네임을 띄우기 위한 닉네임 사전(Dictionary) 생성
  var MEMBER_DICT = {};
  <c:forEach var="m" items="${tripDto.members}">
    MEMBER_DICT['${m.memberId}'] = '${fn:escapeXml(m.nickname)}';
  </c:forEach>

  if (MY_ROLE === 'VIEWER') {
      document.body.classList.add('role-viewer');
      
      //  화면에 있는 모든 "추가/수정" 함수 껍데기로 만들기
      window.openAddPlace = function() { alert('👀 읽기 전용 모드입니다.'); };
      window.saveMemo = function() { alert('👀 읽기 전용 모드입니다.'); };
      window.submitCheckItem = function() { alert('👀 읽기 전용 모드입니다.'); };
      window.submitExpense = function() { alert('👀 읽기 전용 모드입니다.'); };
      window.submitVote = function() { alert('👀 읽기 전용 모드입니다.'); };
      window.removePlace = function() { alert('👀 읽기 전용 모드입니다.'); };
      window.toggleCheckOptimistic = function() { alert('👀 읽기 전용 모드입니다.'); };

      //  마우스 클릭 이벤트 자체를 1순위로 가로채서 파괴하기
      window.addEventListener('click', function(e) {
          var btn = e.target.closest('button');
          if (btn && (btn.classList.contains('map-add-btn') || 
                      btn.classList.contains('btn-add-place') || 
                      btn.classList.contains('rp-add-btn'))) {
              e.preventDefault(); 
              e.stopPropagation(); 
              alert('👀 읽기 전용 모드에서는 장소를 추가할 수 없습니다.');
              return;
          }
          
          var clickEl = e.target.closest('[onclick]');
          if (clickEl) {
              var fnStr = clickEl.getAttribute('onclick') || '';
              if (fnStr.includes('addRecToDay') || 
                  fnStr.includes('openDayPicker') || 
                  fnStr.includes('addMapPlace') || 
                  fnStr.includes('addKakaoPlace') ||
                  fnStr.includes('addPlace')) {
                  
                  e.preventDefault(); 
                  e.stopPropagation(); 
                  alert('👀 읽기 전용 모드에서는 추천 장소나 지도 장소를 추가할 수 없습니다.');
                  return;
              }
          }
      }, true);

      
      // 드래그 앤 드롭 및 메모장 타이핑 물리적 마비
      window.addEventListener('DOMContentLoaded', function() {
          var memoArea = document.getElementById('memoText');
          if(memoArea) {
              memoArea.readOnly = true;
              memoArea.placeholder = "읽기 전용 모드입니다.";
          }
          
          document.querySelectorAll('.place-card').forEach(function(card) {
              card.setAttribute('draggable', 'false');
          });
          
          window.onCardDragStart = function(event) {
              event.preventDefault();
              alert('👀 읽기 전용 모드에서는 일정을 이동할 수 없습니다.');
              return false;
          };
      });
  }
</script>

<jsp:include page="/WEB-INF/views/layout/footerResources.jsp" />
</body>
</html>
