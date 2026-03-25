<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<aside class="sidebar">
  <div class="glass-card profile-widget">
    <div class="profile-avatar">
      <c:choose>
        <c:when test="${not empty sessionScope.loginUser.profilePhoto}">
          <img src="${pageContext.request.contextPath}/uploads/member/${sessionScope.loginUser.profilePhoto}" alt="프로필">
        </c:when>
        <c:otherwise>
          <div class="profile-avatar-default" id="avatar-initial">T</div>
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
      <li class="${activeMenu == 'bookmark' ? 'active' : ''}">
        <a href="${pageContext.request.contextPath}/mypage/bookmark">
          <i class="bi bi-bookmark-heart"></i> 관심 및 저장(찜)
        </a>
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
document.addEventListener('DOMContentLoaded', function () {

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