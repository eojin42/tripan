<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <title>TripanSuper — 회원 관리</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/dist/css/admin.css">
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
        <div class="header-actions">
          <button class="btn btn-ghost btn-sm">📥 전체 목록 다운로드</button>
        </div>
      </div>

      <div class="kpi-grid">
		  <div class="card kpi-card fade-up fade-up-1">
		    <div class="kpi-label">전체 회원수</div>
		    <div class="kpi-value" id="kpiTotal">${kpi.totalCount}</div>
		    <div class="kpi-sub">일반 ${kpi.userCount} / 파트너 ${kpi.partnerCount} / 관리자 ${kpi.adminCount}</div>
		  </div>
		
		  <div class="card kpi-card fade-up fade-up-2">
		    <div class="kpi-label">신규 가입 (오늘)</div>
		    <div class="kpi-value" id="kpiTodayNew">${kpi.todayNewCount}명</div> <c:choose>
		      <c:when test="${kpi.dailyTrend > 0}">
		        <span class="trend trend-up" style="color: #ff4d4f;">↑ ${kpi.dailyTrend}%</span>
		      </c:when>
		      <c:when test="${kpi.dailyTrend < 0}">
		        <%-- 절댓값 처리를 위해 마이너스(-) 기호 붙임 --%>
		        <span class="trend trend-down" style="color: #1890ff;">↓ ${-kpi.dailyTrend}%</span>
		      </c:when>
		      <c:otherwise>
		        <span class="trend" style="color: #999;">- 0%</span>
		      </c:otherwise>
		    </c:choose>
		  </div>
		
		  <div class="card kpi-card fade-up fade-up-3">
		    <div class="kpi-label">정상 활동 유저</div>
		    <div class="kpi-value" style="color:var(--success)" id="kpiActive">${kpi.activeCount}</div>
		    <div class="kpi-sub">현재 서비스 이용 가능</div>
		  </div>
		
		  <div class="card kpi-card fade-up fade-up-4">
		    <div class="kpi-label">활동 정지(Ban) 유저</div>
		    <div class="kpi-value" style="color:var(--danger)" id="kpiBan">${kpi.banCount}</div>
		    <div class="badge badge-danger">정책 위반 관리중</div>
		  </div>
	  
	  </div>

      <div class="card filter-card fade-up">
        <div class="filter-row">
          <div class="filter-label">회원 검색</div>
          
          <select class="filter-select" id="searchRole" style="width: 120px;" onchange="filterTable()">
            <option value="ALL">전체 권한</option>
            <option value="USER">일반 유저</option>
            <option value="PARTNER">파트너</option>
            <option value="ADMIN">관리자</option>
          </select>

          <select class="filter-select" id="searchStatus" style="width: 120px;" onchange="filterTable()">
            <option value="ALL">전체 상태</option>
            <option value="ACTIVE">정상</option>
            <option value="BAN">정지(BAN)</option>
            <option value="WITHDRAW">탈퇴</option>
          </select>

          <select class="filter-select" id="searchCategory" style="width: 120px;">
            <option value="id">ID (이메일)</option>
            <option value="nickname">닉네임</option>
          </select>
          <input type="text" id="searchInput" class="keyword-input" placeholder="검색어를 입력하세요..." onkeyup="if(event.key==='Enter') filterTable()">
          <button class="btn btn-primary" onclick="filterTable()">🔍 검색</button>
        </div>
      </div>

      <div class="card table-card fade-up">
        <div class="w-header"><h2>👥 전체 회원 목록</h2></div>
        <div class="table-responsive">
          <table>
            <thead>
              <tr>
                <th>ID / 이메일</th>
                <th>닉네임</th>
                <th>권한 레벨</th>
                <th>상태</th>
                <th>위반 지표</th>
                <th style="cursor: pointer; user-select: none;" onclick="sortByDate()">
                  가입일 <span id="dateSortIcon">↕️</span>
                </th>
                <th class="right">관리</th>
              </tr>
            </thead>
            
            <tbody id="memberTableBody">
			  <c:forEach var="member" items="${list}">
          		  <tr class="member-row" data-phone="${member.phoneNumber}" data-role="${member.role}" data-status="${member.status}">
			      
			      <td class="col-id"><strong>${member.email}</strong></td>
			      
			      <td class="col-nickname">
			        <span class="member-name-link" onclick="goToDetail('${member.email}')">
			          ${member.nickname}
			        </span>
			      </td>
			      
			      <td>
			        <c:choose>
			          <c:when test="${member.role == 'ADMIN'}">
			            <span class="badge" style="background:#E0E7FF; color:#4338CA;">SYS ADMIN</span>
			          </c:when>
			          <c:when test="${member.role == 'PARTNER'}">
			            <span class="badge" style="background:#F0FDF4; color:#15803D;">PARTNER</span>
			          </c:when>
			          <c:otherwise>
			            <span class="badge">USER</span>
			          </c:otherwise>
			        </c:choose>
			      </td>
			      
			      <td id="status-${member.memberId}">
			        <c:choose>
			          <c:when test="${member.status == '2'}">
			            <span class="badge badge-danger status-badge" onclick="showReason(event, '${member.reason}')">BAN(정지)</span>
			          </c:when>
			          <c:when test="${member.status == '4'}">
			            <span class="badge" style="background:var(--bg); color:var(--muted)">탈퇴 완료</span>
			          </c:when>
			          <c:otherwise>
			            <span class="badge badge-done">정상</span>
			          </c:otherwise>
			        </c:choose>
			      </td>
			      
			      <td>
			        <c:choose>
			          <c:when test="${member.reportCount >= 5}">
			            <span class="badge badge-alert">신고 ${member.reportCount}회 누적</span>
			          </c:when>
			          <c:otherwise>
			            -
			          </c:otherwise>
			        </c:choose>
			      </td>
			      
			      <td class="num date-cell">
			        <fmt:formatDate value="${member.regDate}" pattern="yyyy-MM-dd" />
			      </td>
			      
			      <td class="right">
			        <button class="btn btn-primary btn-sm" 
			                onclick="openDetailModal(event, '${member.email}', '${member.nickname}', '${member.role}', '${member.status}', '${member.reason}')">
			          상세/수정
			        </button>
			      </td>
			      
			    </tr>
			  </c:forEach>
			</tbody>
          </table>
        </div>
      </div>
    </main>
  </div>
