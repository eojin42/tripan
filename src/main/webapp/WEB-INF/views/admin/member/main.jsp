<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <title>TripanSuper — 회원 관리</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/dist/css/admin.css">
  <style>
    .col-check { width: 44px; text-align: center; }
    input[type="checkbox"] { width: 16px; height: 16px; cursor: pointer; accent-color: var(--primary); }
    .col-id { user-select: text; -webkit-user-select: text; cursor: text; }

    .bulk-bar {
      display: none; align-items: center; gap: 12px;
      padding: 12px 20px; background: #EFF6FF;
      border: 1.5px solid #BFDBFE; border-radius: 14px;
      margin-bottom: 16px; animation: slideDown 0.2s ease;
    }
    .bulk-bar.visible { display: flex; }
    @keyframes slideDown { from { opacity:0; transform:translateY(-6px); } to { opacity:1; transform:translateY(0); } }
    .bulk-count { font-size: 13px; font-weight: 800; color: #1D4ED8; background: #DBEAFE; padding: 4px 12px; border-radius: 20px; }
    .bulk-bar-label { font-size: 13px; font-weight: 700; color: var(--text); }
    .bulk-bar-actions { display: flex; gap: 8px; margin-left: auto; }
    .btn-bulk { height: 36px; padding: 0 16px; border-radius: 9px; font-size: 13px; font-weight: 800; border: none; cursor: pointer; transition: opacity 0.15s; }
    .btn-bulk-status { background: #111; color: #fff; }
    .btn-bulk-excel  { background: var(--bg); color: var(--text); border: 1px solid var(--border); }
    .btn-bulk-copy   { background: #F0FDF4; color: #15803D; border: 1px solid #BBF7D0; }
    .btn-bulk:hover  { opacity: 0.8; }

    .modal-overlay {
      position: fixed; inset: 0; background: rgba(15,23,42,0.5);
      backdrop-filter: blur(6px); display: none;
      justify-content: center; align-items: center;
      z-index: 3000; padding: 24px;
    }
    .modal-sheet {
      background: #fff; width: 100%; max-width: 440px;
      border-radius: 22px; overflow: hidden;
      box-shadow: 0 24px 64px rgba(0,0,0,0.16);
      animation: modalUp 0.3s cubic-bezier(0.16,1,0.3,1);
      display: flex; flex-direction: column;
    }
    @keyframes modalUp { from{opacity:0;transform:translateY(20px)} to{opacity:1;transform:translateY(0)} }
    .ms-head    { padding: 26px 28px 18px; border-bottom: 1px solid var(--border); }
    .ms-head h3 { font-size: 17px; font-weight: 900; margin: 0 0 4px; }
    .ms-head p  { font-size: 13px; color: var(--muted); margin: 0; }
    .ms-body    { padding: 22px 28px; display: flex; flex-direction: column; gap: 16px; }
    .ms-foot    { padding: 16px 28px; border-top: 1px solid var(--border); display: flex; gap: 10px; }
    .fg         { display: flex; flex-direction: column; gap: 7px; }
    .fg label   { font-size: 11px; font-weight: 800; color: var(--muted); text-transform: uppercase; letter-spacing: 0.6px; }
    .fg select, .fg textarea, .fg input {
      width: 100%; border: 1.5px solid var(--border); border-radius: 10px;
      padding: 10px 14px; font-size: 14px; font-weight: 600;
      background: #fff; outline: none; transition: border-color 0.2s;
      box-sizing: border-box; font-family: inherit; color: var(--text);
    }
    .fg select:focus, .fg textarea:focus, .fg input:focus { border-color: var(--primary); box-shadow: 0 0 0 3px var(--primary-10); }
    .fg textarea { resize: vertical; min-height: 80px; line-height: 1.5; }
    .btn-m         { flex:1; height: 46px; border-radius: 11px; font-weight: 800; font-size: 14px; border: none; cursor: pointer; transition: opacity 0.15s; }
    .btn-m-ghost   { background: var(--bg); color: var(--text); }
    .btn-m-primary { background: #111; color: #fff; }
    .btn-m:hover   { opacity: 0.84; }
    .filter-row .btn { display: inline-flex; align-items: center; gap: 6px; }
    .btn-reset { background: var(--bg); color: var(--muted); border: 1.5px solid var(--border); border-radius: 10px; height: 38px; padding: 0 14px; font-size: 13px; font-weight: 700; cursor: pointer; display: inline-flex; align-items: center; gap: 5px; transition: all 0.15s; }
    .btn-reset:hover { background: #F1F5F9; color: var(--text); border-color: #94A3B8; }
    .btn-reset svg { transition: transform 0.35s cubic-bezier(0.34,1.56,0.64,1); }
    .btn-reset:hover svg { transform: rotate(-180deg); }
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
          <h1>회원 관리</h1>
          <p>전체 유저, 파트너 및 관리자의 권한과 상태를 통합 관리합니다.</p>
        </div>
      </div>

      <div class="kpi-grid">
        <div class="card kpi-card fade-up fade-up-1">
          <div class="kpi-label">전체 회원수</div>
          <div class="kpi-value" id="kpiTotal">${kpi.totalCount != null ? kpi.totalCount : 0}</div>
          <div class="kpi-sub">일반 ${kpi.userCount} / 파트너 ${kpi.partnerCount} / 관리자 ${kpi.adminCount}</div>
        </div>
        <div class="card kpi-card fade-up fade-up-2">
          <div class="kpi-label">신규 가입 (오늘)</div>
          <div class="kpi-value" id="kpiTodayNew">${kpi.todayNewCount != null ? kpi.todayNewCount : 0}명</div>
          <c:choose>
            <c:when test="${kpi.dailyTrend > 0}"><span class="trend" style="color:#ff4d4f;">↑ ${kpi.dailyTrend}%</span></c:when>
            <c:when test="${kpi.dailyTrend < 0}"><span class="trend" style="color:#1890ff;">↓ ${-kpi.dailyTrend}%</span></c:when>
            <c:otherwise><span class="trend" style="color:#999;">- 0%</span></c:otherwise>
          </c:choose>
        </div>
        <div class="card kpi-card fade-up fade-up-3">
          <div class="kpi-label">정상 활동 유저</div>
          <div class="kpi-value" style="color:var(--success)" id="kpiActive">${kpi.activeCount != null ? kpi.activeCount : 0}</div>
          <div class="kpi-sub">현재 서비스 이용 가능</div>
        </div>
        <div class="card kpi-card fade-up fade-up-4">
          <div class="kpi-label">활동 정지(Ban) 유저</div>
          <div class="kpi-value" style="color:var(--danger)" id="kpiBan">${kpi.banCount != null ? kpi.banCount : 0}</div>
          <div class="badge badge-danger">정책 위반 관리중</div>
        </div>
      </div>

      <div class="card filter-card fade-up">
        <div class="filter-row">
          <div class="filter-label">회원 검색</div>
          <select class="filter-select" id="searchRole" style="width:120px;">
            <option value="ALL">전체 권한</option>
            <option value="ROLE_USER">일반 유저</option>
            <option value="ROLE_PARTNER">파트너</option>
            <option value="ROLE_ADMIN">관리자</option>
          </select>
          <select class="filter-select" id="searchStatus" style="width:120px;">
            <option value="ALL">전체 상태</option>
            <option value="1">정상</option>
            <option value="2">정지(BAN)</option>
            <option value="3">휴면</option>
          </select>
          <select class="filter-select" id="searchCategory" style="width:120px;">
            <option value="id">ID</option>
            <option value="nickname">닉네임</option>
          </select>
          <input type="text" id="searchInput" class="keyword-input"
                 placeholder="여러 ID는 쉼표(,)로 구분해 붙여넣기"
                 onkeyup="if(event.key==='Enter') filterTable()" style="flex:1;">
          <button class="btn-reset" onclick="resetFilter()" title="검색 초기화">
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><polyline points="1 4 1 10 7 10"/><path d="M3.51 15a9 9 0 1 0 .49-3.51"/></svg>
            초기화
          </button>
          <button class="btn btn-primary" onclick="filterTable()">
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
            검색
          </button>
        </div>
      </div>

      <div class="card table-card fade-up">
        <div class="w-header" style="display:flex; justify-content:space-between; align-items:center; margin-bottom:16px;">
          <h2 style="display:inline-flex; align-items:center; gap:8px;">
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/>
              <path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/>
            </svg>
            회원 목록
          </h2>
          <button class="btn btn-outline btn-sm" onclick="downloadFilteredExcel(false)" style="display:inline-flex; align-items:center; gap:6px;">
            <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
              <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="7 10 12 15 17 10"/><line x1="12" y1="15" x2="12" y2="3"/>
            </svg>
            엑셀 다운로드
          </button>
        </div>

        <div class="bulk-bar" id="bulkBar">
          <span class="bulk-count" id="bulkCount">0명</span>
          <span class="bulk-bar-label">선택됨</span>
          <div class="bulk-bar-actions">
            <button class="btn-bulk btn-bulk-copy"   onclick="copySelectedIds()">ID 복사</button>
            <button class="btn-bulk btn-bulk-status" onclick="openBulkStatusModal()">상태 일괄 변경</button>
            <button class="btn-bulk btn-bulk-excel"  onclick="downloadFilteredExcel(true)">선택 엑셀</button>
          </div>
        </div>

        <div class="table-responsive">
          <table>
            <thead>
              <tr>
                <th class="col-check">
                  <input type="checkbox" id="checkAll" onchange="toggleCheckAll(this)" title="전체 선택">
                </th>
                <th>ID / 이메일</th>
                <th>닉네임</th>
                <th>권한 레벨</th>
                <th>상태</th>
                <th>위반 지표</th>
                <th style="cursor:pointer; user-select:none;" onclick="sortByDate()">
                  가입일 <span id="dateSortIcon">↕</span>
                </th>
                <th class="right">관리</th>
              </tr>
            </thead>
            <tbody id="memberTableBody">
              <%-- 초기엔 안내 메시지만. member-row 전부 display:none --%>
              <tr id="emptySearchMsg">
                <td colspan="8" style="text-align:center; padding:50px 0; color:var(--muted);">
                  상단의 검색 조건을 설정한 후 <strong>[검색]</strong> 버튼을 눌러주세요.
                </td>
              </tr>
              <c:forEach var="member" items="${list}">
                <tr class="member-row"
                    style="display:none;"
                    data-memberid="${member.memberId}"
                    data-email="${member.email}"
                    data-nickname="${member.nickname}"
                    data-role="${member.role}"
                    data-status="${member.statusCode}"
                    data-reason="${member.reason}">

                  <td class="col-check">
                    <input type="checkbox" class="row-check"
                           value="${member.loginId}"
                           data-memberid="${member.memberId}"
                           onchange="onRowCheck()" onclick="event.stopPropagation()">
                  </td>

                  <td class="col-id"><strong>${member.loginId}</strong></td>

                  <td class="col-nickname">
                    <a href="${pageContext.request.contextPath}/admin/member/detail/${member.memberId}"
                       style="color:inherit; font-weight:bold; text-decoration:none;"
                       onmouseover="this.style.textDecoration='underline'"
                       onmouseout="this.style.textDecoration='none'">
                      ${member.nickname}
                    </a>
                  </td>

                  <td>
                    <c:choose>
                      <c:when test="${member.role == 'ROLE_ADMIN'}"><span class="badge" style="background:#E0E7FF;color:#4338CA;">SYS ADMIN</span></c:when>
                      <c:when test="${member.role == 'ROLE_PARTNER'}"><span class="badge" style="background:#F0FDF4;color:#15803D;">PARTNER</span></c:when>
                      <c:otherwise><span class="badge">USER</span></c:otherwise>
                    </c:choose>
                  </td>

                  <td class="col-status">
                    <c:choose>
                      <c:when test="${member.statusCode == '2'}"><span class="badge badge-danger" onclick="showReason(event,'${member.reason}')">BAN(정지)</span></c:when>
                      <c:when test="${member.statusCode == '3'}"><span class="badge" style="background:#fef3c7;color:#b45309;">휴면</span></c:when>
                      <c:when test="${member.statusCode == '4'}"><span class="badge" style="background:var(--bg);color:var(--muted)">탈퇴 완료</span></c:when>
                      <c:otherwise><span class="badge badge-done">정상</span></c:otherwise>
                    </c:choose>
                  </td>

                  <td>
                    <c:choose>
                      <c:when test="${member.reportCount >= 5}"><span class="badge badge-alert">신고 ${member.reportCount}회</span></c:when>
                      <c:otherwise>-</c:otherwise>
                    </c:choose>
                  </td>

                  <td class="num date-cell">${not empty member.regDate ? fn:substring(member.regDate, 0, 10) : '-'}</td>

                  <td class="right">
                    <button class="btn btn-primary btn-sm"
                            onclick="location.href='${pageContext.request.contextPath}/admin/member/detail/${member.memberId}'">상세/수정</button>
                  </td>
                </tr>
              </c:forEach>
            </tbody>
          </table>
        </div>
      </div>

    </main>

    <div class="modal-overlay" id="bulkStatusModal">
      <div class="modal-sheet">
        <div class="ms-head">
          <h3>상태 일괄 변경</h3>
          <p id="bulkStatusDesc">선택된 회원의 상태를 일괄 변경합니다.</p>
        </div>
        <div class="ms-body">
          <div class="fg">
            <label>변경할 상태</label>
            <select id="bulkStatusSelect">
              <option value="1">정상 활동</option>
              <option value="2">활동 정지</option>
              <option value="3">휴면</option>
              <option value="4">탈퇴</option>
            </select>
          </div>
          <div class="fg">
            <label>처리 사유 <span style="color:var(--danger);">*</span></label>
            <textarea id="bulkStatusReason" placeholder="정지/탈퇴 처리 시 반드시 입력하세요."></textarea>
          </div>
        </div>
        <div class="ms-foot">
          <button class="btn-m btn-m-ghost"   onclick="closeBulkStatusModal()">취소</button>
          <button class="btn-m btn-m-primary"  onclick="applyBulkStatus()">일괄 적용</button>
        </div>
      </div>
    </div>

    <%-- 기존 infoModal / detailModal 껍데기 (member.js 호환용) --%>
    <div class="modal-overlay" id="detailModal" style="display:none;"></div>
    <div class="modal-overlay" id="infoModal"   style="display:none;">
      <div class="modal-content" style="max-width:500px;">
        <div class="modal-header"><h2>회원 상세 정보</h2></div>
        <div class="modal-body">
          <div style="text-align:center; margin-bottom:20px;">
            <h3 id="infoNickname" style="margin-top:10px;">로딩중...</h3>
          </div>
          <table style="width:100%; border-collapse:collapse; text-align:left;">
            <tr style="border-bottom:1px solid var(--border);"><th style="padding:10px;width:30%;">ID(이메일)</th><td id="infoEmail" style="padding:10px;"></td></tr>
            <tr style="border-bottom:1px solid var(--border);"><th style="padding:10px;">이름</th><td id="infoUsername" style="padding:10px;"></td></tr>
            <tr style="border-bottom:1px solid var(--border);"><th style="padding:10px;">전화번호</th><td id="infoPhone" style="padding:10px;"></td></tr>
            <tr style="border-bottom:1px solid var(--border);"><th style="padding:10px;">성별/생일</th><td id="infoGenderBirth" style="padding:10px;"></td></tr>
            <tr><th style="padding:10px;">마지막 접속</th><td id="infoLastLogin" style="padding:10px;"></td></tr>
          </table>
        </div>
        <div class="modal-footer">
          <button class="btn btn-ghost" style="flex:1" onclick="closeInfoModal()">닫기</button>
        </div>
      </div>
    </div>

  </div>
</div>

<script>
  const contextPath = '${pageContext.request.contextPath}';

  function resetFilter() {
    document.getElementById('searchRole').value     = 'ALL';
    document.getElementById('searchStatus').value   = 'ALL';
    document.getElementById('searchCategory').value = 'id';
    document.getElementById('searchInput').value    = '';
    filterTable();
  }
</script>
<script src="${pageContext.request.contextPath}/dist/js/admin/member.js"></script>
</body>
</html>
