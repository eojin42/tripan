<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<jsp:include page="../layout/header.jsp" />

<!-- ══════════════════════════════════
     테스트 트리거 페이지
     실제 서비스: 헤더 메뉴에서 openCreateModal() 호출
══════════════════════════════════ -->
<div style="
  min-height: 100vh;
  background: linear-gradient(135deg, #F8FAFC 0%, #EDF2F7 100%);
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 20px;
  font-family: 'Pretendard', sans-serif;
  padding-top: 80px;
">
  <p style="font-size:13px;font-weight:700;letter-spacing:3px;color:#A0AEC0;text-transform:uppercase;">Tripan Travel Planner</p>
  <h1 style="font-size:36px;font-weight:900;color:#1A202C;letter-spacing:-1px;">새 여행 일정 만들기</h1>
  <p style="font-size:16px;color:#718096;margin-top:-8px;">아래 버튼을 눌러 일정을 시작하세요</p>
  <button
    onclick="openCreateModal()"
    style="
      margin-top:12px;
      padding: 18px 52px;
      background: linear-gradient(135deg, #89CFF0, #FFB6C1);
      border: none;
      border-radius: 50px;
      color: white;
      font-family: 'Pretendard', sans-serif;
      font-size: 16px;
      font-weight: 800;
      cursor: pointer;
      box-shadow: 0 10px 30px rgba(137,207,240,0.4);
      transition: all 0.3s cubic-bezier(0.19,1,0.22,1);
      letter-spacing: 0.5px;
    "
    onmouseover="this.style.transform='translateY(-4px)';this.style.boxShadow='0 16px 40px rgba(137,207,240,0.5)'"
    onmouseout="this.style.transform='';this.style.boxShadow='0 10px 30px rgba(137,207,240,0.4)'"
  >
    ✈️ &nbsp; 일정 만들기
  </button>
  <p style="font-size:12px;color:#CBD5E0;margin-top:8px;">
    헤더 메뉴 "AI 플래너 &gt; 일정 만들기" 와 연결 시 이 버튼 영역은 삭제하세요
  </p>
</div>


<link href="https://fonts.googleapis.com/css2?family=Pretendard:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">

<style>
/* ═══════════════════════════════════
   DESIGN TOKENS (Tripan 공통)
═══════════════════════════════════ */
:root {
  --ice-blue:      #A8C8E1;
  --orchid:        #C2B8D9;
  --rose:          #E0BBC2;
  --point-blue:    #89CFF0;
  --point-pink:    #FFB6C1;
  --text-dark:     #1A202C;
  --text-mid:      #4A5568;
  --text-light:    #A0AEC0;
  --white:         #FFFFFF;
  --bg:            #F8FAFC;
  --border:        #E2E8F0;

  --grad:  linear-gradient(120deg, var(--ice-blue) 0%, var(--orchid) 50%, var(--rose) 100%);
  --grad2: linear-gradient(135deg, var(--point-blue), var(--point-pink));
  --ease:  cubic-bezier(0.19, 1, 0.22, 1);
}

*, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

/* ═══════════════════════════════════
   OVERLAY BACKDROP
═══════════════════════════════════ */
#createOverlay {
  display: none;
  position: fixed;
  inset: 0;
  background: rgba(26, 32, 44, 0.55);
  backdrop-filter: blur(6px);
  -webkit-backdrop-filter: blur(6px);
  z-index: 1000;
  align-items: center;
  justify-content: center;
  animation: fadeIn .25s ease;
}
#createOverlay.active { display: flex; }

@keyframes fadeIn  { from { opacity:0 } to { opacity:1 } }
@keyframes slideUp { from { opacity:0; transform:translateY(32px) } to { opacity:1; transform:translateY(0) } }

/* ═══════════════════════════════════
   MODAL SHELL
═══════════════════════════════════ */
.modal {
  background: var(--white);
  border-radius: 20px;
  width: min(780px, 95vw);
  max-height: 90vh;
  overflow: hidden;
  box-shadow: 0 40px 100px rgba(0,0,0,0.18);
  display: flex;
  flex-direction: column;
  animation: slideUp .35s var(--ease);
}

/* 모달 헤더 */
.modal-head {
  padding: 36px 40px 28px;
  border-bottom: 1px solid var(--border);
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  flex-shrink: 0;
}
.modal-head-left {}
.modal-step-label {
  font-size: 11px;
  font-weight: 800;
  letter-spacing: 3px;
  text-transform: uppercase;
  background: var(--grad);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  display: block;
  margin-bottom: 6px;
}
.modal-title {
  font-size: 24px;
  font-weight: 800;
  color: var(--text-dark);
  letter-spacing: -0.5px;
}
.modal-close {
  width: 36px; height: 36px;
  border: none;
  background: var(--bg);
  border-radius: 50%;
  cursor: pointer;
  display: flex; align-items: center; justify-content: center;
  color: var(--text-mid);
  flex-shrink: 0;
  transition: background .2s, transform .2s;
}
.modal-close:hover { background: #EDF2F7; transform: rotate(90deg); }

/* 스텝 인디케이터 */
.step-indicator {
  display: flex;
  gap: 8px;
  padding: 0 40px 0;
  margin-top: 20px;
  flex-shrink: 0;
}
.step-dot {
  height: 4px;
  border-radius: 2px;
  transition: all .3s var(--ease);
  background: var(--border);
  flex: 1;
}
.step-dot.active {
  background: var(--grad);
  background: linear-gradient(90deg, var(--point-blue), var(--point-pink));
}

/* 모달 바디 */
.modal-body {
  flex: 1;
  overflow-y: auto;
  padding: 32px 40px;
  scrollbar-width: thin;
  scrollbar-color: var(--border) transparent;
}

/* 스텝 패널 */
.step-panel { display: none; }
.step-panel.active { display: block; animation: slideUp .3s var(--ease); }

/* ═══════════════════════════════════
   STEP 1 — 도시 선택
═══════════════════════════════════ */
.city-search-wrap {
  position: relative;
  margin-bottom: 24px;
}
.city-search-wrap svg {
  position: absolute;
  left: 16px; top: 50%;
  transform: translateY(-50%);
  color: var(--text-light);
  pointer-events: none;
}
.city-search {
  width: 100%;
  padding: 14px 16px 14px 46px;
  border: 1.5px solid var(--border);
  border-radius: 12px;
  font-family: 'Pretendard', sans-serif;
  font-size: 15px;
  color: var(--text-dark);
  outline: none;
  transition: border-color .2s, box-shadow .2s;
  background: var(--bg);
}
.city-search:focus {
  border-color: var(--point-blue);
  box-shadow: 0 0 0 3px rgba(137,207,240,.18);
  background: var(--white);
}

.region-section { margin-bottom: 28px; }
.region-label {
  font-size: 11px;
  font-weight: 800;
  letter-spacing: 2px;
  color: var(--text-light);
  text-transform: uppercase;
  margin-bottom: 12px;
  display: block;
}

.city-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(110px, 1fr));
  gap: 10px;
}
.city-chip {
  padding: 12px 8px;
  border: 1.5px solid var(--border);
  border-radius: 12px;
  background: var(--white);
  cursor: pointer;
  text-align: center;
  transition: all .2s var(--ease);
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 5px;
  user-select: none;
}
.city-chip:hover {
  border-color: var(--point-blue);
  background: #EBF8FF;
  transform: translateY(-2px);
  box-shadow: 0 6px 16px rgba(137,207,240,.2);
}
.city-chip.selected {
  border-color: transparent;
  background: var(--grad2);
  box-shadow: 0 6px 16px rgba(137,207,240,.35);
}
.city-chip.selected .city-name,
.city-chip.selected .city-emoji { color: white !important; filter: none; }
.city-emoji { font-size: 22px; line-height: 1; }
.city-name  { font-size: 13px; font-weight: 700; color: var(--text-dark); }

