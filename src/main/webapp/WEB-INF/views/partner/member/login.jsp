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

    <form action="${pageContext.request.contextPath}/member/login" method="POST">
      <div class="form-group">
        <label class="form-label">아이디</label>
        <input type="text" name="loginId" class="form-control" placeholder="아이디를 입력해주세요" required autofocus>
      </div>
      <div class="form-group">
        <label class="form-label">비밀번호</label>
        <input type="password" name="password" class="form-control" placeholder="비밀번호를 입력해주세요" required>
      </div>
      
      <button type="submit" class="btn-login">로그인</button>
    </form>

    <div class="util-links">
      <a href="${pageContext.request.contextPath}/member/pwd"></a>
      <a href="${pageContext.request.contextPath}/member/member">일반 회원가입 (입점신청용)</a>
    </div>
  </div>
</div>

</body>
</html>