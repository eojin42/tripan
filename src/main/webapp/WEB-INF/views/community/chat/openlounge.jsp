<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>

<style>
  /* ── 채팅 모달 ── */
  .global-chat-wrapper {
    position: fixed; bottom: 50px; right: 30px;
    z-index: 10000; display: none;
    flex-direction: column; align-items: flex-end;
  }
  .chat-modal-container {
    width: 950px; height: 700px; max-width: 90vw;
    background: rgba(255,255,255,0.75);
    backdrop-filter: blur(24px); -webkit-backdrop-filter: blur(24px);
    border: 1px solid rgba(255,255,255,0.9); border-radius: 28px;
    box-shadow: 0 24px 48px rgba(45,55,72,0.15);
    display: flex; overflow: hidden;
    transform-origin: bottom right;
    animation: chatPopUp 0.3s cubic-bezier(0.34,1.56,0.64,1) forwards;
  }
  @keyframes chatPopUp {
    0%   { opacity:0; transform:scale(0.8); }
    100% { opacity:1; transform:scale(1); }
  }
  .chat-sidebar {
    width: 300px; background: rgba(255,255,255,0.4);
    border-right: 1px solid rgba(255,255,255,0.6);
    display: flex; flex-direction: column;
  }
  .chat-sidebar-header {
    padding: 20px; padding-bottom: 0;
    border-bottom: 1px solid rgba(255,255,255,0.5);
  }
  .chat-sidebar-header h3 { margin:0 0 12px; font-size:16px; font-weight:900; color:var(--text-black); }
  .chat-room-list {
    flex:1; overflow-y:auto; padding:12px;
    display:flex; flex-direction:column; gap:8px;
  }
  .chat-room-list::-webkit-scrollbar { display:none; }
  .chat-room-item {
    display:flex; align-items:center; gap:12px;
    padding:12px; border-radius:16px; cursor:pointer;
    transition:all 0.2s; background:transparent;
  }
  .chat-room-item:hover  { background:rgba(255,255,255,0.7); }
  .chat-room-item.active { background:white; box-shadow:0 4px 12px rgba(0,0,0,0.05); }
  .room-icon {
    width:40px; height:40px; border-radius:12px;
    background:var(--grad-main); color:white;
    display:flex; justify-content:center; align-items:center; font-size:18px;
    flex-shrink:0;
  }
  .room-info h4 { margin:0 0 4px; font-size:14px; font-weight:800; color:var(--text-dark); }
  .room-info p  { margin:0; font-size:12px; color:var(--text-gray); font-weight:500; }
  .chat-main { flex:1; display:flex; flex-direction:column; background:transparent; }
  .chat-header {
    padding:16px 20px; border-bottom:1px solid rgba(255,255,255,0.6);
    display:flex; justify-content:space-between; align-items:center;
  }
  .chat-title-info h2 { margin:0 0 6px; font-size:18px; font-weight:900; }
  .chat-title-info span { font-size:12px; font-weight:700; color:#FF6B6B; background:#FFE5E5; padding:3px 8px; border-radius:12px; }
  .chat-controls { display:flex; gap:8px; }
  .chat-control-btn {
    width:32px; height:32px; border-radius:50%;
    border:none; background:rgba(255,255,255,0.6);
    color:var(--text-dark); font-size:16px; font-weight:900; cursor:pointer;
    display:flex; justify-content:center; align-items:center; transition:0.2s;
  }
  .chat-control-btn:hover { background:var(--text-black); color:white; }
  .chat-messages {
    flex:1; padding:20px; overflow-y:auto;
    display:flex; flex-direction:column; gap:16px;
  }
  .msg-row { display:flex; gap:10px; align-items:flex-end; }
  .msg-row.me { justify-content:flex-end; }
  .msg-profile { width:36px; height:36px; border-radius:50%; object-fit:cover; }
  .msg-bubble {
    max-width:75%; padding:12px 16px; border-radius:20px;
    font-size:14px; line-height:1.5; font-weight:600;
    box-shadow:0 4px 12px rgba(0,0,0,0.03);
  }
  .msg-row.other .msg-bubble { background:white; border-top-left-radius:4px; color:var(--text-black); }
  .msg-row.me    .msg-bubble { background:var(--grad-main); color:white; border-bottom-right-radius:4px; }
  .msg-name { font-size:12px; color:var(--text-gray); margin-bottom:4px; font-weight:700; }
  .msg-time { font-size:11px; color:#A0AEC0; font-weight:600; margin-bottom:4px; }
  .chat-input-area {
    padding:16px; background:rgba(255,255,255,0.4);
    border-top:1px solid rgba(255,255,255,0.6); display:flex; gap:12px;
  }
  .chat-input {
    flex:1; padding:12px 20px; border:none; border-radius:24px;
    background:rgba(255,255,255,0.9); font-size:14px; outline:none;
    transition:0.3s; font-family:'Pretendard',sans-serif;
    box-shadow:0 0 0 2px var(--sky-blue);
  }
  .btn-send {
    width:44px; height:44px; border-radius:50%; border:none;
    background:var(--grad-main); color:white; cursor:pointer;
    display:flex; justify-content:center; align-items:center; transition:0.2s;
  }
  .btn-send:hover { transform:scale(1.05); }
  .btn-send svg { width:18px; height:18px; fill:none; stroke:currentColor; stroke-width:2.5; stroke-linecap:round; stroke-linejoin:round; margin-left:-2px; }

  /* ── 최소화 플로팅 버튼 ── */
  .chat-floating-btn {
    position:fixed; bottom:30px; right:30px;
    width:64px; height:64px; border-radius:50%;
    background:white; box-shadow:0 8px 24px rgba(45,55,72,0.15);
    display:none; justify-content:center; align-items:center;
    cursor:pointer; z-index:10000; border:2px solid var(--sky-blue);
    transition:transform 0.3s cubic-bezier(0.34,1.56,0.64,1);
  }
  .chat-floating-btn:hover { transform:translateY(-5px) scale(1.05); }
  .chat-floating-btn img { width:40px; height:40px; object-fit:contain; }
  .chat-badge {
    position:absolute; top:-2px; right:-2px;
    background:#FF6B6B; color:white; font-size:11px; font-weight:900;
    width:20px; height:20px; border-radius:50%;
    display:flex; justify-content:center; align-items:center; border:2px solid white;
  }

  /* ── 탭 ── */
  .chat-tabs { display:flex; gap:12px; padding-top:12px; overflow-x:auto; }
  .chat-tabs::-webkit-scrollbar { display:none; }
  .chat-tab {
    background:none; border:none; font-size:13px; font-weight:800;
    color:var(--text-gray); padding-bottom:8px; cursor:pointer;
    border-bottom:3px solid transparent; transition:0.2s; white-space:nowrap; flex-shrink:0;
  }
  .chat-tab.active { color:var(--sky-blue); border-bottom-color:var(--sky-blue); }

  /* ── 배경 오버레이 (모달 밖 클릭 닫기) ── */
  #chatBackdrop {
    display:none; position:fixed; inset:0; z-index:9999;
  }

  /* ── 마이페이지 헤드셋 FAB ── */
  #mypageChatFab {
    display:none;
    position:fixed; bottom:40px; right:40px; z-index:10001;
    width:64px; height:64px; border-radius:50%;
    background:var(--grad-main); color:white; font-size:26px;
    border:none; box-shadow:0 8px 24px rgba(255,182,193,0.5);
    cursor:pointer; transition:transform 0.3s cubic-bezier(0.34,1.56,0.64,1);
    justify-content:center; align-items:center;
  }
  #mypageChatFab:hover { transform:translateY(-5px) scale(1.05); }
