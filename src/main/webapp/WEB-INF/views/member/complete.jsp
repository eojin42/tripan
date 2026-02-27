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
      
      <div class="icon-wrapper">
        <svg class="check-icon" width="40" height="40" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round">
          <path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"></path>
          <polyline points="22 4 12 14.01 9 11.01"></polyline>
        </svg>
      </div>
      
      <div class="brand-logo" style="margin-bottom: 16px; justify-content: center;">
        <span class="tri" style="font-size: 32px;">Trip</span><span class="pan" style="font-size: 32px;">an</span><span class="dot" style="color: var(--light-pink); font-size: 34px;">.</span>
      </div>
      
      <h2 class="complete-title">${message}</h2>
      
      <p class="complete-desc">
        성공적으로 가입이 완료되었습니다.<br>
        지금 바로 Tripan과 함께 특별한 여행을 계획해 보세요!
      </p>

      <div class="action-buttons">
        <button type="button" class="btn-outline" onclick="location.href='${pageContext.request.contextPath}/';">홈으로 이동</button>
        <button type="button" class="btn-primary" onclick="location.href='${pageContext.request.contextPath}/member/login';">로그인하기</button>
      </div>

    </div>
  </main>
</div>

<footer>
	<jsp:include page="/WEB-INF/views/layout/footer.jsp"/>
</footer>

</body>
</html>