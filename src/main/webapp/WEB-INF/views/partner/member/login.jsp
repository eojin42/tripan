<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Tripan Partner — 로그인</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link href="https://fonts.googleapis.com/css2?family=Sora:wght@600;700;800&family=Noto+Sans+KR:wght@400;500;700;900&display=swap" rel="stylesheet">
  
  <style>
    :root {
      --bg: #F0F2F8; --surface: #FFFFFF; --text: #0D1117; --muted: #8B92A5; --border: rgba(0,0,0,0.07);
      --primary: #3B6EF8; --primary-10: rgba(59,110,248,0.10);
      --secondary: #8B5CF6;
      --radius-md: 12px; --radius-xl: 24px; --radius-full: 100px;
      --shadow-lg: 0 20px 60px rgba(0,0,0,0.12);
      --font-display: 'Sora', sans-serif; --font-body: 'Noto Sans KR', sans-serif;
    }
    
    body { background: var(--bg); font-family: var(--font-body); color: var(--text); display: flex; align-items: center; justify-content: center; min-height: 100vh; margin: 0; }
    
    .login-container { width: 100%; max-width: 440px; padding: 20px; }
    .login-card { background: var(--surface); border-radius: var(--radius-xl); box-shadow: var(--shadow-lg); padding: 50px 40px; border: 1px solid rgba(255,255,255,0.8); }
    
    .brand-logo { font-size: 28px; font-family: var(--font-display); font-weight: 900; letter-spacing: -0.5px; text-align: center; margin-bottom: 8px; }
    .brand-logo span.an { background: linear-gradient(to right, var(--primary), var(--secondary)); -webkit-background-clip: text; -webkit-text-fill-color: transparent; }
    .brand-desc { text-align: center; color: var(--muted); font-size: 15px; margin-bottom: 40px; font-weight: 500; }
    
    .form-group { margin-bottom: 20px; }
    .form-label { display: block; font-size: 13px; font-weight: 700; margin-bottom: 8px; color: var(--text); }
    .form-control { width: 100%; padding: 14px 16px; border: 1px solid #E5E7EB; border-radius: var(--radius-md); font-size: 15px; font-family: inherit; transition: all 0.2s; box-sizing: border-box; }
    .form-control:focus { outline: none; border-color: var(--primary); box-shadow: 0 0 0 4px var(--primary-10); }
    
    .btn-login { width: 100%; padding: 16px; background: var(--primary); color: white; border: none; border-radius: var(--radius-md); font-size: 16px; font-weight: 700; cursor: pointer; transition: all 0.2s; margin-top: 10px; }
    .btn-login:hover { opacity: 0.9; transform: translateY(-2px); box-shadow: 0 4px 12px rgba(59,110,248,0.3); }
    
    .util-links { display: flex; justify-content: space-between; margin-top: 20px; font-size: 13px; font-weight: 600; }
    .util-links a { color: var(--muted); text-decoration: none; transition: color 0.2s; }
    .util-links a:hover { color: var(--primary); }

    .error-msg { color: #EF4444; font-size: 13px; font-weight: 600; text-align: center; margin-bottom: 20px; }
    
    /* 🌟 커스텀 로그인 모달 스타일 */
    .modal-overlay {
      position: fixed; top: 0; left: 0; width: 100%; height: 100%;
      background: rgba(0,0,0,0.5); backdrop-filter: blur(4px);
      z-index: 9999; display: none; align-items: center; justify-content: center;
    }
    .modal-content {
      background: var(--surface); width: 340px; border-radius: 20px; padding: 32px 24px 24px;
      box-shadow: var(--shadow-lg); text-align: center; border: 1px solid rgba(255,255,255,0.8);
      animation: popIn 0.3s cubic-bezier(0.68, -0.55, 0.265, 1.55);
    }
    @keyframes popIn {
      0% { opacity: 0; transform: scale(0.9); }
      100% { opacity: 1; transform: scale(1); }
    }
    .modal-icon { font-size: 40px; margin-bottom: 16px; display: inline-block; }
    .modal-title { font-size: 18px; font-weight: 800; color: var(--text); margin-bottom: 12px; }
    .modal-desc { font-size: 14px; color: var(--muted); line-height: 1.5; margin-bottom: 24px; font-weight: 500; }
    .modal-actions { display: flex; gap: 10px; }
    .btn-modal-cancel { flex: 1; padding: 14px; background: #F0F2F8; color: #475569; border: none; border-radius: 12px; font-weight: 700; cursor: pointer; transition: 0.2s; }
    .btn-modal-cancel:hover { background: #E2E8F0; }
    .btn-modal-confirm { flex: 1; padding: 14px; background: var(--primary); color: white; border: none; border-radius: 12px; font-weight: 700; cursor: pointer; transition: 0.2s; }
    .btn-modal-confirm:hover { background: #2563EB; box-shadow: 0 4px 12px rgba(59,110,248,0.3); }
    
  </style>
</head>
<body>

<div class="login-container">
  <div class="login-card">
    <div class="brand-logo">
      Trip<span class="an">an</span>
    </div>
    <div class="brand-desc">파트너 센터 로그인</div>

    <c:if test="${not empty sessionScope.SPRING_SECURITY_LAST_EXCEPTION}">
        <div class="error-msg">아이디 또는 비밀번호가 일치하지 않습니다.</div>
        <c:remove var="SPRING_SECURITY_LAST_EXCEPTION" scope="session"/>
    </c:if>

    <form id="partnerLoginForm" action="${pageContext.request.contextPath}/member/login" method="POST">
      <div class="form-group">
        <label class="form-label">아이디</label>
        <input type="text" id="loginId" name="loginId" class="form-control" placeholder="아이디를 입력해주세요" required autofocus>
      </div>
      <div class="form-group">
        <label class="form-label">비밀번호</label>
        <input type="password" name="password" class="form-control" placeholder="비밀번호를 입력해주세요" required>
      </div>
      
      <button type="submit" class="btn-login">로그인</button>
    </form>

    <div class="util-links">
      <a href="${pageContext.request.contextPath}/member/pwd"></a>
      <a href="${pageContext.request.contextPath}/member/account">일반 회원가입</a>
    </div>
  </div>
</div>

<div class="modal-overlay" id="duplicateLoginModal">
  <div class="modal-content">
    <div class="modal-icon">📱</div>
    <div class="modal-title">이미 접속 중인 계정입니다</div>
    <div class="modal-desc">
      현재 다른 기기에서 관리자 계정으로<br>접속 중입니다.<br>기존 접속을 해제하고 로그인하시겠습니까?
    </div>
    <div class="modal-actions">
      <button class="btn-modal-cancel" onclick="closeLoginModal()">취소</button>
      <button class="btn-modal-confirm" onclick="forceLogin()">접속 해제</button>
    </div>
  </div>
</div>

<script>
document.getElementById('partnerLoginForm').addEventListener('submit', function(event) {
    event.preventDefault(); 

    const loginId = document.getElementById('loginId').value; 
    const form = this;

    fetch('${pageContext.request.contextPath}/partner/api/check-session?loginId=' + loginId, {
        method: 'POST'
    })
    .then(res => res.json())
    .then(data => {
        if (data.isLoggedIn) {
            document.getElementById('duplicateLoginModal').style.display = 'flex';
        } else {
            form.submit();
        }
    })
    .catch(error => {
        console.error('세션 체크 에러:', error);
        form.submit(); 
    });
});

function closeLoginModal() {
    document.getElementById('duplicateLoginModal').style.display = 'none';
}

function forceLogin() {
    document.getElementById('partnerLoginForm').submit();
}
</script>

</body>
</html>