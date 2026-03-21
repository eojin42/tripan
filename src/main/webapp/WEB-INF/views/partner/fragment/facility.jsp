<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<div id="tab-facility" class="page-section ${activeTab == 'facility' ? 'active' : ''}">
    <div class="page-header" style="display:flex; justify-content:space-between; align-items:flex-end; margin-bottom: 28px;">
        <div>
            <h1 style="font-size: 26px; font-weight: 900; color: var(--text-black); letter-spacing: -0.5px;">✨ 공통 시설 및 규정 관리</h1>
            <p style="color: var(--text-gray); margin-top: 8px; font-weight: 500;">우리 숙소의 운영 정책과 빵빵한 편의시설을 매력적으로 설정해 보세요!</p>
        </div>
        <button type="button" onclick="saveFacilityInfo()" class="btn-save-cute">
            💾 변경사항 저장
        </button>
    </div>

    <input type="hidden" id="placeId" value="${accommodation.placeId}">

    <div class="cute-card" style="margin-bottom: 24px;">
        <div style="display: flex; justify-content: space-between; align-items: center;">
            <div>
                <h2 style="font-size: 17px; font-weight: 800; margin-bottom: 6px; color: var(--text-black);">📢 숙소 노출 상태</h2>
                <p style="font-size: 13px; color: var(--text-gray); margin: 0; font-weight: 500;">비활성화 시 앱/웹 검색 결과에서 우리 숙소가 숨겨집니다 🙈</p>
            </div>
            
            <div style="display: flex; align-items: center; gap: 12px;">
                <span id="activeStatusText" style="font-size: 14px; font-weight: 800; color: ${accommodation.isActive == 1 ? '#4A44F2' : '#A0AEC0'};">
                    ${accommodation.isActive == 1 ? '온라인 (노출 중) 🟢' : '오프라인 (숨김) ⚪'}
                </span>
                <label class="toggle-switch">
                    <input type="checkbox" id="isActive" onchange="updateToggleUI()" ${accommodation.isActive == 1 ? 'checked' : ''}>
                    <span class="slider round"></span>
                </label>
            </div>
        </div>
    </div>

    <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 24px;">
        
        <div class="cute-card">
            <h2 style="font-size: 17px; font-weight: 800; margin-bottom: 20px; color: var(--text-black);">🕒 숙소 운영 규정</h2>
            <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 16px; margin-bottom: 20px;">
                <div>
                    <label style="font-size: 14px; font-weight: 700; color: var(--text-dark);">체크인 시간 🌞</label>
                    <input type="time" id="checkinTime" value="${accommodation.checkinTime}" class="cute-input">
                </div>
                <div>
                    <label style="font-size: 14px; font-weight: 700; color: var(--text-dark);">체크아웃 시간 🌛</label>
                    <input type="time" id="checkoutTime" value="${accommodation.checkoutTime}" class="cute-input">
                </div>
            </div>
            <div>
                <label style="font-size: 14px; font-weight: 700; color: var(--text-dark);">주차 시설 안내 🚗</label>
                <input type="text" id="parkinglodging" value="${accommodation.parkinglodging}" placeholder="예: 객실당 1대 무료 주차 가능, 발렛 1만원" class="cute-input">
            </div>
        </div>

        <div class="cute-card">
            <h2 style="font-size: 17px; font-weight: 800; margin-bottom: 20px; color: var(--text-black);">🏊 숙소 공통 편의시설</h2>
            <p style="font-size: 13px; color: var(--text-gray); margin-bottom: 16px; font-weight: 500;">기본으로 제공하는 시설을 모두 콕콕 찝어주세요!</p>
            
            <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 12px;">
                <label class="fac-label">
                    <input type="checkbox" id="fitness" value="1" ${accommodation.fitness == 1 ? 'checked' : ''}> <span class="fac-text">🏋️ 체력단련장</span>
                </label>
                <label class="fac-label">
                    <input type="checkbox" id="chkcooking" value="1" ${accommodation.chkcooking == 1 ? 'checked' : ''}> <span class="fac-text">🍳 취사 가능</span>
                </label>
                <label class="fac-label">
                    <input type="checkbox" id="barbecue" value="1" ${accommodation.barbecue == 1 ? 'checked' : ''}> <span class="fac-text">🍖 바비큐</span>
                </label>
                <label class="fac-label">
                    <input type="checkbox" id="beverage" value="1" ${accommodation.beverage == 1 ? 'checked' : ''}> <span class="fac-text">☕ 식음료/조식</span>
                </label>
                <label class="fac-label">
                    <input type="checkbox" id="karaoke" value="1" ${accommodation.karaoke == 1 ? 'checked' : ''}> <span class="fac-text">🎤 노래방</span>
                </label>
                <label class="fac-label">
                    <input type="checkbox" id="publicpc" value="1" ${accommodation.publicpc == 1 ? 'checked' : ''}> <span class="fac-text">💻 공용 PC</span>
                </label>
                <label class="fac-label">
                    <input type="checkbox" id="sauna" value="1" ${accommodation.sauna == 1 ? 'checked' : ''}> <span class="fac-text">♨️ 사우나</span>
                </label>

                <div></div>

				<div style="grid-column: 1 / -1; display: flex; align-items: center; gap: 12px; margin-top: 4px; padding-top: 12px; border-top: 1px dashed #E2E8F0;">
                    <label class="fac-label" style="flex-shrink: 0; background: none; padding: 0;">
                        <input type="checkbox" id="hasOtherFacility" onchange="toggleOtherInput()" ${not empty accommodation.otherFacility ? 'checked' : ''}> <span class="fac-text">➕ 기타 시설</span>
                    </label>
                    
                    <input type="text" id="otherFacilityName" class="cute-input" 
                           value="${accommodation.otherFacility}" 
                           placeholder="부대시설을 적어주세요! (예: 루프탑 펍)" 
                           style="flex: 1; margin-top: 0; display: ${not empty accommodation.otherFacility ? 'block' : 'none'};">
                </div>
            </div>
        </div>
    </div>
