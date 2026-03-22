<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <title>TripanSuper — 통계</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/dist/css/admin.css">
  <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
  <style>
    .stat-filter {
      display:flex; align-items:center; gap:10px; flex-wrap:wrap;
      padding:16px 22px; background:#fff;
      border:1.5px solid var(--border); border-radius:14px; margin-bottom:22px;
    }
    .filter-label { font-size:12px; font-weight:700; color:var(--muted); white-space:nowrap; }
    .filter-select {
      height:34px; padding:0 10px; border:1.5px solid var(--border); border-radius:8px;
      font-size:12px; font-weight:600; color:var(--text); background:#fff; outline:none;
      cursor:pointer; font-family:inherit;
    }
    .period-tab { display:flex; gap:3px; background:var(--bg,#F3F4F6); border-radius:9px; padding:3px; margin-left:auto; }
    .tab-btn { padding:5px 14px; border-radius:7px; font-size:12px; font-weight:700; border:none; background:transparent; color:var(--muted); cursor:pointer; transition:all .15s; white-space:nowrap; }
    .tab-btn.active { background:#fff; color:var(--text); box-shadow:0 1px 4px rgba(0,0,0,.08); }
    .filter-note { font-size:11px; color:var(--muted); margin-left:4px; }

    .section-header { display:flex; align-items:center; justify-content:space-between; margin-bottom:14px; }
    .section-title { font-size:13px; font-weight:800; color:var(--text); }
    .section-sub { font-size:11px; color:var(--muted); }

    .grid-2   { display:grid; grid-template-columns:1fr 1fr; gap:16px; margin-bottom:22px; }
    .grid-3-1 { display:grid; grid-template-columns:2fr 1fr; gap:16px; margin-bottom:22px; }

    .stat-card { background:#fff; border:1.5px solid var(--border); border-radius:14px; padding:20px 22px; }
    .chart-wrap    { position:relative; height:220px; }
    .chart-wrap-sm { position:relative; height:180px; }
    .chart-wrap-lg { position:relative; height:260px; }

    /* 랭킹 */
    .rank-list { list-style:none; margin:0; padding:0; }
    .rank-item {
      display:flex; align-items:center; gap:12px;
      padding:10px 0; border-bottom:1px solid var(--border-light,#F3F4F6);
    }
    .rank-item:last-child { border-bottom:none; }
    .rank-num {
      width:24px; height:24px; border-radius:7px; flex-shrink:0;
      display:flex; align-items:center; justify-content:center;
      font-size:11px; font-weight:900;
      background:var(--bg,#F3F4F6); color:var(--muted);
    }
    .rank-num.top1 { background:#F59E0B; color:#fff; }
    .rank-num.top2 { background:#94A3B8; color:#fff; }
    .rank-num.top3 { background:#CD7C3A; color:#fff; }
    .rank-info { flex:1; min-width:0; }
    .rank-info h4 { font-size:13px; font-weight:700; margin:0 0 2px; white-space:nowrap; overflow:hidden; text-overflow:ellipsis; }
    .rank-info p  { font-size:11px; color:var(--muted); margin:0; }
    .rank-bar-wrap { width:80px; height:5px; background:var(--bg,#F3F4F6); border-radius:3px; overflow:hidden; flex-shrink:0; }
    .rank-bar { height:100%; border-radius:3px; }
    .rank-val { font-size:12px; font-weight:800; font-variant-numeric:tabular-nums; white-space:nowrap; flex-shrink:0; color:var(--muted); }
    .rank-val b { color:var(--text); }

    /* 목적지 순위 전용 */
    .dest-item {
      display:flex; align-items:center; gap:12px;
      padding:9px 0; border-bottom:1px solid var(--border-light,#F3F4F6);
    }
    .dest-item:last-child { border-bottom:none; }
    .dest-icon {
      width:36px; height:36px; border-radius:9px; flex-shrink:0;
      background:var(--bg,#F3F4F6); display:flex; align-items:center;
      justify-content:center; font-size:14px; font-weight:800; color:var(--muted);
    }
    .dest-info { flex:1; min-width:0; }
    .dest-info h4 { font-size:13px; font-weight:700; margin:0 0 2px; }
    .dest-info p  { font-size:11px; color:var(--muted); margin:0; }
    .dest-bar-wrap { width:100px; height:5px; background:var(--bg,#F3F4F6); border-radius:3px; overflow:hidden; flex-shrink:0; }
    .dest-bar { height:100%; border-radius:3px; background:#3B6EF8; }
    .dest-cnt { font-size:12px; font-weight:800; color:var(--text); white-space:nowrap; flex-shrink:0; font-variant-numeric:tabular-nums; }

    /* 회원 KPI */
    .member-kpi { display:grid; grid-template-columns:repeat(3,1fr); gap:10px; margin-bottom:16px; }
    .m-kpi { background:var(--bg,#F8FAFC); border-radius:10px; padding:12px 14px; }
    .m-kpi-label { font-size:11px; color:var(--muted); font-weight:600; margin-bottom:4px; }
    .m-kpi-val   { font-size:18px; font-weight:900; font-variant-numeric:tabular-nums; }

    /* 숙소 타입 */
    .type-legend { display:flex; flex-direction:column; gap:9px; justify-content:center; }
    .type-leg-item { display:flex; align-items:center; gap:8px; font-size:12px; }
    .type-dot { width:9px; height:9px; border-radius:2px; flex-shrink:0; }
    .type-name { flex:1; color:var(--muted); }
    .type-pct  { font-weight:800; color:var(--text); min-width:32px; text-align:right; font-variant-numeric:tabular-nums; }

    /* 랭킹 탭 */
    .rank-tab { display:flex; gap:3px; background:var(--bg,#F3F4F6); border-radius:8px; padding:2px; }
    .rank-tab-btn { padding:4px 10px; border-radius:6px; font-size:11px; font-weight:700; border:none; background:transparent; color:var(--muted); cursor:pointer; transition:all .15s; }
    .rank-tab-btn.active { background:#fff; color:var(--text); box-shadow:0 1px 3px rgba(0,0,0,.08); }

    table { width:100%; border-collapse:collapse; }
    th { padding:8px 12px; font-size:11px; font-weight:700; color:var(--muted); text-transform:uppercase; letter-spacing:.04em; text-align:left; border-bottom:2px solid var(--border); white-space:nowrap; }
    td { padding:10px 12px; font-size:13px; border-bottom:1px solid var(--border-light,#F3F4F6); vertical-align:middle; }
    tbody tr:last-child td { border-bottom:none; }
    tbody tr:hover { background:var(--hover-bg,#F9FAFB); }
    .num { font-variant-numeric:tabular-nums; font-weight:700; }
  </style>
</head>
<body>
<div class="admin-layout">
  <jsp:include page="../layout/sidebar.jsp"><jsp:param name="activePage" value="statistics"/></jsp:include>
  <div class="main-wrapper">
    <jsp:include page="../layout/header.jsp" />
    <main class="main-content">

      <div class="page-header fade-up">
        <div>
          <h1>통계</h1>
          <p>숙소 인기도, 여행 트렌드, 회원 현황을 분석합니다.</p>
        </div>
      </div>

      <!-- 필터 바 -->
      <div class="stat-filter fade-up">
        <span class="filter-label">기간</span>
        <select class="filter-select" id="filterYear">
          <option value="2026">2026년</option>
          <option value="2025">2025년</option>
        </select>
        <select class="filter-select" id="filterMonth">
          <option value="">전체 월</option>
          <option value="03" selected>3월</option>
          <option value="02">2월</option>
          <option value="01">1월</option>
        </select>
        <span class="filter-note">* 백엔드 연동 후 실시간 반영 예정</span>
        <div class="period-tab">
          <button class="tab-btn active" onclick="switchPeriod('monthly',this)">월별</button>
          <button class="tab-btn" onclick="switchPeriod('quarterly',this)">분기별</button>
          <button class="tab-btn" onclick="switchPeriod('yearly',this)">연간</button>
        </div>
      </div>

      <!-- ① 인기 숙소 TOP10 + 여행 목적지 순위 -->
      <div class="grid-3-1 fade-up">

        <!-- 인기 숙소 TOP 10 -->
        <div class="stat-card">
          <div class="section-header">
            <div>
              <div class="section-title">인기 숙소 TOP 10</div>
              <div class="section-sub">예약 건수 또는 매출 기준</div>
            </div>
            <div class="rank-tab">
              <button class="rank-tab-btn active" onclick="switchPlaceRank('reservation',this)">예약건수</button>
              <button class="rank-tab-btn" onclick="switchPlaceRank('revenue',this)">매출액</button>
            </div>
          </div>
          <ul class="rank-list" id="topPlaceList"></ul>
        </div>

        <!-- 여행 목적지 순위 -->
        <div class="stat-card">
          <div class="section-header">
            <div>
              <div class="section-title">여행 목적지 순위</div>
              <div class="section-sub">일정 생성 기준 (trip.cities)</div>
            </div>
          </div>
          <div id="destList"></div>
        </div>

      </div>

      <!-- ② 찜 순위 + 리뷰 순위 -->
      <div class="grid-2 fade-up">

        <div class="stat-card">
          <div class="section-header">
            <div>
              <div class="section-title">찜 많은 숙소 TOP 5</div>
              <div class="section-sub">스크랩 수 기준</div>
            </div>
          </div>
          <ul class="rank-list" id="wishlistRankList"></ul>
        </div>

        <div class="stat-card">
          <div class="section-header">
            <div>
              <div class="section-title">리뷰 많은 숙소 TOP 5</div>
              <div class="section-sub">리뷰 수 기준</div>
            </div>
          </div>
          <ul class="rank-list" id="reviewRankList"></ul>
        </div>

      </div>

      <!-- ③ 회원 추이 -->
      <div class="stat-card fade-up" style="margin-bottom:22px;">
        <div class="section-header">
          <div>
            <div class="section-title">회원 추이</div>
            <div class="section-sub">누적 회원수 / 신규 가입 / 탈퇴</div>
          </div>
        </div>
        <div class="member-kpi">
          <div class="m-kpi">
            <div class="m-kpi-label">총 회원수</div>
            <div class="m-kpi-val">45,120</div>
          </div>
          <div class="m-kpi">
            <div class="m-kpi-label">이번 달 신규</div>
            <div class="m-kpi-val" style="color:#3B6EF8;">+1,240</div>
          </div>
          <div class="m-kpi">
            <div class="m-kpi-label">이번 달 탈퇴</div>
            <div class="m-kpi-val" style="color:#EF4444;">-83</div>
          </div>
        </div>
        <div class="chart-wrap-lg"><canvas id="memberChart"></canvas></div>
      </div>

      <!-- ④ 숙소 타입별 예약 비율 -->
      <div class="stat-card fade-up" style="margin-bottom:22px;">
        <div class="section-header">
          <div>
            <div class="section-title">숙소 타입별 예약 비율</div>
            <div class="section-sub">전체 예약 건수 기준</div>
          </div>
        </div>
        <div style="display:grid;grid-template-columns:260px 1fr;gap:24px;align-items:center;">
          <div class="chart-wrap-sm"><canvas id="accTypeDoughnut"></canvas></div>
          <div class="type-legend" id="accTypeLegend"></div>
        </div>
      </div>

    </main>
  </div>
</div>

<script>
Chart.defaults.font.family = "'Noto Sans KR', sans-serif";
Chart.defaults.font.size = 11;
Chart.defaults.color = '#8B92A5';

/* ── 더미 데이터 ── */
const PLACE_RANK_DATA = [
  { name:'아만 스위트 리저브', region:'제주', type:'풀빌라', cnt:248, revenue:42000000 },
  { name:'신라 더 파크 호텔',  region:'서울', type:'호텔',   cnt:201, revenue:38500000 },
  { name:'루나 오션 펜션',     region:'강릉', type:'펜션',   cnt:187, revenue:21000000 },
  { name:'제주 돌담 독채',     region:'제주', type:'독채',   cnt:163, revenue:29000000 },
  { name:'해운대 씨뷰 스위트', region:'부산', type:'호텔',   cnt:142, revenue:31000000 },
  { name:'경주 한옥 스테이',   region:'경주', type:'한옥',   cnt:131, revenue:18000000 },
  { name:'속초 오션 캐빈',     region:'강릉', type:'펜션',   cnt:118, revenue:14000000 },
  { name:'서울 남산 뷰 호텔',  region:'서울', type:'호텔',   cnt:109, revenue:27000000 },
  { name:'제주 감귤 팜스테이', region:'제주', type:'독채',   cnt:97,  revenue:11000000 },
  { name:'부산 광안리 레지던스',region:'부산', type:'레지던스',cnt:88, revenue:16000000 },
];

const DEST_DATA = [
  { name:'제주',   cnt:3840, pct:28 },
  { name:'서울',   cnt:2910, pct:21 },
  { name:'부산',   cnt:2340, pct:17 },
  { name:'강릉',   cnt:1820, pct:13 },
  { name:'경주',   cnt:1240, pct:9  },
  { name:'여수',   cnt:980,  pct:7  },
  { name:'전주',   cnt:680,  pct:5  },
];

const WISHLIST_DATA = [
  { name:'아만 스위트 리저브', region:'제주', type:'풀빌라', cnt:1840 },
  { name:'제주 돌담 독채',     region:'제주', type:'독채',   cnt:1430 },
  { name:'루나 오션 펜션',     region:'강릉', type:'펜션',   cnt:1210 },
  { name:'신라 더 파크 호텔',  region:'서울', type:'호텔',   cnt:980  },
  { name:'경주 한옥 스테이',   region:'경주', type:'한옥',   cnt:870  },
];

const REVIEW_DATA = [
  { name:'신라 더 파크 호텔',  region:'서울', cnt:312, rating:4.9 },
  { name:'아만 스위트 리저브', region:'제주', cnt:287, rating:4.8 },
  { name:'루나 오션 펜션',     region:'강릉', cnt:241, rating:4.7 },
  { name:'해운대 씨뷰 스위트', region:'부산', cnt:198, rating:4.6 },
  { name:'제주 돌담 독채',     region:'제주', cnt:176, rating:4.8 },
];

const MEMBER_DATA = {
  labels: ['10월','11월','12월','1월','2월','3월'],
  total:  [38200, 39800, 41200, 42500, 43900, 45120],
  newMem: [1200,  1600,  1400,  1300,  1400,  1240],
  left:   [80,    70,    90,    65,    75,    83],
};

const ACC_TYPE = [
  { name:'호텔',      pct:32, cnt:4821, color:'#3B6EF8' },
  { name:'펜션',      pct:27, cnt:4073, color:'#8B5CF6' },
  { name:'풀빌라',    pct:18, cnt:2715, color:'#10B981' },
  { name:'독채',      pct:13, cnt:1961, color:'#F59E0B' },
  { name:'한옥',      pct:6,  cnt:905,  color:'#EF4444' },
  { name:'레지던스',  pct:4,  cnt:603,  color:'#94A3B8' },
];

/* ── 인기 숙소 렌더 ── */
function renderTopPlace(mode) {
  const sorted = [...PLACE_RANK_DATA].sort((a,b) =>
    mode === 'reservation' ? b.cnt - a.cnt : b.revenue - a.revenue
  );
  const maxVal = mode === 'reservation' ? sorted[0].cnt : sorted[0].revenue;
  const html = sorted.map((p, i) => {
    const val    = mode === 'reservation' ? p.cnt : p.revenue;
    const valStr = mode === 'reservation'
      ? '<b>' + val + '</b>건'
      : '<b>₩' + Math.round(val/10000) + '</b>만';
    const barW = Math.round(val / maxVal * 100);
    const nc = i===0?'top1':i===1?'top2':i===2?'top3':'';
    return `<li class="rank-item">
      <div class="rank-num ${nc}">${i+1}</div>
      <div class="rank-info">
        <h4>${p.name}</h4>
        <p>${p.region} &middot; ${p.type}</p>
      </div>
      <div class="rank-bar-wrap"><div class="rank-bar" style="width:${barW}%;background:#3B6EF8;"></div></div>
      <div class="rank-val">${valStr}</div>
    </li>`;
  }).join('');
  document.getElementById('topPlaceList').innerHTML = html;
}

/* ── 목적지 순위 렌더 ── */
function renderDest() {
  const max = DEST_DATA[0].cnt;
  const COLORS = ['#3B6EF8','#8B5CF6','#10B981','#F59E0B','#EF4444','#06B6D4','#94A3B8'];
  const html = DEST_DATA.map((d, i) => {
    const barW = Math.round(d.cnt / max * 100);
    return `<div class="dest-item">
      <div class="dest-icon" style="background:${COLORS[i]}18;color:${COLORS[i]};">${i+1}</div>
      <div class="dest-info">
        <h4>${d.name}</h4>
        <p>일정 생성 ${d.cnt.toLocaleString()}건 &middot; ${d.pct}%</p>
      </div>
      <div class="dest-bar-wrap"><div class="dest-bar" style="width:${barW}%;background:${COLORS[i]};"></div></div>
      <div class="dest-cnt">${d.cnt.toLocaleString()}</div>
    </div>`;
  }).join('');
  document.getElementById('destList').innerHTML = html;
}

/* ── 찜 순위 ── */
function renderWishlist() {
  const max = WISHLIST_DATA[0].cnt;
  const html = WISHLIST_DATA.map((p,i) => {
    const nc = i===0?'top1':i===1?'top2':i===2?'top3':'';
    return `<li class="rank-item">
      <div class="rank-num ${nc}">${i+1}</div>
      <div class="rank-info"><h4>${p.name}</h4><p>${p.region} &middot; ${p.type}</p></div>
      <div class="rank-bar-wrap"><div class="rank-bar" style="width:${Math.round(p.cnt/max*100)}%;background:#DB2777;"></div></div>
      <div class="rank-val"><b>${p.cnt.toLocaleString()}</b>개</div>
    </li>`;
  }).join('');
  document.getElementById('wishlistRankList').innerHTML = html;
}

/* ── 리뷰 순위 ── */
function renderReview() {
  const max = REVIEW_DATA[0].cnt;
  const html = REVIEW_DATA.map((p,i) => {
    const nc = i===0?'top1':i===1?'top2':i===2?'top3':'';
    return `<li class="rank-item">
      <div class="rank-num ${nc}">${i+1}</div>
      <div class="rank-info">
        <h4>${p.name}</h4>
        <p>${p.rating} / 5.0 &middot; ${p.region}</p>
      </div>
      <div class="rank-bar-wrap"><div class="rank-bar" style="width:${Math.round(p.cnt/max*100)}%;background:#F59E0B;"></div></div>
      <div class="rank-val"><b>${p.cnt}</b>건</div>
    </li>`;
  }).join('');
  document.getElementById('reviewRankList').innerHTML = html;
}

/* ── 숙소 타입 범례 ── */
function renderAccTypeLegend() {
  const html = ACC_TYPE.map(t =>
    `<div class="type-leg-item">
      <div class="type-dot" style="background:${t.color};"></div>
      <span class="type-name">${t.name}</span>
      <span class="type-pct">${t.pct}%</span>
      <span style="font-size:11px;color:var(--muted);margin-left:4px;">${t.cnt.toLocaleString()}건</span>
    </div>`
  ).join('');
  document.getElementById('accTypeLegend').innerHTML = html;
}

/* ── 초기 렌더 ── */
renderTopPlace('reservation');
renderDest();
renderWishlist();
renderReview();
renderAccTypeLegend();

/* ── 차트 ── */
document.addEventListener('DOMContentLoaded', () => {

  /* 회원 추이 — 라인 + 바 혼합 */
  new Chart(document.getElementById('memberChart'), {
    type:'bar',
    data:{
      labels: MEMBER_DATA.labels,
      datasets:[
        {
          type:'line', label:'누적 회원수',
          data: MEMBER_DATA.total,
          borderColor:'#3B6EF8',
          backgroundColor: ctx => {
            const g = ctx.chart.ctx.createLinearGradient(0,0,0,260);
            g.addColorStop(0,'rgba(59,110,248,.12)');
            g.addColorStop(1,'rgba(59,110,248,0)');
            return g;
          },
          fill:true, tension:.42, borderWidth:2.5,
          pointBackgroundColor:'#3B6EF8', pointRadius:4,
          yAxisID:'y'
        },
        {
          type:'bar', label:'신규 가입',
          data: MEMBER_DATA.newMem,
          backgroundColor:'rgba(16,185,129,.7)',
          borderRadius:4, borderSkipped:false,
          yAxisID:'y1'
        },
        {
          type:'bar', label:'탈퇴',
          data: MEMBER_DATA.left,
          backgroundColor:'rgba(239,68,68,.6)',
          borderRadius:4, borderSkipped:false,
          yAxisID:'y1'
        }
      ]
    },
    options:{
      responsive:true, maintainAspectRatio:false,
      plugins:{
        legend:{ position:'bottom', labels:{ padding:14, usePointStyle:true, pointStyleWidth:8 } }
      },
      scales:{
        x:{ grid:{ display:false } },
        y:{
          position:'left', grid:{ color:'rgba(0,0,0,.04)' },
          ticks:{ callback: v => (v/1000).toFixed(0)+'K' }
        },
        y1:{
          position:'right', grid:{ display:false },
          ticks:{ callback: v => v+'명' }
        }
      }
    }
  });

  /* 숙소 타입 도넛 */
  new Chart(document.getElementById('accTypeDoughnut'), {
    type:'doughnut',
    data:{
      labels: ACC_TYPE.map(t=>t.name),
      datasets:[{
        data: ACC_TYPE.map(t=>t.pct),
        backgroundColor: ACC_TYPE.map(t=>t.color),
        borderWidth:0, hoverOffset:5
      }]
    },
    options:{
      responsive:true, maintainAspectRatio:false, cutout:'65%',
      plugins:{ legend:{ display:false } }
    }
  });

});

/* ── 탭 전환 ── */
function switchPlaceRank(mode, btn) {
  btn.closest('.rank-tab').querySelectorAll('.rank-tab-btn').forEach(b => b.classList.remove('active'));
  btn.classList.add('active');
  renderTopPlace(mode);
}

function switchPeriod(mode, btn) {
  document.querySelectorAll('.period-tab .tab-btn').forEach(b => b.classList.remove('active'));
  btn.classList.add('active');
  /* TODO: 백엔드 연동 시 기간 파라미터 변경 후 fetch */
}
</script>
</body>
</html>
