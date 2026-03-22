const ctxPath  = window.TRIPAN_DATA.ctxPath;
const adminId  = window.TRIPAN_DATA.adminId;
const adminNick = window.TRIPAN_DATA.adminNick || '관리자';

let currentRoomId    = null;
let stompClient      = null;      // 현재 채팅방 전용 연결
let notifClient      = null;      // 관리자 알림 전용 연결
let roomSubscription = null;      // 현재 방 구독 핸들
let allChatRooms     = [];
let currentFilter    = 'all';
let selectedInquiry  = null;
let readDebounceTimer = null;     // 읽음 처리 디바운스 타이머

// ── 탭 전환 ──
function switchTab(tab, el) {
  document.querySelectorAll('.cs-tab').forEach(t => t.classList.remove('active'));
  document.querySelectorAll('.tab-panel').forEach(p => p.classList.remove('active'));
  el.classList.add('active');
  document.getElementById('panel-' + tab).classList.add('active');
  if (tab === 'chat') {
     // 탭 재진입 시 채팅뷰 초기화 → 방 목록에서 직접 클릭해야 열림
	 if (currentRoomId) {                                                      
	           fetch(`${ctxPath}/admin/cs/api/chat/rooms/${currentRoomId}/read`, {   
	   method: 'PUT' }).catch(() => {});                                          
	       }    
     currentRoomId = null;
     document.getElementById('chatViewEmpty').style.display = 'flex';
     document.getElementById('chatViewMain').style.display  = 'none';
     loadChatRooms();
   }
  if (tab === 'board') loadInquiries();
}

// ── 문의 게시판 ──
let allInquiries = [];

async function loadInquiries() {
  try {
    const res  = await fetch(`${ctxPath}/admin/inquiry`);
    const data = await res.json();
    allInquiries = data || [];
    renderInquiries(allInquiries);
    const waiting = allInquiries.filter(i => i.status === 'WAITING').length;
    document.getElementById('boardBadge').textContent = waiting;
  } catch (e) {
    document.getElementById('inquiryTbody').innerHTML = `
      <tr><td colspan="7" style="text-align:center;padding:40px;color:#FC8181;font-size:13px;">
        데이터를 불러오지 못했습니다
      </td></tr>`;
  }
}

function renderInquiries(list) {
  const tbody = document.getElementById('inquiryTbody');
  if (!list || list.length === 0) {
    tbody.innerHTML = `
      <tr><td colspan="7" style="text-align:center;padding:40px;color:var(--text-gray);font-size:13px;">
        <i class="bi bi-inbox" style="font-size:24px;opacity:.3;display:block;margin-bottom:8px;"></i>
        문의 내역이 없습니다
      </td></tr>`;
    return;
  }
  tbody.innerHTML = list.map((item, idx) => `
    <tr>
      <td style="color:var(--text-gray);font-size:12px;">${item.inquiryId || idx+1}</td>
      <td><span class="category-pill">${escHtml(item.category || '기타')}</span></td>
      <td style="font-weight:700; max-width:240px;">
        ${item.status == 'WAITING' ? '<span style="color:#FC8181;font-size:11px;font-weight:800;margin-right:6px;">NEW</span>' : ''}
        ${escHtml(item.title)}
      </td>
      <td>${escHtml(item.userName || '사용자')}</td>
      <td style="font-size:12px;color:var(--text-gray);">${formatDate(item.createdAt)}</td>
      <td>${statusPill(item.status)}</td>
      <td><button class="btn-view" onclick='openInquiry(${JSON.stringify(item)})'>상세보기</button></td>
    </tr>`).join('');
}

function filterInquiry(type, el) {
  document.querySelectorAll('.filter-btn').forEach(b => b.classList.remove('active'));
  el.classList.add('active');
  currentFilter = type;
  applyFilter();
}

function searchInquiry(q) { applyFilter(q); }

function applyFilter(q) {
  q = q || document.getElementById('inquirySearch').value;
  let list = allInquiries;
  if (currentFilter !== 'all') list = list.filter(i => i.status && i.status.toLowerCase() === currentFilter);
  if (q) list = list.filter(i => (i.title||'').includes(q) || (i.userName||'').includes(q));
  renderInquiries(list);
}

