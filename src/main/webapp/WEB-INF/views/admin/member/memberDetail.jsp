<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <title>TripanSuper — 회원 상세 정보</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/dist/css/admin.css">
  <script src="https://cdnjs.cloudflare.com/ajax/libs/html2canvas/1.4.1/html2canvas.min.js"></script>

  <style>
    /* ── 공통 아이콘 ── */
    .section-icon { display: inline-flex; align-items: center; gap: 8px; }
    .section-icon svg { width: 18px; height: 18px; stroke: currentColor; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; flex-shrink: 0; }

    /* ── 프로필 헤더 ── */
    .profile-header-card { display: flex; gap: 32px; padding: 40px; align-items: center; background: #fff; border-radius: 24px; box-shadow: var(--shadow-sm); }
    .profile-img-lg { width: 120px; height: 120px; border-radius: 50%; object-fit: cover; border: 4px solid var(--bg); box-shadow: var(--shadow-sm); flex-shrink: 0; }
    .profile-main-info h2 { font-size: 26px; font-weight: 900; margin-bottom: 12px; display: flex; align-items: center; gap: 10px; flex-wrap: wrap; }
    .profile-bio { color: var(--muted); font-size: 15px; margin-bottom: 8px; line-height: 1.6; }

    /* ── 2단 그리드 ── */
    .detail-grid { display: grid; grid-template-columns: 360px 1fr; gap: 24px; margin-top: 24px; margin-bottom: 24px; }
    @media (max-width: 1200px) { .detail-grid { grid-template-columns: 1fr; } }
    .card-pad { padding: 32px; background: #fff; border-radius: 24px; box-shadow: var(--shadow-sm); }
    .info-list { display: flex; flex-direction: column; gap: 20px; }
    .info-row dt { font-size: 12px; font-weight: 800; color: var(--muted); margin-bottom: 6px; }
    .info-row dd { font-size: 15px; font-weight: 700; color: var(--text); }

    /* ── 예약 필터 ── */
    .res-filter-container {
      display: flex; gap: 12px; margin-bottom: 24px; align-items: center;
      background: #F8FAFC; padding: 16px 20px; border-radius: 16px; border: 1px solid var(--border);
      flex-wrap: wrap;
    }
    .res-filter-container input[type="date"],
    .res-filter-container select,
    .res-filter-container input[type="text"] {
      height: 42px; border: 1px solid var(--border); border-radius: 10px; padding: 0 14px;
      font-size: 14px; font-weight: 600; background: #fff; outline: none; transition: border-color 0.2s;
    }
    .res-filter-container input:focus, .res-filter-container select:focus { border-color: var(--primary); box-shadow: 0 0 0 3px var(--primary-10); }
    .filter-label { font-size: 12px; font-weight: 800; color: var(--muted); white-space: nowrap; }
    .search-btn-black { height: 42px; padding: 0 24px; background: #000; color: #fff; border-radius: 10px; font-weight: 800; border: none; cursor: pointer; transition: opacity 0.2s; white-space: nowrap; }
    .search-btn-black:hover { opacity: 0.8; }

    /* 뱃지 관리 */
    .badge-manage-row { display: flex; align-items: center; justify-content: space-between; padding: 12px 0; border-bottom: 1px solid var(--border); }
    .badge-manage-row:last-child { border-bottom: none; }
    .badge-info { display: flex; align-items: center; gap: 12px; }
    .badge-icon-wrap { width: 36px; height: 36px; border-radius: 10px; background: var(--bg); display: flex; align-items: center; justify-content: center; font-size: 18px; flex-shrink: 0; }
    .badge-meta strong { display: block; font-size: 14px; font-weight: 800; }
    .badge-meta span { font-size: 12px; color: var(--muted); }
    .btn-badge-del { height: 32px; padding: 0 14px; border-radius: 8px; border: 1px solid var(--danger); color: var(--danger); background: transparent; font-size: 12px; font-weight: 700; cursor: pointer; transition: all 0.15s; white-space: nowrap; }
    .btn-badge-del:hover { background: var(--danger); color: #fff; }
    .btn-badge-add { height: 38px; padding: 0 16px; border-radius: 10px; border: 1.5px dashed var(--border); color: var(--muted); background: transparent; font-size: 13px; font-weight: 700; cursor: pointer; transition: all 0.2s; width: 100%; margin-top: 16px; }
    .btn-badge-add:hover { border-color: var(--primary); color: var(--primary); background: var(--primary-10); }

    /* 공통 모달 기반 */
    .modal-overlay {
      position: fixed; inset: 0;
      background: rgba(15, 23, 42, 0.55);
      backdrop-filter: blur(6px);
      display: none;
      justify-content: center;
      align-items: center;
      z-index: 3000;
      padding: 24px;
    }

    /* 영수증 모달 (넓은 것) */
    .modal-receipt {
      background: #fff;
      width: 100%;
      max-width: 780px;
      border-radius: 28px;
      box-shadow: 0 24px 64px rgba(0,0,0,0.18);
      overflow: hidden;
      animation: modalUp 0.35s cubic-bezier(0.16,1,0.3,1);
    }

    /* 소형 모달 (정지 / 뱃지 추가) */
    .modal-sheet {
      background: #fff;
      width: 100%;
      max-width: 460px;
      border-radius: 24px;
      box-shadow: 0 24px 64px rgba(0,0,0,0.18);
      overflow: hidden;
      animation: modalUp 0.35s cubic-bezier(0.16,1,0.3,1);
      display: flex;
      flex-direction: column;
    }

    @keyframes modalUp {
      from { opacity: 0; transform: translateY(24px) scale(0.98); }
      to   { opacity: 1; transform: translateY(0)    scale(1); }
    }

    /* 소형 모달 내부 영역 */
    .ms-head {
      padding: 28px 28px 20px;
      border-bottom: 1px solid var(--border);
    }
    .ms-head.danger-head {
      background: linear-gradient(135deg, #FFF1F1 0%, #FFE8E8 100%);
      border-bottom-color: #FFD0D0;
    }
    .ms-danger-icon {
      width: 40px; height: 40px; border-radius: 12px;
      background: var(--danger);
      display: flex; align-items: center; justify-content: center;
      margin-bottom: 12px;
    }
    .ms-danger-icon svg { width: 20px; height: 20px; stroke: #fff; fill: none; stroke-width: 2.2; stroke-linecap: round; stroke-linejoin: round; }
    .ms-head h3 { font-size: 17px; font-weight: 900; margin: 0 0 4px; }
    .ms-head p  { font-size: 13px; color: var(--muted); margin: 0; }
    .ms-head.danger-head h3 { color: var(--danger); }
    .ms-head.danger-head p  { color: #e05050; opacity: 0.85; }

    .ms-body {
      padding: 24px 28px;
      display: flex;
      flex-direction: column;
      gap: 18px;
      overflow-y: auto;
      max-height: 65vh;
    }

    .ms-foot {
      padding: 18px 28px;
      border-top: 1px solid var(--border);
      display: flex;
      gap: 10px;
    }

    /* 폼 그룹 */
    .fg { display: flex; flex-direction: column; gap: 8px; }
    .fg label { font-size: 11px; font-weight: 800; color: var(--muted); text-transform: uppercase; letter-spacing: 0.6px; }
    .fg select,
    .fg textarea,
    .fg input[type="text"],
    .fg input[type="date"] {
      width: 100%;
      border: 1.5px solid var(--border);
      border-radius: 10px;
      padding: 10px 14px;
      font-size: 14px;
      font-weight: 600;
      background: #fff;
      outline: none;
      transition: border-color 0.2s, box-shadow 0.2s;
      box-sizing: border-box;
      font-family: inherit;
      color: var(--text);
    }
    .fg select:focus,
    .fg textarea:focus,
    .fg input:focus { border-color: var(--primary); box-shadow: 0 0 0 3px var(--primary-10); }
    .fg textarea { resize: vertical; min-height: 88px; line-height: 1.5; }
    .fg input[readonly] { background: var(--bg); color: var(--muted); cursor: default; }

    /* 버튼 */
    .btn-modal { flex: 1; height: 48px; border-radius: 12px; font-weight: 800; font-size: 14px; border: none; cursor: pointer; transition: opacity 0.15s, transform 0.1s; }
    .btn-modal:hover { opacity: 0.88; }
    .btn-modal:active { transform: scale(0.98); }
    .btn-modal-ghost  { background: var(--bg); color: var(--text); }
    .btn-modal-black  { background: #111; color: #fff; }
    .btn-modal-danger { background: var(--danger); color: #fff; }

    /* 영수증 모달 내부 */
    .receipt-body { padding: 44px; }
    .receipt-header { display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 28px; padding-bottom: 22px; border-bottom: 2px solid #111; }
    .receipt-header h2 { font-size: 24px; font-weight: 900; }
    .receipt-main { display: grid; grid-template-columns: 1.2fr 1fr; gap: 36px; }
    .r-section h4 { font-size: 13px; font-weight: 900; color: var(--muted); margin-bottom: 16px; text-transform: uppercase; letter-spacing: 1px; }
    .price-table { background: #F8FAFC; padding: 22px; border-radius: 14px; border: 1px solid var(--border); }
    .price-row { display: flex; justify-content: space-between; margin-bottom: 10px; font-weight: 700; color: var(--muted); font-size: 14px; }
    .price-total { display: flex; justify-content: space-between; margin-top: 14px; padding-top: 14px; border-top: 1px dashed var(--border); font-size: 17px; font-weight: 900; color: var(--primary); }
    .receipt-actions { padding: 20px 44px; background: #fff; border-top: 1px solid var(--border); display: flex; gap: 12px; }
  </style>
</head>
<body>

<div class="admin-layout">
  <jsp:include page="../layout/sidebar.jsp"><jsp:param name="activePage" value="members"/></jsp:include>

  <div class="main-wrapper">
    <jsp:include page="../layout/header.jsp" />

    <main class="main-content">

      <!-- 페이지 헤더 -->
      <div class="page-header fade-up">
        <div>
          <button class="btn btn-ghost btn-sm" onclick="history.back()" style="margin-bottom:12px;">← 목록으로 돌아가기</button>
          <h1>회원 상세 정보</h1>
        </div>
        <div class="header-actions">
		  <button class="btn btn-primary" onclick="openSuspendModal()"
		    style="background: var(--danger); display: inline-flex; align-items: center; gap: 8px; width: fit-content; border-radius: 9999px;">
		    
		    <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
		      <path d="M12 20h9"></path>
		      <path d="M16.5 3.5a2.121 2.121 0 0 1 3 3L7 19l-4 1 1-4L16.5 3.5z"></path>
		    </svg>
		    멤버 상태 변경
		  </button>
		</div>
      </div>

      <!-- 프로필 카드 -->
      <div class="card profile-header-card fade-up">
        <img src="${pageContext.request.contextPath}/dist/images/default-avatar.png" class="profile-img-lg"
             onerror="this.src='https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=200'">
        <div class="profile-main-info">
          <h2>
            ${not empty member.nickname ? member.nickname : '이름없음'}
            <span class="badge" style="background:var(--bg); color:var(--text)">${member.role}</span>
            <c:choose>
              <c:when test="${member.status == '1'}"><span class="badge badge-done"  id="profileStatusBadge">정상 활동</span></c:when>
              <c:when test="${member.status == '2'}"><span class="badge badge-danger" id="profileStatusBadge">활동 정지</span></c:when>
              <c:otherwise><span class="badge badge-wait" id="profileStatusBadge">휴면/탈퇴</span></c:otherwise>
            </c:choose>
          </h2>
          <p class="profile-bio">${member.email}</p>
        </div>
      </div>

      <!-- 2단 그리드 -->
      <div class="detail-grid fade-up">

        <!-- 기본 정보 -->
        <div class="card-pad">
          <div class="w-header">
            <h2 class="section-icon">
              <svg viewBox="0 0 24 24"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
              기본 정보
            </h2>
          </div>
          <dl class="info-list">
            <div class="info-row"><dt>사용자 ID (이메일)</dt><dd>${member.email}</dd></div>
            <div class="info-row"><dt>이름</dt><dd>${not empty member.username ? member.username : '-'}</dd></div>
            <div class="info-row"><dt>전화번호</dt><dd>${not empty member.phoneNumber ? member.phoneNumber : '-'}</dd></div>
            <div class="info-row"><dt>성별 / 생일</dt><dd>${member.gender == 'M' ? '남성' : (member.gender == 'F' ? '여성' : '-')} / ${not empty member.birthday ? member.birthday : '-'}</dd></div>
            <hr style="border:0; height:1px; background:var(--border); margin:4px 0;">
            <div class="info-row"><dt>가입 일시</dt><dd>${not empty member.regDate ? member.regDate : '-'}</dd></div>
            <div class="info-row"><dt>마지막 접속</dt><dd>${not empty member.lastLoginAt ? member.lastLoginAt : '-'}</dd></div>
          </dl>
        </div>

        <!-- 뱃지 관리 -->
        <div class="card-pad">
          <div class="w-header" style="display:flex; justify-content:space-between; align-items:center; margin-bottom:20px;">
            <h2 class="section-icon">
              <svg viewBox="0 0 24 24"><path d="M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01L12 2z"/></svg>
              뱃지 관리
            </h2>
            <span style="font-size:13px; color:var(--muted);" id="badgeCount">0개 보유</span>
          </div>

          <div id="badgeListContainer">
            <%-- c:forEach var="b" items="${badgeList}" --%>
            <%-- 실제 연동 시 아래 하드코딩 행 제거하고 c:forEach 사용 --%>
            <div class="badge-manage-row" data-badge-id="1">
              <div class="badge-info">
                <div class="badge-icon-wrap">🏆</div>
                <div class="badge-meta">
                  <strong>리뷰 마스터</strong>
                  <span>획득일: 2026-02-15</span>
                </div>
              </div>
              <button class="btn-badge-del" onclick="removeBadge(this,1)">삭제</button>
            </div>
            <div class="badge-manage-row" data-badge-id="2">
              <div class="badge-info">
                <div class="badge-icon-wrap">🔥</div>
                <div class="badge-meta">
                  <strong>열정 여행러</strong>
                  <span>획득일: 2026-03-01</span>
                </div>
              </div>
              <button class="btn-badge-del" onclick="removeBadge(this,2)">삭제</button>
            </div>
          </div>

          <button class="btn-badge-add" onclick="openBadgeAddModal()">+ 뱃지 수동 부여</button>
        </div>
      </div>

      <!-- 전체 예약 내역 -->
      <div class="card-pad fade-up">
        <div class="w-header" style="margin-bottom:20px;">
          <h2 class="section-icon">
            <svg viewBox="0 0 24 24"><rect x="3" y="4" width="18" height="18" rx="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
            전체 예약 내역
          </h2>
          <span style="font-size:13px; color:var(--muted);" id="resCount"></span>
        </div>

        <div class="res-filter-container">
          <span class="filter-label">예약일</span>
          <input type="date" id="resStartDate">
          <span style="color:var(--muted); font-weight:800;">~</span>
          <input type="date" id="resEndDate">
          <select id="resSearchType" style="width:120px;">
            <option value="name">숙소명</option>
            <option value="id">예약번호</option>
          </select>
          <input type="text" id="resKeyword" placeholder="검색어 입력..." style="flex:1; min-width:120px;"
                 onkeyup="if(event.key==='Enter') filterReservations()">
          <button class="search-btn-black" onclick="filterReservations()">검색</button>
        </div>

        <div class="table-responsive">
          <table>
            <thead>
              <tr>
                <th>예약 번호</th><th>숙소명</th><th>예약일</th><th>체크인 / 체크아웃</th><th>결제 금액</th><th>상태</th>
              </tr>
            </thead>
            <tbody id="resTableBody">
            <c:forEach var="book" items="${bookingList}">
              <tr style="cursor:pointer;"
                  onclick="openResModal('${book.resId}','${book.roomName}','${book.duration}','${book.totalPrice}','${book.statusText}')"
                  data-status="${book.statusText}"
                  data-name="${book.roomName}"
                  data-resdate="${book.resDate}">
                <td style="color:var(--muted); font-weight:700;">#${book.resId}</td>
                <td><strong>${book.roomName}</strong></td>
                <td style="color:var(--muted);">${book.resDate}</td>
                <td>${book.duration}</td>
                <td class="num">₩ ${book.totalPrice}</td>
                <td><span class="badge ${book.statusClass}">${book.statusText}</span></td>
              </tr>
            </c:forEach>
            <c:if test="${empty bookingList}">
              <tr id="emptyRow"><td colspan="6" style="text-align:center; padding:30px; color:var(--muted);">예약 내역이 없습니다.</td></tr>
            </c:if>
            </tbody>
          </table>
        </div>
      </div>

    </main>
  </div>
</div>

<!-- ══════════════════════════════════════════
  모달 A : 예약 영수증
══════════════════════════════════════════ -->
<div class="modal-overlay" id="resModal">
  <div class="modal-receipt">
    <div id="receiptArea" class="receipt-body">
      <div class="receipt-header">
        <div>
          <h2>예약 상세 정보</h2>
          <p style="color:var(--muted); font-size:14px; margin-top:6px;" id="md_orderId"></p>
        </div>
        <span class="badge badge-done" id="md_status" style="padding:8px 16px; font-size:13px;"></span>
      </div>
      <div class="receipt-main">
        <div class="r-section">
          <h4>예약 기본 정보</h4>
          <dl class="info-list" style="gap:14px;">
            <div class="info-row"><dt>숙소 및 객실명</dt><dd id="md_name"></dd></div>
            <div class="info-row"><dt>체크인 ~ 체크아웃</dt><dd id="md_date"></dd></div>
          </dl>
        </div>
        <div class="r-section">
          <h4>결제 상세 내역</h4>
          <div class="price-table">
            <div class="price-row"><span>총 예약 금액</span><strong id="md_price"></strong></div>
            <div class="price-total"><span>실제 결제</span><strong id="md_realPrice"></strong></div>
          </div>
        </div>
      </div>
    </div>
    <div class="receipt-actions">
      <button class="btn-modal btn-modal-ghost" onclick="closeResModal()">닫기</button>
      <button class="btn-modal btn-modal-black" onclick="downloadReceipt()">결제 영수증 다운로드</button>
    </div>
  </div>
</div>

<!-- ══════════════════════════════════════════
  모달 B : 즉시 활동 정지 / 상태 변경
══════════════════════════════════════════ -->
<div class="modal-overlay" id="suspendModal">
  <div class="modal-sheet">

    <div class="ms-head danger-head">
      <div class="ms-danger-icon">
        <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><line x1="4.93" y1="4.93" x2="19.07" y2="19.07"/></svg>
      </div>
      <h3>회원 상태 변경</h3>
      <p>변경 사항은 즉시 적용됩니다.</p>
    </div>

    <div class="ms-body">
      <input type="hidden" id="suspendMemberId" value="${member.memberId}">
      <div class="fg">
        <label>대상 회원</label>
        <input type="text" id="suspendMemberDisplay"
               value="${member.nickname} (${member.email})" readonly>
      </div>
      <div class="fg">
        <label>변경할 상태</label>
        <select id="suspendStatusSelect">
          <option value="1" ${member.status == '1' ? 'selected' : ''}>정상 활동</option>
          <option value="2" ${member.status == '2' ? 'selected' : ''}>활동 정지</option>
          <option value="3" ${member.status == '3' ? 'selected' : ''}>휴면</option>
          <option value="4" ${member.status == '4' ? 'selected' : ''}>탈퇴</option>
        </select>
      </div>
      <div class="fg">
        <label>처리 사유 <span style="color:var(--danger);">*</span></label>
        <textarea id="suspendReasonInput" placeholder="정지/탈퇴 처리 시 사유를 반드시 입력하세요."></textarea>
      </div>
    </div>

    <div class="ms-foot">
      <button class="btn-modal btn-modal-ghost"  onclick="closeSuspendModal()">취소</button>
      <button class="btn-modal btn-modal-danger"  onclick="saveSuspendStatus()">변경 적용</button>
    </div>

  </div>
</div>

<!-- ══════════════════════════════════════════
  모달 C : 뱃지 수동 부여
══════════════════════════════════════════ -->
<div class="modal-overlay" id="badgeAddModal">
  <div class="modal-sheet">

    <div class="ms-head">
      <h3>뱃지 수동 부여</h3>
      <p>${member.nickname} 회원에게 뱃지를 부여합니다.</p>
    </div>

    <div class="ms-body">
      <div class="fg">
        <label>뱃지 선택</label>
        <select id="badgeSelectInput">
          <option value="">-- 뱃지를 선택하세요 --</option>
          <option value="first_review"   data-icon="✍️">첫 리뷰 작성</option>
          <option value="review_master"  data-icon="🏆">리뷰 마스터</option>
          <option value="passionate"     data-icon="🔥">열정 여행러</option>
          <option value="regular"        data-icon="⭐">단골 손님</option>
          <option value="explorer"       data-icon="🗺️">탐험가</option>
          <option value="vip"            data-icon="💎">VIP 회원</option>
        </select>
      </div>
      <div class="fg">
        <label>부여 일자</label>
        <input type="date" id="badgeDateInput">
      </div>
      <div class="fg">
        <label>관리자 메모 (선택)</label>
        <textarea id="badgeMemoInput" placeholder="부여 사유나 특이사항을 기록하세요." style="min-height:72px;"></textarea>
      </div>
    </div>

    <div class="ms-foot">
      <button class="btn-modal btn-modal-ghost" onclick="closeBadgeAddModal()">취소</button>
      <button class="btn-modal btn-modal-black" onclick="saveBadge()">뱃지 부여</button>
    </div>

  </div>
</div>

<script>
const contextPath = '${pageContext.request.contextPath}';

/* ── 뱃지 카운트 초기화 ── */
(function initBadgeCount() {
  const cnt = document.querySelectorAll('#badgeListContainer .badge-manage-row').length;
  document.getElementById('badgeCount').textContent = cnt + '개 보유';
})();

/* ── 뱃지 삭제 ── */
function removeBadge(btn, badgeId) {
  if (!confirm('이 뱃지를 삭제하시겠습니까?')) return;
  // TODO: fetch DELETE /admin/member/badge/{badgeId}
  btn.closest('.badge-manage-row').remove();
  refreshBadgeCount();
}
function refreshBadgeCount() {
  const cnt = document.querySelectorAll('#badgeListContainer .badge-manage-row').length;
  document.getElementById('badgeCount').textContent = cnt + '개 보유';
}

/* ── 뱃지 부여 모달 ── */
function openBadgeAddModal() {
  document.getElementById('badgeDateInput').value = new Date().toISOString().slice(0,10);
  document.getElementById('badgeAddModal').style.display = 'flex';
}
function closeBadgeAddModal() {
  document.getElementById('badgeAddModal').style.display = 'none';
}
function saveBadge() {
  const sel  = document.getElementById('badgeSelectInput');
  const date = document.getElementById('badgeDateInput').value;

  if (!sel.value) { alert('부여할 뱃지를 선택해주세요.'); return; }
  if (!date)      { alert('부여 일자를 입력해주세요.'); return; }

  const opt      = sel.options[sel.selectedIndex];
  const icon     = opt.getAttribute('data-icon') || '🏅';
  const badgeName = opt.text;   // ★ 핵심 수정: text 그대로 사용

  // TODO: fetch POST /admin/member/badge
  const newId = Date.now();
  document.getElementById('badgeListContainer').insertAdjacentHTML('beforeend', `
    <div class="badge-manage-row" data-badge-id="${newId}">
      <div class="badge-info">
        <div class="badge-icon-wrap">${icon}</div>
        <div class="badge-meta">
          <strong>${badgeName}</strong>
          <span>획득일: ${date}</span>
        </div>
      </div>
      <button class="btn-badge-del" onclick="removeBadge(this,${newId})">삭제</button>
    </div>
  `);

  refreshBadgeCount();
  closeBadgeAddModal();
  sel.value = '';
  document.getElementById('badgeMemoInput').value = '';
}

/* ── 즉시 활동 정지 모달 ── */
function openSuspendModal() {
  document.getElementById('suspendReasonInput').value = '';
  document.getElementById('suspendModal').style.display = 'flex';
}
function closeSuspendModal() {
  document.getElementById('suspendModal').style.display = 'none';
}
function saveSuspendStatus() {
  const newStatus = document.getElementById('suspendStatusSelect').value;
  const reason    = document.getElementById('suspendReasonInput').value.trim();

  if ((newStatus === '2' || newStatus === '4') && !reason) {
    alert('활동 정지 또는 탈퇴 처리 시 반드시 사유를 입력해야 합니다.');
    document.getElementById('suspendReasonInput').focus();
    return;
  }

  const memberId = document.getElementById('suspendMemberId').value;

  fetch(contextPath + '/admin/member/status', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      memberId:   parseInt(memberId),
      statusCode: parseInt(newStatus),
      memo:       reason
    })
  })
  .then(res => {
    if (!res.ok) throw new Error('서버 오류');
    const map = {
      '1': { text:'정상 활동', cls:'badge badge-done'   },
      '2': { text:'활동 정지', cls:'badge badge-danger'  },
      '3': { text:'휴면',      cls:'badge badge-wait'    },
      '4': { text:'탈퇴',      cls:'badge badge-wait'    }
    };
    const s  = map[newStatus];
    const el = document.getElementById('profileStatusBadge');
    if (el && s) { el.textContent = s.text; el.className = s.cls; }
    closeSuspendModal();
    alert('회원 상태가 변경되었습니다.');
  })
  .catch(() => alert('상태 변경 중 오류가 발생했습니다.'));
}

/* ── 예약 영수증 모달 ── */
function openResModal(id, name, date, price, status) {
  document.getElementById('md_orderId').textContent  = '주문번호: #' + id;
  document.getElementById('md_name').textContent     = name;
  document.getElementById('md_date').textContent     = date;
  document.getElementById('md_price').textContent    = price + ' 원';
  document.getElementById('md_realPrice').textContent = price + ' 원';
  const b = document.getElementById('md_status');
  b.textContent = status;
  b.className   = status === '예약 취소' ? 'badge badge-danger'
                : status === '예약 확정' ? 'badge badge-done'
                : 'badge badge-wait';
  document.getElementById('resModal').style.display = 'flex';
}
function closeResModal() { document.getElementById('resModal').style.display = 'none'; }
function downloadReceipt() {
  html2canvas(document.getElementById('receiptArea'), { scale:2, backgroundColor:'#fff' }).then(c => {
    const a = document.createElement('a');
    a.download = 'Tripan_영수증_' + Date.now() + '.png';
    a.href = c.toDataURL('image/png');
    a.click();
  });
}

/* ── 예약 필터 (예약일 기준) ── */
function filterReservations() {
  const s   = document.getElementById('resStartDate').value;
  const e   = document.getElementById('resEndDate').value;
  const kw  = document.getElementById('resKeyword').value.toLowerCase().trim();
  const type= document.getElementById('resSearchType').value;
  const sd  = s ? new Date(s) : null;
  const ed  = e ? new Date(e) : null;

  let cnt = 0;
  document.querySelectorAll('#resTableBody tr[data-resdate]').forEach(row => {
    const rd   = row.dataset.resdate ? new Date(row.dataset.resdate) : null;
    const inRange = (!sd && !ed) || (rd && (!sd||rd>=sd) && (!ed||rd<=ed));
    const target  = type==='name' ? (row.dataset.name||'').toLowerCase()
                  : row.querySelector('td')?.textContent.toLowerCase()||'';
    const match = inRange && (!kw || target.includes(kw));
    row.style.display = match ? '' : 'none';
    if (match) cnt++;
  });
  const el = document.getElementById('resCount');
  if (el) el.textContent = '검색 결과: ' + cnt + '건';
}

/* ── 오버레이 클릭 닫기 ── */
window.addEventListener('click', e => {
  if (e.target.classList.contains('modal-overlay')) {
    closeResModal(); closeSuspendModal(); closeBadgeAddModal();
  }
});
</script>

<script src="${pageContext.request.contextPath}/dist/js/admin/memberDetail.js"></script>
</body>
</html>
