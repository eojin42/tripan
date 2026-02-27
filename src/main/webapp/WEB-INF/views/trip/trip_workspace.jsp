<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%
  String tripTitle  = "제주 힐링 여행 🍊";
  String tripDates  = "2026.03.10 → 2026.03.13";
  String tripNights = "3박 4일";
  int    dayCount   = 4;
%>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title><%= tripTitle %> - Tripan 워크스페이스</title>
<%-- [DB Connect] 실제: String tripTitle = (String) request.getAttribute("tripTitle"); --%>

<link href="https://fonts.googleapis.com/css2?family=Pretendard:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
</head>
<body>

<style>
/* ═══════════════════════════════════════════
   TOKENS
═══════════════════════════════════════════ */
:root {
  --ice:        #A8C8E1;
  --orchid:     #C2B8D9;
  --rose:       #E0BBC2;
  --blue:       #89CFF0;
  --pink:       #FFB6C1;
  --dark:       #1A202C;
  --mid:        #4A5568;
  --light:      #A0AEC0;
  --white:      #FFFFFF;
  --bg:         #F7F9FC;
  --border:     #E2E8F0;
  --sidebar-w:  360px;
  --topbar-h:   64px;
  --grad:       linear-gradient(120deg, var(--ice), var(--orchid), var(--rose));
  --grad2:      linear-gradient(135deg, var(--blue), var(--pink));
  --ease:       cubic-bezier(0.19,1,0.22,1);
  --shadow:     0 4px 24px rgba(0,0,0,0.08);
  --shadow-lg:  0 12px 40px rgba(0,0,0,0.12);
}
*,*::before,*::after { box-sizing:border-box; margin:0; padding:0; }
html, body { 
  height: 100%; 
  overflow: hidden; 
  font-family:'Pretendard',sans-serif; 
  background:var(--bg); 
  color:var(--dark); 
}

/* ═══════════════════════════════════════════
   TOPBAR
═══════════════════════════════════════════ */
.ws-topbar {
  position: fixed;
  top: 0; left: 0; right: 0;
  height: var(--topbar-h);
  background: var(--white);
  border-bottom: 1px solid var(--border);
  display: flex;
  align-items: center;
  padding: 0 20px;
  gap: 16px;
  z-index: 200;
  box-shadow: 0 2px 12px rgba(0,0,0,0.04);
}
.ws-topbar__back {
  width: 36px; height: 36px;
  border: 1.5px solid var(--border);
  border-radius: 10px;
  background: transparent;
  display: flex; align-items: center; justify-content: center;
  cursor: pointer;
  color: var(--mid);
  transition: all .2s;
  flex-shrink: 0;
  text-decoration: none;
}
.ws-topbar__back:hover { background: var(--bg); border-color: var(--blue); color: var(--blue); }
.ws-topbar__info { flex: 1; min-width: 0; }
.ws-topbar__title {
  font-size: 16px; font-weight: 800; color: var(--dark);
  white-space: nowrap; overflow: hidden; text-overflow: ellipsis;
}
.ws-topbar__sub { font-size: 12px; color: var(--light); font-weight: 500; margin-top: 1px; }

.ws-topbar__actions { display: flex; align-items: center; gap: 10px; flex-shrink: 0; }

.live-badge {
  display: flex; align-items: center; gap: 6px;
  padding: 6px 12px;
  background: #F0FFF4;
  border: 1px solid #9AE6B4;
  border-radius: 50px;
  font-size: 12px; font-weight: 700; color: #276749;
}
.live-dot {
  width: 7px; height: 7px; border-radius: 50%;
  background: #48BB78;
  animation: pulse 1.5s ease infinite;
}
@keyframes pulse { 0%,100%{opacity:1;transform:scale(1)} 50%{opacity:.6;transform:scale(1.3)} }

