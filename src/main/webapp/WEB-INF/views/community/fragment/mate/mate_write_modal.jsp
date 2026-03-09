<%@ page contentType="text/html; charset=UTF-8" %>

<div id="mateWriteModal" class="lounge-modal-overlay">
  <div class="lounge-modal-content glass-card" style="max-width: 650px;">
    <div class="lounge-modal-header">
      <h3>🤝 새로운 동행 찾기</h3>
      <button class="btn-close-modal" onclick="closeMateModal()">✕</button>
    </div>
    
    <div class="lounge-editor" style="gap: 16px;">
      <div style="display: flex; gap: 12px;">
        <div class="custom-select-wrapper" style="flex: 1;">
          <select id="mateRegion" class="lounge-input-style" style="appearance: none; cursor: pointer;">
            <option value="">📍 어디로 가시나요?</option>
          </select>
        </div>
        <div style="flex: 1;">
          <input type="number" id="mateCount" class="lounge-input-style" placeholder="🙋 모집 인원 (숫자만)" min="1" max="10">
        </div>
      </div>

      <div style="display: flex; gap: 12px; align-items: center;">
        <input type="date" id="mateStartDate" class="lounge-input-style" title="가는 날">
        <span style="font-weight: bold; color: var(--text-gray);">~</span>
        <input type="date" id="mateEndDate" class="lounge-input-style" title="오는 날">
      </div>

      <input type="text" id="mateTitle" class="lounge-input-style" placeholder="동행 모집 제목을 입력하세요 (예: 제주도 렌트카 쉐어하실 분!)">
      <textarea id="mateTextarea" class="lounge-input-style" placeholder="어떤 여행을 계획 중이신가요? 원하는 동행의 조건(성별/연령대 등)이나 여행 스타일을 자세히 적어주세요!" style="min-height: 150px;"></textarea>
      <input type="text" id="mateTags" class="lounge-input-style" placeholder="🏷️ 해시태그 입력 (쉼표로 구분. 예: #20대, #맛집탐방)">
    </div>

    <div class="lounge-toolbar" style="justify-content: flex-end;">
      <button class="btn-submit-lounge" onclick="submitMatePost()">🚀 동행 모집 시작하기</button>
    </div>
  </div>
</div>

<script>
// 🌟 여기서부터 모든 스크립트를 전역(window) 객체에 달아서 AJAX 렌더링 시에도 절대 뻗지 않도록 방어했습니다.
const CURRENT_USER_ID = '${sessionScope.loginUser != null ? sessionScope.loginUser.memberId : ""}';
let cachedRegions = null;

window.fillRegionSelect = async function(elementId) {
    const selectEl = document.getElementById(elementId);
    if (!selectEl || selectEl.children.length > 1) return; 
    try {
        if (!cachedRegions) cachedRegions = await TripanAPI.getSidoRegions();
        let optionsHtml = '';
        cachedRegions.forEach(sido => {
            const id = sido.regionId || sido.REGIONID || sido.region_id;
            const name = sido.sidoName || sido.NAME || sido.sido_name || sido.name;
            optionsHtml += `<option value="\${id}">\${name}</option>`;
        });
        selectEl.insertAdjacentHTML('beforeend', optionsHtml);
    } catch (error) { console.error("지역 세팅 실패:", error); }
};

window.populateRegionSelects = async function() { await fillRegionSelect('filterRegion'); };

window.openMateModal = function() {
    fillRegionSelect('mateRegion');
    document.getElementById('mateWriteModal').classList.add('active');
};

window.closeMateModal = function() {
    document.getElementById('mateWriteModal').classList.remove('active');
};

window.submitMatePost = function() {
    if (typeof IS_LOGGED_IN !== 'undefined' && !IS_LOGGED_IN) { showLoginModal(); return; }

    const requestData = {
        regionId: document.getElementById('mateRegion').value,
        targetCount: document.getElementById('mateCount').value,
        startDate: document.getElementById('mateStartDate').value,
        endDate: document.getElementById('mateEndDate').value,
        title: document.getElementById('mateTitle').value,
        content: document.getElementById('mateTextarea').value,
        tags: document.getElementById('mateTags').value
    };

    if(!requestData.regionId || !requestData.targetCount || !requestData.startDate || !requestData.endDate || !requestData.title.trim() || !requestData.content.trim()) {
      alert("모든 필수 항목을 입력해주세요!"); return;
    }

    fetch('${pageContext.request.contextPath}/community/mate/write', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json', 'X-Requested-With': 'Fetch', 'AJAX': 'true' },
        body: JSON.stringify(requestData)
    })
    .then(res => {
        if (res.status === 401) { showLoginModal(); throw new Error('Unauthorized'); }
        if (!res.ok) throw new Error('서버 응답 에러');
        return res.json();
    })
    .then(result => {
        if(result.status === 'success') {
            alert(result.message); closeMateModal(); window.searchMates(); 
            document.querySelectorAll('#mateWriteModal input, #mateWriteModal textarea, #mateWriteModal select').forEach(el => el.value = '');
        } else { alert(result.message); }
    }).catch(err => { if (err.message !== 'Unauthorized') alert("글 등록 에러"); });
};

