<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"   uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn"  uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <title>TripanSuper — 회원 상세 정보</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/dist/css/admin.css">
  <script src="https://cdnjs.cloudflare.com/ajax/libs/html2canvas/1.4.1/html2canvas.min.js"></script>
  <style>
    .section-icon { display:inline-flex; align-items:center; gap:8px; }
    .section-icon svg { width:18px; height:18px; stroke:currentColor; fill:none; stroke-width:2; stroke-linecap:round; stroke-linejoin:round; flex-shrink:0; }
    .profile-header-card { display:flex; gap:24px; padding:28px 32px; align-items:center; background:#fff; border-radius:20px; box-shadow:var(--shadow-sm); margin-bottom:20px; }
    .profile-img-lg { width:80px; height:80px; border-radius:50%; object-fit:cover; border:3px solid var(--bg); box-shadow:var(--shadow-sm); flex-shrink:0; }
    .profile-main-info h2 { font-size:22px; font-weight:900; margin-bottom:8px; display:flex; align-items:center; gap:10px; flex-wrap:wrap; }
    .profile-bio { color:var(--muted); font-size:14px; margin-bottom:4px; }
    .detail-grid { display:grid; grid-template-columns:1fr 1fr; gap:20px; margin-bottom:20px; }
    @media (max-width:900px) { .detail-grid { grid-template-columns:1fr; } }
    .card-pad { padding:24px 28px; background:#fff; border-radius:20px; box-shadow:var(--shadow-sm); }
    .info-list { display:flex; flex-direction:column; gap:16px; }
    .info-row dt { font-size:11px; font-weight:800; color:var(--muted); margin-bottom:4px; text-transform:uppercase; letter-spacing:.04em; }
    .info-row dd { font-size:14px; font-weight:700; color:var(--text); }
    .info-row dd.clickable { cursor:pointer; color:var(--primary); text-decoration:underline dotted; }
    .info-row dd.clickable:hover { opacity:.8; }
    .res-filter-container { display:flex; gap:10px; margin-bottom:20px; align-items:center; background:#F8FAFC; padding:14px 18px; border-radius:14px; border:1px solid var(--border); flex-wrap:wrap; }
    .res-filter-container input[type="date"], .res-filter-container select, .res-filter-container input[type="text"] { height:38px; border:1px solid var(--border); border-radius:9px; padding:0 12px; font-size:13px; font-weight:600; background:#fff; outline:none; }
    .filter-label { font-size:12px; font-weight:800; color:var(--muted); white-space:nowrap; }
    .search-btn-black { height:38px; padding:0 20px; background:#000; color:#fff; border-radius:9px; font-weight:800; border:none; cursor:pointer; font-size:13px; }
    .modal-overlay { position:fixed; inset:0; background:rgba(15,23,42,.55); backdrop-filter:blur(6px); display:none; justify-content:center; align-items:center; z-index:3000; padding:24px; }
    .modal-receipt { background:#fff; width:100%; max-width:700px; border-radius:24px; box-shadow:0 24px 64px rgba(0,0,0,.18); overflow:hidden; animation:modalUp .35s cubic-bezier(.16,1,.3,1); }
    .modal-sheet { background:#fff; width:100%; max-width:520px; border-radius:20px; box-shadow:0 24px 64px rgba(0,0,0,.18); overflow:hidden; animation:modalUp .35s cubic-bezier(.16,1,.3,1); display:flex; flex-direction:column; }
    @keyframes modalUp { from{opacity:0;transform:translateY(20px) scale(.98)} to{opacity:1;transform:translateY(0) scale(1)} }
    .ms-head { padding:24px 28px 18px; border-bottom:1px solid var(--border); }
    .ms-head.danger-head { background:linear-gradient(135deg,#FFF1F1,#FFE8E8); border-bottom-color:#FFD0D0; }
    .ms-danger-icon { width:38px; height:38px; border-radius:10px; background:var(--danger); display:flex; align-items:center; justify-content:center; margin-bottom:10px; }
    .ms-danger-icon svg { width:18px; height:18px; stroke:#fff; fill:none; stroke-width:2.2; stroke-linecap:round; stroke-linejoin:round; }
    .ms-head h3 { font-size:16px; font-weight:900; margin:0 0 3px; }
    .ms-head p  { font-size:13px; color:var(--muted); margin:0; }
    .ms-head.danger-head h3 { color:var(--danger); }
    .ms-body { padding:20px 28px; display:flex; flex-direction:column; gap:16px; overflow-y:auto; max-height:65vh; }
    .ms-foot { padding:16px 28px; border-top:1px solid var(--border); display:flex; gap:10px; }
    .fg { display:flex; flex-direction:column; gap:7px; }
    .fg label { font-size:11px; font-weight:800; color:var(--muted); text-transform:uppercase; letter-spacing:.06px; }
    .fg select, .fg textarea, .fg input[type="text"] { width:100%; border:1.5px solid var(--border); border-radius:9px; padding:9px 12px; font-size:14px; font-weight:600; background:#fff; outline:none; box-sizing:border-box; font-family:inherit; color:var(--text); }
    .fg input[readonly] { background:var(--bg); color:var(--muted); cursor:default; }
    .fg textarea { resize:vertical; min-height:80px; line-height:1.5; }
    .btn-modal { flex:1; height:44px; border-radius:11px; font-weight:800; font-size:14px; border:none; cursor:pointer; }
    .btn-modal-ghost  { background:var(--bg); color:var(--text); }
    .btn-modal-black  { background:#111; color:#fff; }
    .btn-modal-danger { background:var(--danger); color:#fff; }
    .receipt-body { padding:36px 40px; }
    .receipt-header { display:flex; justify-content:space-between; align-items:flex-start; margin-bottom:24px; padding-bottom:18px; border-bottom:2px solid #111; }
    .receipt-header h2 { font-size:22px; font-weight:900; }
    .receipt-main { display:grid; grid-template-columns:1.2fr 1fr; gap:28px; }
    .r-section h4 { font-size:12px; font-weight:900; color:var(--muted); margin-bottom:14px; text-transform:uppercase; letter-spacing:1px; }
    .price-table { background:#F8FAFC; padding:18px 20px; border-radius:12px; border:1px solid var(--border); }
    .price-row { display:flex; justify-content:space-between; margin-bottom:9px; font-weight:700; color:var(--muted); font-size:13px; }
    .price-row.discount strong { color:#C2410C; }
    .price-divider { border:none; border-top:1px dashed var(--border); margin:12px 0; }
    .price-total { display:flex; justify-content:space-between; font-size:16px; font-weight:900; color:var(--primary); }
    .receipt-actions { padding:18px 40px; background:#fff; border-top:1px solid var(--border); display:flex; gap:10px; }
    .num { font-variant-numeric:tabular-nums; font-weight:700; }
    .badge { display:inline-flex; align-items:center; padding:4px 10px; border-radius:20px; font-size:12px; font-weight:700; white-space:nowrap; }
    .badge-done   { background:rgba(16,185,129,.12); color:#059669; }
    .badge-danger { background:rgba(239,68,68,.10);  color:#DC2626; }
    .badge-wait   { background:rgba(245,158,11,.12); color:#D97706; }
    .history-table { width:100%; border-collapse:collapse; font-size:13px; }
    .history-table th { padding:8px 12px; font-size:11px; font-weight:800; color:var(--muted); text-transform:uppercase; border-bottom:2px solid var(--border); text-align:left; }
    .history-table td { padding:10px 12px; border-bottom:1px solid var(--border-light,#F3F4F6); vertical-align:middle; }
    .history-table tbody tr:last-child td { border-bottom:none; }
    .point-plus  { color:#059669; font-weight:800; }
    .point-minus { color:#DC2626; font-weight:800; }
    .loading-msg { text-align:center; padding:32px; color:var(--muted); font-size:13px; }
    .toast { position:fixed; bottom:28px; left:50%; transform:translateX(-50%) translateY(16px); background:#111; color:#fff; padding:12px 22px; border-radius:14px; font-size:13px; font-weight:600; z-index:2000; opacity:0; transition:opacity .22s, transform .22s; pointer-events:none; white-space:nowrap; }
    .toast.show { opacity:1; transform:translateX(-50%) translateY(0); }
  </style>
</head>
<body>
<div class="admin-layout">
  <jsp:include page="../layout/sidebar.jsp"><jsp:param name="activePage" value="members"/></jsp:include>
  <div class="main-wrapper">
    <jsp:include page="../layout/header.jsp" />
    <main class="main-content">

      <div class="page-header fade-up">
        <div>
          <button class="btn btn-ghost btn-sm" onclick="history.back()" style="margin-bottom:10px;">← 목록으로</button>
          <h1>회원 상세 정보</h1>
        </div>
        <div class="header-actions">
          <button class="btn btn-primary" onclick="openSuspendModal()"
            style="background:var(--danger);display:inline-flex;align-items:center;gap:8px;border-radius:9999px;">
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
              <path d="M12 20h9"/><path d="M16.5 3.5a2.121 2.121 0 0 1 3 3L7 19l-4 1 1-4L16.5 3.5z"/>
            </svg>
            멤버 상태/역할 변경
          </button>
        </div>
      </div>

      <!-- 프로필 카드 -->
      <div class="card profile-header-card fade-up">
        <img src="${not empty member.profilePhoto 
    ? pageContext.request.contextPath.concat('/uploads/member/').concat(member.profilePhoto)
    : pageContext.request.contextPath.concat('/dist/images/default-avatar.png')}"
     class="profile-img-lg"
     onerror="this.src='https://ui-avatars.com/api/?name=${member.nickname}&background=3B6EF8&color=fff&size=80'">
        <div class="profile-main-info">
          <h2>
            ${not empty member.nickname ? member.nickname : '이름없음'}
            <span class="badge" id="profileRoleBadge" style="background:var(--bg);color:var(--text);">${member.role}</span>
            <c:choose>
              <c:when test="${member.statusCode == 1}"><span class="badge badge-done"   id="profileStatusBadge">정상 활동</span></c:when>
              <c:when test="${member.statusCode == 2}"><span class="badge badge-danger" id="profileStatusBadge">활동 정지</span></c:when>
              <c:when test="${member.statusCode == 3}"><span class="badge badge-wait"   id="profileStatusBadge">휴면</span></c:when>
              <c:otherwise><span class="badge badge-wait" id="profileStatusBadge">탈퇴</span></c:otherwise>
            </c:choose>
          </h2>
          <p class="profile-bio">${member.email}</p>
          <p class="profile-bio" style="font-size:12px;">신고 ${member.reportCount}건</p>
        </div>
      </div>

      <!-- 2단 그리드 -->
      <div class="detail-grid fade-up">
        <div class="card-pad">
          <div class="w-header" style="margin-bottom:18px;">
            <h2 class="section-icon">
              <svg viewBox="0 0 24 24"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
              기본 정보
            </h2>
          </div>
          <dl class="info-list">
            <div class="info-row"><dt>사용자 ID (이메일)</dt><dd>${member.email}</dd></div>
            <div class="info-row"><dt>이름</dt><dd>${not empty member.username ? member.username : '-'}</dd></div>
            <div class="info-row"><dt>전화번호</dt><dd>${not empty member.phoneNumber ? member.phoneNumber : '-'}</dd></div>
            <div class="info-row"><dt>생일</dt><dd>${not empty member.birthday ? member.birthday : '-'}</dd></div>
            <hr style="border:0;height:1px;background:var(--border);margin:2px 0;">
            <div class="info-row">
              <dt>가입 일시</dt>
              <dd>${not empty member.regDate ? fn:substring(member.regDate, 0, 10) : '-'}</dd>
            </div>
            <div class="info-row"><dt>마지막 접속</dt><dd>${not empty member.lastLoginAt ? member.lastLoginAt : '-'}</dd></div>
          </dl>
        </div>

        <div class="card-pad">
          <div class="w-header" style="margin-bottom:18px;">
            <h2 class="section-icon">
              <svg viewBox="0 0 24 24"><polyline points="22 12 18 12 15 21 9 3 6 12 2 12"/></svg>
              활동 요약
            </h2>
          </div>
          <dl class="info-list">
            <div class="info-row"><dt>총 예약 횟수</dt><dd>${not empty bookingList ? fn:length(bookingList) : 0}건</dd></div>
            <div class="info-row">
              <dt>총 결제 금액</dt>
              <dd>
                <c:set var="totalPaid" value="0"/>
                <c:forEach var="b" items="${bookingList}">
                  <c:if test="${b.statusText == 'SUCCESS'}">
                    <c:set var="totalPaid" value="${totalPaid + b.realTotalAmount}"/>
                  </c:if>
                </c:forEach>
                <fmt:formatNumber value="${totalPaid}" pattern="#,###"/>원
              </dd>
            </div>
            <%-- 포인트 클릭 → 내역 모달 --%>
            <div class="info-row">
              <dt>포인트 잔액</dt>
              <dd class="clickable" onclick="openPointModal(${member.memberId})">
                <fmt:formatNumber value="${member.pointBalance}" pattern="#,###"/>P
                <span style="font-size:11px;color:var(--muted);margin-left:4px;">▶ 내역 보기</span>
              </dd>
            </div>
            <%-- 쿠폰 클릭 → 보유 쿠폰 모달 --%>
            <div class="info-row">
              <dt>보유 쿠폰</dt>
              <dd class="clickable" onclick="openCouponModal(${member.memberId})">
                ${member.couponCount}개
                <span style="font-size:11px;color:var(--muted);margin-left:4px;">▶ 내역 보기</span>
              </dd>
            </div>
            <hr style="border:0;height:1px;background:var(--border);margin:2px 0;">
            <div class="info-row">
              <dt>신고 횟수</dt>
              <dd style="color:${member.reportCount > 0 ? 'var(--danger)' : 'var(--text)'};">${member.reportCount}건</dd>
            </div>
          </dl>
        </div>
      </div>

      <!-- 전체 예약 내역 -->
      <div class="card-pad fade-up">
        <div class="w-header" style="margin-bottom:18px;">
          <h2 class="section-icon">
            <svg viewBox="0 0 24 24"><rect x="3" y="4" width="18" height="18" rx="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
            전체 예약 내역
          </h2>
          <span style="font-size:13px;color:var(--muted);" id="resCount"></span>
        </div>
        <div class="res-filter-container">
          <span class="filter-label">체크인일</span>
          <input type="date" id="resStartDate">
          <span style="color:var(--muted);font-weight:800;">~</span>
          <input type="date" id="resEndDate">
          <select id="resSearchType" style="width:110px;">
            <option value="name">숙소명</option>
            <option value="id">예약번호</option>
          </select>
          <input type="text" id="resKeyword" placeholder="검색어 입력..." style="flex:1;min-width:120px;"
                 onkeyup="if(event.key==='Enter') filterReservations()">
          <button class="search-btn-black" onclick="filterReservations()">검색</button>
        </div>
        <div class="table-responsive">
          <table>
            <thead>
              <tr>
                <th>예약 번호</th><th>숙소명 / 객실명</th><th>체크인 / 체크아웃</th><th>결제 금액</th><th>상태</th>
              </tr>
            </thead>
            <tbody id="resTableBody">
            <c:forEach var="book" items="${bookingList}">
              <tr style="cursor:pointer;" onclick="openResModal(this)"
                  data-resid="${book.resId}"
                  data-place="${fn:escapeXml(book.placeName)}"
                  data-room="${fn:escapeXml(book.roomName)}"
                  data-checkin="${book.checkInDate}"
                  data-checkout="${book.checkOutDate}"
                  data-total="${book.totalAmount}"
                  data-coupon="${book.couponDiscount}"
                  data-point="${book.pointDiscount}"
                  data-real="${book.realTotalAmount}"
                  data-status="${book.statusText}"
                  data-name="${fn:escapeXml(book.placeName)}"
                  data-resdate="${book.checkInDate}">
                <td style="color:var(--muted);font-weight:700;">${book.resId}</td>
                <td><strong>${book.placeName}</strong><br><small style="color:var(--muted);font-size:12px;">${book.roomName}</small></td>
                <td style="color:var(--muted);">${book.checkInDate} ~ ${book.checkOutDate}</td>
                <td class="num">${book.totalPrice}</td>
                <td><span class="badge ${book.statusClass}">${book.statusText}</span></td>
              </tr>
            </c:forEach>
            <c:if test="${empty bookingList}">
              <tr><td colspan="5" style="text-align:center;padding:32px;color:var(--muted);">예약 내역이 없습니다.</td></tr>
            </c:if>
            </tbody>
          </table>
        </div>
      </div>

    </main>
  </div>
</div>

<!-- 모달 A: 예약 영수증 -->
<div class="modal-overlay" id="resModal">
  <div class="modal-receipt">
    <div id="receiptArea" class="receipt-body">
      <div class="receipt-header">
        <div>
          <h2>예약 상세 정보</h2>
          <p style="color:var(--muted);font-size:13px;margin-top:4px;" id="md_orderId"></p>
        </div>
        <span class="badge badge-done" id="md_status" style="padding:7px 14px;font-size:12px;"></span>
      </div>
      <div class="receipt-main">
        <div class="r-section">
          <h4>예약 기본 정보</h4>
          <dl class="info-list" style="gap:12px;">
            <div class="info-row"><dt>숙소명</dt><dd id="md_placeName"></dd></div>
            <div class="info-row"><dt>객실명</dt><dd id="md_roomName"></dd></div>
            <div class="info-row"><dt>체크인 ~ 체크아웃</dt><dd id="md_date"></dd></div>
          </dl>
        </div>
        <div class="r-section">
          <h4>결제 상세 내역</h4>
          <div class="price-table">
            <div class="price-row"><span>총 예약 금액</span><strong id="md_price"></strong></div>
            <div class="price-row discount" id="md_couponRow" style="display:none;"><span>쿠폰 할인</span><strong id="md_coupon"></strong></div>
            <div class="price-row discount" id="md_pointRow" style="display:none;"><span>포인트 사용</span><strong id="md_point"></strong></div>
            <hr class="price-divider">
            <div class="price-total"><span>실제 결제</span><strong id="md_realPrice"></strong></div>
          </div>
        </div>
      </div>
    </div>
    <div class="receipt-actions">
      <button class="btn-modal btn-modal-ghost" onclick="closeResModal()">닫기</button>
      <button class="btn-modal btn-modal-black" onclick="downloadReceipt()">영수증 다운로드</button>
    </div>
  </div>
</div>

<!-- 모달 B: 상태/역할 변경 -->
<div class="modal-overlay" id="suspendModal">
  <div class="modal-sheet">
    <div class="ms-head danger-head">
      <div class="ms-danger-icon">
        <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><line x1="4.93" y1="4.93" x2="19.07" y2="19.07"/></svg>
      </div>
      <h3>회원 상태 / 역할 변경</h3>
      <p>변경 사항은 즉시 적용됩니다.</p>
    </div>
    <div class="ms-body">
      <input type="hidden" id="suspendMemberId" value="${member.memberId}">
      <div class="fg">
        <label>대상 회원</label>
        <input type="text" value="${member.nickname} (${member.email})" readonly>
      </div>
      <div class="fg">
        <label>변경할 상태</label>
        <select id="suspendStatusSelect">
          <option value="1" ${member.statusCode == 1 ? 'selected' : ''}>정상 활동</option>
          <option value="2" ${member.statusCode == 2 ? 'selected' : ''}>활동 정지</option>
          <option value="3" ${member.statusCode == 3 ? 'selected' : ''}>휴면</option>
          <option value="4" ${member.statusCode == 4 ? 'selected' : ''}>탈퇴</option>
        </select>
      </div>
      <div class="fg">
        <label>역할 변경</label>
        <select id="suspendRoleSelect">
          <option value="ROLE_USER"    ${member.role == 'ROLE_USER'    ? 'selected' : ''}>일반 회원</option>
          <option value="ROLE_PARTNER" ${member.role == 'ROLE_PARTNER' ? 'selected' : ''}>파트너</option>
          <option value="ROLE_ADMIN"   ${member.role == 'ROLE_ADMIN'   ? 'selected' : ''}>어드민</option>
        </select>
      </div>
      <div class="fg">
        <label>처리 사유 <span style="color:var(--danger);">*</span></label>
        <textarea id="suspendReasonInput" placeholder="정지/탈퇴 처리 시 사유를 반드시 입력하세요."></textarea>
      </div>
    </div>
    <div class="ms-foot">
      <button class="btn-modal btn-modal-ghost"  onclick="closeSuspendModal()">취소</button>
      <button class="btn-modal btn-modal-danger" onclick="saveSuspendStatus()">변경 적용</button>
    </div>
  </div>
</div>

<!-- 모달 C: 포인트 내역 -->
<div class="modal-overlay" id="pointModal">
  <div class="modal-sheet" style="max-width:600px;">
    <div class="ms-head">
      <h3>💰 포인트 내역</h3>
      <p id="pointModalSub"></p>
    </div>
    <div class="ms-body" style="padding:0;">
      <div id="pointModalContent" class="loading-msg">불러오는 중...</div>
    </div>
    <div class="ms-foot">
      <button class="btn-modal btn-modal-ghost" onclick="closePointModal()">닫기</button>
    </div>
  </div>
</div>

<!-- 모달 D: 보유 쿠폰 내역 -->
<div class="modal-overlay" id="couponModal">
  <div class="modal-sheet" style="max-width:600px;">
    <div class="ms-head">
      <h3>🎟️ 보유 쿠폰 내역</h3>
      <p id="couponModalSub"></p>
    </div>
    <div class="ms-body" style="padding:0;">
      <div id="couponModalContent" class="loading-msg">불러오는 중...</div>
    </div>
    <div class="ms-foot">
      <button class="btn-modal btn-modal-ghost" onclick="closeCouponModal()">닫기</button>
    </div>
  </div>
</div>

<div class="toast" id="toast"></div>

<script>
var contextPath = '${pageContext.request.contextPath}';

function showToast(msg) {
  var t = document.getElementById('toast');
  t.textContent = msg;
  t.classList.add('show');
  setTimeout(function() { t.classList.remove('show'); }, 2800);
}

/* ── 예약 영수증 모달 ── */
function openResModal(row) {
  var d = row.dataset;
  document.getElementById('md_orderId').textContent   = '예약번호: ' + d.resid;
  document.getElementById('md_placeName').textContent = d.place  || '-';
  document.getElementById('md_roomName').textContent  = d.room   || '-';
  document.getElementById('md_date').textContent      = d.checkin + ' ~ ' + d.checkout;
  document.getElementById('md_price').textContent     = '₩' + Number(d.total).toLocaleString('ko-KR');
  document.getElementById('md_realPrice').textContent = '₩' + Number(d.real).toLocaleString('ko-KR');
  var couponN = Number(d.coupon) || 0;
  var pointN  = Number(d.point)  || 0;
  var couponRow = document.getElementById('md_couponRow');
  var pointRow  = document.getElementById('md_pointRow');
  if (couponN > 0) { document.getElementById('md_coupon').textContent = '- ₩' + couponN.toLocaleString('ko-KR'); couponRow.style.display = 'flex'; }
  else { couponRow.style.display = 'none'; }
  if (pointN > 0)  { document.getElementById('md_point').textContent  = '- ₩' + pointN.toLocaleString('ko-KR');  pointRow.style.display  = 'flex'; }
  else { pointRow.style.display = 'none'; }
  var b = document.getElementById('md_status');
  b.textContent = d.status;
  b.className   = d.status === 'CANCELED' ? 'badge badge-danger' : d.status === 'SUCCESS' ? 'badge badge-done' : 'badge badge-wait';
  b.style.cssText = 'padding:7px 14px;font-size:12px;';
  document.getElementById('resModal').style.display = 'flex';
}
function closeResModal() { document.getElementById('resModal').style.display = 'none'; }

function downloadReceipt() {
  html2canvas(document.getElementById('receiptArea'), { scale:2, backgroundColor:'#fff' }).then(function(c) {
    var a = document.createElement('a');
    a.download = 'Tripan_영수증_' + Date.now() + '.png';
    a.href = c.toDataURL('image/png');
    a.click();
  });
}

/* ── 포인트 내역 모달 ── */
function openPointModal(memberId) {
  document.getElementById('pointModal').style.display = 'flex';
  document.getElementById('pointModalContent').innerHTML = '<div class="loading-msg">불러오는 중...</div>';
  fetch(contextPath + '/admin/member/point/' + memberId)
    .then(function(r) { return r.json(); })
    .then(function(list) {
      if (!list || list.length === 0) {
        document.getElementById('pointModalContent').innerHTML = '<div class="loading-msg">포인트 내역이 없습니다.</div>';
        document.getElementById('pointModalSub').textContent = '내역 없음';
        return;
      }
      var remPoint = list[0].remPoint || 0;
      document.getElementById('pointModalSub').textContent = '현재 잔액: ' + remPoint.toLocaleString('ko-KR') + 'P';
      var html = '<table class="history-table"><thead><tr><th>날짜</th><th>사유</th><th>변동</th><th>잔액</th></tr></thead><tbody>';
      list.forEach(function(p) {
        var cls = p.pointAmount >= 0 ? 'point-plus' : 'point-minus';
        var sign = p.pointAmount >= 0 ? '+' : '';
        html += '<tr>'
          + '<td style="color:var(--muted);">' + (p.regDate || '-') + '</td>'
          + '<td>' + (p.changeReason || '-') + '</td>'
          + '<td class="' + cls + '">' + sign + p.pointAmount.toLocaleString('ko-KR') + 'P</td>'
          + '<td class="num">' + (p.remPoint || 0).toLocaleString('ko-KR') + 'P</td>'
          + '</tr>';
      });
      html += '</tbody></table>';
      document.getElementById('pointModalContent').innerHTML = html;
    })
    .catch(function() {
      document.getElementById('pointModalContent').innerHTML = '<div class="loading-msg" style="color:var(--danger);">불러오기 실패</div>';
    });
}
function closePointModal() { document.getElementById('pointModal').style.display = 'none'; }

/* ── 보유 쿠폰 모달 ── */
function openCouponModal(memberId) {
  document.getElementById('couponModal').style.display = 'flex';
  document.getElementById('couponModalContent').innerHTML = '<div class="loading-msg">불러오는 중...</div>';
  fetch(contextPath + '/admin/member/coupon/' + memberId)
    .then(function(r) { return r.json(); })
    .then(function(list) {
      if (!list || list.length === 0) {
        document.getElementById('couponModalContent').innerHTML = '<div class="loading-msg">보유 쿠폰이 없습니다.</div>';
        document.getElementById('couponModalSub').textContent = '보유 쿠폰 없음';
        return;
      }
      var unused = list.filter(function(c) { return c.status === 'AVAILABLE'; }).length;
      document.getElementById('couponModalSub').textContent = '사용 가능: ' + unused + '개 / 전체: ' + list.length + '개';
      var statusMap = { unused:'badge-done', used:'badge-wait', cancelled:'badge-danger', expired:'badge-danger' };
      var statusLbl = { unused:'사용가능', used:'사용완료', cancelled:'취소', expired:'만료' };
      var html = '<table class="history-table"><thead><tr><th>쿠폰명</th><th>할인</th><th>만료일</th><th>상태</th></tr></thead><tbody>';
      list.forEach(function(c) {
        var discTxt = c.discountType === 'PERCENT'
          ? c.discountAmount + '%'
          : '₩' + (c.discountAmount || 0).toLocaleString('ko-KR');
        var expTxt = c.expiredAt ? c.expiredAt.toString().substring(0, 10) : '-';
        var cls = statusMap[c.status] || 'badge-wait';
        var lbl = statusLbl[c.status] || c.status;
        html += '<tr>'
          + '<td><strong>' + (c.couponName || '-') + '</strong></td>'
          + '<td class="num" style="color:var(--primary);">' + discTxt + '</td>'
          + '<td style="color:var(--muted);">' + expTxt + '</td>'
          + '<td><span class="badge ' + cls + '">' + lbl + '</span></td>'
          + '</tr>';
      });
      html += '</tbody></table>';
      document.getElementById('couponModalContent').innerHTML = html;
    })
    .catch(function() {
      document.getElementById('couponModalContent').innerHTML = '<div class="loading-msg" style="color:var(--danger);">불러오기 실패</div>';
    });
}
function closeCouponModal() { document.getElementById('couponModal').style.display = 'none'; }

/* ── 예약 필터 ── */
function filterReservations() {
  var s = document.getElementById('resStartDate').value;
  var e = document.getElementById('resEndDate').value;
  var kw = document.getElementById('resKeyword').value.toLowerCase().trim();
  var type = document.getElementById('resSearchType').value;
  var sd = s ? new Date(s) : null;
  var ed = e ? new Date(e) : null;
  var cnt = 0;
  document.querySelectorAll('#resTableBody tr[data-resdate]').forEach(function(row) {
    var rd = row.dataset.resdate ? new Date(row.dataset.resdate) : null;
    var inRange = (!sd && !ed) || (rd && (!sd || rd >= sd) && (!ed || rd <= ed));
    var target = type === 'name' ? (row.dataset.name || '').toLowerCase() : row.querySelector('td') ? row.querySelector('td').textContent.toLowerCase() : '';
    var match = inRange && (!kw || target.includes(kw));
    row.style.display = match ? '' : 'none';
    if (match) cnt++;
  });
  var el = document.getElementById('resCount');
  if (el) el.textContent = '검색 결과: ' + cnt + '건';
}

/* ── 상태/역할 변경 모달 ── */
function openSuspendModal() {
  document.getElementById('suspendReasonInput').value = '';
  document.getElementById('suspendModal').style.display = 'flex';
}
function closeSuspendModal() { document.getElementById('suspendModal').style.display = 'none'; }

function saveSuspendStatus() {
  var newStatus = document.getElementById('suspendStatusSelect').value;
  var newRole   = document.getElementById('suspendRoleSelect').value;
  var reason    = document.getElementById('suspendReasonInput').value.trim();
  var memberId  = document.getElementById('suspendMemberId').value;
  if ((newStatus === '2' || newStatus === '4') && !reason) {
    alert('활동 정지 또는 탈퇴 처리 시 반드시 사유를 입력해야 합니다.');
    return;
  }
  fetch(contextPath + '/admin/member/status', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ memberId: parseInt(memberId), statusCode: parseInt(newStatus), role: newRole, memo: reason })
  })
  .then(function(res) { if (!res.ok) throw new Error('서버 오류'); return res.json(); })
  .then(function() {
    var statusMap = { '1':{text:'정상 활동',cls:'badge badge-done'}, '2':{text:'활동 정지',cls:'badge badge-danger'}, '3':{text:'휴면',cls:'badge badge-wait'}, '4':{text:'탈퇴',cls:'badge badge-wait'} };
    var s = statusMap[newStatus];
    var el = document.getElementById('profileStatusBadge');
    if (el && s) { el.textContent = s.text; el.className = s.cls; }
    var roleEl = document.getElementById('profileRoleBadge');
    if (roleEl) roleEl.textContent = newRole;
    closeSuspendModal();
    showToast('회원 정보가 변경되었습니다.');
  })
  .catch(function() { showToast('변경 중 오류가 발생했습니다.'); });
}

/* ── 오버레이 클릭 닫기 ── */
window.addEventListener('click', function(e) {
  if (e.target.classList.contains('modal-overlay')) {
    closeResModal(); closeSuspendModal(); closePointModal(); closeCouponModal();
  }
});
</script>

<script src="${pageContext.request.contextPath}/dist/js/admin/member.js"></script>
</body>
</html>