.avatar-group { display: flex; }
.avatar {
  width: 30px; height: 30px; border-radius: 50%;
  border: 2px solid var(--white);
  margin-left: -8px;
  background: var(--grad2);
  display: flex; align-items: center; justify-content: center;
  font-size: 11px; font-weight: 800; color: white;
  cursor: pointer;
  transition: transform .2s;
}
.avatar:first-child { margin-left: 0; }
.avatar:hover { transform: translateY(-3px); z-index: 1; }
.avatar-add {
  background: var(--bg);
  border: 1.5px dashed var(--border);
  color: var(--light);
  font-size: 16px;
}
.avatar-add:hover { border-color: var(--blue); color: var(--blue); background: #EBF8FF; }

.btn-save {
  padding: 8px 20px;
  background: var(--grad2);
  border: none; border-radius: 50px;
  color: white; font-family: 'Pretendard',sans-serif;
  font-size: 13px; font-weight: 800;
  cursor: pointer;
  box-shadow: 0 4px 14px rgba(137,207,240,.4);
  transition: all .3s var(--ease);
}
.btn-save:hover { transform: translateY(-2px); box-shadow: 0 8px 20px rgba(137,207,240,.5); }

/* 탭 */
.ws-tabs {
  display: flex; gap: 4px;
  background: var(--bg);
  border: 1px solid var(--border);
  border-radius: 10px;
  padding: 3px;
}
.ws-tab {
  padding: 5px 14px;
  border: none; background: transparent;
  border-radius: 8px;
  font-family: 'Pretendard',sans-serif;
  font-size: 12px; font-weight: 700;
  color: var(--light); cursor: pointer;
  transition: all .2s;
  white-space: nowrap;
}
.ws-tab.active { background: var(--white); color: var(--dark); box-shadow: var(--shadow); }

/* ═══════════════════════════════════════════
   LAYOUT
═══════════════════════════════════════════ */
.ws-layout {
  position: fixed;
  top: var(--topbar-h); left: 0; right: 0; bottom: 0;
  display: flex;
}

/* ═══════════════════════════════════════════
   LEFT SIDEBAR — 일정
═══════════════════════════════════════════ */
.ws-sidebar {
  width: var(--sidebar-w);
  flex-shrink: 0;
  background: var(--white);
  border-right: 1px solid var(--border);
  display: flex;
  flex-direction: column;
  overflow: hidden;
}

/* 사이드바 탭 패널 */
.sidebar-panel { display: none; flex-direction: column; flex: 1; overflow: hidden; }
.sidebar-panel.active { display: flex; }

/* 일정 패널 */
.schedule-scroll {
  flex: 1; overflow-y: auto;
  padding: 16px;
  scrollbar-width: thin;
  scrollbar-color: var(--border) transparent;
}

/* Day 섹션 */
.day-section { margin-bottom: 24px; }
.day-header {
  display: flex; align-items: center; justify-content: space-between;
  margin-bottom: 12px;
  position: sticky; top: 0;
  background: var(--white);
  padding: 6px 0;
  z-index: 10;
}
.day-badge {
  display: inline-flex; align-items: center; gap: 8px;
  padding: 5px 14px 5px 10px;
  background: var(--grad2);
  border-radius: 50px;
  color: white;
  font-size: 12px; font-weight: 800;
}
.day-badge .day-num { font-size: 18px; font-weight: 900; line-height: 1; }
.day-date { font-size: 11px; color: var(--light); font-weight: 600; }

.btn-add-place {
  padding: 5px 12px;
  border: 1.5px dashed var(--border);
  border-radius: 50px;
  background: transparent;
  font-family: 'Pretendard',sans-serif;
  font-size: 11px; font-weight: 700; color: var(--light);
  cursor: pointer;
  transition: all .2s;
}
.btn-add-place:hover { border-color: var(--blue); color: var(--blue); background: #EBF8FF; }

/* 장소 카드 */
.place-list { display: flex; flex-direction: column; gap: 8px; }

.place-card {
  display: flex; align-items: flex-start; gap: 10px;
  padding: 12px 14px;
  background: var(--bg);
  border: 1.5px solid transparent;
  border-radius: 14px;
  cursor: grab;
  transition: all .2s var(--ease);
  position: relative;
}
.place-card:hover { border-color: var(--border); background: var(--white); box-shadow: var(--shadow); }
.place-card.dragging { opacity: .5; border-color: var(--blue); box-shadow: var(--shadow-lg); }
.place-card.drag-over { border-color: var(--pink); background: #FFF5F7; }

.place-num {
  width: 26px; height: 26px; border-radius: 50%;
  background: var(--grad2);
  color: white; font-size: 12px; font-weight: 900;
  display: flex; align-items: center; justify-content: center;
  flex-shrink: 0;
}
.place-info { flex: 1; min-width: 0; }
.place-name { font-size: 14px; font-weight: 700; color: var(--dark); margin-bottom: 3px; }
.place-addr { font-size: 11px; color: var(--light); white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
.place-type-badge {
  font-size: 10px; font-weight: 700; letter-spacing: 1px;
  padding: 2px 8px; border-radius: 50px;
  background: rgba(137,207,240,.15); color: var(--blue);
}
.place-type-badge.eat  { background: rgba(255,182,193,.15); color: #E8849A; }
.place-type-badge.stay { background: rgba(194,184,217,.15); color: #8B7BAE; }

.place-actions { display: flex; gap: 4px; opacity: 0; transition: opacity .2s; }
.place-card:hover .place-actions { opacity: 1; }
.place-action-btn {
  width: 26px; height: 26px; border-radius: 8px;
  border: none; background: var(--white);
  cursor: pointer; color: var(--light);
  display: flex; align-items: center; justify-content: center;
  font-size: 14px; transition: all .15s;
}
.place-action-btn:hover { background: var(--bg); color: var(--dark); }

/* 메모 칩 */
.memo-chip {
  display: flex; align-items: center; gap: 6px;
  margin-top: 6px; padding: 5px 10px;
  background: rgba(255,182,193,.12);
  border-radius: 8px;
  font-size: 11px; color: var(--mid);
}
.memo-chip svg { flex-shrink: 0; color: var(--pink); }

/* 장소 추가 드롭존 */
.drop-zone {
  border: 1.5px dashed var(--border);
  border-radius: 14px;
  padding: 14px;
  text-align: center;
  color: var(--light);
  font-size: 12px; font-weight: 600;
  cursor: pointer;
  transition: all .2s;
  margin-top: 8px;
}
.drop-zone:hover { border-color: var(--blue); color: var(--blue); background: #EBF8FF; }

/* ── 체크리스트 패널 ── */
.checklist-panel-inner { flex: 1; overflow-y: auto; padding: 16px; }
.checklist-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 16px; }
.checklist-title { font-size: 15px; font-weight: 800; }
.btn-add-check {
  padding: 6px 14px; border: none;
  background: var(--grad2); border-radius: 50px;
  color: white; font-family: 'Pretendard',sans-serif;
  font-size: 12px; font-weight: 700; cursor: pointer;
}
.check-category { margin-bottom: 20px; }
.check-cat-label { font-size: 11px; font-weight: 800; color: var(--light); letter-spacing: 2px; text-transform: uppercase; margin-bottom: 10px; display: block; }
.check-item {
  display: flex; align-items: center; gap: 10px;
  padding: 10px 12px; border-radius: 12px;
  cursor: pointer; transition: background .15s;
  margin-bottom: 4px;
}
.check-item:hover { background: var(--bg); }
.check-item input[type=checkbox] { width: 18px; height: 18px; accent-color: var(--blue); cursor: pointer; flex-shrink: 0; }
.check-item label { font-size: 14px; font-weight: 500; color: var(--dark); cursor: pointer; flex: 1; }
.check-item.done label { text-decoration: line-through; color: var(--light); }
.check-by { font-size: 11px; color: var(--light); }

/* ── 가계부 패널 ── */
.expense-panel-inner { flex: 1; overflow-y: auto; padding: 16px; }
.expense-summary {
  background: var(--grad2);
  border-radius: 16px;
  padding: 20px;
  color: white;
  margin-bottom: 20px;
}
.expense-summary__label { font-size: 11px; font-weight: 700; opacity: .8; letter-spacing: 2px; text-transform: uppercase; }
.expense-summary__amount { font-size: 32px; font-weight: 900; margin: 4px 0 12px; letter-spacing: -1px; }
.expense-summary__split { font-size: 13px; opacity: .9; }
.expense-cats { display: grid; grid-template-columns: 1fr 1fr; gap: 8px; margin-bottom: 20px; }
.expense-cat {
  background: var(--bg); border-radius: 12px; padding: 12px;
  display: flex; flex-direction: column; gap: 4px;
}
.expense-cat__icon { font-size: 20px; }
.expense-cat__name { font-size: 11px; color: var(--light); font-weight: 600; }
.expense-cat__amt { font-size: 15px; font-weight: 800; color: var(--dark); }
.expense-list-title { font-size: 13px; font-weight: 800; color: var(--mid); margin-bottom: 10px; }
.expense-item {
  display: flex; align-items: center; gap: 10px;
  padding: 10px 12px; border-radius: 12px; background: var(--bg); margin-bottom: 6px;
}
.expense-item__icon { font-size: 18px; }
.expense-item__info { flex: 1; }
.expense-item__name { font-size: 13px; font-weight: 700; }
.expense-item__detail { font-size: 11px; color: var(--light); }
.expense-item__amt { font-size: 14px; font-weight: 800; color: var(--dark); }
.btn-add-expense {
  width: 100%; padding: 12px; border: 1.5px dashed var(--border);
  border-radius: 12px; background: transparent;
  font-family: 'Pretendard',sans-serif; font-size: 13px; font-weight: 700;
  color: var(--light); cursor: pointer; transition: all .2s;
  margin-top: 8px;
}
.btn-add-expense:hover { border-color: var(--blue); color: var(--blue); background: #EBF8FF; }

/* ── 투표 패널 ── */
.vote-panel-inner { flex: 1; overflow-y: auto; padding: 16px; }
.vote-card { background: var(--white); border: 1.5px solid var(--border); border-radius: 16px; padding: 16px; margin-bottom: 12px; }
.vote-card__title { font-size: 14px; font-weight: 800; margin-bottom: 4px; }
.vote-card__sub { font-size: 11px; color: var(--light); margin-bottom: 14px; }
.vote-option { margin-bottom: 10px; }
.vote-option__top { display: flex; justify-content: space-between; align-items: center; margin-bottom: 5px; }
.vote-option__name { font-size: 13px; font-weight: 600; }
.vote-option__pct { font-size: 12px; font-weight: 800; color: var(--blue); }
.vote-bar-bg { height: 8px; background: var(--bg); border-radius: 50px; overflow: hidden; }
.vote-bar-fill { height: 100%; background: var(--grad2); border-radius: 50px; transition: width .6s var(--ease); }
.btn-vote {
  width: 100%; margin-top: 12px; padding: 10px;
  border: 1.5px solid var(--border); border-radius: 10px;
  background: transparent; font-family: 'Pretendard',sans-serif;
  font-size: 12px; font-weight: 700; color: var(--mid); cursor: pointer; transition: all .2s;
}
.btn-vote:hover { border-color: var(--blue); color: var(--blue); }
.btn-vote.voted { background: var(--grad2); border-color: transparent; color: white; }

/* ═══════════════════════════════════════════
   MAP AREA
═══════════════════════════════════════════ */
.ws-map-area { flex: 1; position: relative; overflow: hidden; }

#kakaoMap {
  width: 100%; height: 100%;
  background: #E8F0E8;
}

/* 지도 위 플로팅 컨트롤 */
.map-overlay-controls {
  position: absolute; top: 16px; right: 16px;
  display: flex; flex-direction: column; gap: 8px;
  z-index: 10;
}
.map-ctrl-btn {
  width: 40px; height: 40px;
  background: var(--white); border: none;
  border-radius: 12px; box-shadow: var(--shadow);
  display: flex; align-items: center; justify-content: center;
  cursor: pointer; color: var(--mid); font-size: 16px;
  transition: all .2s;
}
.map-ctrl-btn:hover { background: var(--blue); color: white; }

/* 장소 검색 오버레이 (상단 중앙) */
.map-search-bar {
  position: absolute; top: 16px; left: 50%;
  transform: translateX(-50%);
  width: min(460px, 80%);
  background: var(--white);
  border-radius: 14px;
  box-shadow: var(--shadow-lg);
  display: flex; align-items: center;
  padding: 0 16px;
  gap: 10px;
  z-index: 10;
  height: 48px;
}
.map-search-bar input {
  flex: 1; border: none; outline: none;
  font-family: 'Pretendard',sans-serif;
  font-size: 14px; font-weight: 500; color: var(--dark);
  background: transparent;
}
.map-search-bar input::placeholder { color: var(--light); }

/* 지도 범례 (Day 색상) */
.map-legend {
  position: absolute; bottom: 24px; left: 50%;
  transform: translateX(-50%);
  background: var(--white);
  border-radius: 50px; padding: 8px 20px;
  box-shadow: var(--shadow);
  display: flex; gap: 16px; align-items: center;
  z-index: 10;
}
.legend-item { display: flex; align-items: center; gap: 6px; font-size: 12px; font-weight: 700; color: var(--mid); }
.legend-dot { width: 10px; height: 10px; border-radius: 50%; }

/* 더미 지도 마커 (Kakao API 없을 때 표시) */
.dummy-map {
  width: 100%; height: 100%;
  background: linear-gradient(135deg, #e8f5e9 0%, #e3f2fd 50%, #fce4ec 100%);
  display: flex; flex-direction: column;
  align-items: center; justify-content: center;
  gap: 16px; color: var(--mid);
}
.dummy-map svg { opacity: .3; }
.dummy-map p { font-size: 14px; font-weight: 600; opacity: .5; }
.map-pin {
  position: absolute;
  display: flex; flex-direction: column; align-items: center;
  cursor: pointer; transition: transform .2s;
}
.map-pin:hover { transform: translateY(-4px); }
.map-pin__bubble {
  background: var(--grad2);
  color: white; font-size: 12px; font-weight: 800;
  padding: 4px 10px; border-radius: 20px;
  box-shadow: 0 4px 12px rgba(137,207,240,.5);
  white-space: nowrap;
}
.map-pin__tail { width: 2px; height: 10px; background: var(--blue); }

/* ═══════════════════════════════════════════
   MODALS
═══════════════════════════════════════════ */
.modal-overlay {
  display: none; position: fixed; inset: 0;
  background: rgba(26,32,44,.5);
  backdrop-filter: blur(4px);
  z-index: 500;
  align-items: center; justify-content: center;
}
.modal-overlay.open { display: flex; animation: fadein .2s ease; }
@keyframes fadein { from{opacity:0} to{opacity:1} }

.modal-box {
  background: var(--white); border-radius: 20px;
  width: min(480px, 95vw);
  box-shadow: 0 40px 80px rgba(0,0,0,.18);
  animation: slideup .3s var(--ease);
  overflow: hidden;
}
@keyframes slideup { from{opacity:0;transform:translateY(24px)} to{opacity:1;transform:translateY(0)} }

.modal-box__head {
  padding: 24px 24px 20px;
  border-bottom: 1px solid var(--border);
  display: flex; justify-content: space-between; align-items: center;
}
.modal-box__title { font-size: 17px; font-weight: 800; }
.modal-close-btn {
  width: 32px; height: 32px; border-radius: 50%;
  border: none; background: var(--bg); cursor: pointer;
  display: flex; align-items: center; justify-content: center;
  color: var(--mid); transition: all .2s; font-size: 16px;
}
.modal-close-btn:hover { background: #EDF2F7; transform: rotate(90deg); }
.modal-box__body { padding: 20px 24px 24px; }

/* 장소 추가 모달 */
.place-type-tabs { display: flex; gap: 6px; margin-bottom: 16px; }
.place-type-tab {
  flex: 1; padding: 8px; border: 1.5px solid var(--border);
  border-radius: 10px; background: transparent;
  font-family: 'Pretendard',sans-serif; font-size: 12px; font-weight: 700;
  cursor: pointer; transition: all .2s; text-align: center;
}
.place-type-tab.active { border-color: var(--blue); background: #EBF8FF; color: var(--blue); }

.search-input-wrap {
  position: relative; margin-bottom: 14px;
}
.search-input-wrap svg { position: absolute; left: 14px; top: 50%; transform: translateY(-50%); color: var(--light); }
.search-input-wrap input {
  width: 100%; padding: 12px 14px 12px 42px;
  border: 1.5px solid var(--border); border-radius: 12px;
  font-family: 'Pretendard',sans-serif; font-size: 14px; color: var(--dark);
  background: var(--bg); outline: none; transition: border-color .2s;
}
.search-input-wrap input:focus { border-color: var(--blue); background: var(--white); }

.place-results { max-height: 200px; overflow-y: auto; }
.place-result-item {
  display: flex; align-items: center; gap: 10px;
  padding: 10px 12px; border-radius: 12px; cursor: pointer; transition: background .15s;
}
.place-result-item:hover { background: var(--bg); }
.place-result-icon { width: 36px; height: 36px; border-radius: 10px; background: var(--grad2); display: flex; align-items: center; justify-content: center; font-size: 16px; flex-shrink: 0; }
.place-result-name { font-size: 14px; font-weight: 700; }
.place-result-addr { font-size: 11px; color: var(--light); }

/* 동행자 초대 모달 */
.invite-method { display: flex; gap: 8px; margin-bottom: 16px; }
.invite-btn {
  flex: 1; padding: 12px 8px; border: 1.5px solid var(--border);
  border-radius: 12px; background: transparent;
  font-family: 'Pretendard',sans-serif; font-size: 12px; font-weight: 700;
  cursor: pointer; transition: all .2s; text-align: center;
  display: flex; flex-direction: column; align-items: center; gap: 6px;
}
.invite-btn:hover { border-color: var(--blue); background: #EBF8FF; color: var(--blue); }
.invite-btn .invite-icon { font-size: 22px; }
.invite-link-box {
  display: flex; gap: 8px; align-items: center;
  background: var(--bg); border-radius: 12px; padding: 12px 14px;
}
.invite-link-box span { flex: 1; font-size: 13px; color: var(--mid); overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
.btn-copy {
  padding: 6px 14px; border: none; border-radius: 8px;
  background: var(--grad2); color: white;
  font-family: 'Pretendard',sans-serif; font-size: 12px; font-weight: 700; cursor: pointer;
  flex-shrink: 0;
}

/* 메모 모달 */
.form-label-sm { font-size: 12px; font-weight: 700; color: var(--mid); margin-bottom: 6px; display: block; }
textarea.form-textarea {
  width: 100%; padding: 12px 14px; height: 100px;
  border: 1.5px solid var(--border); border-radius: 12px;
  font-family: 'Pretendard',sans-serif; font-size: 14px; resize: none;
  outline: none; transition: border-color .2s; background: var(--bg);
}
textarea.form-textarea:focus { border-color: var(--blue); background: var(--white); }
.upload-zone {
  border: 1.5px dashed var(--border); border-radius: 12px; padding: 20px;
  text-align: center; cursor: pointer; transition: all .2s;
  margin-top: 12px;
}
.upload-zone:hover { border-color: var(--blue); background: #EBF8FF; }
.upload-zone p { font-size: 13px; color: var(--light); font-weight: 600; margin-top: 6px; }

.btn-primary {
  width: 100%; padding: 13px; border: none; border-radius: 12px;
  background: var(--grad2); color: white;
  font-family: 'Pretendard',sans-serif; font-size: 14px; font-weight: 800;
  cursor: pointer; margin-top: 16px;
  box-shadow: 0 6px 20px rgba(137,207,240,.4);
  transition: all .3s var(--ease);
}
.btn-primary:hover { transform: translateY(-2px); box-shadow: 0 10px 28px rgba(137,207,240,.5); }

/* ═══════════════════════════════════════════
   TOAST
═══════════════════════════════════════════ */
.toast-wrap { position: fixed; bottom: 24px; left: 50%; transform: translateX(-50%); z-index: 9999; display: flex; flex-direction: column; gap: 8px; pointer-events: none; }
.toast {
  padding: 12px 20px; background: var(--dark); color: white;
  border-radius: 50px; font-size: 13px; font-weight: 700;
  box-shadow: var(--shadow-lg); white-space: nowrap;
  animation: toastIn .3s var(--ease);
}
@keyframes toastIn { from{opacity:0;transform:translateY(16px)} to{opacity:1;transform:translateY(0)} }

/* 반응형 */
@media (max-width: 768px) {
  :root { --sidebar-w: 100vw; }
  .ws-layout { flex-direction: column; }
  .ws-sidebar { width: 100%; height: 50vh; border-right: none; border-bottom: 1px solid var(--border); }
  .ws-map-area { height: 50vh; }
  .ws-topbar__actions .live-badge,
  .ws-topbar__actions .avatar-group { display: none; }
}
</style>


<%-- ══════════ HTML ══════════ --%>

<%-- 탑바 --%>
<div class="ws-topbar">
  <a href="${pageContext.request.contextPath}/" class="ws-topbar__back" title="홈으로">
    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round"><line x1="19" y1="12" x2="5" y2="12"/><polyline points="12 19 5 12 12 5"/></svg>
  </a>

  <div class="ws-topbar__info">
    <div class="ws-topbar__title"><%= tripTitle %></div>
    <div class="ws-topbar__sub"><%= tripDates %> &nbsp;·&nbsp; <%= tripNights %></div>
  </div>

  <div class="ws-topbar__actions">
    <div class="live-badge">
      <span class="live-dot"></span>
      실시간 동기화
    </div>

    <div class="avatar-group" title="동행자">
      <div class="avatar" style="background:linear-gradient(135deg,#89CFF0,#A8C8E1)">나</div>
      <div class="avatar" style="background:linear-gradient(135deg,#FFB6C1,#E0BBC2)">지</div>
      <div class="avatar" style="background:linear-gradient(135deg,#C2B8D9,#A8C8E1)">민</div>
      <div class="avatar avatar-add" onclick="openModal('inviteModal')" title="동행자 초대">+</div>
    </div>

    <div class="ws-tabs">
      <button class="ws-tab active" onclick="switchPanel('schedule', this)">📅 일정</button>
      <button class="ws-tab" onclick="switchPanel('checklist', this)">✅ 체크</button>
      <button class="ws-tab" onclick="switchPanel('expense', this)">💸 가계부</button>
      <button class="ws-tab" onclick="switchPanel('vote', this)">🗳️ 투표</button>
    </div>

    <button class="btn-save" onclick="showToast('💾 저장되었어요!')">저장</button>
  </div>
</div>

<%-- 메인 레이아웃 --%>
<div class="ws-layout">

  <%-- ── 사이드바 ── --%>
  <aside class="ws-sidebar">

    <%-- 일정 패널 --%>
    <div class="sidebar-panel active" id="panel-schedule">
      <div class="schedule-scroll" id="scheduleScroll">

        <%-- Day 1 --%>
        <div class="day-section" id="day-1">
          <div class="day-header">
            <div class="day-badge">
              <span class="day-num">1</span>
              <span>DAY</span>
            </div>
            <span class="day-date">3월 10일 (화)</span>
            <button class="btn-add-place" onclick="openAddPlace(1)">+ 장소</button>
          </div>
          <div class="place-list" id="places-1">
            <div class="place-card" draggable="true" data-day="1" data-id="1">
              <div class="place-num">1</div>
              <div class="place-info">
                <div class="place-name">공항 → 숙소 이동</div>
                <div class="place-addr">제주국제공항 → 서귀포시</div>
                <span class="place-type-badge stay">🚗 이동</span>
              </div>
              <div class="place-actions">
                <button class="place-action-btn" onclick="openMemo(this)" title="메모">📝</button>
                <button class="place-action-btn" onclick="removePlace(this)" title="삭제">🗑</button>
              </div>
            </div>
            <div class="place-card" draggable="true" data-day="1" data-id="2">
              <div class="place-num">2</div>
              <div class="place-info">
                <div class="place-name">스테이 밤편지</div>
                <div class="place-addr">서귀포시 남원읍</div>
                <span class="place-type-badge stay">🏨 숙소</span>
                <div class="memo-chip">
                  <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"/></svg>
                  체크인 15:00 / 조식 포함
                </div>
              </div>
              <div class="place-actions">
                <button class="place-action-btn" onclick="openMemo(this)" title="메모">📝</button>
                <button class="place-action-btn" onclick="removePlace(this)" title="삭제">🗑</button>
              </div>
            </div>
            <div class="place-card" draggable="true" data-day="1" data-id="3">
              <div class="place-num">3</div>
              <div class="place-info">
                <div class="place-name">흑돼지거리 맛집</div>
                <div class="place-addr">제주시 연동</div>
                <span class="place-type-badge eat">🍽️ 식당</span>
              </div>
              <div class="place-actions">
                <button class="place-action-btn" onclick="openMemo(this)" title="메모">📝</button>
                <button class="place-action-btn" onclick="removePlace(this)" title="삭제">🗑</button>
              </div>
            </div>
          </div>
          <div class="drop-zone" onclick="openAddPlace(1)">
            <span>+ 장소 추가 또는 드래그</span>
          </div>
        </div>

        <%-- Day 2 --%>
        <div class="day-section" id="day-2">
          <div class="day-header">
            <div class="day-badge" style="background:linear-gradient(135deg,#C2B8D9,#E0BBC2)">
              <span class="day-num">2</span><span>DAY</span>
            </div>
            <span class="day-date">3월 11일 (수)</span>
            <button class="btn-add-place" onclick="openAddPlace(2)">+ 장소</button>
          </div>
          <div class="place-list" id="places-2">
            <div class="place-card" draggable="true" data-day="2" data-id="4">
              <div class="place-num" style="background:linear-gradient(135deg,#C2B8D9,#E0BBC2)">1</div>
              <div class="place-info">
                <div class="place-name">성산일출봉</div>
                <div class="place-addr">서귀포시 성산읍</div>
                <span class="place-type-badge">🏔️ 관광</span>
              </div>
              <div class="place-actions">
                <button class="place-action-btn" onclick="openMemo(this)" title="메모">📝</button>
                <button class="place-action-btn" onclick="removePlace(this)" title="삭제">🗑</button>
              </div>
            </div>
            <div class="place-card" draggable="true" data-day="2" data-id="5">
              <div class="place-num" style="background:linear-gradient(135deg,#C2B8D9,#E0BBC2)">2</div>
              <div class="place-info">
                <div class="place-name">카페 숨비소리</div>
                <div class="place-addr">서귀포시 성산읍</div>
                <span class="place-type-badge eat">☕ 카페</span>
                <div class="memo-chip">
                  <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"/></svg>
                  브레이크타임 15:00-16:00 주의!
                </div>
              </div>
              <div class="place-actions">
                <button class="place-action-btn" onclick="openMemo(this)" title="메모">📝</button>
                <button class="place-action-btn" onclick="removePlace(this)" title="삭제">🗑</button>
              </div>
            </div>
          </div>
          <div class="drop-zone" onclick="openAddPlace(2)">
            <span>+ 장소 추가 또는 드래그</span>
          </div>
        </div>

        <%-- Day 3 --%>
        <div class="day-section" id="day-3">
          <div class="day-header">
            <div class="day-badge" style="background:linear-gradient(135deg,#A8C8E1,#89CFF0)">
              <span class="day-num">3</span><span>DAY</span>
            </div>
            <span class="day-date">3월 12일 (목)</span>
            <button class="btn-add-place" onclick="openAddPlace(3)">+ 장소</button>
          </div>
          <div class="place-list" id="places-3">
            <div class="place-card" draggable="true" data-day="3" data-id="6">
              <div class="place-num" style="background:linear-gradient(135deg,#A8C8E1,#89CFF0)">1</div>
              <div class="place-info">
                <div class="place-name">우도 자전거 투어</div>
                <div class="place-addr">제주시 우도면</div>
                <span class="place-type-badge">🚲 액티비티</span>
              </div>
              <div class="place-actions">
                <button class="place-action-btn" onclick="openMemo(this)" title="메모">📝</button>
                <button class="place-action-btn" onclick="removePlace(this)" title="삭제">🗑</button>
              </div>
            </div>
          </div>
          <div class="drop-zone" onclick="openAddPlace(3)">
            <span>+ 장소 추가 또는 드래그</span>
          </div>
        </div>

      </div><%-- /schedule-scroll --%>
    </div><%-- /panel-schedule --%>

    <%-- 체크리스트 패널 --%>
    <div class="sidebar-panel" id="panel-checklist">
      <div class="checklist-panel-inner">
        <div class="checklist-header">
          <span class="checklist-title">여행 준비물 체크리스트</span>
          <button class="btn-add-check" onclick="showToast('항목 추가 기능 준비 중')">+ 추가</button>
        </div>
        <div class="check-category">
          <span class="check-cat-label">📋 서류 & 결제</span>
          <div class="check-item" onclick="toggleCheck(this)">
            <input type="checkbox" id="c1" checked><label for="c1">신분증</label><span class="check-by">나</span>
          </div>
          <div class="check-item done" onclick="toggleCheck(this)">
            <input type="checkbox" id="c2" checked><label for="c2">항공권 e-티켓</label><span class="check-by">나</span>
          </div>
          <div class="check-item" onclick="toggleCheck(this)">
            <input type="checkbox" id="c3"><label for="c3">숙소 예약 확인서</label><span class="check-by">지민</span>
          </div>
        </div>
        <div class="check-category">
          <span class="check-cat-label">👗 의류 & 용품</span>
          <div class="check-item" onclick="toggleCheck(this)">
            <input type="checkbox" id="c4"><label for="c4">여벌 옷 (3벌)</label><span class="check-by">나</span>
          </div>
          <div class="check-item" onclick="toggleCheck(this)">
            <input type="checkbox" id="c5"><label for="c5">우산 / 우비</label><span class="check-by">나</span>
          </div>
          <div class="check-item done" onclick="toggleCheck(this)">
            <input type="checkbox" id="c6" checked><label for="c6">선크림 SPF50+</label><span class="check-by">지민</span>
          </div>
          <div class="check-item" onclick="toggleCheck(this)">
            <input type="checkbox" id="c7"><label for="c7">카메라 + 충전기</label><span class="check-by">민준</span>
          </div>
        </div>
        <div class="check-category">
          <span class="check-cat-label">💊 의약품</span>
          <div class="check-item" onclick="toggleCheck(this)">
            <input type="checkbox" id="c8"><label for="c8">멀미약</label><span class="check-by">나</span>
          </div>
          <div class="check-item" onclick="toggleCheck(this)">
            <input type="checkbox" id="c9"><label for="c9">상비약 세트</label><span class="check-by">지민</span>
          </div>
        </div>
      </div>
    </div>

    <%-- 가계부 패널 --%>
    <div class="sidebar-panel" id="panel-expense">
      <div class="expense-panel-inner">
        <div class="expense-summary">
          <div class="expense-summary__label">총 지출</div>
          <div class="expense-summary__amount">₩ 287,500</div>
          <div class="expense-summary__split">3인 기준 &nbsp;→&nbsp; 1인당 약 <strong>₩ 95,833</strong></div>
        </div>
        <div class="expense-cats">
          <div class="expense-cat"><span class="expense-cat__icon">🏨</span><span class="expense-cat__name">숙소</span><span class="expense-cat__amt">₩ 120,000</span></div>
          <div class="expense-cat"><span class="expense-cat__icon">🍽️</span><span class="expense-cat__name">식비</span><span class="expense-cat__amt">₩ 87,500</span></div>
          <div class="expense-cat"><span class="expense-cat__icon">🚗</span><span class="expense-cat__name">교통</span><span class="expense-cat__amt">₩ 45,000</span></div>
          <div class="expense-cat"><span class="expense-cat__icon">🎯</span><span class="expense-cat__name">관광</span><span class="expense-cat__amt">₩ 35,000</span></div>
        </div>
        <div class="expense-list-title">최근 지출 내역</div>
        <div class="expense-item">
          <span class="expense-item__icon">🏨</span>
          <div class="expense-item__info"><div class="expense-item__name">스테이 밤편지</div><div class="expense-item__detail">3/10 · 나 결제</div></div>
          <span class="expense-item__amt">₩ 120,000</span>
        </div>
        <div class="expense-item">
          <span class="expense-item__icon">🍽️</span>
          <div class="expense-item__info"><div class="expense-item__name">흑돼지거리</div><div class="expense-item__detail">3/10 · 지민 결제</div></div>
          <span class="expense-item__amt">₩ 55,500</span>
        </div>
        <div class="expense-item">
          <span class="expense-item__icon">🚗</span>
          <div class="expense-item__info"><div class="expense-item__name">렌터카</div><div class="expense-item__detail">3/10 · 민준 결제</div></div>
          <span class="expense-item__amt">₩ 45,000</span>
        </div>
        <button class="btn-add-expense" onclick="showToast('💸 지출 추가 기능 연동 예정')">+ 지출 추가</button>
      </div>
    </div>

    <%-- 투표 패널 --%>
    <div class="sidebar-panel" id="panel-vote">
      <div class="vote-panel-inner">
        <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:16px;">
          <span style="font-size:15px;font-weight:800;">동행자 투표</span>
          <button style="padding:6px 14px;border:none;background:var(--grad2);border-radius:50px;color:white;font-family:'Pretendard',sans-serif;font-size:12px;font-weight:700;cursor:pointer;" onclick="showToast('투표 생성 기능 연동 예정')">+ 투표 만들기</button>
        </div>
        <div class="vote-card">
          <div class="vote-card__title">🍽️ Day2 저녁 어디서 먹을까요?</div>
          <div class="vote-card__sub">3명 참여 · 12시간 남음</div>
          <div class="vote-option">
            <div class="vote-option__top"><span class="vote-option__name">흑돼지 전문점 A</span><span class="vote-option__pct">67%</span></div>
            <div class="vote-bar-bg"><div class="vote-bar-fill" style="width:67%"></div></div>
          </div>
          <div class="vote-option">
            <div class="vote-option__top"><span class="vote-option__name">해물뚝배기 B</span><span class="vote-option__pct">33%</span></div>
            <div class="vote-bar-bg"><div class="vote-bar-fill" style="width:33%;background:linear-gradient(135deg,#C2B8D9,#E0BBC2)"></div></div>
          </div>
          <button class="btn-vote voted">✓ 흑돼지로 투표함</button>
        </div>
        <div class="vote-card">
          <div class="vote-card__title">🏄 Day3 오후 액티비티</div>
          <div class="vote-card__sub">2명 참여 · 진행 중</div>
          <div class="vote-option">
            <div class="vote-option__top"><span class="vote-option__name">서핑 체험</span><span class="vote-option__pct">50%</span></div>
            <div class="vote-bar-bg"><div class="vote-bar-fill" style="width:50%"></div></div>
          </div>
          <div class="vote-option">
            <div class="vote-option__top"><span class="vote-option__name">스노클링</span><span class="vote-option__pct">50%</span></div>
            <div class="vote-bar-bg"><div class="vote-bar-fill" style="width:50%;background:linear-gradient(135deg,#C2B8D9,#E0BBC2)"></div></div>
          </div>
          <button class="btn-vote" onclick="castVote(this)">투표하기</button>
        </div>
      </div>
    </div>

  </aside>

  <%-- ── 지도 영역 ── --%>
  <div class="ws-map-area">

    <%-- 지도 검색바 --%>
    <div class="map-search-bar">
      <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
      <input type="text" placeholder="장소, 주소 검색…" id="mapSearchInput">
      <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" style="color:var(--light);cursor:pointer" onclick="showToast('🗺️ 카카오맵 연동 후 검색 가능')"><line x1="22" y1="2" x2="11" y2="13"/><polygon points="22 2 15 22 11 13 2 9 22 2"/></svg>
    </div>

    <%-- 지도 컨테이너 (Kakao API 연동 전: 더미 지도) --%>
    <div id="kakaoMap">
      <div class="dummy-map">
        <%-- 더미 핀들 --%>
        <div class="map-pin" style="position:absolute;top:30%;left:35%">
          <div class="map-pin__bubble">1 공항</div>
          <div class="map-pin__tail"></div>
        </div>
        <div class="map-pin" style="position:absolute;top:55%;left:28%">
          <div class="map-pin__bubble" style="background:linear-gradient(135deg,#C2B8D9,#E0BBC2)">2 숙소</div>
          <div class="map-pin__tail" style="background:var(--orchid)"></div>
        </div>
        <div class="map-pin" style="position:absolute;top:42%;left:55%">
          <div class="map-pin__bubble">3 식당</div>
          <div class="map-pin__tail"></div>
        </div>
        <div class="map-pin" style="position:absolute;top:25%;left:65%">
          <div class="map-pin__bubble" style="background:linear-gradient(135deg,#C2B8D9,#E0BBC2)">Day2 성산일출봉</div>
          <div class="map-pin__tail" style="background:var(--orchid)"></div>
        </div>
        <div class="map-pin" style="position:absolute;top:65%;left:60%">
          <div class="map-pin__bubble" style="background:linear-gradient(135deg,#A8C8E1,#89CFF0)">Day3 우도</div>
          <div class="map-pin__tail" style="background:var(--ice)"></div>
        </div>
        <svg width="80" height="80" viewBox="0 0 24 24" fill="none" stroke="#A0AEC0" stroke-width="1"><circle cx="12" cy="10" r="3"/><path d="M12 21.7C17.3 17 20 13 20 10a8 8 0 1 0-16 0c0 3 2.7 6.9 8 11.7z"/></svg>
        <p>카카오맵 API 연동 후 실제 지도가 표시됩니다</p>
      </div>
    </div>

    <%-- 지도 컨트롤 버튼 --%>
    <div class="map-overlay-controls">
      <button class="map-ctrl-btn" title="내 위치" onclick="showToast('📍 내 위치 기능 연동 예정')">📍</button>
      <button class="map-ctrl-btn" title="전체 핀 보기" onclick="showToast('🗺️ 전체 경로 보기')">🗺️</button>
      <button class="map-ctrl-btn" title="확대" onclick="showToast('+')">+</button>
      <button class="map-ctrl-btn" title="축소" onclick="showToast('-')">−</button>
    </div>

    <%-- 범례 --%>
    <div class="map-legend">
      <div class="legend-item"><div class="legend-dot" style="background:linear-gradient(135deg,#89CFF0,#FFB6C1)"></div>Day 1</div>
      <div class="legend-item"><div class="legend-dot" style="background:linear-gradient(135deg,#C2B8D9,#E0BBC2)"></div>Day 2</div>
      <div class="legend-item"><div class="legend-dot" style="background:linear-gradient(135deg,#A8C8E1,#89CFF0)"></div>Day 3</div>
    </div>

  </div>
</div>

<%-- ══════════ MODALS ══════════ --%>

<%-- 장소 추가 모달 --%>
<div class="modal-overlay" id="addPlaceModal">
  <div class="modal-box">
    <div class="modal-box__head">
      <span class="modal-box__title">📍 장소 추가</span>
      <button class="modal-close-btn" onclick="closeModal('addPlaceModal')">✕</button>
    </div>
    <div class="modal-box__body">
      <div class="place-type-tabs">
        <button class="place-type-tab active" onclick="selectPlaceType(this,'all')">🔍 전체</button>
        <button class="place-type-tab" onclick="selectPlaceType(this,'eat')">🍽️ 맛집</button>
        <button class="place-type-tab" onclick="selectPlaceType(this,'tour')">🏔️ 관광</button>
        <button class="place-type-tab" onclick="selectPlaceType(this,'stay')">🏨 숙소</button>
        <button class="place-type-tab" onclick="selectPlaceType(this,'my')">⭐ 나만의</button>
      </div>
      <div class="search-input-wrap">
        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
        <input type="text" placeholder="장소명, 주소 검색…" id="placeSearchInput" oninput="searchPlace(this.value)">
      </div>
      <div class="place-results" id="placeResults">
        <div class="place-result-item" onclick="addPlaceToDay(this, '협재해수욕장', '제주시 한림읍')">
          <div class="place-result-icon">🏖️</div>
          <div><div class="place-result-name">협재해수욕장</div><div class="place-result-addr">제주시 한림읍 협재리</div></div>
        </div>
        <div class="place-result-item" onclick="addPlaceToDay(this, '한라산 어리목 코스', '제주시 해안동')">
          <div class="place-result-icon">🏔️</div>
          <div><div class="place-result-name">한라산 어리목 코스</div><div class="place-result-addr">제주시 해안동</div></div>
        </div>
        <div class="place-result-item" onclick="addPlaceToDay(this, '제주 올레시장', '제주시 이도2동')">
          <div class="place-result-icon">🛒</div>
          <div><div class="place-result-name">제주 올레시장</div><div class="place-result-addr">제주시 이도2동</div></div>
        </div>
        <div class="place-result-item" onclick="addPlaceToDay(this, '카페 봄날', '서귀포시 중문동')">
          <div class="place-result-icon">☕</div>
          <div><div class="place-result-name">카페 봄날</div><div class="place-result-addr">서귀포시 중문동</div></div>
        </div>
      </div>
    </div>
  </div>
</div>

<%-- 메모 & 첨부 모달 --%>
<div class="modal-overlay" id="memoModal">
  <div class="modal-box">
    <div class="modal-box__head">
      <span class="modal-box__title">📝 세부 메모 & 첨부</span>
      <button class="modal-close-btn" onclick="closeModal('memoModal')">✕</button>
    </div>
    <div class="modal-box__body">
      <label class="form-label-sm">메모</label>
      <textarea class="form-textarea" placeholder="브레이크타임 주의, 예약 필수 등 메모를 입력하세요…"></textarea>
      <div class="upload-zone" onclick="showToast('📎 파일 첨부 기능 연동 예정')">
        <svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" style="color:var(--light)"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="17 8 12 3 7 8"/><line x1="12" y1="3" x2="12" y2="15"/></svg>
        <p>e-티켓, 예약 바우처 이미지 첨부</p>
      </div>
      <button class="btn-primary" onclick="saveMemo()">저장</button>
    </div>
  </div>
</div>

<%-- 동행자 초대 모달 --%>
<div class="modal-overlay" id="inviteModal">
  <div class="modal-box">
    <div class="modal-box__head">
      <span class="modal-box__title">👥 동행자 초대</span>
      <button class="modal-close-btn" onclick="closeModal('inviteModal')">✕</button>
    </div>
    <div class="modal-box__body">
      <div class="invite-method">
        <button class="invite-btn" onclick="showToast('카카오톡 공유 연동 예정')">
          <span class="invite-icon">💬</span>카카오톡
        </button>
        <button class="invite-btn" onclick="copyInviteLink()">
          <span class="invite-icon">🔗</span>링크 복사
        </button>
        <button class="invite-btn" onclick="showToast('아이디 검색 연동 예정')">
          <span class="invite-icon">🔍</span>아이디 검색
        </button>
      </div>
      <label class="form-label-sm">초대 링크</label>
      <div class="invite-link-box">
        <span id="inviteLinkText">https://tripan.kr/invite/abc123xyz</span>
        <button class="btn-copy" onclick="copyInviteLink()">복사</button>
      </div>
      <p style="font-size:12px;color:var(--light);margin-top:12px;line-height:1.6;">
        링크를 받은 사람은 Tripan에 로그인 후 일정에 참여할 수 있어요.<br>
        일정 편집 권한은 방장이 개별로 설정할 수 있어요.
      </p>
    </div>
  </div>
</div>

<%-- 토스트 --%>
<div class="toast-wrap" id="toastWrap"></div>


<script>
/* ══════════════════════════════
   탭 전환
══════════════════════════════ */
function switchPanel(name, btn) {
  document.querySelectorAll('.sidebar-panel').forEach(function(p){ p.classList.remove('active'); });
  document.querySelectorAll('.ws-tab').forEach(function(t){ t.classList.remove('active'); });
  document.getElementById('panel-' + name).classList.add('active');
  btn.classList.add('active');
}

/* ══════════════════════════════
   모달
══════════════════════════════ */
function openModal(id) {
  document.getElementById(id).classList.add('open');
}
function closeModal(id) {
  document.getElementById(id).classList.remove('open');
}
document.querySelectorAll('.modal-overlay').forEach(function(el) {
  el.addEventListener('click', function(e) {
    if (e.target === this) this.classList.remove('open');
  });
});

/* ══════════════════════════════
   장소 추가
══════════════════════════════ */
var currentAddDay = 1;
function openAddPlace(day) {
  currentAddDay = day;
  openModal('addPlaceModal');
}
function selectPlaceType(btn, type) {
  document.querySelectorAll('.place-type-tab').forEach(function(t){ t.classList.remove('active'); });
  btn.classList.add('active');
  showToast('🔍 ' + type + ' 카테고리 필터 (카카오 API 연동 후 동작)');
}
function searchPlace(q) {
  if (!q) return;
  showToast('🔍 "' + q + '" 검색 중… (카카오 API 연동 예정)');
}
function addPlaceToDay(el, name, addr) {
  var list = document.getElementById('places-' + currentAddDay);
  var count = list.querySelectorAll('.place-card').length + 1;
  var colors = [
    'linear-gradient(135deg,#89CFF0,#FFB6C1)',
    'linear-gradient(135deg,#C2B8D9,#E0BBC2)',
    'linear-gradient(135deg,#A8C8E1,#89CFF0)'
  ];
  var color = colors[(currentAddDay - 1) % 3];
  var card = document.createElement('div');
  card.className = 'place-card';
  card.draggable = true;
  card.setAttribute('data-day', currentAddDay);
  card.innerHTML =
    '<div class="place-num" style="background:' + color + '">' + count + '</div>' +
    '<div class="place-info">' +
      '<div class="place-name">' + name + '</div>' +
      '<div class="place-addr">' + addr + '</div>' +
      '<span class="place-type-badge">📍 장소</span>' +
    '</div>' +
    '<div class="place-actions">' +
      '<button class="place-action-btn" onclick="openMemo(this)">📝</button>' +
      '<button class="place-action-btn" onclick="removePlace(this)">🗑</button>' +
    '</div>';
  initDrag(card);
  list.appendChild(card);
  closeModal('addPlaceModal');
  showToast('📍 ' + name + ' 추가됨!');
  renumberPlaces(currentAddDay);
}

/* ══════════════════════════════
   메모
══════════════════════════════ */
function openMemo(btn) {
  openModal('memoModal');
}
function saveMemo() {
  closeModal('memoModal');
  showToast('📝 메모 저장됨!');
}

/* ══════════════════════════════
   삭제
══════════════════════════════ */
function removePlace(btn) {
  var card = btn.closest('.place-card');
  var day = card.getAttribute('data-day');
  card.style.transition = 'opacity .3s, transform .3s';
  card.style.opacity = '0';
  card.style.transform = 'translateX(-20px)';
  setTimeout(function() {
    card.remove();
    renumberPlaces(day);
    showToast('🗑 장소 삭제됨');
  }, 300);
}
function renumberPlaces(day) {
  var cards = document.querySelectorAll('#places-' + day + ' .place-card');
  cards.forEach(function(card, i) {
    card.querySelector('.place-num').textContent = i + 1;
  });
}

/* ══════════════════════════════
   드래그 앤 드롭
══════════════════════════════ */
var dragging = null;
function initDrag(card) {
  card.addEventListener('dragstart', function() {
    dragging = this;
    setTimeout(function() { card.classList.add('dragging'); }, 0);
  });
  card.addEventListener('dragend', function() {
    this.classList.remove('dragging');
    dragging = null;
    document.querySelectorAll('.place-card').forEach(function(c){ c.classList.remove('drag-over'); });
  });
  card.addEventListener('dragover', function(e) {
    e.preventDefault();
    if (dragging && dragging !== this) this.classList.add('drag-over');
  });
  card.addEventListener('dragleave', function() { this.classList.remove('drag-over'); });
  card.addEventListener('drop', function(e) {
    e.preventDefault();
    this.classList.remove('drag-over');
    if (dragging && dragging !== this) {
      var list = this.parentNode;
      var allCards = Array.from(list.querySelectorAll('.place-card'));
      var fromIdx = allCards.indexOf(dragging);
      var toIdx   = allCards.indexOf(this);
      if (fromIdx < toIdx) list.insertBefore(dragging, this.nextSibling);
      else list.insertBefore(dragging, this);
      var day = this.getAttribute('data-day');
      renumberPlaces(day);
      showToast('↕️ 순서 변경됨');
    }
  });
}
document.querySelectorAll('.place-card').forEach(function(card) { initDrag(card); });

/* ══════════════════════════════
   체크리스트
══════════════════════════════ */
function toggleCheck(item) {
  var cb = item.querySelector('input[type=checkbox]');
  cb.checked = !cb.checked;
  item.classList.toggle('done', cb.checked);
}

/* ══════════════════════════════
   투표
══════════════════════════════ */
function castVote(btn) {
  btn.classList.add('voted');
  btn.textContent = '✓ 투표 완료!';
  showToast('🗳️ 투표했어요!');
}

/* ══════════════════════════════
   동행자 초대
══════════════════════════════ */
function copyInviteLink() {
  var link = document.getElementById('inviteLinkText').textContent;
  if (navigator.clipboard) {
    navigator.clipboard.writeText(link).then(function() { showToast('🔗 링크 복사됨!'); });
  } else {
    showToast('🔗 링크: ' + link);
  }
}

/* ══════════════════════════════
   토스트
══════════════════════════════ */
function showToast(msg) {
  var wrap = document.getElementById('toastWrap');
  var t = document.createElement('div');
  t.className = 'toast';
  t.textContent = msg;
  wrap.appendChild(t);
  setTimeout(function() {
    t.style.transition = 'opacity .3s, transform .3s';
    t.style.opacity = '0';
    t.style.transform = 'translateY(10px)';
    setTimeout(function() { t.remove(); }, 300);
  }, 2200);
}

/* ══════════════════════════════
   카카오맵 초기화 (API 연동 시)
══════════════════════════════ */
// function initKakaoMap() {
//   var container = document.getElementById('kakaoMap');
//   var options = { center: new kakao.maps.LatLng(33.3617, 126.5292), level: 10 };
//   var map = new kakao.maps.Map(container, options);
//   // 마커 추가 로직 ...
// }
// window.onload = initKakaoMap;
</script>
</body>
</html>
