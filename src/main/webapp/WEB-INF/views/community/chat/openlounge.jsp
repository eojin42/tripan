<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>

<style>
  .global-chat-wrapper {
    position: fixed;
    bottom: 50px; 
    right: 30px;
    z-index: 9999;
    display: none; 
    flex-direction: column;
    align-items: flex-end;
  }

  .chat-modal-container {
    width: 950px;
    height: 700px;
    max-width: 90vw;
    background: rgba(255, 255, 255, 0.75);
    backdrop-filter: blur(24px);
    -webkit-backdrop-filter: blur(24px);
    border: 1px solid rgba(255, 255, 255, 0.9);
    border-radius: 28px;
    box-shadow: 0 24px 48px rgba(45, 55, 72, 0.15);
    display: flex;
    overflow: hidden;
    transform-origin: bottom right;
    animation: chatPopUp 0.3s cubic-bezier(0.34, 1.56, 0.64, 1) forwards;
  }

  @keyframes chatPopUp {
    0% { opacity: 0; transform: scale(0.8); }
    100% { opacity: 1; transform: scale(1); }
  }

  .chat-sidebar {
    width: 300px;
    background: rgba(255, 255, 255, 0.4);
    border-right: 1px solid rgba(255, 255, 255, 0.6);
    display: flex;
    flex-direction: column;
  }
  
  .chat-sidebar-header {
    padding: 20px;
    border-bottom: 1px solid rgba(255, 255, 255, 0.5);
  }
  .chat-sidebar-header h3 {
    margin: 0; font-size: 16px; font-weight: 900; color: var(--text-black);
  }

  .chat-room-list {
    flex: 1;
    overflow-y: auto;
    padding: 12px;
    display: flex;
    flex-direction: column;
    gap: 8px;
  }
  .chat-room-list::-webkit-scrollbar { display: none; }

  .chat-room-item {
    display: flex; align-items: center; gap: 12px;
    padding: 12px; border-radius: 16px; cursor: pointer;
    transition: all 0.2s; background: transparent;
  }
  .chat-room-item:hover { background: rgba(255,255,255,0.7); }
  .chat-room-item.active { background: white; box-shadow: 0 4px 12px rgba(0,0,0,0.05); }
  
  .room-icon {
    width: 40px; height: 40px; border-radius: 12px;
    background: var(--grad-main); color: white;
    display: flex; justify-content: center; align-items: center; font-size: 18px;
  }
  .room-info h4 { margin: 0 0 4px; font-size: 14px; font-weight: 800; color: var(--text-dark); }
  .room-info p { margin: 0; font-size: 12px; color: var(--text-gray); font-weight: 500; }

  .chat-main {
    flex: 1;
    display: flex;
    flex-direction: column;
    background: transparent;
  }

  .chat-header {
    padding: 16px 20px;
    border-bottom: 1px solid rgba(255,255,255,0.6);
    display: flex; justify-content: space-between; align-items: center;
  }
  .chat-title-info h2 { margin: 0 0 6px; font-size: 18px; font-weight: 900; }
  .chat-title-info span { font-size: 12px; font-weight: 700; color: #FF6B6B; background: #FFE5E5; padding: 3px 8px; border-radius: 12px; }

  .chat-controls { display: flex; gap: 8px; }
  .chat-control-btn {
    width: 32px; height: 32px; border-radius: 50%;
    border: none; background: rgba(255,255,255,0.6);
    color: var(--text-dark); font-size: 16px; font-weight: 900; cursor: pointer;
    display: flex; justify-content: center; align-items: center; transition: 0.2s;
  }
  .chat-control-btn:hover { background: var(--text-black); color: white; }
  .chat-messages { 
  	flex: 1; 
  	padding: 20px; 
  	overflow-y: auto; 
  	display: flex; 
  	flex-direction: column; 
  	gap: 16px; }
  .msg-row { display: flex; gap: 10px; align-items: flex-end; }
  .msg-row.me { justify-content: flex-end; }
  .msg-profile { width: 36px; height: 36px; border-radius: 50%; object-fit: cover; }
  .msg-bubble { max-width: 75%; padding: 12px 16px; border-radius: 20px; font-size: 14px; line-height: 1.5; font-weight: 600; box-shadow: 0 4px 12px rgba(0,0,0,0.03); }
  .msg-row.other .msg-bubble { background: white; border-top-left-radius: 4px; color: var(--text-black); }
  .msg-row.me .msg-bubble { background: var(--grad-main); color: white; border-bottom-right-radius: 4px; }
  .msg-name { font-size: 12px; color: var(--text-gray); margin-bottom: 4px; font-weight: 700; }
  .msg-time { font-size: 11px; color: #A0AEC0; font-weight: 600; margin-bottom: 4px; }

  .chat-input-area { padding: 16px; background: rgba(255, 255, 255, 0.4); border-top: 1px solid rgba(255,255,255,0.6); display: flex; gap: 12px; }
  .chat-input { flex: 1; padding: 12px 20px; border: none; border-radius: 24px; background: rgba(255, 255, 255, 0.9); font-size: 14px; outline: none; transition: 0.3s; font-family: 'Pretendard', sans-serif; box-shadow: 0 0 0 2px var(--sky-blue); }
  .btn-send { width: 44px; height: 44px; border-radius: 50%; border: none; background: var(--grad-main); color: white; cursor: pointer; display: flex; justify-content: center; align-items: center; transition: 0.2s; }
  .btn-send:hover { transform: scale(1.05); }
  .btn-send svg { width: 18px; height: 18px; fill: none; stroke: currentColor; stroke-width: 2.5; stroke-linecap: round; stroke-linejoin: round; margin-left: -2px;}

  .chat-floating-btn {
    position: fixed;
    bottom: 30px;
    right: 30px;
    width: 64px;
    height: 64px;
    border-radius: 50%;
    background: white;
    box-shadow: 0 8px 24px rgba(45, 55, 72, 0.15);
    display: none; 
    justify-content: center;
    align-items: center;
    cursor: pointer;
    z-index: 9999;
    border: 2px solid var(--sky-blue);
    transition: transform 0.3s cubic-bezier(0.34, 1.56, 0.64, 1);
  }
  .chat-floating-btn:hover {
    transform: translateY(-5px) scale(1.05);
    box-shadow: 0 12px 32px rgba(137, 207, 240, 0.3);
  }
  .chat-floating-btn img {
    width: 40px; height: 40px; object-fit: contain;
  }
  
  /* 안읽은 메시지 뱃지 */
  .chat-badge {
    position: absolute; top: -2px; right: -2px;
    background: #FF6B6B; color: white; font-size: 11px; font-weight: 900;
    width: 20px; height: 20px; border-radius: 50%;
    display: flex; justify-content: center; align-items: center;
    border: 2px solid white;
  }
</style>

<div id="globalChatModal" class="global-chat-wrapper">
  <div class="chat-modal-container">
    
    <div class="chat-sidebar">
      <div class="chat-sidebar-header">
        <h3>💬 참여중인 라운지</h3>
      </div>
      <div class="chat-room-list" id="dynamicChatRoomList">
        
      </div>
    </div>

    <div class="chat-main" style="position: relative;">
      
      <div id="chatEmptyState" style="width: 100%; height: 100%; display: flex; flex-direction: column; justify-content: center; align-items: center; text-align: center;">
        <div class="chat-controls" style="position: absolute; top: 16px; right: 20px;">
          <button class="chat-control-btn" onclick="document.getElementById('btnChatMinimize').click()">_</button>
          <button class="chat-control-btn" onclick="document.getElementById('btnChatClose').click()">✕</button>
        </div>
        
        <span style="font-size: 54px; margin-bottom: 20px; opacity: 0.6;">💬</span>
        <h3 style="color: var(--text-dark); margin: 0 0 10px 0; font-size: 20px;">입장할 라운지를 선택해주세요</h3>
        <p style="color: var(--text-gray); font-size: 14px; font-weight: 500;">좌측 목록에서 참여하고 싶은 지역 채팅방을 클릭하세요.</p>
      </div>

      <div id="chatRoomView" style="display: none; flex-direction: column; height: 100%;">
        <div class="chat-header">
          <div class="chat-title-info">
            <h2>🌴 #제주도 동행/맛집 방</h2>
            <span>🔴 124명 접속 중</span>
          </div>
          <div class="chat-controls">
            <button class="chat-control-btn" id="btnChatMinimize" title="최소화">_</button>
            <button class="chat-control-btn" id="btnChatClose" title="닫기">✕</button>
          </div>
        </div>

        <div class="chat-messages">
          
        </div>

        <div class="chat-input-area">
          <input type="text" class="chat-input" placeholder="메시지를 입력하세요...">
          <button class="btn-send"><svg viewBox="0 0 24 24"><line x1="22" y1="2" x2="11" y2="13"></line><polygon points="22 2 15 22 11 13 2 9 22 2"></polygon></svg></button>
        </div>
      </div>
    </div>

  </div>
</div>

<div id="chatFloatingBtn" class="chat-floating-btn" title="오픈 라운지 열기">
  <span class="chat-badge">3</span>
  <img src="${pageContext.request.contextPath}/dist/images/logo.png" alt="Tripan Chat" onerror="this.src='https://cdn-icons-png.flaticon.com/512/1041/1041916.png'">
</div>


<script src="https://cdn.jsdelivr.net/npm/sockjs-client@1/dist/sockjs.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/stomp.js/2.3.3/stomp.min.js"></script>

<script>
  document.addEventListener("DOMContentLoaded", () => {
    
  	const memberId = "${sessionScope.loginUser.memberId}";
    const senderNickname = "${sessionScope.loginUser.nickname}";
    const contextPath = "${pageContext.request.contextPath}";

    const chatModal = document.getElementById("globalChatModal");
    const floatingBtn = document.getElementById("chatFloatingBtn");
    const chatState = sessionStorage.getItem("tripanChatState");

    if (chatState === "opened") {
      chatModal.style.display = "flex";
      floatingBtn.style.display = "none";
    } else if (chatState === "minimized") {
      chatModal.style.display = "none";
      floatingBtn.style.display = "flex";
    } else {
      chatModal.style.display = "none";
      floatingBtn.style.display = "none";
    }

    document.getElementById("btnChatClose").addEventListener("click", () => {
      chatModal.style.display = "none";
      floatingBtn.style.display = "none";
      sessionStorage.setItem("tripanChatState", "closed");
    });

    document.getElementById("btnChatMinimize").addEventListener("click", () => {
      chatModal.style.display = "none";
      floatingBtn.style.display = "flex";
      sessionStorage.setItem("tripanChatState", "minimized");
    });

    floatingBtn.addEventListener("click", () => {
      floatingBtn.style.display = "none";
      chatModal.style.display = "flex";
      sessionStorage.setItem("tripanChatState", "opened");
    });

    window.openGlobalChat = function() {
      chatModal.style.display = "flex";
      floatingBtn.style.display = "none";
      sessionStorage.setItem("tripanChatState", "opened");
    };
    
    let stompClient = null;
    let currentRoomId = null;
    
    const emptyState = document.getElementById('chatEmptyState');
    const roomView = document.getElementById('chatRoomView');
    const chatMessages = document.querySelector('.chat-messages');
    const chatInput = document.querySelector('.chat-input');
    const btnSend = document.querySelector('.btn-send');

    if (memberId) {
        fetch(contextPath + '/api/chat/rooms')
        .then(response => {
          // 서버가 에러나 로그인 페이지(HTML)를 던지면 여기서 걸러냅니다.
          const contentType = response.headers.get("content-type");
          if (!contentType || !contentType.includes("application/json")) {
            throw new TypeError("JSON이 아닙니다! 시큐리티 설정이나 주소를 확인하세요.");
          }
          return response.json();
        })
        .then(rooms => {
          const listEl = document.getElementById('dynamicChatRoomList');
          if (!listEl) return;
          
          listEl.innerHTML = ''; 

          const icons = ['🌴', '🌊', '🏔️', '🌃', '🎎'];

          rooms.forEach((room, index) => {
            const icon = icons[index % icons.length];
            const html = `
              <div class="chat-room-item" data-room-id="\${room.chatRoomId}" data-room-name="\${room.chatRoomName}">
                <div class="room-icon">\${icon}</div>
                <div class="room-info">
                  <h4>\${room.chatRoomName}</h4>
                  <p>입장하여 대화를 나눠보세요!</p>
                </div>
              </div>
            `;
            listEl.insertAdjacentHTML('beforeend', html);
          });

          document.querySelectorAll('.chat-room-item').forEach(item => {
            item.addEventListener('click', function() {
              document.querySelectorAll('.chat-room-item').forEach(el => el.classList.remove('active'));
              this.classList.add('active');
              emptyState.style.display = 'none';
              roomView.style.display = 'flex';

              const roomId = this.getAttribute('data-room-id'); 
              const roomName = this.getAttribute('data-room-name');
              
              const countSpan = document.querySelector('.chat-title-info span');
              if (countSpan) {
                  countSpan.innerText = '🔴 인원 확인 중...';
              }
              
              document.querySelector('.chat-title-info h2').innerText = '💬 #' + roomName;

              connectChatRoom(roomId);
            });
          });
        })
        .catch(error => console.error('방 목록을 불러오지 못했습니다:', error));
      }

    btnSend.addEventListener('click', sendMessage);
    chatInput.addEventListener('keypress', function(e) {
      if (e.key === 'Enter') {
        sendMessage();
      }
    });

    function connectChatRoom(roomId) {
      if (!memberId) { 
        if (typeof showLoginModal === 'function') {
            showLoginModal();
        } else {
            alert("로그인이 필요한 서비스입니다.");
        }
        return;
      }

      if (stompClient !== null) {
        stompClient.disconnect();
      }

      currentRoomId = roomId;
      chatMessages.innerHTML = `
        <div style="text-align: center; margin: 20px 0;">
          <span style="background: rgba(0, 0, 0, 0.08); color: var(--text-gray); font-size: 12px; padding: 6px 16px; border-radius: 16px; font-weight: 600;">
            🎉 라운지에 입장하셨습니다. 매너 채팅 부탁드려요!
          </span>
        </div>
      `; 

      const socket = new SockJS(contextPath + '/ws-chat');
      stompClient = Stomp.over(socket);
      stompClient.debug = null; 

      stompClient.connect({}, function (frame) {
          console.log('방 번호 [' + roomId + '] 에 연결되었습니다!');

          stompClient.subscribe('/sub/chat/room/' + roomId + '/count', function (message) {
            const count = message.body; // 백엔드에서 보낸 숫자(count)를 받음
            
            const countSpan = document.querySelector('.chat-title-info span');
            if (countSpan) {
                countSpan.innerText = '🔴 ' + count + '명 접속 중';
            }
          });

          stompClient.subscribe('/sub/chat/room/' + roomId, function (chat) {
            const messageData = JSON.parse(chat.body);
            renderMessage(messageData); 
          });
      });
    }

    function sendMessage() {
      const content = chatInput.value.trim();
      
      if (content && stompClient) {
        const chatMessage = {
          roomId: currentRoomId,
          memberId: memberId,
          senderNickname: senderNickname,
          content: content,
          messageType: 'TALK'
        };

        stompClient.send("/pub/chat/message", {}, JSON.stringify(chatMessage));
        chatInput.value = ''; 
      }
    }

    function renderMessage(message) {
      const isMe = (message.memberId == memberId); 
      
      const msgRow = document.createElement('div');
      msgRow.className = 'msg-row ' + (isMe ? 'me' : 'other');

      let htmlString = '';

      if (!isMe) {
        // 남이 보낸 메시지 (왼쪽)
        htmlString += `
          <img src="https://picsum.photos/seed/\${message.memberId}/100/100" class="msg-profile" alt="프로필">
          <div style="max-width: 70%;">
            <div class="msg-name">@\${message.senderNickname}</div>
            <div class="msg-bubble" style="max-width: 100%; word-break: break-word;">\${message.content}</div>
          </div>
          <span class="msg-time" style="white-space: nowrap; margin-bottom: 4px;">\${message.createdAt || ''}</span>
        `;
      } else {
        // 내가 보낸 메시지 (오른쪽)
        htmlString += `
          <span class="msg-time" style="white-space: nowrap; margin-bottom: 4px;">\${message.createdAt || ''}</span>
          <div class="msg-bubble" style="max-width: 70%; word-break: break-word;">\${message.content}</div>
        `;
      }

      msgRow.innerHTML = htmlString;
      chatMessages.appendChild(msgRow);

      chatMessages.scrollTop = chatMessages.scrollHeight; // 항상 맨 밑으로 스크롤
    }
    
  });
</script>