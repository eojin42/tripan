<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt"%>

<div class="modal-overlay" id="filterOverlay" onclick="closeFilterModal()"></div>
<div class="custom-modal" id="filterModal">
  <div class="c-modal-header">
    <div class="c-modal-title">필터</div>
    <button class="btn-close-modal" onclick="closeFilterModal()">✕</button>
  </div>

  <div class="c-modal-body">
    <div class="filter-section">
      <h4 class="filter-label">요금 범위 (1박 기준)</h4>
      <p style="text-align:center; font-weight:800; font-size:18px; margin-bottom:16px;">0만원 ~ 50만원+</p>
      <div style="display:flex; gap:12px; align-items:center;">
        <input type="number" class="price-input" placeholder="최소 0" value="0">
        <span>-</span>
        <input type="number" class="price-input" placeholder="최대 100" value="500000">
      </div>
    </div>

    <div class="filter-section">
      <h4 class="filter-label">객실 구성</h4>
      <div class="guest-row" style="padding:10px 0;">
        <div class="guest-info"><h4>침실</h4></div>
        <div class="counter-box">
          <div class="btn-count">-</div>
          <span class="count-val">0</span>
          <div class="btn-count">+</div>
        </div>
      </div>
      <div class="guest-row" style="padding:10px 0;">
        <div class="guest-info"><h4>욕실</h4></div>
        <div class="counter-box">
          <div class="btn-count">-</div>
          <span class="count-val">0</span>
          <div class="btn-count">+</div>
        </div>
      </div>
    </div>

    <div class="filter-section">
      <h4 class="filter-label">편의시설</h4>
      <div class="amenity-grid">
        <label class="amenity-chip"><input type="checkbox"> 📶 와이파이</label>
        <label class="amenity-chip"><input type="checkbox"> 🍳 조식</label>
        <label class="amenity-chip"><input type="checkbox"> 🏊‍♀️ 수영장</label>
        <label class="amenity-chip"><input type="checkbox"> 💪 피트니스</label>
        <label class="amenity-chip"><input type="checkbox"> 🛁 스파/마사지</label>
        <label class="amenity-chip"><input type="checkbox"> 🍖 바베큐</label>
        <label class="amenity-chip"><input type="checkbox"> 🅿️ 주차 가능</label>
        <label class="amenity-chip"><input type="checkbox"> 🐶 반려동물</label>
      </div>
    </div>
  </div>

  <div class="c-modal-footer">
    <button class="btn-reset">초기화</button>
    <button class="btn-search-black" onclick="closeFilterModal()">적용하기</button>
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
  /* 체크박스 선택 시 스타일 */
  .amenity-chip:has(input:checked) {
    border-color: var(--text-black); background: var(--text-black); color: white;
  }
</style>

<script>
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
</script>