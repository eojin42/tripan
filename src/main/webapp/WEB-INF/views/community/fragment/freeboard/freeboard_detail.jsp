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
	
	.detail-stats { 
	        display: flex; 
	        align-items: center; 
	        gap: 16px; 
	        font-size: 14px; 
	        color: var(--text-gray); 
	        font-weight: 600; 
	        padding-top: 24px; 
	        border-top: 1px solid #f1f5f9; 
	    }
		
	.like-btn-area {
	    display: inline-flex;
	    align-items: center;
	    gap: 4px;
	    cursor: pointer;
	    color: #E8849A;
	    user-select: none;
	    transition: opacity 0.2s;
	}
	
	.like-btn-area:hover {
	    opacity: 0.7;
	}
	
	#heartIcon {
	    font-size: 14px; 
	    line-height: 1;
	}
	
		.attached-trip-box {
		    display: flex;
		    align-items: center;
		    gap: 16px;
		    margin-top: 32px;
		    padding: 20px 24px;
		    background: linear-gradient(135deg, rgba(240, 248, 255, 0.8), rgba(255, 240, 245, 0.8));
		    border: 1px dashed var(--sky-blue);
		    border-radius: 16px;
		    box-shadow: 0 4px 16px rgba(137, 207, 240, 0.1);
		    transition: transform 0.3s;
		}
		.attached-trip-box:hover {
		    transform: translateY(-3px);
		    box-shadow: 0 8px 24px rgba(137, 207, 240, 0.2);
		}
		.trip-icon-wrapper {
		    width: 50px; height: 50px;
		    background: var(--grad-main);
		    border-radius: 50%;
		    display: flex; align-items: center; justify-content: center;
		    font-size: 24px; color: white;
		    flex-shrink: 0;
		}
		.trip-meta-info { flex: 1; }
		.trip-meta-info .trip-label { font-size: 11px; font-weight: 800; color: var(--sky-blue); display: block; margin-bottom: 4px; letter-spacing: -0.5px;}
		.trip-meta-info .trip-name { font-size: 16px; font-weight: 900; color: var(--text-black); margin: 0 0 4px 0; }
		.trip-meta-info .trip-date { font-size: 12px; color: var(--text-gray); font-weight: 600; margin: 0; }
		
		.btn-trip-scrap {
		    background: white;
		    color: var(--sky-blue);
		    border: 2px solid var(--sky-blue);
		    padding: 10px 20px;
		    border-radius: 50px;
		    font-weight: 800; font-size: 13px;
		    cursor: pointer; transition: 0.2s;
		    white-space: nowrap;
		}
		.btn-trip-scrap:hover {
		    background: var(--sky-blue); color: white;
		}
		
</style>