window.searchMates = function() {
    const region = document.getElementById('filterRegion') ? document.getElementById('filterRegion').value : '';
    const startDate = document.getElementById('filterStartDate') ? document.getElementById('filterStartDate').value : '';
    const endDate = document.getElementById('filterEndDate') ? document.getElementById('filterEndDate').value : '';
    const tag = document.getElementById('filterTag') ? document.getElementById('filterTag').value : '';

    const url = '${pageContext.request.contextPath}/community/api/mate/list?regionId=' + region + '&startDate=' + startDate + '&endDate=' + endDate + '&searchTag=' + encodeURIComponent(tag);
    
    fetch(url).then(res => res.json()).then(list => {
        const container = document.getElementById('mateListContainer');
        if (!container) return; 

        if (list.length === 0) {
            container.innerHTML = '<div style="text-align:center; padding: 60px; color: var(--text-gray); font-weight: bold;">조건에 맞는 동행 글이 없습니다. 😢</div>';
            return;
        }

        let html = '';
        list.forEach(mate => {
            let profileImg = mate.profilePhoto ? '${pageContext.request.contextPath}/uploads/profile/' + mate.profilePhoto : '${pageContext.request.contextPath}/dist/images/default.png';
            let statusBadge = mate.status === 'OPEN' ? '<span class="badge-status status-on">🟢 모집중</span>' : '<span class="badge-status status-off">⚪ 모집마감</span>';
            let tagsHtml = '';
            if (mate.tags) mate.tags.split(',').forEach(t => { if (t.trim() !== '') tagsHtml += `<span class="m-tag">\${t.trim()}</span>`; });

            let isMyPost = (CURRENT_USER_ID !== '' && CURRENT_USER_ID == mate.memberId);
            let statusToggleButton = isMyPost ? (mate.status === 'OPEN' 
                ? `<button class="btn-status-toggle" onclick="event.stopPropagation(); window.toggleMateStatus(\${mate.mateId}, 'CLOSED')">마감하기</button>`
                : `<button class="btn-status-toggle closed" onclick="event.stopPropagation(); window.toggleMateStatus(\${mate.mateId}, 'OPEN')">모집재개</button>`) : '';

            html += `
            <div class="mate-card" id="mate-card-\${mate.mateId}">
              <div class="mate-card-header" style="cursor: pointer;" onclick="window.toggleMateDetail(\${mate.mateId})">
                <div class="mate-info">
                  <div class="mate-badges">\${statusBadge}<span class="mate-region">\${mate.sidoName || '전체'}</span></div>
                  <h3 class="mate-card-title">\${mate.title}</h3>
                  <div class="mate-meta"><span>🗓️ \${mate.startDate} ~ \${mate.endDate}</span><span style="margin-left:8px;">🙋 \${mate.targetCount}명 모집</span></div>
                  <div class="mate-tags">\${tagsHtml}</div>
                </div>
                <div class="mate-action">
                  <div style="display:flex; justify-content:flex-end; align-items:center; gap:6px; width:100%; margin-bottom:8px;">
                    \${statusToggleButton}
                    <button class="btn-collapse" onclick="event.stopPropagation(); window.toggleMateDetail(\${mate.mateId})" title="접기">▲</button>
                  </div>
                  <div class="mate-user">
                    <img src="\${profileImg}" alt="user" style="width: 32px; height: 32px; border-radius: 50%; object-fit: cover;"><span>\${mate.nickname || '여행자'}</span>
                  </div>
                </div>
              </div>

              <div class="mate-detail-area" id="mate-detail-\${mate.mateId}">
                <div style="background: rgba(137, 207, 240, 0.05); padding: 20px; border-radius: 12px; font-size: 14px; line-height: 1.6; color: var(--text-dark); margin-bottom: 24px; border: 1px solid rgba(137,207,240,0.2); white-space: pre-wrap; word-break: break-all;">\${mate.content}</div>

                <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom: 12px;">
                    <h4 style="margin: 0; font-size: 15px; color:var(--text-black);">💬 댓글 <span id="comment-count-\${mate.mateId}" style="color:var(--sky-blue);">0</span></h4>
                    <button class="btn-apply" onclick="window.startPrivateChat(\${mate.memberId}, '\${mate.nickname}')">✉️ 작성자에게 톡 보내기</button>
                </div>

                <div class="comment-list" id="comment-list-\${mate.mateId}" style="display: flex; flex-direction: column; gap: 12px; margin-bottom: 16px;"></div>

                <div style="display: flex; gap: 8px;">
                    <input type="text" id="comment-input-\${mate.mateId}" class="lounge-input-style" placeholder="동행에 대해 궁금한 점을 남겨보세요!" style="flex: 1; padding: 10px 14px;">
                    <button class="btn-submit-lounge" style="padding: 10px 24px; border-radius: 8px;" onclick="window.submitMateComment(\${mate.mateId})">등록</button>
                </div>
              </div>
            </div>`;
        });
        container.innerHTML = html;
    }).catch(err => {
        const container = document.getElementById('mateListContainer');
        if(container) container.innerHTML = '<div style="text-align:center; color:#FF6B6B; font-weight:bold; padding: 50px;">데이터를 불러오는데 실패했습니다.</div>';
    });
};

