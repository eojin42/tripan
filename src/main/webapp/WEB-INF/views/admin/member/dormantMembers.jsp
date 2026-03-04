<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <title>TripanSuper — 휴면 회원 관리</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/dist/css/admin.css">
</head>
<body>

<div class="admin-layout">
  <jsp:include page="../layout/sidebar.jsp"><jsp:param name="activePage" value="dormant"/></jsp:include>
  
  <div class="main-wrapper">
    <jsp:include page="../layout/header.jsp" />

    <main class="main-content">
      <div class="page-header fade-up">
        <div>
          <h1>휴면 회원 관리</h1>
          <p>1년 이상 장기 미접속으로 휴면 처리된 회원과 개인정보 파기 대상을 관리합니다.</p>
        </div>
        <div class="header-actions">
          <button class="btn btn-primary" onclick="sendMassEmail()">📧 일괄 복귀 안내 메일</button>
        </div>
      </div>

      <div class="kpi-grid">
        <div class="card kpi-card fade-up fade-up-1">
          <div class="kpi-label">전체 휴면 회원</div>
          <div class="kpi-value" id="kpiTotalDormant">1,204</div>
          <div class="kpi-sub">보안 DB 분리 보관 중</div>
        </div>
        <div class="card kpi-card fade-up fade-up-2">
          <div class="kpi-label">이번 달 파기 예정</div>
          <div class="kpi-value" style="color:var(--danger)" id="kpiWillDelete">45</div>
          <div class="badge badge-danger">30일 내 영구 삭제 대상</div>
        </div>
        <div class="card kpi-card fade-up fade-up-3">
          <div class="kpi-label">최근 복귀한 유저</div>
          <div class="kpi-value" style="color:var(--success)" id="kpiReactivated">12</div>
          <div class="kpi-sub">지난 7일 기준</div>
        </div>
      </div>

      <div class="card filter-card fade-up">
        <div class="filter-row">
          <div class="filter-label">회원 검색</div>
          <select class="filter-select" id="searchCategory" style="width: 120px;">
            <option value="id">ID (이메일)</option>
            <option value="nickname">닉네임</option>
          </select>
          <input type="text" id="searchInput" class="keyword-input" placeholder="검색어를 입력하세요..." onkeyup="if(event.key==='Enter') searchDormant()">
          <button class="btn btn-primary" onclick="searchDormant()">🔍 검색</button>
        </div>
      </div>

      <div class="card table-card fade-up">
        <div class="w-header"><h2>💤 휴면 회원 목록</h2></div>
        <div class="table-responsive">
          <table>
            <thead>
              <tr>
                <th>ID / 이메일</th>
                <th>닉네임</th>
                <th>마지막 접속일</th>
                <th>휴면 전환일</th>
                <th>개인정보 파기 예정일</th>
                <th class="right">관리 옵션</th>
              </tr>
            </thead>
            
            <tbody id="dormantTableBody">
			  <c:forEach var="member" items="${dormantList}">
			    <tr>
			      <td><strong style="color: var(--muted);">${member.email}</strong></td>
			      <td>${member.nickname}</td>
			      
			      <td class="num date-cell">
			        <fmt:formatDate value="${member.lastLoginDate}" pattern="yyyy-MM-dd" />
			      </td>
			      
			      <td class="num date-cell">
			        <fmt:formatDate value="${member.dormantDate}" pattern="yyyy-MM-dd" />
			      </td>
			      
			      <td class="num date-cell" style="color: var(--danger); font-weight: bold;">
			        <fmt:formatDate value="${member.deleteScheduledDate}" pattern="yyyy-MM-dd" />
			      </td>
			      
			      <td class="right">
			        <button class="btn btn-ghost btn-sm" onclick="sendEmail('${member.email}')">복귀 안내</button>
			        <button class="btn btn-danger btn-sm" onclick="forceDelete('${member.email}')">즉시 파기</button>
			      </td>
			    </tr>
			  </c:forEach>
			  
			  <c:if test="${empty dormantList}">
			    <tr>
			      <td><strong style="color: var(--muted);">user_old@gmail.com</strong></td>
			      <td>여행자원툴</td>
			      <td class="num date-cell">2023-01-15</td>
			      <td class="num date-cell">2024-01-16</td>
			      <td class="num date-cell" style="color: var(--danger); font-weight: bold;">2025-01-16</td>
			      <td class="right">
			        <button class="btn btn-ghost btn-sm" onclick="sendEmail('user_old@gmail.com')">복귀 안내</button>
			        <button class="btn btn-danger btn-sm" onclick="forceDelete('user_old@gmail.com')">즉시 파기</button>
			      </td>
			    </tr>
			  </c:if>
			</tbody>
          </table>
        </div>
      </div>
    </main>
  </div>
</div>

<script>
  function searchDormant() {
    const category = document.getElementById('searchCategory').value;
    const keyword = document.getElementById('searchInput').value.trim();
    alert("검색 실행: " + category + " / " + keyword);
  }

  function sendEmail(email) {
    if(confirm(email + " 님에게 휴면 해제(복귀) 안내 메일을 발송하시겠습니까?")) {
      alert("메일 발송 요청이 완료되었습니다.");
    }
  }

  function sendMassEmail() {
    if(confirm("조회된 휴면 회원 전체에게 복귀 안내 메일을 발송하시겠습니까? (서버 부하 주의)")) {
      alert("일괄 발송이 시작되었습니다.");
    }
  }

  function forceDelete(email) {
    if(confirm("⚠️ 경고: " + email + " 님의 계정과 개인정보를 즉시 영구 파기하시겠습니까?\n이 작업은 되돌릴 수 없습니다.")) {
      alert("파기 처리되었습니다.");
    }
  }
</script>
</body>
</html>