function statusPill(s) {
  const map = {
    WAITING:  ['waiting',  '대기 중'],
    ANSWERED: ['answered', '답변 완료'],
    CLOSED:   ['closed',   '종료'],
  };
  const [cls, label] = map[s] || ['closed','알 수 없음'];
  return `<span class="status-pill ${cls}">${label}</span>`;
}

function openInquiry(item) {
  selectedInquiry = item;
  document.getElementById('modalTitle').textContent    = item.title || '';
  document.getElementById('modalCategory').textContent = item.category || '기타';
  document.getElementById('modalDate').textContent     = formatDate(item.createdAt);
  document.getElementById('modalContent').textContent  = item.content || '';
  document.getElementById('modalReplyInput').value     = item.reply || '';
  document.getElementById('modalStatus').outerHTML     = statusPill(item.status).replace('class="status-pill', 'id="modalStatus" class="status-pill');
  document.getElementById('inquiryModal').classList.add('open');
}

function closeModal() {
  document.getElementById('inquiryModal').classList.remove('open');
  selectedInquiry = null;
}

async function submitReply() {
  if (!selectedInquiry) return;
  const reply = document.getElementById('modalReplyInput').value.trim();
  if (!reply) { alert('답변 내용을 입력해주세요.'); return; }
  try {
    await fetch(`${ctxPath}/admin/inquiry/${selectedInquiry.inquiryId}/reply`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ reply })
    });
    closeModal();
    loadInquiries();
  } catch (e) {
    alert('답변 등록에 실패했습니다.');
  }
}

// ── 1:1 채팅 목록 ──
async function loadChatRooms() {
  try {
    const res   = await fetch(`${ctxPath}/admin/cs/api/chat/rooms/support`);
    const rooms = await res.json();
    allChatRooms = rooms || [];
    renderChatRooms(allChatRooms);
	
	// 현재 보고 있는 방은 배지 제거 (이미 읽고 있으므로)
	    if (currentRoomId) {
	      const cur = document.querySelector(`.chat-room-item[data-room-id="${currentRoomId}"]`);
	      if (cur) {
	        const b = cur.querySelector('.unread-badge');
	        if (b) b.remove();
	        cur.classList.remove('unread');
	      }
	    }

    // unreadCount 없으면 0으로
	const totalUnread = allChatRooms
	     .filter(r => String(r.chatRoomId) !== String(currentRoomId))
	     .reduce((sum, r) => sum + (r.unreadCount || 0), 0);
    const tabBadge = document.getElementById('chatBadge');
    tabBadge.textContent = totalUnread;
    tabBadge.style.display = totalUnread > 0 ? 'inline-flex' : 'none';
  } catch (e) {
    document.getElementById('chatRoomItems').innerHTML = `
      <div class="chat-empty-list">
        <i class="bi bi-exclamation-circle"></i>
        <p style="color:#FC8181;">목록을 불러오지 못했습니다</p>
      </div>`;
  }
}

function renderChatRooms(rooms) {
  const el = document.getElementById('chatRoomItems');
  if (!rooms || rooms.length === 0) {
    el.innerHTML = `<div class="chat-empty-list"><i class="bi bi-chat-dots"></i><p>상담 내역이 없습니다</p></div>`;
    return;
  }

  const statusMeta = {
    WAITING: { label: '신규문의', cls: 'waiting', order: 0 },
    ACTIVE:  { label: '상담 중',  cls: 'active',  order: 1 },
    CLOSED:  { label: '종료됨',   cls: 'closed',  order: 2 },
  };

  // 신규 → 상담중 → 종료 순 정렬
  rooms.sort((a, b) => ((statusMeta[a.status]?.order ?? 9) - (statusMeta[b.status]?.order ?? 9)));

  let lastStatus = null;
  el.innerHTML = rooms.map(r => {
    const meta = statusMeta[r.status] || { label: r.status, cls: 'closed' };
    const groupHtml = r.status !== lastStatus
      ? `<div class="chat-group-label">${meta.label} · ${rooms.filter(x => x.status === r.status).length}건</div>`
      : '';
    lastStatus = r.status;

    const unread = r.unreadCount || (r.hasUnread ? 1 : 0);

    return `
      ${groupHtml}
      <div class="chat-room-item ${unread > 0 ? 'unread' : ''}"
           data-room-id="${r.chatRoomId}"
           onclick='enterRoom(${JSON.stringify(r)})'>
        <div class="room-avatar">👤</div>
        <div class="room-info">
          <div class="room-info-top">
            <span class="room-user">${escHtml(r.userName || '사용자')}</span>
            <span class="room-time">${formatDate(r.createdAt)}</span>
          </div>
          <div class="room-preview">${escHtml(r.lastMessage || '대화를 시작해보세요')}</div>
          <span class="room-status-pill ${meta.cls}">${meta.label}</span>
        </div>
        ${unread > 0 ? `<span class="unread-badge">${unread}</span>` : ''}
      </div>`;
  }).join('');
}