window.toggleMateDetail = function(mateId) {
    const card = document.getElementById('mate-card-' + mateId);
    if (card.classList.contains('expanded')) { card.classList.remove('expanded'); return; }
    document.querySelectorAll('.mate-card.expanded').forEach(el => el.classList.remove('expanded'));
    card.classList.add('expanded');
    window.loadMateComments(mateId, 1);
};

window.submitMateComment = function(mateId, parentId = null) {
    if (typeof IS_LOGGED_IN !== 'undefined' && !IS_LOGGED_IN) { showLoginModal(); return; }
    const inputEl = document.getElementById(parentId ? 'reply-input-' + parentId : 'comment-input-' + mateId);
    const content = inputEl.value.trim();
    if(content === '') { alert('내용을 입력해주세요!'); inputEl.focus(); return; }

    fetch('${pageContext.request.contextPath}/community/api/mate/comment/add', {
        method: 'POST', headers: { 'Content-Type': 'application/json', 'X-Requested-With': 'Fetch' },
        body: JSON.stringify({ mateId: mateId, content: content, parentId: parentId })
    })
    .then(res => res.json()).then(result => {
        if (result.status === 'success') { inputEl.value = ''; window.loadMateComments(mateId, 1); } 
        else { alert(result.message); }
    }).catch(err => alert('댓글 등록에 실패했습니다.'));
};

window.deleteMateComment = function(commentId, mateId) {
    if (!confirm('정말 삭제하시겠습니까?\\n(원본 댓글인 경우 답글도 함께 삭제됩니다)')) return;
    fetch('${pageContext.request.contextPath}/community/api/mate/comment/delete/' + commentId, {
        method: 'POST', headers: { 'X-Requested-With': 'Fetch' }
    }).then(res => res.json()).then(result => {
        if(result.status === 'success') window.loadMateComments(mateId, 1); else alert(result.message);
    }).catch(err => alert('삭제 중 오류가 발생했습니다.'));
};

window.toggleReplyForm = function(commentId) {
    const form = document.getElementById('reply-form-' + commentId);
    if (form.style.display === 'none') { form.style.display = 'flex'; document.getElementById('reply-input-' + commentId).focus(); } 
    else { form.style.display = 'none'; }
};

