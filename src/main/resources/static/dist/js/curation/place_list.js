'use strict';

/* ═══════════════════════════════════════════
   place_list.js
   장소 목록 페이지 – 검색 / 필터 / 무한스크롤
   상태 관리: URL 파라미터 기준
   뒤로가기 시 브라우저가 URL 자동 복원 → 필터 유지
═══════════════════════════════════════════ */

/* ── URL에서 현재 상태 읽기 (기본값: 최신순) ── */
function getStateFromUrl() {
  const p = new URLSearchParams(location.search);
  return {
    cat:     p.get('category') || '전체',
    region:  p.get('region')   || '전체',
    sort:    p.get('sort')     || 'recent',   // ← 기본값 최신순
    keyword: p.get('keyword')  || ''
  };
}

let state         = getStateFromUrl();
let currentCat    = state.cat;
let currentRegion = state.region;
let currentOffset = 0;
const PAGE_SIZE   = 12;
let isFetching    = false;
let hasMore       = true;

/* ── URL 파라미터 업데이트 (history에 push → 뒤로가기 지원) ── */
function pushState(cat, region, sort, keyword) {
  const p = new URLSearchParams();
  if (cat     && cat     !== '전체') p.set('category', cat);
  if (region  && region  !== '전체') p.set('region',   region);
  if (sort    && sort    !== 'recent') p.set('sort',    sort);
  if (keyword && keyword.trim())      p.set('keyword', keyword.trim());
  const qs = p.toString();
  history.pushState({ cat, region, sort, keyword },
    '', location.pathname + (qs ? '?' + qs : ''));
}

/* ── 초기화 ── */
document.addEventListener('DOMContentLoaded', () => {
  // UI 상태 복원 (URL 파라미터 기준)
  restoreActiveStates();

  // sort selectbox 복원
  const sortEl = document.getElementById('sortSelect');
  if (sortEl) sortEl.value = state.sort;

  // keyword 복원
  const keywordEl = document.getElementById('mainSearchInput');
  if (keywordEl && state.keyword) keywordEl.value = state.keyword;

  // 무한스크롤 초기화
  const initialCards = document.querySelectorAll('.pl-card').length;
  currentOffset = initialCards > 0 ? initialCards : 0;
  if (initialCards < PAGE_SIZE) hasMore = false;

  // SSR로 이미 렌더된 카드가 없으면 초기 fetch
  if (initialCards === 0) fetchPlaces(true);

  initInfiniteScroll();
});

/* ── 브라우저 뒤로/앞으로 버튼 ── */
window.addEventListener('popstate', (e) => {
  const s = e.state || getStateFromUrl();
  currentCat    = s.cat     || '전체';
  currentRegion = s.region  || '전체';

  const sortEl = document.getElementById('sortSelect');
  if (sortEl) sortEl.value = s.sort || 'recent';

  const keywordEl = document.getElementById('mainSearchInput');
  if (keywordEl) keywordEl.value = s.keyword || '';

  restoreActiveStates();
  fetchPlaces(true);
});

function restoreActiveStates() {
  document.querySelectorAll('.pl-cat-tab').forEach(btn => {
    const m = (btn.getAttribute('onclick') || '').match(/selectCat\(this,\s*'([^']+)'\)/);
    if (m) btn.classList.toggle('active', m[1] === currentCat);
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
  const sort    = document.getElementById('sortSelect')?.value || 'recent';
  const keyword = document.getElementById('mainSearchInput')?.value || '';
  pushState(cat, currentRegion, sort, keyword);
  fetchPlaces(true);
}

/* ── 지역 선택 ── */
function selectRegion(el, region) {
  currentRegion = region;
  currentOffset = 0;
  hasMore       = true;
  document.querySelectorAll('.pl-region-btn').forEach(b => b.classList.remove('active'));
  el.classList.add('active');
  const sort    = document.getElementById('sortSelect')?.value || 'recent';
  const keyword = document.getElementById('mainSearchInput')?.value || '';
  pushState(currentCat, region, sort, keyword);
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
  const sortEl = document.getElementById('sortSelect');
  if (sortEl) sortEl.value = 'recent';
  history.pushState({ cat: '전체', region: '전체', sort: 'recent', keyword: '' },
    '', location.pathname);
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

  // reset(필터/정렬 변경) 시 URL 업데이트 — selectCat/selectRegion에서 이미 pushState 했어도 덮어씀
  // sortSelect onchange 로 직접 호출된 경우에도 URL 반영됨
  if (reset) {
    pushState(currentCat, currentRegion, sort, keyword);
  }

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