<div class="detail-container">
  <div class="detail-header">
    <button class="btn-back" onclick="restorePreviousState()">❮ 돌아가기</button>
  </div>

  <div class="user-profile" style="display: flex; align-items: center; justify-content: space-between; margin-bottom: 24px;">
    
    <div style="display: flex; align-items: center; gap: 12px;">
      <c:choose>
          <c:when test="${not empty board.profilePhoto}">
              <img src="${pageContext.request.contextPath}/uploads/member/${board.profilePhoto}" style="width: 50px; height: 50px; border-radius: 50%; object-fit: cover; border: 1px solid #edf2f7;">
          </c:when>
          <c:otherwise>
              <img src="${pageContext.request.contextPath}/dist/images/default.png" style="width: 50px; height: 50px; border-radius: 50%; object-fit: cover; border: 1px solid #edf2f7;">
          </c:otherwise>
      </c:choose>
      <div class="user-info">
          <span class="nickname" style="display: block; font-weight: 900; font-size: 16px; color: var(--text-black);">@${board.nickname != null ? board.nickname : '익명'}</span>
          <span class="date" style="font-size: 13px; color: var(--text-gray);">${board.createdAt}</span>
      </div>
    </div>

    <div class="kebab-wrapper" style="position: relative;">
      <div class="kebab-menu" onclick="toggleDropdown(this, event)" style="cursor: pointer; padding: 8px; color: var(--text-gray);">
        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
          <circle cx="12" cy="12" r="1"></circle><circle cx="12" cy="5" r="1"></circle><circle cx="12" cy="19" r="1"></circle>
        </svg>
      </div>
      
      <div class="dropdown-content kebab-menu-list" style="display: none; position: absolute; right: 0; top: 40px; background: white; min-width: 130px; border-radius: 12px; box-shadow: 0 10px 25px rgba(0,0,0,0.1); border: 1px solid rgba(0,0,0,0.05); z-index: 100; overflow: hidden;">
        <c:choose>
          <%-- 내 글일 때: 수정/삭제 버튼 표시 --%>
          <c:when test="${not empty sessionScope.loginUser and sessionScope.loginUser.memberId == board.memberId}">
            <a href="javascript:void(0)" onclick="editFreeboardPost(${board.boardId})" style="display: block; padding: 12px 16px; font-size: 14px; font-weight: 600; color: var(--text-dark); text-decoration: none;">📝 수정하기</a>
            <a href="javascript:void(0)" onclick="deleteFreeboardPost(${board.boardId})" style="display: block; padding: 12px 16px; font-size: 14px; font-weight: 600; color: #ff4d4d; text-decoration: none;">🗑️ 삭제하기</a>
          </c:when>
          <%-- 남의 글일 때: 신고 버튼 표시 --%>
          <c:otherwise>
            <a href="javascript:void(0)" onclick="reportFreeboardPost(${board.boardId}, ${board.memberId})" style="display: block; padding: 12px 16px; font-size: 14px; font-weight: 600; color: var(--text-dark); text-decoration: none;">🚨 게시글 신고</a>
          </c:otherwise>
        </c:choose>
      </div>
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
      
      <c:if test="${not empty board.tripId}">
          <div class="attached-trip-box">
              <div class="trip-icon-wrapper">🗺️</div>
              
              <div class="trip-meta-info">
                  <span class="trip-label">함께 공유된 여행 일정</span>
                  <h4 class="trip-name">${board.tripName}</h4>
                  <p class="trip-date">${board.tripDate}</p>
              </div>
              
              <button class="btn-trip-scrap" onclick="scrapTrip(${board.tripId})">이 일정 담아오기 📥</button>
          </div>
      </c:if>
    </div>

  <div class="detail-stats">
	<span>👁 조회 ${board.viewCount}</span>
	<span>💬 댓글 ${board.replyCount}</span>
    
    <span id="likeBtn" style="color:#E8849A; cursor: pointer; font-size: 1rem;" onclick="toggleLike(${board.boardId})">
      <span id="heartIcon">${isLiked > 0 ? '♥' : '♡'}</span> 
      좋아요 <span id="detailLikeCount">${board.likeCount}</span>
    </span>
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
                      <img src="${pageContext.request.contextPath}/uploads/member/${comment.profilePhoto}">
                  </c:when>
                  <c:otherwise>
                      <img src="${pageContext.request.contextPath}/dist/images/default.png">
                  </c:otherwise>
              </c:choose>
              
              <div class="comment-info">
                <div class="comment-author" style="display: flex; justify-content: space-between; align-items: center;">
                  <div style="display: flex; align-items: center; gap: 8px;">
                    <span>@${comment.nickname != null ? comment.nickname : '익명'}</span>
                    <span class="comment-date">${comment.createdAt}</span>
                  </div>
                  
                  <div class="kebab-wrapper" style="position: relative;">
                    <div class="kebab-menu" onclick="toggleDropdown(this, event)" style="cursor: pointer; color: var(--text-gray); padding: 0 4px;">
                      <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
                        <circle cx="12" cy="12" r="1.5"></circle><circle cx="12" cy="5" r="1.5"></circle><circle cx="12" cy="19" r="1.5"></circle>
                      </svg>
                    </div>
                    
                    <div class="dropdown-content kebab-menu-list" style="display: none; position: absolute; right: 0; top: 24px; background: white; min-width: 100px; border-radius: 8px; box-shadow: 0 4px 12px rgba(0,0,0,0.1); border: 1px solid var(--border-color); z-index: 100; overflow: hidden;">
                      <c:choose>
                        <c:when test="${not empty sessionScope.loginUser and sessionScope.loginUser.memberId == comment.memberId}">
                          <a href="javascript:void(0)" onclick="deleteFreeboardComment(${comment.commentId}, ${board.boardId})" style="display: block; padding: 10px 14px; font-size: 13px; font-weight: 600; color: #ff4d4d; text-decoration: none;">🗑️ 삭제하기</a>
                        </c:when>
                        <c:otherwise>
                          <a href="javascript:void(0)" onclick="reportFreeboardComment(${comment.commentId}, ${comment.memberId})" style="display: block; padding: 10px 14px; font-size: 13px; font-weight: 600; color: var(--text-dark); text-decoration: none;">🚨 신고하기</a>
                        </c:otherwise>
                      </c:choose>
                    </div>
                  </div>
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
</div>