'use strict';

/* ═══════════════════════════════════════════
   place_list.js
   장소 목록 페이지 – 검색 / 필터 / 무한스크롤
═══════════════════════════════════════════ */

let currentCat    = PLACE_CONFIG.initialCategory || '전체';
let currentRegion = PLACE_CONFIG.initialRegion   || '전체';
let currentOffset = 0;
const PAGE_SIZE   = 12;
let isFetching    = false;
let hasMore       = true;

/* URL 파라미터에 sort 있으면 selectbox 동기화 */
(function syncSortFromUrl() {
  const urlSort = new URLSearchParams(location.search).get('sort');
  if (urlSort) {
    const sel = document.getElementById('sortSelect');
    if (sel) sel.value = urlSort;
  }
})();

/* ── 초기화 ── */
document.addEventListener('DOMContentLoaded', () => {
  restoreActiveStates();

  // ★ currentOffset / hasMore를 먼저 세팅 후 observer 등록
  //   (순서가 반대면 observer가 offset=0으로 중복 fetch)
  const initialCards = document.querySelectorAll('.pl-card').length;
  currentOffset = initialCards > 0 ? initialCards : 0;
  if (initialCards < PAGE_SIZE) hasMore = false;

  initInfiniteScroll();
});

function restoreActiveStates() {
  document.querySelectorAll('.pl-cat-tab').forEach(btn => {
    const onclickVal = btn.getAttribute('onclick') || '';
    const match = onclickVal.match(/selectCat\(this,\s*'([^']+)'\)/);
    if (match) btn.classList.toggle('active', match[1] === currentCat);
  });
  document.querySelectorAll('.pl-region-btn').forEach(btn => {
    btn.classList.toggle('active', btn.textContent.trim() === currentRegion);
  });
}

/* ── 카테고리 선택 ── */
function selectCat(el, cat) {
  currentCat    = cat;
  currentOffset = 0;
  hasMore       = true;
  document.querySelectorAll('.pl-cat-tab').forEach(b => b.classList.remove('active'));
  el.classList.add('active');
  fetchPlaces(true);
}

/* ── 지역 선택 ── */
function selectRegion(el, region) {
  currentRegion = region;
  currentOffset = 0;
  hasMore       = true;
  document.querySelectorAll('.pl-region-btn').forEach(b => b.classList.remove('active'));
  el.classList.add('active');
  fetchPlaces(true);
}

/* ── 필터 초기화 ── */
function resetFilters() {
  currentCat    = '전체';
  currentRegion = '전체';
  currentOffset = 0;
  hasMore       = true;
  document.querySelectorAll('.pl-cat-tab').forEach((b, i)    => b.classList.toggle('active', i === 0));
  document.querySelectorAll('.pl-region-btn').forEach((b, i) => b.classList.toggle('active', i === 0));
  const searchInput = document.getElementById('mainSearchInput');
  if (searchInput) searchInput.value = '';
  fetchPlaces(true);
}

/* ── 장소 목록 API 호출 ── */
function fetchPlaces(reset = false) {
  if (isFetching || (!reset && !hasMore)) return;
  isFetching = true;

  if (reset) {
    currentOffset = 0;
    hasMore       = true;
    const grid = document.getElementById('placeGrid');
    if (grid) grid.innerHTML = '';
  }

  const keyword = (document.getElementById('mainSearchInput')?.value || '').trim();
  const sortEl  = document.getElementById('sortSelect');
  const sort    = sortEl ? sortEl.value : 'recent';

  const url = `${PLACE_CONFIG.contextPath}/api/places/curation`
    + `?category=${encodeURIComponent(currentCat)}`
    + `&region=${encodeURIComponent(currentRegion)}`
    + `&keyword=${encodeURIComponent(keyword)}`
    + `&offset=${currentOffset}`
    + `&limit=${PAGE_SIZE}`
    + `&sort=${encodeURIComponent(sort)}`;

  setLoading(true);

  fetch(url)
    .then(res => {
      if (!res.ok) throw new Error(`HTTP ${res.status}`);
      return res.json();
    })
    .then(data => {
      const list  = Array.isArray(data) ? data : (data.places || []);
      const total = data.total !== undefined ? data.total : null;
      renderPlaces(list, reset);
      hasMore        = list.length === PAGE_SIZE;
      currentOffset += list.length;
      if (total !== null) updateResultCount(total);
    })
    .catch(err => {
      console.error('장소 로드 실패:', err);
      showError();
    })
    .finally(() => {
      isFetching = false;
      setLoading(false);
    });
}

