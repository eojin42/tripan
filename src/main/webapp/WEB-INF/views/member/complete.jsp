<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Tripan - 회원가입 완료</title>
<jsp:include page="/WEB-INF/views/layout/headerResources.jsp"/>
</head>
<body>

<header>
	<jsp:include page="/WEB-INF/views/layout/header.jsp"/>
</header>

<div id="complete-page-wrapper">
  <main class="complete-section">
    <div class="complete-card">
      
      <div class="brand-logo" style="margin-bottom: 16px; justify-content: center;">
        <span class="tri" style="font-size: 32px;">Trip</span><span class="pan" style="font-size: 32px;">an</span><span class="dot" style="color: var(--light-pink); font-size: 34px;">.</span>
      </div>


	<c:choose>
	
	<%-- 에러 케이스 (isError=true) --%>
	  <c:when test="${isError}">
	    <div class="icon-wrapper" style="background: #fdecea;">
	      <svg class="check-icon" style="color: #e53935;" width="40" height="40" viewBox="0 0 24 24"
	           fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round">
	        <circle cx="12" cy="12" r="10"/>
	        <line x1="15" y1="9" x2="9" y2="15"/>
	        <line x1="9" y1="9" x2="15" y2="15"/>
	      </svg>
	    </div>
	    <h2 class="complete-title" style="color: #e53935;">${title}</h2>
	    <p class="complete-desc">${message}</p>
	  </c:when>
	  
	   <%-- 성공 케이스 --%>
  <c:when test="${not empty title}">
    <div class="icon-wrapper">
      <svg class="check-icon" width="40" height="40" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round">
        <path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"></path>
        <polyline points="22 4 12 14.01 9 11.01"></polyline>
      </svg>
    </div>
    <h2 class="complete-title" style="color: var(--point-blue);">${title}</h2>
    <p class="complete-desc">${message}</p>
  </c:when>
</c:choose>

<div class="action-buttons">
  <button type="button" class="btn-outline" onclick="location.href='${pageContext.request.contextPath}/';">홈으로 이동</button>
  <c:choose>
    <c:when test="${isError}">
      <button type="button" class="btn-primary" onclick="history.back();">다시 시도</button>
    </c:when>
    <c:otherwise>
      <button type="button" class="btn-primary" onclick="location.href='${pageContext.request.contextPath}/member/login';">로그인하기</button>
    </c:otherwise>
  </c:choose>
</div>
</div>
</main>
</div>

<footer>
	<jsp:include page="/WEB-INF/views/layout/footer.jsp"/>
</footer>

</body>
</html>