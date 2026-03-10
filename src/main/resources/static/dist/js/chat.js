/** chat.js **/
'use strict';

let stompClient    = null;
let currentRoomId  = null;
let currentTabType = null;

// TRIPAN_DATA 가드
if (!window.TRIPAN_DATA) {
  console.warn('[chat.js] window.TRIPAN_DATA 없음. JSP에 TRIPAN_DATA 블록을 추가하세요.');
  window.TRIPAN_DATA = { memberId: '', nickname: '', ctxPath: '', isMypage: false };
}
const { memberId, nickname, ctxPath, isMypage } = window.TRIPAN_DATA;

// 유틸
function escHtmlChat(s) {
  if (!s) return '';
  return String(s)
    .replace(/&/g, '&amp;').replace(/</g, '&lt;')
    .replace(/>/g, '&gt;').replace(/"/g, '&quot;');
}

function disconnectStomp(callback) {
  if (stompClient && stompClient.connected) {
    stompClient.disconnect(() => {
      stompClient   = null;
      currentRoomId = null;
      if (callback) callback();
    });
  } else {
    stompClient   = null;
    currentRoomId = null;
    if (callback) callback();
  }
}

//  고객센터 방 생성 (전역 – inline onclick용)
window.createSupportRoom = function () {
  fetch(`${ctxPath}/api/chat/rooms/support/create`, { method: 'POST' })
    .then(res => {
      if (res.ok) {
        window.loadRoomList('SUPPORT');
      } else {
        alert('문의방 생성에 실패했습니다. 잠시 후 다시 시도해주세요.');
      }
    })
    .catch(() => alert('네트워크 오류가 발생했습니다.'));
};

//  방 목록 로드 (탭 전환 진입점)
window.loadRoomList = function (type) {
  disconnectStomp(() => _loadRoomList(type));
};

function _loadRoomList(type) {
  currentTabType = type;

  // 방 뷰 숨기고 빈 상태 표시
  const emptyState = document.getElementById('chatEmptyState');
  const roomView   = document.getElementById('chatRoomView');
  if (emptyState) emptyState.style.display = 'flex';
  if (roomView)   roomView.style.display   = 'none';

  // 탭 활성화
  document.querySelectorAll('.chat-tab').forEach(t => t.classList.remove('active'));
  const tabIdMap = { REGION: 'tabRegion', PRIVATE: 'tabPrivate', SUPPORT: 'tabSupport' };
  const tabEl = document.getElementById(tabIdMap[type]);
  if (tabEl) tabEl.classList.add('active');

  const apiMap = {
    REGION:  `${ctxPath}/api/chat/rooms/region`,
    PRIVATE: `${ctxPath}/api/chat/rooms/private`,
    SUPPORT: `${ctxPath}/admin/api/chat/rooms/support`,
  };
  const apiUrl = apiMap[type];
  if (!apiUrl) return;

  const listEl = document.getElementById('dynamicChatRoomList');
  if (!listEl) return;

  // 로딩 스피너
  listEl.innerHTML = `
    <div style="display:flex;flex-direction:column;align-items:center;padding:40px 20px;
                gap:12px;color:var(--text-gray);font-size:13px;font-weight:600;">
      <div style="width:28px;height:28px;border:3px solid rgba(137,207,240,.2);
                  border-top-color:var(--sky-blue);border-radius:50%;animation:sp .7s linear infinite;"></div>
      불러오는 중...
    </div>`;

  fetch(apiUrl)
    .then(res => {
      if (!res.ok) throw new Error(`HTTP ${res.status}`);
      return res.json();
    })
    .then(rooms => {
      if (currentTabType !== type) return; // 탭이 이미 바뀐 경우 무시
      listEl.innerHTML = '';

      // 빈 목록 처리
      if (!rooms || rooms.length === 0) {
        if (type === 'SUPPORT') {
          listEl.innerHTML = `
            <div style="text-align:center;padding:40px 20px;">
              <div style="font-size:48px;margin-bottom:16px;opacity:0.35;">🎧</div>
              <p style="font-size:13px;color:#666;margin:0 0 20px;font-weight:600;line-height:1.6;">
                아직 문의 내역이 없어요.<br>새로운 상담을 시작해보세요.
              </p>
              <button
                onclick="window.createSupportRoom()"
                style="width:100%;padding:14px;border-radius:14px;background:var(--text-black);
                       color:#fff;border:none;font-size:14px;font-weight:800;cursor:pointer;
                       font-family:'Pretendard',sans-serif;transition:background .2s;"
                onmouseover="this.style.background='var(--sky-blue)'"
                onmouseout="this.style.background='var(--text-black)'">
                + 새로운 문의 시작하기
              </button>
            </div>`;
        } else if (type === 'PRIVATE') {
          listEl.innerHTML = `
            <div style="text-align:center;padding:40px 20px;">
              <div style="font-size:40px;margin-bottom:12px;opacity:0.3;">💬</div>
              <p style="font-size:12px;color:var(--text-gray);margin:0;font-weight:600;">1:1 대화 내역이 없습니다.</p>
            </div>`;
        } else {
          listEl.innerHTML = `
            <div style="text-align:center;padding:40px 20px;">
              <div style="font-size:40px;margin-bottom:12px;opacity:0.3;">🌍</div>
              <p style="font-size:12px;color:var(--text-gray);margin:0 0 8px;font-weight:600;">라운지 방을 불러올 수 없습니다.</p>
              <p style="font-size:11px;color:#A0AEC0;margin:0;font-weight:500;">잠시 후 다시 시도해주세요.</p>
            </div>`;
        }
        return;
      }

      // 방 목록 렌더링
      const iconMap     = { REGION: ['🌴','🏙️','🌊','⛰️','🏝️'], SUPPORT: ['🎧'], PRIVATE: ['👤'] };
      const icons       = iconMap[type] || ['💬'];
      const displayRooms = (type === 'SUPPORT') ? [rooms[0]] : rooms;

      displayRooms.forEach((room, idx) => {
        const icon     = icons[idx % icons.length];
        const roomName = room.chatRoomName || (type === 'SUPPORT' ? 'Tripan 상담' : '이름 없음');
        const subText  = type === 'SUPPORT' ? '상담이 진행 중입니다' : '실시간 라운지';

        const div = document.createElement('div');
        div.className = 'chat-room-item';
        div.dataset.roomId   = room.chatRoomId;
        div.dataset.roomName = roomName;
        div.innerHTML = `
          <div class="room-icon">${icon}</div>
          <div class="room-info">
            <h4>${escHtmlChat(roomName)}</h4>
            <p>${subText}</p>
          </div>`;

        div.addEventListener('click', function () {
          document.querySelectorAll('.chat-room-item').forEach(el => el.classList.remove('active'));
          this.classList.add('active');

          const emptyEl = document.getElementById('chatEmptyState');
          const viewEl  = document.getElementById('chatRoomView');
          if (emptyEl) emptyEl.style.display = 'none';
          if (viewEl)  viewEl.style.display  = 'flex';

          const prefix  = type === 'REGION' ? '🌴 #' : type === 'SUPPORT' ? '🎧 ' : '💬 ';
          const titleEl = document.querySelector('.chat-title-info h2');
          if (titleEl) titleEl.innerText = prefix + roomName;

          window.connectChatRoom(room.chatRoomId);
        });

        listEl.appendChild(div);
      });
    })
    .catch(err => {
      console.error('[chat.js] 방 목록 로드 실패:', err);
      if (currentTabType !== type) return;
      listEl.innerHTML = `
        <div style="text-align:center;padding:30px 20px;">
          <p style="font-size:12px;color:#FC8181;font-weight:600;margin:0;">
            목록 로드 오류<br>
            <span style="color:var(--text-gray);font-size:11px;">${escHtmlChat(err.message)}</span>
          </p>
        </div>`;
    });
}

//  웹소켓 연결
window.connectChatRoom = function (roomId) {
  // 같은 방이면 재연결 불필요
  if (currentRoomId === roomId && stompClient && stompClient.connected) return;
  disconnectStomp(() => _connectChatRoom(roomId));
};

function _connectChatRoom(roomId) {
  currentRoomId = roomId;

  const socket = new SockJS(`${ctxPath}/ws-tripan`);
  stompClient  = Stomp.over(socket);
  stompClient.debug = null;

  stompClient.connect({}, () => {
    stompClient.subscribe(`/sub/chat/room/${roomId}`, (frame) => {
      const data = JSON.parse(frame.body);
      const list = document.querySelector('.chat-messages');
      if (!list) return;

      const isMe = (String(data.memberId) === String(memberId));
      const row  = document.createElement('div');
      row.className = `msg-row ${isMe ? 'me' : 'other'}`;
      row.innerHTML = isMe
        ? `<span class="msg-time">${data.createdAt || ''}</span>
           <div class="msg-bubble">${escHtmlChat(data.content)}</div>`
        : `<img src="https://picsum.photos/seed/${data.memberId}/50/50" class="msg-profile" alt="">
           <div style="max-width:70%">
             <div class="msg-name">@${escHtmlChat(data.senderNickname)}</div>
             <div class="msg-bubble">${escHtmlChat(data.content)}</div>
           </div>
           <span class="msg-time">${data.createdAt || ''}</span>`;
      list.appendChild(row);
      list.scrollTop = list.scrollHeight;
    });

    const msgList = document.querySelector('.chat-messages');
    if (msgList) msgList.innerHTML = '';

    stompClient.send('/pub/chat/message', {}, JSON.stringify({
      roomId, memberId, senderNickname: nickname, content: '', messageType: 'ENTER'
    }));
  }, err => {
    console.error('[chat.js] STOMP 연결 실패:', err);
  });
}

//  메시지 전송
window.sendMessage = function () {
  const input = document.querySelector('.chat-input');
  if (!input) return;
  const msg = input.value.trim();
  if (!currentRoomId || !msg || !stompClient || !stompClient.connected) return;
  stompClient.send('/pub/chat/message', {}, JSON.stringify({
    roomId: currentRoomId, memberId, senderNickname: nickname,
    content: msg, messageType: 'TALK'
  }));
  input.value = '';
};

//  DOMContentLoaded
document.addEventListener('DOMContentLoaded', () => {
  const chatModal   = document.getElementById('globalChatModal');
  const floatingBtn = document.getElementById('chatFloatingBtn');
  const tabSupport  = document.getElementById('tabSupport');

  // ★ 수정 포인트 1: 새로고침 시 무조건 닫힌 상태로 시작
  if (chatModal)              chatModal.style.display   = 'none';
  if (floatingBtn && memberId) floatingBtn.style.display = 'flex';
  sessionStorage.removeItem('tripanChatState');

  // 마이페이지면 고객센터 탭 노출
  if (tabSupport && isMypage) tabSupport.style.display = 'inline-block';

  // 최소화 버튼: 모달만 숨김, 연결 유지
  const btnMin = document.getElementById('btnChatMinimize');
  if (btnMin) {
    btnMin.addEventListener('click', () => {
      if (chatModal)   chatModal.style.display   = 'none';
      if (floatingBtn) floatingBtn.style.display = 'flex';
    });
  }

  // 닫기 버튼: 모달 숨기고 연결 완전 종료
  const btnClose = document.getElementById('btnChatClose');
  if (btnClose) {
    btnClose.addEventListener('click', () => {
      if (chatModal)   chatModal.style.display   = 'none';
      if (floatingBtn) floatingBtn.style.display = 'flex';
      disconnectStomp();
    });
  }

  // 플로팅 버튼 → 모달 열기
  if (floatingBtn) {
    floatingBtn.addEventListener('click', () => {
      if (chatModal) chatModal.style.display = 'flex';
      floatingBtn.style.display = 'none';
    });
  }

  // 전송 버튼 / Enter
  const btnSend   = document.querySelector('.btn-send');
  const chatInput = document.querySelector('.chat-input');
  if (btnSend)   btnSend.addEventListener('click', window.sendMessage);
  if (chatInput) {
    chatInput.addEventListener('keydown', e => {
      if (e.key === 'Enter' && !e.shiftKey) {
        e.preventDefault();
        window.sendMessage();
      }
    });
  }

  // 로그인 상태일 때만 기본 라운지 로드
  if (memberId) window.loadRoomList('REGION');
});