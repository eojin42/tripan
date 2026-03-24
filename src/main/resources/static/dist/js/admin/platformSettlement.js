/**
 * 플랫폼 정산 JS
 *
 * 숫자 정책:
 *   · KPI 카드          → 원 단위 전체 (예: 42,300,000)  우상단 없음
 *   · 수익흐름(워터폴)   → 천원 단위   (예: 42,300)      우상단 (단위: 천원)
 *   · 수익구조 분해 바   → 천원 단위   (예: 42,300)      우상단 (단위: 천원)
 *   · 차트 Y축           → 천원 단위
 *   · 테이블             → 원 단위 전체
 */

Chart.defaults.font.family = "'Noto Sans KR', sans-serif";
Chart.defaults.font.size   = 11;
Chart.defaults.color       = '#8B92A5';

let revenueChart = null;

/* ─────────────────────────────────────────
   포맷 헬퍼
───────────────────────────────────────── */
// 원 단위 전체 (KPI 카드, 테이블)
function fmtWon(n) {
  if (n == null) return '0';
  return n.toLocaleString();
}

// 천원 단위 (워터폴, 분해 바, 차트)
function fmtK(n) {
  if (n == null) return '0';
  return Math.floor(n / 1000).toLocaleString();
}

function setText(id, val) {
  const el = document.getElementById(id);
  if (el) el.textContent = val;
}

function setBarWidth(id, pct) {
  const el = document.getElementById(id);
  if (el) el.style.width = Math.min(Math.max(pct ?? 0, 2), 100).toFixed(1) + '%';
}

/* ─────────────────────────────────────────
   메인 로드
───────────────────────────────────────── */
function loadData() {
  const year  = document.getElementById('filterYear').value;
  const month = document.getElementById('filterMonth').value;

  const params = new URLSearchParams({ year });
  if (month) params.append('month', month);

  fetch(`${contextPath}/admin/settlement/platform/data?` + params)
    .then(res => { if (!res.ok) throw new Error(res.status); return res.json(); })
    .then(data => {
      renderBanner(data.kpi);
      renderKpi(data.kpi);
      renderWaterfall(data.kpi);
      renderBreakdown(data.kpi, year, month);
      renderTable(data.monthlyList, data.total);
      renderChart(data.dailyChart);
    })
    .catch(err => {
      console.error('[PlatformSettlement] 로드 실패', err);
      alert('데이터를 불러오는 데 실패했습니다.');
    });
}

/* ─────────────────────────────────────────
   미정산 배너
───────────────────────────────────────── */
function renderBanner(kpi) {
	const count = kpi.pendingPartnerCount ?? 0;
	 setText('pendingCount', count);
	 setText('pendingAmt',   '₩' + fmtWon(kpi.pendingAmount));

	 // 0이면 배너 숨기기
	 const banner = document.querySelector('.alert-banner');
	 if (banner) banner.style.display = count > 0 ? 'flex' : 'none';
}

/* ─────────────────────────────────────────
   KPI 카드 — ₩ + 원 단위 전체
───────────────────────────────────────── */
function renderKpi(kpi) {
  setText('kpiGmv',        '₩' + fmtWon(kpi.gmv));
  setText('kpiProfit',     '₩' + fmtWon(kpi.netProfit));
  setText('kpiCommission', '₩' + fmtWon(kpi.commission));
  setText('kpiDiscount',   '₩' + fmtWon(kpi.couponDiscount + kpi.pointUsed));

  const trend   = kpi.gmvTrendPct ?? 0;
  const trendEl = document.getElementById('kpiGmvTrend');
  if (trendEl) {
    trendEl.textContent = (trend >= 0 ? '↑ ' : '↓ ') + Math.abs(trend).toFixed(1) + '%';
    trendEl.className   = trend >= 0 ? 'trend-up' : 'trend-down';
  }
  setText('kpiCommissionRate', kpi.commissionRate.toFixed(1) + '%');
  setText('kpiCoupon', '쿠폰 ₩' + fmtWon(kpi.couponDiscount));
  setText('kpiPoint',  '포인트 ₩' + fmtWon(kpi.pointUsed));
}

