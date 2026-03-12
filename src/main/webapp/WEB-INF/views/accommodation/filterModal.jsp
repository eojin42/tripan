<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>

<div class="modal-overlay" id="filterOverlay" onclick="closeFilterModal()"></div>
<div class="custom-modal" id="filterModal">
  <div class="c-modal-header">
    <div class="c-modal-title">필터</div>
    <button class="btn-close-modal" onclick="closeFilterModal()">✕</button>
  </div>

  <div class="c-modal-body">
    <div class="filter-section">
      <h4 class="filter-label">요금 범위 (1박 기준)</h4>
      <p style="text-align:center; font-weight:800; font-size:18px; margin-bottom:16px;">
        <span id="disp-min-price">0</span>만원 ~ <span id="disp-max-price">50</span>만원+
      </p>
      <div style="display:flex; gap:12px; align-items:center;">
        <input type="number" id="input-min-price" class="price-input" placeholder="최소 0" value="0" oninput="updatePriceUI()">
        <span>-</span>
        <input type="number" id="input-max-price" class="price-input" placeholder="최대 50" value="500000" oninput="updatePriceUI()">
      </div>
    </div>

    <div class="filter-section">
      <h4 class="filter-label">숙소 타입</h4>
      <div class="amenity-grid" id="accTypeGrid">
        <label class="amenity-chip"><input type="checkbox" value="관광호텔"> 🏨 관광호텔</label>
        <label class="amenity-chip"><input type="checkbox" value="모텔"> 🛏️ 모텔</label>
        <label class="amenity-chip"><input type="checkbox" value="펜션"> 🏡 펜션</label>
        <label class="amenity-chip"><input type="checkbox" value="게스트하우스"> 🎒 게스트하우스</label>
        <label class="amenity-chip"><input type="checkbox" value="한옥"> 🏯 한옥</label>
        <label class="amenity-chip"><input type="checkbox" value="기타"> ⛺ 기타</label>
      </div>
    </div>

    <div class="filter-section">
      <h4 class="filter-label">숙소 편의 시설</h4>
      <div class="amenity-grid" id="accAmenityGrid">
        <label class="amenity-chip"><input type="checkbox" value="FITNESS"> 💪 피트니스</label>
        <label class="amenity-chip"><input type="checkbox" value="CHKCOOKING"> 🍳 취사 가능</label>
        <label class="amenity-chip"><input type="checkbox" value="BARBECUE"> 🍖 바베큐장</label>
        <label class="amenity-chip"><input type="checkbox" value="BEVERAGE"> ☕ 식음료장</label>
        <label class="amenity-chip"><input type="checkbox" value="KARAOKE"> 🎤 노래방</label>
        <label class="amenity-chip"><input type="checkbox" value="PUBLICPC"> 💻 공용 PC</label>
        <label class="amenity-chip"><input type="checkbox" value="SAUNA"> ♨️ 사우나</label>
      </div>
    </div>

    <div class="filter-section">
      <h4 class="filter-label">객실 편의 시설</h4>
      <div class="amenity-grid" id="roomAmenityGrid">
        <label class="amenity-chip"><input type="checkbox" value="ROOMBATHFACILITY"> 🚿 객실 내 목욕시설</label>
        <label class="amenity-chip"><input type="checkbox" value="ROOMBATH"> 🛁 욕조</label>
        <label class="amenity-chip"><input type="checkbox" value="ROOMHOMETHEATER"> 🎬 홈시어터</label>
        <label class="amenity-chip"><input type="checkbox" value="ROOMAIRCONDITION"> ❄️ 에어컨</label>
        <label class="amenity-chip"><input type="checkbox" value="ROOMTV"> 📺 TV</label>
        <label class="amenity-chip"><input type="checkbox" value="ROOMPC"> 🖥️ 객실 PC</label>
        <label class="amenity-chip"><input type="checkbox" value="ROOMINTERNET"> 📶 인터넷/와이파이</label>
        <label class="amenity-chip"><input type="checkbox" value="ROOMREFRIGERATOR"> 🧊 냉장고</label>
        <label class="amenity-chip"><input type="checkbox" value="ROOMTOILETRIES"> 🪥 세면도구</label>
        <label class="amenity-chip"><input type="checkbox" value="ROOMSOFA"> 🛋️ 소파</label>
        <label class="amenity-chip"><input type="checkbox" value="ROOMTABLE"> 🪑 테이블</label>
        <label class="amenity-chip"><input type="checkbox" value="ROOMHAIRDRYER"> 💨 헤어드라이어</label>
      </div>
    </div>
  </div>

  <div class="c-modal-footer">
    <button class="btn-reset" onclick="resetFilters()">초기화</button>
    <button class="btn-search-black" onclick="applyFilters()">적용하기</button>
  </div>
