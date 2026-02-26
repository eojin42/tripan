<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>hShop</title>
<jsp:include page="/WEB-INF/views/layout/headerResources.jsp"/>
</head>
<body>

<header>
	<jsp:include page="/WEB-INF/views/layout/header.jsp"/>
</header>
<style>
    /* 로그인 페이지 전용 스타일 */
    .login-section {
      min-height: 100vh;
      display: flex;
      align-items: center;
      justify-content: center;
      background-color: var(--bg-light); /* 기존 배경색 활용 */
      padding: 120px 20px 60px; /* 헤더 높이 고려 */
    }

    .login-card {
      background: var(--bg-white);
      width: 100%;
      max-width: 420px;
      padding: 48px 32px;
      border-radius: var(--radius-lg); /* 32px 둥근 모서리 */
      box-shadow: 0 16px 40px rgba(0, 0, 0, 0.08);
      text-align: center;
    }

    .login-logo {
      font-size: 32px;
      font-weight: 900;
      letter-spacing: -1px;
      margin-bottom: 8px;
      background: linear-gradient(135deg, var(--vivid-coral), var(--electric-blue));
      -webkit-background-clip: text;
      -webkit-text-fill-color: transparent;
    }

    .login-desc {
      color: var(--text-gray);
      font-size: 15px;
      font-weight: 600;
      margin-bottom: 32px;
    }

    .form-group {
      margin-bottom: 16px;
      text-align: left;
    }

    .form-input {
      width: 100%;
      padding: 16px;
      border: 1px solid var(--border-light);
      border-radius: var(--radius-sm);
      font-size: 15px;
      font-family: var(--font-sans);
      transition: all 0.3s ease;
      background-color: var(--bg-light);
    }

    .form-input:focus {
      outline: none;
      border-color: var(--electric-blue);
      background-color: var(--bg-white);
      box-shadow: 0 0 0 3px rgba(77, 150, 255, 0.1);
    }

    .btn-submit {
      width: 100%;
      padding: 16px;
      background: var(--text-black);
      color: var(--bg-white);
      border: none;
      border-radius: var(--radius-sm);
      font-size: 16px;
      font-weight: 800;
      cursor: pointer;
      transition: all 0.3s var(--bounce);
      margin-top: 8px;
    }

    .btn-submit:hover {
      background: var(--electric-blue);
      transform: translateY(-2px);
      box-shadow: 0 8px 16px rgba(77, 150, 255, 0.2);
    }

    .social-divider {
      display: flex;
      align-items: center;
      margin: 24px 0;
      color: var(--text-gray);
      font-size: 13px;
      font-weight: 600;
    }

    .social-divider::before,
    .social-divider::after {
      content: "";
      flex: 1;
      border-bottom: 1px solid var(--border-light);
    }

    .social-divider span {
      padding: 0 12px;
    }

    .btn-social {
      width: 100%;
      padding: 14px;
      border-radius: var(--radius-sm);
      font-size: 15px;
      font-weight: 700;
      display: flex;
      align-items: center;
      justify-content: center;
      gap: 8px;
      cursor: pointer;
      margin-bottom: 12px;
      transition: opacity 0.3s ease;
      border: none;
    }

    .btn-social:hover { opacity: 0.9; }
    
    .btn-kakao { background-color: #FEE500; color: #000000; }
    .btn-google { background-color: #FFFFFF; color: var(--text-dark); border: 1px solid var(--border-light); }

    .login-footer {
      margin-top: 24px;
      font-size: 14px;
      font-weight: 600;
      color: var(--text-gray);
    }

    .login-footer a {
      color: var(--electric-blue);
      margin-left: 8px;
    }
  </style>
</head>
<body>

  <main class="login-section">
    <div class="login-card reveal">
      <div class="login-logo">Tripan</div>
      <p class="login-desc">우리만의 여행을 시작해 볼까요?</p>

      <form action="${pageContext.request.contextPath}/loginProc" method="POST">
        <div class="form-group">
          <input type="email" name="username" class="form-input" placeholder="이메일 주소" required>
        </div>
        <div class="form-group">
          <input type="password" name="password" class="form-input" placeholder="비밀번호" required>
        </div>
        
        <button type="submit" class="btn-submit">이메일로 로그인</button>
      </form>

      <div class="social-divider">
        <span>또는 3초 만에 시작하기</span>
      </div>

      <button class="btn-social btn-kakao">
        카카오로 시작하기
      </button>
      <button class="btn-social btn-google">
        Google로 시작하기
      </button>

      <div class="login-footer">
        아직 계정이 없으신가요? <a href="${pageContext.request.contextPath}/member/join">회원가입</a>
      </div>
    </div>
  </main>

  <jsp:include page="/WEB-INF/views/layout/footer.jsp"/>

</body>
</html>