</div>

<div class="modal-overlay" id="detailModal">
  <div class="modal-content">
    <div class="modal-header">
      <h2>회원 정보 상세 및 수정</h2>
    </div>
    <div class="modal-body">
      <input type="hidden" id="modalTargetId"> 
      <div class="form-group">
        <label>대상 회원</label>
        <input type="text" id="modalUserDisplay" class="keyword-input" readonly style="background:var(--bg); border:none; font-weight:700;">
      </div>
      <div class="form-row">
        <div class="form-group">
          <label>권한 레벨</label>
          <select class="filter-select" id="modalRoleSelect" style="width:100%;" onchange="checkAdminStatus()">
            <option value="USER">일반 유저 (USER)</option>
            <option value="PARTNER">파트너 (PARTNER)</option>
            <option value="ADMIN">시스템 관리자 (SYS ADMIN)</option>
          </select>
        </div>
        <div class="form-group">
          <label>계정 상태</label>
          <select class="filter-select" id="modalStatusSelect" style="width:100%;">
            <option value="ACTIVE">정상 활동</option>
            <option value="BAN" class="user-status-only">활동 정지 (BAN)</option>
            <option value="WITHDRAW" class="user-status-only">탈퇴 완료</option>
          </select>
        </div>
      </div>
      <div class="form-group">
        <label>변경/조치 사유 <span style="color:var(--danger)">*</span></label>
        <textarea id="modalReasonInput" class="keyword-input" placeholder="활동 정지나 탈퇴 처리 시 사유를 반드시 입력해 주세요." style="height:80px; resize:none; padding:12px;"></textarea>
      </div>
    </div>
    <div class="modal-footer">
      <button class="btn btn-ghost" style="flex:1" onclick="closeModal()">취소</button>
      <button class="btn btn-primary" style="flex:1" onclick="saveChanges()">변경사항 저장</button>
    </div>
  </div>
</div>

