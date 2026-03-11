const ctxPath  = window.TRIPAN_DATA.ctxPath;
const adminId  = window.TRIPAN_DATA.adminId;
const adminNick = window.TRIPAN_DATA.adminNick || '관리자';

 let currentRoomId   = null;
 let stompClient     = null;
 let allChatRooms    = [];
 let currentFilter   = 'all';
 let selectedInquiry = null;

 // 탭 전환
 function switchTab(tab, el) {
   document.querySelectorAll('.cs-tab').forEach(t => t.classList.remove('active'));
   document.querySelectorAll('.tab-panel').forEach(p => p.classList.remove('active'));
   el.classList.add('active');
   document.getElementById('panel-' + tab).classList.add('active');
   if (tab === 'chat') loadChatRooms();
   if (tab === 'board') loadInquiries();
 }

 // 문의 게시판
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
   document.getElementById('modalTitle').textContent   = item.title || '';
   document.getElementById('modalCategory').textContent = item.category || '기타';
   document.getElementById('modalDate').textContent    = formatDate(item.createdAt);
   document.getElementById('modalContent').textContent = item.content || '';
   document.getElementById('modalReplyInput').value    = item.reply || '';
   document.getElementById('modalStatus').outerHTML    = statusPill(item.status).replace('class="status-pill', 'id="modalStatus" class="status-pill');
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

 // 1:1 채팅
 async function loadChatRooms() {
   try {
     const res   = await fetch(`${ctxPath}/admin/cs/api/chat/rooms/support`);
     const rooms = await res.json();
     allChatRooms = rooms || [];
     renderChatRooms(allChatRooms);
     const unread = allChatRooms.filter(r => r.hasUnread).length;
     document.getElementById('chatBadge').textContent = unread;
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
   el.innerHTML = rooms.map(r => `
     <div class="chat-room-item ${r.hasUnread ? 'unread' : ''}" data-room-id="${r.chatRoomId}" onclick='enterRoom(${JSON.stringify(r)})'>
       <div class="room-avatar">👤</div>
       <div class="room-info">
         <div class="room-info-top">
           <span class="room-user">${escHtml(r.userName || '사용자')}</span>
           <span class="room-time">${formatDate(r.createdAt)}</span>
         </div>
         <div class="room-preview">${escHtml(r.lastMessage || '대화를 시작해보세요')}</div>
       </div>
       ${r.hasUnread ? '<span class="unread-badge">N</span>' : ''}
     </div>`).join('');
 }

 function filterChatRooms(q) {
   if (!q) { renderChatRooms(allChatRooms); return; }
   renderChatRooms(allChatRooms.filter(r => (r.userName||'').includes(q)));
 }

 function enterRoom(room) {
   document.querySelectorAll('.chat-room-item').forEach(el => el.classList.remove('active'));
   document.querySelector(`[data-room-id="${room.chatRoomId}"]`)?.classList.add('active');
   currentRoomId = room.chatRoomId;

   document.getElementById('chatViewEmpty').style.display = 'none';
   const view = document.getElementById('chatViewMain');
   view.style.display = 'flex';

   document.getElementById('chatViewTitle').textContent = `🎧 ${room.userName || '사용자'} 님의 상담`;
   document.getElementById('chatViewSub').textContent   = `문의 시작: ${formatDate(room.createdAt)}`;

   const badge = document.getElementById('chatStatusBadge');
   if (room.status === 'CLOSED') {
     badge.className = 'chat-status-closed'; badge.textContent = '상담 종료';
   } else {
     badge.className = 'chat-status-open';   badge.textContent = '상담 중';
   }

   if (stompClient && stompClient.connected) {
     stompClient.disconnect(() => connectRoom(room.chatRoomId));
   } else {
     connectRoom(room.chatRoomId);
   }
 }

 function connectRoom(roomId) {
   const socket = new SockJS(`${ctxPath}/ws-tripan`);
   stompClient  = Stomp.over(socket);
   stompClient.debug = null;
   stompClient.connect({}, () => {
     stompClient.subscribe(`/sub/chat/room/${roomId}`, frame => {
       renderMsg(JSON.parse(frame.body));
     });
     document.getElementById('chatMessagesArea').innerHTML = '';
   });
 }

 function renderMsg(data) {
   const area = document.getElementById('chatMessagesArea');
   const isMe = String(data.memberId) === String(adminId);
   const row  = document.createElement('div');
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

 async function endChat() {
   if (!currentRoomId || !confirm('상담을 종료하시겠습니까?')) return;
   try {
     await fetch(`${ctxPath}/api/chat/rooms/${currentRoomId}/close`, { method: 'POST' });
     const badge = document.getElementById('chatStatusBadge');
     badge.className = 'chat-status-closed'; badge.textContent = '상담 종료';
     if (stompClient) stompClient.disconnect();
     loadChatRooms();
   } catch (e) { alert('상담 종료에 실패했습니다.'); }
 }

 // 유틸
 function escHtml(s) {
   if (!s) return '';
   return String(s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;');
 }
 function formatDate(v) {
   if (!v) return '';
   return new Date(v).toLocaleDateString('ko-KR', { month:'2-digit', day:'2-digit', hour:'2-digit', minute:'2-digit' });
 }

 // textarea Enter 전송
 document.getElementById('adminMsgInput').addEventListener('keydown', e => {
   if (e.key === 'Enter' && !e.shiftKey) { e.preventDefault(); sendAdminMsg(); }
 });
 document.getElementById('adminMsgInput').addEventListener('input', function() {
   this.style.height = 'auto';
   this.style.height = Math.min(this.scrollHeight, 100) + 'px';
 });

 // 모달 바깥 클릭 닫기
 document.getElementById('inquiryModal').addEventListener('click', e => {
   if (e.target === document.getElementById('inquiryModal')) closeModal();
 });

 // 초기 로드
 loadInquiries();
 setInterval(loadChatRooms, 30000);
 
 
 // 초기화
 document.addEventListener('DOMContentLoaded', () => {
   // 고객센터 탭 켜기
   const tabSupport = document.getElementById('tabSupport');
   if (tabSupport) {
       tabSupport.style.display = 'inline-block';
   }

   // 데이터 로드 실행
   loadSummary();
   loadMiniMap();
 });

 document.addEventListener("DOMContentLoaded", () => {

   // 1. 고객센터 탭 추가
   const chatTabs = document.querySelector('.chat-tabs');
   if (chatTabs && !document.getElementById('tabSupport')) {
     const supportTab = document.createElement('button');
     supportTab.id = 'tabSupport';
     supportTab.className = 'chat-tab';
     supportTab.textContent = '🎧 고객센터';
     supportTab.addEventListener('click', () => loadSupportRooms());
     chatTabs.appendChild(supportTab);
   }

   // 2. 고객센터 전용 로드 함수 (openlounge.jsp 건드리지 않음)
   window.loadSupportRooms = function() {
     document.querySelectorAll('.chat-tab').forEach(t => t.classList.remove('active'));
     const tab = document.getElementById('tabSupport');
     if (tab) tab.classList.add('active');

     const ctx = '${pageContext.request.contextPath}';

     fetch(ctx + '/admin/api/chat/rooms/support')
       .then(res => res.ok ? res.json() : Promise.reject())
       .then(rooms => {
         const listEl = document.getElementById('dynamicChatRoomList');
         if (!listEl) return;
         listEl.innerHTML = '';

         if (!rooms || rooms.length === 0) {
           listEl.innerHTML = `
             <div style="text-align:center; margin-top:40px;">
               <span style="font-size:32px; opacity:0.5;">🎧</span>
               <p style="font-size:13px; color:var(--text-gray); margin:10px 0;">진행 중인 문의 내역이 없습니다.</p>
               <button onclick="window.createSupportRoom()"
                 style="padding:10px 20px; border-radius:20px; background:var(--text-black);
                        color:white; border:none; font-weight:800; cursor:pointer;">
                 + 1:1 문의 시작하기
               </button>
             </div>`;
           return;
         }

         rooms.forEach(room => {
           const roomTitle = room.chatRoomName || '문의방';
           listEl.insertAdjacentHTML('beforeend', `
             <div class="chat-room-item" data-room-id="${room.chatRoomId}" 
                  data-room-name="${roomTitle}" data-room-type="SUPPORT">
               <div class="room-icon">🎧</div>
               <div class="room-info">
                 <h4>${roomTitle}</h4>
                 <p>1:1 고객센터 문의</p>
               </div>
             </div>
           `);
         });

         // 방 클릭 이벤트
         document.querySelectorAll('.chat-room-item').forEach(item => {
           item.addEventListener('click', function() {
             document.querySelectorAll('.chat-room-item').forEach(el => el.classList.remove('active'));
             this.classList.add('active');
             document.getElementById('chatEmptyState').style.display = 'none';
             document.getElementById('chatRoomView').style.display = 'flex';
             document.querySelector('.chat-title-info h2').innerText = '🎧 ' + this.dataset.roomName;
             document.querySelector('.chat-title-info span').style.display = 'none';
             window.connectChatRoom(this.dataset.roomId);
           });
         });
       })
       .catch(() => {
         const listEl = document.getElementById('dynamicChatRoomList');
         if (listEl) listEl.innerHTML = `
           <div style="text-align:center; margin-top:40px;">
             <span style="font-size:32px; opacity:0.5;">🎧</span>
             <p style="font-size:13px; color:var(--text-gray); margin:10px 0;">진행 중인 문의 내역이 없습니다.</p>
             <button onclick="window.createSupportRoom()"
               style="padding:10px 20px; border-radius:20px; background:var(--text-black);
                      color:white; border:none; font-weight:800; cursor:pointer;">
               1:1 문의 시작하기
             </button>
           </div>`;
       });
   };

 });
 
 function handleBackdropClick(event) {
   // 모달 내부 클릭은 무시, backdrop 자체 클릭만 닫기
   if (event.target === event.currentTarget) {
     closeModal();
   }
 }