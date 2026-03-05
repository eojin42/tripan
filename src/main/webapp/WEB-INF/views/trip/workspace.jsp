<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%
  String tripTitle  = "제주 힐링 여행 🍊";
  String tripDates  = "2026.03.10 → 2026.03.13";
  String tripNights = "3박 4일";
  int    dayCount   = 4;
%>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title><%= tripTitle %> - Tripan 워크스페이스</title>
<%-- [DB Connect] 실제: String tripTitle = (String) request.getAttribute("tripTitle"); --%>
  <%-- CSS 로드 순서 중요: responsive.css는 반드시 마지막 --%>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/dist/css/trip/trip.css">

<%-- ══════════ HTML ══════════ --%>

<%-- 탑바 --%>
<div class="ws-topbar">
  <a href="${pageContext.request.contextPath}/" class="ws-topbar__back" title="홈으로">
    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round"><line x1="19" y1="12" x2="5" y2="12"/><polyline points="12 19 5 12 12 5"/></svg>
  </a>

  <div class="ws-topbar__info">
    <div class="ws-topbar__title-wrap">
      <div class="ws-topbar__title"><%= tripTitle %></div>
      <%-- [DB] status = "PLANNING" | "ONGOING" | "COMPLETED" --%>
      <span class="trip-status-badge planning">📋 계획중</span>
      <%-- ONGOING: <span class="trip-status-badge ongoing">✈️ 진행중</span> --%>
      <%-- COMPLETED: <span class="trip-status-badge completed">✅ 완료된 여행</span> --%>
    </div>
    <div class="ws-topbar__sub"><%= tripDates %> &nbsp;·&nbsp; <%= tripNights %></div>
  </div>

    <div class="ws-topbar__actions">
      <div class="live-badge">
        <span class="live-dot"></span>
        실시간 동기화
      </div>

      <%-- [DB] trip_member 테이블 조회 → role/invitation_status 기반 렌더 --%>
      <div class="avatar-group" title="동행자" onclick="openModal('memberModal')" style="cursor:pointer">
        <%-- OWNER: 파란 링 --%>
        <div class="avatar role-owner" style="background:linear-gradient(135deg,#89CFF0,#A8C8E1)" title="어진 (방장)">어진</div>
        <%-- EDITOR: 기본 --%>
        <div class="avatar" style="background:linear-gradient(135deg,#FFB6C1,#E0BBC2)" title="혁찬 (편집자)">혁찬</div>
        <%-- PENDING: 점선 + 흐림 --%>
        <div class="avatar role-pending" style="background:linear-gradient(135deg,#C2B8D9,#A8C8E1)" title="유원 (초대 대기중)">유원</div>
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

        <%-- Day 1 --%>
        <div class="day-section" id="day-1">
          <div class="day-header">
            <div class="day-badge">
              <span class="day-num">1</span>
              <span>DAY</span>
            </div>
            <span class="day-date">3월 10일 (화)</span>
            <button class="btn-add-place" onclick="openAddPlace(1)">+ 장소</button>
          </div>
          <div class="place-list" id="places-1">
            <div class="place-card" draggable="true" data-day="1" data-id="1">
              <div class="place-num">1</div>
              <div class="place-info">
                <div class="place-name">공항 → 숙소 이동</div>
                <div class="place-addr">제주국제공항 → 서귀포시</div>
                <span class="place-type-badge stay">🚗 이동</span>
                <%-- [DB] itinerary_item.start_time / transportation --%>
                <div class="place-chips">
                  <span class="place-chip time">⏰ 14:30</span>
                  <span class="place-chip trans">🚌 렌터카</span>
                </div>
              </div>
              <div class="place-actions">
                <button class="place-action-btn" onclick="openMemo(this)" title="메모">📝</button>
                <button class="place-action-btn" onclick="removePlace(this)" title="삭제">🗑</button>
              </div>
            </div>
            <div class="place-card" draggable="true" data-day="1" data-id="2">
              <div class="place-num">2</div>
              <div class="place-info">
                <div class="place-name">스테이 밤편지</div>
                <div class="place-addr">서귀포시 남원읍</div>
                <span class="place-type-badge stay">🏨 숙소</span>
                <div class="memo-chip">
                  <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"/></svg>
                  체크인 15:00 / 조식 포함
                </div>
              </div>
              <div class="place-actions">
                <button class="place-action-btn" onclick="openMemo(this)" title="메모">📝</button>
                <button class="place-action-btn" onclick="removePlace(this)" title="삭제">🗑</button>
              </div>
            </div>
            <div class="place-card" draggable="true" data-day="1" data-id="3">
              <div class="place-num">3</div>
              <div class="place-info">
                <div class="place-name">흑돼지거리 맛집</div>
                <div class="place-addr">제주시 연동</div>
                <span class="place-type-badge eat">🍽️ 식당</span>
                <div class="place-chips">
                  <span class="place-chip time">⏰ 19:00</span>
                </div>
              </div>
              <div class="place-actions">
                <button class="place-action-btn" onclick="openMemo(this)" title="메모">📝</button>
                <button class="place-action-btn" onclick="removePlace(this)" title="삭제">🗑</button>
              </div>
            </div>
          </div>
          <div class="drop-zone" onclick="openAddPlace(1)">
            <span>+ 장소 추가 또는 드래그</span>
          </div>
        </div>

        <%-- Day 2 --%>
        <div class="day-section" id="day-2">
          <div class="day-header">
            <div class="day-badge" style="background:linear-gradient(135deg,#C2B8D9,#E0BBC2)">
              <span class="day-num">2</span><span>DAY</span>
            </div>
            <span class="day-date">3월 11일 (수)</span>
            <button class="btn-add-place" onclick="openAddPlace(2)">+ 장소</button>
          </div>
          <div class="place-list" id="places-2">
            <div class="place-card" draggable="true" data-day="2" data-id="4">
              <div class="place-num" style="background:linear-gradient(135deg,#C2B8D9,#E0BBC2)">1</div>
              <div class="place-info">
                <div class="place-name">성산일출봉</div>
                <div class="place-addr">서귀포시 성산읍</div>
                <span class="place-type-badge">🏔️ 관광</span>
              </div>
              <div class="place-actions">
                <button class="place-action-btn" onclick="openMemo(this)" title="메모">📝</button>
                <button class="place-action-btn" onclick="removePlace(this)" title="삭제">🗑</button>
              </div>
            </div>
            <div class="place-card" draggable="true" data-day="2" data-id="5">
              <div class="place-num" style="background:linear-gradient(135deg,#C2B8D9,#E0BBC2)">2</div>
              <div class="place-info">
                <div class="place-name">카페 숨비소리</div>
                <div class="place-addr">서귀포시 성산읍</div>
                <span class="place-type-badge eat">☕ 카페</span>
                <div class="memo-chip">
                  <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"/></svg>
                  브레이크타임 15:00-16:00 주의!
                </div>
              </div>
              <div class="place-actions">
                <button class="place-action-btn" onclick="openMemo(this)" title="메모">📝</button>
                <button class="place-action-btn" onclick="removePlace(this)" title="삭제">🗑</button>
              </div>
            </div>
          </div>
          <div class="drop-zone" onclick="openAddPlace(2)">
            <span>+ 장소 추가 또는 드래그</span>
          </div>
        </div>

        <%-- Day 3 --%>
        <div class="day-section" id="day-3">
          <div class="day-header">
            <div class="day-badge" style="background:linear-gradient(135deg,#C2B8D9,#E0BBC2)">
              <span class="day-num">3</span><span>DAY</span>
            </div>
            <span class="day-date">3월 12일 (목)</span>
            <button class="btn-add-place" onclick="openAddPlace(3)">+ 장소</button>
          </div>
          <div class="place-list" id="places-3">
            <div class="place-card" draggable="true" data-day="3" data-id="6">
              <div class="place-num" style="background:linear-gradient(135deg,#C2B8D9,#E0BBC2)">1</div>
              <div class="place-info">
                <div class="place-name">우도 자전거 투어</div>
                <div class="place-addr">제주시 우도면</div>
                <span class="place-type-badge">🚲 액티비티</span>
              </div>
              <div class="place-actions">
                <button class="place-action-btn" onclick="openMemo(this)" title="메모">📝</button>
                <button class="place-action-btn" onclick="removePlace(this)" title="삭제">🗑</button>
              </div>
            </div>
          </div>
          <div class="drop-zone" onclick="openAddPlace(3)">
            <span>+ 장소 추가 또는 드래그</span>
          </div>
        </div>

      </div><%-- /schedule-scroll --%>
    </div><%-- /panel-schedule --%>

    <%-- 체크리스트 패널 --%>
    <div class="sidebar-panel" id="panel-checklist">
      <div class="checklist-panel-inner">

        <%-- ── 상단 고정 헤더 ── --%>
        <div class="cl-top">
          <div class="checklist-header">
            <span class="checklist-title">여행 준비물 체크리스트</span>
            <%-- [DB] trip_checklist 테이블 INSERT --%>
            <button class="btn-add-check" onclick="openAddCheckModal()">+ 추가</button>
          </div>

          <%-- 완료율 바 --%>
          <div class="checklist-progress">
            <div class="checklist-progress-bar-bg">
              <div class="checklist-progress-bar" id="checkProgressBar" style="width:44%"></div>
            </div>
            <span class="checklist-progress-txt" id="checkProgressTxt">4 / 9 완료</span>
          </div>
        </div><%-- /cl-top --%>

        <%-- ── 스크롤 본문 ── --%>
        <div class="cl-body">

          <%-- 카테고리 그리드 --%>
          <div class="check-categories-grid" id="checkGrid">

            <%-- 서류 & 결제 --%>
            <div class="check-category" id="cat-doc">
              <div class="check-cat-label">
                <span class="check-cat-label-left">📋 서류 &amp; 결제</span>
                <button class="check-cat-add" onclick="openInlineAdd('cat-doc')">+ 항목</button>
              </div>
              <div class="check-item done" onclick="toggleCheck(this)">
                <input type="checkbox" id="c1" checked>
                <label for="c1">신분증</label>
                <span class="check-by">나</span>
                <button class="check-item-del" onclick="event.stopPropagation();delCheckItem(this)" title="삭제">✕</button>
              </div>
              <div class="check-item done" onclick="toggleCheck(this)">
                <input type="checkbox" id="c2" checked>
                <label for="c2">항공권 e-티켓</label>
                <span class="check-by">나</span>
                <button class="check-item-del" onclick="event.stopPropagation();delCheckItem(this)" title="삭제">✕</button>
              </div>
              <div class="check-item" onclick="toggleCheck(this)">
                <input type="checkbox" id="c3">
                <label for="c3">숙소 예약 확인서</label>
                <span class="check-by">지민</span>
                <button class="check-item-del" onclick="event.stopPropagation();delCheckItem(this)" title="삭제">✕</button>
              </div>
              <div class="check-add-row" id="add-row-cat-doc">
                <input type="text" class="check-add-input" placeholder="항목 입력…"
                  onkeydown="checkAddKeydown(event,'cat-doc')">
                <button class="check-add-confirm" onclick="confirmInlineAdd('cat-doc')">추가</button>
                <button class="check-add-cancel" onclick="cancelInlineAdd('cat-doc')">취소</button>
              </div>
            </div>

            <%-- 의류 & 용품 --%>
            <div class="check-category" id="cat-cloth">
              <div class="check-cat-label">
                <span class="check-cat-label-left">👗 의류 &amp; 용품</span>
                <button class="check-cat-add" onclick="openInlineAdd('cat-cloth')">+ 항목</button>
              </div>
              <div class="check-item" onclick="toggleCheck(this)">
                <input type="checkbox" id="c4">
                <label for="c4">여벌 옷 (3벌)</label>
                <span class="check-by">나</span>
                <button class="check-item-del" onclick="event.stopPropagation();delCheckItem(this)" title="삭제">✕</button>
              </div>
              <div class="check-item" onclick="toggleCheck(this)">
                <input type="checkbox" id="c5">
                <label for="c5">우산 / 우비</label>
                <span class="check-by">나</span>
                <button class="check-item-del" onclick="event.stopPropagation();delCheckItem(this)" title="삭제">✕</button>
              </div>
              <div class="check-item done" onclick="toggleCheck(this)">
                <input type="checkbox" id="c6" checked>
                <label for="c6">선크림 SPF50+</label>
                <span class="check-by">지민</span>
                <button class="check-item-del" onclick="event.stopPropagation();delCheckItem(this)" title="삭제">✕</button>
              </div>
              <div class="check-item" onclick="toggleCheck(this)">
                <input type="checkbox" id="c7">
                <label for="c7">카메라 + 충전기</label>
                <span class="check-by">민준</span>
                <button class="check-item-del" onclick="event.stopPropagation();delCheckItem(this)" title="삭제">✕</button>
              </div>
              <div class="check-add-row" id="add-row-cat-cloth">
                <input type="text" class="check-add-input" placeholder="항목 입력…"
                  onkeydown="checkAddKeydown(event,'cat-cloth')">
                <button class="check-add-confirm" onclick="confirmInlineAdd('cat-cloth')">추가</button>
                <button class="check-add-cancel" onclick="cancelInlineAdd('cat-cloth')">취소</button>
              </div>
            </div>

            <%-- 의약품 --%>
            <div class="check-category" id="cat-med">
              <div class="check-cat-label">
                <span class="check-cat-label-left">💊 의약품</span>
                <button class="check-cat-add" onclick="openInlineAdd('cat-med')">+ 항목</button>
              </div>
              <div class="check-item" onclick="toggleCheck(this)">
                <input type="checkbox" id="c8">
                <label for="c8">멀미약</label>
                <span class="check-by">나</span>
                <button class="check-item-del" onclick="event.stopPropagation();delCheckItem(this)" title="삭제">✕</button>
              </div>
              <div class="check-item done" onclick="toggleCheck(this)">
                <input type="checkbox" id="c9" checked>
                <label for="c9">상비약 세트</label>
                <span class="check-by">지민</span>
                <button class="check-item-del" onclick="event.stopPropagation();delCheckItem(this)" title="삭제">✕</button>
              </div>
              <div class="check-add-row" id="add-row-cat-med">
                <input type="text" class="check-add-input" placeholder="항목 입력…"
                  onkeydown="checkAddKeydown(event,'cat-med')">
                <button class="check-add-confirm" onclick="confirmInlineAdd('cat-med')">추가</button>
                <button class="check-add-cancel" onclick="cancelInlineAdd('cat-med')">취소</button>
              </div>
            </div>

            <%-- 카테고리 추가 카드 --%>
            <button class="check-category-add-card" onclick="addNewCategory()">
              <span style="font-size:22px">+</span>
              <span>카테고리 추가</span>
            </button>

          </div><%-- /check-categories-grid --%>
        </div><%-- /cl-body --%>
      </div><%-- /checklist-panel-inner --%>
    </div>

    <%-- 가계부 패널 --%>
    <div class="sidebar-panel" id="panel-expense">
      <div class="expense-panel-inner">

        <%-- 총액 카드 [DB] expense 테이블 SUM --%>
        <div class="expense-summary">
          <div class="expense-summary__label">총 지출</div>
          <div class="expense-summary__amount">₩ 287,500</div>
          <div class="expense-summary__split">3인 기준</div>
          <div class="expense-summary__per">1인당 약 ₩ 95,833</div>
        </div>

        <%-- 카테고리 4칸 --%>
        <div class="expense-cats">
          <div class="expense-cat">
            <span class="expense-cat__icon">🏨</span>
            <span class="expense-cat__name">숙소</span>
            <span class="expense-cat__amt">₩ 120,000</span>
            <div class="expense-cat__bar"><div class="expense-cat__bar-fill" style="width:42%"></div></div>
          </div>
          <div class="expense-cat">
            <span class="expense-cat__icon">🍽️</span>
            <span class="expense-cat__name">식비</span>
            <span class="expense-cat__amt">₩ 87,500</span>
            <div class="expense-cat__bar"><div class="expense-cat__bar-fill" style="width:30%"></div></div>
          </div>
          <div class="expense-cat">
            <span class="expense-cat__icon">🚗</span>
            <span class="expense-cat__name">교통</span>
            <span class="expense-cat__amt">₩ 45,000</span>
            <div class="expense-cat__bar"><div class="expense-cat__bar-fill" style="width:16%;background:linear-gradient(135deg,#C2B8D9,#E0BBC2)"></div></div>
          </div>
          <div class="expense-cat">
            <span class="expense-cat__icon">🎯</span>
            <span class="expense-cat__name">관광</span>
            <span class="expense-cat__amt">₩ 35,000</span>
            <div class="expense-cat__bar"><div class="expense-cat__bar-fill" style="width:12%;background:linear-gradient(135deg,#A8C8E1,#89CFF0)"></div></div>
          </div>
        </div>

        <%-- 최근 지출 내역 [DB] expense + expense_participant JOIN --%>
        <div class="expense-section-head">
          <span class="expense-list-title">최근 지출 내역</span>
          <button class="expense-list-more" onclick="showToast('전체 내역 기능 준비 중')">전체 보기 →</button>
        </div>

        <%-- [DB] expense: id=1, payer=어진, category=ACCOMMODATION, is_private=N --%>
        <div class="expense-item">
          <div class="expense-item__icon-wrap">🏨</div>
          <div class="expense-item__info">
            <div class="expense-item__name">스테이 밤편지</div>
            <div class="expense-item__detail">
              <span>3/10</span>
              <span class="expense-payer-chip">💳 어진</span>
              <span class="expense-cat-chip">🏨 숙소</span>
            </div>
          </div>
          <span class="expense-item__amt">₩ 120,000</span>
        </div>

        <%-- [DB] expense: id=2, payer=지민, category=FOOD, is_private=N --%>
        <div class="expense-item">
          <div class="expense-item__icon-wrap">🍽️</div>
          <div class="expense-item__info">
            <div class="expense-item__name">흑돼지거리 맛집</div>
            <div class="expense-item__detail">
              <span>3/10</span>
              <span class="expense-payer-chip">💳 지민</span>
              <span class="expense-cat-chip">🍽 식비</span>
            </div>
          </div>
          <span class="expense-item__amt">₩ 55,500</span>
        </div>

        <%-- [DB] expense: id=3, payer=민준, category=TRANSPORT, is_private=N --%>
        <div class="expense-item">
          <div class="expense-item__icon-wrap">🚗</div>
          <div class="expense-item__info">
            <div class="expense-item__name">렌터카</div>
            <div class="expense-item__detail">
              <span>3/10</span>
              <span class="expense-payer-chip">💳 민준</span>
              <span class="expense-cat-chip">🚗 교통</span>
            </div>
          </div>
          <span class="expense-item__amt">₩ 45,000</span>
        </div>

        <%-- [DB] expense: is_private=Y → 🔒 나만 보기 뱃지 표시 --%>
        <div class="expense-item">
          <div class="expense-item__icon-wrap">🍦</div>
          <div class="expense-item__info">
            <div class="expense-item__name">아이스크림 간식 <span class="expense-private-badge">🔒 나만 보기</span></div>
            <div class="expense-item__detail">
              <span>3/11</span>
              <span class="expense-payer-chip">💳 나</span>
              <span class="expense-cat-chip">🛍 기타</span>
            </div>
          </div>
          <span class="expense-item__amt">₩ 8,500</span>
        </div>

        <button class="btn-add-expense" onclick="openModal('addExpenseModal')">
          <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
          지출 추가
        </button>

        <%-- 정산 현황 [DB] expense_participant + is_settled 기반 --%>
        <div class="settle-section">
          <div class="settle-head">
            <span class="settle-title">
              <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round"><line x1="12" y1="1" x2="12" y2="23"/><path d="M17 5H9.5a3.5 3.5 0 0 0 0 7h5a3.5 3.5 0 0 1 0 7H6"/></svg>
              정산 현황
            </span>
            <span class="settle-done-badge">1 / 2 완료</span>
          </div>

          <%-- [DB] is_settled=N: 나 → 지민에게 18,500 줘야 함 --%>
          <div class="settle-row">
            <div class="settle-avatars">
              <div class="settle-avatar" style="background:linear-gradient(135deg,#89CFF0,#A8C8E1)">나</div>
              <span class="settle-arrow">→</span>
              <div class="settle-avatar" style="background:linear-gradient(135deg,#FFB6C1,#E0BBC2)">지민</div>
            </div>
            <div class="settle-info">
              <div class="settle-desc">지민에게 보내야 해요</div>
              <div class="settle-amt negative">₩ 18,500</div>
            </div>
            <%-- [DB] is_settled = N → 정산 요청 버튼 표시 --%>
            <button class="settle-req-btn" onclick="requestSettle(this)">정산 요청</button>
          </div>

          <%-- [DB] is_settled=Y: 민준 → 나에게 받음 (완료) --%>
          <div class="settle-row">
            <div class="settle-avatars">
              <div class="settle-avatar" style="background:linear-gradient(135deg,#C2B8D9,#A8C8E1)">민준</div>
              <span class="settle-arrow">→</span>
              <div class="settle-avatar" style="background:linear-gradient(135deg,#89CFF0,#A8C8E1)">나</div>
            </div>
            <div class="settle-info">
              <div class="settle-desc">민준에게 받아야 해요</div>
              <div class="settle-amt positive">₩ 15,000</div>
            </div>
            <%-- [DB] is_settled = Y → 완료 표시 --%>
            <button class="settle-req-btn settled">✓ 완료</button>
          </div>
        </div>

      </div>
    </div>

    <%-- 투표 패널 --%>
    <div class="sidebar-panel" id="panel-vote">
      <div class="vote-panel-inner">

        <div class="vote-panel-head">
          <span class="vote-panel-title">동행자 투표</span>
          <button class="btn-new-vote" onclick="showToast('투표 생성 기능 연동 예정')">+ 투표 만들기</button>
        </div>

        <div class="vote-cards-grid">

          <div class="vote-card">
            <div class="vote-card__emoji">🍽️</div>
            <div class="vote-card__title">Day2 저녁 어디서 먹을까요?</div>
            <div class="vote-card__sub">
              <span>3명 참여</span>
              <span class="vote-card__sub-dot"></span>
              <span>12시간 남음</span>
            </div>
            <div class="vote-option">
              <div class="vote-option__top"><span class="vote-option__name">흑돼지 전문점 A</span><span class="vote-option__pct">67%</span></div>
              <div class="vote-bar-bg"><div class="vote-bar-fill" style="width:67%"></div></div>
            </div>
            <div class="vote-option">
              <div class="vote-option__top"><span class="vote-option__name">해물뚝배기 B</span><span class="vote-option__pct">33%</span></div>
              <div class="vote-bar-bg"><div class="vote-bar-fill" style="width:33%;background:linear-gradient(135deg,#C2B8D9,#E0BBC2)"></div></div>
            </div>
            <div class="vote-card__divider"></div>
            <button class="btn-vote voted">✓ 흑돼지로 투표함</button>
          </div>

          <div class="vote-card">
            <div class="vote-card__emoji">🏄</div>
            <div class="vote-card__title">Day3 오후 액티비티</div>
            <div class="vote-card__sub">
              <span>2명 참여</span>
              <span class="vote-card__sub-dot"></span>
              <span>진행 중</span>
            </div>
            <div class="vote-option">
              <div class="vote-option__top"><span class="vote-option__name">서핑 체험</span><span class="vote-option__pct">50%</span></div>
              <div class="vote-bar-bg"><div class="vote-bar-fill" style="width:50%"></div></div>
            </div>
            <div class="vote-option">
              <div class="vote-option__top"><span class="vote-option__name">스노클링</span><span class="vote-option__pct">50%</span></div>
              <div class="vote-bar-bg"><div class="vote-bar-fill" style="width:50%;background:linear-gradient(135deg,#C2B8D9,#E0BBC2)"></div></div>
            </div>
            <div class="vote-card__divider"></div>
            <button class="btn-vote" onclick="castVote(this)">투표하기</button>
          </div>

        </div><%-- /vote-cards-grid --%>
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
              <div class="rp-weather-main-city">📍 제주도 · 3월 10일 (화)</div>
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
        <button class="dpp-btn" onclick="addRecToDay(1)">DAY 1<br><span>3월 10일</span></button>
        <button class="dpp-btn" onclick="addRecToDay(2)">DAY 2<br><span>3월 11일</span></button>
        <button class="dpp-btn" onclick="addRecToDay(3)">DAY 3<br><span>3월 12일</span></button>
        <button class="dpp-btn" onclick="addRecToDay(4)">DAY 4<br><span>3월 13일</span></button>
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
<div class="modal-overlay" id="memoModal">
  <div class="modal-box">
    <div class="modal-box__head">
      <span class="modal-box__title">📝 세부 메모 & 첨부</span>
      <button class="modal-close-btn" onclick="closeModal('memoModal')">✕</button>
    </div>
    <div class="modal-box__body">
      <label class="form-label-sm">메모</label>
      <textarea class="form-textarea" placeholder="브레이크타임 주의, 예약 필수 등 메모를 입력하세요…"></textarea>
      <div class="upload-zone" onclick="showToast('📎 파일 첨부 기능 연동 예정')">
        <svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" style="color:var(--light)"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="17 8 12 3 7 8"/><line x1="12" y1="3" x2="12" y2="15"/></svg>
        <p>e-티켓, 예약 바우처 이미지 첨부</p>
      </div>
      <button class="btn-primary" onclick="saveMemo()">저장</button>
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
      <label class="form-label-sm" style="margin-bottom:10px;display:block">현재 멤버 (3명)</label>
      <div class="member-list">

        <%-- OWNER --%>
        <div class="member-row">
          <div class="member-avatar-lg role-owner" style="background:linear-gradient(135deg,#89CFF0,#A8C8E1)">어진</div>
          <div class="member-info">
            <div class="member-name">어진</div>
            <div class="member-sub">나 · 방장</div>
          </div>
          <span class="member-role-badge owner">👑 방장</span>
        </div>

        <%-- EDITOR (ACCEPTED) --%>
        <div class="member-row">
          <div class="member-avatar-lg" style="background:linear-gradient(135deg,#FFB6C1,#E0BBC2)">혁찬</div>
          <div class="member-info">
            <div class="member-name">혁찬</div>
            <div class="member-sub">@hyeokc · 편집자</div>
          </div>
          <span class="member-role-badge editor">✏️ 편집자</span>
          <div class="member-actions">
            <button class="member-act-btn change" onclick="showToast('권한 변경 기능 연동 예정')">권한</button>
            <button class="member-act-btn cancel" onclick="showToast('강퇴 기능 연동 예정')">강퇴</button>
          </div>
        </div>

        <%-- PENDING --%>
        <div class="member-row">
          <div class="member-avatar-lg role-pending" style="background:linear-gradient(135deg,#C2B8D9,#A8C8E1)">유원</div>
          <div class="member-info">
            <div class="member-name">유원</div>
            <div class="member-sub">@yw2024 · 초대 대기 중</div>
          </div>
          <span class="member-role-badge pending">⏳ 대기중</span>
          <div class="member-actions">
            <button class="member-act-btn cancel" onclick="showToast('초대 취소됨')">취소</button>
          </div>
        </div>
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
            <option value="me">나 (어진)</option>
            <option value="hyeok">혁찬</option>
            <option value="yuwon">유원</option>
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

    <%-- 초대 알림 (아이디 검색으로 초대된 경우 - PENDING 상태) --%>
    <%-- [DB] trip_member.invitation_status = 'PENDING' → 수락/거절 버튼 표시 --%>
    <div class="notif-item unread" id="notif-invite-1">
      <div class="notif-item-icon type-invite">🧳</div>
      <div class="notif-item-info">
        <div class="notif-item-text"><strong>혁찬</strong>님이 <strong>제주 힐링 여행</strong>에 초대되었습니다.</div>
        <div class="notif-item-time">방금 전</div>
        <%-- [DB] invitation_status = PENDING → 버튼 표시. ACCEPTED → 숨김 --%>
        <div class="notif-invite-actions" id="notif-invite-1-actions">
          <button class="notif-accept-btn" onclick="acceptInvite('notif-invite-1')">수락</button>
          <button class="notif-decline-btn" onclick="declineInvite('notif-invite-1')">거절</button>
        </div>
      </div>
      <div class="notif-item-unread-dot"></div>
    </div>

    <%-- 초대 수락 완료 알림 --%>
    <div class="notif-item unread">
      <div class="notif-item-icon type-accept">✅</div>
      <div class="notif-item-info">
        <div class="notif-item-text"><strong>유원</strong>님이 초대를 수락했어요.</div>
        <div class="notif-item-time">5분 전</div>
      </div>
      <div class="notif-item-unread-dot"></div>
    </div>

    <%-- 일반 알림 --%>
    <div class="notif-item">
      <div class="notif-item-icon type-comment">💬</div>
      <div class="notif-item-info">
        <div class="notif-item-text"><strong>어진</strong>님이 Day2 일정에 메모를 추가했어요.</div>
        <div class="notif-item-time">1시간 전</div>
      </div>
    </div>

    <div class="notif-item">
      <div class="notif-item-icon type-invite">🗳️</div>
      <div class="notif-item-info">
        <div class="notif-item-text"><strong>Day2 저녁 투표</strong>에 새 응답이 있어요.</div>
        <div class="notif-item-time">2시간 전</div>
      </div>
    </div>

  </div>
</div>

<%-- 토스트 --%>
<div class="toast-wrap" id="toastWrap"></div>


<%-- JS 로드 순서 중요: ui.js가 showToast/openModal 등 공통 함수 제공 --%>
<script src="${pageContext.request.contextPath}/dist/js/trip/workspace.ui.js"></script>
<script src="${pageContext.request.contextPath}/dist/js/trip/workspace.notif.js"></script>
<script src="${pageContext.request.contextPath}/dist/js/trip/workspace.schedule.js"></script>
<script src="${pageContext.request.contextPath}/dist/js/trip/workspace.checklist.js"></script>
<script src="${pageContext.request.contextPath}/dist/js/trip/workspace.vote.js"></script>
<script src="${pageContext.request.contextPath}/dist/js/trip/workspace.expense.js"></script>
<script src="${pageContext.request.contextPath}/dist/js/trip/workspace.recommend.js"></script>
<%--
  카카오맵 API 연동 시 아래 주석 해제:
  <script src="//dapi.kakao.com/v2/maps/sdk.js?appkey=${kakaoAppKey}&libraries=services"></script>
--%>
</body>
</html>
