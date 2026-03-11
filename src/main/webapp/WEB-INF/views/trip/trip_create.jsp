<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<jsp:include page="../layout/header.jsp" />

<link href="https://fonts.googleapis.com/css2?family=Pretendard:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">

<style>
:root {
  --ice-blue:   #A8C8E1;
  --orchid:     #C2B8D9;
  --rose:       #E0BBC2;
  --point-blue: #89CFF0;
  --point-pink: #FFB6C1;
  --dark:       #1A202C;
  --mid:        #4A5568;
  --light:      #A0AEC0;
  --white:      #FFFFFF;
  --bg:         #F8FAFC;
  --border:     #E2E8F0;
  --grad:  linear-gradient(120deg, var(--ice-blue) 0%, var(--orchid) 50%, var(--rose) 100%);
  --grad2: linear-gradient(135deg, var(--point-blue), var(--point-pink));
  --ease:  cubic-bezier(0.19, 1, 0.22, 1);
}
*, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

/* 트리거 버튼 영역 */
.page-trigger {
  min-height: 100vh;
  background: linear-gradient(135deg, #F8FAFC 0%, #EDF2F7 100%);
  display: flex; flex-direction: column; align-items: center; justify-content: center;
  gap: 20px; font-family: 'Pretendard', sans-serif; padding-top: 80px;
}

/* 오버레이 */
#createOverlay {
  display: none; position: fixed; inset: 0;
  background: rgba(26,32,44,.55); backdrop-filter: blur(6px); -webkit-backdrop-filter: blur(6px);
  z-index: 1000; align-items: center; justify-content: center; animation: fadeIn .25s ease;
}
#createOverlay.active { display: flex; }

@keyframes fadeIn  { from{opacity:0} to{opacity:1} }
@keyframes slideUp { from{opacity:0;transform:translateY(32px)} to{opacity:1;transform:translateY(0)} }