function filterChatRooms(q) {
  if (!q) { renderChatRooms(allChatRooms); return; }
  renderChatRooms(allChatRooms.filter(r => (r.userName||'').includes(q)));
}

// ── 채팅방 입장 ──
async function enterRoom(room) {
  // 목록 활성화
  document.querySelectorAll('.chat-room-item').forEach(el => el.classList.remove('active'));
  const roomItem = document.querySelector(`[data-room-id="${room.chatRoomId}"]`);
  roomItem?.classList.add('active');

  // 읽음 처리 (뱃지 제거)
  const unreadBadge = roomItem?.querySelector('.unread-badge');
  if (unreadBadge) {
    const cnt = parseInt(unreadBadge.textContent) || 0;
    unreadBadge.remove();
    roomItem?.classList.remove('unread');
    const tabBadge = document.getElementById('chatBadge');
    const next = Math.max(0, (parseInt(tabBadge.textContent) || 0) - cnt);
    tabBadge.textContent = next;
    tabBadge.style.display = next > 0 ? 'inline-flex' : 'none';
  }
	
  currentRoomId = room.chatRoomId;
  
  // DB 읽음 처리 (last_connected_at 갱신 → unreadCount 0으로)
  try {
      await fetch(`${ctxPath}/admin/cs/api/chat/rooms/${room.chatRoomId}/read`, { method: 'PUT' });
    } catch (e) {
      console.warn('읽음 처리 실패:', e);
    }

  // 채팅 뷰 전환
  document.getElementById('chatViewEmpty').style.display = 'none';
  document.getElementById('chatViewMain').style.display = 'flex';
  document.getElementById('chatViewTitle').textContent = `🎧 ${room.userName || '사용자'} 님의 상담`;
  document.getElementById('chatViewSub').textContent = `문의 시작: ${formatDate(room.createdAt)}`;

  // 상태 뱃지
  const isClosed = room.status === 'CLOSED';
  const endBtn = document.querySelector('.btn-end-chat');
    if (endBtn) {
      endBtn.disabled = isClosed;
      endBtn.style.opacity = isClosed ? '0.5' : '1';
      endBtn.style.cursor = isClosed ? 'not-allowed' : 'pointer';
    }
  const statusBadge = document.getElementById('chatStatusBadge');
  statusBadge.className = isClosed ? 'chat-status-closed' : 'chat-status-open';
  statusBadge.textContent = isClosed ? '상담 종료' : '상담 중';

  // 입력창 활성 여부
  const input = document.getElementById('adminMsgInput');
  input.disabled = isClosed;
  input.placeholder = isClosed ? '종료된 상담입니다.' : '답변을 입력하세요... (Enter: 전송, Shift+Enter: 줄바꿈)';

 connectRoom(room.chatRoomId);
}

// ── 채팅방 WebSocket 연결 ──
function connectRoom(roomId) {
  // 기존 방 구독 해제
  if (roomSubscription) {
    try { roomSubscription.unsubscribe(); } catch(e) {}
    roomSubscription = null;
  }

  document.getElementById('chatMessagesArea').innerHTML = '';

  if (stompClient && stompClient.connected) {
    subscribeRoom(roomId);
    loadChatHistory(roomId);
  } else {
    const socket = new SockJS(`${ctxPath}/ws-tripan`);
    stompClient  = Stomp.over(socket);
    stompClient.debug = null;
    stompClient.connect({}, () => {
      subscribeRoom(roomId);
      loadChatHistory(roomId);
    });
  }
}

