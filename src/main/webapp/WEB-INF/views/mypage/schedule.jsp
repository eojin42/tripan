<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Tripan - 내 일정 / 예약</title>
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
    body { background:var(--bg-page);font-family:'Pretendard',sans-serif;margin:0;padding:0;
      background-image:radial-gradient(at 0% 0%,rgba(137,207,240,.15) 0px,transparent 50%),radial-gradient(at 100% 100%,rgba(255,182,193,.15) 0px,transparent 50%);background-attachment:fixed; }
    .mypage-container { max-width:1400px;width:90%;margin:120px auto 80px;display:grid;grid-template-columns:280px 1fr;gap:40px;align-items:start; }
    .glass-card { background:var(--glass-bg);backdrop-filter:blur(20px);-webkit-backdrop-filter:blur(20px);border:1px solid var(--glass-border);border-radius:var(--radius-xl);padding:24px;box-shadow:0 12px 32px rgba(45,55,72,.04); }
    .clean-card { background:#fff;border:1px solid var(--border-light);border-radius:20px;padding:24px;box-shadow:0 4px 20px rgba(0,0,0,.02); }
    /* 사이드바 */
    .sidebar { position:sticky;top:120px;display:flex;flex-direction:column;gap:20px; }
    .profile-widget { text-align:center; }
    .profile-avatar { width:88px;height:88px;border-radius:50%;border:4px solid white;box-shadow:0 8px 16px rgba(137,207,240,.3);margin:0 auto 14px;overflow:hidden;background:white; }
    .profile-avatar img { width:100%;height:100%;object-fit:cover; }
    .profile-avatar-default { width:100%;height:100%;background:var(--grad-main);display:flex;align-items:center;justify-content:center;color:white;font-size:28px;font-weight:900; }
    .profile-name { font-size:20px;font-weight:900;margin-bottom:4px; }
    .profile-bio  { font-size:13px;color:var(--text-gray);margin-bottom:16px;line-height:1.4; }
    .btn-edit-profile { background:white;color:var(--text-dark);border:1px solid var(--border-light);padding:8px 16px;border-radius:20px;font-size:13px;font-weight:700;cursor:pointer;transition:all .2s;width:100%;font-family:inherit; }
    .btn-edit-profile:hover { background:var(--text-black);color:white;border-color:transparent; }
    .profile-stats { display:flex;justify-content:space-around;margin-top:20px;padding-top:20px;border-top:1px dashed rgba(45,55,72,.1); }
    .stat-box { display:flex;flex-direction:column;align-items:center;font-size:12px;color:var(--text-gray);font-weight:600;cursor:pointer;padding:4px 8px;border-radius:8px;transition:.2s;gap:2px; }
    .stat-box:hover { background:rgba(137,207,240,.1);color:var(--sky-blue); }
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
    /* 탭 */
    .tab-bar { display:flex;gap:8px;background:white;padding:6px;border-radius:16px;border:1px solid var(--border-light);width:fit-content; }
    .tab-btn { padding:9px 20px;border-radius:12px;border:none;background:none;font-size:13px;font-weight:700;color:var(--text-gray);cursor:pointer;transition:all .25s;font-family:inherit; }
    .tab-btn.active { background:var(--grad-main);color:white;box-shadow:0 4px 12px rgba(137,207,240,.3); }
    .tab-btn:hover:not(.active) { background:#F8FAFC; }
    /* 일정 카드 */
    .trip-list { display:flex;flex-direction:column;gap:14px; }
    .trip-card {
      background:white;border-radius:20px;padding:22px 24px;
      border:1px solid var(--border-light);box-shadow:0 4px 16px rgba(0,0,0,.02);
      display:flex;align-items:center;gap:20px;
      transition:all .3s var(--bounce);cursor:pointer;
    }
    .trip-card:hover { transform:translateY(-3px);box-shadow:0 12px 28px rgba(137,207,240,.15);border-color:rgba(137,207,240,.4); }
    .trip-color-bar { width:5px;height:60px;border-radius:4px;flex-shrink:0; }
    .trip-info { flex:1;min-width:0; }
    .trip-name { font-size:16px;font-weight:800;margin-bottom:5px;white-space:nowrap;overflow:hidden;text-overflow:ellipsis; }
    .trip-meta { display:flex;align-items:center;gap:12px;font-size:12px;color:var(--text-gray);font-weight:600; }
    .trip-meta i { color:var(--sky-blue); }
    .trip-badge {
      padding:5px 12px;border-radius:20px;font-size:11px;font-weight:800;flex-shrink:0;
    }
    .badge-upcoming  { background:rgba(137,207,240,.15);color:var(--sky-blue); }
    .badge-ongoing   { background:rgba(72,199,142,.15);color:#27AE60; }
    .badge-completed { background:#F8FAFC;color:var(--text-gray); }
    .trip-dday { font-size:22px;font-weight:900;color:var(--sky-blue);flex-shrink:0;min-width:50px;text-align:right; }
    /* 빈 상태 */
    .empty-state { text-align:center;padding:60px 20px;color:var(--text-gray); }
    .empty-state i { font-size:48px;display:block;margin-bottom:16px;opacity:.2;color:var(--sky-blue); }
    .empty-state p { font-size:14px;font-weight:600;margin:0 0 20px; }
    .btn-primary { background:var(--grad-main);color:white;border:none;padding:12px 28px;border-radius:20px;font-size:14px;font-weight:800;cursor:pointer;font-family:inherit;transition:.2s; }
    .btn-primary:hover { opacity:.85; }
    /* 스피너 */
    .spin { width:28px;height:28px;border:3px solid rgba(137,207,240,.2);border-top-color:var(--sky-blue);border-radius:50%;animation:sp .7s linear infinite;margin:30px auto;display:block; }
    @keyframes sp { to { transform:rotate(360deg); } }
    @media(max-width:1024px){ .mypage-container { grid-template-columns:1fr; } .sidebar { position:relative;top:0; } }
  </style>
</head>
<body>
<jsp:include page="/WEB-INF/views/layout/header.jsp"/>

<main class="mypage-container">
 <jsp:include page="/WEB-INF/views/layout/mypage_sidebar.jsp">
    <jsp:param name="activeMenu" value="schedule"/> </jsp:include>

  <!-- 콘텐츠 -->
  <div class="content-area">
    <div>
      <h2 class="page-title">내 일정 / 예약</h2>
      <p class="page-subtitle">참여한 여행 일정과 숙소 예약 내역을 확인해요</p>
    </div>

    <div class="tab-bar">
      <button class="tab-btn active" onclick="switchTab('trip', this)"><i class="bi bi-suitcase-lg"></i> 여행 일정</button>
      <button class="tab-btn" onclick="switchTab('booking', this)"><i class="bi bi-building"></i> 숙소 예약</button>
    </div>

    <div id="tab-trip">
      <div class="sub-tab-bar" style="display:flex;gap:8px;margin-bottom:16px;">
        <button class="sub-tab active" onclick="switchSubTab('upcoming', this)" style="padding:6px 14px;border-radius:10px;border:1px solid var(--border-light);background:var(--sky-blue);color:white;font-size:12px;font-weight:800;cursor:pointer;font-family:inherit;">다가오는 일정</button>
        <button class="sub-tab" onclick="switchSubTab('past', this)" style="padding:6px 14px;border-radius:10px;border:1px solid var(--border-light);background:white;color:var(--text-gray);font-size:12px;font-weight:800;cursor:pointer;font-family:inherit;">지난 일정</button>
      </div>
      <div id="trip-list-area"><div class="spin"></div></div>
    </div>

    <div id="tab-booking" style="display:none;">
      <div id="booking-list-area"><div class="spin"></div></div>
    </div>
  </div>
</main>

<jsp:include page="/WEB-INF/views/layout/footer.jsp"/>
<script>
  var allTrips = [];
  var currentSubTab = 'upcoming';

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

  async function loadTrips() {
    try {
      var res = await fetch('/mypage/api/trips');
      if (!res.ok) throw new Error();
      allTrips = await res.json();
      renderTrips();
    } catch(e) {
      document.getElementById('trip-list-area').innerHTML = renderEmpty('bi-suitcase-lg', '일정을 불러올 수 없어요');
    }
  }

  function renderTrips() {
    var now = new Date();
    var list = allTrips.filter(function(t) {
      var end = new Date(t.endDate);
      return currentSubTab === 'upcoming' ? end >= now : end < now;
    });
    var area = document.getElementById('trip-list-area');
    if (!list.length) {
      area.innerHTML = renderEmpty('bi-calendar3', currentSubTab === 'upcoming' ? '다가오는 일정이 없어요' : '지난 일정이 없어요');
      return;
    }
    var colors = ['#89CFF0','#FFB6C1','#A8D8EA','#FFD3A5','#C3B1E1'];
    area.innerHTML = '<div class="trip-list">' +
      list.map(function(t, i) {
        var start = new Date(t.startDate);
        var end   = new Date(t.endDate);
        var dday  = Math.ceil((start - now) / 86400000);
        var isOngoing  = now >= start && now <= end;
        var isUpcoming = start > now;
        var statusLabel = isOngoing ? '여행 중' : (isUpcoming ? ('D-' + dday) : '완료');
        var statusClass = isOngoing ? 'badge-ongoing' : (isUpcoming ? 'badge-upcoming' : 'badge-completed');
        return '<div class="trip-card" onclick="location.href=\'/trip/detail/' + t.tripId + '\'">' +
          '<div class="trip-color-bar" style="background:' + colors[i % colors.length] + '"></div>' +
          '<div class="trip-info">' +
            '<div class="trip-name">' + escHtml(t.tripName) + '</div>' +
            '<div class="trip-meta">' +
              '<span><i class="bi bi-calendar3"></i> ' + fmtDate(t.startDate) + ' ~ ' + fmtDate(t.endDate) + '</span>' +
              (t.regionName ? '<span><i class="bi bi-geo-alt"></i> ' + escHtml(t.regionName) + '</span>' : '') +
              '<span><i class="bi bi-people"></i> ' + (t.memberCount || 1) + '명</span>' +
            '</div>' +
          '</div>' +
          '<span class="trip-badge ' + statusClass + '">' + statusLabel + '</span>' +
        '</div>';
      }).join('') +
    '</div>';
  }

  async function loadBookings() {
	    var area = document.getElementById('booking-list-area');
	    try {
	        var res = await fetch('/mypage/api/bookings');
	        if (!res.ok) throw new Error();
	        var list = await res.json();
	        
	        if (!list.length) { 
	            area.innerHTML = renderEmpty('bi-building', '예약 내역이 없어요', 'booking'); 
	            return; 
	        }

	        area.innerHTML = '<div class="trip-list">' +
	        list.map(function(b) {
	            var now = new Date();
	            now.setHours(0, 0, 0, 0);
	            
	            var checkIn = new Date(b.checkIn);
	            checkIn.setHours(0, 0, 0, 0);
	            
	            var checkOut = new Date(b.checkOut);
	            checkOut.setHours(0, 0, 0, 0);

	            var diffCancel = Math.ceil((checkIn - now) / (1000 * 60 * 60 * 24));
	            var daysSinceCheckIn = Math.ceil((now - checkIn) / (1000 * 60 * 60 * 24));

	            var canCancel = diffCancel >= 4 && checkIn >= now;
	            var canWriteReview = daysSinceCheckIn >= 0 && daysSinceCheckIn <= 30; 

	            var currentStatus = String(b.status || '').toUpperCase();
	            var isCanceled = (currentStatus === '0' || currentStatus === 'CANCELED' || currentStatus === 'CANCEL');
	            var isConfirmed = (currentStatus === '1' || currentStatus === 'SUCCESS' || currentStatus === 'PAID');

	            var statusTxt = isCanceled ? '취소됨' : (isConfirmed ? '예약확정' : '예약중');
	            var statusClass = isCanceled ? 'badge-completed' : 'badge-upcoming';

	            if (!isCanceled && checkOut < now) {
	                statusTxt = '이용완료';
	                statusClass = 'badge-completed';
	                isConfirmed = true; // 리뷰 쓰기 활성화를 위해
	            }

	            var isCancelable = (canCancel && !isCanceled);
	            var cancelBtnStyle = isCancelable 
	                ? 'flex: 1; border-color: var(--light-pink); color: var(--light-pink);' 
	                : 'flex: 1; border-color: var(--border-light); color: var(--text-gray); background: #f8f9fa; cursor: not-allowed;';

	            return '<div class="trip-card" style="flex-direction: column; align-items: stretch; gap: 15px;">' +
	                '<div style="display: flex; align-items: center; gap: 20px;">' +
	                    '<div class="trip-color-bar" style="background:var(--sky-blue)"></div>' +
	                    '<div class="trip-info">' +
	                        '<div class="trip-name">' + escHtml(b.accommodationName) + '</div>' +
	                        '<div class="trip-meta">' +
	                            '<span><i class="bi bi-calendar3"></i> ' + fmtDate(b.checkIn) + ' ~ ' + fmtDate(b.checkOut) + '</span>' +
	                            '<span><i class="bi bi-geo-alt"></i> ' + escHtml(b.address || '') + '</span>' +
	                        '</div>' +
	                    '</div>' +
	                    '<span class="trip-badge ' + statusClass + '">' + statusTxt + '</span>' +
	                '</div>' +
	                
	                '<div style="display: flex; gap: 8px; margin-top: 5px;">' +
	                    '<button class="btn-edit-profile" style="' + cancelBtnStyle + '" ' + 
	                    	(isCancelable ? 'onclick="cancelReservation(' + b.reservationId + ', ' + diffCancel + ')"' : 'disabled') + '>' +
	                        '예약 취소' + 
	                    '</button>' +
	                    
	                    (canWriteReview && !isCanceled && isConfirmed ? 
	                    		'<button class="btn-primary" style="flex: 1; padding: 8px; font-size: 13px;" onclick="location.href=\'/accommodation/review/write/' + b.reservationId + '\'">리뷰 쓰기</button>' 
	                        : '') +
	                '</div>' +
	            '</div>';
	        }).join('') +
	        '</div>';
	    } catch(e) {
	        area.innerHTML = renderEmpty('bi-building', '예약 내역을 불러올 수 없어요', 'booking');
	    }
	}

  function switchTab(tab, btn) {
    document.querySelectorAll('.tab-btn').forEach(function(b) { b.classList.remove('active'); });
    btn.classList.add('active');
    document.getElementById('tab-trip').style.display     = tab === 'trip'    ? '' : 'none';
    document.getElementById('tab-booking').style.display  = tab === 'booking' ? '' : 'none';
    if (tab === 'booking') loadBookings();
  }

  function switchSubTab(sub, btn) {
    document.querySelectorAll('.sub-tab').forEach(function(b) {
      b.style.background = 'white'; b.style.color = 'var(--text-gray)'; b.classList.remove('active');
    });
    btn.style.background = 'var(--sky-blue)'; btn.style.color = 'white'; btn.classList.add('active');
    currentSubTab = sub;
    renderTrips();
  }

  function renderEmpty(icon, msg, type) {
	    var btn = type === 'booking'? 
	    	'<button class="btn-primary" onclick="location.href=\'/accommodation/list\'">숙소 둘러보기</button>'
	        : '<button class="btn-primary" onclick="location.href=\'/trip/trip_create\'">일정 만들기</button>';
	    return '<div class="empty-state"><i class="bi ' + icon + '"></i><p>' + msg + '</p>' + btn + '</div>';
	}
  function fmtDate(v) { if (!v) return ''; return new Date(v).toLocaleDateString('ko-KR',{month:'2-digit',day:'2-digit'}); }
  function escHtml(s) { if (!s) return ''; return String(s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;'); }

  document.addEventListener('DOMContentLoaded', function() { loadStats(); loadTrips(); });
  
  async function cancelReservation(reservationId, diffCancel) {
	  	let refundRate = 0;
	    if (diffCancel >= 10) refundRate = 100;
	    else if (diffCancel >= 4 && diffCancel <= 9) refundRate = diffCancel * 10; 

	    let msg = '정말로 이 예약을 취소하시겠습니까?\n\n';
	    msg += '※ 현재 체크인 기준 D-' + diffCancel + '일 전입니다.\n';
	    msg += '※ 환불 규정에 따라 결제 금액의 [' + refundRate + '%]만 환불됩니다.\n';
      msg += '(결제 취소 시 사용하신 마일리지와 쿠폰은 100% 즉시 복구됩니다.)';
	  
	    if (!confirm(msg)) {
	        return;
	    }

	    try {
	        const res = await fetch('/accommodation/cancel', {
	            method: 'POST',
	            headers: { 'Content-Type': 'application/json' },
	            body: JSON.stringify({ reservationId: reservationId })
	        });
	        
	        const data = await res.json();
	        
	        if (data.success) {
	            alert('예약이 성공적으로 취소 및 환불되었습니다.');
	            loadBookings();
	        } else {
	            alert('예약 취소에 실패했습니다.\n사유: ' + data.message);
	        }
	    } catch(e) {
	        alert('서버와 통신 중 오류가 발생했습니다.');
	        console.error(e);
	    }
	}
</script>
</body>
</html>
