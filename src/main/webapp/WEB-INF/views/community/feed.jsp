<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt"%>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Tripan - 소셜 커뮤니티</title>
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/gh/orioncactus/pretendard@v1.3.8/dist/web/static/pretendard.css">
  <script src="https://cdn.jsdelivr.net/npm/fullcalendar@6.1.11/index.global.min.js"></script>
  <style>
    :root {
      --sky-blue: #89CFF0;
      --light-pink: #FFB6C1; --ice-melt: #A8C8E1; --rain-pink: #E0BBC2;
      --grad-main: linear-gradient(135deg, var(--sky-blue), var(--light-pink));
      --grad-sub: linear-gradient(120deg, var(--ice-melt) 0%, #C2B8D9 50%, var(--rain-pink) 100%);
      --bg-page: #F0F8FF;
      --glass-bg: rgba(255, 255, 255, 0.65); --glass-border: rgba(255, 255, 255, 0.8);
      --text-black: #2D3748; --text-dark: #4A5568; --text-gray: #718096; --border-color: #E2E8F0;
      --radius-xl: 24px;
      --bounce: cubic-bezier(0.34, 1.56, 0.64, 1);
      --point-blue: #89CFF0; 
      --logo-line-gradient: linear-gradient(90deg, #89CFF0, #FFB6C1);
    }
    
    body {
      background-color: var(--bg-page); color: var(--text-black);
      font-family: 'Pretendard', sans-serif;
      margin: 0; padding: 0;
      background-image: radial-gradient(at 0% 0%, rgba(137, 207, 240, 0.15) 0px, transparent 50%), radial-gradient(at 100% 100%, rgba(255, 182, 193, 0.15) 0px, transparent 50%);
      background-attachment: fixed;
    }

    .community-container {
      max-width: 1400px;
      width: 90%; margin: 120px auto 60px; padding: 0;
      display: grid; grid-template-columns: 240px 1fr 280px; gap: 15px; align-items: start;
    }
    
    .glass-card {
      background: var(--glass-bg); backdrop-filter: blur(20px); -webkit-backdrop-filter: blur(20px);
      border: 1px solid var(--glass-border); border-radius: var(--radius-xl);
      padding: 15px; box-shadow: 0 12px 32px rgba(45, 55, 72, 0.04); margin-bottom: 24px;
    }

    .profile-widget { text-align: center; }
    .profile-avatar { width: 80px; height: 80px; border-radius: 50%; border: 3px solid white;
      box-shadow: 0 8px 16px rgba(137, 207, 240, 0.3); margin: 0 auto 12px; overflow: hidden;
    }
    .profile-avatar img { width: 100%; height: 100%; object-fit: cover; }
    .profile-name { font-size: 18px; font-weight: 900; }
    .profile-stats { display: flex; justify-content: space-around;
      margin-top: 16px; padding-top: 16px; border-top: 1px dashed rgba(45,55,72,0.1); }
    .stat-box { display: flex; flex-direction: column; font-size: 13px;
      color: var(--text-gray); font-weight: 600; }
    .stat-box strong { font-size: 18px; color: var(--text-black); font-weight: 900; }

    .side-menu-widget { padding: 16px; }
    .side-nav { list-style: none; padding: 0; margin: 0;
      display: flex; flex-direction: column; gap: 8px; }
    .side-nav li { border-radius: 16px; overflow: hidden; }
    .side-nav a { display: flex; align-items: center; gap: 12px; padding: 14px 20px; color: var(--text-dark); font-weight: 800;
      font-size: 15px; text-decoration: none; transition: all 0.3s; }
    .side-nav a:hover { background: rgba(255, 255, 255, 0.8);
      color: var(--sky-blue); padding-left: 24px; }
    .side-nav li.active a { background: var(--grad-main); color: white;
      box-shadow: 0 4px 12px rgba(137, 207, 240, 0.4); padding-left: 20px; }

    .chat-widget h3 { font-size: 16px;
      font-weight: 800; margin-bottom: 16px; display: flex; align-items: center; justify-content: space-between; }
    .chat-room { display: flex; align-items: center;
      gap: 12px; padding: 12px; border-radius: 16px; transition: background 0.3s; cursor: pointer; margin-bottom: 8px;
    }
    .chat-room:hover { background: rgba(255,255,255,0.9); }
    .chat-icon { width: 40px; height: 40px; border-radius: 12px;
      background: var(--grad-sub); display: flex; align-items: center; justify-content: center; font-size: 20px; }
    .chat-info h4 { margin: 0; font-size: 14px; font-weight: 800; }
    .chat-info p { margin: 4px 0 0; font-size: 12px; color: var(--text-gray); }
    .live-dot { width: 8px; height: 8px; background: #FF6B6B; border-radius: 50%; box-shadow: 0 0 8px #FF6B6B;
      animation: pulse 1.5s infinite; }

    .feed-main { display: flex; flex-direction: column; gap: 24px; margin: 0px auto; width: 100%; min-height: 50vh; } 

    .widget-header { font-size: 16px; font-weight: 800; margin-bottom: 16px; }
    .festival-list { display: flex; flex-direction: column; gap: 12px; margin-bottom: 8px; }
    .festival-item { display: flex; gap: 12px; align-items: center; background: rgba(255,255,255,0.8); padding: 10px; border-radius: 12px; transition: 0.3s;
      cursor: pointer; }
    .festival-item:hover { transform: translateX(-4px); box-shadow: 0 4px 12px rgba(0,0,0,0.05); }
    .fes-date { background: var(--grad-sub); color: white; border-radius: 8px; padding: 8px; text-align: center; line-height: 1.2; min-width: 45px; }
    .fes-date span { display: block; font-size: 10px; font-weight: 600; text-transform: uppercase; }
    .fes-date strong { font-size: 16px; font-weight: 900; }
    .fes-info h4 { margin: 0 0 4px; font-size: 13px; font-weight: 800; }
    .fes-info p { margin: 0; font-size: 11px; color: var(--text-gray); }

    .game-widget { text-align: center; padding: 32px 20px; background: var(--grad-main); color: white; border-radius: var(--radius-xl);
      box-shadow: 0 12px 24px rgba(255, 182, 193, 0.4); position: relative; overflow: hidden; margin-bottom: 24px;
    }
    .game-widget::before { content: '✈️'; font-size: 100px; position: absolute; opacity: 0.1; top: -10px; right: -20px; transform: rotate(-15deg); }
    .game-widget h3 { font-size: 20px; font-weight: 900; margin: 0 0 8px; }
    .game-widget p { font-size: 13px; font-weight: 600; opacity: 0.9; margin: 0 0 20px; }
    .btn-game { background: white; color: var(--sky-blue); font-weight: 900; font-size: 15px; border: none; padding: 12px 24px;
      border-radius: 24px; cursor: pointer; box-shadow: 0 8px 16px rgba(0,0,0,0.1); transition: 0.3s var(--bounce); width: 100%;
    }
    .btn-game:hover { transform: scale(1.05); box-shadow: 0 12px 24px rgba(0,0,0,0.15); }

    @keyframes pulse { 
      0% { box-shadow: 0 0 0 0 rgba(255,107,107, 0.7); } 
      70% { box-shadow: 0 0 0 10px rgba(255,107,107, 0); } 
      100% { box-shadow: 0 0 0 0 rgba(255,107,107, 0); } 
    }
    
    @media (max-width: 1024px) { .community-container { grid-template-columns: 1fr 300px; } .left-sidebar { display: none; } }
    @media (max-width: 768px) { .community-container { grid-template-columns: 1fr; margin-top: 80px; } .right-sidebar { display: none; } }

    .login-modal-overlay {
      position: fixed; inset: 0; background: rgba(0, 0, 0, 0.4); backdrop-filter: blur(8px); -webkit-backdrop-filter: blur(8px);
      display: none; justify-content: center; align-items: center; z-index: 9999;
      opacity: 0; transition: opacity 0.3s ease;
    }
    .login-modal-overlay.show { display: flex; opacity: 1; }
    
    .login-modal-card {
      position: relative; background: #FFFFFF; border-radius: 32px; padding: 60px 40px 40px; width: 90%; max-width: 440px; text-align: center;
      box-shadow: 0 20px 40px rgba(0,0,0,0.15); transform: translateY(20px); transition: transform 0.3s var(--bounce);
    }
    .login-modal-overlay.show .login-modal-card { transform: translateY(0); }

    .modal-close-icon {
      position: absolute; top: 24px; right: 24px; background: none; border: none;
      font-size: 20px; color: #A0AEC0; cursor: pointer; transition: color 0.2s;
    }
    .modal-close-icon:hover { color: var(--text-black); }

    .modal-auth-brand-wrapper { text-align: center; margin-bottom: 12px; }
    .modal-auth-brand { display: inline-flex; align-items: flex-end; gap: 0; position: relative; }
    
    .logo-text-wrapper { position: relative; display: inline-block; padding-bottom: 8px; line-height: 1; }
    .modal-auth-tri { font-size: 40px; font-weight: 900; letter-spacing: -1.5px; color: #2D3748; }
    .modal-auth-pan { font-size: 40px; font-weight: 900; letter-spacing: -1.5px; color: #89CFF0; }
    
    .logo-track { position: absolute; left: 0; bottom: 0; width: 100%; height: 3px; overflow: visible; }
    .logo-line { 
      width: 100%; height: 100%; border-radius: 2px; background: var(--logo-line-gradient); 
      transform-origin: left center; transform: scaleX(0); 
    }
    .logo-plane { 
      position: absolute; bottom: -8px; left: -15px; width: 22px; height: 22px; 
      fill: var(--point-blue); transform: rotate(90deg); opacity: 0; pointer-events: none; 
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
    .modal-auth-input:focus { outline: none; border-color: var(--sky-blue); background: #fff; box-shadow: 0 0 0 3px rgba(137, 207, 240, 0.1); }
    
    .modal-auth-btn-submit {
      width: 100%; padding: 18px; background: #2D3748; color: white; border: none;
      border-radius: 12px; font-size: 16px; font-weight: 800; cursor: pointer; transition: 0.2s; margin-top: 8px;
    }
    .modal-auth-btn-submit:hover { background: #1A202C; transform: translateY(-2px); }

    .modal-auth-links { display: flex; justify-content: center; align-items: center; gap: 16px; font-size: 14px; color: #718096; font-weight: 600; margin-bottom: 30px; }
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
      background-image: linear-gradient(#FFFFFF, #FFFFFF), var(--grad-main);
      background-origin: border-box; background-clip: padding-box, border-box;
    }
    .modal-auth-btn-signup:hover { transform: translateY(-2px); box-shadow: 0 4px 12px rgba(137, 207, 240, 0.15); }
    
    .left-sidebar, .right-sidebar {
      position: sticky;
  	  top: 120px; 
  	  height: fit-content; 
  	  min-height: calc(100vh - 120px);
   /* max-height: calc(100vh - 140px); */
  /* overflow-y: auto; */
	}
	
	.festival-partial-modal {
	  position: fixed;
	  top: 100px; 
	  left: 12%; 
	  width: 70%; 
	  height: 80vh; 
	  background-color: #f8fafc;
	  z-index: 9999;
	  border-radius: 20px;
	  box-shadow: 0 10px 40px rgba(0,0,0,0.2);
	  transform: translateY(20px);
	  opacity: 0;
	  visibility: hidden;
	  transition: all 0.3s cubic-bezier(0.25, 1, 0.5, 1);
	  display: flex;
	  flex-direction: column;
	}
	
	.festival-partial-modal.active {
	  transform: translateY(0);
	  opacity: 1;
	  visibility: visible;
	}
	
	.festival-modal-header {
	  height: 70px;
	  padding: 0 30px;
	  display: flex;
	  justify-content: space-between;
	  align-items: center;
	  background: white; 
	  border-bottom: 3px solid var(--sky-blue); 
	  border-radius: 20px 20px 0 0;
	  cursor: grab;
	}
	
	.festival-modal-header:active {
		cursor: grabbing;
	}
	
	.festival-modal-header h2 {
	  font-size: 22px;
	  font-weight: 900;
	  background: var(--grad-main);
	  -webkit-background-clip: text;
	  -webkit-text-fill-color: transparent;
	  margin: 0;
	}
	
	.btn-close-modal {
	  width: 36px;
	  height: 36px;
	  background: #f1f5f9;
	  border: none;
	  border-radius: 50%;
	  font-size: 20px;
	  line-height: 1;
	  color: var(--text-gray);
	  cursor: pointer;
	  display: flex;
	  align-items: center;
	  justify-content: center;
	  transition: all 0.3s var(--bounce);
	}
	
	.btn-close-modal:hover {
	  background: var(--light-pink);
	  color: white;
	  transform: rotate(90deg) scale(1.1);
	}
	
	.festival-modal-body {
	  flex: 1;
	  display: grid;
	  grid-template-columns: 1fr 300px; 
	  gap: 20px;
	  padding: 30px;
	  overflow: hidden; 
	}
	
	.calendar-area {
	  background: white;
	  border-radius: 16px;
	  box-shadow: 0 4px 20px rgba(137, 207, 240, 0.15); 
	  display: flex;
	  align-items: center;
	  justify-content: center;
	}
	
	.festival-detail-list {
	  background: white;
	  border-radius: 16px;
	  padding: 20px;
	  overflow-y: auto; 
	  display: flex;
	  flex-direction: column;
	  gap: 12px;
	}
	
	.festival-card {
	  border: 2px solid transparent;
	  border-radius: 12px;
	  padding: 16px;
	  cursor: pointer;
	  text-decoration: none; 
	  color: inherit;
	  display: block;
	  background: #fafafa;
	  transition: all 0.3s ease;
	}
	.festival-card:hover {
	  background: white;
	  border-color: var(--sky-blue);
	  box-shadow: 0 8px 20px rgba(137, 207, 240, 0.2);
	  transform: translateY(-3px);
	}
	
	.fc .fc-button-primary {
	  background-color: var(--sky-blue) !important;
	  border-color: var(--sky-blue) !important;
	  font-family: 'Pretendard', sans-serif;
	  font-weight: 600;
	  border-radius: 8px !important;
	  transition: 0.2s;
	}
	
	.fc .fc-button-primary:hover {
	  background-color: #72bde0 !important;
	  border-color: #72bde0 !important;
	}
	
	.fc .fc-toolbar-title {
	  font-size: 1.3rem !important;
	  font-weight: 900;
	  color: var(--text-dark);
	}
	
	.fc .fc-daygrid-day.fc-day-today {
	  background-color: rgba(255, 182, 193, 0.15) !important; 
	}
	
	.fc-event {
	  border-radius: 4px;
	  border: none !important;
	  font-weight: 700;
	  padding: 2px 4px;
	  cursor: pointer;
	}
	.fc-daygrid-day-number {
    font-family: 'Pretendard', sans-serif;
    font-weight: 700;
    color: var(--text-dark);
    text-decoration: none !important;
}
	.fc-col-header-cell-cushion {
	    font-weight: 800;
	    color: var(--text-black);
	    text-decoration: none !important;
	}
	
    
  </style>
</head>
<body>

  <jsp:include page="/WEB-INF/views/layout/header.jsp"/>

  <main class="community-container">
    <aside class="left-sidebar">
      <div class="glass-card profile-widget">
        <div class="profile-avatar">
		  <c:choose>
		    <c:when test="${not empty sessionScope.member and not empty sessionScope.member.profileImage}">
		      <img src="${pageContext.request.contextPath}/uploads/profile/${sessionScope.member.profileImage}" alt="My Profile">
		    </c:when>
		    <c:otherwise>
		      <svg class="profile-airplane-icon" viewBox="0 0 24 24" 
		           style="width: 100%; height: 100%; fill: var(--sky-blue); padding: 18px; box-sizing: border-box; background: #F0F8FF;">
		        <path d="M22,16v-2l-8.5-5V3.5C13.5,2.67 12.83,2 12,2s-1.5,0.67-1.5,1.5V9L2,14v2l8.5-2.5V19L8.5,20.5V22L12,21l3.5,1v-1.5L13.5,19v-5.5L22,16z"></path>
		      </svg>
		    </c:otherwise>
		  </c:choose>
		</div>
<div class="profile-name">${sessionScope.member.nickname != null ? sessionScope.member.nickname : '여행자'} 님</div>
        <div class="profile-stats">
          <div class="stat-box">게시물 <strong>0</strong></div>
          <div class="stat-box">팔로워 <strong>0</strong></div>
          <div class="stat-box">팔로잉 <strong>0</strong></div>
        </div>
      </div>

      <div class="glass-card side-menu-widget">
        <ul class="side-nav">
          <li class="active" id="tab-feed"> 
            <a href="#" onclick="loadTabContent('feed', event)">📝 Feed </a>
          </li>
          <li id="tab-hot">
            <a href="#" onclick="loadTabContent('hot', event)">🔎 Hot & Now </a>
          </li>
          <li id="tab-freeboard">
            <a href="#" onclick="loadTabContent('freeboard', event)">💬 Lounge </a>
          </li>
        </ul>
      </div>

      <div class="glass-card chat-widget">
        <h3>실시간 지역 톡 <span class="live-dot"></span></h3>
        <div class="chat-room" onclick="checkAuthAndRun(() => alert('채팅방 입장!'))"><div class="chat-icon">🌴</div><div class="chat-info"><h4>제주도 동행/맛집 방</h4><p>현재 124명 접속 중</p></div></div>
        <div class="chat-room" onclick="checkAuthAndRun(() => alert('채팅방 입장!'))"><div class="chat-icon">🌊</div><div class="chat-info"><h4>부산 해운대 핫플 공유</h4><p>현재 89명 접속 중</p></div></div>
        <div class="chat-room" onclick="checkAuthAndRun(() => alert('채팅방 입장!'))"><div class="chat-icon">🏔️</div><div class="chat-info"><h4>강원도 렌터카 드라이브</h4><p>현재 45명 접속 중</p></div></div>
      </div>
    </aside>

    <section class="feed-main" id="dynamic-content">
      <jsp:include page="fragment/feed_list.jsp"/>
    </section>

    <aside class="right-sidebar">
	  <div class="glass-card" onclick="openFestivalModal()" style="cursor: pointer; transition: transform 0.2s;" onmouseover="this.style.transform='scale(1.02)'" onmouseout="this.style.transform='scale(1)'">
  <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 16px;">
    <h3 class="widget-header" style="margin:0;">🎉 전국 축제 캘린더</h3>
    <span style="font-size: 12px; color: var(--sky-blue); font-weight: bold;">더보기 ❯</span>
  </div>
  
  <div class="festival-list" style="display: flex; flex-direction: column; gap: 14px;">
    <div class="festival-item" style="display: flex; gap: 12px; align-items: center;">
      <div class="fes-date" style="background: var(--sky-blue); color: white; padding: 6px 10px; border-radius: 8px; text-align: center; min-width: 45px;">
        <span style="font-size: 10px; display: block; line-height: 1;">MAR</span>
        <strong style="font-size: 16px; display: block; line-height: 1.2; margin-top: 2px;">15</strong>
      </div>
      <div class="fes-info">
        <h4 style="margin: 0 0 4px 0; font-size: 14px; color: var(--text-dark);">광양 매화축제</h4>
        <p style="margin: 0; font-size: 12px; color: var(--text-gray);">전남 광양시 다압면</p>
      </div>
    </div>

    <div class="festival-item" style="display: flex; gap: 12px; align-items: center;">
      <div class="fes-date" style="background: var(--sky-blue); color: white; padding: 6px 10px; border-radius: 8px; text-align: center; min-width: 45px;">
        <span style="font-size: 10px; display: block; line-height: 1;">MAR</span>
        <strong style="font-size: 16px; display: block; line-height: 1.2; margin-top: 2px;">22</strong>
      </div>
      <div class="fes-info">
        <h4 style="margin: 0 0 4px 0; font-size: 14px; color: var(--text-dark);">진해 군항제</h4>
        <p style="margin: 0; font-size: 12px; color: var(--text-gray);">경남 창원시 진해구</p>
      </div>
    </div>

    <div class="festival-item" style="display: flex; gap: 12px; align-items: center;">
      <div class="fes-date" style="background: var(--sky-blue); color: white; padding: 6px 10px; border-radius: 8px; text-align: center; min-width: 45px;">
        <span style="font-size: 10px; display: block; line-height: 1;">APR</span>
        <strong style="font-size: 16px; display: block; line-height: 1.2; margin-top: 2px;">05</strong>
      </div>
      <div class="fes-info">
        <h4 style="margin: 0 0 4px 0; font-size: 14px; color: var(--text-dark);">여의도 봄꽃축제</h4>
        <p style="margin: 0; font-size: 12px; color: var(--text-gray);">서울 영등포구 일대</p>
      </div>
    </div>
  </div>
</div>

      <div class="game-widget">
        <h3>어디 갈지 고민될 땐?</h3>
        <p>Tripan AI 룰렛이 취향에 맞춰<br>완벽한 목적지를 골라드려요!</p>
        <button class="btn-game" onclick="startRoulette()">🎲 랜덤 여행지 뽑기</button>
      </div>
    </aside>

  </main>

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
      <a href="${pageContext.request.contextPath}/member/join" class="modal-auth-btn-signup">이메일로 3초 만에 가입하기</a>
    </div>
  </div>
  
  <!--  캘린더 부분 -->
 <div id="festivalModal" class="festival-partial-modal">
  <div class="festival-modal-header">
    <h2>🎉 Tripan 전국 축제 캘린더</h2>
    <button class="btn-close-modal" onclick="closeFestivalModal()">&times;</button>
  </div>
  
  <div class="festival-modal-body">
    <div class="calendar-area" style="display: block; padding: 20px; overflow: hidden;">
	  <div id="calendar" style="height: 100%;"></div>
	</div>
    
    <div class="festival-detail-list">
      <h3 style="margin-top:0; color:var(--text-dark);">이달의 추천 축제</h3>
      
      <a href="https://korean.visitkorea.or.kr" target="_blank" class="festival-card">
        <h4 style="margin:0 0 6px 0;">🌸 광양 매화축제</h4>
        <p style="margin:0; font-size:12px; color:var(--text-gray);">🗓️ 2026.03.15 ~ 2026.03.24</p>
      </a>

      <a href="https://korean.visitkorea.or.kr" target="_blank" class="festival-card">
        <h4 style="margin:0 0 6px 0;">🌸 진해 군항제</h4>
        <p style="margin:0; font-size:12px; color:var(--text-gray);">🗓️ 2026.03.22 ~ 2026.04.01</p>
      </a>
      
      <a href="https://korean.visitkorea.or.kr" target="_blank" class="festival-card">
        <h4 style="margin:0 0 6px 0;">🌷 태안 튤립축제</h4>
        <p style="margin:0; font-size:12px; color:var(--text-gray);">🗓️ 2026.04.10 ~ 2026.05.08</p>
      </a>
    </div>
  </div>
</div>
  

  <jsp:include page="/WEB-INF/views/layout/footer.jsp"/>

  <script>
    function startRoulette() {
      const dests = ['여수 밤바다 낭만 투어', '경주 황리단길 카페 투어', '강원도 양양 서핑 트립', '제주도 한라산 등반'];
      const random = dests[Math.floor(Math.random() * dests.length)];
      alert("🎲 추천 결과: [" + random + "]\n관련 피드와 숙소를 검색해볼까요?");
    }

    const IS_LOGGED_IN = <sec:authorize access="isAuthenticated()">true</sec:authorize><sec:authorize access="isAnonymous()">false</sec:authorize>;
    let isFetching = false;     
    let scrollObserver = null; 

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
    function closeLoginModal() { document.getElementById('loginPromptModal').classList.remove('show'); }

    function checkAuthAndRun(callbackFn) {
      if (!IS_LOGGED_IN) { showLoginModal(); } 
      else { callbackFn(); }
    }

    function setupInfiniteScroll() {
      if(scrollObserver) scrollObserver.disconnect();
      const targetEl = document.getElementById('infiniteScrollTarget');
      if (!targetEl) return; 

      scrollObserver = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
          if (entry.isIntersecting && !isFetching) { handleInfiniteScroll(targetEl); }
        });
      }, { root: null, rootMargin: '0px', threshold: 0.1 });
      scrollObserver.observe(targetEl);
    }

    function handleInfiniteScroll(trigger) {
      if (isFetching) return;
      if (!IS_LOGGED_IN) { showLoginModal(); return; }

      isFetching = true;
      trigger.innerHTML = '로딩 중... ⏳';
      setTimeout(() => {
        const container = document.getElementById('feedListContainer');
        if(container && container.children.length > 0) {
          const firstCardClone = container.children[0].cloneNode(true);
          container.appendChild(firstCardClone);
        }
        isFetching = false;
        trigger.innerHTML = '아래로 스크롤하여 더 보기...';
      }, 800);
    }

    function loadTabContent(tabType, event) {
        event.preventDefault();
        if (!IS_LOGGED_IN && (tabType === 'hot' || tabType === 'freeboard')) {
            showLoginModal();
            return; 
        }

        document.querySelectorAll('.side-nav li').forEach(li => li.classList.remove('active'));
        document.getElementById('tab-' + tabType).classList.add('active'); 

        const contentArea = document.getElementById('dynamic-content');
        contentArea.innerHTML = '<div style="text-align:center; padding: 100px 20px; color:var(--sky-blue); font-size: 18px; font-weight:800;">데이터를 불러오는 중입니다... ✈️</div>';

        const url = '${pageContext.request.contextPath}/community/fragment/' + tabType;
        fetch(url, {
        	headers: {
        		'X-Requested-With': 'Fetch'
        	}
        })
          .then(response => {
            if(!response.ok) throw new Error("네트워크 응답 에러!");
            return response.text();
          })
          .then(html => {
            contentArea.innerHTML = html;
            setupInfiniteScroll();
            
            window.scrollTo({
            	top: 0,
            	behavior: 'smooth'
            })
            
          })
          .catch(error => {
            console.error('Error:', error);
            contentArea.innerHTML = '<div style="text-align:center; padding: 50px; color:red;">데이터를 불러오는데 실패했습니다. 😢</div>';
          });
    }
    
    
    
    window.addEventListener('DOMContentLoaded', () => { 
    	setupInfiniteScroll(); 
    	
    	const urlParams = new URLSearchParams(window.location.search);
    	const tabParams = urlParams.get('tab');
    	
    	if (tabParams && tabParams !== 'feed') {
    		loadTabContent(tabParams, null);
    	}
    
    });
    
    let festivalCalendar;
    let currentFestivals = [];
    
    async function fetchFestivals(year, month) {
        try {
            const url = '${pageContext.request.contextPath}/api/festivals?year=' + year + '&month=' + month;
            const response = await fetch(url);
            
            if (!response.ok) throw new Error('네트워크 응답 에러');
            const data = await response.json();
            currentFestivals = data; 
            return data;
        } catch (error) {
            console.error("데이터를 불러오지 못했습니다:", error);
            return []; 
        }
    }

    function updateFestivalSidebar(festivals, targetDate = null) {
        const sidebar = document.querySelector('.festival-detail-list');
        
        let titleHtml = `<h3 style="margin-top:0; color:var(--text-dark);">이달의 추천 축제 🎈</h3>`;
        if (targetDate) {
            titleHtml = `<h3 style="margin-top:0; color:var(--text-dark);">${targetDate} 진행 축제 🎈</h3>`;
        }
        
        sidebar.innerHTML = titleHtml;

        if (!festivals || festivals.length === 0) {
            sidebar.innerHTML += `<p style="font-size: 13px; color: var(--text-gray); padding: 20px 0; text-align: center;">해당 기간에 진행되는 축제가 없습니다. 🥲</p>`;
            return;
        }

        festivals.forEach(fes => {
            const address = fes.address ? fes.address : '장소 미정';
            const imgSrc = fes.image ? fes.image : '${pageContext.request.contextPath}/assets/img/default_festival.jpg';
            
            const cardHtml = `
                <div class="festival-card" onclick="window.open('https://search.naver.com/search.naver?query=\${encodeURIComponent(fes.title)}', '_blank')">
                    <div style="display: flex; gap: 12px;">
                        <img src="\${imgSrc}" style="width: 70px; height: 70px; border-radius: 8px; object-fit: cover;" alt="축제 이미지">
                        <div style="flex: 1;">
                            <h4 style="margin:0 0 6px 0; font-size: 14px; color: var(--text-dark);">\${fes.title}</h4>
                            <p style="margin:0 0 4px; font-size:11px; color:var(--text-gray);">📍 \${address}</p>
                            <p style="margin:0; font-size:12px; font-weight: bold; color: \${fes.color};">🗓️ \${fes.start} ~ \${fes.end}</p>
                        </div>
                    </div>
                </div>
            `;
            sidebar.innerHTML += cardHtml;
        });
    }

    function openFestivalModal() {
        document.getElementById('festivalModal').classList.add('active');
        document.body.style.overflow = 'hidden'; 
        
        setTimeout(() => {
            if (!festivalCalendar) {
                const calendarEl = document.getElementById('calendar');
                festivalCalendar = new FullCalendar.Calendar(calendarEl, {
                    initialView: 'dayGridMonth',
                    locale: 'ko', 
                    dayCellContent: function(info) {
                        return info.dayNumberText.replace('일', '');
                    },
                    headerToolbar: {
                        left: 'prev,next',
                        center: 'title',
                        right: 'today'
                    },
                    
                    events: async function(info, successCallback, failureCallback) {
                        const currentViewDate = new Date(info.start.valueOf() + 86400000 * 15); 
                        const year = currentViewDate.getFullYear();
                        const month = currentViewDate.getMonth() + 1;
                        const data = await fetchFestivals(year, month);

                        updateFestivalSidebar(data);
                        successCallback(data);
                    },
                    
                    eventClick: function(info) {
                        const clickedFestival = {
                            title: info.event.title,
                            start: info.event.startStr,
                            end: info.event.endStr || info.event.startStr,
                            color: info.event.backgroundColor,
                            address: info.event.extendedProps.address,
                            image: info.event.extendedProps.image
                        };
                        
                        updateFestivalSidebar([clickedFestival], info.event.title);
                    },
                    
                    dateClick: function(info) {
                        const clickDate = info.dateStr;
                        
                        const filtered = currentFestivals.filter(fes => {
                            return clickDate >= fes.start && clickDate <= fes.end;
                        });
                        
                        updateFestivalSidebar(filtered, clickDate);
                    }
                });
                festivalCalendar.render();
            } 
        }, 300);
    }

    const modal = document.getElementById('festivalModal');
    const modalHeader = document.querySelector('.festival-modal-header');

    let isDragging = false;
    let offsetX = 0;
    let offsetY = 0;

    modalHeader.addEventListener('mousedown', (e) => {
        isDragging = true;
        
        const rect = modal.getBoundingClientRect();
        offsetX = e.clientX - rect.left;
        offsetY = e.clientY - rect.top;
    });

    document.addEventListener('mousemove', (e) => {
        if (!isDragging) return;
        
        modal.style.transform = 'none'; 
        modal.style.left = (e.clientX - offsetX) + 'px';
        modal.style.top = (e.clientY - offsetY) + 'px';
    });

    document.addEventListener('mouseup', () => {
        isDragging = false;
    });

    function closeFestivalModal() {
        modal.classList.remove('active');
        document.body.style.overflow = 'auto'; 
        setTimeout(() => {
            modal.style.left = '12%';
            modal.style.top = '100px';
            modal.style.transform = ''; 
        }, 300); 
    }
    
    
  </script>
  
</body>
</html>