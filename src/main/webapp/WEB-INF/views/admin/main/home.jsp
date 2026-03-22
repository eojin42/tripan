<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>TripanSuper — Dashboard</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/dist/css/admin.css">
  <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
  <style>
    /* ── 대시보드 추가 스타일 ── */
    .dash-grid-2 { display:grid; grid-template-columns:1fr 1fr; gap:20px; margin-bottom:20px; }
    .dash-grid-3 { display:grid; grid-template-columns:1fr 1fr 1fr; gap:20px; margin-bottom:20px; }

    /* 액션 필요 카드 강조 */
    .action-card { padding:22px 24px; border-radius:14px; border:1.5px solid var(--border); background:#fff; }
    .action-card .w-header { display:flex; align-items:center; justify-content:space-between; margin-bottom:14px; }
    .action-card .w-header h2 { font-size:13px; font-weight:800; margin:0; display:flex; align-items:center; gap:6px; }
    .action-card .w-header a { font-size:11px; color:var(--primary); font-weight:700; text-decoration:none; }
    .action-card .w-header a:hover { text-decoration:underline; }

    /* 알림 뱃지 */
    .cnt-badge { display:inline-flex; align-items:center; justify-content:center;
                 min-width:20px; height:20px; padding:0 6px; border-radius:10px;
                 font-size:11px; font-weight:800; background:#EF4444; color:#fff; }
    .cnt-badge.amber { background:#F59E0B; }
    .cnt-badge.blue  { background:#3B6EF8; }

    /* 액션 리스트 공통 */
    .action-list { list-style:none; margin:0; padding:0; }
    .action-list li { display:flex; align-items:center; gap:10px;
                      padding:10px 0; border-bottom:1px solid var(--border-light,#F3F4F6);
                      font-size:13px; }
    .action-list li:last-child { border-bottom:none; padding-bottom:0; }
    .action-list .al-main { flex:1; min-width:0; }
    .action-list .al-main strong { display:block; font-weight:700; white-space:nowrap;
                                   overflow:hidden; text-overflow:ellipsis; }
    .action-list .al-sub  { font-size:11px; color:var(--muted); margin-top:1px; }
    .action-list .al-time { font-size:11px; color:var(--muted); white-space:nowrap; flex-shrink:0; }
    .al-avatar { width:32px; height:32px; border-radius:50%; background:var(--bg);
                 display:flex; align-items:center; justify-content:center;
                 font-size:14px; flex-shrink:0; }
    .al-dot-red  { width:8px; height:8px; border-radius:50%; background:#EF4444; flex-shrink:0; }
    .al-dot-amber{ width:8px; height:8px; border-radius:50%; background:#F59E0B; flex-shrink:0; }

    /* 랭킹 */
    .rank-card { padding:22px 24px; border-radius:14px; border:1.5px solid var(--border); background:#fff; }
    .rank-card .w-header { display:flex; align-items:center; justify-content:space-between; margin-bottom:14px; }
    .rank-card .w-header h2 { font-size:13px; font-weight:800; margin:0; }
    .rank-item { display:flex; align-items:center; gap:12px; padding:10px 0;
                 border-bottom:1px solid var(--border-light,#F3F4F6); }
    .rank-item:last-child { border-bottom:none; padding-bottom:0; }
    .rank-num { width:22px; height:22px; border-radius:6px; background:var(--bg);
                font-size:11px; font-weight:800; display:flex; align-items:center;
                justify-content:center; color:var(--muted); flex-shrink:0; }
    .rank-num.top1 { background:#FFF7ED; color:#EA580C; }
    .rank-num.top2 { background:#F8FAFC; color:#64748B; }
    .rank-num.top3 { background:#FFF8F1; color:#B45309; }
    .stay-thumb { width:40px; height:40px; border-radius:8px; object-fit:cover;
                  background:var(--bg); flex-shrink:0; }
    .stay-info { flex:1; min-width:0; }
    .stay-info strong { display:block; font-size:13px; font-weight:700;
                        white-space:nowrap; overflow:hidden; text-overflow:ellipsis; }
    .stay-info span { font-size:11px; color:var(--muted); }
    .rank-cnt { font-size:12px; font-weight:800; color:var(--primary); white-space:nowrap; }

    /* 차트 카드 */
    .chart-main-card { padding:22px 24px; border-radius:14px; border:1.5px solid var(--border);
                       background:#fff; margin-bottom:20px; }
    .chart-main-card h2 { font-size:13px; font-weight:800; margin:0 0 4px; }
    .chart-sub { font-size:11px; color:var(--muted); margin-bottom:14px; }
    .chart-wrap { position:relative; height:220px; }

    /* 빈 상태 */
    .empty-row { text-align:center; padding:24px; color:var(--muted); font-size:13px; }

    /* 신고 상태 */
    .badge-normal { background:rgba(16,185,129,.12); color:#059669; }
    .badge-ban    { background:rgba(239,68,68,.12);  color:#DC2626; }

    @media(max-width:1100px){
      .dash-grid-3 { grid-template-columns:1fr 1fr; }
    }
    @media(max-width:768px){
      .dash-grid-2, .dash-grid-3 { grid-template-columns:1fr; }
    }
  </style>
</head>
<body>
<div class="admin-layout">
  <jsp:include page="../layout/sidebar.jsp">
    <jsp:param name="activePage" value="dashboard"/>
  </jsp:include>
  <div class="main-wrapper">
    <jsp:include page="../layout/header.jsp" />
    <main class="main-content">

      <!-- 헤더 -->
      <div class="page-header fade-up">
        <div>
          <h1>대시보드</h1>
          <p>플랫폼 운영 현황을 한눈에 확인하세요.</p>
        </div>
        <button class="btn btn-ghost btn-sm" onclick="loadDashboard()">🔄 새로고침</button>
      </div>

      <!-- 최근 15일 예약 추이 차트 -->
      <div class="chart-main-card fade-up">
        <h2>📈 최근 15일 일별 예약 추이</h2>
        <p class="chart-sub">예약 건수 및 매출액 (단위: 천원)</p>
        <div class="chart-wrap"><canvas id="dailyChart"></canvas></div>
      </div>

      <!-- 랭킹 2개 -->
      <div class="dash-grid-2 fade-up">

        <!-- 실시간 숙소 랭킹 -->
        <div class="rank-card">
          <div class="w-header">
            <h2>🏆 실시간 숙소 랭킹 <small style="font-size:10px;color:var(--muted);font-weight:600;">최근 30일</small></h2>
          </div>
          <div id="accomRankList"><div class="empty-row">불러오는 중...</div></div>
        </div>

        <!-- 지역 랭킹 -->
        <div class="rank-card">
          <div class="w-header">
            <h2>🗺️ 지역 랭킹 <small style="font-size:10px;color:var(--muted);font-weight:600;">일정 생성 순</small></h2>
          </div>
          <div id="regionRankList"><div class="empty-row">불러오는 중...</div></div>
        </div>

      </div>

      <!-- 액션 필요 3개 -->
      <div class="dash-grid-3 fade-up">

        <!-- 미답변 채팅 -->
        <div class="action-card">
          <div class="w-header">
            <h2>
              💬 미답변 채팅
              <span class="cnt-badge" id="chatBadge">0</span>
            </h2>
            <a href="${pageContext.request.contextPath}/admin/cs">전체 보기 →</a>
          </div>
          <ul class="action-list" id="chatList">
            <li><div class="empty-row" style="padding:8px 0;">불러오는 중...</div></li>
          </ul>
        </div>

        <!-- 입점 승인 대기 -->
        <div class="action-card">
          <div class="w-header">
            <h2>
              🏢 입점 승인 대기
              <span class="cnt-badge amber" id="partnerBadge">0</span>
            </h2>
            <a href="${pageContext.request.contextPath}/admin/partner/apply">전체 보기 →</a>
          </div>
          <ul class="action-list" id="partnerList">
            <li><div class="empty-row" style="padding:8px 0;">불러오는 중...</div></li>
          </ul>
        </div>

        <!-- 신고 상위 유저 -->
        <div class="action-card">
          <div class="w-header">
            <h2>🚨 신고 상위 유저</h2>
            <a href="${pageContext.request.contextPath}/admin/member/main">전체 보기 →</a>
          </div>
          <ul class="action-list" id="reportList">
            <li><div class="empty-row" style="padding:8px 0;">불러오는 중...</div></li>
          </ul>
        </div>

      </div>

    </main>
  </div>
</div>

<script>
const contextPath = '${pageContext.request.contextPath}';
let dailyChart = null;

/* ── 포맷 헬퍼 ── */
function fmtK(n) { return n == null ? '0' : Math.floor(n / 1000).toLocaleString(); }

/* ── 메인 로드 ── */
function loadDashboard() {
  // 채팅은 cs.js와 동일한 API 직접 호출 (unreadCount 포함)
  fetch(contextPath + '/admin/cs/api/chat/rooms/support')
    .then(function(r) { return r.ok ? r.json() : []; })
    .then(function(rooms) { renderChatList(rooms || []); })
    .catch(function() { renderChatList([]); });

  // 나머지는 대시보드 API
  fetch(contextPath + '/admin/dashboard/data')
    .then(r => { if (!r.ok) throw new Error('HTTP ' + r.status); return r.json(); })
    .then(data => {
      renderChart(data.dailyOrders);
      renderAccomRank(data.accomRanking);
      renderRegionRank(data.regionRanking);
      renderPartnerList(data.pendingPartners);
      renderReportList(data.topReported);
    })
    .catch(function(err) {
      console.error('[Dashboard] 로드 실패', err);
      const errMsg = '<div class="empty-row" style="color:#EF4444;">데이터 로드 실패: ' + err.message + '</div>';
      ['accomRankList','regionRankList'].forEach(function(id) {
        const el = document.getElementById(id);
        if (el) el.innerHTML = errMsg;
      });
      ['partnerList','reportList'].forEach(function(id) {
        const el = document.getElementById(id);
        if (el) el.innerHTML = '<li>' + errMsg + '</li>';
      });
      const canvas = document.getElementById('dailyChart');
      if (canvas) canvas.parentElement.innerHTML = errMsg;
    });
}

/* ── ① 차트 ── */
function renderChart(list) {
  const canvas = document.getElementById('dailyChart');
  if (!canvas) return;
  if (dailyChart) { dailyChart.destroy(); dailyChart = null; }

  if (!list || list.length === 0) {
    canvas.parentElement.innerHTML = '<div class="empty-row">최근 7일 예약 데이터가 없습니다.</div>';
    return;
  }

  Chart.defaults.font.family = "'Noto Sans KR', sans-serif";
  Chart.defaults.font.size   = 11;
  Chart.defaults.color       = '#8B92A5';

  dailyChart = new Chart(canvas, {
    type: 'bar',
    data: {
      labels: list.map(d => d.day),
      datasets: [
        {
          label: '예약 건수',
          data: list.map(d => d.orderCount),
          backgroundColor: 'rgba(59,110,248,.15)',
          borderColor: '#3B6EF8',
          borderWidth: 2,
          borderRadius: 6,
          yAxisID: 'y'
        },
        {
          label: '매출액',
          data: list.map(d => Math.round(d.totalAmount / 1000)),
          type: 'line',
          borderColor: '#10B981',
          backgroundColor: 'transparent',
          borderWidth: 2.5,
          tension: .42,
          pointBackgroundColor: '#10B981',
          pointRadius: 4,
          yAxisID: 'y1'
        }
      ]
    },
    options: {
      responsive: true, maintainAspectRatio: false,
      plugins: {
        legend: { position: 'bottom', labels: { padding: 14, usePointStyle: true } },
        tooltip: {
          callbacks: {
            label: ctx => ctx.datasetIndex === 0
              ? ` 예약 ${ctx.raw}건`
              : ` 매출 ${ctx.raw.toLocaleString()}천원`
          }
        }
      },
      scales: {
        x:  { grid: { display: false } },
        y:  { position: 'left',  grid: { color: 'rgba(0,0,0,.04)' }, ticks: { callback: v => v + '건' } },
        y1: { position: 'right', grid: { display: false },           ticks: { callback: v => v + '천' } }
      }
    }
  });
}

/* ── ② 숙소 랭킹 ── */
function renderAccomRank(list) {
  const el = document.getElementById('accomRankList');
  if (!list || list.length === 0) {
    el.innerHTML = '<div class="empty-row">데이터가 없습니다.</div>'; return;
  }
  const rankClass = function(r) { return r === 1 ? 'top1' : r === 2 ? 'top2' : r === 3 ? 'top3' : ''; };
  const fallback  = 'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=100';
  el.innerHTML = list.map(function(item) {
    const img = item.imageUrl || 'https://images.unsplash.com/photo-1571003123894-1f0594d2b5d9?w=100';
    return '<div class="rank-item">'
      + '<div class="rank-num ' + rankClass(item.rank) + '">' + item.rank + '</div>'
      + '<img class="stay-thumb" src="' + escHtml(img) + '" alt="" onerror="this.src=\'' + fallback + '\'">'
      + '<div class="stay-info">'
      +   '<strong>' + escHtml(item.placeName) + '</strong>'
      +   '<span>' + escHtml(item.address || '') + '</span>'
      + '</div>'
      + '<div class="rank-cnt">' + item.reservationCount + '건</div>'
      + '</div>';
  }).join('');
}

/* ── ③ 지역 랭킹 ── */
function renderRegionRank(list) {
  const el = document.getElementById('regionRankList');
  if (!list || list.length === 0) {
    el.innerHTML = '<div class="empty-row">데이터가 없습니다.</div>'; return;
  }
  const icons     = ['🥇','🥈','🥉','4️⃣','5️⃣'];
  const rankClass = function(r) { return r === 1 ? 'top1' : r === 2 ? 'top2' : r === 3 ? 'top3' : ''; };
  el.innerHTML = list.map(function(item, i) {
    return '<div class="rank-item">'
      + '<div class="rank-num ' + rankClass(item.rank) + '">' + (icons[i] || item.rank) + '</div>'
      + '<div class="stay-info">'
      +   '<strong>' + escHtml(item.regionName) + '</strong>'
      +   '<span>일정 ' + item.tripCount + '개 생성</span>'
      + '</div>'
      + '<div class="rank-cnt">' + item.tripCount + '개</div>'
      + '</div>';
  }).join('');
}

/* ── ④ 미답변 채팅 — cs.js의 loadChatRooms 방식 재활용 ── */
function renderChatList(list) {
  const el    = document.getElementById('chatList');
  const badge = document.getElementById('chatBadge');

  // unreadCount 합산 (cs.js 동일 방식)
  const totalUnread = (list || []).reduce(function(sum, r) {
    return sum + (r.unreadCount || 0);
  }, 0);
  badge.textContent     = totalUnread;
  badge.style.display   = totalUnread > 0 ? 'inline-flex' : 'inline-flex'; // 항상 표시

  if (!list || list.length === 0) {
    el.innerHTML = '<li><div class="empty-row" style="padding:8px 0;">미답변 채팅이 없습니다. 🎉</div></li>';
    return;
  }

  // WAITING → ACTIVE → CLOSED 순, 그 중 unread 있는 것 우선
  const sorted = list.slice().sort(function(a, b) {
    const order = { WAITING: 0, ACTIVE: 1, CLOSED: 2 };
    const oa = order[a.status] ?? 9, ob = order[b.status] ?? 9;
    if (oa !== ob) return oa - ob;
    return (b.unreadCount || 0) - (a.unreadCount || 0);
  });

  el.innerHTML = sorted.slice(0, 5).map(function(item) {
    const unread  = item.unreadCount || 0;
    const preview = item.lastMessage || '메시지 없음';
    return '<li>'
      + (unread > 0 ? '<div class="al-dot-red"></div>' : '<div style="width:8px;flex-shrink:0;"></div>')
      + '<div class="al-avatar">💬</div>'
      + '<div class="al-main">'
      +   '<strong>' + escHtml(item.userName || item.memberNickname || '사용자') + '</strong>'
      +   '<div class="al-sub">' + escHtml(preview) + '</div>'
      + '</div>'
      + (unread > 0
          ? '<span style="background:#EF4444;color:#fff;font-size:11px;font-weight:800;padding:2px 7px;border-radius:10px;white-space:nowrap;">' + unread + '</span>'
          : '<div class="al-time">' + (item.waitingHours != null ? item.waitingHours + '시간 전' : '') + '</div>')
      + '</li>';
  }).join('');
}

/* ── ⑤ 입점 승인 대기 ── */
function renderPartnerList(list) {
  const el    = document.getElementById('partnerList');
  const badge = document.getElementById('partnerBadge');
  badge.textContent = list ? list.length : 0;

  if (!list || list.length === 0) {
    el.innerHTML = '<li><div class="empty-row" style="padding:8px 0;">대기 중인 파트너가 없습니다.</div></li>'; return;
  }
  const applyUrl = contextPath + '/admin/partner/apply';
  el.innerHTML = list.slice(0, 5).map(function(item) {
    return '<li>'
      + '<div class="al-dot-amber"></div>'
      + '<div class="al-avatar">🏢</div>'
      + '<div class="al-main">'
      +   '<strong>' + escHtml(item.username) + '</strong>'
      +   '<div class="al-sub">' + escHtml(item.email) + ' · ' + escHtml(item.regDate) + ' 신청</div>'
      + '</div>'
      + '<a href="' + applyUrl + '" style="font-size:11px;font-weight:700;color:var(--primary);text-decoration:none;white-space:nowrap;">검토 →</a>'
      + '</li>';
  }).join('');
}

/* ── ⑥ 신고 상위 유저 ── */
function renderReportList(list) {
  const el = document.getElementById('reportList');
  if (!list || list.length === 0) {
    el.innerHTML = '<li><div class="empty-row" style="padding:8px 0;">신고 데이터가 없습니다.</div></li>'; return;
  }
  el.innerHTML = list.slice(0, 5).map(item => {
    const isBan      = item.statusCode == 2;
    const badgeCls   = isBan ? 'badge-ban' : 'badge-normal';
    const badgeLabel = isBan ? '정지' : '정상';
    return '<li>'
      + '<div class="al-avatar">👤</div>'
      + '<div class="al-main">'
      +   '<strong>' + escHtml(item.nickname) + '</strong>'
      +   '<div class="al-sub">' + escHtml(item.loginId) + '</div>'
      + '</div>'
      + '<span class="badge ' + badgeCls + '" style="font-size:11px;margin-right:6px;">' + badgeLabel + '</span>'
      + '<span class="badge badge-alert" style="font-size:11px;">신고 ' + item.reportCount + '회</span>'
      + '</li>';
  }).join('');
}

/* ── XSS 방지 ── */
function escHtml(s) {
  if (!s) return '';
  return String(s)
    .replace(/&/g,'&amp;').replace(/</g,'&lt;')
    .replace(/>/g,'&gt;').replace(/"/g,'&quot;');
}

/* ── 초기 로드 ── */
document.addEventListener('DOMContentLoaded', loadDashboard);
</script>
</body>
</html>