/* ─────────────────────────────────────────
   워터폴 — 천원 단위, JS에서 (단위: 천원) 삽입
───────────────────────────────────────── */
function renderWaterfall(kpi) {
  const gmv    = kpi.gmv    || 1;
  const payout = kpi.partnerPayout;
  const coupon = kpi.couponDiscount;
  const point  = kpi.pointUsed;
  const profit = kpi.netProfit;

  // 제목 옆 (단위: 천원) 동적 삽입
  const wfTitle = document.getElementById('waterfallTitle');
  if (wfTitle && !wfTitle.querySelector('.unit-tag')) {
    wfTitle.insertAdjacentHTML('beforeend', '<span class="unit-tag" style="font-size:11px;color:var(--muted);font-weight:600;margin-left:6px;">(단위: 천원)</span>');
  }

  setText('waGmv',    fmtK(gmv));
  setText('waPayout', fmtK(payout));
  setText('waCoupon', fmtK(coupon));
  setText('waPoint',  fmtK(point));
  setText('waProfit', fmtK(profit));

  setBarWidth('wbPayout', payout / gmv * 100);
  setBarWidth('wbCoupon', coupon / gmv * 100);
  setBarWidth('wbPoint',  point  / gmv * 100);
  setBarWidth('wbProfit', Math.max(profit / gmv * 100, 0));
}

/* ─────────────────────────────────────────
   수익 구조 분해 바 — 천원 단위, JS에서 (단위: 천원) 삽입
───────────────────────────────────────── */
function renderBreakdown(kpi, year, month) {
  const gmv    = kpi.gmv || 1;
  const payout = kpi.partnerPayout;
  const comm   = kpi.commission;
  const disc   = kpi.couponDiscount + kpi.pointUsed;
  const etc    = Math.max(gmv - payout - comm - disc, 0);

  const label = month ? `${year}년 ${parseInt(month, 10)}월` : `${year}년 전체`;
  setText('bdLabel', label);

  // GMV 우상단 — (단위: 천원) 삽입
  const bdGmvEl = document.getElementById('bdGmvTotal');
  if (bdGmvEl) bdGmvEl.textContent = 'GMV ' + fmtK(gmv);
  const bdUnitEl = document.getElementById('bdUnit');
  if (bdUnitEl) bdUnitEl.textContent = '(단위: 천원)';

  setText('bdPayout',   fmtK(payout));
  setText('bdComm',     fmtK(comm));
  setText('bdDiscount', fmtK(disc));
  setText('bdEtc',      fmtK(etc));

  setBarWidth('bdSegPayout',   payout / gmv * 100);
  setBarWidth('bdSegComm',     comm   / gmv * 100);
  setBarWidth('bdSegDiscount', disc   / gmv * 100);
  setBarWidth('bdSegEtc',      etc    / gmv * 100);
}

/* ─────────────────────────────────────────
   월별 정산 테이블
   ※ JSP tbody에 id="settlementTbody",
      tfoot에 id="settlementTfoot" 반드시 필요!
───────────────────────────────────────── */
function renderTable(list, total) {
  const tbody = document.getElementById('settlementTbody');
  const tfoot = document.getElementById('settlementTfoot');
  if (!tbody) return;

  if (!list || list.length === 0) {
    tbody.innerHTML = `<tr><td colspan="9" style="text-align:center;color:var(--muted);padding:24px;">
      해당 기간의 정산 데이터가 없습니다.</td></tr>`;
    if (tfoot) tfoot.innerHTML = '';
    return;
  }

  tbody.innerHTML = list.map(row => `
    <tr onclick="goPartner('${row.settlementMonth}')" style="cursor:pointer;">
      <td><strong>${row.settlementMonth}</strong></td>
      <td class="num text-blue">${fmtWon(row.gmv)}</td>
      <td class="num text-muted">${fmtWon(row.partnerPayout)}</td>
      <td class="num text-purple">${fmtWon(row.commission)}</td>
      <td class="num text-amber">${fmtWon(row.couponDiscount)}</td>
      <td class="num text-amber">${fmtWon(row.pointUsed)}</td>
      <td class="num text-green">${fmtWon(row.netProfit)}</td>
      <td class="num">${row.partnerCount}</td>
      <td><span class="badge ${row.statusBadgeClass}">${row.statusLabel}</span></td>
    </tr>
  `).join('');

  if (tfoot && total) {
    tfoot.innerHTML = `
      <tr class="tfoot-row">
        <td>${total.settlementMonth}</td>
        <td class="num text-blue">${fmtWon(total.gmv)}</td>
        <td class="num text-muted">${fmtWon(total.partnerPayout)}</td>
        <td class="num text-purple">${fmtWon(total.commission)}</td>
        <td class="num text-amber">${fmtWon(total.couponDiscount)}</td>
        <td class="num text-amber">${fmtWon(total.pointUsed)}</td>
        <td class="num text-green">${fmtWon(total.netProfit)}</td>
        <td></td><td></td>
      </tr>`;
  }
}

