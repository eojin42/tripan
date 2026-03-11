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
    :root {
      --sky-blue: #89CFF0;
      --light-pink: #FFB6C1;
      --grad-main: linear-gradient(135deg, var(--sky-blue), var(--light-pink));
      --text-black: #2D3748;
      --text-dark: #4A5568;
      --text-gray: #718096;
      --border: #E2E8F0;
      --bg: #F7FAFC;
      --white: #ffffff;
      --sidebar-w: 240px;
    }
    * { box-sizing: border-box; margin: 0; padding: 0; }
    body { font-family: 'Pretendard', sans-serif; background: var(--bg); color: var(--text-black); }

    /* 레이아웃 */
    .admin-wrap { display: flex; min-height: 100vh; }

    /* 메인 콘텐츠 */
    .main-content { flex: 1; display: flex; flex-direction: column; }

    /* 페이지 헤더 */
    .page-header {
      background: var(--white);
      border-bottom: 1px solid var(--border);
      padding: 24px 32px;
      display: flex; align-items: center; justify-content: space-between;
    }
    .page-header-left h1 {
      font-size: 22px; font-weight: 900; color: var(--text-black);
      display: flex; align-items: center; gap: 10px;
    }
    .page-header-left h1 i { color: var(--sky-blue); }
    .page-header-left p { font-size: 13px; color: var(--text-gray); margin-top: 4px; font-weight: 500; }

    /* 탭 */
    .cs-tabs {
      display: flex; gap: 0;
      background: var(--white);
      border-bottom: 1px solid var(--border);
      padding: 0 32px;
    }
    .cs-tab {
      padding: 16px 24px;
      font-size: 14px; font-weight: 700;
      color: var(--text-gray);
      border: none; background: none; cursor: pointer;
      border-bottom: 3px solid transparent;
      transition: all .2s;
      display: flex; align-items: center; gap: 8px;
      font-family: 'Pretendard', sans-serif;
    }
    .cs-tab:hover { color: var(--text-dark); }
    .cs-tab.active { color: var(--sky-blue); border-bottom-color: var(--sky-blue); }
    .tab-badge {
      background: #FC8181; color: white;
      font-size: 10px; font-weight: 900;
      padding: 2px 6px; border-radius: 10px; min-width: 18px; text-align: center;
    }

    /* 탭 패널 */
    .tab-panel { display: none; flex: 1; }
    .tab-panel.active { display: flex; flex-direction: column; }

    /* 문의 게시판 관리 */
    .inquiry-board { padding: 28px 32px; flex: 1; }

    /* 상단 필터/검색 */
    .board-toolbar {
      display: flex; justify-content: space-between; align-items: center;
      margin-bottom: 20px; gap: 16px; flex-wrap: wrap;
    }
    .filter-group { display: flex; gap: 8px; }
    .filter-btn {
      padding: 8px 16px; border-radius: 20px; font-size: 13px; font-weight: 700;
      border: 1.5px solid var(--border); background: var(--white); cursor: pointer;
      color: var(--text-gray); transition: all .2s; font-family: 'Pretendard', sans-serif;
    }
    .filter-btn.active, .filter-btn:hover {
      border-color: var(--sky-blue); color: var(--sky-blue); background: #EBF8FF;
    }
    .search-box {
      display: flex; align-items: center; gap: 8px;
      background: var(--white); border: 1.5px solid var(--border);
      border-radius: 10px; padding: 8px 14px;
    }
    .search-box i { color: var(--text-gray); }
    .search-box input {
      border: none; outline: none; font-size: 13px; font-family: 'Pretendard', sans-serif;
      width: 200px; color: var(--text-black);
    }

    /* 테이블 */
    .inquiry-table-wrap {
      background: var(--white); border-radius: 16px;
      border: 1px solid var(--border); overflow: hidden;
    }
    .inquiry-table { width: 100%; border-collapse: collapse; }
    .inquiry-table thead tr {
      background: var(--bg); border-bottom: 1px solid var(--border);
    }
    .inquiry-table th {
      padding: 14px 20px; text-align: left;
      font-size: 12px; font-weight: 800; color: var(--text-gray);
      text-transform: uppercase; letter-spacing: .5px;
    }
    .inquiry-table td {
      padding: 16px 20px; font-size: 14px; color: var(--text-dark);
      border-bottom: 1px solid var(--border); vertical-align: middle;
    }
    .inquiry-table tr:last-child td { border-bottom: none; }
    .inquiry-table tr:hover td { background: #F7FCFF; }
    .inquiry-table tr { transition: background .15s; }

    .status-pill {
      display: inline-flex; align-items: center; gap: 5px;
      padding: 4px 10px; border-radius: 20px; font-size: 12px; font-weight: 800;
    }
    .status-pill.waiting  { background: #FFF3CD; color: #856404; }
    .status-pill.answered { background: #D1FAE5; color: #065F46; }
    .status-pill.closed   { background: #F3F4F6; color: #6B7280; }

    .category-pill {
      display: inline-block; padding: 3px 10px; border-radius: 8px;
      font-size: 11px; font-weight: 700; background: #EBF8FF; color: #2B6CB0;
    }

    .btn-view {
      padding: 6px 14px; border-radius: 8px; font-size: 12px; font-weight: 700;
      border: 1.5px solid var(--border); background: var(--white); cursor: pointer;
      color: var(--text-dark); transition: all .2s; font-family: 'Pretendard', sans-serif;
    }
    .btn-view:hover { border-color: var(--sky-blue); color: var(--sky-blue); }

    /* 페이지네이션 */
    .pagination {
      display: flex; justify-content: center; gap: 6px;
      padding: 20px 0 0;
    }
    .page-btn {
      width: 34px; height: 34px; border-radius: 8px; border: 1.5px solid var(--border);
      background: var(--white); font-size: 13px; font-weight: 700;
      cursor: pointer; display: flex; align-items: center; justify-content: center;
      color: var(--text-gray); transition: all .2s; font-family: 'Pretendard', sans-serif;
    }
    .page-btn.active { background: var(--sky-blue); border-color: var(--sky-blue); color: white; }
    .page-btn:hover:not(.active) { border-color: var(--sky-blue); color: var(--sky-blue); }

    /* 문의 상세 모달 */
    .modal-backdrop {
      position: fixed; inset: 0; background: rgba(0,0,0,.4);
      z-index: 9000; display: none; align-items: center; justify-content: center;
    }
    .modal-backdrop.open { display: flex; }
    .inquiry-modal {
      background: var(--white); border-radius: 20px; width: 600px; max-width: 90vw;
      max-height: 80vh; overflow-y: auto;
      box-shadow: 0 24px 48px rgba(0,0,0,.15);
      animation: modalIn .25s ease;
    }
    @keyframes modalIn {
      from { opacity: 0; transform: translateY(20px) scale(.97); }
      to   { opacity: 1; transform: translateY(0) scale(1); }
    }
    .modal-header {
      padding: 24px 28px 20px;
      border-bottom: 1px solid var(--border);
      display: flex; justify-content: space-between; align-items: flex-start;
    }
    .modal-header h3 { font-size: 16px; font-weight: 900; margin-bottom: 6px; }
    .modal-meta { display: flex; gap: 8px; align-items: center; flex-wrap: wrap; }
    .modal-body { padding: 24px 28px; }
    .modal-content-text {
      background: var(--bg); border-radius: 12px; padding: 18px;
      font-size: 14px; line-height: 1.7; color: var(--text-dark);
      margin-bottom: 20px; font-weight: 500;
    }
    .modal-reply-area h4 { font-size: 14px; font-weight: 800; margin-bottom: 10px; color: var(--text-black); }
    .modal-reply-area textarea {
      width: 100%; padding: 14px 16px; border: 1.5px solid var(--border);
      border-radius: 12px; font-size: 14px; font-family: 'Pretendard', sans-serif;
      resize: vertical; min-height: 100px; outline: none; line-height: 1.6;
      transition: border-color .2s;
    }
    .modal-reply-area textarea:focus { border-color: var(--sky-blue); }
    .modal-footer {
      padding: 16px 28px 24px;
      display: flex; justify-content: flex-end; gap: 10px;
    }
    .btn-cancel {
      padding: 10px 20px; border-radius: 10px; font-size: 14px; font-weight: 700;
      border: 1.5px solid var(--border); background: var(--white); cursor: pointer;
      color: var(--text-gray); font-family: 'Pretendard', sans-serif; transition: all .2s;
    }
    .btn-reply {
      padding: 10px 20px; border-radius: 10px; font-size: 14px; font-weight: 700;
      border: none; background: var(--grad-main); color: white; cursor: pointer;
      font-family: 'Pretendard', sans-serif; transition: all .2s;
    }
    .btn-reply:hover { opacity: .9; transform: translateY(-1px); }
    .btn-close-modal {
      width: 32px; height: 32px; border-radius: 50%; border: none;
      background: var(--bg); cursor: pointer; font-size: 16px;
      display: flex; align-items: center; justify-content: center;
      color: var(--text-gray); transition: all .2s; flex-shrink: 0;
    }
    .btn-close-modal:hover { background: var(--border); }

    /* 1:1 채팅 관리 */
    .chat-manage-layout {
      display: grid; grid-template-columns: 340px 1fr;
      flex: 1; height: calc(100vh - 130px);
    }

    /* 채팅 목록 패널 */
    .chat-list-panel {
      border-right: 1px solid var(--border);
      background: var(--white); display: flex; flex-direction: column;
    }
    .chat-list-header {
      padding: 20px; border-bottom: 1px solid var(--border);
    }
    .chat-list-header h3 {
      font-size: 15px; font-weight: 900; margin-bottom: 12px;
      display: flex; align-items: center; gap: 8px;
    }
    .chat-search {
      display: flex; align-items: center; gap: 8px;
      background: var(--bg); border-radius: 10px; padding: 8px 12px;
    }
    .chat-search i { color: var(--text-gray); font-size: 13px; }
    .chat-search input {
      border: none; background: none; outline: none;
      font-size: 13px; font-family: 'Pretendard', sans-serif; flex: 1;
    }
    .chat-room-items { flex: 1; overflow-y: auto; }
    .chat-room-item {
      padding: 16px 20px; border-bottom: 1px solid var(--border);
      cursor: pointer; transition: background .15s; display: flex; gap: 12px;
    }
    .chat-room-item:hover { background: #F7FCFF; }
    .chat-room-item.active { background: #EBF8FF; border-left: 3px solid var(--sky-blue); }
    .chat-room-item.unread { background: #FFF5F5; }
    .room-avatar {
      width: 40px; height: 40px; border-radius: 50%;
      background: var(--grad-main); display: flex; align-items: center;
      justify-content: center; font-size: 16px; flex-shrink: 0;
    }
    .room-info { flex: 1; min-width: 0; }
    .room-info-top {
      display: flex; justify-content: space-between; align-items: center; margin-bottom: 4px;
    }
    .room-user { font-size: 14px; font-weight: 800; color: var(--text-black); }
    .room-time { font-size: 11px; color: var(--text-gray); }
    .room-preview {
      font-size: 12px; color: var(--text-gray); font-weight: 500;
      white-space: nowrap; overflow: hidden; text-overflow: ellipsis;
    }
    .unread-badge {
      background: #FC8181; color: white; font-size: 10px; font-weight: 900;
      padding: 2px 6px; border-radius: 10px; flex-shrink: 0; align-self: center;
    }
    .chat-empty-list {
      flex: 1; display: flex; flex-direction: column;
      align-items: center; justify-content: center; gap: 10px;
      color: var(--text-gray); padding: 40px 20px; text-align: center;
    }
    .chat-empty-list i { font-size: 36px; opacity: .2; }
    .chat-empty-list p { font-size: 13px; font-weight: 600; }

    /* 채팅 뷰 패널 */
    .chat-view-panel { display: flex; flex-direction: column; background: var(--bg); }
    .chat-view-empty {
      flex: 1; display: flex; flex-direction: column;
      align-items: center; justify-content: center;
      gap: 12px; color: var(--text-gray);
    }
    .chat-view-empty i { font-size: 48px; opacity: .15; color: var(--sky-blue); }
    .chat-view-empty p { font-size: 14px; font-weight: 600; }

    .chat-view-header {
      padding: 16px 24px; background: var(--white);
      border-bottom: 1px solid var(--border);
      display: flex; justify-content: space-between; align-items: center;
    }
    .chat-view-header h3 { font-size: 15px; font-weight: 900; }
    .chat-view-header span { font-size: 12px; color: var(--text-gray); display: block; margin-top: 2px; }

    .chat-status-open   { background: #D1FAE5; color: #065F46; font-size: 11px; font-weight: 800; padding: 4px 12px; border-radius: 20px; }
    .chat-status-closed { background: #F3F4F6; color: #6B7280; font-size: 11px; font-weight: 800; padding: 4px 12px; border-radius: 20px; }

    .chat-messages-area {
      flex: 1; padding: 20px 24px; overflow-y: auto;
      display: flex; flex-direction: column; gap: 14px;
    }
    .msg-row { display: flex; gap: 10px; align-items: flex-end; }
    .msg-row.admin-msg { justify-content: flex-end; }
    .msg-avatar { width: 32px; height: 32px; border-radius: 50%; object-fit: cover; flex-shrink: 0; font-size: 14px; display: flex; align-items: center; justify-content: center; background: var(--grad-main); }
    .msg-bubble { max-width: 60%; padding: 10px 14px; border-radius: 16px; font-size: 13px; line-height: 1.5; font-weight: 600; word-break: break-word; }
    .msg-row.user-msg .msg-bubble  { background: var(--white); border-top-left-radius: 4px; box-shadow: 0 2px 6px rgba(0,0,0,.05); }
    .msg-row.admin-msg .msg-bubble { background: var(--grad-main); color: white; border-bottom-right-radius: 4px; }
    .msg-name { font-size: 11px; color: var(--text-gray); margin-bottom: 3px; font-weight: 700; }
    .msg-time { font-size: 10px; color: #A0AEC0; flex-shrink: 0; margin-bottom: 2px; }

    .chat-input-bar {
      padding: 14px 20px; background: var(--white);
      border-top: 1px solid var(--border);
      display: flex; gap: 10px; align-items: flex-end;
    }
    .admin-input {
      flex: 1; padding: 10px 16px; border: 1.5px solid var(--border);
      border-radius: 20px; font-size: 13px; font-family: 'Pretendard', sans-serif;
      outline: none; resize: none; max-height: 100px; line-height: 1.5;
      transition: border-color .2s;
    }
    .admin-input:focus { border-color: var(--sky-blue); }
    .btn-send {
      width: 40px; height: 40px; border-radius: 50%; border: none;
      background: var(--grad-main); color: white; cursor: pointer;
      display: flex; align-items: center; justify-content: center; flex-shrink: 0;
      transition: transform .2s;
    }
    .btn-send:hover { transform: scale(1.08); }
    .btn-send svg { width: 16px; height: 16px; fill: none; stroke: currentColor; stroke-width: 2.5; stroke-linecap: round; stroke-linejoin: round; margin-left: -2px; }
    .btn-end-chat {
      padding: 7px 14px; border-radius: 8px; font-size: 12px; font-weight: 800;
      border: 1.5px solid #FC8181; color: #FC8181; background: var(--white);
      cursor: pointer; transition: all .2s; font-family: 'Pretendard', sans-serif;
      flex-shrink: 0;
    }
    .btn-end-chat:hover { background: #FFF5F5; }
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
      <div class="page-header">
        <div class="page-header-left">
          <h1><i class="bi bi-headset"></i> 고객센터 관리</h1>
          <p>문의 게시판 및 1:1 채팅 상담을 관리합니다</p>
        </div>
      </div>

    <!-- 탭 -->
    <div class="cs-tabs">
      <button class="cs-tab active" onclick="switchTab('board', this)">
        <i class="bi bi-card-list"></i> 문의 게시판
        <span class="tab-badge" id="boardBadge">0</span>
      </button>
      <button class="cs-tab" onclick="switchTab('chat', this)">
        <i class="bi bi-chat-dots"></i> 1:1 채팅 상담
        <span class="tab-badge" id="chatBadge">0</span>
      </button>
    </div>

    <!-- 문의 게시판 -->
    <div class="tab-panel active" id="panel-board">
      <div class="inquiry-board">

        <div class="board-toolbar">
          <div class="filter-group">
            <button class="filter-btn active" onclick="filterInquiry('all', this)">전체</button>
            <button class="filter-btn" onclick="filterInquiry('waiting', this)">대기 중</button>
            <button class="filter-btn" onclick="filterInquiry('answered', this)">답변 완료</button>
            <button class="filter-btn" onclick="filterInquiry('closed', this)">종료</button>
          </div>
          <div class="search-box">
            <i class="bi bi-search"></i>
            <input type="text" placeholder="제목 또는 작성자 검색..." id="inquirySearch" oninput="searchInquiry(this.value)">
          </div>
        </div>

        <div class="inquiry-table-wrap">
          <table class="inquiry-table">
            <thead>
              <tr>
                <th>번호</th>
                <th>분류</th>
                <th>제목</th>
                <th>작성자</th>
                <th>작성일</th>
                <th>상태</th>
                <th>관리</th>
              </tr>
            </thead>
            <tbody id="inquiryTbody">
              <tr>
                <td colspan="7" style="text-align:center; padding:40px; color:var(--text-gray); font-size:13px;">
                  <i class="bi bi-inbox" style="font-size:24px; opacity:.3; display:block; margin-bottom:8px;"></i>
                  문의 내역을 불러오는 중...
                </td>
              </tr>
            </tbody>
          </table>
        </div>

        <div class="pagination" id="boardPagination"></div>
      </div>
    </div>

    <!-- 1:1 채팅 -->
    <div class="tab-panel" id="panel-chat">
      <div class="chat-manage-layout">

        <!-- 채팅 목록 -->
        <div class="chat-list-panel">
          <div class="chat-list-header">
            <h3><i class="bi bi-chat-heart" style="color:var(--sky-blue);"></i> 상담 목록</h3>
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

          <div id="chatViewMain" style="display:none; flex-direction:column; height:100%;">
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
              <button class="btn-send" onclick="sendAdminMsg()">
                <svg viewBox="0 0 24 24"><line x1="22" y1="2" x2="11" y2="13"></line><polygon points="22 2 15 22 11 13 2 9 22 2"></polygon></svg>
              </button>
            </div>
          </div>
        </div>

      </div>
    </div>
    </main>
	</div>
  </div>


<!-- 문의 상세 모달 -->
<div class="modal-backdrop" id="inquiryModal">
  <div class="inquiry-modal">
    <div class="modal-header">
      <div>
        <h3 id="modalTitle">문의 제목</h3>
        <div class="modal-meta">
          <span class="category-pill" id="modalCategory">결제</span>
          <span id="modalStatus" class="status-pill waiting">대기 중</span>
          <span style="font-size:12px; color:var(--text-gray);" id="modalDate"></span>
        </div>
      </div>
      <button class="btn-close-modal" onclick="closeModal()">✕</button>
    </div>
    <div class="modal-body">
      <div class="modal-content-text" id="modalContent"></div>
      <div class="modal-reply-area">
        <h4>📝 답변 작성</h4>
        <textarea id="modalReplyInput" placeholder="답변 내용을 입력하세요..."></textarea>
      </div>
    </div>
    <div class="modal-footer">
      <button class="btn-cancel" onclick="closeModal()">취소</button>
      <button class="btn-reply" onclick="submitReply()">답변 등록</button>
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
