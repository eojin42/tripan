<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions"%> 

<aside class="sidebar">
  <div class="glass-card profile-widget">
    <div class="profile-avatar">
      <c:choose>
            <c:when test="${not empty sessionScope.loginUser.profilePhoto}">
		        <c:choose>
		            <c:when test="${fn:startsWith(sessionScope.loginUser.profilePhoto, 'http')}">
		                <img src="${sessionScope.loginUser.profilePhoto}" 
		                     alt="profile">
		            </c:when>
		            <c:otherwise>
		                <img src="${pageContext.request.contextPath}/uploads/member/${sessionScope.loginUser.profilePhoto}" >
		            </c:otherwise>
		        </c:choose>
		    </c:when>
            <c:otherwise>
                <div>
                    profile
                </div>
            </c:otherwise>
        </c:choose>
    </div>
    <div class="profile-name">${sessionScope.loginUser.nickname} 님</div>
    <div class="profile-bio">${not empty sessionScope.loginUser.bio ? sessionScope.loginUser.bio : '등록된 소개글이 없습니다.'}</div>
    
    <button class="btn-edit-profile" onclick="location.href='${pageContext.request.contextPath}/member/pwd'">프로필 수정</button>
    
    <div class="profile-stats">
      <div class="stat-box" onclick="openFollowModal('follower')">
        <strong id="stat-follower">-</strong>팔로워
      </div>
      <div class="stat-box" onclick="openFollowModal('following')">
        <strong id="stat-following">-</strong>팔로잉
      </div>
      <div class="stat-box" onclick="location.href='${pageContext.request.contextPath}/mypage/schedule'">
        <strong id="stat-mytrip">-</strong>내 여행
      </div>
    </div>
  </div>

  <div class="glass-card">
    <ul class="side-nav">
      <li class="${activeMenu == 'main' ? 'active' : ''}">
        <a href="${pageContext.request.contextPath}/mypage/main">
          <i class="bi bi-bar-chart-line"></i> 여행 대시보드
        </a>
      </li>
      <li class="${activeMenu == 'schedule' ? 'active' : ''}">
        <a href="${pageContext.request.contextPath}/mypage/schedule">
          <i class="bi bi-suitcase-lg"></i> 내 일정 / 예약
        </a>
      </li>
      <li class="has-sub ${activeMenu == 'bookmark' || activeMenu == 'likes' ? 'sub-open' : ''}">
        <a href="javascript:void(0)" onclick="toggleSubMenu(this)">
          <i class="bi bi-bookmark-heart"></i> 관심 및 저장
          <i class="bi bi-chevron-down sub-arrow"></i>
        </a>
        <ul class="sub-nav">
          <li class="${activeMenu == 'bookmark' ? 'sub-active' : ''}">
            <a href="${pageContext.request.contextPath}/mypage/bookmark">
              <i class="bi bi-bookmark-fill"></i> 나의 찜 목록
            </a>
          </li>
          <li class="${activeMenu == 'likes' ? 'sub-active' : ''}">
            <a href="${pageContext.request.contextPath}/mypage/likes">
              <i class="bi bi-heart"></i> 나의 좋아요 목록
            </a>
          </li>
        </ul>
      </li>
      <li class="${activeMenu == 'review' ? 'active' : ''}">
        <a href="${pageContext.request.contextPath}/mypage/review">
          <i class="bi bi-chat-square-text"></i> 나의 리뷰 기록
        </a>
      </li>
      <li class="${activeMenu == 'map' ? 'active' : ''}">
        <a href="${pageContext.request.contextPath}/mypage/map">
          <i class="bi bi-map"></i> 나의 여행 지도
        </a>
      </li>
      <li class="${activeMenu == 'coupon' ? 'active' : ''}">
        <a href="${pageContext.request.contextPath}/mypage/coupon">
          <i class="bi bi-ticket-perforated"></i> 보유 쿠폰함
        </a>
      </li>
      <li class="${activeMenu == 'point' ? 'active' : ''}">
        <a href="${pageContext.request.contextPath}/mypage/point">
          <i class="bi bi-coin"></i> 포인트 내역
        </a>
      </li>
    </ul>
  </div>
 
</aside>

<%-- ── 팔로우 모달 HTML (사이드바 공통) ── --%>
<div id="followModal" class="modal-overlay" onclick="closeModal('followModal')">
  <div class="modal-box" onclick="event.stopPropagation()">
    <div class="modal-header">
      <span id="follow-modal-title"></span>
      <button onclick="closeModal('followModal')">&times;</button>
    </div>
    <div id="follow-modal-body"></div>
  </div>
