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

    document.getElementById('val-trips')?.let(el => el.textContent = data.totalTripCount ?? 0);
    document.getElementById('val-regions')?.let(el => el.textContent = data.visitedRegionCount ?? 0);
    document.getElementById('val-avgdays')?.let(el => el.textContent = (data.avgTripDays ?? '-'));
    document.getElementById('val-history')?.let(el => el.textContent = data.completedTripCount ?? 0);

    if (data.member) {
      const setEl = (id, val) => { const el = document.getElementById(id); if (el) el.textContent = val ?? 0; };
      setEl('stat-follower',  data.member.followerCount);
      setEl('stat-following', data.member.followingCount);
      setEl('stat-badge',     data.member.badgeCount);
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

    const ddayLabel = data.dday === 0 ? 'D-Day!' : data.dday > 0 ? `D-${data.dday}` : `D+${Math.abs(data.dday)}`;
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

// ── 최근 본 숙소 ──
async function loadRecentAccom() {
  const area = document.getElementById('recent-accom-area');
  if (!area) return;
  try {
    const res = await fetch(ctxPath + '/mypage/api/recent-accom?limit=3');
    if (!res.ok) throw new Error(res.status);
    const list = await res.json();

    if (!list || list.length === 0) {
      area.innerHTML = `
        <div class="empty-state">
          <i class="bi bi-building"></i>
          <p>최근 본 숙소가 없어요. 마음에 드는 숙소를 찾아보세요!</p>
        </div>`;
      return;
    }

    area.innerHTML = `<div class="accom-grid">${list.map(a => `
      <div class="accom-card" onclick="location.href='${ctxPath}/accom/${a.accomId}'">
        <div class="accom-thumb">
          ${a.thumbUrl
            ? `<img src="${escHtml(a.thumbUrl)}" alt="${escHtml(a.name)}" loading="lazy">`
            : `<i class="bi bi-building"></i>`}
        </div>
        <div class="accom-info">
          <div class="accom-name">${escHtml(a.name)}</div>
          <div class="accom-loc"><i class="bi bi-geo-alt-fill" style="color:var(--sky);font-size:10px;"></i>${escHtml(a.location || '')}</div>
          ${a.price ? `<div class="accom-price">${Number(a.price).toLocaleString()}원 <span>/ 1박</span></div>` : ''}
        </div>
      </div>`).join('')}</div>`;
  } catch (e) {
    area.innerHTML = `<div class="empty-state"><i class="bi bi-building"></i><p>숙소 정보를 불러올 수 없어요</p></div>`;
  }
}

// ── 관심 목록 ──
async function loadWishlist() {
  const area = document.getElementById('wish-list-area');
  if (!area) return;
  try {
    const res = await fetch(ctxPath + '/mypage/api/wishlist?limit=5');
    if (!res.ok) throw new Error(res.status);
    const list = await res.json();

    if (!list || list.length === 0) {
      area.innerHTML = `
        <div class="empty-state">
          <i class="bi bi-heart"></i>
          <p>찜한 숙소가 없어요. 마음에 드는 숙소에 ❤️를 눌러보세요!</p>
        </div>`;
      return;
    }

    area.innerHTML = `<div class="wish-list">${list.map(a => `
      <div class="wish-item" onclick="location.href='${ctxPath}/accom/${a.accomId}'">
        <div class="wish-thumb">
          ${a.thumbUrl
            ? `<img src="${escHtml(a.thumbUrl)}" alt="${escHtml(a.name)}">`
            : `<i class="bi bi-building"></i>`}
        </div>
        <div class="wish-info">
          <div class="wish-name">${escHtml(a.name)}</div>
          <div class="wish-meta">${escHtml(a.location || '')}${a.rating ? ` · ⭐ ${a.rating}` : ''}</div>
        </div>
        ${a.price ? `<div class="wish-price">${Number(a.price).toLocaleString()}원</div>` : ''}
        <button class="btn-heart" onclick="toggleWish(event, ${a.accomId}, this)">♥</button>
      </div>`).join('')}</div>`;
  } catch (e) {
    area.innerHTML = `<div class="empty-state"><i class="bi bi-heart"></i><p>관심 목록을 불러올 수 없어요</p></div>`;
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