/* 모달 */
.modal {
  background: var(--white); border-radius: 20px;
  width: min(780px, 95vw); max-height: 90vh; overflow: hidden;
  box-shadow: 0 40px 100px rgba(0,0,0,.18);
  display: flex; flex-direction: column; animation: slideUp .35s var(--ease);
}
.modal-head {
  padding: 36px 40px 28px; border-bottom: 1px solid var(--border);
  display: flex; align-items: flex-start; justify-content: space-between; flex-shrink: 0;
}
.modal-step-label {
  font-size: 11px; font-weight: 800; letter-spacing: 3px; text-transform: uppercase;
  background: var(--grad); -webkit-background-clip: text; -webkit-text-fill-color: transparent;
  display: block; margin-bottom: 6px;
}
.modal-title { font-size: 24px; font-weight: 800; color: var(--dark); letter-spacing: -.5px; }
.modal-close {
  width: 36px; height: 36px; border: none; background: var(--bg); border-radius: 50%;
  cursor: pointer; display: flex; align-items: center; justify-content: center;
  color: var(--mid); flex-shrink: 0; transition: background .2s, transform .2s;
}
.modal-close:hover { background: #EDF2F7; transform: rotate(90deg); }

.step-indicator { display: flex; gap: 8px; padding: 0 40px; margin-top: 20px; flex-shrink: 0; }
.step-dot { height: 4px; border-radius: 2px; transition: all .3s var(--ease); background: var(--border); flex: 1; }
.step-dot.active { background: linear-gradient(90deg, var(--point-blue), var(--point-pink)); }

.modal-body {
  flex: 1; overflow-y: auto; padding: 36px 40px;
  scrollbar-width: thin; scrollbar-color: var(--border) transparent;
}
.step-panel { display: none; }
.step-panel.active { display: block; animation: slideUp .3s var(--ease); }

/* STEP 1 */


.region-section { margin-bottom: 28px; }
.region-label { font-size: 11px; font-weight: 800; letter-spacing: 2px; color: var(--light); text-transform: uppercase; margin-bottom: 12px; display: block; }
.city-grid { display: grid; grid-template-columns: repeat(4, 1fr); gap: 10px; }
.city-chip {
  padding: 12px 8px; border: 1.5px solid var(--border); border-radius: 12px; background: var(--white);
  cursor: pointer; text-align: center; transition: all .2s var(--ease);
  display: flex; flex-direction: column; align-items: center; gap: 5px; user-select: none;
}
.city-chip:hover { border-color: var(--point-blue); background: #EBF8FF; transform: translateY(-2px); box-shadow: 0 6px 16px rgba(137,207,240,.2); }
.city-chip.selected { border-color: transparent; background: var(--grad2); box-shadow: 0 6px 16px rgba(137,207,240,.35); }
.city-chip.selected .city-name, .city-chip.selected .city-emoji { color: white !important; filter: none; }
.city-emoji { font-size: 18px; line-height: 1; }
.city-name  { font-size: 13px; font-weight: 700; color: var(--dark); }

.selected-tags { display: flex; flex-wrap: wrap; gap: 8px; min-height: 0; margin-bottom: 0; transition: min-height .3s; }
.selected-tags:not(:empty) { min-height: 36px; margin-bottom: 20px; }
.city-tag {
  display: inline-flex; align-items: center; gap: 6px; padding: 6px 12px 6px 14px;
  background: var(--grad2); border-radius: 50px; color: white; font-size: 13px; font-weight: 700; animation: fadeIn .2s ease;
}
.city-tag button {
  background: rgba(255,255,255,.3); border: none; border-radius: 50%; width: 18px; height: 18px;
  cursor: pointer; color: white; font-size: 11px; display: flex; align-items: center; justify-content: center; transition: background .15s;
}
.city-tag button:hover { background: rgba(255,255,255,.5); }

/* STEP 2 */
.form-section { margin-bottom: 36px; }
.form-section:last-child { margin-bottom: 0; }
.form-section-title {
  font-size: 13px; font-weight: 800; color: var(--mid); letter-spacing: 1px;
  margin-bottom: 16px; display: flex; align-items: center; gap: 8px;
}
.form-section-title .dot { width: 6px; height: 6px; border-radius: 50%; background: var(--grad2); flex-shrink: 0; }

.form-row { display: grid; grid-template-columns: 1fr 1fr; gap: 14px; }
.form-group { display: flex; flex-direction: column; gap: 8px; }
.form-label { font-size: 12px; font-weight: 700; color: var(--mid); letter-spacing: .3px; }
.form-input, .form-select {
  padding: 13px 16px; border: 1.5px solid var(--border); border-radius: 12px;
  font-family: 'Pretendard', sans-serif; font-size: 14px; color: var(--dark);
  background: var(--bg); outline: none; transition: border-color .2s, box-shadow .2s; -webkit-appearance: none;
}
.form-input:focus, .form-select:focus { border-color: var(--point-blue); box-shadow: 0 0 0 3px rgba(137,207,240,.18); background: var(--white); }
.form-input::placeholder { color: var(--light); }
.form-textarea {
  padding: 13px 16px; border: 1.5px solid var(--border); border-radius: 12px;
  font-family: 'Pretendard', sans-serif; font-size: 14px; color: var(--dark);
  background: var(--bg); outline: none; resize: vertical; min-height: 88px; max-height: 180px;
  transition: border-color .2s, box-shadow .2s; line-height: 1.6; width: 100%;
}
.form-textarea:focus { border-color: var(--point-blue); box-shadow: 0 0 0 3px rgba(137,207,240,.18); background: var(--white); }
.form-textarea::placeholder { color: var(--light); }
.desc-count { font-size: 12px; color: var(--light); text-align: right; margin-top: 6px; }

.date-range-wrap { display: grid; grid-template-columns: 1fr auto 1fr; gap: 10px; align-items: center; }
.date-range-sep { width: 24px; height: 1.5px; background: var(--border); border-radius: 2px; flex-shrink: 0; }

.stepper-wrap { display: flex; align-items: center; border: 1.5px solid var(--border); border-radius: 12px; overflow: hidden; background: var(--bg); height: 48px; }
.stepper-btn { width: 48px; height: 100%; border: none; background: transparent; cursor: pointer; font-size: 20px; color: var(--mid); transition: background .15s; display: flex; align-items: center; justify-content: center; flex-shrink: 0; }
.stepper-btn:hover { background: #EDF2F7; }
.stepper-val { flex: 1; text-align: center; font-size: 15px; font-weight: 700; color: var(--dark); user-select: none; }

.theme-chips { display: flex; flex-wrap: wrap; gap: 10px; }
.theme-chip {
  padding: 9px 18px; border: 1.5px solid var(--border); border-radius: 50px;
  font-size: 13px; font-weight: 600; color: var(--mid); background: var(--white); cursor: pointer; transition: all .2s; user-select: none;
}
.theme-chip:hover  { border-color: var(--point-pink); color: var(--dark); }
.theme-chip.active { border-color: transparent; background: var(--grad2); color: white; box-shadow: 0 4px 12px rgba(255,182,193,.35); }

.tag-input-wrap {
  margin-top: 12px; display: flex; flex-wrap: wrap; gap: 6px; align-items: center;
  padding: 10px 14px; border: 1.5px solid var(--border); border-radius: 12px;
  background: var(--bg); cursor: text; min-height: 48px; transition: border-color .2s;
}
.tag-input-wrap:focus-within { border-color: var(--point-blue); box-shadow: 0 0 0 3px rgba(137,207,240,.18); background: var(--white); }
.tag-text-input { border: none; outline: none; background: transparent; font-family: 'Pretendard', sans-serif; font-size: 14px; color: var(--dark); flex: 1; min-width: 100px; }
.tag-text-input::placeholder { color: var(--light); }
.custom-tag { display: inline-flex; align-items: center; gap: 5px; padding: 4px 10px 4px 12px; background: var(--grad2); border-radius: 50px; color: white; font-size: 12px; font-weight: 700; }
.custom-tag button { background: rgba(255,255,255,.3); border: none; border-radius: 50%; width: 16px; height: 16px; cursor: pointer; color: white; font-size: 10px; display: flex; align-items: center; justify-content: center; }
.tag-hint { font-size: 12px; color: var(--light); margin-top: 8px; }

.visibility-row {
  display: flex; align-items: center; justify-content: space-between;
  padding: 16px 20px; border: 1.5px solid var(--border); border-radius: 12px; background: var(--bg);
}
.visibility-title { font-size: 14px; font-weight: 700; color: var(--dark); margin-bottom: 3px; }
.visibility-desc  { font-size: 12px; color: var(--light); }
.toggle-switch { position: relative; width: 44px; height: 24px; flex-shrink: 0; }
.toggle-switch input { opacity: 0; width: 0; height: 0; }
.toggle-slider { position: absolute; inset: 0; border-radius: 50px; background: var(--border); transition: .3s; cursor: pointer; }
.toggle-slider::before { content: ''; position: absolute; width: 18px; height: 18px; border-radius: 50%; background: white; bottom: 3px; left: 3px; transition: .3s; box-shadow: 0 1px 4px rgba(0,0,0,.15); }
.toggle-switch input:checked + .toggle-slider { background: var(--grad2); }
.toggle-switch input:checked + .toggle-slider::before { transform: translateX(20px); }

/* STEP 3 */
.confirm-card { background: var(--bg); border-radius: 16px; padding: 28px 32px; margin-bottom: 24px; }
.confirm-row { display: flex; justify-content: space-between; align-items: flex-start; padding: 14px 0; border-bottom: 1px solid var(--border); gap: 20px; }
.confirm-row:last-child { border-bottom: none; padding-bottom: 0; }
.confirm-key { font-size: 12px; font-weight: 700; color: var(--light); letter-spacing: 1px; text-transform: uppercase; flex-shrink: 0; padding-top: 2px; }
.confirm-val { font-size: 14px; font-weight: 700; color: var(--dark); text-align: right; word-break: keep-all; }
.confirm-val .tag-list { display: flex; flex-wrap: wrap; gap: 5px; justify-content: flex-end; }
.confirm-val .mini-tag { padding: 3px 10px; background: var(--grad2); border-radius: 50px; color: white; font-size: 12px; font-weight: 600; }
.badge-private { padding: 2px 10px; border-radius: 50px; font-size: 11px; font-weight: 700; background: rgba(160,174,192,.1); color: var(--mid); border: 1px solid var(--border); }
.badge-public  { padding: 2px 10px; border-radius: 50px; font-size: 11px; font-weight: 700; background: rgba(104,211,145,.15); color: #276749; border: 1px solid rgba(104,211,145,.3); }

.info-box {
  background: linear-gradient(135deg, rgba(137,207,240,.08), rgba(255,182,193,.08));
  border: 1px solid rgba(137,207,240,.3); border-radius: 12px; padding: 18px 20px;
  font-size: 13px; color: var(--mid); line-height: 1.7; display: flex; gap: 12px; align-items: flex-start;
}

/* 로딩 */
.creating-view { display: none; flex-direction: column; align-items: center; justify-content: center; padding: 60px 0; gap: 20px; text-align: center; }
.creating-view.active { display: flex; }
.spinner { width: 52px; height: 52px; border: 4px solid var(--border); border-top-color: var(--point-blue); border-radius: 50%; animation: spin .8s linear infinite; }
@keyframes spin { to { transform: rotate(360deg); } }
.creating-steps { display: flex; flex-direction: column; gap: 10px; margin-top: 4px; }
.creating-step { font-size: 13px; color: var(--light); display: flex; align-items: center; gap: 8px; transition: color .3s; }
.creating-step.done { color: var(--mid); }
.step-icon { font-size: 15px; width: 20px; text-align: center; }

.error-box { background: #FFF5F5; border: 1px solid #FEB2B2; border-radius: 12px; padding: 16px 20px; font-size: 13px; color: #C53030; margin-bottom: 16px; display: none; }
.error-box.active { display: block; }

/* 푸터 */
.modal-foot { padding: 20px 40px 28px; border-top: 1px solid var(--border); display: flex; justify-content: space-between; align-items: center; flex-shrink: 0; gap: 12px; }
.btn-prev { padding: 13px 28px; border: 1.5px solid var(--border); border-radius: 50px; background: transparent; font-family: 'Pretendard', sans-serif; font-size: 14px; font-weight: 700; color: var(--mid); cursor: pointer; transition: all .2s; }
.btn-prev:hover { border-color: var(--mid); color: var(--dark); }
.btn-next { padding: 14px 40px; border: none; border-radius: 50px; background: var(--grad2); font-family: 'Pretendard', sans-serif; font-size: 14px; font-weight: 800; color: white; cursor: pointer; box-shadow: 0 8px 24px rgba(137,207,240,.35); transition: all .3s var(--ease); display: flex; align-items: center; gap: 8px; }
.btn-next:hover { transform: translateY(-2px); box-shadow: 0 12px 32px rgba(137,207,240,.45); }
.btn-next:disabled { opacity: .45; cursor: not-allowed; transform: none; box-shadow: none; }
.btn-create { padding: 14px 48px; border: none; border-radius: 50px; background: var(--grad2); font-family: 'Pretendard', sans-serif; font-size: 15px; font-weight: 800; color: white; cursor: pointer; box-shadow: 0 8px 24px rgba(137,207,240,.4); transition: all .3s var(--ease); display: flex; align-items: center; gap: 10px; }
.btn-create:hover { transform: translateY(-2px); box-shadow: 0 14px 36px rgba(137,207,240,.5); }

@media (max-width: 600px) {
  .modal-head, .modal-body, .modal-foot, .step-indicator { padding-left: 24px; padding-right: 24px; }
  .form-row { grid-template-columns: 1fr; }
  .city-grid { grid-template-columns: repeat(3, 1fr); }
  .date-range-wrap { grid-template-columns: 1fr; }
  .date-range-sep { display: none; }
}

/* ── 여행유형 버튼 (button 태그) ── */
.trip-type-grid { display: flex; gap: 8px; }
.trip-type-btn {
  flex: 1; display: flex; flex-direction: column; align-items: center; gap: 8px;
  padding: 15px 6px 13px;
  border: 2px solid var(--border); border-radius: 16px;
  background: var(--white); cursor: pointer;
  font-family: 'Pretendard', sans-serif;
  transition: all .18s ease; user-select: none; outline: none;
}
.trip-type-btn:hover {
  border-color: var(--point-blue); background: #EBF8FF;
  transform: translateY(-3px); box-shadow: 0 8px 20px rgba(137,207,240,.22);
}
.trip-type-btn.selected {
  border-color: transparent;
  background: linear-gradient(135deg, #89CFF0, #FFB6C1);
  box-shadow: 0 8px 24px rgba(137,207,240,.4);
  transform: translateY(-3px);
}
.trip-type-btn.selected .type-label { color: white; }
.type-emoji { font-size: 24px; line-height: 1; display: block; }
.type-label { font-size: 12px; font-weight: 700; color: var(--dark); white-space: nowrap; }

/* ── 썸네일: 원형 ── */
.thumb-section-wrap { display: flex; gap: 22px; align-items: center; }
.thumb-circle-wrap { position: relative; flex-shrink: 0; }
.thumb-circle {
  width: 96px; height: 96px; border-radius: 50%;
  border: 3px solid var(--border); background: var(--bg);
  overflow: hidden; cursor: pointer; transition: border-color .2s;
  position: relative; display: flex; align-items: center; justify-content: center;
}
.thumb-circle:hover { border-color: var(--point-blue); }
.thumb-circle img { width: 100%; height: 100%; object-fit: cover; border-radius: 50%; display: block; }
.thumb-circle-overlay {
  position: absolute; inset: 0; border-radius: 50%;
  background: rgba(0,0,0,.36); opacity: 0;
  display: flex; align-items: center; justify-content: center;
  font-size: 20px; color: white; transition: opacity .2s;
}
.thumb-circle:hover .thumb-circle-overlay { opacity: 1; }
.thumb-x-btn {
  position: absolute; top: 0; right: 0;
  width: 26px; height: 26px; border-radius: 50%;
  background: #FC8181; border: 2px solid white; color: white;
  font-size: 13px; font-weight: 700; cursor: pointer;
  display: none; align-items: center; justify-content: center;
  outline: none; line-height: 1;
}
.thumb-x-btn.visible { display: flex; }
.thumb-right { display: flex; flex-direction: column; gap: 8px; }
.thumb-pick-btn {
  display: inline-flex; align-items: center; gap: 8px;
  padding: 11px 22px; border-radius: 50px;
  background: var(--grad2); color: white; border: none;
  font-family: 'Pretendard', sans-serif; font-size: 13px; font-weight: 700;
  cursor: pointer; transition: opacity .2s; white-space: nowrap;
}
.thumb-pick-btn:hover { opacity: .87; }
.thumb-info-txt { font-size: 11px; color: var(--light); line-height: 1.7; }

/* ── 예산 ── */
.budget-row {
  display: flex; align-items: center;
  border: 1.5px solid var(--border); border-radius: 12px;
  background: var(--bg); height: 52px; overflow: hidden;
  transition: border-color .2s, box-shadow .2s;
}
.budget-row:focus-within {
  border-color: var(--point-blue); box-shadow: 0 0 0 3px rgba(137,207,240,.18);
  background: var(--white);
}
.budget-sym {
  padding: 0 16px; font-size: 16px; font-weight: 800; color: #718096;
  border-right: 1.5px solid var(--border); height: 100%;
  display: flex; align-items: center; background: #F7FAFC; flex-shrink: 0;
}
.budget-num {
  flex: 1; border: none; outline: none; background: transparent;
  font-family: 'Pretendard', sans-serif; font-size: 15px; font-weight: 700;
  color: var(--dark); padding: 0 16px; height: 100%;
}
.budget-num::placeholder { color: var(--light); font-weight: 400; font-size: 14px; }
.budget-won {
  padding: 0 14px; font-size: 13px; font-weight: 600; color: #A0AEC0;
  height: 100%; display: flex; align-items: center; flex-shrink: 0;
  border-left: 1.5px solid var(--border); background: #F7FAFC;
}
.budget-preview-txt {
  font-size: 12px; color: var(--point-blue); font-weight: 700;
  margin-top: 8px; min-height: 16px; padding-left: 2px;
}

/* ── STEP3 확인카드 썸네일 원형 ── */
.confirm-thumb-circle {
  width: 56px; height: 56px; border-radius: 50%;
  border: 2px solid var(--border); object-fit: cover; display: block;
  flex-shrink: 0;
}
</style>


<%-- 테스트 트리거 --%>
<div class="page-trigger">
  <p style="font-size:13px;font-weight:700;letter-spacing:3px;color:#A0AEC0;text-transform:uppercase;">Tripan Travel Planner</p>
  <h1 style="font-size:36px;font-weight:900;color:#1A202C;letter-spacing:-1px;">새 여행 일정 만들기</h1>
  <p style="font-size:16px;color:#718096;margin-top:-8px;">아래 버튼을 눌러 일정을 시작하세요</p>
  <button onclick="openCreateModal()" style="margin-top:12px;padding:18px 52px;background:linear-gradient(135deg,#89CFF0,#FFB6C1);border:none;border-radius:50px;color:white;font-family:'Pretendard',sans-serif;font-size:16px;font-weight:800;cursor:pointer;box-shadow:0 10px 30px rgba(137,207,240,.4);transition:all .3s;letter-spacing:.5px;" onmouseover="this.style.transform='translateY(-4px)'" onmouseout="this.style.transform=''">✈️ &nbsp; 일정 만들기</button>
</div>


<%-- 모달 --%>
<div id="createOverlay" role="dialog" aria-modal="true" aria-labelledby="modalTitle">
  <div class="modal">

    <div class="modal-head">
      <div>
        <span class="modal-step-label" id="stepLabel">STEP 1 OF 3</span>
        <h2 class="modal-title" id="modalTitle">어디로 떠날까요?</h2>
      </div>
      <button class="modal-close" onclick="closeCreateModal()" aria-label="닫기">
        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>
      </button>
    </div>

    <div class="step-indicator" id="stepIndicator">
      <div class="step-dot active" id="dot0"></div>
      <div class="step-dot"        id="dot1"></div>
      <div class="step-dot"        id="dot2"></div>
    </div>

    <div class="modal-body">

      <%-- 로딩 뷰 --%>
      <div class="creating-view" id="creatingView">
        <div class="spinner"></div>
        <p style="font-size:16px;font-weight:700;color:var(--mid);">여행 일정을 만들고 있어요 ✈️</p>
        <div class="creating-steps">
          <div class="creating-step" id="cs1"><span class="step-icon" id="ci1">⏳</span> 여행 정보 저장 중</div>
          <div class="creating-step" id="cs2"><span class="step-icon" id="ci2">⏳</span> 방장 등록 중</div>
          <div class="creating-step" id="cs3"><span class="step-icon" id="ci3">⏳</span> 일정 뼈대 생성 중</div>
          <div class="creating-step" id="cs4"><span class="step-icon" id="ci4">⏳</span> 테마 태그 적용 중</div>
        </div>
      </div>
      <div class="error-box" id="errorBox"></div>

      <%-- STEP 1 --%>
      <div class="step-panel active" id="panel0">
        <div id="selectedTagsWrap" class="selected-tags"></div>
        <%-- 지역 선택 그리드 (14개 고정, 다중 선택 가능) --%>
        <div class="city-grid" id="cityListWrap">
          <div class="city-chip" onclick="toggleCity('서울',this)"><span class="city-emoji">🗼</span><span class="city-name">서울</span></div>
          <div class="city-chip" onclick="toggleCity('부산',this)"><span class="city-emoji">🌊</span><span class="city-name">부산</span></div>
          <div class="city-chip" onclick="toggleCity('제주',this)"><span class="city-emoji">🍊</span><span class="city-name">제주</span></div>
          <div class="city-chip" onclick="toggleCity('강원',this)"><span class="city-emoji">🏔️</span><span class="city-name">강원</span></div>
          <div class="city-chip" onclick="toggleCity('경상',this)"><span class="city-emoji">🏯</span><span class="city-name">경상</span></div>
          <div class="city-chip" onclick="toggleCity('전라',this)"><span class="city-emoji">🥢</span><span class="city-name">전라</span></div>
          <div class="city-chip" onclick="toggleCity('충청',this)"><span class="city-emoji">🌿</span><span class="city-name">충청</span></div>
          <div class="city-chip" onclick="toggleCity('경기',this)"><span class="city-emoji">🏰</span><span class="city-name">경기</span></div>
          <div class="city-chip" onclick="toggleCity('인천',this)"><span class="city-emoji">✈️</span><span class="city-name">인천</span></div>
          <div class="city-chip" onclick="toggleCity('대전',this)"><span class="city-emoji">🔬</span><span class="city-name">대전</span></div>
          <div class="city-chip" onclick="toggleCity('대구',this)"><span class="city-emoji">🍎</span><span class="city-name">대구</span></div>
          <div class="city-chip" onclick="toggleCity('광주',this)"><span class="city-emoji">🎨</span><span class="city-name">광주</span></div>
          <div class="city-chip" onclick="toggleCity('울산',this)"><span class="city-emoji">🏭</span><span class="city-name">울산</span></div>
          <div class="city-chip" onclick="toggleCity('세종',this)"><span class="city-emoji">🏛️</span><span class="city-name">세종</span></div>
        </div>
      </div>

      <%-- STEP 2 --%>
      <div class="step-panel" id="panel1">

        <div class="form-section">
          <p class="form-section-title"><span class="dot"></span> 여행 제목</p>
          <div class="form-group" style="position:relative;">
            <input type="text" class="form-input" id="tripTitle"
              placeholder="예: 제주 힐링 여행 🍊" maxlength="30"
              oninput="document.getElementById('titleCount').textContent=this.value.length;validateStep(1);"
              style="padding-right:60px;">
            <span style="position:absolute;right:14px;top:50%;transform:translateY(-50%);font-size:12px;color:var(--light);pointer-events:none;">
              <span id="titleCount">0</span>/30
            </span>
          </div>
        </div>

        <%-- 여행 설명 --%>
        <div class="form-section">
          <p class="form-section-title"><span class="dot"></span> 여행 설명 <span style="font-weight:400;color:var(--light);font-size:11px;">(선택)</span></p>
          <div class="form-group" style="position:relative;">
            <textarea class="form-textarea" id="tripDescription"
              placeholder="이 여행에 대해 자유롭게 소개해 주세요. 예: 친구들과 떠나는 설레는 제주 3박 4일! 🍊"
              maxlength="200"
              oninput="document.getElementById('descCount').textContent=this.value.length;"></textarea>
            <p class="desc-count"><span id="descCount">0</span> / 200</p>
          </div>
        </div>

        <div class="form-section">
          <p class="form-section-title"><span class="dot"></span> 여행 날짜</p>
          <div class="date-range-wrap">
            <div class="form-group">
              <label class="form-label">출발일</label>
              <input type="date" class="form-input" id="startDate" onchange="calcNights();setEndMin();validateStep(1);">
            </div>
            <div class="date-range-sep"></div>
            <div class="form-group">
              <label class="form-label">귀국일</label>
              <input type="date" class="form-input" id="endDate" onchange="calcNights();validateStep(1);">
            </div>
          </div>
          <p id="nightsInfo" style="font-size:13px;color:var(--point-blue);font-weight:700;margin-top:10px;min-height:18px;"></p>
        </div>

        <%-- ── 대표 이미지 ── --%>
        <div class="form-section">
          <p class="form-section-title"><span class="dot"></span> 대표 이미지 <span style="font-weight:400;color:var(--light);font-size:11px;">(선택)</span></p>
          <div class="thumb-section-wrap">
            <%-- 원형 프리뷰 --%>
            <div class="thumb-circle-wrap">
              <div class="thumb-circle" onclick="document.getElementById('thumbFileInput').click()">
                <img id="thumbPreviewImg"
                  src="${pageContext.request.contextPath}/dist/images/logo.png"
                  alt="대표 이미지"
                  onerror="this.src='${pageContext.request.contextPath}/dist/images/logo.png'">
                <div class="thumb-circle-overlay">📷</div>
              </div>
              <button class="thumb-x-btn" id="thumbXBtn" onclick="resetThumb()" title="기본 이미지로">✕</button>
            </div>
            <%-- 우측 버튼/안내 --%>
            <div class="thumb-right">
              <button class="thumb-pick-btn" onclick="document.getElementById('thumbFileInput').click()">
                📷 이미지 선택
              </button>
              <input type="file" id="thumbFileInput" accept="image/*" style="display:none" onchange="onThumbChange(event)">
              <p class="thumb-info-txt">JPG · PNG · WEBP · 최대 5MB</p>
            </div>
          </div>
        </div>

        <%-- ── 총 예산 ── --%>
        <div class="form-section">
          <p class="form-section-title"><span class="dot"></span> 총 예산 <span style="font-weight:400;color:var(--light);font-size:11px;">(선택)</span></p>
          <div class="budget-row">
            <span class="budget-sym">₩</span>
            <input type="text" inputmode="numeric" class="budget-num" id="totalBudget"
              placeholder="예상 예산을 입력하세요"
              oninput="onBudgetInput(this)">
            <span class="budget-won">원</span>
          </div>
          <p class="budget-preview-txt" id="budgetPreview"></p>
        </div>

        <div class="form-section">
          <p class="form-section-title"><span class="dot"></span> 여행 유형 <span style="font-weight:400;color:var(--light);font-size:11px;">(선택)</span></p>
          <div class="trip-type-grid" id="tripTypeGrid">
            <button type="button" class="trip-type-btn" data-val="COUPLE" onclick="selectTripType('COUPLE', this)">
              <span class="type-emoji">💑</span>
              <span class="type-label">커플</span>
            </button>
            <button type="button" class="trip-type-btn" data-val="FAMILY" onclick="selectTripType('FAMILY', this)">
              <span class="type-emoji">👨‍👩‍👧</span>
              <span class="type-label">가족</span>
            </button>
            <button type="button" class="trip-type-btn" data-val="FRIENDS" onclick="selectTripType('FRIENDS', this)">
              <span class="type-emoji">👫</span>
              <span class="type-label">친구</span>
            </button>
            <button type="button" class="trip-type-btn" data-val="SOLO" onclick="selectTripType('SOLO', this)">
              <span class="type-emoji">🙋</span>
              <span class="type-label">혼자</span>
            </button>
            <button type="button" class="trip-type-btn" data-val="BUSINESS" onclick="selectTripType('BUSINESS', this)">
              <span class="type-emoji">💼</span>
              <span class="type-label">비즈니스</span>
            </button>
          </div>
          <input type="hidden" id="tripType" value="">
        </div>

        <div class="form-section">
          <p class="form-section-title"><span class="dot"></span> 여행 테마</p>
          <div class="theme-chips" id="themeChips">
            <span class="theme-chip" onclick="toggleTheme(this)">#맛집탐방</span>
            <span class="theme-chip" onclick="toggleTheme(this)">#자연힐링</span>
            <span class="theme-chip" onclick="toggleTheme(this)">#역사문화</span>
            <span class="theme-chip" onclick="toggleTheme(this)">#액티비티</span>
            <span class="theme-chip" onclick="toggleTheme(this)">#카페투어</span>
            <span class="theme-chip" onclick="toggleTheme(this)">#쇼핑</span>
            <span class="theme-chip" onclick="toggleTheme(this)">#럭셔리</span>
            <span class="theme-chip" onclick="toggleTheme(this)">#가성비</span>
            <span class="theme-chip" onclick="toggleTheme(this)">#감성사진</span>
            <span class="theme-chip" onclick="toggleTheme(this)">#우정여행</span>
          </div>
          <div class="tag-input-wrap" id="customTagWrap" onclick="document.getElementById('tagInput').focus()">
            <span id="customTagList"></span>
            <input type="text" class="tag-text-input" id="tagInput"
              placeholder="직접 입력 후 Enter…" maxlength="15"
              onkeydown="handleTagInput(event)">
          </div>
          <p class="tag-hint">Enter 또는 쉼표(,)로 구분 · 최대 10개</p>
        </div>

        <div class="form-section">
          <p class="form-section-title"><span class="dot"></span> 공개 설정</p>
          <div class="visibility-row">
            <div>
              <div class="visibility-title" id="visibilityTitle">🔒 비공개 여행</div>
              <div class="visibility-desc"  id="visibilityDesc">초대된 동행자만 볼 수 있어요</div>
            </div>
            <label class="toggle-switch">
              <input type="checkbox" id="isPublic" onchange="onVisibilityChange()">
              <span class="toggle-slider"></span>
            </label>
          </div>
        </div>

      </div>

      <%-- STEP 3 --%>
      <div class="step-panel" id="panel2">
        <div class="confirm-card" id="confirmCard"></div>
        <div class="info-box">
          <span style="font-size:18px;flex-shrink:0;">💡</span>
          <span>일정을 생성하면 <strong>워크스페이스</strong>로 이동해요. 카카오맵에서 장소를 추가하고, 동행자를 초대해 함께 편집할 수 있어요!</span>
        </div>
      </div>

    </div><%-- /modal-body --%>

    <div class="modal-foot" id="modalFoot">
      <button class="btn-prev" id="btnPrev" onclick="prevStep()" style="visibility:hidden">← 이전</button>
      <button class="btn-next" id="btnNext" onclick="nextStep()" disabled>
        다음 <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round"><line x1="5" y1="12" x2="19" y2="12"/><polyline points="12 5 19 12 12 19"/></svg>
      </button>
    </div>

  </div>
</div>


<script>
var currentStep    = 0;
var TOTAL_STEPS    = 3;
var selectedCities = [];
var selectedRegionIds = [];
var customTags     = [];

var STEPS = [
  { label: 'STEP 1 OF 3', title: '어디로 떠날까요?'    },
  { label: 'STEP 2 OF 3', title: '여행 정보를 알려주세요' },
  { label: 'STEP 3 OF 3', title: '일정을 확인해요 ✨'   },
];

(function() {
  var today = new Date().toISOString().split('T')[0];
  document.getElementById('startDate').min = today;
  document.getElementById('endDate').min   = today;
})();

/* ── OPEN / CLOSE ── */
function openCreateModal() {
  document.getElementById('createOverlay').classList.add('active');
  document.body.style.overflow = 'hidden';
  goToStep(0);
}
function closeCreateModal() {
  document.getElementById('createOverlay').classList.remove('active');
  document.body.style.overflow = '';
}
document.getElementById('createOverlay').addEventListener('click', function(e) {
  if (e.target === this) closeCreateModal();
});

/* ── 스텝 ── */
function goToStep(step) {
  document.querySelectorAll('.step-panel').forEach(function(p, i) {
    p.classList.toggle('active', i === step);
  });
  document.querySelectorAll('.step-dot').forEach(function(d, i) {
    d.classList.toggle('active', i <= step);
  });
  document.getElementById('stepLabel').textContent   = STEPS[step].label;
  document.getElementById('modalTitle').textContent  = STEPS[step].title;

  var btnPrev = document.getElementById('btnPrev');
  var btnNext = document.getElementById('btnNext');
  var foot    = document.getElementById('modalFoot');

  btnPrev.style.visibility = step === 0 ? 'hidden' : 'visible';

  if (step === TOTAL_STEPS - 1) {
    btnNext.style.display = 'none';
    if (!document.getElementById('btnCreate')) {
      var btn = document.createElement('button');
      btn.id = 'btnCreate'; btn.className = 'btn-create';
      btn.innerHTML = '✈️ 일정 만들기';
      btn.onclick = createTrip;
      foot.appendChild(btn);
    }
    document.getElementById('btnCreate').style.display = 'flex';
    buildConfirmCard();
  } else {
    btnNext.style.display = 'flex';
    var bc = document.getElementById('btnCreate');
    if (bc) bc.style.display = 'none';
  }
  validateStep(step);
  currentStep = step;
}
function nextStep() { if (currentStep < TOTAL_STEPS - 1) goToStep(currentStep + 1); }
function prevStep() { if (currentStep > 0) goToStep(currentStep - 1); }

function validateStep(step) {
  var btn = document.getElementById('btnNext');
  if (step === 0) {
    btn.disabled = selectedCities.length === 0;
  } else if (step === 1) {
    var title = document.getElementById('tripTitle').value.trim();
    var start = document.getElementById('startDate').value;
    var end   = document.getElementById('endDate').value;
    btn.disabled = !(title && start && end && start <= end);
  } else {
    btn.disabled = false;
  }
}
document.addEventListener('input',  function(e) { if (['tripTitle','startDate','endDate'].indexOf(e.target.id) !== -1) validateStep(1); });
document.addEventListener('change', function(e) { if (['startDate','endDate'].indexOf(e.target.id) !== -1) validateStep(1); });

/* ── STEP 1 ── */
function toggleCity(name, el) {
  var idx = selectedCities.indexOf(name);
  if (idx === -1) { selectedCities.push(name); el.classList.add('selected'); }
  else { selectedCities.splice(idx, 1); el.classList.remove('selected'); }
  renderCityTags(); validateStep(0);
}
function renderCityTags() {
  document.getElementById('selectedTagsWrap').innerHTML =
    selectedCities.map(function(c) {
      return '<span class="city-tag">' + c +
        '<button onclick="removeCity(\'' + c + '\')" aria-label="' + c + ' 제거">✕</button></span>';
    }).join('');
}
function removeCity(name) {
  selectedCities = selectedCities.filter(function(c) { return c !== name; });
  document.querySelectorAll('.city-chip').forEach(function(el) {
    if (el.querySelector('.city-name').textContent === name) el.classList.remove('selected');
  });
  renderCityTags(); validateStep(0);
}

/* ── STEP 2 ── */
function calcNights() {
  var s = document.getElementById('startDate').value;
  var e = document.getElementById('endDate').value;
  var el = document.getElementById('nightsInfo');
  if (s && e && s <= e) {
    var nights = Math.round((new Date(e) - new Date(s)) / 86400000);
    el.style.color = 'var(--point-blue)';
    el.textContent = nights === 0 ? '당일치기 여행이에요 🌤️' : (nights + '박 ' + (nights+1) + '일 여행이에요 🌙');
  } else if (s && e && s > e) {
    el.style.color = '#FC8181';
    el.textContent = '⚠️ 귀국일이 출발일보다 빠를 수 없어요';
  } else {
    el.textContent = '';
  }
}
function setEndMin() {
  var s = document.getElementById('startDate').value;
  if (s) document.getElementById('endDate').min = s;
}
function toggleTheme(el) { el.classList.toggle('active'); }
function getThemes() {
  var chips = Array.from(document.querySelectorAll('.theme-chip.active')).map(function(e) { return e.textContent; });
  return chips.concat(customTags);
}
function handleTagInput(e) {
  if (e.key === 'Enter' || e.key === ',') {
    e.preventDefault();
    var val = e.target.value.trim().replace(/,/g,'');
    if (val && getThemes().length < 10) addCustomTag(val);
    e.target.value = '';
  } else if (e.key === 'Backspace' && e.target.value === '' && customTags.length > 0) {
    customTags.pop(); renderCustomTags();
  }
}
function addCustomTag(name) {
  var tag = name.startsWith('#') ? name : '#' + name;
  if (!customTags.includes(tag)) { customTags.push(tag); renderCustomTags(); }
}
function removeCustomTag(name) {
  customTags = customTags.filter(function(t) { return t !== name; });
  renderCustomTags();
}
function renderCustomTags() {
  document.getElementById('customTagList').innerHTML =
    customTags.map(function(t) {
      return '<span class="custom-tag">' + t +
        '<button onclick="removeCustomTag(\'' + t + '\')">✕</button></span>';
    }).join('');
}
function onVisibilityChange() {
  var pub = document.getElementById('isPublic').checked;
  document.getElementById('visibilityTitle').textContent = pub ? '🌐 공개 여행' : '🔒 비공개 여행';
  document.getElementById('visibilityDesc').textContent  = pub ? '다른 사용자에게 노출되고 추천될 수 있어요' : '초대된 동행자만 볼 수 있어요';
}

/* ── STEP 3 ── */
var selectedTripType = '';

function selectTripType(val, el) {
  selectedTripType = val;
  document.getElementById('tripType').value = val;
  document.querySelectorAll('.trip-type-btn').forEach(function(b) { b.classList.remove('selected'); });
  el.classList.add('selected');
}

function onBudgetInput(input) {
  // 숫자 외 문자 제거 후 쉼표 포맷
  var raw = input.value.replace(/[^0-9]/g, '');
  input.dataset.raw = raw;
  if (raw === '') { input.value = ''; document.getElementById('budgetPreview').textContent = ''; return; }
  var n = parseInt(raw, 10);
  // input 표시값은 쉼표 없이 (number inputmode) - 미리보기로만 표시
  document.getElementById('budgetPreview').textContent = raw ? '≈ ' + n.toLocaleString() + '원' : '';
}

function onThumbChange(event) {
  var file = event.target.files[0];
  if (!file) return;
  if (file.size > 5 * 1024 * 1024) { alert('이미지 크기는 5MB 이하여야 해요'); return; }
  var reader = new FileReader();
  reader.onload = function(e) {
    document.getElementById('thumbPreviewImg').src = e.target.result;
    document.getElementById('thumbXBtn').classList.add('visible');
  };
  reader.readAsDataURL(file);
}

function resetThumb() {
  var ctx = '${pageContext.request.contextPath}';
  document.getElementById('thumbPreviewImg').src = ctx + '/dist/images/logo.png';
  document.getElementById('thumbFileInput').value = '';
  document.getElementById('thumbXBtn').classList.remove('visible');
}

function buildConfirmCard() {
  var title    = document.getElementById('tripTitle').value;
  var desc     = document.getElementById('tripDescription').value.trim();
  var start    = document.getElementById('startDate').value;
  var end      = document.getElementById('endDate').value;
  var typeLabels = { COUPLE:'💑 커플', FAMILY:'👨‍👩‍👧 가족', FRIENDS:'👫 친구', SOLO:'🙋 혼자', BUSINESS:'💼 비즈니스' };
  var typeText = selectedTripType ? (typeLabels[selectedTripType] || selectedTripType) : '미선택';
  var themes   = getThemes();
  var nights   = Math.round((new Date(end) - new Date(start)) / 86400000);
  var nightText = nights === 0 ? '당일치기' : (nights + '박 ' + (nights+1) + '일');
  var isPublic  = document.getElementById('isPublic').checked;
  var budgetInput = document.getElementById('totalBudget');
  var budget = budgetInput.dataset.raw || budgetInput.value.replace(/[^0-9]/g,'');

  // 썸네일 원형 미리보기
  var thumbSrc = document.getElementById('thumbPreviewImg').src;
  var thumbHtml = '<img src="' + thumbSrc + '" class="confirm-thumb-circle" style="width:56px;height:56px;border-radius:50%;object-fit:cover;border:2px solid #E2E8F0;">';

  var tagsHtml = themes.length
    ? '<div class="tag-list">' + themes.map(function(t){ return '<span class="mini-tag">' + t + '</span>'; }).join('') + '</div>'
    : '선택 없음';
  var pubBadge = isPublic
    ? '<span class="badge-public">공개</span>'
    : '<span class="badge-private">비공개</span>';
  var budgetHtml = (budget && parseInt(budget) > 0)
    ? '<span style="font-weight:700;color:var(--point-blue);">₩ ' + parseInt(budget).toLocaleString() + '원</span>'
    : '<span style="color:var(--light);">미설정</span>';

  function row(k, v) {
    return '<div class="confirm-row"><span class="confirm-key">' + k + '</span><span class="confirm-val">' + v + '</span></div>';
  }
  var rows =
    row('대표 이미지', thumbHtml) +
    row('여행 제목', title) +
    row('여행지',    selectedCities.join(', ') || '미선택') +
    row('일정',      start + ' → ' + end + '<br><span style="color:var(--point-blue);font-size:13px;">' + nightText + '</span>') +
    row('여행 유형', typeText) +
    row('예상 예산', budgetHtml) +
    row('테마',      tagsHtml) +
    row('공개 여부', pubBadge);
  if (desc) rows += row('여행 설명', '<span style="font-size:13px;font-weight:500;color:var(--mid);word-break:keep-all;">' + desc + '</span>');
  document.getElementById('confirmCard').innerHTML = rows;
}

/* ── 여행 생성 ── */
function createTrip() {
  var thumbFile   = document.getElementById('thumbFileInput').files[0];
  var budgetInput = document.getElementById('totalBudget');
  var budgetVal   = budgetInput.dataset.raw || budgetInput.value.replace(/[^0-9]/g,'');
  var totalBudget = (budgetVal && parseInt(budgetVal) > 0) ? parseInt(budgetVal) : null;

  // 로딩 UI 전환
  document.querySelectorAll('.step-panel').forEach(function(p) { p.classList.remove('active'); });
  document.getElementById('creatingView').classList.add('active');
  document.getElementById('modalFoot').style.display = 'none';
  document.getElementById('stepIndicator').style.display = 'none';
  document.getElementById('errorBox').classList.remove('active');

  var icons = ['🖼️','🏗️','📅','🏷️'];
  [1,2,3,4].forEach(function(i, idx) {
    setTimeout(function() {
      document.getElementById('ci' + i).textContent = icons[idx];
      document.getElementById('cs' + i).classList.add('done');
    }, idx * 450);
  });

  function doCreate(thumbnailBase64) {
    var payload = {
      regionId:        selectedRegionIds,
      cities:          selectedCities,
      startDate:       document.getElementById('startDate').value,
      title:           document.getElementById('tripTitle').value.trim(),
      endDate:         document.getElementById('endDate').value,
      tripType:        selectedTripType || null,
      tags:            getThemes(),
      isPublic:        document.getElementById('isPublic').checked ? 1 : 0,
      description:     document.getElementById('tripDescription').value.trim(),
      totalBudget:     totalBudget,
      thumbnailBase64: thumbnailBase64   // null → 서버에서 기본 이미지 경로 적용
    };

    fetch('${pageContext.request.contextPath}/trip/create', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json', 'X-Requested-With': 'XMLHttpRequest' },
      body: JSON.stringify(payload)
    })
    .then(function(res) {
      if (!res.ok) throw new Error('서버 오류 (' + res.status + ')');
      return res.json();
    })
    .then(function(data) {
      if (!data.success) throw new Error(data.message || '생성에 실패했습니다');
      setTimeout(function() {
        location.href = '${pageContext.request.contextPath}/trip/' + data.tripId + '/workspace';
      }, 1800);
    })
    .catch(function(err) {
      document.getElementById('creatingView').classList.remove('active');
      document.querySelectorAll('.step-panel').forEach(function(p, i) { p.classList.toggle('active', i === 2); });
      document.getElementById('modalFoot').style.display = 'flex';
      document.getElementById('stepIndicator').style.display = 'flex';
      var eb = document.getElementById('errorBox');
      eb.textContent = '⚠️ ' + err.message;
      eb.classList.add('active');
      [1,2,3,4].forEach(function(i) {
        document.getElementById('ci' + i).textContent = '⏳';
        document.getElementById('cs' + i).classList.remove('done');
      });
    });
  }

  // 썸네일 파일 있으면 base64로 변환 후 전송, 없으면 바로 전송
  if (thumbFile) {
    var reader = new FileReader();
    reader.onload = function(e) {
      doCreate(e.target.result); // data:image/...;base64,... 형태
    };
    reader.readAsDataURL(thumbFile);
  } else {
    doCreate(null); // 서버에서 기본 이미지 경로 사용
  }
}
</script>