</div>

<style>
  .filter-section { margin-bottom: 32px; padding-bottom: 24px; border-bottom: 1px solid #F1F3F5; }
  .filter-label { font-size: 16px; font-weight: 800; margin-bottom: 16px; color: var(--text-black); }
  
  .price-input {
    width: 100%; padding: 12px; border: 1px solid #E2E8F0; border-radius: 8px;
    font-size: 15px; font-weight: 700; text-align: right;
  }
  
  .amenity-grid { display: flex; flex-wrap: wrap; gap: 8px; }
  .amenity-chip {
    padding: 10px 16px; border: 1px solid #E2E8F0; border-radius: 20px;
    font-size: 14px; font-weight: 600; color: var(--text-gray); cursor: pointer;
    transition: all 0.2s; display: flex; align-items: center; gap: 6px;
  }
  .amenity-chip input { display: none; }
  .amenity-chip:has(input:checked) {
    border-color: var(--text-black); background: var(--text-black); color: white;
  }
</style>

<script>
  // 🌟 [수정] 전역(window) 변수로 만들어 list.jsp와 상태를 공유합니다!
  window.filterState = {
    minPrice: 0,
    maxPrice: 500000,
    accTypes: [],        
    accFacilities: [],   
    roomFacilities: []   
  };

  document.addEventListener("DOMContentLoaded", () => {
    const params = new URLSearchParams(window.location.search);

    if (params.has('minPrice')) window.filterState.minPrice = parseInt(params.get('minPrice'));
    if (params.has('maxPrice')) window.filterState.maxPrice = parseInt(params.get('maxPrice'));
    
    if (params.has('accTypes')) window.filterState.accTypes = params.get('accTypes').split(',');
    if (params.has('accFacilities')) window.filterState.accFacilities = params.get('accFacilities').split(',');
    if (params.has('roomFacilities')) window.filterState.roomFacilities = params.get('roomFacilities').split(',');

    syncFilterUI();
  });

  function syncFilterUI() {
    document.getElementById('input-min-price').value = window.filterState.minPrice;
    document.getElementById('input-max-price').value = window.filterState.maxPrice;
    updatePriceUI();

    document.querySelectorAll('#accTypeGrid input[type="checkbox"]').forEach(cb => {
      cb.checked = window.filterState.accTypes.includes(cb.value);
    });
    document.querySelectorAll('#accAmenityGrid input[type="checkbox"]').forEach(cb => {
      cb.checked = window.filterState.accFacilities.includes(cb.value);
    });
    document.querySelectorAll('#roomAmenityGrid input[type="checkbox"]').forEach(cb => {
      cb.checked = window.filterState.roomFacilities.includes(cb.value);
    });
  }

  function openFilterModal() {
    document.getElementById('filterOverlay').classList.add('open');
    document.getElementById('filterModal').classList.add('open');
    document.body.style.overflow = 'hidden';
  }

  function closeFilterModal() {
    document.getElementById('filterOverlay').classList.remove('open');
    document.getElementById('filterModal').classList.remove('open');
    document.body.style.overflow = '';
  }

  function updatePriceUI() {
    const minVal = document.getElementById('input-min-price').value;
    const maxVal = document.getElementById('input-max-price').value;

    document.getElementById('disp-min-price').innerText = Math.floor(minVal / 10000);
    document.getElementById('disp-max-price').innerText = Math.floor(maxVal / 10000);
    
    window.filterState.minPrice = minVal;
    window.filterState.maxPrice = maxVal;
  }

  function resetFilters() {
    window.filterState = { minPrice: 0, maxPrice: 500000, accTypes: [], accFacilities: [], roomFacilities: [] };
    syncFilterUI();
  }

  // 🌟 [핵심 수정] 여기서 직접 서버로 요청하지 않고, 값만 저장 후 list.jsp의 함수를 호출!
  function applyFilters() {
    window.filterState.accTypes = Array.from(document.querySelectorAll('#accTypeGrid input:checked')).map(cb => cb.value);
    window.filterState.accFacilities = Array.from(document.querySelectorAll('#accAmenityGrid input:checked')).map(cb => cb.value);
    window.filterState.roomFacilities = Array.from(document.querySelectorAll('#roomAmenityGrid input:checked')).map(cb => cb.value);

    closeFilterModal();

    // 🌟 list.jsp에 있는 메인 검색 함수를 "초기화 모드(true)"로 강력하게 호출!
    if (typeof fetchAccommodations === 'function') {
        fetchAccommodations(true);
    }
  }
</script>