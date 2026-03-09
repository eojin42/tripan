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

const CURRENT_USER_ID = '${sessionScope.loginUser != null ? sessionScope.loginUser.memberId : ""}';

  function openMateModal() {
    document.getElementById('mateWriteModal').classList.add('active');
  }
  
  function closeMateModal() {
    document.getElementById('mateWriteModal').classList.remove('active');
  }

  function submitMatePost() {
    if (typeof IS_LOGGED_IN !== 'undefined' && !IS_LOGGED_IN) {
        showLoginModal();
        return;
    }

    const region = document.getElementById('mateRegion').value;
    const count = document.getElementById('mateCount').value;
    const start = document.getElementById('mateStartDate').value;
    const end = document.getElementById('mateEndDate').value;
    const title = document.getElementById('mateTitle').value;
    const content = document.getElementById('mateTextarea').value;
    const tags = document.getElementById('mateTags').value; 

    if(!region || !count || !start || !end || !title.trim() || !content.trim()) {
      alert("모든 필수 항목을 입력해주세요!");
      return;
    }

    const requestData = {
        regionId: region,
        targetCount: count,
        startDate: start,
        endDate: end,
        title: title,
        content: content,
        tags: tags
    };

    fetch('${pageContext.request.contextPath}/community/mate/write', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
            'X-Requested-With': 'Fetch',
            'AJAX': 'true' 
        },
        credentials: 'include',
        body: JSON.stringify(requestData)
    })
    .then(response => {
        if (response.status === 401) {
            showLoginModal();
            throw new Error('Unauthorized'); 
        }
        if (!response.ok) {
            throw new Error('서버 응답 에러');
        }
        return response.json();
    })
    .then(result => {
        if(result.status === 'success') {
            alert(result.message);
            closeMateModal();  
            searchMates(); 
            
            document.getElementById('mateRegion').value = '';
            document.getElementById('mateCount').value = '';
            document.getElementById('mateStartDate').value = '';
            document.getElementById('mateEndDate').value = '';
            document.getElementById('mateTitle').value = '';
            document.getElementById('mateTextarea').value = '';
            document.getElementById('mateTags').value = '';
        } else {
            alert(result.message);
        }
    })
    .catch(error => {
        if (error.message !== 'Unauthorized') {
            console.error("Error:", error);
            alert("글 등록 중 통신 오류가 발생했습니다.");
        }
    });
  }

  function searchMates() {
    const region = document.getElementById('filterRegion') ? document.getElementById('filterRegion').value : '';
    const startDate = document.getElementById('filterStartDate') ? document.getElementById('filterStartDate').value : '';
    const endDate = document.getElementById('filterEndDate') ? document.getElementById('filterEndDate').value : '';
    const tag = document.getElementById('filterTag') ? document.getElementById('filterTag').value : '';

    const url = '${pageContext.request.contextPath}/community/api/mate/list' + 
                '?regionId=' + region + 
                '&startDate=' + startDate + 
                '&endDate=' + endDate + 
                '&searchTag=' + encodeURIComponent(tag);
    
    fetch(url)
    .then(res => res.json())
    .then(list => {
        const container = document.getElementById('mateListContainer');
        if (!container) return; 

        if (list.length === 0) {
            container.innerHTML = '<div style="text-align:center; padding: 60px; color: var(--text-gray); font-weight: bold;">조건에 맞는 동행 글이 없습니다. 😢<br>첫 번째 모집글을 작성해보세요!</div>';
            return;
        }

        let html = '';
        list.forEach(mate => {
            let profileImg = mate.profilePhoto ? 
                '${pageContext.request.contextPath}/uploads/profile/' + mate.profilePhoto : 
                '${pageContext.request.contextPath}/dist/images/default.png';
            
                let statusBadge = mate.status === 'OPEN' ? 
                    '<span class="badge-status status-on">🟢 모집중</span>' : 
                    '<span class="badge-status status-off">⚪ 모집마감</span>';
                
                let tagsHtml = '';
                if (mate.tags) {
                    mate.tags.split(',').forEach(t => {
                        if (t.trim() !== '') tagsHtml += `<span class="m-tag">\${t.trim()}</span>`;
                    });
                }

                let isMyPost = (CURRENT_USER_ID !== '' && CURRENT_USER_ID == mate.memberId);
                let statusToggleButton = '';
                if (isMyPost) {
                    if (mate.status === 'OPEN') {
                        statusToggleButton = `<button class="btn-status-toggle" onclick="event.stopPropagation(); toggleMateStatus(\${mate.mateId}, 'CLOSED')">마감하기</button>`;
                    } else {
                        statusToggleButton = `<button class="btn-status-toggle closed" onclick="event.stopPropagation(); toggleMateStatus(\${mate.mateId}, 'OPEN')">모집재개</button>`;
                    }
                }

                html += `
                <div class="mate-card" id="mate-card-\${mate.mateId}">
                  <div class="mate-card-header" style="cursor: pointer;" onclick="toggleMateDetail(\${mate.mateId})">
                    <div class="mate-info">
                      <div class="mate-badges">
                        \${statusBadge}
                        <span class="mate-region">\${mate.sidoName || '전체'}</span>
                      </div>
                      <h3 class="mate-card-title">\${mate.title}</h3>
                      <div class="mate-meta">
                        <span>🗓️ \${mate.startDate} ~ \${mate.endDate}</span>
                        <span style="margin-left:8px;">🙋 \${mate.targetCount}명 모집</span>
                      </div>
                      <div class="mate-tags">\${tagsHtml}</div>
                    </div>
                    
                    <div class="mate-action">
                      <div style="display:flex; justify-content:flex-end; align-items:center; gap:6px; width:100%; margin-bottom:8px;">
                        \${statusToggleButton}
                        <button class="btn-collapse" onclick="event.stopPropagation(); toggleMateDetail(\${mate.mateId})" title="접기">▲</button>
                      </div>
                      <div class="mate-user">
                        <img src="\${profileImg}" alt="user" style="width: 32px; height: 32px; border-radius: 50%; object-fit: cover;">
                        <span>\${mate.nickname || '여행자'}</span>
                      </div>
                    </div>
                  </div>

              <div class="mate-detail-area" id="mate-detail-\${mate.mateId}">
                
                <div style="background: rgba(137, 207, 240, 0.05); padding: 20px; border-radius: 12px; font-size: 14px; line-height: 1.6; color: var(--text-dark); margin-bottom: 24px; border: 1px solid rgba(137,207,240,0.2); white-space: pre-wrap; word-break: break-all;">\${mate.content}</div>

                <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom: 12px;">
                    <h4 style="margin: 0; font-size: 15px; color:var(--text-black);">💬 댓글 <span id="comment-count-\${mate.mateId}" style="color:var(--sky-blue);">2</span></h4>
                    <button class="btn-apply" style="width: auto; padding: 6px 16px;" onclick="alert('\${mate.nickname}님과 1:1 톡방을 개설합니다! (구현 예정)')">✉️ 작성자에게 톡 보내기</button>
                </div>

                <div class="comment-list" id="comment-list-\${mate.mateId}" style="display: flex; flex-direction: column; gap: 12px; margin-bottom: 16px;">
					<div style="display: flex; gap: 10px; border-bottom: 1px dashed var(--border-color); padding-bottom: 12px;">
                        <img src="${pageContext.request.contextPath}/dist/images/default.png" style="width: 32px; height: 32px; border-radius: 50%; object-fit: cover; border: 1px solid var(--border-color);">
                        <div style="flex: 1;">
                            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 4px;">
                                <span style="font-size: 13px; font-weight: 800; color: var(--text-dark);">제주매니아</span>
                                <div style="display: flex; align-items: center; gap: 4px;">
                                    <span style="font-size: 11px; color: var(--text-gray);">방금 전</span>
                                    
                                    <div class="comment-options">
                                        <button class="btn-kebab" onclick="toggleDropdown(this, event)">
                                            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="5" r="1.5"></circle><circle cx="12" cy="12" r="1.5"></circle><circle cx="12" cy="19" r="1.5"></circle></svg>
                                        </button>
                                        <div class="kebab-menu-list">
                                            <button class="kebab-item" onclick="alert('제주매니아님과 대화를 시작합니다.')">대화하기</button>
                                            <div class="kebab-divider"></div>
                                            <button class="kebab-item danger" onclick="alert('해당 댓글을 신고합니다.')">신고</button>
                                        </div>
                                    </div>

                                </div>
                            </div>
                            <div style="font-size: 13px; color: var(--text-black); line-height: 1.4;">안녕하세요! 일정 너무 좋은데 혹시 숙소는 정하셨나요? 숙소도 같이 알아봐도 좋을 것 같아요! 😊</div>
                        </div>
                    </div>

                    <div style="display: flex; gap: 10px; padding-bottom: 4px;">
                        <div style="width: 32px; height: 32px; border-radius: 50%; background: var(--grad-sub); color: white; display: flex; align-items: center; justify-content: center; font-size: 14px; font-weight: 900;">뚜</div>
                        <div style="flex: 1;">
                            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 4px;">
                                <span style="font-size: 13px; font-weight: 800; color: var(--text-dark);">뚜벅이여행자</span>
                                <div style="display: flex; align-items: center; gap: 4px;">
                                    <span style="font-size: 11px; color: var(--text-gray);">2시간 전</span>
                                    
                                    <div class="comment-options">
                                        <button class="btn-kebab" onclick="toggleDropdown(this, event)">
                                            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="5" r="1.5"></circle><circle cx="12" cy="12" r="1.5"></circle><circle cx="12" cy="19" r="1.5"></circle></svg>
                                        </button>
                                        <div class="kebab-menu-list">
                                            <button class="kebab-item" onclick="alert('뚜벅이여행자님과 대화를 시작합니다.')">대화하기</button>
                                            <div class="kebab-divider"></div>
                                            <button class="kebab-item danger" onclick="alert('해당 댓글을 신고합니다.')">신고</button>
                                        </div>
                                    </div>

                                </div>
                            </div>
                            <div style="font-size: 13px; color: var(--text-black); line-height: 1.4;">렌트카 비용은 N빵인가요?! 쪽지 드렸습니다~ 확인 부탁드려요! 🚗💨</div>
                        </div>
                    </div>

                </div>

                <div style="display: flex; gap: 8px;">
                    <input type="text" id="comment-input-\${mate.mateId}" class="lounge-input-style" placeholder="동행에 대해 궁금한 점을 남겨보세요!" style="flex: 1; padding: 10px 14px;">
                    <button class="btn-submit-lounge" style="padding: 10px 24px; border-radius: 8px;" onclick="submitMateComment(\${mate.mateId})">등록</button>
                </div>

              </div>
            </div>
            `;
        });
        
        container.innerHTML = html;
    })
    .catch(err => {
        console.error("검색 실패:", err);
        const container = document.getElementById('mateListContainer');
        if(container) container.innerHTML = '<div style="text-align:center; color:#FF6B6B; font-weight:bold; padding: 50px;">데이터를 불러오는데 실패했습니다.</div>';
    });
  }
    
  function toggleMateDetail(mateId) {
      const card = document.getElementById('mate-card-' + mateId);
      
      if (card.classList.contains('expanded')) {
          card.classList.remove('expanded');
          return;
      }

      document.querySelectorAll('.mate-card.expanded').forEach(el => {
          el.classList.remove('expanded');
      });

      card.classList.add('expanded');
      loadMateComments(mateId, 1);
  }

     function submitMateComment(mateId, parentId = null) {
         if (typeof IS_LOGGED_IN !== 'undefined' && !IS_LOGGED_IN) {
             showLoginModal();
             return;
         }

         const inputId = parentId ? 'reply-input-' + parentId : 'comment-input-' + mateId;
         const inputEl = document.getElementById(inputId);
         const content = inputEl.value.trim();

         if(content === '') {
             alert('내용을 입력해주세요!');
             inputEl.focus();
             return;
         }

         const requestData = {
             mateId: mateId,
             content: content,
             parentId: parentId 
         };

         fetch('/community/api/mate/comment/add', {
             method: 'POST',
             headers: { 'Content-Type': 'application/json', 'X-Requested-With': 'Fetch' },
             body: JSON.stringify(requestData)
         })
         .then(res => {
             if (!res.ok) throw new Error('서버 에러');
             return res.json();
         })
         .then(result => {
             if (result.status === 'success') {
                 inputEl.value = ''; 
                 if(parentId) document.getElementById('reply-form-' + parentId).style.display = 'none';
                 loadMateComments(mateId, 1); 
             } else {
                 alert(result.message);
             }
         })
         .catch(err => {
             console.error('댓글 등록 에러:', err);
             alert('댓글 등록에 실패했습니다.');
         });
     }
     
     function deleteMateComment(commentId, mateId) {
         if (!confirm('정말 삭제하시겠습니까?\n(원본 댓글인 경우 답글도 함께 삭제됩니다)')) return;

         fetch('/community/api/mate/comment/delete/' + commentId, {
             method: 'POST',
             headers: { 'X-Requested-With': 'Fetch' }
         })
         .then(res => res.json())
         .then(result => {
             if(result.status === 'success') {
                 loadMateComments(mateId, 1); 
             } else {
                 alert(result.message);
             }
         })
         .catch(err => {
             console.error('삭제 에러:', err);
             alert('삭제 중 오류가 발생했습니다.');
         });
     }

     function toggleReplyForm(commentId) {
         const form = document.getElementById('reply-form-' + commentId);
         if (form.style.display === 'none') {
             form.style.display = 'flex';
             document.getElementById('reply-input-' + commentId).focus();
         } else {
             form.style.display = 'none';
         }
     }

    function loadMateComments(mateId, page) {
        if (!page) page = 1;
        const listContainer = document.getElementById('comment-list-' + mateId);
        const countSpan = document.getElementById('comment-count-' + mateId);
        
        listContainer.innerHTML = '<div style="text-align:center; font-size:12px; color:var(--text-gray); padding: 20px 0;">댓글을 불러오는 중... ⏳</div>';

        fetch('/community/api/mate/' + mateId + '/comments?page=' + page)
        .then(res => res.json())
        .then(data => {
            countSpan.innerText = data.totalCount || 0; 
            
            if (!data.comments || data.comments.length === 0) {
                listContainer.innerHTML = '<div style="text-align:center; font-size:13px; color:var(--text-gray); padding: 30px 0;">첫 번째 댓글을 남겨보세요! 💬</div>';
                return;
            }

            let html = '';
            let childList = data.childComments || []; 

            data.comments.forEach(comment => {
                let profileImg = comment.profilePhoto ? '/uploads/profile/' + comment.profilePhoto : '/dist/images/default.png';
                let nickname = comment.nickname ? comment.nickname : '여행자';
                
                let isMyComment = (CURRENT_USER_ID !== '' && CURRENT_USER_ID == comment.memberId);
                let kebabMenu = '';
                if (isMyComment) {
                    kebabMenu = '<button class="kebab-item danger" onclick="deleteMateComment(' + comment.commentId + ', ' + mateId + ')">🗑️ 삭제하기</button>';
                } else {
                    kebabMenu = '<button class="kebab-item danger" onclick="alert(\'해당 댓글을 신고합니다.\')">🚨 신고하기</button>';
                }

                html += '<div style="display: flex; flex-direction: column; gap: 10px; border-bottom: 1px dashed var(--border-color); padding-bottom: 12px; margin-bottom: 12px;">';
                html += '  <div style="display: flex; gap: 10px;">';
                html += '    <img src="' + profileImg + '" style="width: 32px; height: 32px; border-radius: 50%; object-fit: cover; border: 1px solid var(--border-color);">';
                html += '    <div style="flex: 1;">';
                html += '        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 4px;">';
                html += '            <span style="font-size: 13px; font-weight: 800; color: var(--text-dark);">' + nickname + '</span>';
                html += '            <div style="display: flex; align-items: center; gap: 8px;">';
                html += '                <span style="font-size: 11px; color: var(--text-gray);">' + comment.createdAt + '</span>';
                html += '                <span style="font-size: 11px; color: var(--sky-blue); font-weight: 900; cursor: pointer; transition: 0.2s;" onmouseover="this.style.color=\'#FFB6C1\'" onmouseout="this.style.color=\'var(--sky-blue)\'" onclick="toggleReplyForm(' + comment.commentId + ')">↳ 답글</span>';
                html += '                <div class="comment-options" style="position: relative;">';
                html += '                    <button class="btn-kebab" onclick="toggleDropdown(this, event)">';
                html += '                        <svg style="pointer-events: none;" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="5" r="1.5"></circle><circle cx="12" cy="12" r="1.5"></circle><circle cx="12" cy="19" r="1.5"></circle></svg>';
                html += '                    </button>';
                html += '                    <div class="kebab-menu-list" style="display: none; position: absolute; right: 0; top: 100%; background: white; border: 1px solid var(--border-color); border-radius: 8px; box-shadow: 0 4px 12px rgba(0,0,0,0.15); min-width: 110px; z-index: 99999; margin-top: 4px;">';
                html += '                        <button class="kebab-item" onclick="alert(\'' + nickname + '님과 대화를 시작합니다.\')">💬 대화하기</button>';
                html += '                        <div class="kebab-divider"></div>';
                html +=                          kebabMenu; // 🌟 위에서 만든 내글/남글 메뉴 꽂기!
                html += '                    </div>';
                html += '                </div>';
                html += '            </div>';
                html += '        </div>';
                html += '        <div style="font-size: 13px; color: var(--text-black); line-height: 1.4; white-space: pre-wrap;">' + comment.content + '</div>';
                html += '    </div>';
                html += '  </div>';

                let children = childList.filter(c => c.parentId === comment.commentId);
                children.forEach(child => {
                    let cProfileImg = child.profilePhoto ? '/uploads/profile/' + child.profilePhoto : '/dist/images/default.png';
                    let cNickname = child.nickname ? child.nickname : '여행자';

                    let isMyChild = (CURRENT_USER_ID !== '' && CURRENT_USER_ID == child.memberId);
                    let childKebab = isMyChild ? 
                        '<button class="kebab-item danger" onclick="deleteMateComment(' + child.commentId + ', ' + mateId + ')">🗑️ 삭제하기</button>' : 
                        '<button class="kebab-item danger" onclick="alert(\'해당 댓글을 신고합니다.\')">🚨 신고하기</button>';

                    html += '  <div style="display: flex; gap: 8px; margin-left: 36px; margin-top: 4px; padding: 10px 14px; background: rgba(137, 207, 240, 0.05); border-radius: 12px;">';
                    html += '    <span style="color: var(--sky-blue); font-weight: 900; font-size: 14px;">↳</span>';
                    html += '    <img src="' + cProfileImg + '" style="width: 28px; height: 28px; border-radius: 50%; object-fit: cover; border: 1px solid white;">';
                    html += '    <div style="flex: 1;">';
                    html += '        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 2px;">';
                    html += '            <span style="font-size: 12px; font-weight: 800; color: var(--text-dark);">' + cNickname + '</span>';
                    
                    html += '            <div style="display: flex; align-items: center; gap: 4px;">';
                    html += '                <span style="font-size: 10px; color: var(--text-gray);">' + child.createdAt + '</span>';
                    html += '                <div class="comment-options" style="position: relative;">';
                    html += '                    <button class="btn-kebab" onclick="toggleDropdown(this, event)" style="padding: 0 4px; font-size: 12px;">';
                    html += '                        <svg style="pointer-events: none;" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="5" r="1.5"></circle><circle cx="12" cy="12" r="1.5"></circle><circle cx="12" cy="19" r="1.5"></circle></svg>';
                    html += '                    </button>';
                    html += '                    <div class="kebab-menu-list" style="display: none; position: absolute; right: 0; top: 100%; background: white; border: 1px solid var(--border-color); border-radius: 8px; box-shadow: 0 4px 12px rgba(0,0,0,0.15); min-width: 100px; z-index: 99999; margin-top: 4px;">';
                    html += '                        <button class="kebab-item" onclick="alert(\'' + cNickname + '님과 대화를 시작합니다.\')">💬 대화하기</button>';
                    html += '                        <div class="kebab-divider"></div>';
                    html +=                          childKebab;
                    html += '                    </div>';
                    html += '                </div>';
                    html += '            </div>';
                    
                    html += '        </div>';
                    html += '        <div style="font-size: 12px; color: var(--text-black); line-height: 1.4; white-space: pre-wrap;">' + child.content + '</div>';
                    html += '    </div>';
                    html += '  </div>';
                });

                html += '  <div id="reply-form-' + comment.commentId + '" style="display: none; gap: 8px; margin-left: 36px; margin-top: 4px;">';
                html += '      <input type="text" id="reply-input-' + comment.commentId + '" class="lounge-input-style" placeholder="' + nickname + '님에게 답글 남기기..." style="flex: 1; padding: 10px 14px; font-size: 13px;">';
                html += '      <button class="btn-submit-lounge" style="padding: 10px 20px; border-radius: 8px; font-size: 13px;" onclick="submitMateComment(' + mateId + ', ' + comment.commentId + ')">등록</button>';
                html += '  </div>';

                html += '</div>';
            });

            if (data.totalPages > 1) {
                let pageHtml = '<div style="display: flex; justify-content: center; gap: 8px; margin-top: 10px;">';
                for (let i = 1; i <= data.totalPages; i++) {
                    let activeStyle = (i === data.currentPage) ? 
                        'background: var(--sky-blue); color: white; box-shadow: 0 2px 6px rgba(137,207,240,0.4);' : 
                        'background: #f1f5f9; color: var(--text-gray);';
                    pageHtml += '<button style="border: none; width: 28px; height: 28px; border-radius: 50%; font-size: 12px; font-weight: 900; cursor: pointer; transition: 0.2s; ' + activeStyle + '" onclick="loadMateComments(' + mateId + ', ' + i + ')">' + i + '</button>';
                }
                pageHtml += '</div>';
                html += pageHtml;
            }

            listContainer.innerHTML = html;
        })
        .catch(err => {
            console.error('댓글 로딩 에러:', err);
            listContainer.innerHTML = '<div style="text-align:center; font-size:12px; color:#FF6B6B; padding: 10px 0;">백엔드 API를 찾을 수 없습니다.</div>';
        });
    }
  
  function toggleDropdown(btn, event) {
        event.preventDefault();
        event.stopPropagation();
        
        const dropdown = btn.nextElementSibling;
        const isCurrentlyShowing = (dropdown.style.display === 'block');
        
        document.querySelectorAll('.kebab-menu-list').forEach(menu => {
            menu.style.display = 'none';
        });
        
        if (!isCurrentlyShowing) {
            dropdown.style.display = 'block';
        }
    }

    document.addEventListener('click', function(e) {
        document.querySelectorAll('.kebab-menu-list').forEach(menu => {
            menu.style.display = 'none';
        });
    });
    
    function toggleMateStatus(mateId, targetStatus) {
        let msg = targetStatus === 'CLOSED' ? '모집을 마감하시겠습니까?' : '모집을 다시 시작하시겠습니까?';
        if(!confirm(msg)) return;

        fetch('/community/api/mate/' + mateId + '/status?status=' + targetStatus, {
            method: 'POST',
            headers: { 'X-Requested-With': 'Fetch' }
        })
        .then(res => res.json())
        .then(result => {
            if(result.status === 'success') {
                searchMates();
            } else {
                alert(result.message);
            }
        })
        .catch(err => console.error('상태 변경 에러:', err));
    }
    
    let cachedRegions = null;
    
    async function populateRegionSelects() {
        try {
            if (!cachedRegions) {
                cachedRegions = await TripanAPI.getSidoRegions();
            }

            const mateRegionSelect = document.getElementById('mateRegion');
            const filterRegionSelect = document.getElementById('filterRegion');

            let optionsHtml = ''; 
            cachedRegions.forEach(sido => {
                optionsHtml += `<option value="${sido.regionId}">${sido.name}</option>`;
            });
            
            if (mateRegionSelect && mateRegionSelect.children.length <= 1) {
                mateRegionSelect.insertAdjacentHTML('beforeend', optionsHtml);
            }
            
            if (filterRegionSelect && filterRegionSelect.children.length <= 1) {
                filterRegionSelect.insertAdjacentHTML('beforeend', optionsHtml);
            }
            
        } catch (error) {
            console.error("지역 목록 렌더링 에러:", error);
        }
    }
    
    document.addEventListener('DOMContentLoaded', () => {
        populateRegionSelects();
    });
    
</script>
