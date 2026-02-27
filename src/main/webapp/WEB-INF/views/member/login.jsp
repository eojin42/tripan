<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Tripan - 로그인</title>
<jsp:include page="/WEB-INF/views/layout/headerResources.jsp"/>
</head>
<body>

<header><jsp:include page="/WEB-INF/views/layout/header.jsp"/></header>
</head>
<body>

<div id="auth-page-wrapper">
  <main class="auth-section">
    <div class="auth-card">
      
      <div class="auth-logo-wrapper">
        <div class="auth-brand">
          <div class="auth-logo-text-wrapper">
            <span class="auth-tri">Trip</span><span class="auth-pan">an</span>
            <div class="auth-logo-track">
              <div class="auth-logo-line"></div>
              <svg class="auth-logo-plane" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                <path d="M22,16v-2l-8.5-5V3.5C13.5,2.67 12.83,2 12,2s-1.5,0.67-1.5,1.5V9L2,14v2l8.5-2.5V19L8.5,20.5V22L12,21l3.5,1v-1.5L13.5,19v-5.5L22,16z" />
              </svg>
            </div>
          </div>
          <span class="auth-logo-dot">.</span>
        </div>
      </div>
      
      <p class="auth-desc">우리만의 완벽한 여행을 시작해 볼까요?</p>

      <c:if test="${not empty message}">
        <div class="auth-alert-message">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
            <circle cx="12" cy="12" r="10"></circle>
            <line x1="12" y1="8" x2="12" y2="12"></line>
            <line x1="12" y1="16" x2="12.01" y2="16"></line>
          </svg>
          <span>${message}</span>
        </div>
      </c:if>

      <form action="${pageContext.request.contextPath}/member/login" method="POST">
        <div class="auth-form-group">
          <input name="loginId" class="auth-input" placeholder="아이디를 입력해주세요" required>
        </div>
        <div class="auth-form-group">
          <input type="password" name="password" class="auth-input" placeholder="비밀번호를 입력해주세요" required>
        </div>
        <button type="submit" class="auth-btn-submit">로그인</button>
      </form>

      <div class="auth-links">
        <a href="${pageContext.request.contextPath}/member/findId">아이디 찾기</a>
        <span>|</span>
        <a href="${pageContext.request.contextPath}/member/findPw">비밀번호 찾기</a>
      </div>

      <div class="auth-social-divider">
        <span>또는 3초 만에 시작하기</span>
      </div>

      <button class="auth-btn-kakao" onclick="location.href='${pageContext.request.contextPath}/oauth2/authorization/kakao'">
        <svg class="auth-kakao-icon" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
          <path d="M12 3C6.477 3 2 6.556 2 10.944c0 2.822 1.83 5.3 4.613 6.744-.15.54-1.01 3.66-1.045 3.82-.045.2.067.243.19.166.1-.06 3.193-2.158 4.467-2.98.57.087 1.156.134 1.775.134 5.523 0 10-3.556 10-7.944C22 6.556 17.523 3 12 3z" fill="#000000"/>
        </svg>
        카카오로 시작하기
      </button>

      <div class="auth-signup-text">아직 Tripan 회원이 아니신가요?</div>
      <a href="${pageContext.request.contextPath}/member/account" class="auth-btn-signup">
        이메일로 3초 만에 가입하기
      </a>

    </div>
  </main>
</div>

<footer>
	<jsp:include page="/WEB-INF/views/layout/footer.jsp"/>
</footer>

</body>
</html>