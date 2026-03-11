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
	
	
	    .left-sidebar, .right-sidebar {
	      position: sticky;
	  	  top: 120px; 
	  	  height: fit-content; 
	  	  min-height: calc(100vh - 120px);
		}
		
		.festival-partial-modal {
		  position: fixed;
		  top: 50%; 
		  left: 50%; 
		  transform: translate(-50%, -45%) translateY(20px);
		  width: 80%; 
		  max-width: 1300px;
		  height: 85vh; 
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
		  transform: translate(-50%, -50%);
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
		  grid-template-columns: 1fr 420px; 
		  gap: 24px;
		  padding: 24px; 
		  overflow: hidden; 
		  min-height: 0; 
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
		  padding-bottom: 60px;
		  height: 100%;
		  box-sizing: border-box;
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
		
		.fc-event {
	        cursor: pointer;
	        border: none !important;
	        background: transparent !important; 
	        padding: 2px 4px;
	        margin-bottom: 2px;
	        transition: transform 0.2s;
	    }
	    .fc-event:hover {
	        transform: scale(1.05);
	    }
	    .fc-daygrid-event-dot {
	        border-color: var(--sky-blue) !important;
	        border-width: 4px !important;
	    }
	    .fc-event-title {
	        color: var(--text-dark) !important;
	        font-weight: 600;
	        font-size: 11px;
	    }
	    .fc-more-link {
	        color: var(--sky-blue) !important;
	        font-weight: 800;
	        font-size: 11px;
	        background: rgba(137, 207, 240, 0.1);
	        padding: 2px 6px;
	        border-radius: 4px;
	        text-decoration: none !important;
	    }
	    .fc-day-highlight {
	        background-color: rgba(255, 182, 193, 0.2) !important;
	        transition: background-color 0.3s;
	    }
		
		.fc-festival-hover {
		        background-color: rgba(137, 207, 240, 0.05) !important; 
		        box-shadow: inset 0 -10px 0 0 var(--sky-blue) !important; 
		        transition: all 0.2s ease-in-out;
		}
		
		.lounge-modal-overlay {
		  position: fixed; top: 0; left: 0; width: 100%; height: 100%;
		  background: rgba(0, 0, 0, 0.15); 
		  backdrop-filter: blur(3px); 
		  z-index: 10000; display: flex; align-items: center; justify-content: center;
		  opacity: 0; visibility: hidden; transition: all 0.3s ease;
		}
		.lounge-modal-overlay.active { opacity: 1; visibility: visible; }
	
		.lounge-modal-content {
		  width: 90%; max-width: 600px; 
		  background: var(--glass-bg);
		  border: 1px solid var(--glass-border); 
		  border-radius: var(--radius-xl);
		  transform: translateY(20px); transition: all 0.3s var(--bounce);
		  display: flex; flex-direction: column; gap: 16px; padding: 28px;
		  box-shadow: 0 16px 40px rgba(0,0,0,0.1);
		}
		.lounge-modal-overlay.active .lounge-modal-content { transform: translateY(0); }
	
		.lounge-modal-header { display: flex; justify-content: space-between; align-items: center; border-bottom: 2px solid rgba(137, 207, 240, 0.3); padding-bottom: 12px; }
		.lounge-modal-header h3 { margin: 0; font-size: 18px; font-weight: 800; color: var(--text-dark); }
	
		.lounge-editor { display: flex; flex-direction: column; gap: 12px; }
		.lounge-input-style {
		  width: 100%;
		  background: rgba(255, 255, 255, 0.8);
		  border: 1px solid rgba(137, 207, 240, 0.5);
		  border-radius: 8px;
		  font-family: 'Pretendard', sans-serif; font-size: 14px; color: var(--text-black);
		  padding: 12px 14px; box-sizing: border-box; outline: none; transition: 0.3s;
		}
		.lounge-input-style:focus { border-color: var(--sky-blue); background: #fff; box-shadow: inset 0 2px 6px rgba(137, 207, 240, 0.1); }
		#loungeTextarea { min-height: 180px; resize: none; }
	
		.lounge-toolbar { display: flex; justify-content: space-between; align-items: center; border-top: 1px dashed rgba(45,55,72,0.1); padding-top: 16px; }
		.toolbar-icons { display: flex; gap: 12px; }
		.icon-btn { background: white; border: 1px solid var(--border-color); border-radius: 50%; width: 40px; height: 40px; cursor: pointer; font-size: 18px; transition: 0.2s; box-shadow: 0 4px 10px rgba(0,0,0,0.05); }
		.icon-btn:hover { background: var(--sky-blue); color: white; transform: scale(1.1); border-color: transparent; }
		.btn-submit-lounge { background: var(--grad-main); color: white; border: none; border-radius: 20px; padding: 10px 24px; font-weight: 800; font-size: 15px; cursor: pointer; box-shadow: 0 4px 12px rgba(137, 207, 240, 0.4); transition: 0.2s; }
		.btn-submit-lounge:hover { transform: translateY(-2px); box-shadow: 0 6px 16px rgba(137, 207, 240, 0.6); }
	
		.preview-area { display: flex; gap: 8px; flex-wrap: wrap; }
		.thumb-wrap { position: relative; width: 60px; height: 60px; border-radius: 8px; overflow: hidden; border: 1px solid var(--border-color); }
		.thumb-wrap img { width: 100%; height: 100%; object-fit: cover; }
		.thumb-remove { position: absolute; top: 2px; right: 2px; background: rgba(0,0,0,0.6); color: white; border: none; border-radius: 50%; width: 18px; height: 18px; font-size: 10px; cursor: pointer; }
	
		.location-area { background: #EBF8FF; color: var(--sky-blue); padding: 8px 12px; border-radius: 8px; font-size: 13px; font-weight: 700; display: inline-flex; align-items: center; gap: 12px; width: fit-content; }
		.btn-remove-loc { background: rgba(137, 207, 240, 0.3); border: none; border-radius: 50%; width: 20px; height: 20px; font-size: 10px; color: #4A5568; cursor: pointer; transition: 0.2s; }
		.btn-remove-loc:hover { background: #FF6B6B; color: white; }
		
		
		select.lounge-input-style {
		  -webkit-appearance: none !important;
		  -moz-appearance: none !important;
		  appearance: none !important;
		  background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='%2389CFF0'%3E%3Cpath d='M7 10l5 5 5-5z'/%3E%3C/svg%3E") !important;
		  background-repeat: no-repeat !important;
		  background-position: right 14px center !important;
		  background-size: 24px !important;
		  background-color: rgba(255, 255, 255, 0.9) !important;
		  padding-right: 40px !important;
		  cursor: pointer;
		}
	
		select.lounge-input-style::-ms-expand { display: none !important; }
		
  .schedule-modal-overlay {
    position: fixed; top: 0; left: 0; width: 100%; height: 100%;
    background: rgba(0, 0, 0, 0.4); backdrop-filter: blur(3px); z-index: 10001;
    display: flex; align-items: center; justify-content: center;
    opacity: 0; visibility: hidden; transition: all 0.3s ease;
  }
  .schedule-modal-overlay.active { opacity: 1; visibility: visible; }
  .schedule-modal-content {
    width: 90%; max-width: 750px; height: 550px; background: white;
    border-radius: var(--radius-xl); display: flex; flex-direction: column; overflow: hidden;
    box-shadow: 0 20px 40px rgba(0,0,0,0.15); transform: translateY(20px); transition: 0.3s var(--bounce);
  }
  .schedule-modal-overlay.active .schedule-modal-content { transform: translateY(0); }
  
  .sch-header { padding: 20px 24px; border-bottom: 1px solid var(--border-color); display: flex; justify-content: space-between; align-items: center; }
  .sch-header h3 { margin: 0; font-size: 20px; font-weight: 800; color: var(--text-black); }
  
  .sch-body { display: flex; flex: 1; overflow: hidden; }
  .sch-list-area { flex: 1; border-right: 1px solid var(--border-color); overflow-y: auto; padding: 20px; background: #fafafa; }
  .sch-preview-area { width: 280px; background: white; padding: 24px; display: flex; flex-direction: column; }
  
  .sch-item { 
    padding: 16px; border: 2px solid transparent; border-radius: 16px; background: white; margin-bottom: 12px; 
    cursor: pointer; transition: 0.2s; display: flex; justify-content: space-between; align-items: center; box-shadow: 0 2px 8px rgba(0,0,0,0.04);
  }
  .sch-item:hover { border-color: var(--ice-melt); transform: translateY(-2px); }
  .sch-item.selected { border-color: var(--sky-blue); background: #F0F8FF; }
  .sch-item .check-circle { width: 22px; height: 22px; border-radius: 50%; border: 2px solid var(--border-color); display: flex; align-items: center; justify-content: center; }
  .sch-item.selected .check-circle { background: var(--sky-blue); border-color: var(--sky-blue); }
  .sch-item.selected .check-circle::after { content: '✔'; color: white; font-size: 14px; font-weight: bold; }
  
  .sch-footer { padding: 16px 24px; border-top: 1px solid var(--border-color); display: flex; justify-content: flex-end; gap: 12px; background: #fafafa; }
  .btn-sch-cancel { padding: 10px 24px; border-radius: 20px; border: 1px solid var(--border-color); background: white; font-weight: 700; color: var(--text-dark); cursor: pointer; transition: 0.2s; }
  .btn-sch-cancel:hover { background: #f1f5f9; }
  .btn-sch-confirm { padding: 10px 32px; border-radius: 20px; border: none; background: var(--sky-blue); color: white; font-weight: 800; cursor: pointer; transition: 0.2s; box-shadow: 0 4px 12px rgba(137, 207, 240, 0.3); }
  .btn-sch-confirm:hover { background: #72bde0; transform: translateY(-2px); }
  
  .author-left { cursor: pointer; }
  .author-left:hover .name { color: var(--sky-blue); }
		
	  </style>
	  
	</head>
	<body>
	
	  <jsp:include page="/WEB-INF/views/layout/header.jsp"/>
	
	  <main class="community-container">
	    <aside class="left-sidebar">
	    
		<%-- 로그인 상태일 때 --%>
	      <div class="glass-card profile-widget">
			  <c:choose>
			    <c:when test="${not empty sessionScope.loginUser}">
			      <a href="${pageContext.request.contextPath}/community/myfeed?memberId=${sessionScope.loginUser.memberId}" style="text-decoration: none; color: inherit;">
			        <div class="profile-avatar">
			          <c:choose>
			            <c:when test="${not empty sessionScope.loginUser.profilePhoto}">
			              <img src="${pageContext.request.contextPath}/uploads/profile/${sessionScope.loginUser.profilePhoto}" alt="My Profile">
			            </c:when>
			            <c:otherwise>
			              <img src="${pageContext.request.contextPath}/dist/images/default.png" alt="Default Profile">
			            </c:otherwise>
			          </c:choose>
			        </div>
			        <div class="profile-name">${sessionScope.loginUser.nickname} 님</div>
			      </a>
			      
			      <div class="profile-stats">
			        <div class="stat-box">게시물 <strong>0</strong></div>
			        <div class="stat-box">팔로워 <strong>0</strong></div>
			        <div class="stat-box">팔로잉 <strong>0</strong></div>
			      </div>
			    </c:when>
			    
			    <%-- 비로그인 상태일 때 --%>
			    <c:otherwise>
			      <div class="profile-avatar">
			         <img src="${pageContext.request.contextPath}/dist/images/default.png" alt="Default Profile">
			      </div>
			      <div class="profile-name">여행자 님</div>
			      <div class="profile-stats">
			        <div class="stat-box" style="width: 100%;">
			          <button class="btn-follow" onclick="showLoginModal()" style="width: 100%; border-radius: 20px; background: var(--sky-blue); color: white; border: none; padding: 8px 0; font-weight: bold; cursor: pointer;">로그인하고 시작하기</button>
			        </div>
			      </div>
			    </c:otherwise>
			  </c:choose>
			</div>
	
	      <div class="glass-card side-menu-widget">
	        <ul class="side-nav">
	          <li class="active" id="tab-feed"> 
	            <a href="#" onclick="loadTabContent('feed', event)">📝 Feed </a>
	          </li>
			  <li id="tab-mate">
			    <a href="#" onclick="loadTabContent('mate', event)">🤝 travel mate </a>
			  </li>
	          <li id="tab-freeboard">
	            <a href="#" onclick="loadTabContent('freeboard', event)">💬 Lounge </a>
	          </li>
	        </ul>
	      </div>
	
	      <div class="glass-card chat-widget" style="cursor: pointer;" onclick="checkAuthAndRun(() => window.openGlobalChat())">
			<h3>실시간 지역 톡 <span class="live-dot"></span></h3>
			  
			<div id="live-chat-list">
				<p style="text-align:center; font-size:12px; color:var(--text-gray); padding: 10px 0;">로딩 중... 💬</p>
			</div>
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
		    
		    <div id="mini-festival-list" class="festival-list" style="display: flex; flex-direction: column; gap: 14px;">
		      <p style="text-align:center; font-size:12px; color:var(--text-gray);">축제 정보를 불러오는 중... ✈️</p>
		    </div>
		  </div>
	
	      <div class="game-widget">
	        <h3>어디 갈지 고민될 땐?</h3>
	        <p>Tripan AI 룰렛이 취향에 맞춰<br>완벽한 목적지를 골라드려요!</p>
	        <button class="btn-game" onclick="startRoulette()">🎲 랜덤 여행지 뽑기</button>
	      </div>
	    </aside>
	
	  </main>
	
	  <div id="festivalModal" class="festival-partial-modal">
	    <div class="festival-modal-header">
	      <h2>🎉 Tripan 전국 축제 캘린더</h2>
	      <button class="btn-close-modal" onclick="closeFestivalModal()">✕</button>
	    </div>
	    <div class="festival-modal-body">
	      <div class="calendar-area">
	        <div id="calendar" style="width: 100%; height: 100%; padding: 10px;"></div>
	      </div>
	      <div class="festival-detail-list">
	        </div>
	    </div>
	  </div>
	  
	  <div id="loungeWriteModal" class="lounge-modal-overlay">
	    <div class="lounge-modal-content glass-card">
	      <div class="lounge-modal-header">
	        <h3>새로운 이야기 ✈️</h3>
	        <button class="btn-close-modal" onclick="closeLoungeModal()">✕</button>
	      </div>
	      
	      <div class="lounge-editor">
	        <select id="loungeCategory" class="lounge-input-style">
	          <option value="">말머리(카테고리)를 선택해주세요</option>
	          <option value="tip">💡 여행 꿀팁</option>
	          <option value="question">🙋‍♂️ 질문있어요</option>
	          <option value="review">📸 다녀온 후기</option>
	        </select>
	
	        <input type="text" id="loungeTitle" class="lounge-input-style" placeholder="제목을 입력하세요">
	        
	        <textarea id="loungeTextarea" class="lounge-input-style" placeholder="여행자님, 지금 어떤 생각 중이신가요?"></textarea>
	        
	        <div id="photoPreviewArea" class="preview-area"></div>
	        
	        <div id="locationPreviewArea" class="location-area" style="display: none;">
	          📍 <span id="locationText">위치 정보를 불러오는 중...</span>
	          <button type="button" class="btn-remove-loc" onclick="removeLocation()" title="위치 지우기">✕</button>
	        </div>
	        
	        <div id="scheduleSelectArea" class="schedule-area" style="display: none;">
	          <select id="myTripSelect" class="lounge-input-style">
	            <option value="">📅 공유할 내 일정을 선택하세요</option>
	            <option value="1">제주도 3박 4일 힐링 여행</option>
	            <option value="2">여수 밤바다 낭만 투어</option>
	          </select>
	        </div>
	      </div>
	
	      <div class="lounge-toolbar">
	        <div class="toolbar-icons">
	          <button type="button" class="icon-btn" onclick="toggleSchedule()" title="일정 공유">📅</button>
	          <button type="button" class="icon-btn" onclick="document.getElementById('loungeFileInput').click()" title="사진 첨부">📷</button>
	          <input type="file" id="loungeFileInput" accept="image/*" multiple style="display: none;" onchange="handleFiles(this.files)">
	          <button type="button" class="icon-btn" onclick="getLocation()" title="위치 공유">📍</button>
	        </div>
	        <button class="btn-submit-lounge" onclick="submitLoungePost()">작성 완료</button>
	      </div>
	    </div>
	  </div>
	  
	  <div id="scheduleModal" class="schedule-modal-overlay">
  <div class="schedule-modal-content">
    <div class="sch-header">
      <h3>📅 공유할 일정 선택</h3>
      <button onclick="closeScheduleModal()" style="background:none; border:none; font-size:24px; color:var(--text-gray); cursor:pointer;">✕</button>
    </div>
    
    <div class="sch-body">
      <div class="sch-list-area">
        <div class="sch-item" onclick="toggleScheduleSelect(this, '0000000000000000001', '제주도 3박 4일 힐링 여행')">
          <div>
            <h4 style="margin: 0 0 6px; font-size: 16px; font-weight: 800; color: var(--text-black);">제주도 3박 4일 힐링 여행</h4>
            <p style="margin: 0; font-size: 13px; color: var(--text-gray);">2024.05.10 ~ 2024.05.13</p>
          </div>
          <div class="check-circle"></div>
        </div>
        
        <div class="sch-item" onclick="toggleScheduleSelect(this, '0000000000000000002', '여수 밤바다 낭만 투어')">
          <div>
            <h4 style="margin: 0 0 6px; font-size: 16px; font-weight: 800; color: var(--text-black);">여수 밤바다 낭만 투어</h4>
            <p style="margin: 0; font-size: 13px; color: var(--text-gray);">2024.06.01 ~ 2024.06.02</p>
          </div>
          <div class="check-circle"></div>
        </div>
      </div>
      
      <div class="sch-preview-area">
        <h4 style="margin: 0 0 20px; font-size: 15px; font-weight: 800; color: var(--text-black); border-bottom: 2px solid var(--border-color); padding-bottom: 10px;">선택된 일정</h4>
        <div id="schRightPreview" style="display: flex; flex-direction: column; align-items: center; justify-content: center; flex: 1; color: var(--text-gray); font-size: 14px; text-align: center; gap: 12px;">
          <span style="font-size: 40px; opacity: 0.3;">🗺️</span>
          왼쪽 목록에서 공유할<br>일정을 선택해주세요.
        </div>
      </div>
    </div>
    
    <div class="sch-footer">
      <button class="btn-sch-cancel" onclick="closeScheduleModal()">취소</button>
      <button class="btn-sch-confirm" onclick="confirmScheduleSelection()">확인</button>
    </div>
  </div>
</div>
	  
	  <jsp:include page="/WEB-INF/views/layout/footer.jsp"/>
	  <jsp:include page="/WEB-INF/views/member/loginModal.jsp" />
	  <jsp:include page="/WEB-INF/views/community/fragment/mate/mate_write_modal.jsp" />
	
	  <script>
		
	    function startRoulette() {
	      const dests = ['여수 밤바다 낭만 투어', '경주 황리단길 카페 투어', '강원도 양양 서핑 트립', '제주도 한라산 등반'];
	      const random = dests[Math.floor(Math.random() * dests.length)];
	      alert("🎲 추천 결과: [" + random + "]\n관련 피드와 숙소를 검색해볼까요?");
	    }
	
	
	    let isFetching = false;     
	    let scrollObserver = null; 
	    let scrollCount = 0;
	
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
	      if (!IS_LOGGED_IN) {
	    	  scrollCount++;
	    	  
	    	  if (scrollCount > 2) {
	    	  showLoginModal(); 
	    	  return; 
	    	  }
	    		  
	    	}
	
	      isFetching = true;
	      trigger.innerHTML = '로딩 중... ⏳';
	      setTimeout(() => {
	          
	          isFetching = false;
	          trigger.innerHTML = '모든 게시글을 불러왔습니다 ✨';
	          trigger.style.opacity = '0.5'; 
	          if(scrollObserver) scrollObserver.disconnect();
	          
	      }, 800);
	  }
	
    function loadTabContent(tabType, event) {
        if(event) event.preventDefault();
        
        if (!IS_LOGGED_IN && (tabType === 'mate' || tabType === 'freeboard')) {
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
            });
            
            if (tabType === 'mate') {
                if(typeof populateRegionSelects === 'function') {
                    populateRegionSelects().then(() => searchMates());
                } else {
                    searchMates();
                }
            } else if ( tabType === 'feed' || tabType === '') {
            	if (typeof renderHashtags === 'function') {
            		setTimeout(() => renderHashtags(), 50);
            	}
            }
            
        })
        .catch(error => {
            console.error('Error:', error);
            contentArea.innerHTML = '<div style="text-align:center; padding: 50px; color:red;">데이터를 불러오는데 실패했습니다. 😢</div>';
        });
    }
	    
	    window.addEventListener('DOMContentLoaded', () => { 
	    	setupInfiniteScroll(); 
			const now = new Date();
			loadMiniFestivalSidebar(now.getFullYear(), now.getMonth() + 1);
			
	    	const urlParams = new URLSearchParams(window.location.search);
	    	const tabParams = urlParams.get('tab');
	    	
	    	if (tabParams && tabParams !== 'feed') {
	    		loadTabContent(tabParams, null);
	    	}
	    
	    });
		
		async function loadMiniFestivalSidebar(year, month) {
		    const miniList = document.getElementById('mini-festival-list');
		    
		    if (!miniList) {
		        console.warn("알림: 화면에 mini-festival-list 영역이 없어서 축제 정보를 그리지 않습니다.");
		        return; 
		    }
	
		    const data = await fetchFestivals(year, month);
	
		    if (!data || data.length === 0) {
		        miniList.innerHTML = `<p style="text-align:center; font-size:12px; color:var(--text-gray);">진행 중인 축제가 없습니다.</p>`;
		        return;
		    }
	
		    const limitData = data.slice(0, 3);
		    
		    let html = '';
		    limitData.forEach(fes => {
		        const startDate = new Date(fes.start);
		        const monthNames = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"];
		        const monthName = monthNames[startDate.getMonth()];
		        const day = startDate.getDate();
	
		        html += `
		            <div class="festival-item" style="display: flex; gap: 12px; align-items: center;">
		              <div class="fes-date" style="background: var(--sky-blue); color: white; padding: 6px 10px; border-radius: 8px; text-align: center; min-width: 45px;">
		                <span style="font-size: 10px; display: block; line-height: 1;">\${monthName}</span>
		                <strong style="font-size: 16px; display: block; line-height: 1.2; margin-top: 2px;">\${day}</strong>
		              </div>
		              <div class="fes-info">
		                <h4 style="margin: 0 0 4px 0; font-size: 14px; color: var(--text-dark);">\${fes.title}</h4>
		                <p style="margin: 0; font-size: 12px; color: var(--text-gray);">\${fes.address || '장소 정보 없음'}</p>
		              </div>
		            </div>
		        `;
		    });
		    miniList.innerHTML = html;
		}
	    
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
		            titleHtml = `<h3 style="margin-top:0; color:var(--text-dark);">\${targetDate} 진행 축제 🎈</h3>`;
		        }
		        
		        sidebar.innerHTML = titleHtml;
	
		        if (!festivals || festivals.length === 0) {
		            sidebar.innerHTML += `<p style="font-size: 13px; color: var(--text-gray); padding: 20px 0; text-align: center;">해당 기간에 진행되는 축제가 없습니다. 🥲</p>`;
		            return;
		        }
	
		        festivals.forEach(fes => {
		            const address = fes.address ? fes.address : '장소 미정';
		            const imgSrc = fes.image ? fes.image : '${pageContext.request.contextPath}/dist/images/default_festival.jpg';
		            const cardHtml = `
		                <div class="festival-card" 
		                     onclick="window.open('https://search.naver.com/search.naver?query=\${encodeURIComponent(fes.title)}', '_blank')"
		                     onmouseenter="highlightFestivalDates('\${fes.start}', '\${fes.end}')"
		                     onmouseleave="clearFestivalHighlights()">
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
		                    
		                    eventDisplay: 'list-item', 
		                    
		                    dayMaxEvents: 2, 
		                    moreLinkText: function(n) {
		                        return "+" + n + "개";
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
		                        const clickDate = info.event.startStr;
		                        const filtered = currentFestivals.filter(fes => {
		                            return clickDate >= fes.start && clickDate <= fes.end;
		                        });
		                        updateFestivalSidebar(filtered, clickDate);
		                        highlightCalendarDay(clickDate);
		                    },
		                    
		                    dateClick: function(info) {
		                        const clickDate = info.dateStr;
		                        
		                        const filtered = currentFestivals.filter(fes => {
		                            return clickDate >= fes.start && clickDate <= fes.end;
		                        });
		                        
		                        updateFestivalSidebar(filtered, clickDate);
		                        highlightCalendarDay(clickDate); 
		                    }
		                });
		                festivalCalendar.render();
		            } 
		        }, 300);
		    }
	
		    function highlightCalendarDay(dateStr) {
		        document.querySelectorAll('.fc-day-highlight').forEach(el => {
		            el.classList.remove('fc-day-highlight');
		        });
		        const targetCell = document.querySelector(`.fc-day[data-date="\${dateStr}"]`);
		        if (targetCell) {
		            targetCell.classList.add('fc-day-highlight');
		        }
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
	            modal.style.left = '50%';
	            modal.style.top = '50%';
	            modal.style.transform = 'translate(-50%, -50%) translateY(15px)'; 
	        }, 300); 
	    }
		
		function highlightFestivalDates(startStr, endStr) {
		        clearFestivalHighlights(); 
		        if (!endStr) endStr = startStr; 
	
		        let startDate = new Date(startStr + "T00:00:00");
		        let endDate = new Date(endStr + "T00:00:00");
	
		        for (let d = new Date(startDate); d <= endDate; d.setDate(d.getDate() + 1)) {
		            let y = d.getFullYear();
		            let m = String(d.getMonth() + 1).padStart(2, '0');
		            let day = String(d.getDate()).padStart(2, '0');
		            let dateString = y + '-' + m + '-' + day;
	
		            let cell = document.querySelector(`.fc-day[data-date="\${dateString}"]`);
		            if (cell) {
		                cell.classList.add('fc-festival-hover');
		            }
		        }
		    }
	
	    function clearFestivalHighlights() {
	        document.querySelectorAll('.fc-festival-hover').forEach(el => {
	            el.classList.remove('fc-festival-hover');
	        });
	    }
		    
		async function loadLiveChatSidebar() {
		    const chatListEl = document.getElementById('live-chat-list');
		    if (!chatListEl) return; 

		    try {
		        const url = '${pageContext.request.contextPath}/api/chat/rooms/region'; 
		        const response = await fetch(url);
		        if (!response.ok) throw new Error('채팅방 로딩 실패'); 
		        
		        let rooms = await response.json(); 
		        
		        if (!rooms || rooms.length === 0) { 
		            chatListEl.innerHTML = `<p style="text-align:center; font-size:12px; color:var(--text-gray); padding: 10px 0;">현재 활성화된 방이 없습니다.</p>`; // [cite: 283]
		            return; 
		        }

		        rooms.sort((a, b) => (b.userCount || 0) - (a.userCount || 0));
		        const topRooms = rooms.slice(0, 3); 

		        const icons = ['\uD83C\uDF34', '\uD83C\uDF0A', '\uD83C\uDFD4\uFE0F', '\uD83C\uDF03', '\uD83C\uDF8E']; // [cite: 284]
		        let html = '';

		        topRooms.forEach((room, index) => {
		            const icon = icons[index % icons.length]; 
		            html += `
		                <div class="chat-room">
		                  <div class="chat-icon">\${icon}</div>
		                  <div class="chat-info">
		                    <h4>\${room.chatRoomName}</h4>
		                    <p>현재 \${room.userCount || 0}명 접속 중</p>
		                  </div>
		                </div>
		            `;
		        });
		        chatListEl.innerHTML = html; 

		    } catch (error) {
		        console.error("인기 채팅방을 불러오지 못했습니다:", error); 
		        chatListEl.innerHTML = `<p style="text-align:center; font-size:12px; color:#FF6B6B; padding: 10px 0;">목록 로딩 실패 😢</p>`; // [cite: 289]
		    }
		}
	
	    window.addEventListener('DOMContentLoaded', () => { 
	        setupInfiniteScroll(); 
	        const now = new Date();
	        loadMiniFestivalSidebar(now.getFullYear(), now.getMonth() + 1);
	        
	        loadLiveChatSidebar();
	
	        const urlParams = new URLSearchParams(window.location.search);
	        const tabParams = urlParams.get('tab');
	        if (tabParams && tabParams !== 'feed') {
	            loadTabContent(tabParams, null);
	        }
	    });
		
		function loadBoardDetail(boardId, updateView = true) {
		    const contentArea = document.getElementById('dynamic-content');
		    contentArea.innerHTML = '<div style="...">데이터 로딩 중...</div>';
	
		    const url = `${pageContext.request.contextPath}/community/freeboard/detail/` + boardId + "?updateView=" + updateView;
	
		    fetch(url, { headers: { 'X-Requested-With': 'Fetch' } })
		    .then(res => res.text())
		    .then(html => {
		        contentArea.innerHTML = html;
		        if(updateView) window.scrollTo({ top: 0, behavior: 'smooth' });
		    });
		}
		
		function submitComment(boardId) {
		        if (!IS_LOGGED_IN) {
		            showLoginModal();
		            return;
		        }
	
		        const contentInput = document.getElementById('commentContent');
		        const content = contentInput.value.trim();
	
		        if (content === '') {
		            alert('댓글 내용을 입력해주세요!');
		            contentInput.focus();
		            return;
		        }
	
		        const url = `${pageContext.request.contextPath}/community/freeboard/comment/add`;
		        const data = {
		            boardId: boardId,
		            content: content
		        };
	
		        fetch(url, {
		            method: 'POST',
		            headers: {
		                'Content-Type': 'application/json',
		                'X-Requested-With': 'Fetch' 
		            },
		            body: JSON.stringify(data)
		        })
		        .then(response => {
		            if (!response.ok) throw new Error('서버 통신 에러');
		            return response.json();
		        })
		        .then(result => {
		            if (result.status === 'success') {
						document.getElementById('commentContent').value = '';
						loadBoardDetail(boardId, false); 
		            } else {
		                alert(result.message);
		            }
		        })
		        .catch(error => {
		            console.error('Error:', error);
		            alert('댓글 등록에 실패했습니다.');
		        });
		    }
			
			function toggleLike(boardId) {
			    const url = `${pageContext.request.contextPath}/community/freeboard/like/` + boardId;
			    
			    fetch(url, { 
			        method: 'POST', 
			        headers: { 'X-Requested-With': 'Fetch' } 
			    })
			    .then(res => {
			        if (res.status === 401) { 
			            showLoginModal();
			            return null;
			        }
			        if (!res.ok) throw new Error('서버 에러');
			        return res.json();
			    })
			    .then(data => {
			        if (data) {
			            const heart = document.getElementById('heartIcon');
			            const count = document.getElementById('detailLikeCount');
			            
			            heart.innerText = (data.status === 'liked') ? '♥' : '♡';
			            count.innerText = data.count;
			        }
			    })
			    .catch(err => console.error("좋아요 처리 중 오류:", err));
			}
			
	  </script>
	  
	  <script>
		let uploadedFiles = []; 
	
		  function openLoungeModal() {
		    document.getElementById('loungeWriteModal').classList.add('active');
		  }
		  
		  function closeLoungeModal() {
		    document.getElementById('loungeWriteModal').classList.remove('active');
		  }
	
		  function toggleSchedule() {
		    const scheduleArea = document.getElementById('scheduleSelectArea');
		    scheduleArea.style.display = scheduleArea.style.display === 'none' ? 'block' : 'none';
		  }
	
		  function handleFiles(files) {
		    const previewArea = document.getElementById('photoPreviewArea');
		    if (uploadedFiles.length + files.length > 4) {
		      alert("사진은 최대 4장까지만 첨부할 수 있습니다.");
		      return;
		    }
		    Array.from(files).forEach(file => {
		      uploadedFiles.push(file);
		      const fileUrl = URL.createObjectURL(file);
		      const thumbWrap = document.createElement('div');
		      thumbWrap.className = 'thumb-wrap';
		      thumbWrap.innerHTML = `
		        <img src="${fileUrl}" alt="미리보기">
		        <button type="button" class="thumb-remove" onclick="removeFile(this, '${file.name}')">x</button>
		      `;
		      previewArea.appendChild(thumbWrap);
		    });
		  }
	
		  function removeFile(btn, fileName) {
		    uploadedFiles = uploadedFiles.filter(f => f.name !== fileName);
		    btn.parentElement.remove();
		  }
	
		  function getLocation() {
		    const locArea = document.getElementById('locationPreviewArea');
		    const locText = document.getElementById('locationText');
		    
		    locArea.style.display = 'inline-flex';
		    locText.innerText = "위치 정보를 불러오는 중..."; 
	
		    if (navigator.geolocation) {
		      navigator.geolocation.getCurrentPosition(
		        (position) => {
		          const lat = position.coords.latitude.toFixed(4);
		          const lon = position.coords.longitude.toFixed(4);
		          locText.innerText = `현재 위치 (위도: ${lat}, 경도: ${lon})`;
		        },
		        (error) => {
		          locText.innerText = "위치 정보 권한을 확인해주세요.";
		        }
		      );
		    } else {
		      locText.innerText = "위치 정보를 지원하지 않는 브라우저입니다.";
		    }
		  }
	
		  function removeLocation() {
		    document.getElementById('locationPreviewArea').style.display = 'none';
		    document.getElementById('locationText').innerText = '';
		  }
	
		  function submitLoungePost() {
		    const category = document.getElementById('loungeCategory').value;
		    const title = document.getElementById('loungeTitle').value;
		    const content = document.getElementById('loungeTextarea').value;
		    const tripId = document.getElementById('myTripSelect').value;
		    
		    if(!category) {
		      alert("카테고리를 선택해주세요!");
		      return;
		    }
		    if(!title.trim()) {
		      alert("제목을 입력해주세요!");
		      return;
		    }
		    if(!content.trim()) {
		      alert("내용을 입력해주세요!");
		      return;
		    }
	
		    console.log("카테고리:", category);
		    console.log("제목:", title);
		    console.log("내용:", content);
		    console.log("일정 ID:", tripId);
		    console.log("첨부 파일 수:", uploadedFiles.length);
	
		    alert("비동기 작성이 완료되었습니다! (콘솔 확인)");
		    closeLoungeModal();
		  }
		  
		  window.startPrivateChat = function(targetMemberId, targetNickname) {
		      if (typeof IS_LOGGED_IN !== 'undefined' && !IS_LOGGED_IN) {
		          showLoginModal();
		          return;
		      }
		      
		      const myId = '${sessionScope.loginUser != null ? sessionScope.loginUser.memberId : ""}';
		      if(myId == targetMemberId) {
		          alert("나 자신과는 1:1 대화를 할 수 없습니다!");
		          return;
		      }

		      fetch('${pageContext.request.contextPath}/api/chat/private?targetId=' + targetMemberId, {
		          method: 'POST',
		          headers: { 'X-Requested-With': 'Fetch' }
		      })
		      .then(res => res.json())
		      .then(data => {
		          if(data.roomId) {
		              window.openGlobalChat();
		              
		              document.getElementById('chatEmptyState').style.display = 'none';
		              document.getElementById('chatRoomView').style.display = 'flex';
		              
		              document.querySelector('.chat-title-info h2').innerText = '💬 @' + targetNickname + ' 님과의 대화';
		              const countSpan = document.querySelector('.chat-title-info span');
		              if(countSpan) countSpan.style.display = 'none'; // 1:1방은 접속자 수 숨김
		              
		              if(typeof connectChatRoom === 'function') {
		                  connectChatRoom(data.roomId);
		              }
		          }
		      })
		      .catch(err => console.error("채팅방 연결 오류:", err));
		  }
		  
		  let inlineFiles = []; 
		  let tempSelectedTripId = null;
		  let tempSelectedTripName = null;
		  let confirmedTripId = null;
		  let tempSelectedTripMeta = {}; 

		  function handleInlineFiles(files) {
		      const previewArea = document.getElementById('inlinePhotoPreview');
		      if (inlineFiles.length + files.length > 4) {
		          alert("사진은 최대 4장까지만 첨부할 수 있습니다.");
		          return;
		      }
		      
		      Array.from(files).forEach(file => {
		          inlineFiles.push(file);
		          const fileUrl = URL.createObjectURL(file);
		          const thumbWrap = document.createElement('div');
		          thumbWrap.style = "position: relative; width: 80px; height: 80px; border-radius: 12px; overflow: hidden; border: 1px solid var(--border-color);";
		          thumbWrap.innerHTML = `
		              <img src="\${fileUrl}" style="width: 100%; height: 100%; object-fit: cover;">
		              <button type="button" onclick="removeInlineFile(this, '\${file.name}')" 
		                      style="position: absolute; top: 4px; right: 4px; background: rgba(0,0,0,0.6); color: white; border: none; border-radius: 50%; width: 22px; height: 22px; font-size: 12px; cursor: pointer;">✕</button>
		          `;
		          previewArea.appendChild(thumbWrap);
		      });
		  }

		  function removeInlineFile(btn, fileName) {
		      inlineFiles = inlineFiles.filter(f => f.name !== fileName);
		      btn.parentElement.remove();
		  }

		  function openScheduleModal() {
		      document.getElementById('scheduleModal').classList.add('active');
		      document.body.style.overflow = 'hidden';
		  }

		  function closeScheduleModal() {
		      document.getElementById('scheduleModal').classList.remove('active');
		      document.body.style.overflow = 'auto';
		  }

		  function toggleScheduleSelect(element, tripId, tripName, placeCount = 0, totalBudget = 0, memberCount = 1) {
		      document.querySelectorAll('.sch-item').forEach(el => el.classList.remove('selected'));
		      
		      element.classList.add('selected');
		      tempSelectedTripId = tripId;
		      tempSelectedTripName = tripName;
		      tempSelectedTripMeta = { placeCount, totalBudget, memberCount };
		      
		      const perPerson = Math.floor(totalBudget / memberCount).toLocaleString();
		      
		      const rightPreview = document.getElementById('schRightPreview');
		      rightPreview.innerHTML = 
		          '<div style="background: var(--grad-main); width: 60px; height: 60px; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-size: 24px; color: white; margin-bottom: 12px;">✈️</div>' +
		          '<h5 style="margin: 0; font-size: 16px; color: var(--text-black);">' + tripName + '</h5>' +
		          '<p style="margin: 8px 0 0; font-size: 13px; color: var(--sky-blue); font-weight: 700;">이 일정을 공유합니다</p>' +
		          '<div style="margin-top: 16px; padding: 12px; background: #f8fafc; border-radius: 8px; font-size: 12px; color: var(--text-dark); width: 100%; box-sizing: border-box; text-align: left;">' +
		          '    <li style="margin-bottom: 4px;">📍 장소: ' + placeCount + '곳 방문</li>' +
		          '    <li style="margin-bottom: 4px;">👥 인원: ' + memberCount + '명</li>' +
		          '    <li style="color:var(--sky-blue); font-weight: bold;">└ 1인당 약 ' + perPerson + '원</li>' +
		          '</div>';
		  }

		  function confirmScheduleSelection() {
		      if (!tempSelectedTripId) {
		          alert("선택된 일정이 없습니다.");
		          return;
		      }
		      
		      confirmedTripId = tempSelectedTripId;
		      
		      const previewDiv = document.getElementById('inlineSchedulePreview');
		      const nameSpan = document.getElementById('displayScheduleName');
		      const metaSpan = document.getElementById('displayScheduleMeta');
		      
		      const perPerson = Math.floor(tempSelectedTripMeta.totalBudget / tempSelectedTripMeta.memberCount).toLocaleString();
		      
		      nameSpan.innerText = tempSelectedTripName;
		      if(metaSpan) {
		          metaSpan.innerText = '장소 ' + tempSelectedTripMeta.placeCount + '곳 · 총 ' + tempSelectedTripMeta.totalBudget.toLocaleString() + '원 (' + tempSelectedTripMeta.memberCount + '인 기준, 1인 약 ' + perPerson + '원)';
		      }
		      
		      previewDiv.style.display = 'flex';
		      closeScheduleModal();
		  }

		  function removeInlineSchedule() {
		      confirmedTripId = null;
		      document.getElementById('inlineSchedulePreview').style.display = 'none';
		  }

		  function submitInlinePost() {
		      const content = document.getElementById('inlineTextarea').value;
		      const tagsInput = document.getElementById('inlineTags');
		      const tags = tagsInput ? tagsInput.value : '';
		      
		      if(!content.trim() && inlineFiles.length === 0 && !confirmedTripId) {
		          alert("내용, 사진, 또는 일정 중 하나 이상을 입력해주세요!");
		          return;
		      }
		      
		      const formData = new FormData();
		      formData.append('content', content);
		      formData.append('tags', tags);
		      
		      if (confirmedTripId) {
		          formData.append('tripId', confirmedTripId);
		      }
		      
		      inlineFiles.forEach(file => {
		          formData.append('files', file);
		      });

		      fetch('${pageContext.request.contextPath}/community/api/feed/write', {
		          method: 'POST',
		          body: formData 
		      })
		      .then(response => {
		          if (!response.ok) throw new Error('서버 통신 에러');
		          return response.json();
		      })
		      .then(data => {
		          if(data.status === 'success') {
		              alert("✨ 피드가 성공적으로 등록되었습니다!");
		              location.reload(); 
		          } else {
		              alert("등록 실패: " + data.message);
		          }
		      })
		      .catch(error => {
		          console.error('Error:', error);
		          alert("게시글 작성 중 오류가 발생했습니다. 🥲");
		      });
		  }
		  
		  function toggleKebab(btn, event) {
			    event.stopPropagation();
			    const dropdown = btn.nextElementSibling;
			    const isShowing = dropdown.classList.contains('show');
			    
			    document.querySelectorAll('.dropdown-content').forEach(d => d.classList.remove('show'));
			    if (!isShowing) dropdown.classList.add('show');
			}

		  function toggleFollow(btn, targetMemberId) {
			    if (typeof IS_LOGGED_IN !== 'undefined' && !IS_LOGGED_IN) {
			        showLoginModal();
			        return;
			    }

			    fetch(`/community/api/follow/\${targetMemberId}`, { 
			        method: 'POST',
			        headers: { 'X-Requested-With': 'Fetch' }
			    })
			    .then(res => res.json())
			    .then(data => {
			        if(data.status === 'followed') {
			            btn.classList.add('following');
			            btn.innerText = '팔로잉';
			        } else {
			            btn.classList.remove('following');
			            btn.innerText = '팔로우';
			        }
			    })
			    .catch(err => console.error("팔로우 오류:", err));
			}

			function scrapTrip(tripId) {
			    checkAuthAndRun(() => {
			        if(confirm('이 일정을 내 보관함으로 담아오시겠습니까?')) {
			            alert('✨ 일정이 내 보관함에 저장되었습니다!');
			        }
			    });
			}

			document.addEventListener('click', () => {
			    document.querySelectorAll('.dropdown-content').forEach(d => d.classList.remove('show'));
			});
			
			  function renderHashtags() {
			    document.querySelectorAll('.feed-text:not(.tagged)').forEach(p => {
			      p.classList.add('tagged'); 
			      
			      let originalText = p.innerHTML;
			      
			      const hashtagRegex = /(#[^\s#<]+)/g;
			      const tags = originalText.match(hashtagRegex);
			      
			      if (tags && tags.length > 0) {
			        let cleanText = originalText.replace(hashtagRegex, '').trim();
			        p.innerHTML = cleanText; 
			        
			        const tagContainer = document.createElement('div');
			        tagContainer.className = 'feed-tag-container';
			        
			        const iconDiv = document.createElement('div');
			        iconDiv.className = 'feed-tag-icon';
			        iconDiv.innerHTML = '🏷️';
			        
			        const tagList = document.createElement('div');
			        tagList.className = 'feed-tag-list';
			        
			        tags.forEach(tag => {
			          const badge = document.createElement('span');
			          badge.className = 'feed-tag-badge';
			          badge.innerText = tag;
			          tagList.appendChild(badge);
			        });
			        
			        tagContainer.appendChild(iconDiv);
			        tagContainer.appendChild(tagList);
			        
			        p.parentNode.insertBefore(tagContainer, p.nextSibling);
			      }
			    });
			  }

			  document.addEventListener("DOMContentLoaded", renderHashtags);
		  
	  </script>
	  
	</body>
	</html>