<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<div id="tab-facility" class="page-section ${activeTab == 'facility' ? 'active' : ''}">
  <div class="page-header" style="display:flex; justify-content:space-between; align-items:flex-end;">
    <div>
      <h1>공통 시설 및 규정 관리</h1>
      <p>숙소의 공통 체크인/아웃 시간과 보유한 편의시설(Default)을 설정합니다.</p>
    </div>
    <button class="btn btn-primary" onclick="saveFacilityInfo()">설정 저장하기</button>
  </div>

  <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 24px;">
    <div class="card">
      <h2 style="font-size: 16px; font-weight: 800; margin-bottom: 20px;">🕒 숙소 운영 규정</h2>
      <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 16px; margin-bottom: 20px;">
        <div>
          <label class="form-label">체크인 시간</label>
          <input type="text" id="checkintime" class="form-control" value="${accommodation.checkinTime}" placeholder="예: 15:00">
        </div>
        <div>
          <label class="form-label">체크아웃 시간</label>
          <input type="text" id="checkouttime" class="form-control" value="${accommodation.checkoutTime}" placeholder="예: 11:00">
        </div>
      </div>
      <div>
        <label class="form-label">주차 시설 여부</label>
        <input type="text" id="parkinglodging" class="form-control" value="${accommodation.parkinglodging}" placeholder="예: 가능 (무료)">
      </div>
    </div>

    <div class="card">
      <h2 style="font-size: 16px; font-weight: 800; margin-bottom: 20px;">🏊 숙소 공통 시설</h2>
      <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 12px;" id="af-checkbox-group">
        <label style="display:flex; align-items:center; gap:8px; cursor:pointer;">
          <input type="checkbox" id="fitness" ${accommodation.fitness == 1 ? 'checked' : ''}> 🏋️ 헬스장
        </label>
        <label style="display:flex; align-items:center; gap:8px; cursor:pointer;">
          <input type="checkbox" id="chkcooking" ${accommodation.chkcooking == 1 ? 'checked' : ''}> 🍳 취사 가능
        </label>
        <label style="display:flex; align-items:center; gap:8px; cursor:pointer;">
          <input type="checkbox" id="barbecue" ${accommodation.barbecue == 1 ? 'checked' : ''}> 🍖 바베큐장
        </label>
        <label style="display:flex; align-items:center; gap:8px; cursor:pointer;">
          <input type="checkbox" id="sauna" ${accommodation.sauna == 1 ? 'checked' : ''}> ♨️ 사우나
        </label>
        <label style="display:flex; align-items:center; gap:8px; cursor:pointer;">
          <input type="checkbox" id="karaoke" ${accommodation.karaoke == 1 ? 'checked' : ''}> 🎤 노래방
        </label>
        <label style="display:flex; align-items:center; gap:8px; cursor:pointer;">
          <input type="checkbox" id="publicpc" ${accommodation.publicpc == 1 ? 'checked' : ''}> 💻 공용 PC
        </label>
      </div>
    </div>
  </div>
</div>