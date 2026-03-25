'use strict';

/* ═══════════════════════════════════════════
   place_detail.js
   캐러셀 / 라이트박스 / 카카오지도 / 주변장소
   ※ workspace.jsp 방식과 동일: autoload=false → kakao.maps.load()
═══════════════════════════════════════════ */

const KAKAO_CAT_CODE = {
  TOUR: 'AT4', RESTAURANT: 'FD6', ACCOMMODATION: 'AD5',
  CULTURE: 'CT1', LEISURE: 'AT4', SHOPPING: 'MT1', FESTIVAL: 'AT4'
};

/* ════════════ 캐러셀 ════════════ */
let slideIdx = 0;
const total  = PLACE_DATA.imageCount;

function goSlide(n) {
  if (total <= 0) return;
  slideIdx = ((n % total) + total) % total;
  const track = document.getElementById('dtTrack');
  const ctr   = document.getElementById('dtCounter');
  if (track) track.style.transform = `translateX(-${slideIdx * 100}%)`;
  if (ctr)   ctr.textContent = `${slideIdx + 1} / ${total}`;
  document.querySelectorAll('.dt-thumb').forEach((t, i) =>
    t.classList.toggle('active', i === slideIdx)
  );
}

function slideMove(d) {
  if (total <= 1) return;
  goSlide(slideIdx + d);
}

/* ════════════ 라이트박스 ════════════ */
let lbIdx = 0;

function openLightbox(idx) {
  lbIdx = idx;
  _lbShow();
  document.getElementById('lbOverlay').classList.add('open');
  document.body.style.overflow = 'hidden';
}

function closeLightbox() {
  document.getElementById('lbOverlay').classList.remove('open');
  document.body.style.overflow = '';
}

function lbMove(d) {
  lbIdx = ((lbIdx + d + total) % total);
  _lbShow();
  goSlide(lbIdx);
}

function _lbShow() {
  const imgs = PLACE_DATA.images || [];
  const img  = document.getElementById('lbImg');
  const ctr  = document.getElementById('lbCounter');
  if (img && imgs[lbIdx]) img.src = imgs[lbIdx];
  if (ctr) ctr.textContent = total > 1 ? `${lbIdx + 1} / ${total}` : '';
}

/* ════════════ 설명 토글 ════════════ */
let expanded = false;

function toggleDesc() {
  expanded = !expanded;
  document.getElementById('dtDesc')?.classList.toggle('expanded', expanded);
  const btn = document.getElementById('dtMoreBtn');
  if (btn) btn.innerHTML = expanded
    ? `내용 접기 <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round"><polyline points="18 15 12 9 6 15"/></svg>`
    : `내용 더보기 <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round"><polyline points="6 9 12 15 18 9"/></svg>`;
}

/* ════════════════════════════════════════
   카카오 지도 초기화
   workspace.jsp 방식과 동일:
     SDK는 autoload=false 로 로드됨
     → kakao.maps.load() 콜백 안에서 초기화
════════════════════════════════════════ */
function initKakaoMap() {
  const container = document.getElementById('kakaoDetailMap');
  if (!container) return;

  const { lat, lng, name } = PLACE_DATA;

  /* 위경도 없으면 지도 컨테이너 숨기기 */
  if (!lat || !lng || lat === 0 || lng === 0) {
    container.closest('.dt-map-section')?.remove();
    return;
  }

  /* ── 지도 생성 (마커 예시 코드와 동일 방식) ── */
  const mapOption = {
    center: new kakao.maps.LatLng(lat, lng),
    level: 4
  };
  const map = new kakao.maps.Map(container, mapOption);

  /* 현재 장소 마커 */
  const markerPosition = new kakao.maps.LatLng(lat, lng);
  const marker = new kakao.maps.Marker({ position: markerPosition });
  marker.setMap(map);

  /* InfoWindow */
  const infoWindow = new kakao.maps.InfoWindow({
    content: `<div style="padding:6px 12px;font-size:13px;font-weight:700;white-space:nowrap;">${escHtml(name)}</div>`
  });
  infoWindow.open(map, marker);

  /* 주변 장소 검색 (카카오 Places) */
  loadNearbyKakao(map);
}

/* ════════════════════════════════════════
   주변 장소
════════════════════════════════════════ */
function loadNearbyKakao(map) {
  const { lat, lng, category } = PLACE_DATA;
  const catCode = KAKAO_CAT_CODE[category];

  if (!catCode || !kakao?.maps?.services?.Places) {
    loadNearbyServer(); return;
  }

  const ps       = new kakao.maps.services.Places();
  const location = new kakao.maps.LatLng(lat, lng);
  const infoWin  = new kakao.maps.InfoWindow({ zIndex: 1 });

  ps.categorySearch(catCode, (data, status) => {
    if (status !== kakao.maps.services.Status.OK || !data?.length) {
      loadNearbyServer(); return;
    }

    const places = data.slice(0, 8);

    /* 지도에 주변 마커 표시 */
    places.forEach(p => {
      const pos    = new kakao.maps.LatLng(p.y, p.x);
      const mk     = new kakao.maps.Marker({ map, position: pos });
      kakao.maps.event.addListener(mk, 'click', () => {
        infoWin.setContent(`<div style="padding:5px 10px;font-size:12px;font-weight:700;white-space:nowrap;">${p.place_name}</div>`);
        infoWin.open(map, mk);
      });
    });

    renderNearbyKakao(places);
  }, { location, radius: 2000, sort: kakao.maps.services.SortBy.DISTANCE });
}

