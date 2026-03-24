'use strict';

/* ═══════════════════════════════════════════
   place_detail.js
   장소 상세 페이지 – 캐러셀 / 지도 / 설명 토글 / 주변 장소
═══════════════════════════════════════════ */

/* ── 캐러셀 ── */
let slideIdx  = 0;
const total   = PLACE_DATA.imageCount;
const track   = document.getElementById('dtTrack');
const counter = document.getElementById('dtCounter');

function goSlide(n) {
  slideIdx = n;
  if (track) track.style.transform = `translateX(-${slideIdx * 100}%)`;
  if (counter) counter.textContent = `${slideIdx + 1} / ${total}`;
  document.querySelectorAll('.dt-thumb').forEach((t, i) => t.classList.toggle('active', i === slideIdx));
}

function slideMove(d) {
  if (total <= 1) return;
  goSlide((slideIdx + d + total) % total);
}

/* ── 설명 접기/펼치기 ── */
let expanded = false;

function toggleDesc() {
  expanded = !expanded;
  const desc    = document.getElementById('dtDesc');
  const moreBtn = document.getElementById('dtMoreBtn');
  if (!desc || !moreBtn) return;

  desc.classList.toggle('expanded', expanded);
  moreBtn.innerHTML = expanded
    ? `내용 접기 <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round"><polyline points="18 15 12 9 6 15"/></svg>`
    : `내용 더보기 <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round"><polyline points="6 9 12 15 18 9"/></svg>`;
}

/* ── 탭 스크롤 ── */
function scrollToSection(id, el) {
  document.querySelectorAll('.dt-tab').forEach(t => t.classList.remove('active'));
  el.classList.add('active');
  const section = document.getElementById(id);
  if (section) {
      // 헤더 높이(약 80px)만큼 여유를 두고 스크롤
      const yOffset = -150; 
      const y = section.getBoundingClientRect().top + window.pageYOffset + yOffset;
      window.scrollTo({top: y, behavior: 'smooth'});
  }
}

/* ── 카카오 지도 초기화 ── */
function initKakaoMap() {
  const container = document.getElementById('kakaoDetailMap');
  if (!container || !window.kakao?.maps) return;

  const lat = PLACE_DATA.lat;
  const lng = PLACE_DATA.lng;

  if (!lat || !lng || lat === 0 || lng === 0) {
    container.innerHTML = `<div style="display:flex;align-items:center;justify-content:center;height:100%;color:#AAA;font-size:14px;font-weight:600;">지도 정보가 없습니다</div>`;
    return;
  }

  const options = {
    center: new kakao.maps.LatLng(lat, lng),
    level: 3
  };
  const map    = new kakao.maps.Map(container, options);
  const marker = new kakao.maps.Marker({ position: new kakao.maps.LatLng(lat, lng) });
  marker.setMap(map);

  const infoWindow = new kakao.maps.InfoWindow({
    content: `<div style="padding:8px 12px;font-size:13px;font-weight:700;">${PLACE_DATA.name}</div>`
  });
  infoWindow.open(map, marker);
}

/* ── 주변 장소 로드 ── */
function loadNearbyPlaces() {
  // 🔥 id -> placeId 로 수정
  if (!PLACE_DATA.placeId) return;

  fetch(`${PLACE_DATA.contextPath}/api/places/${PLACE_DATA.placeId}/nearby`)
    .then(res => {
      if (!res.ok) throw new Error();
      return res.json();
    })
    .then(data => renderNearby(data))
    .catch(() => {
      const el = document.getElementById('nearbyList');
      if (el) el.innerHTML = `<div class="dt-nearby-empty">주변 장소 정보를 불러올 수 없습니다</div>`;
    });
}

function renderNearby(places) {
  const container = document.getElementById('nearbyList');
  if (!container) return;

  if (!places || places.length === 0) {
    container.innerHTML = `<div class="dt-nearby-empty">
      <div style="font-size:36px;margin-bottom:10px;">📍</div>
      <div>주변 장소 정보가 없습니다</div>
    </div>`;
    return;
  }

  const defaultImg = `${PLACE_DATA.contextPath}/dist/images/logo.png`;

  container.innerHTML = places.map(p => {
    // 🔥 변수명 수정: p.id -> p.placeId / p.name -> p.placeName / p.image -> p.imageUrl / p.location -> p.address
    const imgSrc = p.imageUrl || defaultImg;

    return `
    <div class="dt-nearby-item" 
         onclick="location.href='${PLACE_DATA.contextPath}/curation/detail?id=${p.placeId}'" 
         style="cursor:pointer;display:flex;gap:12px;padding:12px;border-radius:10px;border:1px solid #F0F0F0;margin-bottom:8px;transition:background .15s;">
      <img src="${imgSrc}" alt="${p.placeName}"
           style="width:72px;height:72px;border-radius:8px;object-fit:cover;flex-shrink:0;"
           onerror="this.src='${defaultImg}'">
      <div style="flex:1;min-width:0;">
        <div style="font-size:14px;font-weight:800;color:#1A1A1A;margin-bottom:4px;">${p.placeName}</div>
        <div style="font-size:12px;color:#888;">${p.address || ''}</div>
        <div style="font-size:11px;color:#AAA;margin-top:4px;">${p.category || ''}</div>
      </div>
    </div>`;
  }).join('');
}

/* ── DOMContentLoaded ── */
document.addEventListener('DOMContentLoaded', () => {
  // 카카오 지도 SDK 로드 완료 후 초기화
  if (window.kakao?.maps) {
    kakao.maps.load(initKakaoMap);
  }
  loadNearbyPlaces();
});

function escHtml(str) {
  if (!str) return '';
  return String(str)
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;');
}