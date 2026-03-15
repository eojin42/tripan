<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt"%>

<style>
  .modal-overlay {
    position: fixed; top: 0; left: 0; width: 100%; height: 100%;
    background: rgba(0,0,0,0.6); z-index: 9990;
    opacity: 0; visibility: hidden; transition: all 0.3s;
    backdrop-filter: blur(2px);
  }
  .modal-overlay.open { opacity: 1; visibility: visible; }

  .custom-modal {
    position: fixed; bottom: 0; left: 50%;
    width: 100%; max-width: 800px; height: 90vh;
    background: white; border-top-left-radius: 24px; border-top-right-radius: 24px;
    z-index: 9999;
    transform: translateX(-50%) translateY(100%); 
    transition: transform 0.4s cubic-bezier(0.16, 1, 0.3, 1);
    display: flex; flex-direction: column;
    box-shadow: 0 -10px 40px rgba(0,0,0,0.2);
  }
  .custom-modal.open { transform: translateX(-50%) translateY(0); }

  .c-modal-header { padding: 20px 24px 10px; text-align: center; position: relative; flex-shrink: 0; }
  .c-modal-title { font-size: 18px; font-weight: 800; color: var(--text-black); }
  .btn-close-modal { 
    position: absolute; right: 20px; top: 20px; 
    font-size: 24px; cursor: pointer; background: none; border: none; padding: 4px; 
    color: var(--text-black);
  }

  .c-search-area { padding: 0 24px 20px; flex-shrink: 0; border-bottom: 1px solid #F1F3F5; }
  
  .search-row {
    display: flex; align-items: center; gap: 12px;
    padding: 12px 4px; border-bottom: 1px solid #E2E8F0; cursor: pointer; transition: border 0.2s;
  }
  .search-row.active { border-bottom: 2px solid var(--text-black); }
  
  .chip-container {
    flex: 1; display: flex; gap: 8px; overflow-x: auto; flex-wrap: nowrap;
    align-items: center; height: 42px; padding-bottom: 4px;
  }
  .chip-container::-webkit-scrollbar { height: 4px; }
  .chip-container::-webkit-scrollbar-thumb { background: #CBD5E0; border-radius: 4px; }
  .chip-container::-webkit-scrollbar-track { background: transparent; }
  
  .search-chip {
    background: #F1F3F5; padding: 8px 14px; border-radius: 20px;
    font-size: 14px; font-weight: 700; color: var(--text-black);
    display: flex; align-items: center; gap: 8px; white-space: nowrap; flex-shrink: 0;
  }
  .btn-chip-close {
    cursor: pointer; color: #A0AEC0; font-size: 16px; display: flex; align-items: center; justify-content: center;
    width: 20px; height: 20px; border-radius: 50%;
  }
  .btn-chip-close:hover { background: rgba(0,0,0,0.1); color: #E53E3E; }
  .placeholder-text { color: #A0AEC0; font-weight: 600; font-size: 16px; }

  .filter-row { display: flex; justify-content: space-between; margin-top: 12px; }
  .filter-tab {
    display: flex; align-items: center; gap: 8px; padding: 8px 4px;
    font-size: 15px; font-weight: 600; color: var(--text-dark); cursor: pointer; flex: 1;
  }
  .filter-tab:hover { color: var(--point-blue); }
  .filter-tab.active { color: var(--point-blue); font-weight: 800; }

  .c-modal-body { flex: 1; overflow-y: auto; padding: 24px; scrollbar-width: thin; position: relative; }
  
  .view-section { display: none; animation: fadeIn 0.3s ease-out; }
  .view-section.active { display: block; }
  @keyframes fadeIn { from { opacity: 0; transform: translateY(5px); } to { opacity: 1; transform: translateY(0); } }

  .section-title { font-size: 15px; font-weight: 800; color: var(--text-gray); margin-bottom: 12px; display: block; }
  .region-grid { display: grid; grid-template-columns: repeat(5, 1fr); gap: 10px; margin-bottom: 32px; }
  .region-btn {
    display: flex; justify-content: center; align-items: center; height: 46px; border-radius: 12px;
    background: #F5F7FA; font-size: 14px; font-weight: 600; color: var(--text-dark);
    cursor: pointer; transition: all 0.2s; text-align: center; line-height: 1.2; padding: 0 4px;
  }
  .region-btn:hover { background: #E9ECEF; }
  .region-btn.selected { background: var(--text-black); color: white; box-shadow: 0 4px 10px rgba(0,0,0,0.15); }
  #subRegionContainer { display: none; background: #FAFAFA; margin: 0 -24px 24px; padding: 20px 24px; border-bottom: 1px solid #EEEEEE; }

  .calendar-container { text-align: center; padding-bottom: 40px; }
  .month-block { margin-bottom: 40px; }
  .month-title { font-size: 18px; font-weight: 900; margin-bottom: 20px; text-align: center; color: var(--text-black); }
  
  .calendar-grid { display: grid; grid-template-columns: repeat(7, 1fr); row-gap: 12px; }
  .day-header { font-size: 14px; color: var(--text-gray); font-weight: 600; padding-bottom: 8px; }
  .day-header.sun { color: #E53E3E; }
  .day-header.sat { color: var(--point-blue); }
  
  .day-cell {
    aspect-ratio: 1/1; display: flex; justify-content: center; align-items: center;
    font-size: 15px; font-weight: 600; cursor: pointer; position: relative;
    border-radius: 50%; z-index: 1;
  }
  .day-cell:not(.empty):hover { background: #F7FAFC; font-weight: 800; }
  .day-cell.empty { cursor: default; }
  
  .day-cell.selected { 
    background: var(--point-blue); color: white; border-radius: 50%; 
    box-shadow: 0 4px 10px rgba(137, 207, 240, 0.4);
  }
  .day-cell.range { background: var(--bg-beige); color: var(--text-black); border-radius: 0; }
  
  .day-cell.range-start { background: var(--point-blue); color: white; border-radius: 50%; position: relative; }
  .day-cell.range-start::before { content: ''; position: absolute; z-index: -1; top: 0; right: 0; bottom: 0; left: 50%; background: var(--bg-beige); }
  .day-cell.range-end { background: var(--point-blue); color: white; border-radius: 50%; position: relative; }
  .day-cell.range-end::before { content: ''; position: absolute; z-index: -1; top: 0; right: 50%; bottom: 0; left: 0; background: var(--bg-beige); }

  .guest-row { display: flex; justify-content: space-between; align-items: center; padding: 20px 0; border-bottom: 1px solid #F1F3F5; }
  .guest-info h4 { font-size: 16px; font-weight: 800; margin-bottom: 4px; color: var(--text-black); }
  .guest-info p { font-size: 13px; color: var(--text-gray); }
  .counter-box { display: flex; align-items: center; gap: 16px; }
  .btn-count {
    width: 32px; height: 32px; border-radius: 50%; border: 1px solid #E2E8F0; background: white;
    display: flex; justify-content: center; align-items: center; font-size: 18px; color: var(--text-gray); cursor: pointer; transition: all 0.2s;
  }
  .btn-count:hover { border-color: var(--point-blue); color: var(--point-blue); }
  .btn-count.active { border-color: var(--text-black); color: var(--text-black); font-weight: 700; }
  .count-val { font-size: 18px; font-weight: 800; width: 20px; text-align: center; }

  .c-modal-footer { padding: 16px 24px 32px; border-top: 1px solid #F1F3F5; display: flex; justify-content: space-between; align-items: center; background: white; flex-shrink: 0; }
  .btn-reset { font-size: 14px; font-weight: 600; color: var(--text-gray); background: none; text-decoration: underline; cursor: pointer; border: none; }
  .btn-search-black { background: var(--text-black); color: white; padding: 14px 40px; border-radius: 100px; border: none; font-size: 15px; font-weight: 800; cursor: pointer; transition: background 0.3s; }
  .btn-search-black:hover { background: var(--point-blue); }

  @media (max-width: 768px) {
    .custom-modal { max-width: 100%; height: 95vh; border-radius: 20px 20px 0 0; }
    .region-grid { grid-template-columns: repeat(4, 1fr); }
  }
</style>

<div class="modal-overlay" id="modalOverlay" onclick="closeModal()"></div>
<div class="custom-modal" id="customModal">
  <div class="c-modal-header">
    <div class="c-modal-title">어디로 떠날까요?</div>
    <button class="btn-close-modal" onclick="closeModal()">✕</button>
  </div>

  <div class="c-search-area">
    <c:if test="${param.hideRegion != 'true'}">
        <div class="search-row active" id="headerRegion" onclick="switchView('region')">
          <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#718096" stroke-width="2"><circle cx="11" cy="11" r="8"></circle><line x1="21" y1="21" x2="16.65" y2="16.65"></line></svg>
          <div class="chip-container" id="chipContainer">
            <span class="placeholder-text" id="regionPlaceholder">여행지 검색 (예: 제주, 강릉)</span>
          </div>
          <div style="color:#CBD5E0; cursor: pointer; margin-left:8px;" onclick="clearRegions(event)">✕</div>
        </div>
    </c:if>

    <div class="filter-row">
      <div class="filter-tab" id="headerDate" onclick="switchView('date')">
        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
        <span id="dateText">일정</span>
      </div>
      <div class="filter-tab" id="headerGuest" onclick="switchView('guest')">
        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
        <span id="guestText">인원</span>
      </div>
    </div>
  </div>
    
  <div class="c-modal-body">
    <c:if test="${param.hideRegion != 'true'}">
        <div id="viewRegion" class="view-section active">
          <div id="subRegionContainer">
            <span class="section-title" id="subRegionTitle" style="color: var(--point-blue);">상세 지역</span>
            <div class="region-grid" id="subRegionGrid"></div>
          </div>
          <span class="section-title">주요 도시</span>
          <div class="region-grid" id="majorRegionGrid">
            <div class="region-btn" id="btn-nationwide" onclick="selectNationwide()">전국</div>
	        <div class="region-btn" onclick="showSubRegions('서울')">서울</div>
	        <div class="region-btn" onclick="showSubRegions('제주')">제주</div>
	        <div class="region-btn" onclick="showSubRegions('부산')">부산</div>
	        <div class="region-btn" onclick="showSubRegions('강원')">강원</div>
	        <div class="region-btn" onclick="showSubRegions('경기')">경기</div>
	        <div class="region-btn" onclick="showSubRegions('인천')">인천</div>
	        <div class="region-btn" onclick="showSubRegions('경상')">경상</div>
	        <div class="region-btn" onclick="showSubRegions('전라')">전라</div>
	        <div class="region-btn" onclick="showSubRegions('충청')">충청</div>
	        </div>
        </div>
    </c:if>

    <div id="viewDate" class="view-section">
      <div class="calendar-container" id="calendarContainer"></div>
    </div>

    <div id="viewGuest" class="view-section">
      <div class="guest-row">
        <div class="guest-info"><h4>성인</h4><p>만 13세 이상</p></div>
        <div class="counter-box">
          <div class="btn-count" onclick="updateGuest('adult', -1)">-</div>
          <span class="count-val" id="cnt-adult">0</span>
          <div class="btn-count" onclick="updateGuest('adult', 1)">+</div>
        </div>
      </div>
      <div class="guest-row">
        <div class="guest-info"><h4>아동</h4><p>12세 이하</p></div>
        <div class="counter-box">
          <div class="btn-count" onclick="updateGuest('child', -1)">-</div>
          <span class="count-val" id="cnt-child">0</span>
          <div class="btn-count" onclick="updateGuest('child', 1)">+</div>
        </div>
      </div>
    </div>
  </div>

  <div class="c-modal-footer">
    <button class="btn-reset" onclick="resetAll()">초기화</button>
    <button class="btn-search-black" onclick="submitSearch()">검색</button>
  </div>
</div>

<script>
  // --- 유틸리티 ---
  const getDisplayDate = dateStr => {
    const [y, m, d] = dateStr.split('-');
    return `\${m}.\${d}`;
  };

  // --- 상태 관리 변수 ---
  let selectedRegions = []; 
  let selectedDates = []; 
  let guests = { adult: 0, child: 0 }; 
  let currentMajorRegion = null; 

  // --- 데이터 정의 ---
  const subRegionData = {
    '서울': ['서울 전체', '강남/역삼/삼성', '신촌/홍대/합정', '명동/을지로/종로', '잠실/송파/강동', '영등포/여의도', '이태원/용산/서울역', '동대문/청량리/성북', '구로/신도림/금천', '강서/마포/김포공항', '건대/성수/왕십리', '서초/교대/방배', '강북/노원/도봉', '관악/동작/사당'],
    '경기': ['경기 전체', '가평/청평/대성리', '양평/용문', '수원/인계/화성', '용인/에버랜드', '파주/헤이리', '고양/일산', '대부도/제부도', '포천/산정호수', '의정부/동두천/양주', '남양주/구리', '안산/시흥', '성남/분당/판교', '인천공항 인근', '부천'],
    '제주': ['제주 전체', '제주시/공항인근', '서귀포시/중문', '애월/협재/한림', '성산/우도', '표선/남원', '함덕/구좌/김녕', '한라산/성판악'],
    '강원': ['강원 전체', '강릉/주문진', '속초/설악', '양양/낙산', '춘천/강촌', '평창/용평', '정선/하이원', '홍천/비발디', '원주/오크밸리', '고성/간성', '동해/삼척', '철원/화천', '횡성', '영월'],
    '부산': ['부산 전체', '해운대/재송', '광안리/수영', '서면/진구', '남포동/자갈치', '부산역/초량', '송정/기장/정관', '영도/태종대', '동래/온천장', '김해공항/강서'],
    '인천': ['인천 전체', '송도/연수/소래포구', '월미도/차이나타운', '영종도/을왕리', '강화도', '부평', '구월/간석', '계양/서구'],
    '경상': ['경상 전체', '경주', '거제', '통영', '남해', '포항', '안동', '울산', '창원', '김해', '구미', '문경', '울진/영덕'],
    '전라': ['전라 전체', '전주/한옥마을', '여수', '순천', '군산', '목포', '광주', '담양', '부안/변산', '남원'],
    '충청': ['충청 전체', '대전', '천안/아산', '보령/대천', '태안/안면도', '청주', '제천/단양', '공주/부여/서산', '충주']
  };

  // ✅ [FIX] 페이지 로드 시 URL 파라미터를 읽어와 상태를 동기화
  document.addEventListener("DOMContentLoaded", () => {
    const params = new URLSearchParams(window.location.search);
    
    // 1. 지역 상태 복원
    const regionParam = params.get('regions');
    if (regionParam) {
      selectedRegions = decodeURIComponent(regionParam).split(',');
      renderChips(); // 칩 UI 갱신
      refreshGridHighlight(); // 그리드 선택 상태 갱신
    }

    // 2. 일정 상태 복원
    const checkin = params.get('checkin');
    const checkout = params.get('checkout');
    if (checkin && checkout) {
      selectedDates = [checkin, checkout];
      // 달력 UI는 openModal()에서 갱신됨
    }

    // 3. 인원 상태 복원
    const adult = parseInt(params.get('adult')) || 1;
    const child = parseInt(params.get('child')) || 0;
    guests.adult = adult;
    guests.child = child;
    
    // 인원 카운터 UI 즉시 반영
    if(document.getElementById('cnt-adult')) {
      document.getElementById('cnt-adult').innerText = adult;
      document.getElementById('cnt-child').innerText = child;
      updateGuestBtnState('adult', adult);
      updateGuestBtnState('child', child);
    }

    // 상단 탭 텍스트 갱신
    updateHeaderText();
  });

  // 버튼 활성/비활성 헬퍼 함수
  function updateGuestBtnState(type, val) {
      const el = document.getElementById(`cnt-\${type}`);
      if(!el) return;
      const btnBox = el.parentNode;
      const minusBtn = btnBox.querySelector('.btn-count:first-child');
      if (val > 0) minusBtn.classList.add('active');
      else minusBtn.classList.remove('active');
  }

  // --- 모달 제어 ---
  function openModal(viewType) {
    document.getElementById('modalOverlay').classList.add('open');
    document.getElementById('customModal').classList.add('open');
    document.body.style.overflow = 'hidden';
    
    // 달력 렌더링 (없으면 생성)
    if(document.getElementById('calendarContainer').innerHTML.trim() === "") {
      renderCalendar();
    }
    
    updateCalendarUI();
    
    let targetView = viewType || 'region';
    <c:if test="${param.hideRegion == 'true'}">
        if (targetView === 'region') {
            targetView = 'date';
        }
    </c:if>
    
    switchView(targetView);
  }

  function closeModal() {
    document.getElementById('modalOverlay').classList.remove('open');
    document.getElementById('customModal').classList.remove('open');
    document.body.style.overflow = '';
  }

  function switchView(viewName) {
    const headerRegion = document.getElementById('headerRegion');
    const viewRegion = document.getElementById('viewRegion');

    if(headerRegion) headerRegion.classList.remove('active'); // null 체크
    document.getElementById('headerDate').classList.remove('active');
    document.getElementById('headerGuest').classList.remove('active');

    if(viewName === 'region' && headerRegion) headerRegion.classList.add('active');
    else if(viewName === 'date') document.getElementById('headerDate').classList.add('active');
    else if(viewName === 'guest') document.getElementById('headerGuest').classList.add('active');

    document.querySelectorAll('.view-section').forEach(el => el.classList.remove('active'));
    
    if(viewName === 'region' && viewRegion) viewRegion.classList.add('active');
    else if(viewName === 'date') document.getElementById('viewDate').classList.add('active');
    else if(viewName === 'guest') document.getElementById('viewGuest').classList.add('active');
  }

  // --- [로직 1] 지역 ---
  function selectNationwide() {
    selectedRegions = ['전국']; 
    renderChips();
    document.getElementById('subRegionContainer').style.display = 'none'; 
    refreshGridHighlight();
  }

  function showSubRegions(major) {
    currentMajorRegion = major;
    const container = document.getElementById('subRegionContainer');
    const grid = document.getElementById('subRegionGrid');
    const title = document.getElementById('subRegionTitle');
    
    grid.innerHTML = '';
    title.innerText = major + ' 상세 지역';
    
    if (subRegionData[major]) {
      subRegionData[major].forEach(sub => {
        const btn = document.createElement('div');
        btn.className = 'region-btn';
        btn.innerText = sub;
        if(selectedRegions.includes(sub)) btn.classList.add('selected');
        btn.onclick = () => toggleRegion(sub, major);
        grid.appendChild(btn);
      });
      container.style.display = 'block';
      container.scrollIntoView({ behavior: 'smooth', block: 'start' });
    }
    refreshGridHighlight(); 
  }

  function toggleRegion(name, majorContext) {
    // 1. 이미 선택된 지역을 다시 누르면? -> 선택 해제 (빈 값)
    if (selectedRegions.includes(name)) {
      selectedRegions = []; 
    } else {
      // 2. 아니면? -> 기존 것 다 버리고 이걸로 교체 (단일 선택)
      selectedRegions = [name];
    }
    
    renderChips();
    refreshGridHighlight();
  }

  function refreshGridHighlight() {
    const subBtns = document.querySelectorAll('#subRegionGrid .region-btn');
    subBtns.forEach(btn => {
      if(selectedRegions.includes(btn.innerText)) btn.classList.add('selected');
      else btn.classList.remove('selected');
    });
    const btnNation = document.getElementById('btn-nationwide');
    if (selectedRegions.includes('전국')) btnNation.classList.add('selected');
    else btnNation.classList.remove('selected');
  }

  function renderChips() {
    const container = document.getElementById('chipContainer');
    const placeholder = document.getElementById('regionPlaceholder');
    Array.from(container.children).forEach(child => {
      if (!child.classList.contains('placeholder-text')) container.removeChild(child);
    });

    if (selectedRegions.length > 0) {
      placeholder.style.display = 'none';
      selectedRegions.forEach(region => {
        const chip = document.createElement('div');
        chip.className = 'search-chip';
        chip.innerHTML = `\${region} <div class="btn-chip-close" onclick="removeRegion('\${region}', event)">✕</div>`;
        container.appendChild(chip);
      });
    } else {
      placeholder.style.display = 'block';
    }
  }

  function removeRegion(name, e) {
    if(e) { e.preventDefault(); e.stopPropagation(); }
    const index = selectedRegions.indexOf(name);
    if (index > -1) selectedRegions.splice(index, 1);
    renderChips();
    refreshGridHighlight();
  }

  function clearRegions(e) {
    if(e) { e.preventDefault(); e.stopPropagation(); }
    selectedRegions = [];
    renderChips();
    document.getElementById('subRegionContainer').style.display = 'none';
    refreshGridHighlight();
  }

  // --- [로직 2] 달력 ---
  function renderCalendar() {
    const container = document.getElementById('calendarContainer');
    const now = new Date();
    
    const today = new Date();
    const tYear = today.getFullYear();
    const tMonth = String(today.getMonth() + 1).padStart(2, '0');
    const tDate = String(today.getDate()).padStart(2, '0');
    const todayStr = `\${tYear}-\${tMonth}-\${tDate}`; 

    let html = '';
    
    for (let i = 0; i <= 12; i++) {
      let currentMonth = new Date(now.getFullYear(), now.getMonth() + i, 1);
      let year = currentMonth.getFullYear();
      let month = currentMonth.getMonth();
      
      html += `<div class="month-block">
                 <div class="month-title">\${year}년 \${month + 1}월</div>
                 <div class="calendar-grid">
                   <div class="day-header sun">일</div><div class="day-header">월</div><div class="day-header">화</div>
                   <div class="day-header">수</div><div class="day-header">목</div><div class="day-header">금</div><div class="day-header sat">토</div>`;
      
      let firstDay = new Date(year, month, 1).getDay();
      for(let j=0; j<firstDay; j++) html += `<div class="day-cell empty"></div>`;
      
      let daysInMonth = new Date(year, month + 1, 0).getDate();
      for(let d=1; d<=daysInMonth; d++) {
         let mStr = String(month+1).padStart(2,'0');
         let dStr = String(d).padStart(2,'0');
         let dateStr = `\${year}-\${mStr}-\${dStr}`;
         
         // 예약 마감된 날짜인지 확인 (detail에서만 동작)
         let isBooked = window.disabledDates && window.disabledDates.includes(dateStr);

         if (dateStr < todayStr) {
             html += `<div class="day-cell disabled" style="color:#CBD5E0; cursor:not-allowed;">\${d}</div>`;
         } else if (isBooked) {
             // 예약 마감 날짜 디자인 (취소선)
             html += `<div class="day-cell disabled" style="color:#A0AEC0; background:#F7FAFC; cursor:not-allowed; text-decoration:line-through;" title="예약 마감">\${d}</div>`;
         } else {
             html += `<div class="day-cell" data-date="\${dateStr}" onclick="selectDate(this)">\${d}</div>`;
         }
       }
      html += `</div></div>`;
    }
    container.innerHTML = html;
  }

  function selectDate(el) {
    const date = el.dataset.date;
    if (selectedDates.length === 2) selectedDates = []; 
    
    if (selectedDates.length === 0) {
        selectedDates.push(date);
    } else {
        const start = selectedDates[0] < date ? selectedDates[0] : date;
        const end = selectedDates[0] < date ? date : selectedDates[0];

        // 체크인 ~ 체크아웃 사이에 예약 마감된 날짜가 껴있는지 검사
        let hasBookedInBetween = false;
        if (window.disabledDates) {
            for (let d of window.disabledDates) {
                if (d >= start && d < end) {
                    hasBookedInBetween = true;
                    break;
                }
            }
        }

        if (hasBookedInBetween) {
            alert("선택하신 기간 내에 예약이 마감된 날짜가 포함되어 있습니다.");
            selectedDates = [date]; // 방금 클릭한 날짜로 초기화
        } else {
            selectedDates = [start, end];
        }
    }
    
    updateCalendarUI();
    updateHeaderText();
  }

  function updateCalendarUI() {
    document.querySelectorAll('.day-cell').forEach(el => {
      el.className = 'day-cell'; 
      if(el.classList.contains('empty')) el.classList.add('empty');

      const d = el.dataset.date;
      if (!d) return;

      if(selectedDates.includes(d)) el.classList.add('selected');
      
      if(selectedDates.length === 2) {
        if(d > selectedDates[0] && d < selectedDates[1]) el.classList.add('range');
        if(d === selectedDates[0]) el.classList.add('range-start');
        if(d === selectedDates[1]) el.classList.add('range-end');
      }
    });
  }

  // --- [로직 3] 인원 ---
  function updateGuest(type, delta) {
    let newVal = guests[type] + delta;
    if (newVal < 0) return;
    
    guests[type] = newVal;
    document.getElementById(`cnt-\${type}`).innerText = newVal;
    updateGuestBtnState(type, newVal); // 버튼 상태 갱신

    updateHeaderText();
  }

	//--- [JS 수정] 모달 헤더 텍스트 갱신 함수 (박수 계산 포함) ---
  function updateHeaderText() {
    const dateText = document.getElementById('dateText');
    
    if (selectedDates.length === 2) {
      // 날짜 객체로 변환하여 차이 계산
      const d1 = new Date(selectedDates[0]);
      const d2 = new Date(selectedDates[1]);
      const diffTime = Math.abs(d2 - d1);
      const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24)); 
      
      // "2박 M.D ~ M.D" 형식으로 표시
      dateText.innerText = `\${diffDays}박 \${getDisplayDate(selectedDates[0])} ~ \${getDisplayDate(selectedDates[1])}`;
      dateText.style.color = "var(--text-black)";
      dateText.style.fontWeight = "800";
    } else if (selectedDates.length === 1) {
      dateText.innerText = `\${getDisplayDate(selectedDates[0])} ~`;
    } else {
      dateText.innerText = "일정";
      dateText.style.color = "var(--text-dark)";
      dateText.style.fontWeight = "600";
    }

    const guestText = document.getElementById('guestText');
    const total = guests.adult + guests.child;
    if (total > 0) {
      guestText.innerText = `\${total}명`;
      guestText.style.color = "var(--text-black)";
      guestText.style.fontWeight = "800";
    } else {
      guestText.innerText = "인원";
      guestText.style.color = "var(--text-dark)";
      guestText.style.fontWeight = "600";
    }
  }

  //--- 검색 제출 ---
  function submitSearch() {
    let params = [];
    let hasRegion = false; // 지역 변경 여부 체크
    
    if(selectedRegions.length > 0 && !selectedRegions.includes('전국')) {
      const optimizedRegions = selectedRegions.map(r => r.replace(' 전체', ''));
      params.push('regions=' + encodeURIComponent(optimizedRegions.join(',')));
      hasRegion = true;
    }
    
    if(selectedDates.length === 2) {
      params.push('checkin=' + selectedDates[0]);
      params.push('checkout=' + selectedDates[1]);
    }
    
    if (guests.adult > 0 || guests.child > 0) {
        params.push(`adult=\${guests.adult}&child=\${guests.child}`);
    }
    
    // 기본 이동 경로는 list 페이지!
    let url = '${pageContext.request.contextPath}/accommodation/list';
    
    // 만약 현재 위치가 detail 페이지이고, '지역' 필터를 건드리지 않았다면?
    // -> 리스트로 튕기지 않고 현재 상세 페이지를 유지하면서 날짜/인원만 재계산!
    if (window.location.pathname.includes('/detail/') && !hasRegion) {
        url = window.location.pathname; 
    }

    if(params.length > 0) {
        url += '?' + params.join('&');
    }
    location.href = url;
  }
  
  function resetAll() {
     clearRegions();
     selectedDates = [];
     guests = { adult: 0, child: 0 };
     
     document.getElementById('cnt-adult').innerText = 1;
     document.getElementById('cnt-child').innerText = 0;
     
     document.querySelectorAll('.btn-count').forEach(b => b.classList.remove('active'));
     
     updateCalendarUI();
     updateHeaderText();
  }
</script>