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
  .btn-profile-sub { background: white; color: var(--text-dark); border: 1px solid var(--border-color); padding: 10px 24px; border-radius: 20px; font-weight: 800; font-size: 14px; cursor: pointer; transition: 0.2s; }
  .btn-profile-sub:hover { background: #f1f5f9; }

  .profile-tab-bar { display: flex; gap: 24px; margin-bottom: 24px; border-bottom: 2px solid var(--border-color); padding: 0 12px; overflow-x: auto; white-space: nowrap; }
  .profile-tab { padding: 12px 4px; font-size: 16px; font-weight: 800; color: var(--text-gray); cursor: pointer; position: relative; transition: 0.2s; }
  .profile-tab:hover { color: var(--text-dark); }
  .profile-tab.active { color: var(--sky-blue); }
  .profile-tab.active::after { content: ''; position: absolute; bottom: -2px; left: 0; width: 100%; height: 3px; background: var(--sky-blue); border-radius: 3px 3px 0 0; }

  .activity-list { display: flex; flex-direction: column; gap: 12px; }
  .activity-item { 
    display: flex; gap: 16px; padding: 20px; background: white; border-radius: 16px; 
    border: 1px solid var(--border-color); cursor: pointer; transition: 0.3s; align-items: flex-start;
  }
  .activity-item:hover { transform: translateY(-2px); border-color: var(--sky-blue); box-shadow: 0 6px 16px rgba(137,207,240,0.15); }
  .act-icon { width: 40px; height: 40px; border-radius: 50%; background: #F0F8FF; display: flex; align-items: center; justify-content: center; font-size: 18px; flex-shrink: 0; }
  .act-content { flex: 1; }
  .act-meta { font-size: 13px; color: var(--text-gray); margin: 0 0 6px 0; }
  .act-meta strong { color: var(--sky-blue); }
  .act-text { font-size: 15px; color: var(--text-dark); font-weight: 600; margin: 0 0 8px 0; line-height: 1.5; }
  .act-date { font-size: 12px; color: #A0AEC0; font-weight: 500; }
</style>

<div class="profile-hero">
  <img src="${not empty targetUser.profilePhoto ? pageContext.request.contextPath += '/uploads/profile/' += targetUser.profilePhoto : pageContext.request.contextPath += '/dist/images/default.png'}" 
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
      <div class="profile-stat-item">게시물 <strong>${postCount != null ? postCount : 0}</strong></div>
      <div class="profile-stat-item">팔로워 <strong>${followerCount != null ? followerCount : 0}</strong></div>
      <div class="profile-stat-item">팔로잉 <strong>${followingCount != null ? followingCount : 0}</strong></div>
    </div>
  </div>
</div>

<div class="profile-tab-bar">
  <div class="profile-tab active" onclick="switchProfileTab(this, 'feeds')">📝 작성한 피드</div>
  <div class="profile-tab" onclick="switchProfileTab(this, 'mates')">🤝 동행글</div>
  <div class="profile-tab" onclick="switchProfileTab(this, 'lounge')">💬 라운지글</div>
  <c:if test="${isMyProfile}">
    <div class="profile-tab" onclick="switchProfileTab(this, 'activity')">🏃 내 활동</div>
  </c:if>
</div>

<div id="profileDynamicContent">
  
  <div id="tab-feeds" style="display: block;">
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

  <div id="tab-activity" style="display: none;">
    <div class="activity-list">
      
      <div class="activity-item" onclick="alert('해당 피드 원본 글로 이동합니다!')">
        <div class="act-icon">💬</div>
        <div class="act-content">
          <p class="act-meta"><strong>[피드]</strong> 길동이 님의 "제주도 3박 4일 일정" 에 댓글을 남겼습니다.</p>
          <p class="act-text">"와 진짜 풍경 예쁘네요! 맛집 리스트 공유 가능할까요? 😍"</p>
          <span class="act-date">방금 전</span>
        </div>
      </div>
      
      <div class="activity-item" onclick="alert('해당 라운지 글로 이동합니다!')">
        <div class="act-icon">💡</div>
        <div class="act-content">
          <p class="act-meta"><strong>[라운지]</strong> "오사카 여행 꿀팁 질문" 글에 답변을 남겼습니다.</p>
          <p class="act-text">"주유패스는 꼭 사가시는 걸 추천드려요. 뽕 뽑습니다!"</p>
          <span class="act-date">2시간 전</span>
        </div>
      </div>
      
      <div class="activity-item" onclick="alert('해당 글로 이동합니다!')">
        <div class="act-icon" style="background: #FFF5F5; color: #FF6B6B;">❤️</div>
        <div class="act-content">
          <p class="act-meta"><strong>[트래블 메이트]</strong> "유럽 한 달 동행 구해요" 글을 좋아합니다.</p>
          <span class="act-date">어제</span>
        </div>
      </div>

    </div>
  </div>

</div>

<script>
  function switchProfileTab(element, tabName) {
    document.querySelectorAll('.profile-tab').forEach(tab => tab.classList.remove('active'));
    element.classList.add('active');

    document.getElementById('tab-feeds').style.display = (tabName === 'feeds') ? 'block' : 'none';
    document.getElementById('tab-activity').style.display = (tabName === 'activity') ? 'block' : 'none';
    
    if(tabName === 'mates' || tabName === 'lounge') {
       document.getElementById('profileDynamicContent').innerHTML = 
         '<div class="glass-card" style="text-align: center; padding: 60px 20px; color: var(--text-gray); font-weight: 600;">해당 탭의 데이터를 불러오는 중... ⏳</div>';
    } else if(tabName === 'feeds' || tabName === 'activity') {
       // 원래 상태로 복구 로직 (생략: 위에서 display로 제어중)
    }
  }
</script>