function subscribeRoom(roomId) {
  roomSubscription = stompClient.subscribe(`/sub/chat/room/${roomId}`, frame => {
    const msg = JSON.parse(frame.body);

    // 종료 메시지 처리
    if (msg.messageType === 'CLOSED' || msg.messageType === 'END' || msg.messageType === 'SYSTEM') {
      renderMsg(msg);
      const badge = document.getElementById('chatStatusBadge');
      if (badge) { badge.className = 'chat-status-closed'; badge.textContent = '상담 종료'; }
      
	  const endBtn = document.querySelector('.btn-end-chat');
	        if (endBtn) { endBtn.disabled = true; endBtn.style.opacity = '0.5'; endBtn.style.cursor = 'not-allowed'; }
	        return;
    }

	const badge = document.getElementById('chatStatusBadge');
	    if (badge && badge.className === 'chat-status-closed') {
	      badge.className = 'chat-status-open';
	      badge.textContent = '상담 중';
	      const input = document.getElementById('adminMsgInput');
	      input.disabled = false;
	      input.placeholder = '답변을 입력하세요... (Enter: 전송, Shift+Enter: 줄바꿈)';
	      
	      // 방 목록 갱신 (상태 업데이트 반영)
	      loadChatRooms();
	    }
	
    renderMsg(msg);

    // 유저 메시지 && 내가 보낸 게 아닐 때 → 알림음 + 읽음 처리 갱신
	if (String(msg.memberId) !== String(adminId)) { 
	      const badge = document.getElementById('chatStatusBadge');
	      if (badge && badge.className === 'chat-status-closed') {
	        // 현재 채팅방 상단 뱃지와 버튼만 즉시 활성화
	        badge.className = 'chat-status-open';
	        badge.textContent = '상담 중';
	        
	        const endBtn = document.querySelector('.btn-end-chat');
	        if (endBtn) { endBtn.disabled = false; endBtn.style.opacity = '1'; endBtn.style.cursor = 'pointer'; }
	      }
	      // DB 상태가 바뀌었을 테니 방 목록을 즉시 새로고침
	      loadChatRooms(); 
	    }
		});
		}

// ── 채팅 히스토리 로드 ──
async function loadChatHistory(roomId) {
  try {
    const res  = await fetch(`${ctxPath}/api/chat/history/${roomId}`);
    if (!res.ok) throw new Error(res.status);
    const msgs = await res.json();
    if (!Array.isArray(msgs) || msgs.length === 0) return;
    
    const area = document.getElementById('chatMessagesArea');
	area.innerHTML = '';

	    let lastDate = null;
	    msgs.forEach(m => {
	      if (m.msgDate && m.msgDate !== lastDate) {
	        renderDateSeparator(m.msgDate);
	        lastDate = m.msgDate;
	      }
	      renderMsg(m);
	    });
    area.scrollTop = area.scrollHeight;
  } catch(e) {
    console.warn('채팅 히스토리 로드 실패:', e);
  }
}
function renderDateSeparator(dateStr) {
  const area = document.getElementById('chatMessagesArea');
  const d = new Date(dateStr);
  const label = d.toLocaleDateString('ko-KR', { year: 'numeric', month: 'long', day: 'numeric', weekday: 'long' });
  area.insertAdjacentHTML('beforeend', `
    <div style="display:flex;align-items:center;gap:10px;margin:18px 0 10px;">
      <div style="flex:1;height:1px;background:#E2E8F0;"></div>
      <span style="font-size:11px;color:#A0AEC0;font-weight:700;white-space:nowrap;">${label}</span>
      <div style="flex:1;height:1px;background:#E2E8F0;"></div>
    </div>`);
}
// ── 메시지 렌더링 ──
function renderMsg(data) {
  const area = document.getElementById('chatMessagesArea');

  // 시스템/종료 메시지
  if (data.messageType === 'CLOSED' || data.messageType === 'END' || data.messageType === 'SYSTEM') {
    area.insertAdjacentHTML('beforeend', `
      <div style="text-align:center;margin:8px 0;">
        <span style="background:rgba(0,0,0,0.07);color:#6B7280;font-size:12px;
                     padding:5px 16px;border-radius:16px;font-weight:700;display:inline-block;">
          🔒 ${escHtml(data.content || '상담이 종료되었습니다.')}
        </span>
      </div>`);
    area.scrollTop = area.scrollHeight;
    return;
  }

  const isMe = String(data.memberId) === String(adminId)
             || data.messageType === 'ADMIN';  // ← messageType으로도 판별
  const row = document.createElement('div');
  row.className = `msg-row ${isMe ? 'admin-msg' : 'user-msg'}`;
  row.innerHTML = isMe
    ? `<span class="msg-time">${data.createdAt || ''}</span>
       <div class="msg-bubble">${escHtml(data.content)}</div>`
    : `<div class="msg-avatar">👤</div>
       <div>
         <div class="msg-name">${escHtml(data.senderNickname || '사용자')}</div>
         <div class="msg-bubble">${escHtml(data.content)}</div>
       </div>
       <span class="msg-time">${data.createdAt || ''}</span>`;
  area.appendChild(row);
  area.scrollTop = area.scrollHeight;
}