</div>

<style>
  /* 🌟 감성 파스텔 큐트 CSS */
  .cute-card {
      background: white; padding: 28px; border-radius: 20px; 
      border: 1px solid #EDF2F7; 
      box-shadow: 0 4px 15px rgba(226, 232, 240, 0.4);
      transition: transform 0.3s ease, box-shadow 0.3s ease;
  }
  .cute-card:hover {
      transform: translateY(-4px);
      box-shadow: 0 10px 25px rgba(226, 232, 240, 0.8);
      border-color: #E2E8F0;
  }

  .cute-input {
      width: 100%; padding: 12px 16px; border-radius: 12px; 
      border: 1px solid #E2E8F0; margin-top: 8px;
      font-family: inherit; font-size: 14px;
      background: #F8FAFC; transition: 0.2s; outline: none;
  }
  .cute-input:focus {
      background: white; border-color: #4A44F2; box-shadow: 0 0 0 3px rgba(74, 68, 242, 0.1);
  }

  .btn-save-cute {
      background-color: #1A202C; color: white; padding: 12px 28px; 
      border-radius: 14px; border: none; font-size: 15px; font-weight: 800; 
      cursor: pointer; transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1); 
      box-shadow: 0 4px 12px rgba(26, 32, 44, 0.2);
  }
  .btn-save-cute:hover {
      background-color: #4A44F2; transform: scale(1.03); box-shadow: 0 6px 16px rgba(74, 68, 242, 0.3);
  }

  .fac-label {
      display: flex; align-items: center; gap: 8px; cursor: pointer;
      padding: 10px 14px; background: #F8FAFC; border-radius: 12px;
      transition: background 0.2s, transform 0.1s;
  }
  .fac-label:hover { background: #EDF2F7; transform: scale(1.02); }
  .fac-label input[type="checkbox"] { width: 16px; height: 16px; accent-color: #4A44F2; cursor: pointer; }
  .fac-text { font-size: 14px; font-weight: 600; color: #2D3748; }

  /* 🌟 토글 스위치 (파란색 포인트) */
  .toggle-switch { position: relative; display: inline-block; width: 54px; height: 30px; }
  .toggle-switch input { opacity: 0; width: 0; height: 0; }
  .slider { position: absolute; cursor: pointer; top: 0; left: 0; right: 0; bottom: 0; background-color: #E2E8F0; transition: .4s; }
  .slider.round { border-radius: 34px; }
  .slider.round:before { border-radius: 50%; }
  .slider:before { position: absolute; content: ""; height: 22px; width: 22px; left: 4px; bottom: 4px; background-color: white; transition: .4s; box-shadow: 0 2px 4px rgba(0,0,0,0.2); }
  
  .toggle-switch input:checked + .slider { background-color: #4A44F2; } /* 활성 시 파란색 */
  .toggle-switch input:focus + .slider { box-shadow: 0 0 1px #4A44F2; }
  .toggle-switch input:checked + .slider:before { transform: translateX(24px); }
</style>