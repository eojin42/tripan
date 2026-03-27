<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>

<style>
.login-modal-overlay {
    position: fixed; 
    top: 0; left: 0; right: 0; bottom: 0;
    background: rgba(0, 0, 0, 0.4); 
    backdrop-filter: blur(8px); -webkit-backdrop-filter: blur(8px);
    display: flex; justify-content: center; align-items: center; 
    z-index: 10005;
    opacity: 0; 
    visibility: hidden; 
    transition: opacity 0.3s ease, visibility 0.3s ease; 
  }
  
  .login-modal-overlay.show { 
    opacity: 1; 
    visibility: visible;
    display: flex !important; 
  }
  
  .login-modal-card {
    position: relative; background: #FFFFFF; border-radius: 32px; padding: 60px 40px 40px; 
    width: 90%; max-width: 440px; text-align: center;
    box-shadow: 0 20px 40px rgba(0,0,0,0.15); 
    transform: translateY(20px); 
    transition: transform 0.3s cubic-bezier(0.34, 1.56, 0.64, 1);
  }
  
  .login-modal-overlay.show .login-modal-card { 
    transform: translateY(0); 
  }
  
  .modal-close-icon {
    position: absolute; top: 24px; right: 24px; background: none; border: none;
    font-size: 20px; color: #A0AEC0; cursor: pointer; transition: color 0.2s;
  }
  .modal-close-icon:hover { color: #2D3748; }
  .modal-auth-brand-wrapper { text-align: center; margin-bottom: 12px; }
  .modal-auth-brand { display: inline-flex; align-items: flex-end; gap: 0; position: relative; }
  .logo-text-wrapper { position: relative; display: inline-block; padding-bottom: 8px; line-height: 1; }
  .modal-auth-tri { font-size: 40px; font-weight: 900; letter-spacing: -1.5px; color: #2D3748; }
  .modal-auth-pan { font-size: 40px; font-weight: 900; letter-spacing: -1.5px; color: #89CFF0; }
  .logo-track { position: absolute; left: 0; bottom: 0; width: 100%; height: 3px; overflow: visible; }
  .logo-line { 
    width: 100%; height: 100%; border-radius: 2px; 
    background: linear-gradient(90deg, #89CFF0, #FFB6C1); 
    transform-origin: left center; transform: scaleX(0); 
  }
  .logo-plane { 
    position: absolute; bottom: -8px; left: -15px; width: 22px; height: 22px; 
    fill: #89CFF0; transform: rotate(90deg); opacity: 0; pointer-events: none; 
  }
  .logo-dot { 
    font-size: 40px; font-weight: 900; color: #FFB6C1; line-height: 1; 
    opacity: 0; transform: scale(0); transform-origin: bottom center; display: inline-block;
  }

  .show .logo-line { animation: drawLine 1.2s cubic-bezier(0.4, 0, 0.2, 1) forwards; animation-delay: 0.2s; }
  .show .logo-plane { animation: flyPlane 1.2s cubic-bezier(0.4, 0, 0.2, 1) forwards; animation-delay: 0.2s; }
  .show .logo-dot { animation: popDot 0.4s cubic-bezier(0.175, 0.885, 0.32, 1.275) forwards; animation-delay: 1.4s; }

  @keyframes drawLine { 0% { transform: scaleX(0); } 100% { transform: scaleX(1); } }
  @keyframes flyPlane {
    0% { left: -20px; opacity: 0; }
    10% { opacity: 1; }
    90% { opacity: 1; left: calc(100% - 5px); }
    100% { left: 100%; opacity: 0; }
  }
  @keyframes popDot { 0% { opacity: 0; transform: scale(0); } 100% { opacity: 1; transform: scale(1); } }
  .modal-auth-subtitle { font-size: 16px; color: #4A5568; margin: 0 0 32px; font-weight: 600; letter-spacing: -0.5px; }
  .modal-auth-form { display: flex; flex-direction: column; gap: 12px; margin-bottom: 20px; }
  .modal-auth-input {
    width: 100%; padding: 18px 20px; border: 1px solid #EAEAEA; border-radius: 12px;
    font-size: 15px; box-sizing: border-box; background: #FAFAFA; transition: all 0.2s; font-family: 'Pretendard', sans-serif;
  }
  .modal-auth-input:focus { outline: none; border-color: #89CFF0; background: #fff; box-shadow: 0 0 0 3px rgba(137, 207, 240, 0.1); }
  .modal-auth-btn-submit {
    width: 100%; padding: 18px; background: #2D3748; color: white; border: none;
    border-radius: 12px; font-size: 16px; font-weight: 800; cursor: pointer; transition: 0.2s; margin-top: 8px;
  }
  .modal-auth-btn-submit:hover { background: #1A202C; transform: translateY(-2px); }
  .modal-auth-links { display: flex; justify-content: center; align-items: center; gap: 16px; font-size: 14px; font-weight: 600; margin-bottom: 30px; }
  .modal-auth-links a { color: #718096; text-decoration: none; }
  .modal-auth-links .divider { color: #E2E8F0; font-weight: 300; }
  .modal-auth-social-divider { display: flex; align-items: center; text-align: center; color: #A0AEC0; font-size: 14px; margin-bottom: 24px; font-weight: 500; }
  .modal-auth-social-divider::before, .modal-auth-social-divider::after { content: ''; flex: 1; border-bottom: 1px solid #F0F0F0; }
  .modal-auth-social-divider span { padding: 0 16px; }
  .modal-auth-btn-kakao {
    width: 100%; padding: 16px; background: #FEE500; color: #000000; border: none;
    border-radius: 12px; font-size: 16px; font-weight: 800; cursor: pointer; display: flex; align-items: center; justify-content: center; gap: 8px;
    transition: 0.2s;
  }
  .modal-auth-btn-kakao:hover { background: #FDD835; transform: translateY(-2px); }
  .modal-auth-signup-prompt { font-size: 14px; color: #A0AEC0; font-weight: 500; margin-top: 32px; margin-bottom: 12px; }
  .modal-auth-btn-signup {
    display: block; width: 100%; padding: 16px; font-size: 15px; font-weight: 800; color: #4A5568;
    text-decoration: none; border-radius: 12px; box-sizing: border-box; transition: 0.2s;
    border: 2px solid transparent;
    background-image: linear-gradient(#FFFFFF, #FFFFFF), linear-gradient(135deg, #89CFF0, #FFB6C1);
    background-origin: border-box; background-clip: padding-box, border-box;
  }
  .modal-auth-btn-signup:hover { transform: translateY(-2px); box-shadow: 0 4px 12px rgba(137, 207, 240, 0.15); }
</style>

<div id="loginPromptModal" class="login-modal-overlay">
  <div class="login-modal-card">
    <button class="modal-close-icon" onclick="closeLoginModal()">✕</button>
    
    <div class="modal-auth-brand-wrapper">
      <div class="modal-auth-brand">
        <div class="logo-text-wrapper">
          <div class="modal-auth-text-group">
            <span class="modal-auth-tri">Trip</span><span class="modal-auth-pan">an</span>
          </div>
          <div class="logo-track">
            <div class="logo-line"></div>
            <svg class="logo-plane" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
              <path d="M22,16v-2l-8.5-5V3.5C13.5,2.67 12.83,2 12,2s-1.5,0.67-1.5,1.5V9L2,14v2l8.5-2.5V19L8.5,20.5V22L12,21l3.5,1v-1.5L13.5,19v-5.5L22,16z" />
            </svg>
          </div>
        </div>
        <span class="logo-dot">.</span>
      </div>
    </div>

    <p class="modal-auth-subtitle">우리만의 완벽한 여행을 시작해 볼까요?</p>

    <form name="modalLoginForm" action="${pageContext.request.contextPath}/member/login" method="post" class="modal-auth-form">
      <input type="text" name="loginId" class="modal-auth-input" placeholder="아이디를 입력해주세요" required>
      <input type="password" name="password" class="modal-auth-input" placeholder="비밀번호를 입력해주세요" required>
      <button type="submit" class="modal-auth-btn-submit">로그인</button>
    </form>

    <div class="modal-auth-links">
      <a href="${pageContext.request.contextPath}/member/findId">아이디 찾기</a>
      <span class="divider">|</span>
      <a href="${pageContext.request.contextPath}/member/findPw">비밀번호 찾기</a>
    </div>

    <div class="modal-auth-social-divider">
      <span>또는 3초 만에 시작하기</span>
    </div>

    <button class="modal-auth-btn-kakao" onclick="location.href='${pageContext.request.contextPath}/oauth2/authorization/kakao'">
      <svg style="width: 20px; height: 20px; fill: currentColor; margin-right: 8px;" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
        <path d="M12 3C6.477 3 2 6.556 2 10.944c0 2.822 1.83 5.3 4.613 6.744-.15.54-1.01 3.66-1.045 3.82.04.09.28.21.36.21.1 0 .23-.05.41-.1l3.52-1.42c2.4.67 5.17.67 7.57 0 .18.05.31.1.41.1.08 0 .32-.12.36-.21-.03-.16-.89-3.28-1.04-3.82 2.78-1.44 4.61-3.92 4.61-6.744C22 6.556 17.523 3 12 3z"/>
      </svg>
      카카오로 시작하기
    </button>

    <div class="modal-auth-signup-prompt">아직 Tripan 회원이 아니신가요?</div>
    <a href="${pageContext.request.contextPath}/member/join" class="modal-auth-btn-signup">Tripan 가입하기</a>
  </div>
</div>

<script>
  const IS_LOGGED_IN = <sec:authorize access="isAuthenticated()">true</sec:authorize><sec:authorize access="isAnonymous()">false</sec:authorize>;

  function showLoginModal() {
    const line  = document.querySelector('.logo-line');
    const plane = document.querySelector('.logo-plane');
    const dot   = document.querySelector('.logo-dot');
    
    if (line && plane && dot) {
      line.style.animation  = 'none';
      plane.style.animation = 'none';
      dot.style.animation   = 'none';
      void line.offsetWidth; 
      line.style.animation  = '';
      plane.style.animation = '';
      dot.style.animation   = '';
    }
    document.getElementById('loginPromptModal').classList.add('show');
  }

  function closeLoginModal() { 
    document.getElementById('loginPromptModal').classList.remove('show'); 
  }

  function checkAuthAndRun(callbackFn) {
    if (!IS_LOGGED_IN) { 
      showLoginModal(); 
    } else { 
      if (typeof callbackFn === 'function') {
        callbackFn(); 
      }
    }
  }
</script>