/* ─────────────────────────────────────────
   일별 수익 추이 차트
   · ORDER_DATE 기준이므로 오늘 이후 데이터 없음
   · Y축: 천원 단위
───────────────────────────────────────── */
function renderChart(dailyList) {
  const canvas = document.getElementById('revenueChart');
  if (!canvas) return;

  if (revenueChart) { revenueChart.destroy(); revenueChart = null; }

  if (!dailyList || dailyList.length === 0) {
    // 빈 상태 텍스트
    const parent = canvas.parentElement;
    parent.innerHTML = `<div style="height:210px;display:flex;align-items:center;
      justify-content:center;color:var(--muted);font-size:13px;">
      해당 기간의 데이터가 없습니다.</div>`;
    return;
  }

  const labels     = dailyList.map(d => d.day);
  const commData   = dailyList.map(d => Math.round(d.commission / 1000));
  const profitData = dailyList.map(d => Math.round(d.netProfit  / 1000));

  revenueChart = new Chart(canvas, {
    type: 'line',
    data: {
      labels,
      datasets: [
        {
          label: '수수료 수익',
          data: commData,
          borderColor: '#8B5CF6',
          backgroundColor: ctx => {
            const g = ctx.chart.ctx.createLinearGradient(0, 0, 0, 200);
            g.addColorStop(0, 'rgba(139,92,246,.18)');
            g.addColorStop(1, 'rgba(139,92,246,0)');
            return g;
          },
          fill: true, tension: .42, borderWidth: 2.5,
          pointBackgroundColor: '#8B5CF6', pointRadius: 3
        },
        {
          label: '플랫폼 순이익',
          data: profitData,
          borderColor: '#10B981',
          backgroundColor: 'transparent',
          tension: .42, borderWidth: 2, borderDash: [5, 4],
          pointBackgroundColor: '#10B981', pointRadius: 3
        }
      ]
    },
    options: {
      responsive: true, maintainAspectRatio: false,
      plugins: {
        legend: { position: 'bottom', labels: { padding: 14, usePointStyle: true, pointStyleWidth: 8 } },
        tooltip: {
          callbacks: {
            label: ctx => ` ${ctx.dataset.label}: ${ctx.raw.toLocaleString()}천원`
          }
        }
      },
      scales: {
        x: { grid: { display: false } },
        y: {
          grid: { color: 'rgba(0,0,0,.04)' },
          ticks: { callback: v => v.toLocaleString() + '천' }
        }
      }
    }
  });
}

/* ─────────────────────────────────────────
   파트너 상세 이동
───────────────────────────────────────── */
function goPartner(month) {
  location.href = contextPath + '/admin/settlement/partner/main?month=' + month;
}

/* ─────────────────────────────────────────
   초기화
───────────────────────────────────────── */
document.addEventListener('DOMContentLoaded', () => {
  loadData();
  document.getElementById('filterYear') .addEventListener('change', loadData);
  document.getElementById('filterMonth').addEventListener('change', loadData);
});