window.loadMateComments = function(mateId, page) {
    if (!page) page = 1;
    const listContainer = document.getElementById('comment-list-' + mateId);
    const countSpan = document.getElementById('comment-count-' + mateId);

    fetch('${pageContext.request.contextPath}/community/api/mate/' + mateId + '/comments?page=' + page)
    .then(res => res.json())
    .then(data => {
        countSpan.innerText = data.totalCount || 0; 
        if (!data.comments || data.comments.length === 0) {
            listContainer.innerHTML = '<div style="text-align:center; font-size:13px; color:var(--text-gray); padding: 30px 0;">첫 번째 댓글을 남겨보세요! 💬</div>'; return;
        }

        let html = '';
        data.comments.forEach(comment => {
            let profileImg = comment.profilePhoto ? '${pageContext.request.contextPath}/uploads/profile/' + comment.profilePhoto : '${pageContext.request.contextPath}/dist/images/default.png';
            let isMyComment = (CURRENT_USER_ID !== '' && CURRENT_USER_ID == comment.memberId);
            let kebabMenu = isMyComment 
                ? `<button class="kebab-item danger" onclick="window.deleteMateComment(\${comment.commentId}, \${mateId})">🗑️ 삭제하기</button>`
                : `<button class="kebab-item danger" onclick="alert('해당 댓글을 신고합니다.')">🚨 신고하기</button>`;

            html += `
            <div style="display: flex; flex-direction: column; gap: 10px; border-bottom: 1px dashed var(--border-color); padding-bottom: 12px; margin-bottom: 12px;">
              <div style="display: flex; gap: 10px;">
                <img src="\${profileImg}" style="width: 32px; height: 32px; border-radius: 50%; object-fit: cover; border: 1px solid var(--border-color);">
                <div style="flex: 1;">
                    <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 4px;">
                        <span style="font-size: 13px; font-weight: 800; color: var(--text-dark);">\${comment.nickname || '여행자'}</span>
                        <div style="display: flex; align-items: center; gap: 8px;">
                            <span style="font-size: 11px; color: var(--text-gray);">\${comment.createdAt}</span>
                            <span style="font-size: 11px; color: var(--sky-blue); font-weight: 900; cursor: pointer;" onclick="window.toggleReplyForm(\${comment.commentId})">↳ 답글</span>
                            <div class="comment-options" style="position: relative;">
                                <button class="btn-kebab" onclick="window.toggleDropdown(this, event)"><svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round" style="pointer-events: none;"><circle cx="12" cy="5" r="1.5"></circle><circle cx="12" cy="12" r="1.5"></circle><circle cx="12" cy="19" r="1.5"></circle></svg></button>
                                <div class="kebab-menu-list" style="display: none; position: absolute; right: 0; top: 100%; background: white; border: 1px solid var(--border-color); border-radius: 8px; box-shadow: 0 4px 12px rgba(0,0,0,0.15); min-width: 110px; z-index: 99999; margin-top: 4px;">
                                    <button class="kebab-item" onclick="window.startPrivateChat(\${comment.memberId}, '\${comment.nickname}')">💬 대화하기</button>
                                    <div class="kebab-divider"></div>
                                    \${kebabMenu}
                                </div>
                            </div>
                        </div>
                    </div>
                    <div style="font-size: 13px; color: var(--text-black); line-height: 1.4; white-space: pre-wrap;">\${comment.content}</div>
                </div>
              </div>`;

            (data.childComments || []).filter(c => c.parentId === comment.commentId).forEach(child => {
                let cProfileImg = child.profilePhoto ? '${pageContext.request.contextPath}/uploads/profile/' + child.profilePhoto : '${pageContext.request.contextPath}/dist/images/default.png';
                let isMyChild = (CURRENT_USER_ID !== '' && CURRENT_USER_ID == child.memberId);
                let childKebab = isMyChild 
                    ? `<button class="kebab-item danger" onclick="window.deleteMateComment(\${child.commentId}, \${mateId})">🗑️ 삭제하기</button>`
                    : `<button class="kebab-item danger" onclick="alert('해당 댓글을 신고합니다.')">🚨 신고하기</button>`;

                html += `
                <div style="display: flex; gap: 8px; margin-left: 36px; margin-top: 4px; padding: 10px 14px; background: rgba(137, 207, 240, 0.05); border-radius: 12px;">
                  <span style="color: var(--sky-blue); font-weight: 900; font-size: 14px;">↳</span>
                  <img src="\${cProfileImg}" style="width: 28px; height: 28px; border-radius: 50%; object-fit: cover; border: 1px solid white;">
                  <div style="flex: 1;">
                      <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 2px;">
                          <span style="font-size: 12px; font-weight: 800; color: var(--text-dark);">\${child.nickname || '여행자'}</span>
                          <div style="display: flex; align-items: center; gap: 4px;">
                              <span style="font-size: 10px; color: var(--text-gray);">\${child.createdAt}</span>
                              <div class="comment-options" style="position: relative;">
                                  <button class="btn-kebab" onclick="window.toggleDropdown(this, event)"><svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round" style="pointer-events: none;"><circle cx="12" cy="5" r="1.5"></circle><circle cx="12" cy="12" r="1.5"></circle><circle cx="12" cy="19" r="1.5"></circle></svg></button>
                                  <div class="kebab-menu-list" style="display: none; position: absolute; right: 0; top: 100%; background: white; border: 1px solid var(--border-color); border-radius: 8px; box-shadow: 0 4px 12px rgba(0,0,0,0.15); min-width: 100px; z-index: 99999; margin-top: 4px;">
                                      <button class="kebab-item" onclick="window.startPrivateChat(\${child.memberId}, '\${child.nickname}')">💬 대화하기</button>
                                      <div class="kebab-divider"></div>
                                      \${childKebab}
                                  </div>
                              </div>
                          </div>
                      </div>
                      <div style="font-size: 12px; color: var(--text-black); line-height: 1.4; white-space: pre-wrap;">\${child.content}</div>
                  </div>
                </div>`;
            });

            html += `
              <div id="reply-form-\${comment.commentId}" style="display: none; gap: 8px; margin-left: 36px; margin-top: 4px;">
                  <input type="text" id="reply-input-\${comment.commentId}" class="lounge-input-style" placeholder="\${comment.nickname || '여행자'}님에게 답글 남기기..." style="flex: 1; padding: 10px 14px; font-size: 13px;">
                  <button class="btn-submit-lounge" style="padding: 10px 20px; border-radius: 8px; font-size: 13px;" onclick="window.submitMateComment(\${mateId}, \${comment.commentId})">등록</button>
              </div>
            </div>`;
        });

        if (data.totalPages > 1) {
            let pageHtml = '<div style="display: flex; justify-content: center; gap: 8px; margin-top: 10px;">';
            for (let i = 1; i <= data.totalPages; i++) {
                let activeStyle = (i === data.currentPage) ? 'background: var(--sky-blue); color: white; box-shadow: 0 2px 6px rgba(137,207,240,0.4);' : 'background: #f1f5f9; color: var(--text-gray);';
                pageHtml += `<button style="border: none; width: 28px; height: 28px; border-radius: 50%; font-size: 12px; font-weight: 900; cursor: pointer; transition: 0.2s; \${activeStyle}" onclick="window.loadMateComments(\${mateId}, \${i})">\${i}</button>`;
            }
            pageHtml += '</div>';
            html += pageHtml;
        }
        listContainer.innerHTML = html;
    }).catch(err => { listContainer.innerHTML = '<div style="text-align:center; font-size:12px; color:#FF6B6B; padding: 10px 0;">댓글 로딩 실패</div>'; });
};

