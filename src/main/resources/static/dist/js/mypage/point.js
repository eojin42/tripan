

/* ── 아이콘 매핑 ── */
const TYPE_META = {
  earn:   { iconClass:'pi-icon-earn',   icon:'bi-plus-circle-fill',   amountClass:'amount-earn',   badge:'badge-earn',   label:'적립' },
  use:    { iconClass:'pi-icon-use',    icon:'bi-dash-circle-fill',    amountClass:'amount-use',    badge:'badge-use',    label:'사용' },
  expire: { iconClass:'pi-icon-expire', icon:'bi-exclamation-circle-fill', amountClass:'amount-expire', badge:'badge-expire', label:'소멸' }
};

let allPoints = [];
let currentFilter = 'all';
let currentPage = 1;
const PAGE_SIZE = 8;

/* ── 날짜 포맷 ── */
function fmtDate(d) {
  if (!d) return '';
  const dt = new Date(d);
  return `${dt.getFullYear()}.${String(dt.getMonth()+1).padStart(2,'0')}.${String(dt.getDate()).padStart(2,'0')}`;
}

/* ── 숫자 포맷 ── */
function fmtNum(n) { return Number(n || 0).toLocaleString(); }

/* ── HTML 이스케이프 ── */
function esc(s) { return String(s||'').replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;'); }

/* ── 포인트 내역 불러오기 ── */
async function loadPoints() {
  try {
    const res = await fetch(ctxPath + '/mypage/api/point/list', { credentials:'include' });
    if (!res.ok) throw new Error('fail');
    const data = await res.json();
    allPoints = data.list || [];

    // 요약 수치 바인딩
    document.getElementById('total-point').textContent    = fmtNum(data.totalPoint);
    document.getElementById('banner-month-earn').textContent = fmtNum(data.monthEarn);
    document.getElementById('banner-month-use').textContent  = fmtNum(data.monthUse);
    document.getElementById('month-earn').textContent     = fmtNum(data.monthEarn);
    document.getElementById('month-use').textContent      = fmtNum(data.monthUse);

    renderList();
  } catch(e) {
    // 데이터 없을 때 샘플 표시
    useSampleData();
  }
}

/* ── 샘플 데이터 (API 연동 전 UI 확인용) ── */
function useSampleData() {
  document.getElementById('total-point').textContent       = '12,500';
  document.getElementById('banner-month-earn').textContent = '3,500';
  document.getElementById('banner-month-use').textContent  = '1,000';
  document.getElementById('month-earn').textContent        = '3,500';
  document.getElementById('month-use').textContent         = '1,000';

  // point 테이블 구조: pointAmount 양수=적립, 음수=사용
  allPoints = [
    { pointAmount: 500,   changeReason:'숙소 예약 적립',        remPoint:12500, regDate:'2025-07-14 10:22' },
    { pointAmount: 200,   changeReason:'리뷰 작성 보너스',       remPoint:12000, regDate:'2025-07-10 14:05' },
    { pointAmount:-1000,  changeReason:'예약 결제 포인트 사용',   remPoint:11800, regDate:'2025-07-08 09:30' },
    { pointAmount: 1000,  changeReason:'이벤트 참여 적립',        remPoint:12800, regDate:'2025-07-05 18:00' },
    { pointAmount: 1500,  changeReason:'첫 예약 적립',           remPoint:11800, regDate:'2025-06-25 11:20' },
    { pointAmount: -500,  changeReason:'쿠폰 교환 사용',          remPoint:10300, regDate:'2025-06-20 16:44' },
    { pointAmount: 3000,  changeReason:'친구 초대 보너스',        remPoint:10800, regDate:'2025-06-15 09:00' },
    { pointAmount:  100,  changeReason:'출석 체크 적립',          remPoint: 7800, regDate:'2025-06-10 08:01' },
    { pointAmount:-2000,  changeReason:'숙소 결제 포인트 사용',   remPoint: 7700, regDate:'2025-06-05 13:55' },
    { pointAmount:  700,  changeReason:'숙소 예약 적립',          remPoint: 9700, regDate:'2025-05-28 10:10' },
    { pointAmount:-1000,  changeReason:'포인트 소멸',             remPoint: 9000, regDate:'2025-05-31 23:59' },
  ];
  renderList();
}

/* ── 렌더 ── */
function renderList() {
  const search = document.getElementById('point-search').value.trim().toLowerCase();
  let list = allPoints.filter(p => {
    const type = p.pointAmount > 0 ? 'earn' : 'use';
    const matchFilter = currentFilter === 'all' || currentFilter === type;
    const matchSearch = !search || (p.changeReason || '').toLowerCase().includes(search);
    return matchFilter && matchSearch;
  });

  const total = list.length;
  const totalPages = Math.max(1, Math.ceil(total / PAGE_SIZE));
  if (currentPage > totalPages) currentPage = 1;

  const paged = list.slice((currentPage-1)*PAGE_SIZE, currentPage*PAGE_SIZE);
  const area = document.getElementById('point-list-area');

  if (!paged.length) {
    area.innerHTML = `<div class="empty-state"><i class="bi bi-coin"></i><p>조건에 맞는 포인트 내역이 없어요.</p></div>`;
    document.getElementById('pagination-area').style.display = 'none';
    return;
  }

  area.innerHTML = paged.map(p => {
    const type = p.pointAmount > 0 ? 'earn' : 'use';
    const m    = TYPE_META[type];
    const sign = p.pointAmount > 0 ? '+' : '-';
    return `
      <div class="point-item">
        <div class="point-item-icon ${m.iconClass}"><i class="bi ${m.icon}"></i></div>
        <div class="point-item-info">
          <div class="pi-title">${esc(p.changeReason)}</div>
          <div class="pi-date"><i class="bi bi-calendar3" style="margin-right:4px;"></i>${p.regDate || ''}</div>
        </div>
        <span class="pi-badge ${m.badge}">${m.label}</span>
        <div class="point-item-amount ${m.amountClass}">${sign}${fmtNum(Math.abs(p.pointAmount))} P</div>
      </div>`;
  }).join('');

  renderPagination(totalPages);
}

function renderPagination(totalPages) {
  const pg = document.getElementById('pagination-area');
  if (totalPages <= 1) { pg.style.display='none'; return; }
  pg.style.display = 'flex';

  let html = `<button class="page-btn" onclick="goPage(${currentPage-1})" ${currentPage===1?'disabled':''}><i class="bi bi-chevron-left"></i></button>`;
  for (let i=1; i<=totalPages; i++) {
    html += `<button class="page-btn ${i===currentPage?'active':''}" onclick="goPage(${i})">${i}</button>`;
  }
  html += `<button class="page-btn" onclick="goPage(${currentPage+1})" ${currentPage===totalPages?'disabled':''}><i class="bi bi-chevron-right"></i></button>`;
  pg.innerHTML = html;
}

function goPage(n) {
  currentPage = n;
  renderList();
  window.scrollTo({top: document.getElementById('point-list-area').getBoundingClientRect().top + window.scrollY - 140, behavior:'smooth'});
}

function filterPoints(filter, btn) {
  currentFilter = filter;
  currentPage = 1;
  document.querySelectorAll('.tab-btn').forEach(b => b.classList.remove('active'));
  btn.classList.add('active');
  renderList();
}

function searchPoints() {
  currentPage = 1;
  renderList();
}

/* ── 모달 유틸 ── */
function openFollowModal(type) {
  document.getElementById('follow-modal-title').textContent = type === 'follower' ? '팔로워' : '팔로잉';
  document.getElementById('followModal').classList.add('active');
}
function closeModal(id) { document.getElementById(id).classList.remove('active'); }

/* ── 초기화 ── */
document.addEventListener('DOMContentLoaded', () => {
  loadPoints();

  // 사이드바 통계 불러오기 (main.js 공통 함수 없을 경우 대비)
  if (typeof loadSidebarStats === 'function') loadSidebarStats();
});