</style>

<%-- 배경 오버레이: 클릭 시 모달 닫기 --%>
<div id="chatBackdrop" onclick="window._chatClose()"></div>

<%-- 채팅 모달 --%>
<div id="globalChatModal" class="global-chat-wrapper">
  <div class="chat-modal-container">

    <div class="chat-sidebar">
      <div class="chat-sidebar-header">
        <h3>채팅 목록</h3>
        <div class="chat-tabs">
          <button id="tabRegion"  class="chat-tab active" onclick="window.loadRoomList('REGION')">🌍 라운지</button>
          <button id="tabPrivate" class="chat-tab"        onclick="window.loadRoomList('PRIVATE')">💬 1:1 대화</button>
          <button id="tabCS"      class="chat-tab"        onclick="window.loadRoomList('CS')" style="display:none;">🎧 고객센터</button>
        </div>
      </div>
      <div class="chat-room-list" id="dynamicChatRoomList"></div>
    </div>

    <div class="chat-main" style="position:relative;">

      <div id="chatEmptyState" style="width:100%;height:100%;display:flex;flex-direction:column;justify-content:center;align-items:center;text-align:center;">
        <div class="chat-controls" style="position:absolute;top:16px;right:20px;">
          <button class="chat-control-btn" onclick="window._chatMinimize()">_</button>
          <button class="chat-control-btn" onclick="window._chatClose()">✕</button>
        </div>
        <span style="font-size:54px;margin-bottom:20px;opacity:0.6;">💬</span>
        <h3 style="color:var(--text-dark);margin:0 0 10px;font-size:20px;">입장할 채팅방을 선택해주세요</h3>
        <p style="color:var(--text-gray);font-size:14px;font-weight:500;">좌측 목록에서 참여하고 싶은 채팅방을 클릭하세요.</p>
      </div>

      <div id="chatRoomView" style="display:none;flex-direction:column;height:100%;">
        <div class="chat-header">
          <div class="chat-title-info">
            <h2 id="chatRoomTitle">💬 채팅방</h2>
            <span id="chatRoomCountBadge" style="display:none;">🔴 접속 중</span>
          </div>
          <div class="chat-controls">
            <button class="chat-control-btn" onclick="window._chatMinimize()" title="최소화">_</button>
            <button class="chat-control-btn" onclick="window._chatClose()" title="닫기">✕</button>
          </div>
        </div>
        <div class="chat-messages" id="chatMessagesArea"></div>
        <div class="chat-input-area">
          <input type="text" id="chatInputField" class="chat-input" placeholder="메시지를 입력하세요...">
          <button class="btn-send" id="chatSendBtn">
            <svg viewBox="0 0 24 24"><line x1="22" y1="2" x2="11" y2="13"></line><polygon points="22 2 15 22 11 13 2 9 22 2"></polygon></svg>
          </button>
        </div>
      </div>

    </div>
  </div>
