<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Tripan - 관심 및 저장</title>
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
    .tab-bar { display:flex;gap:8px;background:white;padding:6px;border-radius:16px;border:1px solid var(--border-light);width:fit-content; }
    .tab-btn { padding:9px 20px;border-radius:12px;border:none;background:none;font-size:13px;font-weight:700;color:var(--text-gray);cursor:pointer;transition:all .25s;font-family:inherit; }
    .tab-btn.active { background:var(--grad-main);color:white;box-shadow:0 4px 12px rgba(137,207,240,.3); }
    .tab-btn:hover:not(.active) { background:#F8FAFC; }
    /* 찜 그리드 */
    .wish-grid { display:grid;grid-template-columns:repeat(auto-fill,minmax(200px,1fr));gap:16px; }
    .wish-card {
      background:white;border-radius:20px;overflow:hidden;
      border:1px solid var(--border-light);box-shadow:0 4px 16px rgba(0,0,0,.02);
      transition:all .3s var(--bounce);cursor:pointer;position:relative;
    }
    .wish-card:hover { transform:translateY(-4px);box-shadow:0 12px 28px rgba(137,207,240,.15);border-color:rgba(137,207,240,.4); }
    .wish-thumb { width:100%;height:130px;object-fit:cover;background:#F0F8FF; }
    .wish-thumb-placeholder { width:100%;height:130px;background:linear-gradient(135deg,#E6F4FF,#FFE4E8);display:flex;align-items:center;justify-content:center;color:var(--sky-blue);font-size:28px; }
    .wish-body { padding:14px; }
    .wish-name { font-size:14px;font-weight:800;margin-bottom:4px;white-space:nowrap;overflow:hidden;text-overflow:ellipsis; }
    .wish-meta { font-size:11px;color:var(--text-gray);font-weight:600;display:flex;align-items:center;gap:4px; }
    .wish-meta i { color:var(--sky-blue); }
    .btn-unwish {
      position:absolute;top:10px;right:10px;width:30px;height:30px;border-radius:50%;
      background:rgba(255,255,255,.9);backdrop-filter:blur(4px);
      border:none;cursor:pointer;display:flex;align-items:center;justify-content:center;
      color:#FF6B6B;font-size:14px;transition:.2s;box-shadow:0 2px 8px rgba(0,0,0,.1);
    }
    .btn-unwish:hover { background:#FF6B6B;color:white;transform:scale(1.1); }
    /* 최근 본 숙소 전용 */
    .wish-viewed { font-size:10px;color:var(--text-gray);font-weight:600;margin-top:6px;display:flex;align-items:center;gap:3px; }
    .wish-viewed i { color:var(--sky-blue);font-size:10px; }
    .btn-remove-recent {
      position:absolute;top:10px;right:10px;width:28px;height:28px;border-radius:50%;
      background:rgba(255,255,255,.85);backdrop-filter:blur(4px);
      border:none;cursor:pointer;display:flex;align-items:center;justify-content:center;
      color:var(--text-gray);font-size:12px;transition:.2s;box-shadow:0 2px 8px rgba(0,0,0,.1);
    }
    .btn-remove-recent:hover { background:var(--text-black);color:white;transform:scale(1.1); }
    .empty-state { text-align:center;padding:60px 20px;color:var(--text-gray); }
    .empty-state i { font-size:48px;display:block;margin-bottom:16px;opacity:.2;color:var(--sky-blue); }
    .empty-state p { font-size:14px;font-weight:600;margin:0 0 20px; }
    .btn-primary { background:var(--grad-main);color:white;border:none;padding:12px 28px;border-radius:20px;font-size:14px;font-weight:800;cursor:pointer;font-family:inherit;transition:.2s; }
    .spin { width:28px;height:28px;border:3px solid rgba(137,207,240,.2);border-top-color:var(--sky-blue);border-radius:50%;animation:sp .7s linear infinite;margin:30px auto;display:block; }
    @keyframes sp { to { transform:rotate(360deg); } }
    @media(max-width:1024px){ .mypage-container { grid-template-columns:1fr; } .sidebar { position:relative;top:0; } }
    @media(max-width:600px){ .wish-grid { grid-template-columns:repeat(2,1fr); } }
  </style>
</head>
<body>
<jsp:include page="/WEB-INF/views/layout/header.jsp"/>

<main class="mypage-container">
	<jsp:include page="/WEB-INF/views/layout/mypage_sidebar.jsp">
    <jsp:param name="activeMenu" value="schedule"/> </jsp:include>

  <div class="content-area">
    <div>
      <h2 class="page-title">관심 및 저장(찜)</h2>
      <p class="page-subtitle">찜해둔 장소와 숙소를 모아볼 수 있어요</p>
    </div>

    <div class="tab-bar">
      <button class="tab-btn active" onclick="switchTab('place', this)"><i class="bi bi-geo-alt"></i> 찜한 장소</button>
      <button class="tab-btn" onclick="switchTab('stay', this)"><i class="bi bi-building"></i> 찜한 숙소</button>
      <button class="tab-btn" onclick="switchTab('recent', this)"><i class="bi bi-clock-history"></i> 최근 본 숙소</button>
    </div>

    <div id="tab-place">
      <div id="place-grid-area"><div class="spin"></div></div>
    </div>
    <div id="tab-stay" style="display:none;">
      <div id="stay-grid-area"><div class="spin"></div></div>
    </div>
    <div id="tab-recent" style="display:none;">
      <div style="display:flex;justify-content:flex-end;margin-bottom:12px;">
        <button onclick="clearRecent()" style="background:none;border:1px solid var(--border-light);color:var(--text-gray);font-size:12px;font-weight:700;padding:6px 14px;border-radius:10px;cursor:pointer;font-family:inherit;transition:.2s;"
          onmouseover="this.style.background='#FFF0F0';this.style.color='#FF6B6B';this.style.borderColor='#FFD0D0'"
          onmouseout="this.style.background='none';this.style.color='var(--text-gray)';this.style.borderColor='var(--border-light)'">
          <i class="bi bi-trash3"></i> 기록 전체 삭제
        </button>
      </div>
      <div id="recent-grid-area"><div class="spin"></div></div>
    </div>
  </div>
</main>

<jsp:include page="/WEB-INF/views/layout/footer.jsp"/>
<script src="${pageContext.request.contextPath}/js/mypage/main.js"></script>
<script>
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

  async function loadPlaces() {
    var area = document.getElementById('place-grid-area');
    try {
      var res = await fetch('/mypage/api/bookmarks?type=PLACE');
      if (!res.ok) throw new Error();
      var list = await res.json();
      if (!list.length) { area.innerHTML = renderEmpty('bi-bookmark-heart', '찜한 장소가 없어요', '/guest/list'); return; }
      area.innerHTML = '<div class="wish-grid">' +
        list.map(function(p) {
          return '<div class="wish-card" onclick="location.href=\'/place/detail/' + p.placeId + '\'">' +
            (p.thumbnailUrl
              ? '<img class="wish-thumb" src="' + escHtml(p.thumbnailUrl) + '" alt="" loading="lazy">'
              : '<div class="wish-thumb-placeholder"><i class="bi bi-geo-alt"></i></div>') +
            '<div class="wish-body">' +
              '<div class="wish-name">' + escHtml(p.placeName) + '</div>' +
              '<div class="wish-meta"><i class="bi bi-geo-alt"></i>' + escHtml(p.address || '') + '</div>' +
            '</div>' +
            '<button class="btn-unwish" onclick="removeBookmark(event,' + p.bookmarkId + ', this)" title="찜 해제"><i class="bi bi-heart-fill"></i></button>' +
          '</div>';
        }).join('') +
      '</div>';
    } catch(e) {
      area.innerHTML = renderEmpty('bi-bookmark-heart', '불러오기에 실패했어요', '/guest/list');
    }
  }

  async function loadStays() {
    var area = document.getElementById('stay-grid-area');
    try {
      var res = await fetch('${pageContext.request.contextPath}/mypage/api/bookmarks?type=ACCOMMODATION');
      if (!res.ok) throw new Error();
      var list = await res.json();
      
      if (!list.length) { 
          area.innerHTML = renderEmpty('bi-building', '찜한 숙소가 없어요', '${pageContext.request.contextPath}/accommodation/list'); 
          return; 
      }
      
      area.innerHTML = '<div class="wish-grid">' +
        list.map(function(p) {
          
          let finalImg = '';
          if (p.imageUrl) {
              finalImg = p.imageUrl.startsWith('http') ? p.imageUrl : '${pageContext.request.contextPath}' + p.imageUrl;
          }

          return '<div class="wish-card" onclick="location.href=\'${pageContext.request.contextPath}/accommodation/detail/' + p.placeId + '\'">' +
            (finalImg
              ? '<img class="wish-thumb" src="' + escHtml(finalImg) + '" alt="" loading="lazy" onerror="this.src=\'https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?w=600\'">'
              : '<div class="wish-thumb-placeholder"><i class="bi bi-building"></i></div>') +
            '<div class="wish-body">' +
              '<div class="wish-name">' + escHtml(p.placeName) + '</div>' +
              '<div class="wish-meta"><i class="bi bi-geo-alt"></i>' + escHtml(p.address || '') + '</div>' +
            '</div>' +
            '<button class="btn-unwish" onclick="removeBookmark(event,' + p.bookmarkId + ', this)" title="찜 해제"><i class="bi bi-heart-fill"></i></button>' +
          '</div>';
        }).join('') +
      '</div>';
      
    } catch(e) {
      area.innerHTML = renderEmpty('bi-building', '불러오기에 실패했어요', '${pageContext.request.contextPath}/accommodation/list');
    }
  }

  async function removeBookmark(e, id, btn) {
    e.stopPropagation();
    try {
      var res = await fetch('/mypage/api/bookmarks/' + id, { method: 'DELETE' });
      if (!res.ok) throw new Error();
      var card = btn.closest('.wish-card');
      card.style.transition = 'all .3s';
      card.style.opacity = '0';
      card.style.transform = 'scale(0.9)';
      setTimeout(function() { card.remove(); }, 300);
    } catch(e) { alert('찜 해제에 실패했어요'); }
  }

  function switchTab(tab, btn) {
    document.querySelectorAll('.tab-btn').forEach(function(b) { b.classList.remove('active'); });
    btn.classList.add('active');
    document.getElementById('tab-place').style.display  = tab === 'place'  ? '' : 'none';
    document.getElementById('tab-stay').style.display   = tab === 'stay'   ? '' : 'none';
    document.getElementById('tab-recent').style.display = tab === 'recent' ? '' : 'none';
    if (tab === 'stay')   loadStays();
    if (tab === 'recent') loadRecent();
  }
  
  const currentUserId = '${sessionScope.loginUser.memberId}';
  const RECENT_STORAGE_KEY = currentUserId ? 'tripan_recent_stays_' + currentUserId : 'tripan_recent_stays_guest';
  
  // ── 최근 본 숙소 (서버 API → 없으면 localStorage fallback) ──
  async function loadRecent() {
    var area = document.getElementById('recent-grid-area');
    area.innerHTML = '<div class="spin"></div>';
    try {
      var raw = localStorage.getItem(RECENT_STORAGE_KEY);
      var list = raw ? JSON.parse(raw) : [];
      renderRecentList(area, list);
    } catch(e) {
      area.innerHTML = renderEmpty('bi-building', '최근 본 숙소가 없어요', '/accommodation/list');
    }
  }
  
  function renderRecentList(area, list) {
    if (!list || !list.length) {
      area.innerHTML = renderEmpty('bi-clock-history', '최근 본 숙소가 없어요', '/accommodation/list');
      return;
    }
    area.innerHTML = '<div class="wish-grid">' +
      list.map(function(p) {
        var viewedAt = p.viewedAt ? '<div class="wish-viewed"><i class="bi bi-clock"></i> ' + fmtRelative(p.viewedAt) + '</div>' : '';
        return '<div class="wish-card recent-card" onclick="location.href=\'/accommodation/detail/' + p.accommodationId + '\'">' +
          (p.thumbnailUrl
            ? '<img class="wish-thumb" src="' + escHtml(p.thumbnailUrl) + '" alt="" loading="lazy">'
            : '<div class="wish-thumb-placeholder"><i class="bi bi-building"></i></div>') +
          '<div class="wish-body">' +
            '<div class="wish-name">' + escHtml(p.accommodationName || p.placeName) + '</div>' +
            '<div class="wish-meta"><i class="bi bi-geo-alt"></i>' + escHtml(p.address || '') + '</div>' +
            viewedAt +
          '</div>' +
          '<button class="btn-remove-recent" onclick="removeRecent(event,' + p.accommodationId + ', this)" title="기록 삭제"><i class="bi bi-x-lg"></i></button>' +
        '</div>';
      }).join('') +
    '</div>';
  }

  function removeRecent(e, id, btn) {
    e.stopPropagation();
    fetch('/mypage/api/recent-accommodations/' + id, { method: 'DELETE' }).catch(function(){});
    try {
      var raw  = localStorage.getItem(RECENT_STORAGE_KEY);
      var list = raw ? JSON.parse(raw) : [];
      list = list.filter(function(x) { return x.accommodationId != id; });
      localStorage.setItem(RECENT_STORAGE_KEY, JSON.stringify(list));
    } catch(le) {}
    
    var card = btn.closest('.wish-card');
    card.style.transition = 'all .3s';
    card.style.opacity = '0';
    card.style.transform = 'scale(0.9)';
    setTimeout(function() { card.remove(); }, 300);
  }
  function clearRecent() {
	    if (!confirm('최근 본 숙소 기록을 모두 삭제할까요?')) return;
	    fetch('/mypage/api/recent-accommodations', { method: 'DELETE' }).catch(function(){});
	    try { 
	      localStorage.removeItem(RECENT_STORAGE_KEY); 
	    } catch(e) {}
	    
	    document.getElementById('recent-grid-area').innerHTML =
	      renderEmpty('bi-clock-history', '최근 본 숙소가 없어요', '/accommodation/list');
	  }
  function fmtRelative(v) {
    if (!v) return '';
    var diff = Date.now() - new Date(v).getTime();
    var min  = Math.floor(diff / 60000);
    if (min < 1)  return '방금 전';
    if (min < 60) return min + '분 전';
    var hr = Math.floor(min / 60);
    if (hr < 24)  return hr + '시간 전';
    return Math.floor(hr / 24) + '일 전';
  }

  function renderEmpty(icon, msg, href) {
    return '<div class="empty-state"><i class="bi ' + icon + '"></i><p>' + msg + '</p>' +
      '<button class="btn-primary" onclick="location.href=\'' + href + '\'">둘러보기</button></div>';
  }
  function escHtml(s) { if (!s) return ''; return String(s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;'); }

  document.addEventListener('DOMContentLoaded', function() {
	  loadStats();
	  loadPlaces();

	  const tab = sessionStorage.getItem('bookmarkTab');
	  if (tab === 'recent') {
	    sessionStorage.removeItem('bookmarkTab');
	    document.querySelectorAll('.tab-btn').forEach(b => b.classList.remove('active'));
	    document.querySelector('[onclick*="recent"]').classList.add('active');
	    document.getElementById('tab-place').style.display  = 'none';
	    document.getElementById('tab-stay').style.display   = 'none';
	    document.getElementById('tab-recent').style.display = '';
	    loadRecent();
	  }
	});
</script>
</body>
</html>
