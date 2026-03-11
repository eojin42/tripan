
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

	    window.loadRoomList = function(type) {
	        document.querySelectorAll('.chat-tab').forEach(tab => tab.classList.remove('active'));
	        let url = contextPath;
	        
	        if (type === 'REGION') {
	            document.getElementById('tabRegion').classList.add('active');
	            url += '/api/chat/rooms/region'; 
	        } else {
	            document.getElementById('tabPrivate').classList.add('active');
	            url += '/api/chat/rooms/private'; 
	        }

	        fetch(url)
	        .then(response => {
	            if (!response.ok) throw new Error("목록 로딩 실패");
	            return response.json();
	        })
	        .then(rooms => {
	            const listEl = document.getElementById('dynamicChatRoomList');
	            if (!listEl) return;
	            
	            listEl.innerHTML = ''; 
	            if(!rooms || rooms.length === 0) {
	                listEl.innerHTML = '<p style="text-align:center; font-size:12px; color:var(--text-gray); margin-top:20px;">참여 중인 대화방이 없습니다.</p>';
	                return;
	            }

	            const icons = type === 'REGION' ? ['🌴', '🌊', '🏔️', '🌃', '🎎'] : ['👤', '😎', '👨‍🚀', '👩‍🎤', '👽'];

	            rooms.forEach((room, index) => {
	                const icon = icons[index % icons.length];
	                const roomTitle = room.chatRoomName || '이름 없음';
	                const desc = type === 'REGION' ? '다같이 떠드는 라운지' : '1:1 비밀 대화방';

	                const html = `
	                  <div class="chat-room-item" data-room-id="\${room.chatRoomId}" data-room-name="\${roomTitle}" data-room-type="\${type}">
	                    <div class="room-icon">\${icon}</div>
	                    <div class="room-info">
	                      <h4>\${roomTitle}</h4>
	                      <p>\${desc}</p>
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
	                    const roomType = this.getAttribute('data-room-type');
	                    
	                    document.querySelector('.chat-title-info h2').innerText = (roomType === 'REGION' ? '🌴 #' : '💬 @') + roomName;
	                    
	                    const countSpan = document.querySelector('.chat-title-info span');
	                    if (countSpan) {
	                        if (roomType === 'REGION') {
	                            countSpan.style.display = 'inline-block';
	                            countSpan.innerText = '🔴 인원 확인 중...';
	                        } else {
	                            countSpan.style.display = 'none'; 
	                        }
	                    }
	                    
	                    window.connectChatRoom(roomId);
	                });
	            });
	        })
	        .catch(error => console.error('방 목록을 불러오지 못했습니다:', error));
	    };

	    if (memberId) {
	        window.loadRoomList('REGION');
	    }

	    btnSend.addEventListener('click', sendMessage);
	    chatInput.addEventListener('keypress', function(e) {
	      if (e.key === 'Enter') {
	        sendMessage();
	      }
	    });

    window.connectChatRoom = function(roomId) {
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

      const socket = new SockJS(contextPath + '/ws-tripan');
      stompClient = Stomp.over(socket);
      stompClient.debug = null; 

      stompClient.connect({}, function (frame) {
          console.log('방 번호 [' + roomId + '] 에 연결되었습니다!');

          stompClient.subscribe('/sub/chat/room/' + roomId + '/count', function (message) {
            const count = message.body; 
            
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