/* 선택된 도시 태그 영역 */
.selected-tags {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
  min-height: 0;
  margin-bottom: 0;
  transition: min-height .3s;
}
.selected-tags:not(:empty) { min-height: 36px; margin-bottom: 20px; }
.city-tag {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  padding: 6px 12px 6px 14px;
  background: var(--grad2);
  border-radius: 50px;
  color: white;
  font-size: 13px;
  font-weight: 700;
  animation: fadeIn .2s ease;
}
.city-tag button {
  background: rgba(255,255,255,.3);
  border: none;
  border-radius: 50%;
  width: 18px; height: 18px;
  cursor: pointer;
  color: white;
  font-size: 11px;
  display: flex; align-items: center; justify-content: center;
  transition: background .15s;
  line-height: 1;
}
.city-tag button:hover { background: rgba(255,255,255,.5); }

/* ═══════════════════════════════════
   STEP 2 — 여행 정보 입력
═══════════════════════════════════ */
.form-section { margin-bottom: 28px; }
.form-section-title {
  font-size: 13px;
  font-weight: 800;
  color: var(--text-mid);
  letter-spacing: 1px;
  margin-bottom: 12px;
  display: flex;
  align-items: center;
  gap: 8px;
}
.form-section-title .dot {
  width: 6px; height: 6px;
  border-radius: 50%;
  background: var(--grad2);
  flex-shrink: 0;
}