/* ── 카드 렌더링 ── */
function renderPlaces(places, reset) {
  const grid = document.getElementById('placeGrid');
  if (reset) grid.innerHTML = '';

  if (!places || places.length === 0) {
    if (reset) {
      grid.innerHTML = `
        <div class="pl-empty" id="emptyMsg">
          <div class="pl-empty-ico">🔍</div>
          <div class="pl-empty-msg">검색 결과가 없습니다</div>
        </div>`;
    }
    return;
  }

  const defaultImg = `${PLACE_CONFIG.contextPath}/dist/images/logo.png`;

  places.forEach(p => {
    const card     = document.createElement('div');
    card.className = 'pl-card';
    card.onclick   = () => goDetail(p.placeId);

    /* 이미지가 없으면 이미지 영역 자체를 숨김 */
    const imgSection = p.imageUrl ? `
      <div class="pl-card-img-wrap">
        <img class="pl-card-img"
             src="${escHtml(p.imageUrl)}"
             alt="${escHtml(p.placeName)}"
             onerror="this.closest('.pl-card-img-wrap').style.display='none'">
      </div>` : '';

    card.innerHTML = `
      ${imgSection}
      <div class="pl-card-body">
        <div class="pl-card-name">${escHtml(p.placeName)}</div>
        <div class="pl-card-loc">
          <svg width="10" height="10" viewBox="0 0 24 24" fill="none" stroke="#BDC7D3" stroke-width="2.5" stroke-linecap="round">
            <path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z"/>
            <circle cx="12" cy="10" r="3"/>
          </svg>
          ${escHtml(p.address || '')}
        </div>
        <div class="pl-card-stats">
          <div class="pl-card-stat">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <path d="M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 0 0-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 0 0 0-7.78z"/>
            </svg>
            ${p.likeCount || 0}
          </div>
          <div class="pl-card-stat">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/>
              <circle cx="12" cy="12" r="3"/>
            </svg>
            ${p.viewCount || 0}
          </div>
        </div>
      </div>`;

    grid.appendChild(card);
  });
}

/* ── 결과 카운트 업데이트 ── */
function updateResultCount(total) {
  const el = document.getElementById('totalCount');
  if (el) el.textContent = total;
}

/* ── 무한스크롤 ── */
function initInfiniteScroll() {
  const sentinel = document.getElementById('scrollSentinel');
  if (!sentinel) return;
  const observer = new IntersectionObserver(entries => {
    if (entries[0].isIntersecting && !isFetching && hasMore) fetchPlaces(false);
  }, { rootMargin: '200px' });
  observer.observe(sentinel);
}

/* ── 상세 페이지 이동 ── */
function goDetail(id) {
  location.href = `${PLACE_CONFIG.contextPath}/curation/detail?id=${id}`;
}

/* ── 북마크 토글 ── */
function toggleBookmark(el, placeId) {
  el.classList.toggle('saved');
  const isSaved = el.classList.contains('saved');
  fetch(`${PLACE_CONFIG.contextPath}/api/places/${placeId}/bookmark`, {
    method: isSaved ? 'POST' : 'DELETE',
    headers: { 'Content-Type': 'application/json' }
  }).catch(() => el.classList.toggle('saved'));
}

/* ── 유틸 ── */
function setLoading(show) {
  const spinner = document.getElementById('loadingSpinner');
  if (spinner) spinner.style.display = show ? 'block' : 'none';
}

function showError() {
  const grid = document.getElementById('placeGrid');
  if (grid && !grid.children.length) {
    grid.innerHTML = `
      <div class="pl-empty">
        <div class="pl-empty-ico">⚠️</div>
        <div class="pl-empty-msg">데이터를 불러오지 못했습니다</div>
      </div>`;
  }
}

function escHtml(str) {
  if (!str) return '';
  return String(str)
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;');
}