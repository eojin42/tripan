<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<%--
  supportLounge.jsp
  - 마이페이지(또는 고객센터 탭이 필요한 페이지)에서만 include
  - openlounge.jsp / footer.jsp 건드리지 않음
  - 이 파일을 include하면 openlounge 모달에 🎧 고객센터 탭이 추가됨
--%>
<script>
(function() {
  // ✅ openlounge.jsp와 동일하게: DOM 준비 여부 체크 후 실행
  function initSupportTab() {
    const ctx = '${pageContext.request.contextPath}';

    // ── 1. 고객센터 탭 버튼 동적 추가 ──────────────────────────────
    const chatTabs = document.querySelector('.chat-tabs');
    if (chatTabs && !document.getElementById('tabSupport')) {
      const btn = document.createElement('button');
      btn.id        = 'tabSupport';
      btn.className = 'chat-tab';
      btn.textContent = '🎧 고객센터';
      btn.addEventListener('click', () => window.loadSupportRooms());
      chatTabs.appendChild(btn);
    }

    // ── 2. 고객센터 방 생성 ─────────────────────────────────────────
    window.createSupportRoom = function() {
      if (!confirm('1:1 고객센터 문의를 시작하시겠습니까?')) return;
      fetch(ctx + '/api/chat/rooms/support/create', { method: 'POST' })
        .then(res => { if (!res.ok) throw new Error(); return res.json(); })
        .then(() => window.loadSupportRooms())
        .catch(() => alert('방 생성에 실패했습니다.'));
    };

    // ── 3. 고객센터 방 목록 로드 ────────────────────────────────────
    window.loadSupportRooms = function() {
      document.querySelectorAll('.chat-tab').forEach(t => t.classList.remove('active'));
      const tab = document.getElementById('tabSupport');
      if (tab) tab.classList.add('active');

      fetch(ctx + '/api/chat/rooms/support')
        .then(res => res.ok ? res.json() : Promise.reject())
        .then(rooms => {
          const listEl = document.getElementById('dynamicChatRoomList');
          if (!listEl) return;
          listEl.innerHTML = '';

          if (!rooms || rooms.length === 0) {
            listEl.innerHTML = `
              <div style="text-align:center; margin-top:40px;">
                <span style="font-size:32px; opacity:0.5;">🎧</span>
                <p style="font-size:13px; color:var(--text-gray); margin:10px 0;">
                  진행 중인 문의 내역이 없습니다.
                </p>
                <button onclick="window.createSupportRoom()"
                  style="padding:10px 20px; border-radius:20px; background:var(--text-black);
                         color:white; border:none; font-weight:800; cursor:pointer; font-size:13px;">
                  + 1:1 문의 시작하기
                </button>
              </div>`;
            return;
          }

          rooms.forEach(room => {
            const roomTitle = room.chatRoomName || '문의방';
            listEl.insertAdjacentHTML('beforeend', `
              <div class="chat-room-item"
                   data-room-id="${room.chatRoomId}"
                   data-room-name="${roomTitle}"
                   data-room-type="SUPPORT">
                <div class="room-icon">🎧</div>
                <div class="room-info">
                  <h4>${roomTitle}</h4>
                  <p>1:1 고객센터 문의 · ${room.status === 'CLOSED' ? '종료' : '상담 중'}</p>
                </div>
              </div>`);
          });

          // ✅ openlounge.jsp의 공통 클릭 바인더 재사용 → 중복 코드 제거
          if (typeof window.bindRoomItemClick === 'function') {
            window.bindRoomItemClick();
          }
        })
        .catch(() => {
          const listEl = document.getElementById('dynamicChatRoomList');
          if (listEl) listEl.innerHTML = `
            <div style="text-align:center; margin-top:40px;">
              <span style="font-size:32px; opacity:0.5;">🎧</span>
              <p style="font-size:13px; color:var(--text-gray); margin:10px 0;">
                목록을 불러오지 못했습니다.
              </p>
              <button onclick="window.createSupportRoom()"
                style="padding:10px 20px; border-radius:20px; background:var(--text-black);
                       color:white; border:none; font-weight:800; cursor:pointer; font-size:13px;">
                + 1:1 문의 시작하기
              </button>
            </div>`;
        });
    };
  }

  // DOM 준비 여부에 따라 즉시 or 대기
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initSupportTab);
  } else {
    initSupportTab();
  }
})();
</script>
