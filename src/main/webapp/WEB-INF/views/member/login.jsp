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

<style>
    /* 💡 푸터(Footer)와 절대 충돌하지 않도록 로그인 전용(auth-) 스코프로 묶음 */
    #auth-page-wrapper {
      --auth-sky-blue: #89CFF0;
      --auth-light-pink: #FFB6C1;
      --auth-logo-grad: linear-gradient(to right, var(--auth-sky-blue), var(--auth-light-pink));
      
      --auth-bg-white: #FFFFFF;
      --auth-text-black: #2D3748;
      --auth-text-dark: #4A5568;
      --auth-text-gray: #A0AEC0;
      --auth-border-light: #E2E8F0;
      
      --auth-radius-sm: 12px;
      --auth-radius-lg: 28px;
      --auth-font: 'Pretendard', sans-serif;
      --auth-bounce: cubic-bezier(0.68, -0.55, 0.26, 1.55);
    }

    /* 로그인 전체 배경 */
    .auth-section {
      min-height: calc(100vh - 100px);
      display: flex;
      align-items: center;
      justify-content: center;
      background: linear-gradient(135deg, #F0F8FF 0%, #FFF0F5 100%); 
      padding: 120px 20px 80px; 
      font-family: var(--auth-font);
      box-sizing: border-box;
    }

    /* 글래스모피즘 로그인 카드 */
    .auth-card {
      background: rgba(255, 255, 255, 0.85);
      backdrop-filter: blur(20px); -webkit-backdrop-filter: blur(20px);
      width: 100%;
      max-width: 440px;
      padding: 56px 40px;
      border-radius: var(--auth-radius-lg); 
      border: 1px solid rgba(255, 255, 255, 0.6);
      box-shadow: 0 24px 48px rgba(137, 207, 240, 0.15);
      text-align: center;
      transform: translateY(30px);
      opacity: 0;
      animation: authFadeUp 0.8s var(--auth-bounce) forwards;
      box-sizing: border-box;
    }

    @keyframes authFadeUp {
      to { transform: translateY(0); opacity: 1; }
    }

    /* ✨ 비행기 애니메이션 로고 */
    .auth-logo-wrapper { margin-bottom: 8px; display: inline-block; }
    .auth-brand { 
      font-size: 36px; font-weight: 900; letter-spacing: -0.5px;
      display: flex; align-items: baseline; justify-content: center; text-decoration: none; line-height: 1;
    }
    .auth-brand .auth-tri { color: var(--auth-text-black); }
    .auth-brand .auth-pan { background: var(--auth-logo-grad); -webkit-background-clip: text; -webkit-text-fill-color: transparent; display: inline-block; }
    
    .auth-logo-text-wrapper { position: relative; display: inline-block; padding-bottom: 6px; }
    .auth-logo-track { position: absolute; left: 0; bottom: 0; width: 100%; height: 4px; }
    .auth-logo-line {
      width: 100%; height: 100%; border-radius: 2px; background: var(--auth-logo-grad); 
      transform-origin: left center; transform: scaleX(0); 
      animation: authDrawLine 1.5s cubic-bezier(0.4, 0, 0.2, 1) forwards 0.3s;
    }
    .auth-logo-plane {
      position: absolute; bottom: -8px; left: -15px; width: 20px; height: 20px;
      fill: var(--auth-sky-blue); transform: rotate(90deg); opacity: 0;
      animation: authFlyPlane 1.5s cubic-bezier(0.4, 0, 0.2, 1) forwards 0.3s; pointer-events: none;
    }
    .auth-logo-dot {
      color: var(--auth-light-pink); opacity: 0; transform: scale(0); transform-origin: bottom center;
      animation: authPopDot 0.4s cubic-bezier(0.175, 0.885, 0.32, 1.275) forwards 1.7s; font-size: 40px; line-height: 0;
    }

    @keyframes authDrawLine { 0% { transform: scaleX(0); } 100% { transform: scaleX(1); } }
    @keyframes authFlyPlane {
      0% { left: -15px; opacity: 0; transform: rotate(90deg) scale(0.5); }
      10% { opacity: 1; transform: rotate(90deg) scale(1); }
      90% { left: 100%; opacity: 1; transform: rotate(90deg) scale(1); }
      100% { left: 100%; opacity: 0; transform: rotate(90deg) scale(0.2); } 
    }
    @keyframes authPopDot { 0% { opacity: 0; transform: scale(0); } 60% { opacity: 1; transform: scale(1.3); } 100% { opacity: 1; transform: scale(1); } }

    .auth-desc { color: var(--auth-text-dark); font-size: 15px; font-weight: 600; margin-bottom: 40px; margin-top: 0; }

    /* 💡 추가된 팀원 코드: 에러 메시지 스타일 (변수 충돌 방지 및 통합) */
    .auth-alert-message {
      display: flex;
      align-items: center;
      justify-content: center;
      gap: 8px;
      background-color: rgba(255, 118, 117, 0.1);
      color: #D63031;
      padding: 12px 16px;
      border-radius: var(--auth-radius-sm);
      font-size: 13.5px;
      font-weight: 700;
      margin-bottom: 20px;
      border: 1px solid rgba(255, 118, 117, 0.3);
      animation: shake 0.4s ease-in-out;
    }
    
    .auth-alert-message svg { width: 16px; height: 16px; flex-shrink: 0; }
    
    @keyframes shake {
      0%, 100% { transform: translateX(0); }
      25% { transform: translateX(-4px); }
      75% { transform: translateX(4px); }
    }

    /* 폼 영역 */
    .auth-form-group { margin-bottom: 16px; text-align: left; }
    .auth-input {
      width: 100%; padding: 16px 20px;
      border: 1px solid var(--auth-border-light); border-radius: var(--auth-radius-sm);
      font-size: 15px; font-weight: 600; font-family: var(--auth-font); color: var(--auth-text-black);
      transition: all 0.3s ease; background-color: rgba(244, 247, 246, 0.6); box-sizing: border-box; margin: 0;
    }
    .auth-input::placeholder { color: var(--auth-text-gray); font-weight: 500; }
    .auth-input:focus {
      outline: none; border-color: var(--auth-sky-blue); background-color: var(--auth-bg-white);
      box-shadow: 0 0 0 4px rgba(137, 207, 240, 0.15);
    }

    /* 기본 로그인 버튼 */
    .auth-btn-submit {
      width: 100%; padding: 16px;
      background: var(--auth-text-black); color: var(--auth-bg-white);
      border: none; border-radius: var(--auth-radius-sm);
      font-size: 16px; font-weight: 800; cursor: pointer;
      transition: all 0.3s var(--auth-bounce); margin-top: 8px; box-sizing: border-box;
    }
    .auth-btn-submit:hover {
      background: var(--auth-sky-blue); transform: translateY(-3px);
      box-shadow: 0 8px 20px rgba(137, 207, 240, 0.3);
    }

    .auth-links {
      display: flex; justify-content: center; align-items: center; gap: 12px;
      margin-top: 20px; font-size: 13px; font-weight: 600; color: var(--auth-text-gray);
    }
    .auth-links a { color: var(--auth-text-dark); text-decoration: none; transition: color 0.3s; }
    .auth-links a:hover { color: var(--auth-sky-blue); }
    .auth-links span { color: var(--auth-border-light); }

    .auth-social-divider {
      display: flex; align-items: center; margin: 32px 0;
      color: var(--auth-text-gray); font-size: 13px; font-weight: 600;
    }
    .auth-social-divider::before, .auth-social-divider::after { content: ""; flex: 1; border-bottom: 1px solid var(--auth-border-light); }
    .auth-social-divider span { padding: 0 16px; }

    /* 카카오 로그인 버튼 */
    .auth-btn-kakao {
      width: 100%; padding: 16px; border-radius: var(--auth-radius-sm);
      font-size: 15px; font-weight: 800; display: flex; align-items: center; justify-content: center; gap: 10px;
      cursor: pointer; transition: all 0.3s var(--auth-bounce); border: none; box-sizing: border-box;
      background-color: #FEE500; color: #000000; margin-bottom: 32px;
    }
    .auth-btn-kakao:hover { transform: translateY(-3px) scale(1.02); box-shadow: 0 8px 20px rgba(254, 229, 0, 0.3); }
    .auth-kakao-icon { width: 20px; height: 20px; }

    /* 💡 신규: 회원가입 영역 업그레이드 */
    .auth-signup-text {
      font-size: 13px; font-weight: 600; color: var(--auth-text-gray); margin-bottom: 12px;
    }
    
    .auth-btn-signup {
      display: flex; justify-content: center; align-items: center;
      width: 100%; padding: 14px;
      background-color: var(--auth-bg-white);
      color: var(--auth-text-dark);
      font-size: 15px; font-weight: 800; text-decoration: none;
      border-radius: var(--auth-radius-sm);
      border: 2px solid transparent;
      transition: all 0.3s var(--auth-bounce);
      box-sizing: border-box;
      
      /* 그라데이션 테두리 구현 */
      background-image: linear-gradient(var(--auth-bg-white), var(--auth-bg-white)), var(--auth-logo-grad);
      background-origin: border-box;
      background-clip: padding-box, border-box;
    }
    
    .auth-btn-signup:hover {
      transform: translateY(-3px);
      box-shadow: 0 8px 20px rgba(137, 207, 240, 0.2);
      color: var(--auth-sky-blue);
    }
</style>
</head>
<body>

<header>
	<jsp:include page="/WEB-INF/views/layout/header.jsp"/>
</header>

<div id="auth-page-wrapper">
  <main class="auth-section">
    <div class="auth-card">
      
      <div class="auth-logo-wrapper">
        <div class="auth-brand">
          <div class="auth-logo-text-wrapper">
            <span class="auth-tri">Tri</span><span class="auth-pan">pan</span>
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