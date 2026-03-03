<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<head>
  <meta charset="UTF-8">
  <title>Tripan - 오픈 라운지 테스트</title>
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/gh/orioncactus/pretendard@v1.3.8/dist/web/static/pretendard.css">
  <style>
    :root {
      --sky-blue: #89CFF0; --light-pink: #FFB6C1; --bg-page: #F0F8FF;
      --glass-bg: rgba(255, 255, 255, 0.7); --glass-border: rgba(255, 255, 255, 0.9);
      --grad-main: linear-gradient(135deg, var(--sky-blue), var(--light-pink));
      --text-black: #2D3748; --text-gray: #718096;
    }

    body {
      margin: 0; padding: 20px; font-family: 'Pretendard', sans-serif;
      background-color: var(--bg-page);
      background-image: radial-gradient(at 0% 0%, rgba(137, 207, 240, 0.2) 0px, transparent 50%), 
                        radial-gradient(at 100% 100%, rgba(255, 182, 193, 0.2) 0px, transparent 50%);
      display: flex; justify-content: center; align-items: center; height: 100vh;
    }

    /* 채팅창 전체 프레임 (글래스모피즘) */
    .chat-container {
      width: 100%; max-width: 450px; height: 80vh; max-height: 700px;
      background: var(--glass-bg); backdrop-filter: blur(20px); -webkit-backdrop-filter: blur(20px);
      border: 1px solid var(--glass-border); border-radius: 32px;
      box-shadow: 0 20px 40px rgba(45, 55, 72, 0.08);
      display: flex; flex-direction: column; overflow: hidden;
    }

    /* 상단 헤더: 해시태그 및 접속자 목록 */
    .chat-header {
      padding: 20px; background: rgba(255, 255, 255, 0.5); border-bottom: 1px solid rgba(255,255,255,0.8);
    }
    .chat-title-row { display: flex; justify-content: space-between; align-items: center; margin-bottom: 12px; }
    .chat-title { font-size: 18px; font-weight: 900; color: var(--text-black); margin: 0; }
    .chat-count { font-size: 13px; font-weight: 700; color: #FF6B6B; background: #FFE5E5; padding: 4px 10px; border-radius: 20px; }
    
    .chat-users { display: flex; gap: -10px; overflow-x: auto; padding-bottom: 4px; }
    .chat-users::-webkit-scrollbar { display: none; } /* 스크롤바 숨기기 */
    .user-avatar { 
      width: 36px; height: 36px; border-radius: 50%; border: 2px solid white; 
      object-fit: cover; flex-shrink: 0; margin-right: -10px; /* 프로필 겹치기 효과 */
      box-shadow: 0 4px 8px rgba(0,0,0,0.05);
    }

    /* 채팅 메시지 영역 */
    .chat-messages {
      flex: 1; padding: 20px; overflow-y: auto; display: flex; flex-direction: column; gap: 16px;
    }

    /* 공통 말풍선 스타일 */
    .msg-row { display: flex; gap: 10px; align-items: flex-end; }
    .msg-row.me { justify-content: flex-end; }
    
    .msg-profile { width: 40px; height: 40px; border-radius: 50%; object-fit: cover; }
    
    .msg-bubble {
      max-width: 70%; padding: 12px 16px; border-radius: 20px;
      font-size: 15px; line-height: 1.5; font-weight: 500;
      box-shadow: 0 4px 12px rgba(0,0,0,0.03);
    }
    
    /* 타인 말풍선: 하얀색 글래스 */
    .msg-row.other .msg-bubble {
      background: white; border-top-left-radius: 4px; color: var(--text-black);
    }
    .msg-name { font-size: 12px; color: var(--text-gray); margin-bottom: 4px; font-weight: 700; }

    /* 내 말풍선: Tripan 메인 그라데이션 */
    .msg-row.me .msg-bubble {
      background: var(--grad-main); color: white; border-bottom-right-radius: 4px;
    }

    .msg-time { font-size: 11px; color: #A0AEC0; font-weight: 600; margin-bottom: 4px; }

    /* 하단 입력창 */
    .chat-input-area {
      padding: 16px; background: rgba(255, 255, 255, 0.6);
      border-top: 1px solid rgba(255,255,255,0.8); display: flex; gap: 12px;
    }
    .chat-input {
      flex: 1; padding: 14px 20px; border: none; border-radius: 24px;
      background: rgba(255, 255, 255, 0.9); font-size: 15px; font-family: 'Pretendard', sans-serif;
      box-shadow: inset 0 2px 4px rgba(0,0,0,0.02); outline: none; transition: 0.3s;
    }
    .chat-input:focus { box-shadow: 0 0 0 2px var(--sky-blue); }
    .btn-send {
      width: 48px; height: 48px; border-radius: 50%; border: none;
      background: var(--grad-main); color: white; cursor: pointer;
      display: flex; justify-content: center; align-items: center;
      box-shadow: 0 4px 12px rgba(137, 207, 240, 0.4); transition: transform 0.2s;
    }
    .btn-send:hover { transform: scale(1.05); }
    .btn-send svg { width: 20px; height: 20px; fill: none; stroke: currentColor; stroke-width: 2.5; stroke-linecap: round; stroke-linejoin: round; margin-left: -2px; }
  </style>
</head>
<body>

  <div class="chat-container">
    <div class="chat-header">
      <div class="chat-title-row">
        <h2 class="chat-title">🌴 #제주도 동행/맛집 방</h2>
        <span class="chat-count">🔴 124명 접속 중</span>
      </div>
      <div class="chat-users">
        <img src="https://picsum.photos/seed/user1/100/100" class="user-avatar" style="z-index: 5;">
        <img src="https://picsum.photos/seed/user2/100/100" class="user-avatar" style="z-index: 4;">
        <img src="https://picsum.photos/seed/user3/100/100" class="user-avatar" style="z-index: 3;">
        <img src="https://picsum.photos/seed/user4/100/100" class="user-avatar" style="z-index: 2;">
        <div class="user-avatar" style="z-index: 1; background:#E2E8F0; display:flex; justify-content:center; align-items:center; font-size:12px; font-weight:800; color:#718096; border:2px solid white;">+120</div>
      </div>
    </div>

    <div class="chat-messages">
      <div class="msg-row other">
        <img src="https://picsum.photos/seed/user2/100/100" class="msg-profile">
        <div>
          <div class="msg-name">@서핑매니아</div>
          <div class="msg-bubble">혹시 지금 중문 색달해변 파도 어떤가요? 🌊</div>
        </div>
        <span class="msg-time">오후 2:30</span>
      </div>

      <div class="msg-row other">
        <img src="https://picsum.photos/seed/user3/100/100" class="msg-profile">
        <div>
          <div class="msg-name">@고기국수러버</div>
          <div class="msg-bubble">바람 꽤 불어서 서핑하기 딱 좋아요! 근데 웨이팅 있는 카페가 많네요 ㅠㅠ</div>
        </div>
        <span class="msg-time">오후 2:32</span>
      </div>

      <div class="msg-row me">
        <span class="msg-time">오후 2:35</span>
        <div class="msg-bubble">저 근처에 숨겨진 뷰 맛집 카페 아는데 위치 공유해드릴까요? 😎</div>
      </div>
    </div>

    <div class="chat-input-area">
      <input type="text" class="chat-input" placeholder="메시지를 입력하세요...">
      <button class="btn-send">
        <svg viewBox="0 0 24 24"><line x1="22" y1="2" x2="11" y2="13"></line><polygon points="22 2 15 22 11 13 2 9 22 2"></polygon></svg>
      </button>
    </div>
  </div>

</body>
</html>