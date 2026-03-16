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

    .feed-main { display: flex; flex-direction: column; gap: 24px; margin: 0px auto; width: 100%; min-height: 50vh; min-width: 0;} 

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
 
.balance-card-container { display: grid; grid-template-columns: 1fr 1fr; gap: 12px; margin-top: 24px; }
.balance-card { background: #F8FAFC; border: 2px solid var(--border-color); border-radius: 16px; padding: 24px 10px; cursor: pointer; transition: 0.3s var(--bounce); display: flex; flex-direction: column; align-items: center; justify-content: center; }
.balance-card:hover { border-color: var(--sky-blue); background: white; transform: translateY(-5px); box-shadow: 0 12px 24px rgba(137, 207, 240, 0.2); }
.balance-emoji { font-size: 45px; margin-bottom: 12px; display: block; transition: 0.3s; }
.balance-card:hover .balance-emoji { transform: scale(1.15); }
.balance-text { font-size: 14px; font-weight: 800; color: var(--text-dark); word-break: keep-all; line-height: 1.4; }

.ai-loading-spinner { font-size: 60px; display: inline-block; margin-bottom: 20px; animation: fly 2s ease-in-out infinite; }
@keyframes fly { 0% { transform: translateY(0) rotate(0deg) scale(1); } 50% { transform: translateY(-15px) rotate(10deg) scale(1.1); } 100% { transform: translateY(0) rotate(0deg) scale(1); } }

.ai-result-box { background: linear-gradient(145deg, #F0F8FF, #F8FAFC); border-radius: 16px; padding: 24px; font-size: 15px; line-height: 1.8; color: var(--text-black); text-align: left; border: 1px solid rgba(137,207,240,0.4); min-height: 150px; font-weight: 500; }

.btn-ai-retry { background: white; color: var(--text-dark); border: 1px solid var(--border-color); border-radius: 20px; padding: 12px; font-weight: 800; cursor: pointer; transition: 0.2s; font-size: 15px; }
.btn-ai-retry:hover { background: #f1f5f9; }

.btn-ai-go { background: var(--grad-main); color: white; border: none; border-radius: 20px; padding: 12px; font-weight: 800; font-size: 15px; cursor: pointer; box-shadow: 0 4px 12px rgba(137, 207, 240, 0.3); transition: 0.2s; }
.btn-ai-go:hover { transform: translateY(-2px); box-shadow: 0 6px 16px rgba(137, 207, 240, 0.5); }

/* 👥 인스타 스타일 팔로우 목록 모달 탭 & 리스트 */
.follow-tabs { display: flex; width: 100%; border-bottom: 1px solid var(--border-color); margin-top: 10px; }
.follow-tab { flex: 1; text-align: center; padding: 12px 0; font-size: 15px; font-weight: 800; color: var(--text-gray); cursor: pointer; transition: 0.2s; border-bottom: 2px solid transparent; }
.follow-tab.active { color: var(--text-black); border-bottom: 2px solid var(--text-black); }
.follow-tab:hover:not(.active) { color: var(--sky-blue); }

.follow-item { display: flex; align-items: center; justify-content: space-between; padding: 12px 0; }
.follow-item-left { display: flex; align-items: center; gap: 12px; cursor: pointer; text-decoration: none; color: inherit; }
.follow-avatar { width: 46px; height: 46px; border-radius: 50%; object-fit: cover; border: 1px solid var(--border-color); }
.follow-info { display: flex; flex-direction: column; justify-content: center; }
.follow-name { font-size: 14px; font-weight: 900; color: var(--text-black); transition: 0.2s; line-height: 1.2; }
.follow-desc { font-size: 13px; color: var(--text-gray); font-weight: 500; margin-top: 2px; line-height: 1.2; }
.follow-item-left:hover .follow-name { color: var(--sky-blue); }

.btn-mini-follow { padding: 7px 18px; border-radius: 8px; font-size: 13px; font-weight: 800; cursor: pointer; transition: 0.2s; border: none; }
.btn-mini-follow.following { background: #f1f5f9; color: var(--text-dark); border: 1px solid var(--border-color); }
.btn-mini-follow.following:hover { background: #ffe4e4; color: #ff4d4d; border-color: #ff4d4d; } 
.btn-mini-follow:not(.following) { background: var(--sky-blue); color: white; box-shadow: 0 4px 10px rgba(137, 207, 240, 0.2); }
.btn-mini-follow:not(.following):hover { background: #72bde0; transform: translateY(-2px); }

.lounge-modal-content.glass-card {
  background: rgba(255, 255, 255, 0.90) !important; 
  backdrop-filter: blur(16px) !important; 
  -webkit-backdrop-filter: blur(16px) !important;
  border: 1px solid rgba(255, 255, 255, 0.2) !important; 
  box-shadow: 0 16px 40px rgba(0, 0, 0, 0.1);
}
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
		      <a href="javascript:void(0);" onclick="loadUserProfile('${sessionScope.loginUser.memberId}')" style="text-decoration: none; color: inherit;">
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
				<div class="stat-box" style="cursor: pointer;" onclick="loadUserProfile('${sessionScope.loginUser.memberId}')">
					게시물 <strong>${postCount != null ? postCount : 0}</strong>
				</div>
				<div class="stat-box" style="cursor: pointer;" onclick="openFollowModal('follower', '${sessionScope.loginUser.memberId}')">
					팔로워 <strong>${followerCount != null ? followerCount : 0}</strong>
				</div>
				<div class="stat-box" style="cursor: pointer;" onclick="openFollowModal('following', '${sessionScope.loginUser.memberId}')">
					팔로잉 <strong>${followingCount != null ? followingCount : 0}</strong>
				</div>
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
	  <h3>떠나고 싶은데 고민이라면?</h3>
	  <p>내 취향을 고르면 AI가 알아서<br>핫한 여행지 피드를 찾아줍니다!</p>
	  <button class="btn-game" onclick="startRoulette()">🧭 취향 저격 테스트 시작</button>
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
            <option value="etc">💬 기타</option>
          </select>	

          <input type="text" id="loungeTitle" class="lounge-input-style" placeholder="제목을 입력하세요">
          
          <textarea id="loungeTextarea" class="lounge-input-style" placeholder="여행자님, 지금 어떤 생각 중이신가요?"></textarea>
          
          <div id="photoPreviewArea" class="preview-area"></div>
          
          <div id="scheduleSelectArea" class="schedule-area" style="display: none;">
            <select id="myTripSelect" class="lounge-input-style">
              <option value="">📅 공유할 내 일정을 선택하세요</option>
            </select>
          </div>
          
        </div> <div class="lounge-toolbar">
          <div class="toolbar-icons">
            <button type="button" class="icon-btn" onclick="toggleSchedule()" title="일정 공유">📅</button>
            <button type="button" class="icon-btn" onclick="document.getElementById('loungeFileInput').click()" title="사진 첨부">📷</button>
            <input type="file" id="loungeFileInput" accept="image/*" style="display: none;" onchange="handleFiles(this.files)">
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

<div id="commonReportModal" class="lounge-modal-overlay">
  <div class="lounge-modal-content glass-card" style="max-width: 400px; text-align: center;">
    <div class="lounge-modal-header" style="justify-content: center; border-bottom: none;">
      <h3 style="color: #ff4d4d;">🚨 신고하기</h3>
    </div>
    
    <p style="font-size: 13px; color: var(--text-gray); margin-bottom: 16px;">
      관리자 확인 후 조치됩니다. 올바른 사유를 선택해 주세요.
    </p>

    <input type="hidden" id="reportTargetType" value="">
    <input type="hidden" id="reportTargetId" value="">

    <select id="reportReasonSelect" class="lounge-input-style" style="margin-bottom: 20px;">
      <option value="">신고 사유를 선택해주세요</option>
      <option value="SPAM">스팸홍보/도배글입니다.</option>
      <option value="ABUSE">욕설/혐오/차별적 표현입니다.</option>
      <option value="ILLEGAL">불법정보를 포함하고 있습니다.</option>
      <option value="PORN">음란/선정적인 내용입니다.</option>
      <option value="OTHER">기타 부적절한 내용입니다.</option>
    </select>

    <div style="display: flex; gap: 10px; justify-content: center;">
      <button onclick="closeReportModal()" style="padding: 10px 20px; border-radius: 20px; border: 1px solid var(--border-color); background: white; font-weight: 700; cursor: pointer;">취소</button>
      <button onclick="submitReport()" style="padding: 10px 20px; border-radius: 20px; border: none; background: #ff4d4d; color: white; font-weight: 800; cursor: pointer; box-shadow: 0 4px 12px rgba(255, 77, 77, 0.3);">신고 접수</button>
    </div>
  </div>
</div>

<div id="feedDetailModalOverlay" class="lounge-modal-overlay">
      <div id="feedDetailModalContent" class="lounge-modal-content glass-card" style="padding: 0; max-width: 650px; overflow: hidden;">
      </div>
  </div>
  
  <div id="aiRouletteModal" class="lounge-modal-overlay">
  <div class="lounge-modal-content glass-card" style="max-width: 550px; text-align: center; padding: 40px 30px;">
    <button class="btn-close-modal" onclick="closeAiModal()" style="position: absolute; right: 20px; top: 20px;">✕</button>
    <h3 style="color: var(--text-black); font-size: 22px; margin: 0 0 10px 0;">🤖 Tripan AI 추천</h3>

    <div id="aiQuestionArea">
        <p id="aiStepIndicator" style="color: var(--sky-blue); font-weight: 900; margin: 0 0 8px; font-size: 14px;">STEP 1 / 3</p>
        <h4 id="aiQuestionText" style="font-size: 22px; font-weight: 900; margin: 0; color: var(--text-black);">지금 당장 떠난다면?</h4>
        <div class="balance-card-container" id="aiChoices"></div>
    </div>

    <div id="aiLoadingArea" style="display: none; padding: 40px 0;">
        <span class="ai-loading-spinner">✈️</span>
        <h4 style="font-size: 20px; font-weight: 900; margin: 0 0 10px; color: var(--text-black);">AI가 완벽한 여행지를 탐색 중입니다...</h4>
        <p style="color: var(--text-gray); font-size: 14px; font-weight: 600; margin:0;">선택하신 취향 빅데이터를 분석하고 있어요 🔍</p>
    </div>

    <div id="aiResultArea" style="display: none; margin-top: 10px;">
        <h4 style="font-size: 18px; font-weight: 900; margin: 0 0 16px; color: var(--text-black);">🎉 맞춤형 추천 결과가 도착했습니다!</h4>
        <div class="ai-result-box" id="aiResultText"></div>
        <div style="display: flex; gap: 10px; margin-top: 20px;">
		    <button class="btn-ai-retry" style="flex:1;" onclick="startRoulette()">다시 하기</button>
		    <button id="btnGoFeed" class="btn-ai-go" style="flex:2;" onclick="goToRecommendedFeed('제주')">추천 피드 보러가기 🚀</button>
		</div>
    </div>
  </div>
</div>

<div id="followModalOverlay" class="lounge-modal-overlay">
  <div class="lounge-modal-content glass-card" style="max-width: 420px; padding: 20px 24px; border-radius: 20px;">
    
    <div style="position: relative; display: flex; justify-content: center; align-items: center; margin-bottom: 5px;">
      <h3 id="followModalTitle" style="margin: 0; font-size: 16px; font-weight: 900; color: var(--text-black);">@유저닉네임</h3>
      <button class="btn-close-modal" onclick="closeFollowModal()" style="position: absolute; right: -10px; top: -10px; width: 32px; height: 32px; font-size: 16px;">✕</button>
    </div>

    <div class="follow-tabs">
      <div id="tabFollower" class="follow-tab" onclick="switchFollowTab('follower')">팔로워</div>
      <div id="tabFollowing" class="follow-tab" onclick="switchFollowTab('following')">팔로잉</div>
    </div>
    
    <div id="followModalList" style="max-height: 400px; min-height: 250px; overflow-y: auto; padding-right: 5px; margin-top: 10px;">
      <div style="text-align: center; color: var(--text-gray); font-size: 13px; padding: 40px 0;">목록을 불러오는 중... ⏳</div>
    </div>
    
  </div>
</div>



	  <jsp:include page="/WEB-INF/views/layout/footer.jsp"/>
	  <jsp:include page="/WEB-INF/views/member/loginModal.jsp" />
	  <jsp:include page="/WEB-INF/views/community/fragment/mate/mate_write_modal.jsp" />
 <script>
   let isFetching = false;     
   let scrollObserver = null; 
   let scrollCount = 0;
   const LOAD_COUNT = 5;

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
        
        const checkLogin = typeof IS_LOGGED_IN !== 'undefined' ? IS_LOGGED_IN : true;

        if (!checkLogin) {
            scrollCount++;
            if (scrollCount > 2) {
                if(typeof showLoginModal === 'function') showLoginModal(); 
                return; 
            }
        }

        isFetching = true;
        trigger.innerHTML = '로딩 중... ⏳';

        setTimeout(() => {
            const allCards = document.querySelectorAll('.feed-card');
            const hiddenCards = Array.from(allCards).filter(card => card.style.display === 'none' || card.style.display === 'none;');
            
            if (hiddenCards.length > 0) {
                for (let i = 0; i < LOAD_COUNT && i < hiddenCards.length; i++) {
                    hiddenCards[i].style.display = 'block';
                }
                
                isFetching = false;
                trigger.innerHTML = '아래로 스크롤하여 더 보기...';

                if (hiddenCards.length <= LOAD_COUNT && checkLogin) {
                    trigger.innerHTML = '모든 게시글을 불러왔습니다 ✨';
                    trigger.style.opacity = '0.5'; 
                    if(scrollObserver) scrollObserver.disconnect();
                }
                
            } else {
                if (!checkLogin) {
                    const spacer = document.createElement('div');
                    spacer.style.height = '400px'; 
                    trigger.parentNode.insertBefore(spacer, trigger);
                    
                    isFetching = false;
                    trigger.innerHTML = '아래로 스크롤하여 더 보기...';
                } else {
                    isFetching = false;
                    trigger.innerHTML = '모든 게시글을 불러왔습니다 ✨';
                    trigger.style.opacity = '0.5'; 
                    if(scrollObserver) scrollObserver.disconnect();
                }
            }
            
        }, 800);
    }

function initCommunity() {
       if (typeof setupInfiniteScroll === 'function') setupInfiniteScroll(); 
       
       const now = new Date();
       if (typeof loadMiniFestivalSidebar === 'function') {
           loadMiniFestivalSidebar(now.getFullYear(), now.getMonth() + 1);
       }
       if (typeof loadLiveChatSidebar === 'function') {
           loadLiveChatSidebar();
       }
       
       if (typeof renderHashtags === 'function') {
           setTimeout(() => renderHashtags(), 50);
       }

       const urlParams = new URLSearchParams(window.location.search);
       const tabParams = urlParams.get('tab');
       const memberIdParam = urlParams.get('memberId');
       
       if (tabParams === 'profile' && memberIdParam) {
           if (typeof loadUserProfile === 'function') loadUserProfile(memberIdParam);
       } else if (tabParams && tabParams !== 'feed') {
           if (typeof loadTabContent === 'function') loadTabContent(tabParams, null);
       }
   }

   if (document.readyState === 'loading') {
       document.addEventListener('DOMContentLoaded', initCommunity);
   } else {
       initCommunity();
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
    const memberIdParam = urlParams.get('memberId'); 

    loadUserProfile(memberIdParam);
});

function loadBoardDetail(boardId, updateView = true) {
    const contentArea = document.getElementById('dynamic-content');
    contentArea.innerHTML = '<div style="text-align:center; padding: 100px; color:var(--sky-blue); font-weight:800;">데이터 로딩 중... ⏳</div>';

    const url = `${pageContext.request.contextPath}/community/freeboard/detail/` + boardId + "?updateView=" + updateView;

    fetch(url, { headers: { 'X-Requested-With': 'Fetch' } })
    .then(res => res.text())
    .then(html => {
        contentArea.innerHTML = html;
        if(updateView) window.scrollTo({ top: 0, behavior: 'smooth' });
    });
}

// 동행글 상세 조회 화면 열기
function loadMateDetail(mateId, updateView = true) {
    const contentArea = document.getElementById('dynamic-content');
    
    contentArea.innerHTML = '<div style="text-align:center; padding: 100px; color:var(--sky-blue); font-weight:800;">여행 동행 정보를 불러오는 중... ✈️</div>';

    const url = `${pageContext.request.contextPath}/community/mate/detail/` + mateId + "?updateView=" + updateView;

    fetch(url, { headers: { 'X-Requested-With': 'Fetch' } })
    .then(res => {
        if(!res.ok) throw new Error("데이터를 불러오지 못했습니다.");
        return res.text();
    })
    .then(html => {
        contentArea.innerHTML = html; 
        
        if(updateView) {
            window.scrollTo({ top: 0, behavior: 'smooth' });
        }
        
        if(typeof window.loadMateComments === 'function') {
            window.loadMateComments(mateId, false);
        }
    })
    .catch(err => {
        console.error('Error:', err);
        contentArea.innerHTML = '<div style="text-align:center; padding: 50px; color:red;">동행글을 불러오는데 실패했습니다. 😢</div>';
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

async function openLoungeModal() {
      document.getElementById('loungeWriteModal').classList.add('active');
      
      const tripSelect = document.getElementById('myTripSelect');
      tripSelect.innerHTML = '<option value="">⏳ 일정을 불러오는 중...</option>'; 

      try {
          const response = await fetch(`${pageContext.request.contextPath}/trip/api/my-trips`, {
              headers: { 'X-Requested-With': 'Fetch' }
          });
          
          if (!response.ok) throw new Error('데이터 로드 실패');
          
          const trips = await response.json();
          
          let optionsHtml = '<option value="">📅 공유할 내 일정을 선택하세요</option>';
          
          if (trips && trips.length > 0) {
              trips.forEach(trip => {
                  optionsHtml += `<option value="\${trip.tripId}">\${trip.tripName}</option>`;
              });
          } else {
              optionsHtml = '<option value="">📅 공유할 일정이 없습니다</option>';
          }
          
          tripSelect.innerHTML = optionsHtml;
          
      } catch (error) {
          console.error("일정 목록 로딩 실패:", error);
          tripSelect.innerHTML = '<option value="">❌ 일정 불러오기 실패</option>';
      }
  }
  
  //  모달 닫기 
  function closeLoungeModal() {
      document.getElementById('loungeWriteModal').classList.remove('active');
      
      document.getElementById('loungeCategory').style.display = 'block'; 
      document.getElementById('loungeTitle').style.display = 'block';
      
      document.getElementById('loungeCategory').value = '';
      document.getElementById('loungeTitle').value = '';
      document.getElementById('loungeTextarea').value = '';
      uploadedFiles = [];
      document.getElementById('photoPreviewArea').innerHTML = '';
      
      const submitBtn = document.querySelector('.btn-submit-lounge');
      submitBtn.innerText = '작성 완료';
      submitBtn.removeAttribute('data-mode');
      submitBtn.removeAttribute('data-board-id');
      submitBtn.removeAttribute('data-post-id');
      document.querySelector('.lounge-modal-header h3').innerText = '새로운 이야기 ✈️';
  }
  function toggleSchedule() {
    const scheduleArea = document.getElementById('scheduleSelectArea');
    scheduleArea.style.display = scheduleArea.style.display === 'none' ? 'block' : 'none';
  }

  function handleFiles(files) {
      const previewArea = document.getElementById('photoPreviewArea');
      if (files.length === 0) return;

      const file = files[0];
      uploadedFiles = [file]; 
      
      previewArea.innerHTML = ''; 
      
      const fileUrl = URL.createObjectURL(file);
      const thumbWrap = document.createElement('div');
      thumbWrap.className = 'thumb-wrap';
      
      thumbWrap.innerHTML = `
        <img src="\${fileUrl}" alt="미리보기">
        <button type="button" class="thumb-remove" onclick="removeFile(this, '\${file.name}')">x</button>
      `;
      previewArea.appendChild(thumbWrap);
  }

  function removeFile(btn, fileName) {
    uploadedFiles = uploadedFiles.filter(f => f.name !== fileName);
    btn.parentElement.remove();
  }


  //  작성/수정 전송 함수 (글쓰기와 수정을 모두 처리)
  function submitLoungePost() {
      const submitBtn = document.querySelector('.btn-submit-lounge');
      const mode = submitBtn.getAttribute('data-mode');
      const targetId = submitBtn.getAttribute('data-post-id') || submitBtn.getAttribute('data-board-id');
      
      const category = document.getElementById('loungeCategory').value;
      const title = document.getElementById('loungeTitle').value;
      const content = document.getElementById('loungeTextarea').value;
      const tripId = document.getElementById('myTripSelect').value;

      if (mode !== 'edit-feed') {
          if(!category) { alert("카테고리를 선택해주세요!"); return; }
          if(!title.trim()) { alert("제목을 입력해주세요!"); return; }
      }
      
      if(!content.trim()) { alert("내용을 입력해주세요!"); return; }

      const formData = new FormData();
      
      if (mode !== 'edit-feed') {
          formData.append('category', category);
          formData.append('title', title);
      }
      
      formData.append('content', content);
      if (tripId) formData.append('tripId', tripId);
      
      uploadedFiles.forEach(file => {
          formData.append('files', file); 
      });

      let url = `${pageContext.request.contextPath}/community/api/freeboard/write`; 
      
      if (mode === 'edit') {
          url = `${pageContext.request.contextPath}/community/api/freeboard/update`;
          formData.append('boardId', targetId);
      } else if (mode === 'edit-feed') {
          url = `${pageContext.request.contextPath}/community/api/feed/update`;
          formData.append('postId', targetId);
      }

      fetch(url, {
          method: 'POST',
          body: formData 
      })
      .then(response => {
          if (!response.ok) throw new Error('서버 통신 에러');
          return response.json();
      })
      .then(data => {
          if(data.status === 'success') {
              alert("✨ " + (data.message || "처리가 완료되었습니다!"));
              location.reload(); 
          } else {
              alert("실패: " + data.message);
          }
      })
      .catch(error => {
          console.error('Error:', error);
          alert("작업 중 오류가 발생했습니다. 🥲");
      });
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

  async function openScheduleModal() {
	    if (typeof IS_LOGGED_IN !== 'undefined' && !IS_LOGGED_IN) {
	        showLoginModal();
	        return;
	    }

	    document.getElementById('scheduleModal').classList.add('active');
	    document.body.style.overflow = 'hidden';
	    
	    const listArea = document.querySelector('.sch-list-area');
	    listArea.innerHTML = '<div style="text-align:center; padding: 40px 20px; color:var(--text-gray); font-weight: bold;">일정을 불러오는 중... ✈️</div>';

	    try {
	        const url = '${pageContext.request.contextPath}/trip/api/my-trips'; 
	        const response = await fetch(url, { headers: { 'X-Requested-With': 'Fetch' } });
	        
	        if (!response.ok) throw new Error('데이터 로드 실패');
	        
	        const trips = await response.json(); 
	        
	        if (!trips || trips.length === 0) {
	            listArea.innerHTML = '<div style="text-align:center; padding: 40px 20px; color:var(--text-gray);">공유할 내 일정이 없습니다. 🥲</div>';
	            return;
	        }

	        let html = '';
	        trips.forEach(trip => {
	            const tripId = trip.tripId;
	            const tripName = trip.tripName;
	            const budget = trip.totalBudget || 0;
	            const members = trip.regionId || 1; 
	            const placeCount = trip.cities ? trip.cities.length : 0; 
	            
	            const startDate = trip.startDate ? trip.startDate.substring(0, 10) : '';
	            const endDate = trip.endDate ? trip.endDate.substring(0, 10) : '';

	            html += `
	                <div class="sch-item" onclick="toggleScheduleSelect(this, '\${tripId}', '\${tripName}', \${placeCount}, \${budget}, \${members})">
	                    <div>
	                        <h4 style="margin: 0 0 6px; font-size: 16px; font-weight: 800; color: var(--text-black);">\${tripName}</h4>
	                        <p style="margin: 0; font-size: 13px; color: var(--text-gray);">\${startDate} ~ \${endDate}</p>
	                    </div>
	                    <div class="check-circle"></div>
	                </div>
	            `;
	        });
	        
	        listArea.innerHTML = html;

	    } catch (error) {
	        console.error("일정 목록 로딩 실패:", error);
	        listArea.innerHTML = '<div style="text-align:center; padding: 40px 20px; color:#FF6B6B;">일정을 불러오지 못했습니다. 😢</div>';
	    }
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
          '    <div style="margin-bottom: 4px;">📍 장소: ' + placeCount + '곳 방문</div>' +
          '    <div style="margin-bottom: 4px;">👥 인원: ' + memberCount + '명</div>' +
          '    <div style="color:var(--sky-blue); font-weight: bold;">└ 1인당 약 ' + perPerson + '원</div>' +
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
  
	function deletePost(postId) {
	    if (!confirm('정말 이 게시글을 삭제하시겠습니까? 삭제 후에는 복구할 수 없습니다.')) return; 

	    fetch(`${pageContext.request.contextPath}/community/api/feed/delete/` + postId, {
	        method: 'POST',
	        headers: { 'X-Requested-With': 'Fetch' } 
	    })
	    .then(res => {
	        if (res.status === 401) { showLoginModal(); throw new Error('Unauthorized'); }
	        return res.json();
	    })
	    .then(data => {
	        if(data.status === 'success') {
	            alert("✨ 게시글이 삭제되었습니다.");
	            if(typeof closeFeedModal === 'function') closeFeedModal(); // 열려있던 모달창 닫기
	            
	            refreshBackgroundProfile(true); 
	        } else {
	            alert("삭제 실패: " + data.message);
	        }
	    })
	    .catch(err => {
	        if(err.message !== 'Unauthorized') { console.error('에러:', err); alert("오류가 발생했습니다."); }
	    });
	}

  function toggleFollow(btn, targetMemberId) {
	    if (typeof IS_LOGGED_IN !== 'undefined' && !IS_LOGGED_IN) {
	        showLoginModal();
	        return;
	    }

	    fetch(`${pageContext.request.contextPath}/community/api/follow/\${targetMemberId}`, { 
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
	    if (typeof IS_LOGGED_IN !== 'undefined' && !IS_LOGGED_IN) {
	        showLoginModal();
	        return;
	    }

	    if (!confirm('이 여행 일정을 내 보관함으로 담아오시겠습니까?\n담아온 일정은 나의 여행 목록에서 자유롭게 수정할 수 있습니다.')) {
	        return;
	    }

	    const url = '${pageContext.request.contextPath}/trip/' + tripId + '/scrap';

	    fetch(url, {
	        method: 'POST',
	        headers: {
	            'X-Requested-With': 'Fetch'
	        }
	    })
	    .then(res => {
	        if (res.status === 401) {
	            showLoginModal();
	            throw new Error('Unauthorized');
	        }
	        if (!res.ok) throw new Error('서버 응답 오류');
	        return res.json();
	    })
	    .then(data => {
	        if (data.success) {
	            if (confirm('✨ 일정이 내 보관함에 성공적으로 저장되었습니다!\n지금 바로 새 일정을 확인하러 가시겠습니까?')) {
	                location.href = '/trip/' + data.newTripId + '/workspace';
	            }
	        } else {
	            alert('일정 담아오기에 실패했습니다: ' + (data.message || '알 수 없는 오류'));
	        }
	    })
	    .catch(err => {
	        if (err.message !== 'Unauthorized') {
	            console.error('Scrap Error:', err);
	            alert('일정을 담아오는 중 오류가 발생했습니다. 잠시 후 다시 시도해주세요. 🥲');
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

	        const feedCard = p.closest('.feed-card');
	        if(feedCard) {
	            const postId = feedCard.getAttribute('data-post-id');
	            if(postId) {
	                loadFeedComments(postId, true); 
	            }
	        }
	    });
	}

  document.addEventListener("DOMContentLoaded", renderHashtags);
 
  function toggleFeedLike(btnElement, postId) {
      if (typeof IS_LOGGED_IN !== 'undefined' && !IS_LOGGED_IN) { showLoginModal(); return; }
      
      const url = `${pageContext.request.contextPath}/community/api/feed/like/` + postId;
      fetch(url, { method: 'POST', headers: { 'X-Requested-With': 'Fetch' } })
      .then(res => {
          if (res.status === 401) { showLoginModal(); return null; }
          if (!res.ok) throw new Error('서버 에러');
          return res.json();
      })
      .then(data => {
          if (data) {
              const countSpan = btnElement.querySelector('.like-cnt');
              const heartIcon = btnElement.querySelector('.heart-icon');
              countSpan.innerText = data.count;
              if (data.status === 'liked') heartIcon.innerText = '♥';
              else heartIcon.innerText = '♡';
              
              refreshBackgroundProfile(false); 
          }
      })
      .catch(err => console.error("피드 좋아요 처리 중 오류:", err));
  }

function openComment(postId) {
 if (typeof IS_LOGGED_IN !== 'undefined' && !IS_LOGGED_IN) {
        showLoginModal();
        return;
    }
    const commentArea = document.getElementById('feed-comment-area-' + postId);
    if (commentArea.style.display === 'block') {
        commentArea.style.display = 'none'; 
        return;
    }
    commentArea.style.display = 'block';
    loadFeedComments(postId, false); 
}

function loadFeedComments(postId, isInit = false) {
    const listContainer = document.getElementById('comment-list-' + postId);
    const commentArea = document.getElementById('feed-comment-area-' + postId);
    
    if (!isInit) {
        listContainer.innerHTML = '<div style="text-align:center; font-size:12px; color:#999; padding:10px;">불러오는 중...⏳</div>';
    }
    
    const currentUserId = '${sessionScope.loginUser != null ? sessionScope.loginUser.memberId : ""}';

    fetch(`${pageContext.request.contextPath}/community/api/feed/` + postId + `/comments`)
    .then(res => {
        if (res.redirected || !res.ok) throw new Error("로그인 풀림");
        return res.text(); 
    })
    .then(text => {
        if(text.trim().startsWith("<!DOCTYPE") || text.trim().startsWith("<html")) {
            if(!isInit) showLoginModal(); // 자동 로딩 중엔 로그인 모달을 띄우지 않음
            throw new Error("HTML 응답됨");
        }
        
        const comments = JSON.parse(text);
        
        if (!comments || comments.length === 0) {
            if (isInit) return; 
            
            listContainer.innerHTML = '<div style="text-align:center; font-size:12px; color:#999; padding:10px;">첫 번째 댓글을 남겨보세요! ✨</div>';
            return;
        }
        
        if (commentArea) {
            commentArea.style.display = 'block';
        }
        
        let html = '';
        const parentComments = comments.filter(c => c.parentCommentId === 0 || c.parentCommentId === null);
        const childComments = comments.filter(c => c.parentCommentId !== 0 && c.parentCommentId !== null);

        parentComments.forEach(comment => {
            let profileImg = comment.profileImage ? `${pageContext.request.contextPath}/uploads/profile/\${comment.profileImage}` : `${pageContext.request.contextPath}/dist/images/default.png`;
            let isMyComment = (currentUserId !== '' && currentUserId == comment.memberId);
            
		 let kebabMenu = isMyComment 
		     ? `<button class="kebab-item danger" onclick="deleteFeedComment(\${comment.commentId}, \${postId})">🗑️ 삭제하기</button>`
		     : `<button class="kebab-item danger" onclick="openReportModal('FEED_COMMENT', \${comment.commentId})">🚨 신고하기</button>`;

            html += `
            <div style="display: flex; flex-direction: column; gap: 10px; border-bottom: 1px dashed var(--border-color); padding-bottom: 12px; margin-bottom: 12px;">
                <div style="display: flex; gap: 10px;">
                    <img src="\${profileImg}" style="width: 32px; height: 32px; border-radius: 50%; object-fit: cover; border: 1px solid var(--border-color);">
                    <div style="flex: 1;">
                        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 4px;">
                            <span style="font-size: 13px; font-weight: 800; color: var(--text-dark);">@\${comment.nickname || '여행자'}</span>
                            <div style="display: flex; align-items: center; gap: 8px;">
                                <span style="font-size: 11px; color: var(--text-gray);">\${comment.createdAt}</span>
                                <span style="font-size: 11px; color: var(--sky-blue); font-weight: 900; cursor: pointer;" onclick="toggleFeedReplyForm(\${comment.commentId})">↳ 답글</span>
                                
                                <div class="comment-options" style="position: relative;">
                                    <button class="btn-kebab" onclick="toggleDropdown(this, event)"><svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round" style="pointer-events: none;"><circle cx="12" cy="5" r="1.5"></circle><circle cx="12" cy="12" r="1.5"></circle><circle cx="12" cy="19" r="1.5"></circle></svg></button>
                                    <div class="kebab-menu-list" style="display: none; position: absolute; right: 0; top: 100%; background: white; border: 1px solid var(--border-color); border-radius: 8px; box-shadow: 0 4px 12px rgba(0,0,0,0.15); min-width: 110px; z-index: 99999; margin-top: 4px;">
                                        \${kebabMenu}
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div style="font-size: 13px; color: var(--text-black); line-height: 1.4; white-space: pre-wrap;">\${comment.content}</div>
                    </div>
                </div>`;

            childComments.filter(child => child.parentCommentId === comment.commentId).forEach(child => {
                let cProfileImg = child.profileImage ? `${pageContext.request.contextPath}/uploads/profile/\${child.profileImage}` : `${pageContext.request.contextPath}/dist/images/default.png`;
                let isMyChild = (currentUserId !== '' && currentUserId == child.memberId);
                
			 let childKebab = isMyChild 
			     ? `<button class="kebab-item danger" onclick="deleteFeedComment(\${child.commentId}, \${postId})">🗑️ 삭제하기</button>`
			     : `<button class="kebab-item danger" onclick="openReportModal('FEED_COMMENT', \${child.commentId})">🚨 신고하기</button>`;

                html += `
                <div style="display: flex; gap: 8px; margin-left: 36px; margin-top: 4px; padding: 10px 14px; background: rgba(137, 207, 240, 0.05); border-radius: 12px;">
                    <span style="color: var(--sky-blue); font-weight: 900; font-size: 14px;">↳</span>
                    <img src="\${cProfileImg}" style="width: 28px; height: 28px; border-radius: 50%; object-fit: cover; border: 1px solid white;">
                    <div style="flex: 1;">
                        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 2px;">
                            <span style="font-size: 12px; font-weight: 800; color: var(--text-dark);">@\${child.nickname || '여행자'}</span>
                            <div style="display: flex; align-items: center; gap: 4px;">
                                <span style="font-size: 10px; color: var(--text-gray);">\${child.createdAt}</span>
                                <div class="comment-options" style="position: relative;">
                                    <button class="btn-kebab" onclick="toggleDropdown(this, event)"><svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round" style="pointer-events: none;"><circle cx="12" cy="5" r="1.5"></circle><circle cx="12" cy="12" r="1.5"></circle><circle cx="12" cy="19" r="1.5"></circle></svg></button>
                                    <div class="kebab-menu-list" style="display: none; position: absolute; right: 0; top: 100%; background: white; border: 1px solid var(--border-color); border-radius: 8px; box-shadow: 0 4px 12px rgba(0,0,0,0.15); min-width: 100px; z-index: 99999; margin-top: 4px;">
                                        \${childKebab}
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div style="font-size: 12px; color: var(--text-black); line-height: 1.4; white-space: pre-wrap;">\${child.content}</div>
                    </div>
                </div>`;
            });

            html += `
                <div id="feed-reply-form-\${comment.commentId}" style="display: none; gap: 8px; margin-left: 36px; margin-top: 8px;">
                    <input type="text" id="feed-reply-input-\${comment.commentId}" placeholder="@\${comment.nickname || '여행자'}님에게 답글 남기기..." style="flex: 1; border: 1px solid var(--border-color); border-radius: 20px; padding: 8px 14px; font-family: 'Pretendard', sans-serif; font-size: 12px; outline: none;">
                    <button class="btn-submit-lounge" style="padding: 8px 16px; border-radius: 20px; font-size: 12px;" onclick="submitFeedComment(\${postId}, \${comment.commentId})">등록</button>
                </div>
            </div>`;
        });
        
        listContainer.innerHTML = html;
        if(!isInit) listContainer.scrollTop = listContainer.scrollHeight;
    })
    .catch(err => {
        if(!isInit) listContainer.innerHTML = '<div style="text-align:center; font-size:13px; color:#FF6B6B; padding:10px; cursor:pointer;" onclick="showLoginModal()">세션이 만료되었습니다. 다시 로그인해주세요! 🔒</div>';
    });
}

function submitFeedComment(postId, parentId = 0) {
    if (typeof IS_LOGGED_IN !== 'undefined' && !IS_LOGGED_IN) {
        showLoginModal(); return;
    }

    const inputId = parentId === 0 ? 'comment-input-' + postId : 'feed-reply-input-' + parentId;
    const inputEl = document.getElementById(inputId);
    const content = inputEl.value.trim();
    
    if(content === '') {
        alert("내용을 입력해주세요!"); inputEl.focus(); return;
    }

    const data = { postId: postId, content: content, parentCommentId: parentId };

    fetch(`${pageContext.request.contextPath}/community/api/feed/comment/add`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json', 'X-Requested-With': 'Fetch' },
        body: JSON.stringify(data)
    })
    .then(res => {
        if (res.status === 401) { showLoginModal(); throw new Error('Unauthorized'); }
        return res.json();
    })
    .then(result => {
        if(result.status === 'success') {
            inputEl.value = ''; 
            loadFeedComments(postId, false); 
        } else {
            alert(result.message);
        }
    })
    .catch(err => console.error("댓글 등록 에러:", err));
}

function toggleFeedReplyForm(commentId) {
    const form = document.getElementById('feed-reply-form-' + commentId);
    if (form.style.display === 'none') {
        form.style.display = 'flex';
        document.getElementById('feed-reply-input-' + commentId).focus();
    } else {
        form.style.display = 'none';
    }
}

function deleteFeedComment(commentId, postId) {
    if (!confirm('정말 삭제하시겠습니까?\n(원본 댓글인 경우 답글도 함께 화면에서 사라집니다)')) return;
    
    fetch(`${pageContext.request.contextPath}/community/api/feed/comment/delete/` + commentId, {
        method: 'POST', headers: { 'X-Requested-With': 'Fetch' }
    })
    .then(res => res.json())
    .then(result => {
        if(result.status === 'success') {
            loadFeedComments(postId, false); 
            if (document.getElementById('feedDetailModalOverlay') && document.getElementById('feedDetailModalOverlay').classList.contains('active')) {
                openFeedModal(postId); 
            }
            
            refreshBackgroundProfile(false); 
        } else {
            alert(result.message);
        }
    })
    .catch(err => alert('삭제 중 오류가 발생했습니다.'));
}

const feedSliderState = {};

function moveSlide(postId, step) {
    if (feedSliderState[postId] === undefined) feedSliderState[postId] = 0;
    
    const slider = document.getElementById('slider-' + postId);
    const track = slider.querySelector('.slider-track');
    const dots = slider.querySelectorAll('.s-dot');
    const total = dots.length;

    let newIdx = feedSliderState[postId] + step;
    if (newIdx < 0) return; 
    if (newIdx >= total) return; 

    updateSliderUI(postId, newIdx, track, dots);
}

function goSlide(postId, idx) {
    const slider = document.getElementById('slider-' + postId);
    updateSliderUI(postId, idx, slider.querySelector('.slider-track'), slider.querySelectorAll('.s-dot'));
}

function updateSliderUI(postId, idx, track, dots) {
    feedSliderState[postId] = idx;
    track.style.transform = `translateX(-\${idx * 100}%)`;
    
    dots.forEach((dot, i) => {
        if (i === idx) dot.classList.add('active');
        else dot.classList.remove('active');
    });
}

function showToast(message) {
    let toast = document.getElementById("toastMsg");
    
    if (!toast) {
        toast = document.createElement("div");
        toast.id = "toastMsg";
        toast.style.cssText = `
            visibility: hidden; min-width: 250px; background-color: rgba(45, 55, 72, 0.9); 
            color: #fff; text-align: center; border-radius: 20px; padding: 14px 20px; 
            position: fixed; z-index: 10000; left: 50%; bottom: 30px; 
            transform: translateX(-50%); font-size: 14px; font-weight: 600; 
            opacity: 0; transition: opacity 0.3s, bottom 0.3s, visibility 0.3s;
            box-shadow: 0 4px 12px rgba(0,0,0,0.15);
        `;
        document.body.appendChild(toast);
    }
    
    toast.innerText = message;
    toast.style.visibility = "visible";
    toast.style.opacity = "1";
    toast.style.bottom = "50px";
    
    setTimeout(function(){ 
        toast.style.opacity = "0";
        toast.style.bottom = "30px";
        setTimeout(() => { toast.style.visibility = "hidden"; }, 300);
    }, 3000);
}

document.addEventListener('click', function(e) {
    const composerElement = e.target.closest('.composer-card textarea, .composer-card input, .composer-card button');
    
    if (composerElement) {
        if (typeof IS_LOGGED_IN !== 'undefined' && !IS_LOGGED_IN) {
            e.preventDefault();   
            e.stopPropagation(); 
            
            showToast("로그인이 필요한 서비스입니다. ✈️");
            
            if(typeof composerElement.blur === 'function') {
                composerElement.blur();
            }
        }
    }
}, true); 

// 자유게시판 카테고리 필터링 함수 
function filterFreeboard(category) {
    const contentArea = document.getElementById('dynamic-content');
    
    contentArea.innerHTML = '<div style="text-align:center; padding: 100px 20px; color:var(--sky-blue); font-size: 18px; font-weight:800;">데이터를 불러오는 중입니다... ⏳</div>';

    const url = `${pageContext.request.contextPath}/community/fragment/freeboard?category=` + category;
    
    fetch(url, {
        headers: { 'X-Requested-With': 'Fetch' }
    })
    .then(response => {
        if(!response.ok) throw new Error("네트워크 응답 에러!");
        return response.text();
    })
    .then(html => {
        contentArea.innerHTML = html;
         
        const activeChip = document.getElementById('chip-' + category);
        if(activeChip) {
            activeChip.classList.add('on');
        }
    })
    .catch(error => {
        console.error('Error:', error);
        contentArea.innerHTML = '<div style="text-align:center; padding: 50px; color:red;">데이터를 불러오는데 실패했습니다. 😢</div>';
    });
}

function deleteFreeboardPost(boardId) {
    if (!confirm('정말 이 게시글을 삭제하시겠습니까? 삭제 후에는 복구할 수 없습니다.')) {
        return; 
    }

    fetch(`${pageContext.request.contextPath}/community/api/freeboard/delete/` + boardId, {
        method: 'POST',
        headers: { 'X-Requested-With': 'Fetch' } 
    })
    .then(res => {
        if (res.status === 401) {
            showLoginModal();
            throw new Error('Unauthorized');
        }
        return res.json();
    })
    .then(data => {
        if(data.status === 'success') {
            alert("✨ 게시글이 성공적으로 삭제되었습니다.");
            loadTabContent('freeboard', null); 
        } else {
            alert("삭제 실패: " + data.message);
        }
    })
    .catch(err => {
        if(err.message !== 'Unauthorized') {
            console.error('게시글 삭제 에러:', err);
            alert("게시글 삭제 중 오류가 발생했습니다. 🥲");
        }
    });
}

function editFreeboardPost(boardId) {
     fetch(`${pageContext.request.contextPath}/community/api/freeboard/` + boardId)
     .then(res => res.json())
     .then(data => {
         document.getElementById('loungeCategory').value = data.category;
         document.getElementById('loungeTitle').value = data.title;
         document.getElementById('loungeTextarea').value = data.content;
         
         const submitBtn = document.querySelector('.btn-submit-lounge');
         submitBtn.innerText = '수정 완료'; 
         submitBtn.setAttribute('data-mode', 'edit'); 
         submitBtn.setAttribute('data-board-id', boardId); 
         
         document.querySelector('.lounge-modal-header h3').innerText = '게시글 수정 ✏️';

         openLoungeModal();
     })
     .catch(err => {
         console.error(err);
         alert('게시글 정보를 불러오지 못했습니다.');
     });
 }

 function reportFreeboardPost(boardId) {
     openReportModal('FREEBOARD', boardId); // 종류: FREEBOARD
 }

// 🗑️ 자유게시판 댓글 삭제 함수
function deleteFreeboardComment(commentId, boardId) {
    if (!confirm('정말 이 댓글을 삭제하시겠습니까?')) {
        return; 
    }

    fetch(`${pageContext.request.contextPath}/community/api/freeboard/comment/delete/` + commentId, {
        method: 'POST',
        headers: { 'X-Requested-With': 'Fetch' }
    })
    .then(res => {
        if (res.status === 401) { // 로그인이 풀렸을 경우
            showLoginModal();
            throw new Error('Unauthorized');
        }
        return res.json();
    })
    .then(data => {
        if(data.status === 'success') {
            loadBoardDetail(boardId, false); 
        } else {
            alert("댓글 삭제 실패: " + data.message);
        }
    })
    .catch(err => {
        if(err.message !== 'Unauthorized') {
            console.error('댓글 삭제 에러:', err);
            alert("댓글 삭제 중 오류가 발생했습니다. 🥲");
        }
    });
}

function reportFreeboardComment(commentId) {
    openReportModal('FREEBOARD_COMMENT', commentId); // 종류: FREEBOARD_COMMENT
}
 
 function openReportModal(targetType, targetId) {
     if (typeof IS_LOGGED_IN !== 'undefined' && !IS_LOGGED_IN) {
         showLoginModal();
         return;
     }
     document.getElementById('reportTargetType').value = targetType;
     document.getElementById('reportTargetId').value = targetId;
     document.getElementById('reportReasonSelect').value = ''; // 셀렉트박스 초기화
     
     document.getElementById('commonReportModal').classList.add('active');
 }

 function closeReportModal() {
     document.getElementById('commonReportModal').classList.remove('active');
 }

 function submitReport() {
     const targetType = document.getElementById('reportTargetType').value;
     const targetId = document.getElementById('reportTargetId').value;
     const reason = document.getElementById('reportReasonSelect').value;

     if (!reason) {
         alert("신고 사유를 선택해주세요.");
         return;
     }

     const requestData = {
         targetType: targetType,
         targetId: targetId,
         reason: reason
     };

     fetch(`${pageContext.request.contextPath}/api/report/submit`, {
         method: 'POST',
         headers: { 'Content-Type': 'application/json', 'X-Requested-With': 'Fetch' },
         body: JSON.stringify(requestData)
     })
     .then(res => res.json())
     .then(data => {
         if(data.status === 'success') {
             alert("신고가 정상적으로 접수되었습니다.");
             closeReportModal();
         } else {
             alert("신고 접수 실패: " + data.message);
         }
     })
     .catch(err => {
         console.error(err);
         alert("신고 처리 중 오류가 발생했습니다.");
     });
 }
 
 function editPost(postId) {
     fetch(`${pageContext.request.contextPath}/community/api/feed/` + postId)
     .then(res => {
         if (!res.ok) throw new Error("데이터 로딩 실패");
         return res.json();
     })
     .then(data => {
         document.querySelector('.lounge-modal-header h3').innerText = '피드 수정하기 ✏️';
         
         document.getElementById('loungeCategory').style.display = 'none'; 
         document.getElementById('loungeTitle').style.display = 'none';   
         
         const contentArea = document.getElementById('loungeTextarea');
         contentArea.value = data.content;
         
         const previewArea = document.getElementById('photoPreviewArea');
         previewArea.innerHTML = ''; 
         
         if (data.imageUrl) {
             const images = data.imageUrl.split(',');
             images.forEach(imgName => {
                 const thumbWrap = document.createElement('div');
                 thumbWrap.className = 'thumb-wrap';
                 thumbWrap.innerHTML = `
                     <img src="${pageContext.request.contextPath}/uploads/feed/\${imgName}" alt="기존 이미지">
                     <p style="font-size:10px; color:gray; margin:0;">기존사진</p>
                 `;
                 previewArea.appendChild(thumbWrap);
             });
         }
         
         const submitBtn = document.querySelector('.btn-submit-lounge');
         submitBtn.innerText = '수정 완료';
         submitBtn.setAttribute('data-mode', 'edit-feed');
         submitBtn.setAttribute('data-post-id', postId);

         document.getElementById('loungeWriteModal').classList.add('active');
     })
     .catch(err => {
         console.error(err);
         alert("게시글 정보를 불러오는 데 실패했습니다. 🥲");
     });
 }
 
 function loadUserProfile(memberId) {
     if (!memberId || memberId === '') return;

     const currentUserId = '${sessionScope.loginUser != null ? sessionScope.loginUser.memberId : ""}';
     if (!currentUserId) { showLoginModal(); return; }

     document.querySelectorAll('.side-nav li').forEach(li => li.classList.remove('active'));

     const contentArea = document.getElementById('dynamic-content');
     contentArea.innerHTML = '<div style="text-align:center; padding: 100px 20px; color:var(--sky-blue); font-size: 18px; font-weight:800;">여행자의 발자취를 불러오는 중... ✈️</div>';

     const url = '${pageContext.request.contextPath}/community/fragment/profile?memberId=' + memberId;
     
     fetch(url, { headers: { 'X-Requested-With': 'Fetch' } })
     .then(res => {
         if (res.redirected) throw new Error("로그인 풀림");
         if(!res.ok) throw new Error("네트워크 응답 에러");
         return res.text();
     })
     .then(html => {
         if(html.trim().startsWith("<!DOCTYPE") || html.trim().startsWith("<html")) {
              showLoginModal(); throw new Error("HTML 응답됨");
         }
         
         contentArea.innerHTML = html;
         
         if (typeof setupInfiniteScroll === 'function') setupInfiniteScroll(); 
         if (typeof renderHashtags === 'function') setTimeout(() => renderHashtags(), 50);
         
         window.scrollTo({ top: 0, behavior: 'smooth' });
         history.pushState(null, null, '?tab=profile&memberId=' + memberId);

         const savedTab = sessionStorage.getItem('profileTab_' + memberId);
         if (savedTab) {
             const tabToClick = document.querySelector(`.profile-tab[onclick*="${savedTab}"]`);
             if (tabToClick) window.switchProfileTab(tabToClick, savedTab);
         }
     })
     .catch(err => {
         console.error(err);
         if (err.message !== "로그인 풀림" && err.message !== "HTML 응답됨(로그인 필요)") {
             contentArea.innerHTML = '<div style="text-align:center; padding: 50px; color:#FF6B6B;">프로필을 불러오는데 실패했습니다. 😢</div>';
         }
     });
 }
 
window.switchProfileTab = function(element, tabName) {
     document.querySelectorAll('.profile-tab').forEach(tab => tab.classList.remove('active'));
     element.classList.add('active');

     document.querySelectorAll('.tab-pane').forEach(pane => pane.classList.remove('active'));
     
     const targetPane = document.getElementById('tab-' + tabName);
     if (targetPane) {
         targetPane.classList.add('active');
     }
	 const urlParams = new URLSearchParams(window.location.search);
	 const currentMemberId = urlParams.get('memberId');
	 if (currentMemberId) {
		sessionStorage.setItem('profileTab_' + currentMemberId, tabName);
	 }
 };
 
 //  피드 상세 모달 열기
 function openFeedModal(postId) {
     const overlay = document.getElementById('feedDetailModalOverlay');
     const content = document.getElementById('feedDetailModalContent');
     
     content.innerHTML = '<div style="padding:50px; text-align:center; color:var(--sky-blue); font-weight:800;">피드를 불러오는 중... ✈️</div>';
     overlay.classList.add('active');
     document.body.style.overflow = 'hidden';

     fetch(`${pageContext.request.contextPath}/community/api/feed/detail/modal/` + postId, {
         headers: { 'X-Requested-With': 'Fetch' }
     })
     .then(res => res.text())
     .then(html => {
         content.innerHTML = html; 
     })
     .catch(err => {
         console.error(err);
         content.innerHTML = '<div style="padding:50px; text-align:center; color:red;">피드를 불러오지 못했습니다. 😢</div>';
     });
 }

 function closeFeedModal() {
     const overlay = document.getElementById('feedDetailModalOverlay');
     overlay.classList.remove('active');
     document.body.style.overflow = 'auto'; // 스크롤 복구
 }

 document.getElementById('feedDetailModalOverlay').addEventListener('click', function(e) {
     if (e.target === this) closeFeedModal();
 });

 // 배경 화면(내 활동 탭 등)을 새로고침 없이 갱신해주는 함수
 function refreshBackgroundProfile(isPostDelete = false) {
     const urlParams = new URLSearchParams(window.location.search);
     if (urlParams.get('tab') === 'profile') {
         const activeTabEl = document.querySelector('.profile-tab.active');
         let activeInnerTabName = 'feeds';
         
         if (activeTabEl) {
             const match = activeTabEl.getAttribute('onclick').match(/'([^']+)'/);
             if (match) activeInnerTabName = match[1];
         }

         if (isPostDelete || activeInnerTabName === 'activity') {
             const memberId = urlParams.get('memberId');
             fetch(`${pageContext.request.contextPath}/community/fragment/profile?memberId=` + memberId, {
                 headers: { 'X-Requested-With': 'Fetch' }
             })
             .then(res => res.text())
             .then(html => {
                 document.getElementById('dynamic-content').innerHTML = html;
                 
                 const tabToClick = document.querySelector(`.profile-tab[onclick*="\${activeInnerTabName}"]`);
                 if (tabToClick) switchProfileTab(tabToClick, activeInnerTabName);
             });
         }
     } else {
         if (isPostDelete) location.reload();
     }
 }
 
 function restorePreviousState() {
     const urlParams = new URLSearchParams(window.location.search);
     const tab = urlParams.get('tab');
     const memberId = urlParams.get('memberId');

     if (tab === 'profile' && memberId) {
         loadUserProfile(memberId);
     } else if (tab) {
         loadTabContent(tab);
     } else {
         loadTabContent('feed');
     }
 }
 
 window.toggleMateStatus = function(mateId, targetStatus) {
 	     if (!confirm(targetStatus === 'CLOSED' ? '동행 모집을 마감하시겠습니까?' : '동행 모집을 다시 시작하시겠습니까?')) return;
 	     
 	     const formData = new URLSearchParams();
 	     formData.append('status', targetStatus);

 	     fetch(`${pageContext.request.contextPath}/community/api/mate/status/` + mateId, {
 	         method: 'POST',
 	         body: formData,
 	         headers: { 
 	             'X-Requested-With': 'Fetch',
 	             'Content-Type': 'application/x-www-form-urlencoded'
 	         }
 	     })
 	     .then(res => {
 	         if(res.status === 401) { showLoginModal(); throw new Error('Unauthorized'); }
 	         return res.json();
 	     })
 	     .then(data => {
 	         if(data.status === 'success') {
                  
 	             if (document.getElementById('mateListContainer') && typeof window.searchMates === 'function') {
 	                 window.searchMates();
 	             } else if (typeof loadMateDetail === 'function') {
 	                 loadMateDetail(mateId, false); 
 	             }
                  
                  if (typeof refreshBackgroundProfile === 'function') refreshBackgroundProfile(false); 

 	         } else {
 	             alert(data.message);
 	         }
 	     })
 	     .catch(err => { if(err.message !== 'Unauthorized') console.error(err); });
 	 };

 	 window.deleteMatePost = function(mateId) {
 	     if (!confirm('정말 이 동행 모집글을 삭제하시겠습니까? 삭제 후에는 복구할 수 없습니다.')) return; 

 	     fetch(`${pageContext.request.contextPath}/community/api/mate/delete/` + mateId, {
 	         method: 'POST',
 	         headers: { 'X-Requested-With': 'Fetch' } 
 	     })
 	     .then(res => {
 	         if (res.status === 401) { showLoginModal(); throw new Error('Unauthorized'); }
 	         return res.json();
 	     })
 	     .then(data => {
 	         if(data.status === 'success') {
 	             alert("✨ 동행글이 성공적으로 삭제되었습니다.");
                  
 	             if (document.getElementById('mateListContainer') && typeof window.searchMates === 'function') {
 	                 window.searchMates(); 
 	             } else if (typeof restorePreviousState === 'function') {
 	                 restorePreviousState(); 
 	             }
                  
                  if (typeof refreshBackgroundProfile === 'function') refreshBackgroundProfile(true);

 	         } else {
 	             alert("삭제 실패: " + data.message);
 	         }
 	     })
 	     .catch(err => { if(err.message !== 'Unauthorized') alert("게시글 삭제 중 오류가 발생했습니다. 🥲"); });
 	 };
	 
	 
 window.loadMateComments = function(mateId, isInit = false) {
      const listContainer = document.getElementById('comment-list-' + mateId);
      if (!listContainer) return;

      if (!isInit) listContainer.innerHTML = '<div style="text-align:center; font-size:12px; color:#999; padding:10px;">불러오는 중...⏳</div>';

      const myId = '${sessionScope.loginUser != null ? sessionScope.loginUser.memberId : ""}';

      fetch(`${pageContext.request.contextPath}/community/api/mate/` + mateId + `/comments`)
      .then(res => {
          if (res.redirected || !res.ok) throw new Error("로그인 풀림");
          return res.text();
      })
      .then(text => {
          if(text.trim().startsWith("<!DOCTYPE") || text.trim().startsWith("<html")) {
              if(!isInit) showLoginModal();
              throw new Error("HTML 응답됨");
          }
          const comments = JSON.parse(text);
          
          const countSpan = document.getElementById('comment-count-' + mateId);
          if(countSpan) countSpan.innerText = comments ? comments.length : 0;

          if (!comments || comments.length === 0) {
              listContainer.innerHTML = '<div style="text-align:center; font-size:12px; color:#999; padding:10px;">첫 번째 댓글을 남겨보세요! ✨</div>';
              return;
          }

          let html = '';
          const parentComments = comments.filter(c => c.parentId === 0 || c.parentId === null);
          const childComments = comments.filter(c => c.parentId !== 0 && c.parentId !== null);

          parentComments.forEach(comment => {
              let profileImg = comment.profilePhoto ? `${pageContext.request.contextPath}/uploads/profile/\${comment.profilePhoto}` : `${pageContext.request.contextPath}/dist/images/default.png`;
              
              let isMyComment = (myId !== '' && String(myId) === String(comment.memberId));

              let kebabMenu = isMyComment
                  ? `<button class="kebab-item danger" onclick="window.deleteMateComment(\${comment.commentId}, \${mateId})">🗑️ 삭제하기</button>`
                  : `<button class="kebab-item danger" onclick="openReportModal('MATE_COMMENT', \${comment.commentId})">🚨 신고하기</button>`;

              html += `
              <div style="display: flex; flex-direction: column; gap: 10px; border-bottom: 1px dashed var(--border-color); padding-bottom: 12px; margin-bottom: 12px;">
                  <div style="display: flex; gap: 10px;">
                      <img src="\${profileImg}" style="width: 32px; height: 32px; border-radius: 50%; object-fit: cover; border: 1px solid var(--border-color);">
                      <div style="flex: 1;">
                          <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 4px;">
                              <span style="font-size: 13px; font-weight: 800; color: var(--text-dark);">@\${comment.nickname || '여행자'}</span>
                              <div style="display: flex; align-items: center; gap: 8px;">
                                  <span style="font-size: 11px; color: var(--text-gray);">\${comment.createdAt}</span>
                                  <span style="font-size: 11px; color: var(--sky-blue); font-weight: 900; cursor: pointer;" onclick="window.toggleMateReplyForm(\${comment.commentId})">↳ 답글</span>

                                  <div class="comment-options" style="position: relative;">
                                      <button class="btn-kebab" onclick="event.stopPropagation(); const menu = this.nextElementSibling; const isBlock = menu.style.display === 'block'; document.querySelectorAll('.kebab-menu-list').forEach(el => el.style.display = 'none'); if(!isBlock) menu.style.display = 'block';"><svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round" style="pointer-events: none;"><circle cx="12" cy="5" r="1.5"></circle><circle cx="12" cy="12" r="1.5"></circle><circle cx="12" cy="19" r="1.5"></circle></svg></button>
                                      <div class="kebab-menu-list" style="display: none; position: absolute; right: 0; top: 100%; background: white; border: 1px solid var(--border-color); border-radius: 8px; box-shadow: 0 4px 12px rgba(0,0,0,0.15); min-width: 110px; z-index: 99999; margin-top: 4px;">
                                          \${kebabMenu}
                                      </div>
                                  </div>
                              </div>
                          </div>
                          <div style="font-size: 13px; color: var(--text-black); line-height: 1.4; white-space: pre-wrap;">\${comment.content}</div>
                      </div>
                  </div>`;

              childComments.filter(child => child.parentId === comment.commentId).forEach(child => {
                  let cProfileImg = child.profilePhoto ? `${pageContext.request.contextPath}/uploads/profile/\${child.profilePhoto}` : `${pageContext.request.contextPath}/dist/images/default.png`;
                  
                  let isMyChild = (myId !== '' && String(myId) === String(child.memberId));

                  let childKebab = isMyChild
                      ? `<button class="kebab-item danger" onclick="window.deleteMateComment(\${child.commentId}, \${mateId})">🗑️ 삭제하기</button>`
                      : `<button class="kebab-item danger" onclick="openReportModal('MATE_COMMENT', \${child.commentId})">🚨 신고하기</button>`;

                  html += `
                  <div style="display: flex; gap: 8px; margin-left: 36px; margin-top: 4px; padding: 10px 14px; background: rgba(137, 207, 240, 0.05); border-radius: 12px;">
                      <span style="color: var(--sky-blue); font-weight: 900; font-size: 14px;">↳</span>
                      <img src="\${cProfileImg}" style="width: 28px; height: 28px; border-radius: 50%; object-fit: cover; border: 1px solid white;">
                      <div style="flex: 1;">
                          <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 2px;">
                              <span style="font-size: 12px; font-weight: 800; color: var(--text-dark);">@\${child.nickname || '여행자'}</span>
                              <div style="display: flex; align-items: center; gap: 4px;">
                                  <span style="font-size: 10px; color: var(--text-gray);">\${child.createdAt}</span>
                                  <div class="comment-options" style="position: relative;">
                                      <button class="btn-kebab" onclick="event.stopPropagation(); const menu = this.nextElementSibling; const isBlock = menu.style.display === 'block'; document.querySelectorAll('.kebab-menu-list').forEach(el => el.style.display = 'none'); if(!isBlock) menu.style.display = 'block';"><svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round" style="pointer-events: none;"><circle cx="12" cy="5" r="1.5"></circle><circle cx="12" cy="12" r="1.5"></circle><circle cx="12" cy="19" r="1.5"></circle></svg></button>
                                      <div class="kebab-menu-list" style="display: none; position: absolute; right: 0; top: 100%; background: white; border: 1px solid var(--border-color); border-radius: 8px; box-shadow: 0 4px 12px rgba(0,0,0,0.15); min-width: 100px; z-index: 99999; margin-top: 4px;">
                                          \${childKebab}
                                      </div>
                                  </div>
                              </div>
                          </div>
                          <div style="font-size: 12px; color: var(--text-black); line-height: 1.4; white-space: pre-wrap;">\${child.content}</div>
                      </div>
                  </div>`;
              });

              html += `
                  <div id="mate-reply-form-\${comment.commentId}" style="display: none; gap: 8px; margin-left: 36px; margin-top: 8px;">
                      <input type="text" id="mate-reply-input-\${comment.commentId}" placeholder="@\${comment.nickname || '여행자'}님에게 답글 남기기..." style="flex: 1; border: 1px solid var(--border-color); border-radius: 20px; padding: 8px 14px; font-family: 'Pretendard', sans-serif; font-size: 12px; outline: none;">
                      <button class="btn-submit-lounge" style="padding: 8px 16px; border-radius: 20px; font-size: 12px;" onclick="window.submitMateComment(\${mateId}, \${comment.commentId})">등록</button>
                  </div>
              </div>`;
          });
          listContainer.innerHTML = html;
      }).catch(err => {
          if(!isInit) listContainer.innerHTML = '<div style="text-align:center; font-size:13px; color:#FF6B6B; padding:10px; cursor:pointer;" onclick="showLoginModal()">세션이 만료되었습니다. 다시 로그인해주세요! 🔒</div>';
      });
  };

  document.addEventListener('click', () => {
     document.querySelectorAll('.kebab-menu-list').forEach(d => d.style.display = 'none');
  });

window.submitMateComment = function(mateId, parentId = null) {
    if (typeof IS_LOGGED_IN !== 'undefined' && !IS_LOGGED_IN) { showLoginModal(); return; }

    const inputId = parentId === null ? 'comment-input-' + mateId : 'mate-reply-input-' + parentId;
    const inputEl = document.getElementById(inputId);
    const content = inputEl.value.trim();

    if(content === '') { alert("내용을 입력해주세요!"); inputEl.focus(); return; }

    const data = { mateId: mateId, content: content, parentId: parentId };

    fetch(`${pageContext.request.contextPath}/community/api/mate/comment/add`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json', 'X-Requested-With': 'Fetch' },
        body: JSON.stringify(data)
    })
    .then(res => {
        if (res.status === 401) { showLoginModal(); throw new Error('Unauthorized'); }
        return res.json();
    })
    .then(result => {
        if(result.status === 'success') {
            inputEl.value = '';
            window.loadMateComments(mateId, false);
        } else {
            alert(result.message);
        }
    })
    .catch(err => console.error("댓글 등록 에러:", err));
};

window.toggleMateReplyForm = function(commentId) {
    const form = document.getElementById('mate-reply-form-' + commentId);
    if (form.style.display === 'none') {
        form.style.display = 'flex';
        document.getElementById('mate-reply-input-' + commentId).focus();
    } else {
        form.style.display = 'none';
    }
};

window.deleteMateComment = function(commentId, mateId) {
    if (!confirm('정말 삭제하시겠습니까?\n(원본 댓글인 경우 답글도 함께 사라집니다)')) return;

    fetch(`${pageContext.request.contextPath}/community/api/mate/comment/delete/` + commentId, {
        method: 'POST', headers: { 'X-Requested-With': 'Fetch' }
    })
    .then(res => res.json())
    .then(result => {
        if(result.status === 'success') {
            window.loadMateComments(mateId, false);
            if (typeof refreshBackgroundProfile === 'function') refreshBackgroundProfile(false);
        } else {
            alert(result.message);
        }
    })
    .catch(err => alert('삭제 중 오류가 발생했습니다.'));
};

const aiQuestions = [
    { q: "이번 여행에서 가장 기대하는 것은?", 
   		 choices: [
   			 { emoji: "📸", text: "핫플 인생샷 건지기" }, 
   			 { emoji: "🌲", text: "자연 속 조용한 힐링" }, 
   			 { emoji: "🍽️", text: "맛집 푸드파이터" }, 
   			 { emoji: "🏛️", text: "역사와 문화 탐방" }] },
    { q: "선호하는 숙소 스타일은?", 
   		 choices: [
   			 { emoji: "🏨", text: "깔끔한 호텔/리조트" }, 
   			 { emoji: "⛺", text: "감성 가득 글램핑" }, 
   			 { emoji: "🏡", text: "현지 느낌 촌캉스" }, 
   			 { emoji: "🏖️", text: "오션뷰 럭셔리 풀빌라" }] },
    { q: "여행 중 주요 이동 수단은?", 
   		 choices: [
   			 { emoji: "🚗", text: "렌트카로 편하게" }, 
   			 { emoji: "🚌", text: "대중교통 감성 투어" }, 
   			 { emoji: "🚶", text: "튼튼한 두 다리" }, 
   			 { emoji: "🚂", text: "낭만적인 기차 여행" }] }
];

let currentAiStep = 0;
let aiAnswers = [];
let typingInterval;

function startRoulette() {
    currentAiStep = 0;
    aiAnswers = [];
    clearInterval(typingInterval);
    document.getElementById('aiRouletteModal').classList.add('active');
    document.getElementById('aiQuestionArea').style.display = 'block';
    document.getElementById('aiLoadingArea').style.display = 'none';
    document.getElementById('aiResultArea').style.display = 'none';
    renderAiQuestion();
}

function closeAiModal() {
    document.getElementById('aiRouletteModal').classList.remove('active');
    clearInterval(typingInterval);
}

function renderAiQuestion() {
    const qData = aiQuestions[currentAiStep];
    document.getElementById('aiStepIndicator').innerText = `STEP \${currentAiStep + 1} / 3`;
    document.getElementById('aiQuestionText').innerText = qData.q;
    let html = '';
    qData.choices.forEach(choice => {
        html += `<div class="balance-card" onclick="selectAiAnswer('\${choice.text}')">
                    <span class="balance-emoji">\${choice.emoji}</span>
                    <span class="balance-text">\${choice.text}</span>
                 </div>`;
    });
    document.getElementById('aiChoices').innerHTML = html;
}

function selectAiAnswer(answerText) {
    aiAnswers.push(answerText);
    currentAiStep++;
    if (currentAiStep < aiQuestions.length) {
        renderAiQuestion();
    } else {
        showAiLoading();
    }
}

function showAiLoading() {
    document.getElementById('aiQuestionArea').style.display = 'none';
    document.getElementById('aiLoadingArea').style.display = 'block';
    
    fetch(`${pageContext.request.contextPath}/community/api/ai/roulette`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json', 'X-Requested-With': 'Fetch' },
        body: JSON.stringify({ answers: aiAnswers })
    })
    .then(async res => {
        if (!res.ok) throw new Error("API 할당량 초과 또는 통신 에러");
        const text = await res.text(); 
        if (text.trim().startsWith("<")) throw new Error("서버에서 HTML 에러 반환");
        return JSON.parse(text); 
    })
    .then(data => {
        showAiResult(data.keyword, data.reason);
    })
    .catch(err => {
        console.error("🤖 AI 연동 에러 (보험 발동!):", err);
        const backupKeywords = ["제주", "부산", "강원", "여수", "서울"];
        const fallbackKeyword = backupKeywords[Math.floor(Math.random() * backupKeywords.length)];
        const fallbackReason = "앗! 지금 AI가 추천을 너무 많이 받아서 조금 지쳤나봐요 🥲 대신 기존 빅데이터를 기반으로 완벽한 여행지를 뽑아드렸습니다!";
        showAiResult(fallbackKeyword, fallbackReason);
    });
}

function showAiResult(keyword, reasonText) {
    document.getElementById('aiLoadingArea').style.display = 'none';
    document.getElementById('aiResultArea').style.display = 'block';
    const resultEl = document.getElementById('aiResultText');
    resultEl.innerHTML = ''; 
    const keywordsStr = aiAnswers.map(a => `<strong style="color:var(--sky-blue)">[\${a}]</strong>`).join(", ");
    const aiResponse = `선택하신 \${keywordsStr} 취향을 분석했습니다!<br><br>AI의 추천 여행지: <strong>\${keyword}</strong><br><br>\${reasonText}`;
    
    let i = 0;
    typingInterval = setInterval(() => {
        if(aiResponse.charAt(i) === '<') {
            let tag = '';
            while(aiResponse.charAt(i) !== '>') { tag += aiResponse.charAt(i); i++; }
            tag += '>';
            resultEl.innerHTML += tag;
        } else {
            resultEl.innerHTML += aiResponse.charAt(i);
        }
        i++;
        if (i >= aiResponse.length) clearInterval(typingInterval);
    }, 30);
    document.getElementById('btnGoFeed').setAttribute('onclick', `goToRecommendedFeed('\${keyword}')`);
}

window.goToRecommendedFeed = function(keyword) {
    closeAiModal(); 
    window.scrollTo({ top: 0, behavior: 'smooth' });
    showToast(`✨ AI가 추천한 [\${keyword}] 피드를 찾고 있어요 🔍`);
    const activeTab = document.querySelector('.side-nav li.active');
    if (!(activeTab && activeTab.id === 'tab-feed') && typeof loadTabContent === 'function') {
        loadTabContent('feed', null);
    }
    let attempts = 0;
    const checkExist = setInterval(() => {
        const cards = document.querySelectorAll('.feed-card');
        if (cards.length > 0 || attempts > 20) {
            clearInterval(checkExist);
            let matchCount = 0;
            cards.forEach(card => {
                if (card.innerText.includes(keyword)) {
                    card.style.display = 'block';
                    card.style.animation = 'fadeIn 0.5s ease'; 
                    matchCount++;
                } else {
                    card.style.display = 'none';
                }
            });
            if (matchCount === 0) {
                showToast(`앗! 지금은 [\${keyword}] 관련 피드가 없네요 🥲 다른 피드를 구경해보세요!`);
                cards.forEach(card => card.style.display = 'block'); 
            } else {
                showToast(`🎉 [\${keyword}] 관련 핫한 피드를 \${matchCount}개 찾았습니다!`);
            }
        }
        attempts++;
    }, 150); 
}

let currentFollowTargetId = null;

function openFollowModal(type, targetMemberId, targetNickname = '나의 친구들') {
 if (typeof IS_LOGGED_IN !== 'undefined' && !IS_LOGGED_IN) {
     showLoginModal();
     return;
 }

 currentFollowTargetId = targetMemberId;
 
 document.getElementById('followModalTitle').innerText = targetNickname;
 
 const modal = document.getElementById('followModalOverlay');
 modal.classList.add('active');
 document.body.style.overflow = 'hidden'; 
 
 switchFollowTab(type); 
}

function closeFollowModal() {
 document.getElementById('followModalOverlay').classList.remove('active');
 document.body.style.overflow = 'auto'; 
}

function switchFollowTab(type) {
 document.getElementById('tabFollower').classList.remove('active');
 document.getElementById('tabFollowing').classList.remove('active');
 
 if (type === 'follower') {
     document.getElementById('tabFollower').classList.add('active');
 } else {
     document.getElementById('tabFollowing').classList.add('active');
 }

 const listContainer = document.getElementById('followModalList');
 listContainer.innerHTML = '<div style="text-align: center; color: var(--text-gray); font-size: 13px; padding: 40px 0;">데이터를 불러오는 중... ✈️</div>';

 fetch(`${pageContext.request.contextPath}/api/feed/follow/list/\${type}/\${currentFollowTargetId}`, {
     headers: { 'X-Requested-With': 'Fetch' }
 })
 .then(res => {
     if (res.status === 401) { showLoginModal(); throw new Error('Unauthorized'); }
     return res.json();
 })
 .then(data => {
     if (!data || data.length === 0) {
         listContainer.innerHTML = `<div style="text-align: center; color: var(--text-gray); font-size: 14px; padding: 40px 0;">목록이 텅 비어있습니다 🥲</div>`;
         return;
     }

     let html = '';
     data.forEach(user => {
         // 자바에서 넘겨준 문자열 'true'/'false'를 boolean으로 안전하게 처리
         const isFollowing = user.isFollowing === 'true' || user.isFollowing === true;
         
         const btnClass = isFollowing ? 'following' : '';
         const btnText = isFollowing ? '팔로잉' : '팔로우';
         
         const profileSrc = user.profile && user.profile !== 'default.png' 
             ? `${pageContext.request.contextPath}/uploads/profile/\${user.profile}` 
             : `${pageContext.request.contextPath}/dist/images/default.png`;

         html += `
         <div class="follow-item">
             <div class="follow-item-left" onclick="goToProfile(\${user.id})">
                 <img src="\${profileSrc}" class="follow-avatar">
                 <span class="follow-name" style="font-size: 15px;">\${user.nickname}</span>
             </div>
             <button class="btn-mini-follow \${btnClass}" onclick="toggleFollow(this, \${user.id})">\${btnText}</button>
         </div>
         `;
     });
     
     listContainer.innerHTML = html;
 })
 .catch(err => {
     if(err.message !== 'Unauthorized') {
         console.error(err);
         listContainer.innerHTML = `<div style="text-align: center; color: #FF6B6B; font-size: 13px; padding: 40px 0;">데이터를 불러오지 못했습니다.</div>`;
     }
 });
}
 
function goToProfile(memberId) {
 closeFollowModal();
 if (typeof loadUserProfile === 'function') {
     loadUserProfile(memberId);
 }
}
 </script>
  
</body>
</html>