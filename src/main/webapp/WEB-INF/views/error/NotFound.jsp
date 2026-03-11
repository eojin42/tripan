<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Tripan - 페이지를 찾을 수 없습니다 (404)</title>
  
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/gh/orioncactus/pretendard@v1.3.8/dist/web/static/pretendard.css">
  
  <style>
    :root {
      /* Tripan 메인 컬러 시스템 */
      --sky-blue: #89CFF0;
      --light-pink: #FFB6C1; 
      --ice-melt: #A8C8E1; 
      --rain-pink: #E0BBC2;
      --grad-main: linear-gradient(135deg, var(--sky-blue), var(--light-pink));
      --bg-page: #F0F8FF;
      --glass-bg: rgba(255, 255, 255, 0.65); 
      --glass-border: rgba(255, 255, 255, 0.8);
      --text-black: #2D3748; 
      --text-dark: #4A5568; 
      --text-gray: #718096;
      --radius-xl: 24px;
      --bounce: cubic-bezier(0.34, 1.56, 0.64, 1);
    }

    body {
      background-color: var(--bg-page);
      color: var(--text-black);
      font-family: 'Pretendard', sans-serif;
      margin: 0;
      padding: 0;
      display: flex;
      align-items: center;
      justify-content: center;
      height: 100vh;
      /* 배경 그라데이션 패턴 */
      background-image: radial-gradient(at 0% 0%, rgba(137, 207, 240, 0.15) 0px, transparent 50%), 
                        radial-gradient(at 100% 100%, rgba(255, 182, 193, 0.15) 0px, transparent 50%);
      background-attachment: fixed;
    }

    .error-container {
      text-align: center;
      padding: 60px 40px;
      max-width: 500px;
      width: 90%;
      /* Glassmorphism 카드 스타일 */
      background: var(--glass-bg);
      backdrop-filter: blur(20px);
      -webkit-backdrop-filter: blur(20px);
      border: 1px solid var(--glass-border);
      border-radius: var(--radius-xl);
      box-shadow: 0 16px 40px rgba(45, 55, 72, 0.08);
      animation: float 6s ease-in-out infinite;
    }

    .error-code {
      font-size: 100px;
      font-weight: 900;
      margin: 0;
      background: var(--grad-main);
      -webkit-background-clip: text;
      -webkit-text-fill-color: transparent;
      line-height: 1;
      letter-spacing: -2px;
    }

    .error-icon {
      font-size: 60px;
      margin: 20px 0;
      display: inline-block;
      transform: rotate(-15deg);
    }

    .error-title {
      font-size: 24px;
      font-weight: 800;
      color: var(--text-black);
      margin-bottom: 12px;
    }

    .error-desc {
      font-size: 15px;
      font-weight: 600;
      color: var(--text-gray);
      margin-bottom: 32px;
      line-height: 1.6;
    }

    .btn-group {
      display: flex;
      gap: 12px;
      justify-content: center;
    }

    .btn {
      padding: 14px 28px;
      border-radius: 24px;
      font-weight: 800;
      font-size: 15px;
      cursor: pointer;
      transition: all 0.3s var(--bounce);
      border: none;
      text-decoration: none;
    }

    .btn-back {
      background: white;
      color: var(--text-dark);
      border: 1px solid var(--glass-border);
      box-shadow: 0 4px 12px rgba(0,0,0,0.05);
    }

    .btn-back:hover {
      background: #f8fafc;
      transform: translateY(-2px);
    }

    .btn-home {
      background: var(--grad-main);
      color: white;
      box-shadow: 0 8px 16px rgba(137, 207, 240, 0.3);
    }

    .btn-home:hover {
      transform: translateY(-2px) scale(1.02);
      box-shadow: 0 12px 24px rgba(137, 207, 240, 0.4);
    }

    @keyframes float {
      0% { transform: translateY(0px); }
      50% { transform: translateY(-10px); }
      100% { transform: translateY(0px); }
    }
  </style>
</head>
<body>

  <div class="error-container">
    <div class="error-icon">🪂</div>
    <h1 class="error-code">404</h1>
    <h2 class="error-title">지도에 없는 목적지입니다!</h2>
    <p class="error-desc">
      비행기가 엉뚱한 곳에 착륙한 것 같아요.<br>
      입력하신 주소를 다시 확인하시거나,<br>안전한 곳으로 이동해 볼까요?
    </p>
    
    <div class="btn-group">
      <button onclick="history.back()" class="btn btn-back">이전으로</button>
      <a href="/" class="btn btn-home">홈으로 가기 ✈️</a>
    </div>
  </div>

</body>
</html>