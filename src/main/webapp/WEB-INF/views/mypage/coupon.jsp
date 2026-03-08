<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Tripan - 보유 쿠폰함</title>
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/gh/orioncactus/pretendard@v1.3.8/dist/web/static/pretendard.css">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
  <style>
    :root {
      --sky-blue:#89CFF0;--sky-blue-light:#E6F4FF;--light-pink:#FFB6C1;
      --grad-main:linear-gradient(135deg,var(--sky-blue),var(--light-pink));
      --bg-page:#F0F8FF;--glass-bg:rgba(255,255,255,0.65);--glass-border:rgba(255,255,255,0.8);
      --text-black:#2D3748;--text-dark:#4A5568;--text-gray:#718096;
      --border-light:#E2E8F0;--radius-xl:24px;--bounce:cubic-bezier(0.34,1.56,0.64,1);
    }
    body { background:var(--bg-page);font-family:'Pretendard',sans-serif;margin:0;padding:0;background-image:radial-gradient(at 0% 0%,rgba(137,207,240,.15) 0px,transparent 50%),radial-gradient(at 100% 100%,rgba(255,182,193,.15) 0px,transparent 50%);background-attachment:fixed; }
    .mypage-container { max-width:1400px;width:90%;margin:120px auto 80px;display:grid;grid-template-columns:280px 1fr;gap:40px;align-items:start; }
    .glass-card { background:var(--glass-bg);backdrop-filter:blur(20px);-webkit-backdrop-filter:blur(20px);border:1px solid var(--glass-border);border-radius:var(--radius-xl);padding:24px;box-shadow:0 12px 32px rgba(45,55,72,.04); }
    .sidebar { position:sticky;top:120px;display:flex;flex-direction:column;gap:20px; }
    .profile-avatar { width:88px;height:88px;border-radius:50%;border:4px solid white;box-shadow:0 8px 16px rgba(137,207,240,.3);margin:0 auto 14px;overflow:hidden;background:white; }
    .profile-avatar img { width:100%;height:100%;object-fit:cover; }
    .profile-avatar-default { width:100%;height:100%;background:var(--grad-main);display:flex;align-items:center;justify-content:center;color:white;font-size:28px;font-weight:900; }
    .profile-name { font-size:20px;font-weight:900;margin-bottom:4px;text-align:center; }
    .profile-bio  { font-size:13px;color:var(--text-gray);margin-bottom:16px;line-height:1.4;text-align:center; }
    .btn-edit-profile { background:white;color:var(--text-dark);border:1px solid var(--border-light);padding:8px 16px;border-radius:20px;font-size:13px;font-weight:700;cursor:pointer;transition:all .2s;width:100%;font-family:inherit; }
    .btn-edit-profile:hover { background:var(--text-black);color:white;border-color:transparent; }
    .profile-stats { display:flex;justify-content:space-around;margin-top:20px;padding-top:20px;border-top:1px dashed rgba(45,55,72,.1); }
    .stat-box { display:flex;flex-direction:column;align-items:center;font-size:12px;color:var(--text-gray);font-weight:600;padding:4px 8px;border-radius:8px;transition:.2s;gap:2px; }
    .stat-box strong { font-size:18px;color:var(--text-black);font-weight:900; }
    .side-nav { list-style:none;padding:0;margin:0;display:flex;flex-direction:column;gap:6px; }
    .side-nav li { border-radius:16px;overflow:hidden; }
    .side-nav a { display:flex;align-items:center;gap:12px;padding:13px 20px;color:var(--text-dark);font-weight:700;font-size:14px;text-decoration:none;transition:all .3s; }
    .side-nav a i { font-size:16px;width:20px;text-align:center;flex-shrink:0; }
    .side-nav a:hover { background:rgba(255,255,255,.8);color:var(--sky-blue);padding-left:24px; }
    .side-nav li.active a { background:var(--grad-main);color:white;box-shadow:0 4px 12px rgba(137,207,240,.4); }
    .side-nav li.active a i { color:white; }
    /* 콘텐츠 */
    .content-area { display:flex;flex-direction:column;gap:24px;padding-top:20px; }
    .page-title { font-size:24px;font-weight:800;margin:0 0 4px; }
    .page-subtitle { font-size:14px;color:var(--text-gray);font-weight:500;margin:0 0 24px; }
    /* 쿠폰 입력 */
    .coupon-input-area {
      background:white;border-radius:20px;padding:20px 24px;
      border:1px solid var(--border-light);box-shadow:0 4px 16px rgba(0,0,0,.02);
      display:flex;gap:12px;align-items:center;
    }
    .coupon-input {
      flex:1;padding:12px 18px;border:1.5px solid var(--border-light);border-radius:14px;
      font-size:14px;font-family:'Pretendard',sans-serif;font-weight:600;color:var(--text-black);
      outline:none;transition:.2s;
    }
    .coupon-input:focus { border-color:var(--sky-blue); }
    .coupon-input::placeholder { color:var(--text-gray); }
    .btn-register { background:var(--grad-main);color:white;border:none;padding:12px 24px;border-radius:14px;font-size:14px;font-weight:800;cursor:pointer;font-family:inherit;white-space:nowrap;transition:.2s; }
    .btn-register:hover { opacity:.85; }
    /* 탭 */
    .tab-bar { display:flex;gap:8px;background:white;padding:6px;border-radius:16px;border:1px solid var(--border-light);width:fit-content; }
    .tab-btn { padding:9px 20px;border-radius:12px;border:none;background:none;font-size:13px;font-weight:700;color:var(--text-gray);cursor:pointer;transition:all .25s;font-family:inherit; }
    .tab-btn.active { background:var(--grad-main);color:white;box-shadow:0 4px 12px rgba(137,207,240,.3); }
    /* 쿠폰 카드 */
    .coupon-list { display:flex;flex-direction:column;gap:14px; }
    .coupon-card {
      background:white;border-radius:20px;
      border:1px solid var(--border-light);box-shadow:0 4px 16px rgba(0,0,0,.02);
      display:flex;overflow:hidden;transition:all .3s;
    }
    .coupon-card:hover { box-shadow:0 8px 24px rgba(137,207,240,.12);border-color:rgba(137,207,240,.3); }
    .coupon-card.expired { opacity:.55;filter:grayscale(.4); }
    .coupon-left {
      width:110px;flex-shrink:0;background:var(--grad-main);
      display:flex;flex-direction:column;align-items:center;justify-content:center;
      color:white;padding:20px 10px;gap:4px;position:relative;
    }
    .coupon-left::after {
      content:'';position:absolute;right:-12px;top:50%;transform:translateY(-50%);
      width:24px;height:24px;background:var(--bg-page);border-radius:50%;z-index:1;
    }
    .coupon-discount { font-size:28px;font-weight:900;line-height:1; }
    .coupon-discount-unit { font-size:11px;font-weight:700;opacity:.9; }
    .coupon-right { flex:1;padding:18px 24px;display:flex;align-items:center;justify-content:space-between;gap:16px; }
    .coupon-name { font-size:15px;font-weight:800;margin-bottom:4px; }
    .coupon-meta { font-size:11px;color:var(--text-gray);font-weight:600;display:flex;flex-direction:column;gap:3px; }
    .coupon-meta span { display:flex;align-items:center;gap:4px; }
    .coupon-meta i { color:var(--sky-blue); }
    .coupon-dday { font-size:12px;font-weight:800;padding:4px 12px;border-radius:20px;flex-shrink:0; }
    .dday-urgent { background:#FFF0F0;color:#FF6B6B; }
    .dday-normal { background:var(--sky-blue-light);color:var(--sky-blue); }
    .dday-expired { background:#F8FAFC;color:var(--text-gray); }
    .empty-state { text-align:center;padding:60px 20px;color:var(--text-gray); }
    .empty-state i { font-size:48px;display:block;margin-bottom:16px;opacity:.2;color:var(--sky-blue); }
    .empty-state p { font-size:14px;font-weight:600;margin:0; }
    .spin { width:28px;height:28px;border:3px solid rgba(137,207,240,.2);border-top-color:var(--sky-blue);border-radius:50%;animation:sp .7s linear infinite;margin:30px auto;display:block; }
    @keyframes sp { to { transform:rotate(360deg); } }
    @media(max-width:1024px){ .mypage-container { grid-template-columns:1fr; } .sidebar { position:relative;top:0; } }
    @media(max-width:600px){ .coupon-left { width:80px; } .coupon-discount { font-size:22px; } }
  </style>
</head>
<body>
<jsp:include page="/WEB-INF/views/layout/header.jsp"/>

<main class="mypage-container">
  <aside class="sidebar">
    <div class="glass-card">
      <div class="profile-avatar">
        <c:choose>
          <c:when test="${not empty sessionScope.loginUser.profilePhoto}">
            <img src="${pageContext.request.contextPath}/uploads/member/${sessionScope.loginUser.profilePhoto}" alt="프로필">
          </c:when>
          <c:otherwise><div class="profile-avatar-default" id="avatar-initial">T</div></c:otherwise>
        </c:choose>
      </div>
      <div class="profile-name">${sessionScope.loginUser.nickname} 님</div>
      <div class="profile-bio">${not empty sessionScope.loginUser.bio ? sessionScope.loginUser.bio : '등록된 소개글이 없습니다.'}</div>
      <button class="btn-edit-profile" onclick="location.href='${pageContext.request.contextPath}/mypage/edit'">프로필 수정</button>
      <div class="profile-stats">
        <div class="stat-box"><strong id="stat-follower">-</strong>팔로워</div>
        <div class="stat-box"><strong id="stat-following">-</strong>팔로잉</div>
        <div class="stat-box"><strong id="stat-badge">-</strong>배지</div>
      </div>
    </div>
    <div class="glass-card">
      <ul class="side-nav">
        <li><a href="${pageContext.request.contextPath}/mypage/main"><i class="bi bi-bar-chart-line"></i> 여행 대시보드</a></li>
        <li><a href="${pageContext.request.contextPath}/mypage/schedule"><i class="bi bi-suitcase-lg"></i> 내 일정 / 예약</a></li>
        <li><a href="${pageContext.request.contextPath}/mypage/bookmark"><i class="bi bi-bookmark-heart"></i> 관심 및 저장(찜)</a></li>
        <li><a href="${pageContext.request.contextPath}/mypage/review"><i class="bi bi-chat-square-text"></i> 나의 리뷰 기록</a></li>
        <li class="active"><a href="${pageContext.request.contextPath}/mypage/coupon"><i class="bi bi-ticket-perforated"></i> 보유 쿠폰함</a></li>
      </ul>
    </div>
  </aside>

  <div class="content-area">
    <div>
      <h2 class="page-title">보유 쿠폰함</h2>
      <p class="page-subtitle">할인 쿠폰을 등록하고 사용 내역을 확인해요</p>
    </div>

    <!-- 쿠폰 코드 등록 -->
    <div class="coupon-input-area">
      <input class="coupon-input" type="text" id="coupon-code" placeholder="쿠폰 코드를 입력해 주세요" maxlength="30">
      <button class="btn-register" onclick="registerCoupon()"><i class="bi bi-plus-lg"></i> 쿠폰 등록</button>
    </div>

    <div class="tab-bar">
      <button class="tab-btn active" onclick="switchTab('available', this)"><i class="bi bi-ticket-perforated"></i> 사용 가능</button>
      <button class="tab-btn" onclick="switchTab('used', this)"><i class="bi bi-check2-circle"></i> 사용 완료</button>
    </div>

    <div id="coupon-list-area"><div class="spin"></div></div>
  </div>
</main>

<jsp:include page="/WEB-INF/views/layout/footer.jsp"/>
<script>
  var currentTab = 'available';

  async function loadStats() {
    try {
      var res = await fetch('/mypage/api/summary');
      if (!res.ok) return;
      var data = await res.json();
      if (data.member) {
        document.getElementById('stat-follower').textContent  = data.member.followerCount  || 0;
        document.getElementById('stat-following').textContent = data.member.followingCount || 0;
        document.getElementById('stat-badge').textContent     = data.member.badgeCount     || 0;
        var el = document.getElementById('avatar-initial');
        if (el && data.member.nickname) el.textContent = data.member.nickname.charAt(0);
      }
    } catch(e) {}
  }

  async function loadCoupons() {
    var area = document.getElementById('coupon-list-area');
    area.innerHTML = '<div class="spin"></div>';
    try {
      var url = '/mypage/api/coupons?status=' + currentTab;
      var res = await fetch(url);
      if (!res.ok) throw new Error();
      var list = await res.json();
      if (!list.length) {
        area.innerHTML = '<div class="empty-state"><i class="bi bi-ticket-perforated"></i><p>' +
          (currentTab === 'available' ? '사용 가능한 쿠폰이 없어요' : '사용한 쿠폰이 없어요') +
          '</p></div>';
        return;
      }
      area.innerHTML = '<div class="coupon-list">' +
        list.map(function(c) {
          var now = new Date();
          var exp = c.expiryDate ? new Date(c.expiryDate) : null;
          var dday = exp ? Math.ceil((exp - now) / 86400000) : null;
          var isExpired = exp && exp < now;
          var ddayClass = isExpired ? 'dday-expired' : (dday !== null && dday <= 3 ? 'dday-urgent' : 'dday-normal');
          var ddayText  = isExpired ? '만료됨' : (dday !== null ? (dday === 0 ? '오늘 마감' : 'D-' + dday) : '기간 없음');
          var disc = c.discountType === 'PERCENT' ? (c.discountValue + '%') : (c.discountValue.toLocaleString() + '원');
          return '<div class="coupon-card' + (isExpired || currentTab === 'used' ? ' expired' : '') + '">' +
            '<div class="coupon-left">' +
              '<div class="coupon-discount">' + escHtml(disc) + '</div>' +
              '<div class="coupon-discount-unit">' + (c.discountType === 'PERCENT' ? '할인' : '할인') + '</div>' +
            '</div>' +
            '<div class="coupon-right">' +
              '<div>' +
                '<div class="coupon-name">' + escHtml(c.couponName) + '</div>' +
                '<div class="coupon-meta">' +
                  (c.minOrderAmount ? '<span><i class="bi bi-info-circle"></i>' + c.minOrderAmount.toLocaleString() + '원 이상 사용 가능</span>' : '') +
                  (exp ? '<span><i class="bi bi-calendar3"></i>' + fmtDate(c.expiryDate) + ' 까지</span>' : '') +
                '</div>' +
              '</div>' +
              '<span class="coupon-dday ' + ddayClass + '">' + ddayText + '</span>' +
            '</div>' +
          '</div>';
        }).join('') +
      '</div>';
    } catch(e) {
      area.innerHTML = '<div class="empty-state"><i class="bi bi-exclamation-circle"></i><p>쿠폰 정보를 불러올 수 없어요</p></div>';
    }
  }

  async function registerCoupon() {
    var code = document.getElementById('coupon-code').value.trim();
    if (!code) { alert('쿠폰 코드를 입력해 주세요'); return; }
    try {
      var res = await fetch('/mypage/api/coupons/register', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ code: code })
      });
      var data = await res.json();
      if (!res.ok) { alert(data.message || '쿠폰 등록에 실패했어요'); return; }
      alert('쿠폰이 등록되었어요!');
      document.getElementById('coupon-code').value = '';
      loadCoupons();
    } catch(e) { alert('쿠폰 등록에 실패했어요'); }
  }

  function switchTab(tab, btn) {
    document.querySelectorAll('.tab-btn').forEach(function(b) { b.classList.remove('active'); });
    btn.classList.add('active');
    currentTab = tab;
    loadCoupons();
  }

  function fmtDate(v) {
    if (!v) return '';
    return new Date(v).toLocaleDateString('ko-KR', { year:'numeric', month:'2-digit', day:'2-digit' });
  }
  function escHtml(s) { if (!s) return ''; return String(s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;'); }

  document.addEventListener('DOMContentLoaded', function() { loadStats(); loadCoupons(); });
</script>
</body>
</html>