</div>
<style>
  /* 하위메뉴 토글 */
  .side-nav li.has-sub > a { justify-content:space-between; }
  .side-nav li.has-sub.sub-open > a,
  .side-nav li.has-sub.sub-open > a:hover {
    background:var(--grad-main) !important; color:white !important;
    box-shadow:0 4px 12px rgba(137,207,240,.4);
    border-radius:16px;
    padding-left:20px;
  }
  .side-nav li.has-sub.sub-open > a i { color:white !important; }
  .sub-arrow { transition:transform .25s; margin-left:auto; font-size:12px !important; width:auto !important; }
  .side-nav li.has-sub.sub-open .sub-arrow { transform:rotate(180deg); }

  /* 하위메뉴 목록 */
  .sub-nav { list-style:none; padding:4px 0 4px 12px; margin:0; display:none; }
  .side-nav li.has-sub.sub-open .sub-nav { display:block; }
  .sub-nav li { border-radius:12px; overflow:hidden; }
  .sub-nav li a {
    display:flex; align-items:center; gap:10px;
    padding:9px 14px; font-size:13px; font-weight:600;
    color:var(--text-gray); text-decoration:none;
    border-radius:12px; transition:all .2s;
  }
  .sub-nav li a i { font-size:13px; color:var(--text-gray); width:16px; text-align:center; }
  .sub-nav li a:hover { background:rgba(137,207,240,.12); color:var(--sky-blue); }
  .sub-nav li a:hover i { color:var(--sky-blue); }
  .sub-nav li.sub-active a {
    background:rgba(137,207,240,.18);
    color:var(--sky-blue);
    font-weight:700;
  }
  .sub-nav li.sub-active a i { color:var(--sky-blue); }

  .modal-overlay {
    display: none;
    position: fixed;
    inset: 0;
    background: rgba(0,0,0,0.4);
    z-index: 9999;
    align-items: center;
    justify-content: center;
  }
  .modal-overlay.active {
    display: flex;
  }
  .modal-box {
    background: var(--bg-white, #fff);
    border-radius: 16px;
    width: 360px;
    max-height: 70vh;
    overflow-y: auto;
    padding: 24px;
    box-shadow: 0 8px 32px rgba(0,0,0,0.15);
  }
  .modal-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    font-weight: 700;
    font-size: 16px;
    margin-bottom: 16px;
  }
  .modal-header button {
    background: none;
    border: none;
    font-size: 20px;
    cursor: pointer;
    color: var(--text-gray, #888);
  }
  .user-item {
    display: flex;
    align-items: center;
    gap: 12px;
    padding: 10px 0;
    border-bottom: 1px solid var(--border-light, #f0f0f0);
  }
  .user-pic {
    width: 40px;
    height: 40px;
    border-radius: 50%;
    overflow: hidden;
    background: var(--bg-light, #f5f5f5);
    display: flex;
    align-items: center;
    justify-content: center;
    font-weight: 700;
    font-size: 14px;
  }
  .user-pic img {
    width: 100%;
    height: 100%;
    object-fit: cover;
  }
</style>
<script>
window.toggleSubMenu = function(el) {
    var li = el.closest('li.has-sub');
    li.classList.toggle('sub-open');
  };

  document.addEventListener('DOMContentLoaded', function () {

  // 하위메뉴 링크 클릭 시 부모 sub-open 강제 유지
  document.querySelectorAll('.sub-nav a').forEach(function(a) {
    a.addEventListener('click', function(e) {
      var li = a.closest('li.has-sub');
      if (li) li.classList.add('sub-open');
    });
  });

  // ── 사이드바 통계 로드 ──
  const ctxPath = document.querySelector('meta[name="ctx-path"]')?.content
    || (window.location.pathname.startsWith('/tripan') ? '/tripan' : '');

  fetch(ctxPath + '/mypage/api/summary')
    .then(r => r.json())
    .then(data => {
      const set = (id, v) => { const el = document.getElementById(id); if (el) el.textContent = v ?? 0; };
      set('stat-follower',  data.followerCount  ?? 0);
      set('stat-following', data.followingCount ?? 0);
      set('stat-mytrip',    data.totalTripCount ?? 0);
    })
    .catch(() => {});

  // ── 팔로우 모달 ──
  window.openFollowModal = async function (type) {
    const modal = document.getElementById('followModal');
    const title = document.getElementById('follow-modal-title');
    const body  = document.getElementById('follow-modal-body');
    if (!modal) return;
    title.textContent = type === 'follower' ? '팔로워' : '팔로잉';
    body.innerHTML = '<div style="text-align:center;padding:30px;color:var(--muted);">불러오는 중...</div>';
    modal.classList.add('active');
    try {
      const res  = await fetch(ctxPath + '/mypage/api/' + type);
      const list = await res.json();
      if (!list.length) {
        body.innerHTML = '<div style="text-align:center;padding:30px;color:var(--muted);font-size:13px;">목록이 없습니다</div>';
        return;
      }
      const esc = s => s ? String(s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;') : '';
      body.innerHTML = list.map(function(u) {
    	  return '<div class="user-item" style="cursor:pointer;" onclick="location.href=\'' + ctxPath + '/community/feed?tab=profile&memberId=' + u.memberId + '\'">' +
    	    '<div class="user-pic">' +
    	      '<img src="' + ctxPath + '/dist/images/trip_icon.png" ' +
    	      (u.profileImage ? 'data-src="' + ctxPath + '/uploads/member/' + esc(u.profileImage) + '" ' : '') +
    	      'style="width:100%;height:100%;object-fit:cover;">' +
    	    '</div>' +
    	    '<div>' +
    	      '<div class="user-name">' + esc(u.nickname) + '</div>' +
    	      '<div class="user-id" style="font-size:11px;color:var(--muted);">@' + esc(u.nickname || '') + '</div>' +
    	    '</div>' +
    	  '</div>';
    	}).join('');

    	// 프로필 이미지 있는 것만 따로 로드 시도
    	body.querySelectorAll('img[data-src]').forEach(function(img) {
    	  var testImg = new Image();
    	  testImg.onload  = function() { img.src = img.dataset.src; };
    	  testImg.onerror = function() { /* 기본 이미지 유지 */ };
    	  testImg.src = img.dataset.src;
    	});
    } catch (e) {
      body.innerHTML = '<div style="text-align:center;padding:30px;color:#FC8181;font-size:13px;">불러오기 실패</div>';
    }
  };

  window.closeModal = id => document.getElementById(id)?.classList.remove('active');

});
</script>