// ── 메시지 전송 ──
function sendAdminMsg() {
  const input = document.getElementById('adminMsgInput');
  const msg   = input.value.trim();
  if (!msg || !currentRoomId || !stompClient?.connected) return;
  stompClient.send('/pub/chat/message', {}, JSON.stringify({
    roomId: currentRoomId, memberId: adminId,
    senderNickname: adminNick, content: msg, messageType: 'TALK'
  }));
  input.value = '';
  input.style.height = 'auto';
}

// 상담 종료
async function endChat() {
  if (!currentRoomId || !confirm('상담을 종료하시겠습니까?')) return;
  try {
    const res = await fetch(`${ctxPath}/api/chat/rooms/${currentRoomId}/close`, { method: 'POST' });
	
	const endBtn = document.querySelector('.btn-end-chat');
	    if (endBtn) {
	      endBtn.disabled = true;
	      endBtn.style.opacity = '0.5';
	      endBtn.style.cursor = 'not-allowed';
	    }

    // 유저 화면에도 전달되도록 WebSocket 발행
    if (stompClient?.connected) {
      stompClient.send('/pub/chat/message', {}, JSON.stringify({
        roomId: currentRoomId,
        memberId: adminId,
        senderNickname: adminNick,
        content: '상담이 종료되었습니다.',
        messageType: 'CLOSED' 
      }));
    }

    // 관리자 UI 업데이트
    const badge = document.getElementById('chatStatusBadge');
    badge.className = 'chat-status-closed'; badge.textContent = '상담 종료';
    const input = document.getElementById('adminMsgInput');
     input.placeholder = '채팅을 입력하세요.';

    loadChatRooms();
  } catch (e) {
    alert('상담 종료에 실패했습니다.');
  }
}
function playBeep() {
  try {
    const ac = new (window.AudioContext || window.webkitAudioContext)();
    const o = ac.createOscillator(), g = ac.createGain();
    o.connect(g); g.connect(ac.destination);
    o.frequency.value = 820; o.type = 'sine';
    g.gain.setValueAtTime(0.25, ac.currentTime);
    g.gain.exponentialRampToValueAtTime(0.001, ac.currentTime + 0.35);
    o.start(); o.stop(ac.currentTime + 0.35);
  } catch(e) {}
}

function incrementRoomBadge(roomId, lastMsg) {
  const item = document.querySelector(`.chat-room-item[data-room-id="${roomId}"]`);
  if (!item) { loadChatRooms(); return; } // 목록에 없으면 새로고침

  item.classList.add('unread');
  let badge = item.querySelector('.unread-badge');
  if (!badge) {
    badge = document.createElement('span');
    badge.className = 'unread-badge';
    badge.textContent = '0';
    item.appendChild(badge);
  }
  badge.textContent = parseInt(badge.textContent || 0) + 1;

  // 탭 뱃지도 +1
  const tabBadge = document.getElementById('chatBadge');
  tabBadge.textContent = parseInt(tabBadge.textContent || 0) + 1;

  // 마지막 메시지 preview 갱신
  const preview = item.querySelector('.room-preview');
  if (preview && lastMsg) preview.textContent = lastMsg;
}

