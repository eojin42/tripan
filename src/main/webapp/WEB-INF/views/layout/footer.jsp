<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

  <footer class="reveal">
    <div class="footer-top">
      <div class="footer-company-info">
        <div class="brand-logo" style="font-size: 30px; margin-bottom: 16px;">
          <div class="logo-text-wrapper">
            <span class="trip" style="color: var(--text-black); text-shadow: none;">Tri</span><span class="an">pan</span>
            <div class="logo-track">
              <div class="logo-line"></div>
              <svg class="logo-plane" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                <path d="M22,16v-2l-8.5-5V3.5C13.5,2.67 12.83,2 12,2s-1.5,0.67-1.5,1.5V9L2,14v2l8.5-2.5V19L8.5,20.5V22L12,21l3.5,1v-1.5L13.5,19v-5.5L22,16z" />
              </svg>
            </div>
          </div>
          <span class="logo-dot">.</span>
        </div>
        <p class="footer-desc">함께 노는 여행 플래너 & 정산 솔루션</p>
        <p class="footer-address">
          주식회사 스프링 (Tripan Project)<br>
          서울특별시 강남구 테헤란로 123, 4층<br>
          대표: 조장님 | 사업자등록번호: 123-45-67890<br>
          고객센터: 1588-0000
        </p>
      </div>

      <div class="footer-links">
        <div class="footer-links-col">
          <strong>SERVICE</strong>
          <a href="#">AI 추천 일정 만들기</a>
          <a href="#">실시간 공동 편집 가이드</a>
          <a href="#">여행 가계부 & N빵 정산</a>
          <a href="#">소셜 여행기 커뮤니티</a>
        </div>
        <div class="footer-links-col">
          <strong>PARTNERS</strong>
          <a href="#">입점사(숙소/티켓) 관리자 센터</a>
          <a href="#">B2B 제휴 및 수수료 안내</a>
          <a href="#">광고 및 마케팅 문의</a>
        </div>
        <div class="footer-links-col">
          <strong>SUPPORT</strong>
          <a href="#">고객센터 (FAQ)</a>
          <a href="#">공지사항</a>
          <a href="#">이용약관</a>
          <a href="#">개인정보처리방침</a>
        </div>
      </div>
    </div>

    <div class="footer-bottom">
      <p>© 2026 SPRING Corp. / Tripan Project. All rights reserved.</p>
      <div class="social-links">
        <a href="#" aria-label="Instagram">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="2" y="2" width="20" height="20" rx="5" ry="5"></rect><path d="M16 11.37A4 4 0 1 1 12.63 8 4 4 0 0 1 16 11.37z"></path><line x1="17.5" y1="6.5" x2="17.51" y2="6.5"></line></svg>
        </a>
        <a href="#" aria-label="YouTube">
          <svg viewBox="0 0 24 24" fill="currentColor"><path d="M23.498 6.186a3.016 3.016 0 0 0-2.122-2.136C19.505 3.545 12 3.545 12 3.545s-7.505 0-9.377.505A3.017 3.017 0 0 0 .502 6.186C0 8.07 0 12 0 12s0 3.93.502 5.814a3.016 3.016 0 0 0 2.122 2.136c1.871.505 9.376.505 9.376.505s7.505 0 9.377-.505a3.015 3.015 0 0 0 2.122-2.136C24 15.93 24 12 24 12s0-3.93-.502-5.814zM9.545 15.568V8.432L15.818 12l-6.273 3.568z"/></svg>
        </a>
        <a href="#" aria-label="X (Twitter)">
          <svg viewBox="0 0 24 24" fill="currentColor"><path d="M18.244 2.25h3.308l-7.227 8.26 8.502 11.24H16.17l-5.214-6.817L4.99 21.75H1.68l7.73-8.835L1.254 2.25H8.08l4.713 6.231zm-1.161 17.52h1.833L7.084 4.126H5.117z"/></svg>
        </a>
      </div>
    </div>
  </footer>
  
  <jsp:include page="footerResources.jsp"/>

  <script>
  window.loadRoomList = function(type) {
	    // 모든 탭의 활성화 상태 해제
	    document.querySelectorAll('.chat-tab').forEach(tab => tab.classList.remove('active'));
	    
	    let url = contextPath;
	    
	    // 누른 탭에 따라 주소와 버튼 색상 변경
	    if (type === 'REGION') {
	        const tab = document.getElementById('tabRegion');
	        if(tab) tab.classList.add('active');
	        url += '/api/chat/rooms/region'; 
	    } else if (type === 'PRIVATE') {
	        const tab = document.getElementById('tabPrivate');
	        if(tab) tab.classList.add('active');
	        url += '/api/chat/rooms/private'; 
	    } else if (type === 'SUPPORT') {
	        const tab = document.getElementById('tabSupport');
	        if(tab) tab.classList.add('active');
	        url += '/api/chat/rooms/support'; // 백엔드 고객센터 API
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
	        
	        // 방이 없을 때의 처리 (고객센터는 생성 버튼)
	        if(!rooms || rooms.length === 0) {
	            if (type === 'SUPPORT') {
	                listEl.innerHTML = `
	                    <div style="text-align:center; margin-top:40px;">
	                        <span style="font-size:32px; opacity:0.5;">🎧</span>
	                        <p style="font-size:13px; color:var(--text-gray); margin:10px 0;">진행 중인 문의 내역이 없습니다.</p>
	                        <button onclick="createSupportRoom()" style="padding:10px 20px; border-radius:20px; background:var(--text-black); color:white; border:none; font-weight:800; cursor:pointer; transition:0.2s;">+ 1:1 문의 시작하기</button>
	                    </div>
	                `;
	            } else {
	                listEl.innerHTML = '<p style="text-align:center; font-size:12px; color:var(--text-gray); margin-top:20px;">참여 중인 대화방이 없습니다.</p>';
	            }
	            return;
	        }

	        // 아이콘 동적 할당
	        const icons = type === 'REGION' ? ['🌴', '🌊', '🏔️', '🌃', '🎎'] : 
	                      type === 'SUPPORT' ? ['🎧'] : 
	                      ['👤', '😎', '👨‍🚀', '👩‍🎤', '👽'];

	        rooms.forEach((room, index) => {
	            const icon = icons[index % icons.length];
	            const roomTitle = room.chatRoomName || '이름 없음';
	            const desc = type === 'REGION' ? '다같이 떠드는 라운지' : 
	                         type === 'SUPPORT' ? 'Tripan 24시간 공식 고객센터' : '1:1 비밀 대화방';

	            const html = `
	              <div class="chat-room-item" data-room-id="${room.chatRoomId}" data-room-name="${roomTitle}" data-room-type="${type}">
	                <div class="room-icon">${icon}</div>
	                <div class="room-info">
	                  <h4>${roomTitle}</h4>
	                  <p>${desc}</p>
	                </div>
	              </div>
	            `;
	            listEl.insertAdjacentHTML('beforeend', html);
	        });

	        // 5. 방 클릭 이벤트
	        document.querySelectorAll('.chat-room-item').forEach(item => {
	            item.addEventListener('click', function() {
	                document.querySelectorAll('.chat-room-item').forEach(el => el.classList.remove('active'));
	                this.classList.add('active');
	                emptyState.style.display = 'none';
	                roomView.style.display = 'flex';

	                const roomId = this.getAttribute('data-room-id'); 
	                const roomName = this.getAttribute('data-room-name');
	                const roomType = this.getAttribute('data-room-type');
	                
	                // 고객센터일 때는 방 제목 앞에 헤드셋 아이콘을 붙여줌!
	                document.querySelector('.chat-title-info h2').innerText = 
	                    (roomType === 'REGION' ? '🌴 #' : roomType === 'SUPPORT' ? '🎧 ' : '💬 @') + roomName;
	                
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

	// 고객센터 방 생성 버튼 기능
	window.createSupportRoom = function() {
	    if (!confirm('새로운 1:1 고객센터 문의 방을 개설하시겠습니까?')) return;
	    
	    // 백엔드 방 생성 API (POST) 호출
	    fetch(contextPath + '/api/chat/rooms/support/create', { method: 'POST' })
	    .then(res => {
	        if(!res.ok) throw new Error("방 생성 실패");
	        return res.json();
	    })
	    .then(data => {
	        // 생성 성공 시 고객센터 탭 다시 새로고침
	        loadRoomList('SUPPORT');
	    })
	    .catch(err => {
	        alert('백엔드 API가 아직 연결되지 않았습니다! (컨트롤러를 확인해주세요)');
	    });
  </script>
  
  <jsp:include page="/WEB-INF/views/community/chat/openlounge.jsp"/>
  
</body>
</html>