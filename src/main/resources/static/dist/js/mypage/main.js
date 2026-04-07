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

	const setVal = (id, val) => {
	      const el = document.getElementById(id);
	      if (el) el.textContent = val ?? 0;
	    };

	    setVal('val-trips',   data.totalTripCount ?? 0);
	    setVal('val-regions', data.visitedRegionCount ?? 0);
	    setVal('val-avgdays', data.avgTripDays ?? '-');
	    setVal('val-history', data.completedTripCount ?? 0);

	    // 팔로워/팔로잉
	    setVal('stat-follower',  data.followerCount ?? 0);
	    setVal('stat-following', data.followingCount ?? 0);

	    setVal('stat-mytrip', data.totalTripCount ?? 0);

	  } catch (e) {
	    console.error('요약 로드 실패', e);
	  }
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
	    <div class="upcoming-card-custom">
	      <div class="upcoming-info-group">
	        <div class="upcoming-icon-box">
	          <i class="bi bi-calendar-plus"></i>
	        </div>
	        <div class="upcoming-text-group">
	          <h4>다가오는 일정이 없어요</h4>
	          <p>새로운 여행을 계획해볼까요? ✈️</p>
	        </div>
	      </div>
	      <button class="btn-upcoming-go" onclick="location.href='${ctxPath}/trip/trip_create'" style="margin:0; padding:12px 24px; border-radius:12px;">
	        일정 만들기
	      </button>
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
      <div class="upcoming-banner" onclick="location.href='${ctxPath}/trip/${data.tripId}/workspace'">
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
	const cards = list.slice(0, 5).map(a => {
	  const placeId = a.placeId || a.accommodationId || a.id;

	  let imgSrc = a.thumbnailUrl || a.imageUrl || '';
	  if (imgSrc && !imgSrc.startsWith('http')) imgSrc = ctxPath + imgSrc;

	  const img = imgSrc
	    ? '<img src="' + escHtml(imgSrc) + '" style="width:100%;height:150px;object-fit:cover;">'
	    : '<div style="width:100%;height:150px;background:#E6F4FF;display:flex;align-items:center;justify-content:center;"><i class="bi bi-building" style="font-size:32px;color:#89CFF0;"></i></div>';

	  return '<div onclick="' + (
	      placeId
	        ? "location.href='" + ctxPath + "/accommodation/detail/" + placeId + "'"
	        : "alert('숙소 ID가 없습니다.')"
	    ) + '" '
	    + 'style="background:#fff;border-radius:12px;border:1px solid #E2E8F0;cursor:pointer;overflow:hidden;transition:all .2s;"'
	    + 'onmouseover="this.style.transform=\'translateY(-4px)\';this.style.boxShadow=\'0 8px 24px rgba(137,207,240,.2)\'"'
	    + 'onmouseout="this.style.transform=\'\';this.style.boxShadow=\'\'">'
	    + img
	    + '<div style="padding:10px;background:#F8FAFC;border-top:1px solid #E2E8F0;">'
	    + '<div style="font-size:13px;font-weight:800;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;">' + escHtml(a.placeName || a.name || '') + '</div>'
	    + '<div style="font-size:11px;color:#718096;margin-top:3px;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;">' + escHtml(a.address || '') + '</div>'
	    + '</div></div>';
	}).join('');

	    area.innerHTML = '<div style="display:grid;grid-template-columns:repeat(5,1fr);gap:12px;">' + cards + '</div>';

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


// ── 초기화 ──
document.addEventListener('DOMContentLoaded', () => {
  loadSummary();
  loadUpcoming();
   if (typeof loadRecentAccom === 'function') loadRecentAccom();
  loadWishlist();
  
});