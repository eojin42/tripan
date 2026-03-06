<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<style>
	.detail-container { background: white; border-radius: 20px; padding: 32px; box-shadow: 0 4px 16px rgba(0,0,0,0.04); }
	.detail-header { display: flex; align-items: center; justify-content: space-between; margin-bottom: 24px; padding-bottom: 16px; border-bottom: 1px solid #f1f5f9; }
	.btn-back { background: none; border: none; font-size: 18px; cursor: pointer; color: var(--text-gray); display: flex; align-items: center; gap: 8px; font-weight: 800; }
	
	.user-profile { display: flex; align-items: center; gap: 12px; margin-bottom: 24px; }
	.user-profile img { width: 50px; height: 50px; border-radius: 50%; object-fit: cover; border: 1px solid #edf2f7; }
	.user-info .nickname { display: block; font-weight: 900; font-size: 16px; color: var(--text-black); }
	.user-info .date { font-size: 13px; color: var(--text-gray); }
	
	.content-body { margin-bottom: 40px; }
	.content-category { display: inline-block; padding: 4px 10px; border-radius: 6px; font-size: 12px; font-weight: 800; background: #f1f5f9; color: var(--text-gray); margin-bottom: 12px; }
	.content-title { font-size: 24px; font-weight: 900; margin: 0 0 20px 0; line-height: 1.4; color: var(--text-black); }
	.content-text { font-size: 16px; line-height: 1.8; color: var(--text-dark); white-space: pre-wrap; word-break: break-all; }
	
	.content-image { width: 100%; border-radius: 16px; margin: 20px 0; max-height: 600px; object-fit: contain; background: #fafafa; }
	
	.detail-stats { display: flex; gap: 16px; font-size: 14px; color: var(--text-gray); font-weight: 600; padding-top: 24px; border-top: 1px solid #f1f5f9; }
  
	.comment-section { margin-top: 30px; padding-top: 30px; border-top: 2px solid #f1f5f9; }
	.comment-count { font-size: 16px; font-weight: 900; margin-bottom: 20px; color: var(--text-black); }
	
	.comment-list { display: flex; flex-direction: column; gap: 20px; margin-bottom: 30px; }
	.comment-item { display: flex; gap: 12px; }
	.comment-item img { width: 36px; height: 36px; border-radius: 50%; object-fit: cover; border: 1px solid #edf2f7; }
	.comment-info { flex: 1; background: #f8fafc; padding: 12px 16px; border-radius: 0 16px 16px 16px; }
	.comment-author { font-size: 13px; font-weight: 800; color: var(--text-dark); margin-bottom: 4px; display: flex; justify-content: space-between; }
	.comment-date { font-size: 11px; color: #A0AEC0; font-weight: 500; }
	.comment-text { font-size: 14px; color: var(--text-black); line-height: 1.5; }
	
	.comment-input-box { display: flex; gap: 10px; align-items: flex-end; }
	.comment-input-box textarea { flex: 1; border: 1px solid #E2E8F0; border-radius: 12px; padding: 12px 16px; font-size: 14px; font-family: 'Pretendard'; resize: none; min-height: 20px; outline: none; transition: 0.2s; }
	.comment-input-box textarea:focus { border-color: var(--sky-blue); box-shadow: 0 0 0 3px rgba(137,207,240,0.1); }
	.btn-comment-submit { background: var(--text-black); color: white; border: none; border-radius: 12px; padding: 12px 20px; font-weight: 800; cursor: pointer; transition: 0.2s; height: 46px; white-space: nowrap; }
	.btn-comment-submit:hover { background: var(--sky-blue); }
  
  
</style>

<div class="detail-container">
  <div class="detail-header">
    <button class="btn-back" onclick="loadTabContent('freeboard')">❮ 목록으로</button>
  </div>

  <div class="user-profile">
    <c:choose>
      <c:when test="${not empty board.profilePhoto}">
        <img src="${pageContext.request.contextPath}/uploads/profile/${board.profilePhoto}" alt="profile">
      </c:when>
      <c:otherwise>
        <img src="${pageContext.request.contextPath}/dist/images/default.png" alt="default">
      </c:otherwise>
    </c:choose>
    <div class="user-info">
      <span class="nickname">@${board.nickname != null ? board.nickname : '익명'}</span>
      <span class="date">${board.createdAt}</span>
    </div>
  </div>

  <div class="content-body">
    <span class="content-category">
      <c:choose>
        <c:when test="${board.category == 'tip'}">💡 여행 꿀팁</c:when>
        <c:when test="${board.category == 'question'}">🙋‍♂️ 질문있어요</c:when>
        <c:otherwise>📸 다녀온 후기</c:otherwise>
      </c:choose>
    </span>
    <h2 class="content-title">${board.title}</h2>
    
    <c:if test="${not empty board.thumbnailUrl}">
        <img src="${pageContext.request.contextPath}/uploads/freeboard/${board.thumbnailUrl}" class="content-image" alt="post image">
    </c:if>

    <div class="content-text">${board.content}</div>
  </div>

  <div class="detail-stats">
    <span>👁 조회 ${board.viewCount}</span>
    <span>💬 댓글 ${board.replyCount}</span>
    <span style="color:#E8849A">♥ 좋아요 ${board.likeCount}</span>
  </div>
</div>

<div class="comment-section">
  <div class="comment-count">댓글 ${not empty comments ? comments.size() : 0}개</div>
  
  <div class="comment-list">
    <c:choose>
      <c:when test="${not empty comments}">
        <c:forEach var="comment" items="${comments}">
          <div class="comment-item">
            <c:choose>
                <c:when test="${not empty comment.profilePhoto}">
                    <img src="${pageContext.request.contextPath}/uploads/profile/${comment.profilePhoto}">
                </c:when>
                <c:otherwise>
                    <img src="${pageContext.request.contextPath}/dist/images/default.png">
                </c:otherwise>
            </c:choose>
            <div class="comment-info">
              <div class="comment-author">
                <span>@${comment.nickname != null ? comment.nickname : '익명'}</span>
                <span class="comment-date">${comment.createdAt}</span>
              </div>
              <div class="comment-text">${comment.content}</div>
            </div>
          </div>
        </c:forEach>
      </c:when>
      <c:otherwise>
        <div style="text-align: center; color: var(--text-gray); font-size: 13px; padding: 20px 0;">
          첫 번째 댓글을 남겨보세요! 💬
        </div>
      </c:otherwise>
    </c:choose>

	  <div class="comment-input-box">
	    <textarea id="commentContent" placeholder="따뜻한 댓글을 남겨주세요." rows="1"></textarea>
	    <button class="btn-comment-submit" onclick="submitComment(${board.boardId})">등록</button>
	  </div>
	</div>
  </div>