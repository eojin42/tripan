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

    /* ── 필터/검색 툴바 ── */
    .board-toolbar {
      display: flex; justify-content: space-between; align-items: center;
      margin-bottom: 16px; gap: 12px; flex-wrap: wrap;
    }
    .filter-group { display: flex; gap: 6px; }
    .filter-btn {
      height: 34px; padding: 0 16px; border-radius: 9px; font-size: 13px; font-weight: 700;
      border: 1.5px solid var(--border); background: #fff; cursor: pointer;
      color: var(--muted); transition: all .2s; font-family: 'Pretendard', sans-serif;
    }
    .filter-btn.active, .filter-btn:hover {
      border-color: var(--primary); color: var(--primary); background: var(--primary-10);
    }

    /* ── 상태 pill ── */
    .status-pill {
      display: inline-flex; align-items: center; gap: 4px;
      padding: 3px 10px; border-radius: 20px; font-size: 12px; font-weight: 800;
    }
    .status-pill.waiting  { background: #FFF3CD; color: #856404; }
    .status-pill.answered { background: #D1FAE5; color: #065F46; }
    .status-pill.closed   { background: #F3F4F6; color: #6B7280; }

    .category-pill {
      display: inline-block; padding: 3px 10px; border-radius: 8px;
      font-size: 11px; font-weight: 700; background: #EFF6FF; color: #1D4ED8;
    }

    /* ── 문의 상세 모달 ── */
    .modal-overlay {
      position: fixed; inset: 0; background: rgba(15,23,42,0.5);
      backdrop-filter: blur(6px); display: none;
      justify-content: center; align-items: center;
      z-index: 3000; padding: 24px;
    }
    .modal-overlay.open { display: flex; }
    .inquiry-modal {
      background: #fff; width: 100%; max-width: 560px;
      border-radius: 22px; overflow: hidden;
      box-shadow: 0 24px 64px rgba(0,0,0,.16);
      animation: modalUp 0.3s cubic-bezier(0.16,1,0.3,1);
      display: flex; flex-direction: column;
      max-height: 85vh;
    }
    @keyframes modalUp {
      from { opacity:0; transform:translateY(20px); }
      to   { opacity:1; transform:translateY(0); }
    }
    .im-head {
      padding: 24px 28px 18px; border-bottom: 1px solid var(--border);
      display: flex; justify-content: space-between; align-items: flex-start;
    }
    .im-head h3 { font-size: 16px; font-weight: 900; margin: 0 0 8px; }
    .im-meta { display: flex; gap: 8px; align-items: center; flex-wrap: wrap; }
    .im-body { padding: 22px 28px; overflow-y: auto; flex: 1; display: flex; flex-direction: column; gap: 16px; }
    .im-content-box {
      background: var(--bg); border-radius: 12px; padding: 16px;
      font-size: 14px; line-height: 1.7; color: var(--text); font-weight: 500;
    }
    .im-foot { padding: 16px 28px; border-top: 1px solid var(--border); display: flex; gap: 10px; }
    .fg { display: flex; flex-direction: column; gap: 7px; }
    .fg label { font-size: 11px; font-weight: 800; color: var(--muted); text-transform: uppercase; letter-spacing: 0.6px; }
    .fg textarea {
      width: 100%; border: 1.5px solid var(--border); border-radius: 10px;
      padding: 10px 14px; font-size: 14px; font-weight: 500;
      background: #fff; outline: none; resize: vertical; min-height: 100px;
      font-family: 'Pretendard', sans-serif; line-height: 1.6;
      transition: border-color .2s; box-sizing: border-box;
    }
    .fg textarea:focus { border-color: var(--primary); box-shadow: 0 0 0 3px var(--primary-10); }
    .btn-m        { flex:1; height: 44px; border-radius: 10px; font-weight: 800; font-size: 14px; border: none; cursor: pointer; transition: opacity .15s; font-family: 'Pretendard', sans-serif; }
    .btn-m-ghost  { background: var(--bg); color: var(--text); }
    .btn-m-primary{ background: #111; color: #fff; }
    .btn-m:hover  { opacity: .84; }
    .btn-close-x  {
      width: 30px; height: 30px; border-radius: 50%; border: none;
      background: var(--bg); cursor: pointer; font-size: 15px;
      display: flex; align-items: center; justify-content: center;
      color: var(--muted); transition: all .2s; flex-shrink: 0;
    }
    .btn-close-x:hover { background: var(--border); }

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
          <p>문의 게시판 및 1:1 채팅 상담을 관리합니다.</p>
        </div>
      </div>

      <!-- 탭 바 -->
      <div class="card fade-up" style="padding: 0;">
        <div class="cs-tab-bar">
          <button class="cs-tab active" onclick="switchTab('board', this)">
            <i class="bi bi-card-list"></i> 문의 게시판
            <span class="tab-badge" id="boardBadge">0</span>
          </button>
          <button class="cs-tab" onclick="switchTab('chat', this)">
            <i class="bi bi-chat-dots"></i> 1:1 채팅 상담
            <span class="tab-badge" id="chatBadge">0</span>
          </button>
        </div>

        <!-- ── 문의 게시판 패널 ── -->
        <div class="tab-panel active" id="panel-board" style="padding: 24px;">

          <div class="board-toolbar">
            <div class="filter-group">
              <button class="filter-btn active" onclick="filterInquiry('all', this)">전체</button>
              <button class="filter-btn" onclick="filterInquiry('waiting', this)">대기 중</button>
              <button class="filter-btn" onclick="filterInquiry('answered', this)">답변 완료</button>
              <button class="filter-btn" onclick="filterInquiry('closed', this)">종료</button>
            </div>
            <div class="filter-row" style="margin:0;">
              <input type="text" class="keyword-input" style="width:220px;"
                     placeholder="제목 또는 작성자 검색..."
                     id="inquirySearch" oninput="searchInquiry(this.value)">
            </div>
          </div>

          <div class="table-responsive">
            <table>
              <thead>
                <tr>
                  <th>번호</th>
                  <th>분류</th>
                  <th>제목</th>
                  <th>작성자</th>
                  <th>작성일</th>
                  <th>상태</th>
                  <th class="right">관리</th>
                </tr>
              </thead>
              <tbody id="inquiryTbody">
                <tr>
                  <td colspan="7" style="text-align:center; padding:50px 0; color:var(--muted);">
                    <i class="bi bi-inbox" style="font-size:24px; opacity:.3; display:block; margin-bottom:8px;"></i>
                    문의 내역을 불러오는 중...
                  </td>
                </tr>
              </tbody>
            </table>
          </div>

          <div style="display:flex; justify-content:center; gap:6px; padding-top:16px;" id="boardPagination"></div>
        </div>

        <!-- ── 1:1 채팅 패널 ── -->
        <div class="tab-panel" id="panel-chat">
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

<!-- 문의 상세 모달 -->
<div class="modal-overlay" id="inquiryModal" onclick="handleBackdropClick(event)">
  <div class="inquiry-modal">
    <div class="im-head">
      <div>
        <h3 id="modalTitle">문의 제목</h3>
        <div class="im-meta">
          <span class="category-pill" id="modalCategory">결제</span>
          <span id="modalStatus" class="status-pill waiting">대기 중</span>
          <span style="font-size:12px; color:var(--muted);" id="modalDate"></span>
        </div>
      </div>
      <button class="btn-close-x" onclick="closeModal()">✕</button>
    </div>
    <div class="im-body">
      <div class="im-content-box" id="modalContent"></div>
      <div class="fg">
        <label>📝 답변 작성</label>
        <textarea id="modalReplyInput" placeholder="답변 내용을 입력하세요..."></textarea>
      </div>
    </div>
    <div class="im-foot">
      <button class="btn-m btn-m-ghost" onclick="closeModal()">취소</button>
      <button class="btn-m btn-m-primary" onclick="submitReply()">답변 등록</button>
    </div>
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