<script>
  function filterTable() {
    const roleFilter = document.getElementById('searchRole').value;
    const statusFilter = document.getElementById('searchStatus').value;
    const categoryFilter = document.getElementById('searchCategory').value;
    const keyword = document.getElementById('searchInput').value.toLowerCase().trim();

    const rows = document.querySelectorAll('.member-row');

    rows.forEach(row => {
      const rowRole = row.getAttribute('data-role');
      const rowStatus = row.getAttribute('data-status');
      
      let searchText = '';
      if (categoryFilter === 'id') {
        searchText = row.querySelector('.col-id').innerText.toLowerCase();
      } else if (categoryFilter === 'nickname') {
        searchText = row.querySelector('.col-nickname').innerText.toLowerCase();
      }

      const matchRole = (roleFilter === 'ALL' || roleFilter === rowRole);
      const matchStatus = (statusFilter === 'ALL' || statusFilter === rowStatus);
      const matchKeyword = (keyword === '' || searchText.includes(keyword));

      if (matchRole && matchStatus && matchKeyword) {
        row.style.display = '';
      } else {
        row.style.display = 'none';
      }
    });
  }

  let dateSortAsc = true;
  function sortByDate() {
    const tbody = document.getElementById('memberTableBody');
    const rows = Array.from(tbody.querySelectorAll('.member-row'));
    const icon = document.getElementById('dateSortIcon');

    rows.sort((a, b) => {
      const dateA = new Date(a.querySelectorAll('td')[5].innerText.trim());
      const dateB = new Date(b.querySelectorAll('td')[5].innerText.trim());

      if (dateSortAsc) {
        return dateA - dateB; 
      } else {
        return dateB - dateA; 
      }
    });

    dateSortAsc = !dateSortAsc;
    icon.innerText = dateSortAsc ? '⬇️' : '⬆️';

    rows.forEach(row => tbody.appendChild(row));
  }

  let currentOldStatus = '';

  function goToDetail(userId) {
    location.href = '${pageContext.request.contextPath}/admin/memberDetail?id=' + userId;
  }

  function showReason(event, reason) {
    event.stopPropagation(); 
    alert("📌 [처리 사유]\n\n" + (reason || "기록된 사유가 없습니다."));
  }

  function openDetailModal(event, id, nickname, role, status, reason) {
    event.stopPropagation();
    document.getElementById('modalTargetId').value = id;
    document.getElementById('modalUserDisplay').value = `\${nickname} (\${id})`;
    document.getElementById('modalRoleSelect').value = role;
    
    currentOldStatus = status; 
    checkAdminStatus(role);
    document.getElementById('modalStatusSelect').value = status;
    document.getElementById('modalReasonInput').value = reason;
    
    document.getElementById('detailModal').style.display = 'flex';
  }

  function saveChanges() {
    const newStatus = document.getElementById('modalStatusSelect').value;
    const reason = document.getElementById('modalReasonInput').value.trim();

    if ((newStatus === 'BAN' || newStatus === 'WITHDRAW') && reason === '') {
      alert("⚠️ 활동 정지 또는 탈퇴 처리 시 반드시 사유를 입력해야 합니다.");
      document.getElementById('modalReasonInput').focus();
      return;
    }

    if(confirm("회원 정보 및 권한/상태를 변경하시겠습니까?")) {
      updateKPI(currentOldStatus, newStatus);
      alert("성공적으로 저장되었습니다.");
      closeModal();
    }
  }

  function updateKPI(oldStatus, newStatus) {
    if (oldStatus === newStatus) return; 

    let elActive = document.getElementById('kpiActive');
    let elBan = document.getElementById('kpiBan');
    let elWithdraw = document.getElementById('kpiWithdraw');

    let activeCnt = parseInt(elActive.innerText.replace(/,/g, ''));
    let banCnt = parseInt(elBan.innerText.replace(/,/g, ''));
    let withdrawCnt = parseInt(elWithdraw.innerText.replace(/,/g, ''));

    if(oldStatus === 'ACTIVE') activeCnt--;
    else if(oldStatus === 'BAN') banCnt--;
    else if(oldStatus === 'WITHDRAW') withdrawCnt--;

    if(newStatus === 'ACTIVE') activeCnt++;
    else if(newStatus === 'BAN') banCnt++;
    else if(newStatus === 'WITHDRAW') withdrawCnt++;

    elActive.innerText = activeCnt.toLocaleString('ko-KR');
    elBan.innerText = banCnt.toLocaleString('ko-KR');
    elWithdraw.innerText = withdrawCnt.toLocaleString('ko-KR');
  }

  function checkAdminStatus(passedRole) {
    const role = passedRole || document.getElementById('modalRoleSelect').value;
    const statusSelect = document.getElementById('modalStatusSelect');
    const userOnlyOpts = statusSelect.querySelectorAll('.user-status-only');
    if(role === 'ADMIN') { userOnlyOpts.forEach(opt => opt.style.display = 'none'); statusSelect.value = 'ACTIVE'; }
    else { userOnlyOpts.forEach(opt => opt.style.display = ''); }
  }

  function closeModal() { document.getElementById('detailModal').style.display = 'none'; }
</script>
</body>
</html>