.form-row { display: grid; grid-template-columns: 1fr 1fr; gap: 14px; }

.form-group { display: flex; flex-direction: column; gap: 7px; }
.form-label {
  font-size: 12px;
  font-weight: 700;
  color: var(--text-mid);
  letter-spacing: 0.3px;
}
.form-input, .form-select {
  padding: 13px 16px;
  border: 1.5px solid var(--border);
  border-radius: 12px;
  font-family: 'Pretendard', sans-serif;
  font-size: 14px;
  color: var(--text-dark);
  background: var(--bg);
  outline: none;
  transition: border-color .2s, box-shadow .2s;
  -webkit-appearance: none;
}
.form-input:focus, .form-select:focus {
  border-color: var(--point-blue);
  box-shadow: 0 0 0 3px rgba(137,207,240,.18);
  background: var(--white);
}
.form-input::placeholder { color: var(--text-light); }

/* 날짜 범위 인풋 */
.date-range-wrap {
  display: grid;
  grid-template-columns: 1fr auto 1fr;
  gap: 10px;
  align-items: center;
}
.date-range-sep {
  width: 24px; height: 1.5px;
  background: var(--border);
  border-radius: 2px;
  flex-shrink: 0;
}

/* 인원 stepper */
.stepper-wrap {
  display: flex;
  align-items: center;
  gap: 0;
  border: 1.5px solid var(--border);
  border-radius: 12px;
  overflow: hidden;
  background: var(--bg);
  height: 48px;
}
.stepper-btn {
  width: 48px; height: 100%;
  border: none;
  background: transparent;
  cursor: pointer;
  font-size: 20px;
  color: var(--text-mid);
  transition: background .15s, color .15s;
  display: flex; align-items: center; justify-content: center;
  flex-shrink: 0;
}
.stepper-btn:hover { background: #EDF2F7; color: var(--text-dark); }
.stepper-val {
  flex: 1;
  text-align: center;
  font-size: 15px;
  font-weight: 700;
  color: var(--text-dark);
  user-select: none;
}

/* 테마 해시태그 선택 */
.theme-chips {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
}
.theme-chip {
  padding: 8px 16px;
  border: 1.5px solid var(--border);
  border-radius: 50px;
  font-size: 13px;
  font-weight: 600;
  color: var(--text-mid);
  background: var(--white);
  cursor: pointer;
  transition: all .2s;
  user-select: none;
}
.theme-chip:hover  { border-color: var(--point-pink); color: var(--text-dark); }
.theme-chip.active {
  border-color: transparent;
  background: var(--grad2);
  color: white;
  box-shadow: 0 4px 12px rgba(255,182,193,.35);
}

/* ═══════════════════════════════════
   STEP 3 — 확인 & 생성
═══════════════════════════════════ */
.confirm-card {
  background: var(--bg);
  border-radius: 16px;
  padding: 28px 32px;
  margin-bottom: 24px;
}
.confirm-row {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  padding: 12px 0;
  border-bottom: 1px solid var(--border);
  gap: 20px;
}
.confirm-row:last-child { border-bottom: none; }
.confirm-key {
  font-size: 12px;
  font-weight: 700;
  color: var(--text-light);
  letter-spacing: 1px;
  text-transform: uppercase;
  flex-shrink: 0;
  padding-top: 2px;
}
.confirm-val {
  font-size: 14px;
  font-weight: 700;
  color: var(--text-dark);
  text-align: right;
  word-break: keep-all;
}
.confirm-val .tag-list {
  display: flex; flex-wrap: wrap; gap: 5px; justify-content: flex-end;
}
.confirm-val .mini-tag {
  padding: 3px 10px;
  background: var(--grad2);
  border-radius: 50px;
  color: white;
  font-size: 12px;
  font-weight: 600;
}

.info-box {
  background: linear-gradient(135deg, rgba(137,207,240,.08), rgba(255,182,193,.08));
  border: 1px solid rgba(137,207,240,.3);
  border-radius: 12px;
  padding: 16px 20px;
  font-size: 13px;
  color: var(--text-mid);
  line-height: 1.7;
  display: flex;
  gap: 12px;
  align-items: flex-start;
}
.info-box .info-icon { font-size: 18px; flex-shrink: 0; margin-top: 1px; }

/* ═══════════════════════════════════
   MODAL FOOTER
═══════════════════════════════════ */
.modal-foot {
  padding: 20px 40px 28px;
  border-top: 1px solid var(--border);
  display: flex;
  justify-content: space-between;
  align-items: center;
  flex-shrink: 0;
  gap: 12px;
}
.btn-prev {
  padding: 13px 28px;
  border: 1.5px solid var(--border);
  border-radius: 50px;
  background: transparent;
  font-family: 'Pretendard', sans-serif;
  font-size: 14px;
  font-weight: 700;
  color: var(--text-mid);
  cursor: pointer;
  transition: all .2s;
}
.btn-prev:hover { border-color: var(--text-mid); color: var(--text-dark); }
.btn-next {
  padding: 14px 40px;
  border: none;
  border-radius: 50px;
  background: var(--grad2);
  font-family: 'Pretendard', sans-serif;
  font-size: 14px;
  font-weight: 800;
  color: white;
  cursor: pointer;
  box-shadow: 0 8px 24px rgba(137,207,240,.35);
  transition: all .3s var(--ease);
  display: flex;
  align-items: center;
  gap: 8px;
}
.btn-next:hover { transform: translateY(-2px); box-shadow: 0 12px 32px rgba(137,207,240,.45); }
.btn-next:disabled {
  opacity: .45;
  cursor: not-allowed;
  transform: none;
  box-shadow: none;
}
.btn-create {
  padding: 14px 48px;
  border: none;
  border-radius: 50px;
  background: var(--grad2);
  font-family: 'Pretendard', sans-serif;
  font-size: 15px;
  font-weight: 800;
  color: white;
  cursor: pointer;
  box-shadow: 0 8px 24px rgba(137,207,240,.4);
  transition: all .3s var(--ease);
  display: flex;
  align-items: center;
  gap: 10px;
}
.btn-create:hover { transform: translateY(-2px); box-shadow: 0 14px 36px rgba(137,207,240,.5); }

/* ═══════════════════════════════════
   LOADING SPINNER (생성 중)
═══════════════════════════════════ */
.creating-view {
  display: none;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 60px 0;
  gap: 24px;
  text-align: center;
}
.creating-view.active { display: flex; }
.spinner {
  width: 52px; height: 52px;
  border: 4px solid var(--border);
  border-top-color: var(--point-blue);
  border-radius: 50%;
  animation: spin 0.8s linear infinite;
}
@keyframes spin { to { transform: rotate(360deg); } }
.creating-text {
  font-size: 16px;
  font-weight: 700;
  color: var(--text-mid);
}
.creating-sub {
  font-size: 13px;
  color: var(--text-light);
  margin-top: -12px;
}

/* ═══════════════════════════════════
   RESPONSIVE
═══════════════════════════════════ */
@media (max-width: 600px) {
  .modal-head, .modal-body, .modal-foot, .step-indicator { padding-left: 24px; padding-right: 24px; }
  .form-row { grid-template-columns: 1fr; }
  .city-grid { grid-template-columns: repeat(3, 1fr); }
  .date-range-wrap { grid-template-columns: 1fr; }
  .date-range-sep { display: none; }
}
</style>


<%-- ══════════════════════════════════════════════
     MODAL HTML
══════════════════════════════════════════════ --%>
<div id="createOverlay" role="dialog" aria-modal="true" aria-labelledby="modalTitle">
  <div class="modal" id="createModal">

    <%-- ── 헤더 ── --%>
    <div class="modal-head">
      <div class="modal-head-left">
        <span class="modal-step-label" id="stepLabel">STEP 1 OF 3</span>
        <h2 class="modal-title" id="modalTitle">어디로 떠날까요?</h2>
      </div>
      <button class="modal-close" onclick="closeCreateModal()" aria-label="닫기">
        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>
      </button>
    </div>

    <%-- 스텝 인디케이터 --%>
    <div class="step-indicator" id="stepIndicator">
      <div class="step-dot active" id="dot0"></div>
      <div class="step-dot"        id="dot1"></div>
      <div class="step-dot"        id="dot2"></div>
    </div>

    <%-- ── 바디 ── --%>
    <div class="modal-body">

      <%-- 생성 중 로딩 --%>
      <div class="creating-view" id="creatingView">
        <div class="spinner"></div>
        <p class="creating-text">여행 일정을 만들고 있어요 ✈️</p>
        <p class="creating-sub">잠시만 기다려 주세요</p>
      </div>

      <%-- STEP 1: 도시 선택 --%>
      <div class="step-panel active" id="panel0">

        <div id="selectedTagsWrap" class="selected-tags"></div>

        <div class="city-search-wrap">
          <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
          <input type="text" class="city-search" id="citySearch" placeholder="도시 이름으로 검색…" oninput="filterCities(this.value)">
        </div>

        <div id="cityListWrap">
          <div class="region-section">
            <span class="region-label">🌊 해안 & 섬</span>
            <div class="city-grid">
              <div class="city-chip" onclick="toggleCity('제주', this)"><span class="city-emoji">🍊</span><span class="city-name">제주</span></div>
              <div class="city-chip" onclick="toggleCity('부산', this)"><span class="city-emoji">🌊</span><span class="city-name">부산</span></div>
              <div class="city-chip" onclick="toggleCity('여수', this)"><span class="city-emoji">🎆</span><span class="city-name">여수</span></div>
              <div class="city-chip" onclick="toggleCity('속초', this)"><span class="city-emoji">🦀</span><span class="city-name">속초</span></div>
              <div class="city-chip" onclick="toggleCity('강릉', this)"><span class="city-emoji">🌲</span><span class="city-name">강릉</span></div>
              <div class="city-chip" onclick="toggleCity('통영', this)"><span class="city-emoji">⛵</span><span class="city-name">통영</span></div>
            </div>
          </div>
          <div class="region-section">
            <span class="region-label">🏙️ 도심 & 도시</span>
            <div class="city-grid">
              <div class="city-chip" onclick="toggleCity('서울', this)"><span class="city-emoji">🗼</span><span class="city-name">서울</span></div>
              <div class="city-chip" onclick="toggleCity('인천', this)"><span class="city-emoji">✈️</span><span class="city-name">인천</span></div>
              <div class="city-chip" onclick="toggleCity('대구', this)"><span class="city-emoji">🍎</span><span class="city-name">대구</span></div>
              <div class="city-chip" onclick="toggleCity('광주', this)"><span class="city-emoji">🎨</span><span class="city-name">광주</span></div>
              <div class="city-chip" onclick="toggleCity('대전', this)"><span class="city-emoji">🔬</span><span class="city-name">대전</span></div>
              <div class="city-chip" onclick="toggleCity('울산', this)"><span class="city-emoji">🐋</span><span class="city-name">울산</span></div>
            </div>
          </div>
          <div class="region-section">
            <span class="region-label">🌿 자연 & 힐링</span>
            <div class="city-grid">
              <div class="city-chip" onclick="toggleCity('경주', this)"><span class="city-emoji">🏛️</span><span class="city-name">경주</span></div>
              <div class="city-chip" onclick="toggleCity('전주', this)"><span class="city-emoji">🥢</span><span class="city-name">전주</span></div>
              <div class="city-chip" onclick="toggleCity('춘천', this)"><span class="city-emoji">🦆</span><span class="city-name">춘천</span></div>
              <div class="city-chip" onclick="toggleCity('안동', this)"><span class="city-emoji">🎎</span><span class="city-name">안동</span></div>
              <div class="city-chip" onclick="toggleCity('남해', this)"><span class="city-emoji">🌻</span><span class="city-name">남해</span></div>
              <div class="city-chip" onclick="toggleCity('포항', this)"><span class="city-emoji">🌅</span><span class="city-name">포항</span></div>
            </div>
          </div>
        </div>
      </div>

      <%-- STEP 2: 여행 정보 입력 --%>
      <div class="step-panel" id="panel1">

        <div class="form-section">
          <p class="form-section-title"><span class="dot"></span> 여행 제목</p>
          <div class="form-group">
            <input type="text" class="form-input" id="tripTitle" placeholder="예: 제주 힐링 여행 🍊" maxlength="30">
          </div>
        </div>

        <div class="form-section">
          <p class="form-section-title"><span class="dot"></span> 여행 날짜</p>
          <div class="date-range-wrap">
            <div class="form-group">
              <label class="form-label">출발일</label>
              <input type="date" class="form-input" id="startDate" onchange="calcNights()">
            </div>
            <div class="date-range-sep"></div>
            <div class="form-group">
              <label class="form-label">귀국일</label>
              <input type="date" class="form-input" id="endDate" onchange="calcNights()">
            </div>
          </div>
          <p id="nightsInfo" style="font-size:13px;color:var(--point-blue);font-weight:700;margin-top:10px;min-height:18px;"></p>
        </div>

        <div class="form-section">
          <p class="form-section-title"><span class="dot"></span> 여행 인원</p>
          <div class="form-row">
            <div class="form-group">
              <label class="form-label">총 인원</label>
              <div class="stepper-wrap">
                <button class="stepper-btn" onclick="stepperChange('memberCount', -1)">−</button>
                <span class="stepper-val" id="memberCount">2</span>
                <button class="stepper-btn" onclick="stepperChange('memberCount', 1)">+</button>
              </div>
            </div>
            <div class="form-group">
              <label class="form-label">여행 유형</label>
              <select class="form-select" id="tripType">
                <option value="">선택하세요</option>
                <option value="couple">💑 커플</option>
                <option value="family">👨‍👩‍👧 가족</option>
                <option value="friends">👫 친구</option>
                <option value="solo">🙋 혼자</option>
                <option value="business">💼 비즈니스</option>
              </select>
            </div>
          </div>
        </div>

        <div class="form-section">
          <p class="form-section-title"><span class="dot"></span> 여행 테마 <span style="font-size:11px;color:var(--text-light);font-weight:500;margin-left:4px;">(중복 선택 가능)</span></p>
          <div class="theme-chips">
            <span class="theme-chip" onclick="toggleTheme(this)">#맛집탐방</span>
            <span class="theme-chip" onclick="toggleTheme(this)">#자연힐링</span>
            <span class="theme-chip" onclick="toggleTheme(this)">#역사문화</span>
            <span class="theme-chip" onclick="toggleTheme(this)">#액티비티</span>
            <span class="theme-chip" onclick="toggleTheme(this)">#카페투어</span>
            <span class="theme-chip" onclick="toggleTheme(this)">#쇼핑</span>
            <span class="theme-chip" onclick="toggleTheme(this)">#럭셔리</span>
            <span class="theme-chip" onclick="toggleTheme(this)">#가성비</span>
            <span class="theme-chip" onclick="toggleTheme(this)">#감성사진</span>
            <span class="theme-chip" onclick="toggleTheme(this)">#숙소중심</span>
          </div>
        </div>

      </div>

      <%-- STEP 3: 확인 & 생성 --%>
      <div class="step-panel" id="panel2">
        <div class="confirm-card" id="confirmCard">
          <%-- JS로 채워짐 --%>
        </div>
        <div class="info-box">
          <span class="info-icon">💡</span>
          <span>일정을 생성하면 <strong>워크스페이스</strong>로 이동해요. 카카오맵에서 장소를 추가하고, 동행자를 초대해 함께 편집할 수 있어요!</span>
        </div>
      </div>

    </div><%-- /modal-body --%>

    <%-- ── 푸터 ── --%>
    <div class="modal-foot" id="modalFoot">
      <button class="btn-prev" id="btnPrev" onclick="prevStep()" style="visibility:hidden">← 이전</button>
      <button class="btn-next" id="btnNext" onclick="nextStep()" disabled>
        다음 <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round"><line x1="5" y1="12" x2="19" y2="12"/><polyline points="12 5 19 12 12 19"/></svg>
      </button>
    </div>

  </div><%-- /modal --%>
</div><%-- /overlay --%>


<script>
/* ══════════════════════════════════
   STATE
══════════════════════════════════ */
let currentStep   = 0;
const TOTAL_STEPS = 3;
let selectedCities = [];
let memberCount    = 2;

const STEPS = [
  { label: 'STEP 1 OF 3', title: '어디로 떠날까요?'   },
  { label: 'STEP 2 OF 3', title: '여행 정보를 알려주세요' },
  { label: 'STEP 3 OF 3', title: '일정을 확인해요 ✨'  },
];

/* ══════════════════════════════════
   OPEN / CLOSE
══════════════════════════════════ */
function openCreateModal() {
  document.getElementById('createOverlay').classList.add('active');
  document.body.style.overflow = 'hidden';
  goToStep(0);
}
function closeCreateModal() {
  document.getElementById('createOverlay').classList.remove('active');
  document.body.style.overflow = '';
}
// 오버레이 클릭 시 닫기
document.getElementById('createOverlay').addEventListener('click', function(e) {
  if (e.target === this) closeCreateModal();
});

/* ══════════════════════════════════
   STEP NAVIGATION
══════════════════════════════════ */
function goToStep(step) {
  // 패널 전환
  document.querySelectorAll('.step-panel').forEach((p, i) => {
    p.classList.toggle('active', i === step);
  });
  // 인디케이터
  document.querySelectorAll('.step-dot').forEach((d, i) => {
    d.classList.toggle('active', i <= step);
  });
  // 헤더 텍스트
  document.getElementById('stepLabel').textContent = STEPS[step].label;
  document.getElementById('modalTitle').textContent = STEPS[step].title;

  // 버튼 상태
  const btnPrev = document.getElementById('btnPrev');
  const btnNext = document.getElementById('btnNext');
  const foot    = document.getElementById('modalFoot');

  btnPrev.style.visibility = step === 0 ? 'hidden' : 'visible';

  if (step === TOTAL_STEPS - 1) {
    // 마지막 스텝 → 생성 버튼
    btnNext.style.display = 'none';
    if (!document.getElementById('btnCreate')) {
      const btn = document.createElement('button');
      btn.id        = 'btnCreate';
      btn.className = 'btn-create';
      btn.innerHTML = '✈️ 일정 만들기';
      btn.onclick   = createTrip;
      foot.appendChild(btn);
    }
    document.getElementById('btnCreate').style.display = 'flex';
    buildConfirmCard();
  } else {
    btnNext.style.display = 'flex';
    const bc = document.getElementById('btnCreate');
    if (bc) bc.style.display = 'none';
  }

  validateStep(step);
  currentStep = step;
}

function nextStep() {
  if (currentStep < TOTAL_STEPS - 1) goToStep(currentStep + 1);
}
function prevStep() {
  if (currentStep > 0) goToStep(currentStep - 1);
}

/* ══════════════════════════════════
   VALIDATION
══════════════════════════════════ */
function validateStep(step) {
  const btn = document.getElementById('btnNext');
  if (step === 0) {
    btn.disabled = selectedCities.length === 0;
  } else if (step === 1) {
    const title = document.getElementById('tripTitle').value.trim();
    const start = document.getElementById('startDate').value;
    const end   = document.getElementById('endDate').value;
    btn.disabled = !(title && start && end && start <= end);
  } else {
    btn.disabled = false;
  }
}
// 실시간 검증
document.addEventListener('input', function(e) {
  if (['tripTitle','startDate','endDate'].includes(e.target.id)) validateStep(1);
});
document.addEventListener('change', function(e) {
  if (['startDate','endDate'].includes(e.target.id)) validateStep(1);
});

/* ══════════════════════════════════
   STEP 1: 도시 선택
══════════════════════════════════ */
function toggleCity(name, el) {
  const idx = selectedCities.indexOf(name);
  if (idx === -1) {
    selectedCities.push(name);
    el.classList.add('selected');
  } else {
    selectedCities.splice(idx, 1);
    el.classList.remove('selected');
  }
  renderTags();
  validateStep(0);
}

function renderTags() {
  const wrap = document.getElementById('selectedTagsWrap');
  wrap.innerHTML = selectedCities.map(function(city) {
    return '<span class="city-tag">' + city +
      '<button onclick="removeCity(\'' + city + '\')" aria-label="' + city + ' 제거">✕</button>' +
    '</span>';
  }).join('');
}

function removeCity(name) {
  selectedCities = selectedCities.filter(c => c !== name);
  // chip selected 해제
  document.querySelectorAll('.city-chip').forEach(el => {
    if (el.querySelector('.city-name').textContent === name) el.classList.remove('selected');
  });
  renderTags();
  validateStep(0);
}

function filterCities(q) {
  document.querySelectorAll('.city-chip').forEach(el => {
    const match = el.querySelector('.city-name').textContent.includes(q);
    el.style.display = match ? '' : 'none';
  });
  // 비어있는 섹션 숨기기
  document.querySelectorAll('.region-section').forEach(sec => {
    const visible = [...sec.querySelectorAll('.city-chip')].some(c => c.style.display !== 'none');
    sec.style.display = visible ? '' : 'none';
  });
}

/* ══════════════════════════════════
   STEP 2: 폼
══════════════════════════════════ */
function stepperChange(id, delta) {
  const el  = document.getElementById(id);
  const val = Math.max(1, Math.min(20, parseInt(el.textContent) + delta));
  el.textContent = val;
  memberCount = val;
}

function calcNights() {
  const s = document.getElementById('startDate').value;
  const e = document.getElementById('endDate').value;
  const el = document.getElementById('nightsInfo');
  if (s && e && s <= e) {
    const nights = Math.round((new Date(e) - new Date(s)) / 86400000);
    el.textContent = nights === 0
      ? '당일치기 여행이에요 🌤️'
      : (nights + '박 ' + (nights + 1) + '일 여행이에요 🌙');
  } else if (s && e && s > e) {
    el.textContent = '⚠️ 귀국일이 출발일보다 빠를 수 없어요';
    el.style.color = '#FC8181';
  } else {
    el.textContent = '';
  }
}

function toggleTheme(el) {
  el.classList.toggle('active');
}

function getSelectedThemes() {
  return [...document.querySelectorAll('.theme-chip.active')]
    .map(el => el.textContent);
}

/* ══════════════════════════════════
   STEP 3: 확인 카드 빌드
══════════════════════════════════ */
function buildConfirmCard() {
  const title  = document.getElementById('tripTitle').value;
  const start  = document.getElementById('startDate').value;
  const end    = document.getElementById('endDate').value;
  const type   = document.getElementById('tripType');
  const typeText = type.options[type.selectedIndex].text || '미선택';
  const themes = getSelectedThemes();
  const nights = Math.round((new Date(end) - new Date(start)) / 86400000);
  const nightText = nights === 0 ? '당일치기' : (nights + '박 ' + (nights+1) + '일');

  const tagsHtml = themes.length
    ? '<div class="tag-list">' + themes.map(function(t){ return '<span class="mini-tag">' + t + '</span>'; }).join('') + '</div>'
    : '선택 없음';

  document.getElementById('confirmCard').innerHTML =
    '<div class="confirm-row">' +
      '<span class="confirm-key">여행 제목</span>' +
      '<span class="confirm-val">' + title + '</span>' +
    '</div>' +
    '<div class="confirm-row">' +
      '<span class="confirm-key">여행지</span>' +
      '<span class="confirm-val">' + selectedCities.join(', ') + '</span>' +
    '</div>' +
    '<div class="confirm-row">' +
      '<span class="confirm-key">일정</span>' +
      '<span class="confirm-val">' + start + ' → ' + end + '<br><span style="color:var(--point-blue);font-size:13px;">' + nightText + '</span></span>' +
    '</div>' +
    '<div class="confirm-row">' +
      '<span class="confirm-key">인원 / 유형</span>' +
      '<span class="confirm-val">' + memberCount + '명 / ' + typeText + '</span>' +
    '</div>' +
    '<div class="confirm-row">' +
      '<span class="confirm-key">테마</span>' +
      '<span class="confirm-val">' + tagsHtml + '</span>' +
    '</div>';
}

/* ══════════════════════════════════
   CREATE TRIP (실제 구현 시 AJAX → redirect)
══════════════════════════════════ */
function createTrip() {
  // 로딩 표시
  document.querySelectorAll('.step-panel').forEach(p => p.classList.remove('active'));
  document.getElementById('creatingView').classList.add('active');
  document.getElementById('modalFoot').style.display = 'none';
  document.querySelector('.step-indicator').style.display = 'none';

  // ── [실제 구현] ──────────────────────────────────
  // const data = {
  //   cities:    selectedCities,
  //   title:     document.getElementById('tripTitle').value,
  //   startDate: document.getElementById('startDate').value,
  //   endDate:   document.getElementById('endDate').value,
  //   memberCount: memberCount,
  //   tripType:  document.getElementById('tripType').value,
  //   themes:    getSelectedThemes()
  // };
  // fetch('/trip/create', { method:'POST', headers:{'Content-Type':'application/json'}, body: JSON.stringify(data) })
  //   .then(r => r.json())
  //   .then(res => location.href = '/trip/workspace?id=' + res.tripId)
  //   .catch(err => alert('오류가 발생했습니다.'));
  // ─────────────────────────────────────────────────

  // 데모: 1.5초 후 workspace로 이동
  setTimeout(() => {
    location.href = '${pageContext.request.contextPath}/trip/trip_workspace';
  }, 1500);
}

/* ══════════════════════════════════
   날짜 min 설정 (오늘 이후만)
══════════════════════════════════ */
(function() {
  const today = new Date().toISOString().split('T')[0];
  document.getElementById('startDate').min = today;
  document.getElementById('endDate').min   = today;
})();
</script>
