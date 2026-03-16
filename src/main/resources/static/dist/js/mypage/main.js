const ctxPath = document.querySelector('meta[name="ctx-path"]')?.content
  || (window.location.pathname.startsWith('/tripan') ? '/tripan' : '');

function formatDate(v) {
  return v ? new Date(v).toLocaleDateString('ko-KR', { year: '2-digit', month: '2-digit', day: '2-digit' }) : '';
}
function escHtml(s) {
  return s ? String(s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;') : '';
}

// ── 여행 요약 ──
async function loadSummary() {
  try {
    const res = await fetch(ctxPath + '/mypage/api/summary');
    if (!res.ok) return;
    const data = await res.json();

    const setVal = (id, val) => { const el = document.getElementById(id); if (el) el.textContent = val ?? '-'; };
    setVal('val-trips',   data.totalTripCount   ?? 0);
    setVal('val-regions', data.visitedRegionCount ?? 0);
    setVal('val-avgdays', data.avgTripDays       ?? '-');
    setVal('val-history', data.completedTripCount ?? 0);

    if (data.member) {
      setVal('stat-follower',  data.member.followerCount);
      setVal('stat-following', data.member.followingCount);
      setVal('stat-badge',     data.member.badgeCount);
    }
  } catch (e) { console.error('요약 로드 실패', e); }
}

// ── 다가오는 일정 ──
async function loadUpcoming() {
  const area = document.getElementById('upcoming-area');
  if (!area) return;
  try {
    const res = await fetch(ctxPath + '/mypage/api/upcoming');
    if (!res.ok) throw new Error(res.status);
    const data = await res.json(); // { tripName, startDate, endDate, dday }

    if (!data || !data.tripName) {
      area.innerHTML = `
        <div class="upcoming-none">
          <div class="upcoming-none-icon"><i class="bi bi-calendar-plus"></i></div>
          <div class="upcoming-none-text">
            <h4>다가오는 일정이 없어요</h4>
            <p>새로운 여행을 계획해볼까요? ✈️</p>
          </div>
        </div>`;
      return;
    }

	const today = new Date();
	today.setHours(0, 0, 0, 0);
	const start = new Date(data.startDate);
	start.setHours(0, 0, 0, 0);
	const diff = Math.floor((start - today) / (1000 * 60 * 60 * 24));
	const ddayLabel = diff === 0 ? 'D-Day!' : diff > 0 ? `D-${diff}` : `D+${Math.abs(diff)}`;
    area.innerHTML = `
      <div class="upcoming-banner" onclick="location.href='${ctxPath}/mypage/schedule'">
        <i class="bi bi-airplane-fill"></i>
        <div class="up-info">
          <div class="up-lbl">다음 여행</div>
          <div class="up-name">${escHtml(data.tripName)}</div>
          <div class="up-date"><i class="bi bi-calendar3"></i>${formatDate(data.startDate)} ~ ${formatDate(data.endDate)}</div>
        </div>
        <div class="up-dday">${ddayLabel}</div>
      </div>`;
  } catch (e) {
    area.innerHTML = `
      <div class="upcoming-none">
        <div class="upcoming-none-icon"><i class="bi bi-calendar-x"></i></div>
        <div class="upcoming-none-text">
          <h4>일정을 불러올 수 없어요</h4>
          <p>잠시 후 다시 시도해주세요</p>
        </div>
      </div>`;
  }
}

// ── 관심 목록 ──
async function loadWishlist() {
  const area = document.getElementById('wish-list-area');
  if (!area) return;
  try {
    const res = await fetch(ctxPath + '/mypage/api/bookmarks');
    if (!res.ok) throw new Error(res.status);
    const list = await res.json();

    if (!list || list.length === 0) {
      area.innerHTML = `
        <div class="empty-state">
          <i class="bi bi-heart"></i>
          <p>찜한 항목이 없어요. 마음에 드는 숙소에 ❤️를 눌러보세요!</p>
        </div>`;
      return;
    }
	area.innerHTML = `<div class="wish-list">${list.slice(0,5).map(a => `
	      <div class="wish-item">
	        <div class="wish-info">
	          <div class="wish-name">${escHtml(a.placeName)}</div>
	          <div class="wish-meta">${escHtml(a.address || '')}</div>
	        </div>
	      </div>`).join('')}</div>`;
  } catch (e) {
    area.innerHTML = `<div class="empty-state"><i class="bi bi-heart"></i><p>찜한 항목이 없어요</p></div>`;
  }
}

// ── 찜 토글 ──
async function toggleWish(e, accomId, btn) {
  e.stopPropagation();
  try {
    const csrfToken  = document.querySelector("meta[name='_csrf']")?.content;
    const csrfHeader = document.querySelector("meta[name='_csrf_header']")?.content;
    const headers = { 'Content-Type': 'application/json' };
    if (csrfToken && csrfHeader) headers[csrfHeader] = csrfToken;
    await fetch(ctxPath + '/accom/' + accomId + '/wish', { method: 'POST', headers });
    // 목록에서 해당 아이템 제거
    btn.closest('.wish-item')?.remove();
    // 비어있으면 빈 상태 표시
    if (!document.querySelector('.wish-item')) {
      document.getElementById('wish-list-area').innerHTML =
        `<div class="empty-state"><i class="bi bi-heart"></i><p>찜한 숙소가 없어요</p></div>`;
    }
  } catch (e) { console.error(e); }
}

// ── 팔로워/팔로잉 모달 ──
async function openFollowModal(type) {
  const modal = document.getElementById('followModal');
  const title = document.getElementById('follow-modal-title');
  const body  = document.getElementById('follow-modal-body');
  if (!modal) return;
  title.textContent = type === 'follower' ? '팔로워' : '팔로잉';
  body.innerHTML    = '<div style="text-align:center;padding:30px;color:var(--muted);">불러오는 중...</div>';
  modal.classList.add('active');
  try {
    const res  = await fetch(ctxPath + '/mypage/api/' + type);
    const list = await res.json();
    if (!list.length) {
      body.innerHTML = '<div style="text-align:center;padding:30px;color:var(--muted);font-size:13px;">목록이 없습니다</div>';
      return;
    }
    body.innerHTML = list.map(u => `
      <div class="user-item">
        <div class="user-pic">${u.profileImg ? `<img src="${escHtml(u.profileImg)}">` : escHtml((u.nickname||'?')[0])}</div>
        <div>
          <div class="user-name">${escHtml(u.nickname)}</div>
          <div class="user-id" style="font-size:11px;color:var(--muted);">@${escHtml(u.username||'')}</div>
        </div>
      </div>`).join('');
  } catch (e) {
    body.innerHTML = '<div style="text-align:center;padding:30px;color:#FC8181;font-size:13px;">불러오기 실패</div>';
  }
}

window.closeModal = (id) => document.getElementById(id)?.classList.remove('active');

// ── 초기화 ──
document.addEventListener('DOMContentLoaded', () => {
  loadSummary();
  loadUpcoming();
  loadRecentAccom();
  loadWishlist();
});