window.toggleDropdown = function(btn, event) {
    event.preventDefault(); event.stopPropagation();
    const dropdown = btn.nextElementSibling;
    const isCurrentlyShowing = (dropdown.style.display === 'block');
    document.querySelectorAll('.kebab-menu-list').forEach(menu => menu.style.display = 'none');
    if (!isCurrentlyShowing) dropdown.style.display = 'block';
};

document.addEventListener('click', function(e) {
    document.querySelectorAll('.kebab-menu-list').forEach(menu => menu.style.display = 'none');
});

window.toggleMateStatus = function(mateId, targetStatus) {
    let msg = targetStatus === 'CLOSED' ? '모집을 마감하시겠습니까?' : '모집을 다시 시작하시겠습니까?';
    if(!confirm(msg)) return;
    fetch('${pageContext.request.contextPath}/community/api/mate/' + mateId + '/status?status=' + targetStatus, { method: 'POST', headers: { 'X-Requested-With': 'Fetch' } })
    .then(res => res.json()).then(result => { if(result.status === 'success') window.searchMates(); else alert(result.message); })
    .catch(err => console.error('상태 변경 에러:', err));
};

window.startPrivateChat = function(targetMemberId, targetNickname) {
    if (typeof IS_LOGGED_IN !== 'undefined' && !IS_LOGGED_IN) { showLoginModal(); return; }
    if(CURRENT_USER_ID == targetMemberId) { alert("나 자신과는 1:1 대화를 할 수 없습니다!"); return; }

    const url = '/community/api/chat/private?targetId=' + targetMemberId;
    
	fetch('/community/api/chat/private?targetId=' + targetMemberId, {
	    method: 'POST',
	    headers: { 'X-Requested-With': 'Fetch' }
	})
    .then(res => { if(!res.ok) throw new Error("방 생성 실패"); return res.json(); })
    .then(data => {
        if(data.roomId) {
            window.openGlobalChat();
            document.getElementById('chatEmptyState').style.display = 'none';
            document.getElementById('chatRoomView').style.display = 'flex';
            document.querySelector('.chat-title-info h2').innerText = '💬 @' + targetNickname + ' 님과의 대화';
            const countSpan = document.querySelector('.chat-title-info span');
            if(countSpan) countSpan.style.display = 'none';
            if(typeof connectChatRoom === 'function') connectChatRoom(data.roomId);
        }
    }).catch(err => console.error("채팅방 연결 오류:", err));
};
</script>