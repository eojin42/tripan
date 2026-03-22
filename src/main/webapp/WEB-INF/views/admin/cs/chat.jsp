<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <title>Tripan 관리자 - 고객 상담</title>
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/gh/orioncactus/pretendard@v1.3.8/dist/web/static/pretendard.css">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
  <style>
    :root {
      --sky-blue: #89CFF0; --light-pink: #FFB6C1;
      --grad-main: linear-gradient(135deg, var(--sky-blue), var(--light-pink));
      --text-black: #2D3748; --text-dark: #4A5568; --text-gray: #718096;
      --border-light: #E2E8F0; --bg-page: #F7FAFC;
    }
    * { box-sizing: border-box; margin: 0; padding: 0; }
    body { font-family: 'Pretendard', sans-serif; background: var(--bg-page); color: var(--text-black); }

    .admin-chat-layout {
      display: grid;
      grid-template-columns: 320px 1fr;
      height: 100vh;
    }

    /* ── 왼쪽: 상담 목록 ── */
    .inquiry-list-panel {
      background: white;
      border-right: 1px solid var(--border-light);
      display: flex;
      flex-direction: column;
    }
    .panel-header {
      padding: 20px 20px 16px;
      border-bottom: 1px solid var(--border-light);
      background: white;
      position: sticky; top: 0;
    }
    .panel-header h2 {
      font-size: 18px; font-weight: 900; margin-bottom: 12px;
      display: flex; align-items: center; gap: 8px;
    }
    .panel-header h2 i { color: var(--sky-blue); }
    .badge-count {
      background: #FF6B6B; color: white; font-size: 11px; font-weight: 900;
      padding: 2px 8px; border-radius: 20px;
    }
    .inquiry-items {
      flex: 1; overflow-y: auto; padding: 12px;
      display: flex; flex-direction: column; gap: 6px;
    }
    .inquiry-item {
      padding: 14px 16px; border-radius: 14px; cursor: pointer;
      border: 1.5px solid var(--border-light); transition: all .2s;
      background: white;
    }
    .inquiry-item:hover { border-color: var(--sky-blue); background: #F0F8FF; }
    .inquiry-item.active {
      border-color: var(--sky-blue); background: #EBF8FF;
      box-shadow: 0 4px 12px rgba(137,207,240,.15);
    }
    .inquiry-item.unread { border-color: #FC8181; }
    .inquiry-top {
      display: flex; justify-content: space-between; align-items: center; margin-bottom: 6px;
    }
    .inquiry-user { font-size: 14px; font-weight: 800; color: var(--text-black); }
    .inquiry-time { font-size: 11px; color: var(--text-gray); font-weight: 500; }
    .inquiry-preview {
      font-size: 12px; color: var(--text-gray); font-weight: 500;
      white-space: nowrap; overflow: hidden; text-overflow: ellipsis;
    }
    .unread-dot {
      width: 8px; height: 8px; background: #FC8181; border-radius: 50%;
      display: inline-block; margin-left: 6px; flex-shrink: 0;
    }
    .empty-list {
      flex: 1; display: flex; flex-direction: column;
      align-items: center; justify-content: center;
      color: var(--text-gray); font-size: 13px; gap: 10px;
    }
    .empty-list i { font-size: 36px; opacity: .25; color: var(--sky-blue); }

    /* ── 오른쪽: 채팅 영역 ── */
    .chat-panel {
      display: flex; flex-direction: column; height: 100vh;
    }
    .chat-panel-header {
      padding: 16px 24px;
      background: white; border-bottom: 1px solid var(--border-light);
      display: flex; justify-content: space-between; align-items: center;
    }
    .chat-panel-header h3 { font-size: 16px; font-weight: 800; }
    .chat-panel-header span { font-size: 12px; color: var(--text-gray); margin-top: 3px; display: block; }
    .status-badge {
      font-size: 11px; font-weight: 800; padding: 4px 12px; border-radius: 20px;
      background: #C6F6D5; color: #276749;
    }
    .status-badge.closed { background: #FED7D7; color: #9B2C2C; }

    .admin-chat-messages {
      flex: 1; padding: 24px; overflow-y: auto;
      display: flex; flex-direction: column; gap: 16px;
      background: var(--bg-page);
    }

    /* 메시지 버블 (사용자) */
    .msg-row { display: flex; gap: 10px; align-items: flex-end; }
    .msg-row.admin-side { justify-content: flex-end; }
    .msg-profile {
      width: 34px; height: 34px; border-radius: 50%; object-fit: cover; flex-shrink: 0;
    }
    .msg-bubble {
      max-width: 65%; padding: 12px 16px; border-radius: 18px;
      font-size: 14px; line-height: 1.5; font-weight: 600;
      word-break: break-word;
    }
    .msg-row.user-side .msg-bubble {
      background: white; border-top-left-radius: 4px;
      box-shadow: 0 2px 8px rgba(0,0,0,.05);
    }
    .msg-row.admin-side .msg-bubble {
      background: var(--grad-main); color: white; border-bottom-right-radius: 4px;
    }
    .msg-name { font-size: 11px; color: var(--text-gray); margin-bottom: 4px; font-weight: 700; }
    .msg-time { font-size: 11px; color: #A0AEC0; font-weight: 500; margin-bottom: 4px; flex-shrink: 0; }

    /* 입력창 */
    .admin-input-area {
      padding: 16px 24px;
      background: white; border-top: 1px solid var(--border-light);
      display: flex; gap: 12px; align-items: flex-end;
    }
    .admin-chat-input {
      flex: 1; padding: 12px 18px; border: 1.5px solid var(--border-light);
      border-radius: 20px; font-size: 14px; font-family: 'Pretendard', sans-serif;
      outline: none; resize: none; max-height: 120px; line-height: 1.5;
      transition: border-color .2s;
    }
    .admin-chat-input:focus { border-color: var(--sky-blue); }
    .btn-admin-send {
      width: 44px; height: 44px; border-radius: 50%; border: none;
      background: var(--grad-main); color: white; cursor: pointer;
      display: flex; justify-content: center; align-items: center;
      flex-shrink: 0; transition: transform .2s;
    }
    .btn-admin-send:hover { transform: scale(1.08); }
    .btn-admin-send svg { width: 18px; height: 18px; fill: none; stroke: currentColor; stroke-width: 2.5; stroke-linecap: round; stroke-linejoin: round; margin-left: -2px; }

    /* 빈 상태 */
    .chat-empty {
      flex: 1; display: flex; flex-direction: column;
      align-items: center; justify-content: center;
      color: var(--text-gray); gap: 12px;
    }
    .chat-empty i { font-size: 48px; opacity: .2; color: var(--sky-blue); }
    .chat-empty p { font-size: 14px; font-weight: 600; }

    /* 상담 종료 버튼 */
    .btn-close-inquiry {
      padding: 7px 14px; border-radius: 10px; font-size: 12px; font-weight: 800;
      border: 1.5px solid #FC8181; color: #FC8181; background: white;
      cursor: pointer; transition: all .2s; font-family: 'Pretendard', sans-serif;
    }
    .btn-close-inquiry:hover { background: #FFF5F5; }

    /* 새 상담 알림 토스트 */
    .toast-notification {
      position: fixed; top: 20px; right: 20px; z-index: 9999;
      background: white; border-radius: 16px; padding: 16px 20px;
      box-shadow: 0 8px 24px rgba(0,0,0,.12); border-left: 4px solid var(--sky-blue);
      display: flex; align-items: center; gap: 12px;
      animation: slideIn .3s ease; min-width: 280px;
    }
    @keyframes slideIn {
      from { opacity: 0; transform: translateX(50px); }
      to   { opacity: 1; transform: translateX(0); }
    }
    .toast-icon { font-size: 24px; }
    .toast-text strong { display: block; font-size: 14px; font-weight: 800; margin-bottom: 2px; }
    .toast-text span   { font-size: 12px; color: var(--text-gray); font-weight: 500; }
  </style>
</head>
<body>

<div class="admin-chat-layout">

  <!-- ── 왼쪽: 상담 목록 ── -->
  <div class="inquiry-list-panel">
    <div class="panel-header">
      <h2>
        <i class="bi bi-headset"></i>
        고객 상담
        <span class="badge-count" id="unreadCount">0</span>
      </h2>
    </div>
    <div class="inquiry-items" id="inquiryList">
      <div class="empty-list">
        <i class="bi bi-chat-dots"></i>
        <p>상담 내역이 없습니다</p>
      </div>
    </div>
  </div>

  <!-- ── 오른쪽: 채팅 영역 ── -->
  <div class="chat-panel">

    <!-- 비어있을 때 -->
    <div class="chat-empty" id="adminChatEmpty">
      <i class="bi bi-chat-heart"></i>
      <p>좌측에서 상담을 선택하세요</p>
    </div>

    <!-- 채팅 뷰 -->
    <div id="adminChatView" style="display:none; flex-direction:column; height:100%;">
      <div class="chat-panel-header">
        <div>
          <h3 id="adminChatTitle">고객 상담</h3>
          <span id="adminChatSub"></span>
        </div>
        <div style="display:flex; gap:8px; align-items:center;">
          <span class="status-badge" id="adminStatusBadge">상담 중</span>
          <button class="btn-close-inquiry" onclick="closeInquiry()">상담 종료</button>
        </div>
      </div>
      <div class="admin-chat-messages" id="adminChatMessages"></div>
      <div class="admin-input-area">
        <textarea class="admin-chat-input" id="adminChatInput"
                  placeholder="답변을 입력하세요... (Enter: 전송, Shift+Enter: 줄바꿈)"
                  rows="1"></textarea>
        <button class="btn-admin-send" onclick="sendAdminMessage()">
          <svg viewBox="0 0 24 24"><line x1="22" y1="2" x2="11" y2="13"></line><polygon points="22 2 15 22 11 13 2 9 22 2"></polygon></svg>
        </button>
      </div>
    </div>

  </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/sockjs-client@1/dist/sockjs.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/stomp.js/2.3.3/stomp.min.js"></script>
<script>
  const ctxPath    = '${pageContext.request.contextPath}';
  const adminId    = '${sessionScope.loginUser.memberId}';
  const adminNick  = '${sessionScope.loginUser.nickname}' || '관리자';

  let stompClient     = null;
  let currentRoomId   = null;
  let subscribedRooms = new Set(); // 알림용 구독 방 목록

  // ── 상담 목록 로드 ──
  async function loadInquiryList() {
    try {
      const res   = await fetch(`${ctxPath}/api/admin/chat/rooms/support`);
      const rooms = await res.json();

      const listEl      = document.getElementById('inquiryList');
      const unreadBadge = document.getElementById('unreadCount');

      if (!rooms || rooms.length === 0) {
        listEl.innerHTML = `
          <div class="empty-list">
            <i class="bi bi-chat-dots"></i>
            <p>상담 내역이 없습니다</p>
          </div>`;
        unreadBadge.textContent = '0';
        return;
      }

      listEl.innerHTML = '';
      let unread = 0;

      rooms.forEach(room => {
        if (room.hasUnread) unread++;

        const div = document.createElement('div');
        div.className = `inquiry-item${room.hasUnread ? ' unread' : ''}`;
        div.dataset.roomId = room.chatRoomId;
        div.innerHTML = `
          <div class="inquiry-top">
            <span class="inquiry-user">
              👤 ${escHtml(room.userName || '사용자')}
              ${room.hasUnread ? '<span class="unread-dot"></span>' : ''}
            </span>
            <span class="inquiry-time">${formatTime(room.createdAt)}</span>
          </div>
          <div class="inquiry-preview">${escHtml(room.lastMessage || '대화를 시작해보세요')}</div>`;

        div.addEventListener('click', () => enterRoom(room));
        listEl.appendChild(div);

        // 알림용 구독 (아직 구독 안 한 방)
        subscribeForNotification(room.chatRoomId);
      });

      unreadBadge.textContent = unread;

    } catch (e) {
      console.error('상담 목록 로드 실패:', e);
    }
  }

  // ── 채팅방 입장 ──
  function enterRoom(room) {
    document.querySelectorAll('.inquiry-item').forEach(el => el.classList.remove('active', 'unread'));
    document.querySelector(`[data-room-id="${room.chatRoomId}"]`)?.classList.add('active');

    currentRoomId = room.chatRoomId;

    document.getElementById('adminChatEmpty').style.display = 'none';
    const viewEl = document.getElementById('adminChatView');
    viewEl.style.display = 'flex';

    document.getElementById('adminChatTitle').textContent = `🎧 ${room.nickname || '사용자'} 님의 상담`;
    document.getElementById('adminChatSub').textContent   = `문의 시작: ${formatTime(room.createdAt)}`;

    // 이전 연결 끊기
    if (stompClient && stompClient.connected) {
      stompClient.disconnect(() => connectAdminRoom(room.chatRoomId));
    } else {
      connectAdminRoom(room.chatRoomId);
    }
  }

  // ── 웹소켓 연결 ──
  function connectAdminRoom(roomId) {
    const socket = new SockJS(`${ctxPath}/ws-tripan`);
    stompClient  = Stomp.over(socket);
    stompClient.debug = null;

    stompClient.connect({}, () => {
      stompClient.subscribe(`/sub/chat/room/${roomId}`, (frame) => {
        const data = JSON.parse(frame.body);
        renderAdminMessage(data);
      });

      document.getElementById('adminChatMessages').innerHTML = '';
    });
  }

  // ── 알림용 구독 (목록 자동 갱신) ──
  function subscribeForNotification(roomId) {
    if (subscribedRooms.has(roomId)) return;
    subscribedRooms.add(roomId);

    // 관리자 알림 전용 채널
    if (stompClient && stompClient.connected) {
      stompClient.subscribe(`/sub/admin/chat/new`, (frame) => {
        const data = JSON.parse(frame.body);
        showToast(`새 문의가 도착했습니다`, `${data.userName || '사용자'}님이 상담을 요청했습니다.`);
        loadInquiryList(); // 목록 새로고침
      });
    }
  }

  // ── 메시지 전송 ──
  function sendAdminMessage() {
    const input = document.getElementById('adminChatInput');
    const msg   = input.value.trim();
    if (!msg || !currentRoomId || !stompClient || !stompClient.connected) return;

    stompClient.send('/pub/chat/message', {}, JSON.stringify({
      roomId          : currentRoomId,
      memberId        : adminId,
      senderNickname  : adminNick,
      content         : msg,
      messageType     : 'TALK'
    }));
    input.value = '';
    input.style.height = 'auto';
  }

  // ── 메시지 렌더링 ──
  function renderAdminMessage(data) {
    const list  = document.getElementById('adminChatMessages');
    const isMe  = (String(data.memberId) === String(adminId));

    const row   = document.createElement('div');
    row.className = `msg-row ${isMe ? 'admin-side' : 'user-side'}`;
    row.innerHTML = isMe
      ? `<span class="msg-time">${data.createdAt || ''}</span>
         <div class="msg-bubble">${escHtml(data.content)}</div>`
      : `<img src="https://picsum.photos/seed/${data.memberId}/50/50" class="msg-profile" alt="">
         <div>
           <div class="msg-name">👤 ${escHtml(data.senderNickname)}</div>
           <div class="msg-bubble">${escHtml(data.content)}</div>
         </div>
         <span class="msg-time">${data.createdAt || ''}</span>`;

    list.appendChild(row);
    list.scrollTop = list.scrollHeight;
  }

  // ── 상담 종료 ──
  async function closeInquiry() {
    if (!currentRoomId) return;
    if (!confirm('상담을 종료하시겠습니까?')) return;

    try {
      await fetch(`${ctxPath}/api/admin/chat/rooms/${currentRoomId}/close`, { method: 'POST' });
      document.getElementById('adminStatusBadge').textContent = '상담 종료';
      document.getElementById('adminStatusBadge').classList.add('closed');
      if (stompClient) stompClient.disconnect();
      loadInquiryList();
    } catch (e) {
      alert('상담 종료에 실패했습니다.');
    }
  }

  // ── 새 상담 토스트 알림 ──
  function showToast(title, body) {
    const toast = document.createElement('div');
    toast.className = 'toast-notification';
    toast.innerHTML = `
      <span class="toast-icon">🎧</span>
      <div class="toast-text">
        <strong>${escHtml(title)}</strong>
        <span>${escHtml(body)}</span>
      </div>`;
    document.body.appendChild(toast);
    setTimeout(() => toast.remove(), 4000);
  }

  // ── 유틸 ──
  function escHtml(s) {
    if (!s) return '';
    return String(s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;');
  }
  function formatTime(v) {
    if (!v) return '';
    return new Date(v).toLocaleDateString('ko-KR', { month:'2-digit', day:'2-digit', hour:'2-digit', minute:'2-digit' });
  }

  // ── textarea 자동 높이 조절 + Enter 전송 ──
  const inputEl = document.getElementById('adminChatInput');

	inputEl.addEventListener('input', function() {
	  this.style.height = 'auto';
	  this.style.height = Math.min(this.scrollHeight, 120) + 'px';
	});
	
	inputEl.addEventListener('keydown', function(e) {
	  // 한글 조합 중 엔터 방지
	  if (e.isComposing || e.keyCode === 229) return;
	
	  if (e.key === 'Enter' && !e.shiftKey) {
	    e.preventDefault();
	    sendAdminMessage();
	  }
	});

  // ── 초기 로드 + 30초마다 목록 갱신 ──
  loadInquiryList();
  setInterval(loadInquiryList, 30000);
</script>
</body>
</html>