</div>

<%-- 최소화 플로팅 버튼 --%>
<div id="chatFloatingBtn" class="chat-floating-btn" title="채팅 열기">
  <span class="chat-badge">3</span>
  <img src="${pageContext.request.contextPath}/dist/images/logo.png" alt="Tripan Chat"
       onerror="this.src='https://cdn-icons-png.flaticon.com/512/1041/1041916.png'">
</div>

<%-- 마이페이지 전용 헤드셋 FAB (JS가 /mypage URL 감지 시 자동 표시) --%>
<button id="mypageChatFab" title="1:1 고객센터 문의">
  <i class="bi bi-headset"></i>
</button>

<script src="https://cdn.jsdelivr.net/npm/sockjs-client@1/dist/sockjs.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/stomp.js/2.3.3/stomp.min.js"></script>
<script>
(function() { 

  var memberId       = "${sessionScope.loginUser.memberId}";
  var senderNickname = "${sessionScope.loginUser.nickname}";
  var ctxPath = (typeof contextPath !== 'undefined') ? contextPath : "${pageContext.request.contextPath}";

  var chatModal   = document.getElementById("globalChatModal");
  var floatingBtn = document.getElementById("chatFloatingBtn");
  var backdrop    = document.getElementById("chatBackdrop");
  var fabBtn      = document.getElementById("mypageChatFab");
  var emptyState  = document.getElementById('chatEmptyState');
  var roomView    = document.getElementById('chatRoomView');
  var msgArea     = document.getElementById('chatMessagesArea');
  var inputField  = document.getElementById('chatInputField');
  var sendBtn     = document.getElementById('chatSendBtn');

  var stompClient   = null;
  var currentRoomId = null;
  var isConnecting  = false;
  var _subs         = []; 

  // 열기/닫기/최소화
  function _show() {
    chatModal.style.display   = "flex";
    floatingBtn.style.display = "none";
    backdrop.style.display    = "block";
    sessionStorage.setItem("tripanChatState", "opened");
  }

  window._chatClose = function() {
    chatModal.style.display   = "none";
    floatingBtn.style.display = "none";
    backdrop.style.display    = "none";
    sessionStorage.setItem("tripanChatState", "closed");
  };

  window._chatMinimize = function() {
    chatModal.style.display   = "none";
    floatingBtn.style.display = "flex";
    backdrop.style.display    = "none";
    sessionStorage.setItem("tripanChatState", "minimized");
  };

  window.openGlobalChat = _show;

  // sessionStorage 복원
  var savedState = sessionStorage.getItem("tripanChatState");
  if      (savedState === "opened")    { _show(); }
  else if (savedState === "minimized") { floatingBtn.style.display = "flex"; }

  floatingBtn.addEventListener("click", _show);

  //  mypage 경로면 헤드셋 FAB + 고객센터 탭 표시
  if (window.location.pathname.indexOf('/mypage') !== -1) {
    fabBtn.style.display = "flex";
    var tabCS = document.getElementById('tabCS');
    if (tabCS) tabCS.style.display = 'inline-block';

    fabBtn.addEventListener("click", function() {
      _show();
      window.loadRoomList('CS');
    });
  }

  // ── 방 목록 로드 ──
  window.loadRoomList = function(type) {
    document.querySelectorAll('.chat-tab').forEach(function(t) { t.classList.remove('active'); });

    var isCS = (type === 'CS' || type === 'SUPPORT');
    var url  = ctxPath;

    if (type === 'REGION') {
      document.getElementById('tabRegion').classList.add('active');
      url += '/api/chat/rooms/region';
    } else if (isCS) {
      var tabCS = document.getElementById('tabCS');
      if (tabCS) { tabCS.style.display = 'inline-block'; tabCS.classList.add('active'); }
      url += '/api/chat/rooms/support';
    } else {
      document.getElementById('tabPrivate').classList.add('active');
      url += '/api/chat/rooms/private';
    }

    var listEl = document.getElementById('dynamicChatRoomList');
    listEl.innerHTML = '<p style="text-align:center;font-size:12px;color:var(--text-gray);margin-top:20px;">불러오는 중...</p>';

    fetch(url)
      .then(function(res) {
        if (!res.ok) throw new Error(res.status);
        return res.json();
      })
      .then(function(rooms) {
        listEl.innerHTML = '';

        if (!rooms || rooms.length === 0) {
          if (isCS) {
            listEl.innerHTML =
              '<div style="text-align:center;margin-top:40px;">' +
              '<span style="font-size:32px;opacity:0.5;">🎧</span>' +
              '<p style="font-size:13px;color:var(--text-gray);margin:10px 0;">진행 중인 문의 내역이 없습니다.</p>' +
              '<button onclick="window.createSupportRoom()" style="padding:10px 20px;border-radius:20px;background:var(--text-black);color:white;border:none;font-weight:800;cursor:pointer;font-size:13px;">+ 1:1 문의 시작하기</button>' +
              '</div>';
          } else {
            listEl.innerHTML = '<p style="text-align:center;font-size:12px;color:var(--text-gray);margin-top:20px;">참여 중인 대화방이 없습니다.</p>';
          }
          return;
        }

        var rIcons = ['🌴','🌊','🏔️','🌃','🎎'];
        var pIcons = ['👤','😎','👨‍🚀','👩‍🎤','👽'];

        rooms.forEach(function(room, idx) {
          var icon  = isCS ? '🎧' : (type === 'REGION' ? rIcons[idx%5] : pIcons[idx%5]);
          var title = room.chatRoomName || '이름 없음';
          var desc  = isCS ? ('1:1 고객센터 · ' + (room.status === 'CLOSED' ? '종료' : '상담 중'))
                    : (type === 'REGION' ? '다같이 떠드는 라운지' : '1:1 비밀 대화방');
          listEl.insertAdjacentHTML('beforeend',
            '<div class="chat-room-item" onclick="window._onRoomClick(this)"' +
            ' data-room-id="' + room.chatRoomId +
            '" data-room-name="' + title + '" data-room-type="' + type + '">' +
            '<div class="room-icon">' + icon + '</div>' +
            '<div class="room-info"><h4>' + title + '</h4><p>' + desc + '</p></div></div>');
        });

      })
      .catch(function(e) {
        listEl.innerHTML = '<p style="text-align:center;font-size:12px;color:#FC8181;margin-top:20px;">목록을 불러오지 못했습니다.<br><small>' + e + '</small></p>';
      });
  };

  if (memberId) window.loadRoomList('REGION');

  window._onRoomClick = function(item) {
    document.querySelectorAll('.chat-room-item').forEach(function(el) { el.classList.remove('active'); });
    item.classList.add('active');
    emptyState.style.display = 'none';
    roomView.style.display   = 'flex';

    var rId   = item.getAttribute('data-room-id');
    var rName = item.getAttribute('data-room-name');
    var rType = item.getAttribute('data-room-type');
    var cs    = (rType === 'CS' || rType === 'SUPPORT');

    document.getElementById('chatRoomTitle').innerText =
      (rType === 'REGION' ? '🌴 #' : cs ? '🎧 ' : '💬 @') + rName;

    var badge = document.getElementById('chatRoomCountBadge');
    if (badge) {
      badge.style.display = rType === 'REGION' ? 'inline-block' : 'none';
      if (rType === 'REGION') badge.innerText = '🔴 인원 확인 중...';
    }

    window.connectChatRoom(rId);
  };

  // 고객센터 방 생성
  window.createSupportRoom = function() {
    if (!confirm('1:1 고객센터 문의를 시작하시겠습니까?')) return;
    fetch(ctxPath + '/api/chat/rooms/support/create', { method: 'POST' })
      .then(function(res) { if (!res.ok) throw new Error(); return res.json(); })
      .then(function() { window.loadRoomList('CS'); })
      .catch(function() { alert('방 생성에 실패했습니다.'); });
  };

  // 메시지 전송
  sendBtn.addEventListener('click', sendMessage);
  inputField.addEventListener('keypress', function(e) { if (e.key === 'Enter') sendMessage(); });

  function sendMessage() {
    var content = inputField.value.trim();
    if (content && stompClient && stompClient.connected) {
      stompClient.send("/pub/chat/message", {}, JSON.stringify({
        roomId: currentRoomId, memberId: memberId,
        senderNickname: senderNickname, content: content, messageType: 'TALK'
      }));
      inputField.value = '';
    }
  }

  // WebSocket 연결
  window.connectChatRoom = function(roomId) {
    if (!memberId) {
      if (typeof showLoginModal === 'function') showLoginModal();
      else alert("로그인이 필요한 서비스입니다.");
      return;
    }

    // 같은 방에 이미 연결됐거나 연결 중이면 무시
    if (isConnecting) return;
    if (currentRoomId === String(roomId) && stompClient && stompClient.connected) return;

    isConnecting  = true;
    currentRoomId = String(roomId);

    msgArea.innerHTML =
      '<div style="text-align:center;margin:20px 0;">' +
      '<span style="background:rgba(0,0,0,0.08);color:var(--text-gray);font-size:12px;padding:6px 16px;border-radius:16px;font-weight:600;">' +
      '🎉 채팅방에 입장했습니다. 매너 채팅 부탁드려요!</span></div>';

    function _doConnect() {
      var socket = new SockJS(ctxPath + '/ws-tripan');
      stompClient = Stomp.over(socket);
      stompClient.debug = null;
      stompClient.connect({}, function() {
        isConnecting = false;
        // 이전 구독 전부 해제
        _subs.forEach(function(s) { try { s.unsubscribe(); } catch(e) {} });
        _subs = [];
        // 새 구독 등록 및 저장
        _subs.push(stompClient.subscribe('/sub/chat/room/' + roomId + '/count', function(msg) {
          var b = document.getElementById('chatRoomCountBadge');
          if (b) b.innerText = '🔴 ' + msg.body + '명 접속 중';
        }));
        _subs.push(stompClient.subscribe('/sub/chat/room/' + roomId, function(frame) {
          renderMessage(JSON.parse(frame.body));
        }));
      }, function() {
        isConnecting = false;
      });
    }

    if (stompClient && stompClient.connected) {
      stompClient.disconnect(function() {
        stompClient = null;
        _doConnect();
      });
    } else {
      stompClient = null;
      _doConnect();
    }
  };

  function renderMessage(m) {
    var isMe = (String(m.memberId) === String(memberId));
    var row  = document.createElement('div');
    row.className = 'msg-row ' + (isMe ? 'me' : 'other');
    row.innerHTML = isMe
      ? '<span class="msg-time" style="white-space:nowrap;">' + (m.createdAt||'') + '</span>' +
        '<div class="msg-bubble" style="max-width:70%;word-break:break-word;white-space:pre-wrap;">' + (m.content||'') + '</div>'
      : '<img src="https://picsum.photos/seed/' + m.memberId + '/100/100" class="msg-profile" alt="">' +
        '<div style="max-width:70%;min-width:0;"><div class="msg-name">@' + (m.senderNickname||'') + '</div>' +
        '<div class="msg-bubble" style="word-break:break-word;white-space:pre-wrap;min-width:60px;">' + (m.content||'') + '</div></div>' +
        '<span class="msg-time" style="white-space:nowrap;">' + (m.createdAt||'') + '</span>';
    msgArea.appendChild(row);
    msgArea.scrollTop = msgArea.scrollHeight;
  }

  // 외부에서 특정 방 바로 열기
  window.forceOpenChat = function(roomId, type) {
    _show();
    window.loadRoomList(type || 'PRIVATE');
    setTimeout(function() {
      var item = document.querySelector('.chat-room-item[data-room-id="' + roomId + '"]');
      if (item) item.click();
    }, 400);
  };

})(); 
</script>
