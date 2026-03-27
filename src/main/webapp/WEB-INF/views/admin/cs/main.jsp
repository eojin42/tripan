<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>고객센터 관리 - Tripan Admin</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/dist/css/admin.css">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/gh/orioncactus/pretendard@v1.3.8/dist/web/static/pretendard.css">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
  <style>
    /* ── 탭 ── */
    .cs-tab-bar {
      display: flex; gap: 0;
      border-bottom: 1px solid var(--border);
      margin-bottom: 24px;
      background: #fff;
      padding: 0 4px;
      border-radius: 12px 12px 0 0;
    }
    .cs-tab {
      padding: 14px 22px;
      font-size: 14px; font-weight: 700;
      color: var(--muted);
      border: none; background: none; cursor: pointer;
      border-bottom: 3px solid transparent;
      transition: all .2s;
      display: flex; align-items: center; gap: 8px;
      font-family: 'Pretendard', sans-serif;
    }
    .cs-tab:hover { color: var(--text); }
    .cs-tab.active { color: var(--primary); border-bottom-color: var(--primary); }
    .tab-badge {
      background: #FC8181; color: white;
      font-size: 10px; font-weight: 900;
      padding: 2px 7px; border-radius: 10px; min-width: 18px; text-align: center;
    }

    /* ── 탭 패널 ── */
    .tab-panel { display: none; }
    .tab-panel.active { display: block; }

    /* ── 채팅 레이아웃 ── */
    .chat-manage-layout {
	  display: grid; grid-template-columns: 320px 1fr;
	  height: calc(100vh - 220px);
	  border-radius: 16px; overflow: hidden;
	  border: 1px solid var(--border);
	}
    .chat-list-panel {
	  border-right: 1px solid var(--border);
	  background: #fff; display: flex; flex-direction: column;
	  height: 100%;   
	  min-height: 0;  
	  overflow: hidden;
	}
    .chat-list-header {
      padding: 18px 20px; border-bottom: 1px solid var(--border);
    }
    .chat-list-header h3 {
      font-size: 14px; font-weight: 900; margin-bottom: 10px;
      display: flex; align-items: center; gap: 7px; color: var(--text);
    }
    .chat-search {
      display: flex; align-items: center; gap: 8px;
      background: var(--bg); border-radius: 9px; padding: 8px 12px;
      border: 1px solid var(--border);
    }
    .chat-search i { color: var(--muted); font-size: 13px; }
    .chat-search input {
      border: none; background: none; outline: none;
      font-size: 13px; font-family: 'Pretendard', sans-serif; flex: 1; color: var(--text);
    }
    .chat-room-items { flex: 1; overflow-y: auto; }
    .chat-room-item {
      padding: 14px 18px; border-bottom: 1px solid var(--border);
      cursor: pointer; transition: background .15s; display: flex; gap: 12px;
    }
    .chat-room-item:hover { background: #F7FCFF; }
    .chat-room-item.active { background: #EFF6FF; border-left: 3px solid var(--primary); }
    .chat-room-item.unread { background: #FFF5F5; }
    .room-avatar {
      width: 38px; height: 38px; border-radius: 50%;
      background: linear-gradient(135deg, #89CFF0, #FFB6C1);
      display: flex; align-items: center; justify-content: center;
      font-size: 15px; flex-shrink: 0;
    }
    .room-info { flex: 1; min-width: 0; }
    .room-info-top {
      display: flex; justify-content: space-between; align-items: center; margin-bottom: 3px;
    }
    .room-user { font-size: 13px; font-weight: 800; color: var(--text); }
    .room-time { font-size: 11px; color: var(--muted); }
    .room-preview {
      font-size: 12px; color: var(--muted); font-weight: 500;
      white-space: nowrap; overflow: hidden; text-overflow: ellipsis;
    }
    .unread-badge {
      background: #FC8181; color: white; font-size: 10px; font-weight: 900;
      padding: 2px 6px; border-radius: 10px; flex-shrink: 0; align-self: center;
    }
    .chat-empty-list {
      flex: 1; display: flex; flex-direction: column;
      align-items: center; justify-content: center; gap: 8px;
      color: var(--muted); padding: 40px 20px; text-align: center;
    }
    .chat-empty-list i { font-size: 32px; opacity: .2; }
    .chat-empty-list p { font-size: 13px; font-weight: 600; }

    /* ── 채팅 뷰 ── */
    .chat-view-panel { display: flex; flex-direction: column; background: var(--bg); min-height: 0;}
    .chat-view-empty {
      flex: 1; display: flex; flex-direction: column;
      align-items: center; justify-content: center; gap: 12px; color: var(--muted);
    }
    .chat-view-empty i { font-size: 44px; opacity: .15; color: var(--primary); }
    .chat-view-empty p { font-size: 14px; font-weight: 600; }
    .chat-view-header {
      padding: 14px 22px; background: #fff;
      border-bottom: 1px solid var(--border);
      display: flex; justify-content: space-between; align-items: center;
    }
    .chat-view-header h3 { font-size: 14px; font-weight: 900; color: var(--text); margin: 0 0 2px; }
    .chat-view-header span { font-size: 12px; color: var(--muted); }
    .chat-status-open   { background: #D1FAE5; color: #065F46; font-size: 11px; font-weight: 800; padding: 4px 12px; border-radius: 20px; }
    .chat-status-closed { background: #F3F4F6; color: #6B7280; font-size: 11px; font-weight: 800; padding: 4px 12px; border-radius: 20px; }
    .chat-messages-area {
      flex: 1; padding: 18px 22px; overflow-y: auto;
      display: flex; flex-direction: column; gap: 12px; min-height: 0;
    }
    .msg-row { display: flex; gap: 8px; align-items: flex-end; }
    .msg-row.admin-msg { justify-content: flex-end; }
    .msg-avatar {
      width: 30px; height: 30px; border-radius: 50%; flex-shrink: 0;
      font-size: 13px; display: flex; align-items: center; justify-content: center;
      background: linear-gradient(135deg, #89CFF0, #FFB6C1);
    }
    .msg-bubble {
       min-width: 60px; max-width: 90%; padding: 9px 14px; border-radius: 14px;
      font-size: 13px; line-height: 1.5; font-weight: 600; word-break: break-word;
    }
    .msg-row.user-msg .msg-bubble  { background: #fff; border-top-left-radius: 4px; box-shadow: 0 2px 6px rgba(0,0,0,.05); }
    .msg-row.admin-msg .msg-bubble { background: #111; color: white; border-bottom-right-radius: 4px; }
    .msg-name { font-size: 11px; color: var(--muted); margin-bottom: 3px; font-weight: 700; }
    .msg-time { font-size: 10px; color: #A0AEC0; flex-shrink: 0; margin-bottom: 2px; }
    .chat-input-bar {
      padding: 12px 18px; background: #fff;
      border-top: 1px solid var(--border);
      display: flex; gap: 10px; align-items: flex-end;
    }
    .admin-input {
      flex: 1; padding: 9px 16px; border: 1.5px solid var(--border);
      border-radius: 20px; font-size: 13px; font-family: 'Pretendard', sans-serif;
      outline: none; resize: none; max-height: 100px; line-height: 1.5;
      transition: border-color .2s;
    }
    .admin-input:focus { border-color: var(--primary); }
    .btn-chat-send {
      width: 38px; height: 38px; border-radius: 50%; border: none;
      background: #111; color: white; cursor: pointer;
      display: flex; align-items: center; justify-content: center; flex-shrink: 0;
      transition: transform .2s;
    }
    .btn-chat-send:hover { transform: scale(1.08); opacity: .85; }
    .btn-chat-send svg { width: 15px; height: 15px; fill: none; stroke: currentColor; stroke-width: 2.5; stroke-linecap: round; stroke-linejoin: round; margin-left: -1px; }
    .btn-end-chat {
      height: 32px; padding: 0 14px; border-radius: 8px; font-size: 12px; font-weight: 800;
      border: 1.5px solid #FC8181; color: #FC8181; background: #fff;
      cursor: pointer; transition: all .2s; font-family: 'Pretendard', sans-serif; flex-shrink: 0;
    }
    .btn-end-chat:hover { background: #FFF5F5; }
    
    .room-status-pill {
	  font-size: 10px; font-weight: 800;
	  padding: 2px 8px; border-radius: 10px;
	  display: inline-block; margin-top: 3px;
	}
	.room-status-pill.waiting { background: #FFF3CD; color: #856404; }
	.room-status-pill.active  { background: #D1FAE5; color: #065F46; }
	.room-status-pill.closed  { background: #F3F4F6; color: #6B7280; }
	.chat-group-label {
	  padding: 8px 18px 4px;
	  font-size: 10px; font-weight: 900; color: var(--muted);
	  letter-spacing: 0.5px; text-transform: uppercase;
}
#chatViewMain {
  display: none; flex-direction: column; height: 100%;
  min-height: 0; 
  overflow: hidden; 
}
  </style>
</head>
<body>

<div class="admin-layout">
  <jsp:include page="../layout/sidebar.jsp">
    <jsp:param name="activePage" value="cs"/>
  </jsp:include>

  <div class="main-wrapper">
    <jsp:include page="../layout/header.jsp" />

    <main class="main-content">

      <!-- 페이지 헤더 -->
      <div class="page-header fade-up">
        <div>
          <h1>고객센터 관리</h1>
          <p>1:1 채팅 상담을 관리합니다.</p>
        </div>
      </div>

      <!-- 탭 바 -->
      <div class="card fade-up" style="padding: 0;">
        <div class="cs-tab-bar">
          <button class="cs-tab active" onclick="switchTab('chat', this)">
            <i class="bi bi-chat-dots"></i> 1:1 채팅 상담
            <span class="tab-badge" id="chatBadge">0</span>
          </button>
        </div>

        <!-- ── 1:1 채팅 패널 ── -->
        <div class="tab-panel active" id="panel-chat">
          <div class="chat-manage-layout">

            <!-- 채팅 목록 -->
            <div class="chat-list-panel">
              <div class="chat-list-header">
                <h3><i class="bi bi-chat-heart" style="color:var(--primary);"></i> 상담 목록</h3>
                <div class="chat-search">
                  <i class="bi bi-search"></i>
                  <input type="text" placeholder="사용자 검색..." oninput="filterChatRooms(this.value)">
                </div>
              </div>
              <div class="chat-room-items" id="chatRoomItems">
                <div class="chat-empty-list">
                  <i class="bi bi-chat-dots"></i>
                  <p>상담 내역이 없습니다</p>
                </div>
              </div>
            </div>

            <!-- 채팅 뷰 -->
            <div class="chat-view-panel">
              <div class="chat-view-empty" id="chatViewEmpty">
                <i class="bi bi-chat-heart"></i>
                <p>좌측에서 상담을 선택하세요</p>
              </div>

              <div id="chatViewMain" style="display:none; flex-direction:column; height:100%; overflow:hidden;">
                <div class="chat-view-header">
                  <div>
                    <h3 id="chatViewTitle">상담</h3>
                    <span id="chatViewSub"></span>
                  </div>
                  <div style="display:flex; gap:8px; align-items:center;">
                    <span id="chatStatusBadge" class="chat-status-open">상담 중</span>
                    <button class="btn-end-chat" onclick="endChat()">상담 종료</button>
                  </div>
                </div>
                <div class="chat-messages-area" id="chatMessagesArea"></div>
                <div class="chat-input-bar">
                  <textarea class="admin-input" id="adminMsgInput"
                            placeholder="답변을 입력하세요... (Enter: 전송, Shift+Enter: 줄바꿈)"
                            rows="1"></textarea>
                  <button class="btn-chat-send" onclick="sendAdminMsg()">
                    <svg viewBox="0 0 24 24"><line x1="22" y1="2" x2="11" y2="13"></line><polygon points="22 2 15 22 11 13 2 9 22 2"></polygon></svg>
                  </button>
                </div>
              </div>
            </div>

          </div>
        </div>
      </div>

    </main>
  </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/sockjs-client@1/dist/sockjs.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/stomp.js/2.3.3/stomp.min.js"></script>
<script>
  window.TRIPAN_DATA = {
    ctxPath: '${pageContext.request.contextPath}',
    adminId: '${sessionScope.loginUser.memberId}',
    adminNick: '${sessionScope.loginUser.nickname}' || '관리자'
  };
</script>
<script src="${pageContext.request.contextPath}/dist/js/admin/cs.js"></script>
</body>
</html>