function renderNearbyKakao(places) {
  const el = document.getElementById('nearbyList');
  if (!el) return;
  if (!places?.length) { renderNearbyEmpty(); return; }

  el.innerHTML = `<div class="dt-nearby-list">` + places.map(p => `
    <a class="dt-nearby-item"
       href="${escHtml(p.place_url || '#')}"
       target="_blank" rel="noopener noreferrer">
      <div class="dt-nearby-thumb">
        <svg width="26" height="26" viewBox="0 0 24 24" fill="none" stroke="#007AFF" stroke-width="1.8" stroke-linecap="round">
          <path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z"/>
          <circle cx="12" cy="10" r="3"/>
        </svg>
      </div>
      <div class="dt-nearby-info">
        <div class="dt-nearby-name">${escHtml(p.place_name)}</div>
        <div class="dt-nearby-addr">${escHtml(p.road_address_name || p.address_name || '')}</div>
        <div class="dt-nearby-dist">${p.distance ? p.distance + 'm' : ''}</div>
      </div>
      <svg class="dt-nearby-chev" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round">
        <polyline points="9 18 15 12 9 6"/>
      </svg>
    </a>`
  ).join('') + `</div>`;
}

/* ── 서버 DB fallback ── */
function loadNearbyServer() {
  const { placeId, contextPath } = PLACE_DATA;
  if (!placeId) { renderNearbyEmpty(); return; }

  fetch(`${contextPath}/api/places/${placeId}/nearby`)
    .then(res => { if (!res.ok) throw new Error(res.status); return res.json(); })
    .then(data => renderNearbyServer(data))
    .catch(() => renderNearbyEmpty());
}

function renderNearbyServer(places) {
  const el = document.getElementById('nearbyList');
  if (!el) return;
  if (!places?.length) { renderNearbyEmpty(); return; }

  const defaultImg = `${PLACE_DATA.contextPath}/dist/images/logo.png`;
  el.innerHTML = `<div class="dt-nearby-list">` + places.map(p => `
    <div class="dt-nearby-item"
         onclick="location.href='${PLACE_DATA.contextPath}/curation/detail?id=${p.placeId}'">
      <div class="dt-nearby-thumb">
        <img src="${escHtml(p.imageUrl || defaultImg)}" alt=""
             onerror="this.src='${defaultImg}'"
             style="width:100%;height:100%;object-fit:cover;">
      </div>
      <div class="dt-nearby-info">
        <div class="dt-nearby-name">${escHtml(p.placeName)}</div>
        <div class="dt-nearby-addr">${escHtml(p.address || '')}</div>
        <div class="dt-nearby-dist">${escHtml(p.category || '')}</div>
      </div>
      <svg class="dt-nearby-chev" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round">
        <polyline points="9 18 15 12 9 6"/>
      </svg>
    </div>`
  ).join('') + `</div>`;
}

function renderNearbyEmpty() {
  const el = document.getElementById('nearbyList');
  if (el) el.innerHTML = `<div class="dt-nearby-empty"><div class="dt-ne-ico">📍</div><p>주변 장소 정보가 없습니다</p></div>`;
}

/* ════════════ DOMContentLoaded ════════════ */
document.addEventListener('DOMContentLoaded', () => {
  /* ESC / 방향키 */
  document.addEventListener('keydown', e => {
    if (e.key === 'Escape')       closeLightbox();
    if (e.key === 'ArrowLeft')    lbMove(-1);
    if (e.key === 'ArrowRight')   lbMove(1);
  });

  /* ─ 카카오 SDK 초기화 ─
     workspace.jsp 방식과 동일:
     SDK가 autoload=false로 로드되었으므로 반드시 kakao.maps.load() 호출 */
  if (window.kakao && kakao.maps) {
    kakao.maps.load(() => {
      initKakaoMap();
    });
  } else {
    /* SDK 자체가 없으면 (key 없거나 로드 실패) 서버 fallback */
    loadNearbyServer();
  }
});

/* ════════════ 유틸 ════════════ */
function escHtml(str) {
  if (!str) return '';
  return String(str)
    .replace(/&/g, '&amp;').replace(/</g, '&lt;')
    .replace(/>/g, '&gt;').replace(/"/g, '&quot;');
}
