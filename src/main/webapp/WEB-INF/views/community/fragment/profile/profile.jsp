<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>

<style>
  .profile-hero { 
    display: flex; align-items: center; gap: 32px; padding: 32px; margin-bottom: 24px; 
    background: var(--glass-bg); border-radius: 16px; border: 1px solid rgba(255,255,255,0.8); 
    box-shadow: 0 4px 12px rgba(0,0,0,0.03); 
  }
  .profile-avatar-large { 
    width: 110px; height: 110px; border-radius: 50%; object-fit: cover; 
    border: 3px solid white; box-shadow: 0 4px 16px rgba(137, 207, 240, 0.2); flex-shrink: 0;
  }
  .profile-info-wrapper { flex: 1; display: flex; flex-direction: column; gap: 16px; }
  .profile-title-area { display: flex; align-items: center; justify-content: space-between; flex-wrap: wrap; gap: 16px; }
  
  .profile-name { font-size: 26px; font-weight: 900; color: var(--text-black); letter-spacing: -0.5px; margin: 0; }
  
  .profile-stats-row { 
    display: flex; gap: 24px; align-items: center; background: #F8FAFC; 
    padding: 12px 20px; border-radius: 12px; width: fit-content; border: 1px solid var(--border-color);
  }
  .profile-stat-item { font-size: 14px; color: var(--text-gray); font-weight: 600; }
  .profile-stat-item strong { font-size: 18px; font-weight: 900; color: var(--text-black); margin-left: 6px; }
  
  .profile-action-group { display: flex; gap: 12px; }
  .btn-profile-main { background: var(--sky-blue); color: white; border: none; padding: 10px 24px; border-radius: 20px; font-weight: 800; font-size: 14px; cursor: pointer; box-shadow: 0 4px 12px rgba(137, 207, 240, 0.3); transition: 0.2s; }
  .btn-profile-main:hover { transform: translateY(-2px); background: #72bde0; }
  .btn-profile-main.following { background: #f1f5f9; color: var(--text-gray); box-shadow: none; border: 1px solid var(--border-color); }
  
  .btn-profile-sub { background: white; color: var(--text-dark); border: 1px solid var(--border-color); padding: 10px 24px; border-radius: 20px; font-weight: 800; font-size: 14px; cursor: pointer; transition: 0.2s; }
  .btn-profile-sub:hover { background: #f1f5f9; }

  .profile-tab-bar { display: flex; gap: 24px; margin-bottom: 24px; border-bottom: 2px solid var(--border-color); padding: 0 12px; white-space: nowrap; }
  .profile-tab { padding: 12px 4px; font-size: 16px; font-weight: 800; color: var(--text-gray); cursor: pointer; position: relative; transition: 0.2s; }
  .profile-tab:hover { color: var(--text-dark); }
  .profile-tab.active { color: var(--sky-blue); }
  .profile-tab.active::after { content: ''; position: absolute; bottom: -2px; left: 0; width: 100%; height: 3px; background: var(--sky-blue); border-radius: 3px 3px 0 0; }

  .profile-content-list { display: flex; flex-direction: column; gap: 16px; }
  
  .activity-item { 
    display: flex; gap: 16px; padding: 20px; background: white; border-radius: 16px; 
    border: 1px solid var(--border-color); cursor: pointer; transition: 0.3s; align-items: flex-start;
  }
  .activity-item:hover { transform: translateY(-2px); border-color: var(--sky-blue); box-shadow: 0 6px 16px rgba(137,207,240,0.15); }
  .act-icon { width: 40px; height: 40px; border-radius: 50%; background: #F0F8FF; display: flex; align-items: center; justify-content: center; font-size: 18px; flex-shrink: 0; }
  .act-content { flex: 1; }
  .act-meta { font-size: 13px; color: var(--text-gray); margin: 0 0 6px 0; display: flex; justify-content: space-between; align-items: center; }
  .act-meta strong { color: var(--sky-blue); }
  .act-text { font-size: 15px; color: var(--text-dark); font-weight: 600; margin: 0 0 8px 0; line-height: 1.5; }
  .act-date { font-size: 12px; color: #A0AEC0; font-weight: 500; }
  
  .profile-mate-card {
    background: var(--glass-bg); padding: 20px; border-radius: 16px; border: 1px solid rgba(255,255,255,0.8); 
    box-shadow: 0 4px 12px rgba(0,0,0,0.03); transition: all 0.3s ease; display: flex; justify-content: space-between; align-items: center;
  }
  .profile-mate-card:hover { transform: translateY(-3px); box-shadow: 0 12px 24px rgba(137, 207, 240, 0.15); border-color: rgba(137,207,240,0.4); }
  .pm-title { font-size: 16px; font-weight: 800; margin: 0 0 8px 0; color: var(--text-black); }
  .pm-meta { font-size: 13px; color: var(--text-gray); display: flex; gap: 12px; align-items: center; }
  .pm-region { font-size: 12px; font-weight: 700; color: white; background: var(--text-dark); padding: 4px 8px; border-radius: 6px; }
  .pm-status { padding: 4px 8px; border-radius: 6px; font-size: 12px; font-weight: 800; background: #E6FFFA; color: #00A88F; }
  .pm-status.closed { background: #EDF2F7; color: #A0AEC0; }
  
  .tab-pane { display: none; animation: fadeIn 0.3s ease; }
  .tab-pane.active { display: block; }
  @keyframes fadeIn { from { opacity: 0; transform: translateY(10px); } to { opacity: 1; transform: translateY(0); } }
</style>

<div class="profile-hero">
  <img src="${not empty targetUser.profilePhoto ? pageContext.request.contextPath += '/uploads/member/' += targetUser.profilePhoto : pageContext.request.contextPath += '/dist/images/default.png'}" 
       class="profile-avatar-large" alt="Profile">
  
  <div class="profile-info-wrapper">
    <div class="profile-title-area">
      <h2 class="profile-name">${targetUser.nickname}</h2>
      
      <c:if test="${!isMyProfile}">
        <div class="profile-action-group">
          <button class="btn-profile-main ${isFollowing ? 'following' : ''}" onclick="toggleFollow(this, ${targetUser.memberId})">
            ${isFollowing ? '팔로잉' : '팔로우'}
          </button>
          <button class="btn-profile-sub" onclick="startPrivateChat('${targetUser.memberId}', '${targetUser.nickname}')">1:1 메시지</button>
        </div>
      </c:if>
      
      <c:if test="${isMyProfile}">
         <div class="profile-action-group">
          <button class="btn-profile-sub" onclick="location.href='${pageContext.request.contextPath}/mypage/main'">프로필 수정 ⚙️</button>
        </div>
      </c:if>
    </div>

    <div class="profile-stats-row">
      <div class="profile-stat-item" style="cursor: pointer;" onclick="loadUserProfile('${sessionScope.loginUser.memberId}')">
		게시물 <strong>${postCount != null ? postCount : 0}</strong>
	  </div>
	  <div class="profile-stat-item" style="cursor: pointer;" onclick="openFollowModal('follower', '${sessionScope.loginUser.memberId}')">
		팔로워 <strong>${followerCount != null ? followerCount : 0}</strong>
	  </div>
	  <div class="profile-stat-item" style="cursor: pointer;" onclick="openFollowModal('following', '${sessionScope.loginUser.memberId}')">
		팔로잉 <strong>${followingCount != null ? followingCount : 0}</strong>
	  </div>
    </div>
  </div>
</div>

<div class="profile-tab-bar">
  <div class="profile-tab active" onclick="switchProfileTab(this, 'feeds')">📝 feed </div>
  <div class="profile-tab" onclick="switchProfileTab(this, 'mates')">🤝 travel mate </div>
  <div class="profile-tab" onclick="switchProfileTab(this, 'lounge')">💬 lounge </div>
  <c:if test="${isMyProfile}">
    <div class="profile-tab" onclick="switchProfileTab(this, 'activity')">🏃 actvity </div>
  </c:if>
</div>

<div id="profileDynamicContent">
  
  <div id="tab-feeds" class="tab-pane active">
    <c:choose>
      <c:when test="${empty feedList}">
        <div class="glass-card" style="text-align: center; padding: 60px 20px; color: var(--text-gray); font-weight: 600;">
          아직 등록된 게시물이 없습니다. ✈️
        </div>
      </c:when>
      <c:otherwise>
        <jsp:include page="../feed_list.jsp"/> 
      </c:otherwise>
    </c:choose>
  </div>

  <div id="tab-mates" class="tab-pane">
      <div class="profile-content-list">
        <c:choose>
          <c:when test="${empty mateList}">
            <div class="glass-card" style="text-align: center; padding: 40px; color: var(--text-gray);">
              아직 작성한 동행 모집글이 없습니다. 🤝
            </div>
          </c:when>
          <c:otherwise>
            <c:forEach var="mate" items="${mateList}">
              <div class="profile-mate-card" onclick="loadMateDetail(${mate.mateId})" style="${mate.status == 'CLOSED' ? 'opacity: 0.7;' : 'cursor:pointer;'}">
                <div>
                  <div style="display: flex; gap: 8px; margin-bottom: 8px; align-items: center;">
                    <span class="pm-region" style="${mate.status == 'CLOSED' ? 'background:#A0AEC0;' : ''}">${mate.sidoName}</span>
                    <span class="pm-status ${mate.status == 'CLOSED' ? 'closed' : ''}">
                      ${mate.status == 'CLOSED' ? '모집완료' : '모집중'}
                    </span>
                  </div>
                  <h3 class="pm-title" style="${mate.status == 'CLOSED' ? 'color:var(--text-gray); text-decoration: line-through;' : ''}">
                    ${mate.title}
                  </h3>
                  <div class="pm-meta">
                    <span>📅 ${mate.startDate} ~ ${mate.endDate}</span>
                  </div>
                </div>
                <button class="btn-profile-main" style="border-radius: 8px;">상세보기</button>
              </div>
            </c:forEach>
          </c:otherwise>
        </c:choose>
      </div>
    </div>

    <div id="tab-lounge" class="tab-pane">
      <div class="profile-content-list">
        <c:choose>
          <c:when test="${empty loungeList}">
            <div class="glass-card" style="text-align: center; padding: 40px; color: var(--text-gray);">
              아직 작성한 라운지 글이 없습니다. 💬
            </div>
          </c:when>
          <c:otherwise>
            <c:forEach var="lounge" items="${loungeList}">
              <div class="activity-item" onclick="loadBoardDetail(${lounge.boardId})">
                <div class="act-icon">
                  ${lounge.category == 'tip' ? '💡' : (lounge.category == 'question' ? '🙋‍♂️' : (lounge.category == 'review' ? '📸' : '💬'))}
                </div>
                <div class="act-content">
                  <div class="act-meta">
                    <strong>
                      [${lounge.category == 'tip' ? '여행 꿀팁' : (lounge.category == 'question' ? '질문있어요' : (lounge.category == 'review' ? '다녀온 후기' : '기타'))}]
                    </strong>
                    <span class="act-date">${lounge.createdAt}</span>
                  </div>
                  <p class="act-text">${lounge.title}</p>
                  <div style="font-size: 12px; color: var(--text-gray); font-weight: 600;">
                    👀 조회수 ${lounge.viewCount}
                  </div>
                </div>
              </div>
            </c:forEach>
          </c:otherwise>
        </c:choose>
      </div>
    </div>

	<div id="tab-activity" class="tab-pane">
	  <div class="profile-content-list">
	    <c:choose>
	      <c:when test="${empty activityList}">
	        <div class="glass-card" style="text-align: center; padding: 40px; color: var(--text-gray);">
	          아직 활동 내역이 없습니다. 부지런히 여행자들과 소통해 보세요! 🏃
	        </div>
	      </c:when>
	      <c:otherwise>
	        <c:forEach var="act" items="${activityList}">
	          
			<div class="activity-item" 
			     onclick="${act.activityType.contains('FEED') ? 'openFeedModal(' += act.targetUrlId += ')' : (act.activityType.contains('LOUNGE') ? 'loadBoardDetail(' += act.targetUrlId += ')' : 'loadMateDetail(' += act.targetUrlId += ')')}">
	            
	            <div class="act-icon">${act.icon}</div>
	            <div class="act-content">
	              <p class="act-meta"><strong>${act.metaInfo}</strong> ${act.targetTitle}</p>
	              <c:if test="${not empty act.content}">
	                <p class="act-text">"${act.content}"</p>
	              </c:if>
	              <span class="act-date">${act.createdAt}</span>
	            </div>
	          </div>

	        </c:forEach>
	      </c:otherwise>
	    </c:choose>
	  </div>
	</div>

<script>
  function switchProfileTab(element, tabName) {
    document.querySelectorAll('.profile-tab').forEach(tab => tab.classList.remove('active'));
    element.classList.add('active');

    document.querySelectorAll('.tab-pane').forEach(pane => pane.classList.remove('active'));
    document.getElementById('tab-' + tabName).classList.add('active');
  }
</script>