// 관리자 알림용 WebSocket (페이지 로드 시 상시 유지)
function connectNotification() {
  if (!adminId) return;
  const socket = new SockJS(`${ctxPath}/ws-tripan`);
  notifClient  = Stomp.over(socket);
  notifClient.debug = null;
  notifClient.connect({}, () => {

    notifClient.subscribe('/sub/admin/chat/new', frame => {
      const data = JSON.parse(frame.body);
      showToast('새 상담 문의', `${data.userName || '사용자'}님이 1:1 상담을 요청했습니다.`);
      playBeep();
      loadChatRooms(); // 목록 갱신
    });

    // 유저 메시지 실시간 알림 (현재 보고 있는 방 제외)
    notifClient.subscribe('/sub/admin/chat/message', frame => {
      const data = JSON.parse(frame.body);
      if (String(data.roomId) === String(currentRoomId)) return; // 보고 있는 방은 스킵

      playBeep();
	  showToast('새 메시지', `${data.userName || '사용자'}님이 메시지를 보냈습니다.`);
      loadChatRooms();
	  const bellBadge = document.querySelector('.notif-badge'); 
	        if (bellBadge) {
	          bellBadge.textContent = (parseInt(bellBadge.textContent) || 0) + 1;
	          bellBadge.style.display = 'inline-block';
	        }
			const notifList = document.getElementById('notifList');
			      if (notifList) {
			        // "알림이 없습니다" 문구 제거
			        const emptyMsg = document.getElementById('emptyNotif');
			        if (emptyMsg) emptyMsg.remove(); 

			        const timeStr = new Date().toLocaleTimeString('ko-KR', { hour: '2-digit', minute: '2-digit' });
			        
			        // 새로 추가될 알림의 HTML 구조
			        const itemHtml = `
			          <div style="padding:14px 18px; border-bottom:1px solid #f1f5f9; cursor:pointer; transition:background 0.2s;" 
			               onmouseover="this.style.background='#F8FAFC'" onmouseout="this.style.background='white'"
			               onclick="location.href='${ctxPath}/admin/cs'">
			            <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:4px;">
			              <span style="font-size:12px; font-weight:800; color:#2D3748;">🎧 상담 메시지</span>
			              <span style="font-size:10px; color:#A0AEC0; font-weight:600;">${timeStr}</span>
			            </div>
			            <div style="font-size:12px; color:#718096; line-height:1.4;">
			              <strong style="color:#4A5568;">${data.userName || '사용자'}</strong>님이 메시지를 보냈습니다.
			            </div>
			          </div>
			        `;
			        // 최신 알림이 맨 위에 오도록 추가
			        notifList.insertAdjacentHTML('afterbegin', itemHtml); 
			      }	
    }); 

  }, () => {
    // 연결 실패 시 5초 후 재시도
    setTimeout(connectNotification, 5000);
  }); 
}
// ── 토스트 알림 ──
function showToast(title, body) {
  if (!document.getElementById('cs-toast-style')) {
    const style = document.createElement('style');
    style.id = 'cs-toast-style';
    style.textContent = '@keyframes csToastIn{from{opacity:0;transform:translateX(50px)}to{opacity:1;transform:translateX(0)}}';
    document.head.appendChild(style);
  }
  const toast = document.createElement('div');
  toast.style.cssText = `
    position:fixed; top:20px; right:20px; z-index:9999;
    background:white; border-radius:14px; padding:14px 18px;
    box-shadow:0 8px 24px rgba(0,0,0,.13); border-left:4px solid #89CFF0;
    display:flex; align-items:center; gap:12px; min-width:280px;
    animation:csToastIn .3s ease;
  `;
  toast.innerHTML = `
    <span style="font-size:22px;">🎧</span>
    <div>
      <strong style="display:block;font-size:13px;font-weight:800;margin-bottom:2px;">${escHtml(title)}</strong>
      <span style="font-size:12px;color:#718096;">${escHtml(body)}</span>
    </div>`;
  document.body.appendChild(toast);
  setTimeout(() => toast.remove(), 5000);
}

// ── 유틸 ──
function escHtml(s) {
  if (!s) return '';
  return String(s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;');
}
function formatDate(v) {
  if (!v) return '';
  return new Date(v).toLocaleDateString('ko-KR', { month:'2-digit', day:'2-digit', hour:'2-digit', minute:'2-digit' });
}

// ── textarea Enter 전송 ──
 if (e.key === 'Enter' && !e.shiftKey)
document.getElementById('adminMsgInput').addEventListener('input', function() {
  this.style.height = 'auto';
  this.style.height = Math.min(this.scrollHeight, 100) + 'px';
});

function handleBackdropClick(event) {
  if (event.target === event.currentTarget) closeModal();
}

// ── 초기화 ──
loadInquiries();
loadChatRooms();
connectNotification();             // 관리자 알림 WebSocket 상시 연결
setInterval(loadChatRooms, 30000); // 30초마다 채팅 목록 새로고침
