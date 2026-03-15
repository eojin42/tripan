<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<style>
  .board-header { margin-bottom: 24px; }
  .board-title { font-size: 24px; font-weight: 900; margin: 0 0 8px; letter-spacing: -0.5px; }
  .board-sub { font-size: 14px; color: var(--text-gray); font-weight: 500; margin: 0; }
  .filter-bar { display: flex; align-items: center; justify-content: space-between; margin-bottom: 24px; padding-bottom: 16px; border-bottom: 1px solid rgba(0,0,0,0.05); }
  .filter-left { display: flex; gap: 8px; flex-wrap: wrap; }
  .f-chip { padding: 8px 16px; border-radius: 50px; border: 1.5px solid rgba(0,0,0,0.1); background: var(--glass-bg); font-size: 13px; font-weight: 700; color: var(--text-gray); cursor: pointer; transition: all .2s; }
  .f-chip:hover { border-color: var(--sky-blue); color: var(--sky-blue); background: #F0F8FF; }
  .f-chip.on { 
        border-color: var(--text-black); 
        background: var(--text-black); 
        color: white; 
        font-weight: 800;
        box-shadow: 0 4px 12px rgba(45, 55, 72, 0.25); 
    }
  .btn-write { padding: 9px 20px; border: none; border-radius: 50px; background: var(--grad-main); color: white; font-size: 14px; font-weight: 800; cursor: pointer; box-shadow: 0 4px 14px rgba(137,207,240,.3); transition: all .3s; }
  .btn-write:hover { transform: translateY(-2px); box-shadow: 0 7px 20px rgba(137,207,240,.4); }
  .board-list { display: flex; flex-direction: column; gap: 16px; }
  .board-card { display: flex; gap: 20px; background: var(--glass-bg); padding: 24px; border-radius: 20px; border: 1px solid rgba(255,255,255,0.8); box-shadow: 0 4px 16px rgba(0,0,0,0.04); cursor: pointer; text-decoration: none; color: inherit; transition: all 0.3s ease; }
  .board-card:hover { transform: translateY(-3px); box-shadow: 0 12px 32px rgba(137, 207, 240, 0.15); border-color: rgba(137,207,240,0.3); }
  .card-content { flex: 1; display: flex; flex-direction: column; justify-content: center; }
  .card-badge { display: inline-block; padding: 4px 10px; border-radius: 6px; font-size: 11px; font-weight: 800; margin-bottom: 12px; width: fit-content; }

  .badge-tip { background: #E6FFFA; color: #00A88F; }
  .badge-question { background: #FFF3CD; color: #D69E2E; }
  .badge-review { background: #EBF8FF; color: var(--sky-blue); }
  .badge-etc { background: #F1F5F9; color: #718096; }
  
  .card-title { font-size: 17px; font-weight: 800; margin: 0 0 8px; line-height: 1.4; }
  .card-text { font-size: 14px; color: var(--text-gray); margin: 0 0 16px; line-height: 1.5; display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden; }
  .card-meta { display: flex; align-items: center; gap: 16px; font-size: 12px; color: #A0AEC0; font-weight: 600; }
  .meta-user { display: flex; align-items: center; gap: 6px; color: var(--text-dark); }
  .meta-user img { width: 24px; height: 24px; border-radius: 50%; object-fit: cover; }
  .meta-stats { display: flex; gap: 12px; margin-left: auto; }
  .card-thumb { width: 120px; height: 120px; border-radius: 12px; overflow: hidden; flex-shrink: 0; }
  .card-thumb img { width: 100%; height: 100%; object-fit: cover; }
  
  
  
</style>

<div class="board-header">
  <h2 class="board-title">💬 자유게시판</h2>
  <p class="board-sub">여행 꿀팁부터 궁금한 질문, 다녀온 생생 후기까지!</p>
</div>

<div class="filter-bar">
  <div class="filter-left">
    <button id="chip-all" class="f-chip" onclick="filterFreeboard('all')">전체</button>
    <button id="chip-tip" class="f-chip" onclick="filterFreeboard('tip')">💡 여행 꿀팁</button>
    <button id="chip-question" class="f-chip" onclick="filterFreeboard('question')">🙋‍♂️ 질문있어요</button>
    <button id="chip-review" class="f-chip" onclick="filterFreeboard('review')">📸 다녀온 후기</button>
    <button id="chip-etc" class="f-chip" onclick="filterFreeboard('etc')">💬 기타</button>
  </div>
  <button class="btn-write" onclick="openLoungeModal()">✏️ 글쓰기</button>
</div>

<div class="board-list">
	<div class="board-list">
	  <c:choose>
	    <c:when test="${not empty boardList}">
	      <c:forEach var="board" items="${boardList}">
	        <a href="javascript:void(0);" onclick="loadBoardDetail(${board.boardId})" class="board-card">
	          
	          <div class="card-content">
				<c:choose>
				  <c:when test="${board.category == 'tip'}">
				    <span class="card-badge badge-tip">💡 여행 꿀팁</span>
				  </c:when>
				  <c:when test="${board.category == 'question'}">
				    <span class="card-badge badge-question">🙋‍♂️ 질문있어요</span>
				  </c:when>
				  <c:when test="${board.category == 'review'}"> <span class="card-badge badge-review">📸 다녀온 후기</span>
				  </c:when>
				  <c:otherwise> <span class="card-badge badge-etc">💬 기타</span>
				  </c:otherwise>
				</c:choose>
				
	            <h3 class="card-title">${board.title}</h3>
	            <p class="card-text">${board.content}</p>

	            <div class="card-meta">
	              <div class="meta-user">
	                <c:choose>
	                  <c:when test="${not empty board.profilePhoto}">
	                    <img src="${pageContext.request.contextPath}/uploads/profile/${board.profilePhoto}" alt="profile">
	                  </c:when>
	                  <c:otherwise>
	                    <img src="${pageContext.request.contextPath}/dist/images/default.png" alt="default profile">
	                  </c:otherwise>
	                </c:choose>
	                <span>@${board.nickname != null ? board.nickname : '익명'}</span>
	              </div>
	              
	              <span>${board.createdAt}</span>
	              
	              <div class="meta-stats">
	                <span>👁 ${board.viewCount}</span>
	                <span>💬 ${board.replyCount}</span>
	                <span style="color:#E8849A">♥ ${board.likeCount}</span>
	              </div>
	            </div>
	          </div>
	          
	          <c:if test="${not empty board.thumbnailUrl}">
	            <div class="card-thumb">
	                <img src="${pageContext.request.contextPath}/uploads/freeboard/${board.thumbnailUrl}" alt="thumb">
	            </div>
	          </c:if>

	        </a>
	      </c:forEach>
	    </c:when>
	    <c:otherwise>
	      <div style="text-align:center; padding: 100px 20px; color:var(--text-gray);">
	        <p style="font-size: 40px; margin-bottom: 20px;">🏜️</p>
	        <p style="font-weight: 700;">아직 등록된 게시글이 없습니다.</p>
	        <p style="font-size: 13px;">첫 번째 주인공이 되어 여행 이야기를 들려주세요!</p>
	      </div>
	    </c:otherwise>
	  </c:choose>
	</div>
</div>