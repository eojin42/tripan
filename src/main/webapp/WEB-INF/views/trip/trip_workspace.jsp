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
  min-width: 260px;
  max-width: 720px;
  flex-shrink: 0;
  background: var(--white);
  border-right: 1px solid var(--border);
  display: flex;
  flex-direction: column;
  overflow: hidden;
  position: relative;
}

/* ── 리사이저 핸들 ── */
.ws-resizer {
  position: absolute;
  top: 0; right: -4px; bottom: 0;
  width: 8px;
  cursor: col-resize;
  z-index: 100;
  display: flex;
  align-items: center;
  justify-content: center;
}
.ws-resizer::before {
  content: '';
  display: block;
  width: 3px;
  height: 40px;
  border-radius: 2px;
  background: var(--border);
  transition: background .2s, height .2s;
}
.ws-resizer:hover::before,
.ws-resizer.dragging::before {
  background: var(--blue);
  height: 60px;
}
/* 리사이저 드래그 중 전역 커서 */
body.resizing { cursor: col-resize !important; user-select: none !important; }
body.resizing * { pointer-events: none !important; }
body.resizing .ws-resizer { pointer-events: all !important; }

/* ── 가로 크기 표시 툴팁 ── */
.resize-tooltip {
  position: fixed;
  background: var(--dark);
  color: white;
  font-size: 11px;
  font-weight: 700;
  padding: 4px 10px;
  border-radius: 6px;
  pointer-events: none;
  z-index: 999;
  white-space: nowrap;
  opacity: 0;
  transition: opacity .15s;
}
.resize-tooltip.show { opacity: 1; }

/* ── 사이드바 너비 표시 (하단 상태바) ── */
.sidebar-width-bar {
  height: 28px;
  border-top: 1px solid var(--border);
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  flex-shrink: 0;
  padding: 0 12px;
}
.sidebar-width-label {
  font-size: 10px;
  font-weight: 700;
  color: var(--light);
  letter-spacing: .5px;
}
.sidebar-width-btns { display: flex; gap: 4px; margin-left: auto; }
.sidebar-width-btn {
  padding: 2px 8px;
  border: 1px solid var(--border);
  border-radius: 4px;
  background: transparent;
  font-family: 'Pretendard', sans-serif;
  font-size: 10px;
  font-weight: 700;
  color: var(--light);
  cursor: pointer;
  transition: all .15s;
}
.sidebar-width-btn:hover { border-color: var(--blue); color: var(--blue); background: #EBF8FF; }

/* 사이드바 탭 패널 */
.sidebar-panel { display: none; flex-direction: column; flex: 1; overflow: hidden; }
.sidebar-panel.active { display: flex; }
/* 편집 모드에서 panel-schedule flex:1 차지 */
.ws-layout.mode-edit .sidebar-panel.active { flex: 1; min-width: 0; }

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
  display: flex; align-items: flex-start; gap: 12px;
  padding: 13px 14px;
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
  width: 28px; height: 28px; border-radius: 50%;
  background: var(--grad2);
  color: white; font-size: 12px; font-weight: 900;
  display: flex; align-items: center; justify-content: center;
  flex-shrink: 0; margin-top: 1px;
}
.place-info { flex: 1; min-width: 0; }
.place-name {
  font-size: 14px; font-weight: 700; color: var(--dark);
  margin-bottom: 3px; line-height: 1.3;
  /* 넓어지면 전체 표시, 좁으면 ellipsis */
  overflow: hidden; text-overflow: ellipsis; white-space: nowrap;
}
.ws-sidebar[data-wide="true"] .place-name { white-space: normal; }
.place-addr {
  font-size: 12px; color: var(--light);
  overflow: hidden; text-overflow: ellipsis; white-space: nowrap;
  margin-bottom: 4px;
}
.ws-sidebar[data-wide="true"] .place-addr { white-space: normal; font-size: 12px; }
.place-type-badge {
  display: inline-block;
  font-size: 10px; font-weight: 700; letter-spacing: .5px;
  padding: 3px 9px; border-radius: 50px; margin-top: 2px;
  background: rgba(137,207,240,.15); color: var(--blue);
}
.place-type-badge.eat  { background: rgba(255,182,193,.15); color: #E8849A; }
.place-type-badge.stay { background: rgba(194,184,217,.15); color: #8B7BAE; }

.place-actions { display: flex; gap: 4px; opacity: 0; transition: opacity .2s; flex-shrink: 0; }
.place-card:hover .place-actions { opacity: 1; }
.place-action-btn {
  width: 28px; height: 28px; border-radius: 8px;
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

/* ══════════════════════════════
   체크리스트 패널
══════════════════════════════ */
.checklist-panel-inner { flex: 1; overflow-y: auto; padding: 24px; }
.checklist-header {
  display: flex; justify-content: space-between; align-items: center;
  margin-bottom: 20px;
}
.checklist-title { font-size: 16px; font-weight: 900; color: var(--dark); }
.checklist-progress {
  display: flex; align-items: center; gap: 10px;
  margin-bottom: 20px; padding: 14px 16px;
  background: linear-gradient(135deg,rgba(137,207,240,.08),rgba(255,182,193,.08));
  border: 1.5px solid rgba(137,207,240,.2); border-radius: 14px;
}
.checklist-progress-bar-bg { flex: 1; height: 8px; background: var(--border); border-radius: 50px; overflow: hidden; }
.checklist-progress-bar { height: 100%; background: var(--grad2); border-radius: 50px; transition: width .5s var(--ease); }
.checklist-progress-txt { font-size: 12px; font-weight: 800; color: var(--mid); white-space: nowrap; }
.btn-add-check {
  padding: 7px 16px; border: none;
  background: var(--grad2); border-radius: 50px;
  color: white; font-family: 'Pretendard',sans-serif;
  font-size: 12px; font-weight: 700; cursor: pointer;
  box-shadow: 0 4px 12px rgba(137,207,240,.3);
  transition: all .2s;
}
.btn-add-check:hover { transform: translateY(-1px); box-shadow: 0 6px 16px rgba(137,207,240,.4); }
.check-category {
  background: var(--white);
  border: 1.5px solid var(--border);
  border-radius: 16px;
  padding: 16px 18px;
  margin-bottom: 12px;
  transition: box-shadow .2s;
}
.check-category:hover { box-shadow: 0 4px 16px rgba(0,0,0,.06); }
.check-cat-label {
  display: flex; align-items: center; gap: 6px;
  font-size: 12px; font-weight: 800; color: var(--dark);
  margin-bottom: 12px; padding-bottom: 10px;
  border-bottom: 1px solid var(--border);
}
.check-item {
  display: flex; align-items: center; gap: 10px;
  padding: 9px 0; cursor: pointer;
  border-bottom: 1px solid var(--bg);
}
.check-item:last-child { border-bottom: none; padding-bottom: 0; }
.check-item input[type=checkbox] {
  width: 18px; height: 18px; border-radius: 5px;
  accent-color: var(--blue); cursor: pointer; flex-shrink: 0;
}
.check-item label { font-size: 13px; font-weight: 600; color: var(--dark); cursor: pointer; flex: 1; }
.check-item.done label { text-decoration: line-through; color: var(--light); }
.check-by {
  font-size: 11px; font-weight: 700; color: var(--light);
  background: var(--bg); padding: 2px 8px; border-radius: 50px;
}

/* ══════════════════════════════
   가계부 패널
══════════════════════════════ */
.expense-panel-inner { flex: 1; overflow-y: auto; padding: 24px; }
.expense-summary {
  background: linear-gradient(135deg, #89CFF0 0%, #C2B8D9 60%, #FFB6C1 100%);
  border-radius: 20px; padding: 24px; color: white; margin-bottom: 20px;
  position: relative; overflow: hidden;
}
.expense-summary::after {
  content: ''; position: absolute;
  right: -20px; top: -20px;
  width: 100px; height: 100px;
  background: rgba(255,255,255,.12);
  border-radius: 50%;
}
.expense-summary__label { font-size: 11px; font-weight: 700; opacity: .8; letter-spacing: 1px; }
.expense-summary__amount { font-size: 34px; font-weight: 900; margin: 6px 0; letter-spacing: -2px; line-height: 1; }
.expense-summary__split { font-size: 12px; opacity: .85; }
.expense-summary__per {
  display: inline-block; margin-top: 8px;
  background: rgba(255,255,255,.25); padding: 4px 12px;
  border-radius: 50px; font-size: 12px; font-weight: 700;
}
.expense-cats {
  display: grid; grid-template-columns: 1fr 1fr 1fr 1fr;
  gap: 8px; margin-bottom: 20px;
}
.expense-cat {
  background: var(--white);
  border: 1.5px solid var(--border);
  border-radius: 14px; padding: 14px 10px;
  display: flex; flex-direction: column; align-items: center; gap: 5px;
  transition: all .18s;
}
.expense-cat:hover { border-color: var(--blue); box-shadow: 0 4px 12px rgba(137,207,240,.15); }
.expense-cat__icon { font-size: 22px; }
.expense-cat__name { font-size: 10px; font-weight: 700; color: var(--light); }
.expense-cat__amt { font-size: 13px; font-weight: 900; color: var(--dark); }
.expense-cat__bar { width: 100%; height: 3px; background: var(--border); border-radius: 50px; overflow: hidden; margin-top: 2px; }
.expense-cat__bar-fill { height: 100%; background: var(--grad2); border-radius: 50px; }
.expense-section-head {
  display: flex; justify-content: space-between; align-items: center;
  margin-bottom: 12px;
}
.expense-list-title { font-size: 13px; font-weight: 800; color: var(--dark); }
.expense-list-more { font-size: 11px; color: var(--blue); font-weight: 700; cursor: pointer; background: none; border: none; font-family: 'Pretendard',sans-serif; }
.expense-item {
  display: flex; align-items: center; gap: 12px;
  padding: 13px 14px;
  background: var(--white);
  border: 1.5px solid var(--border);
  border-radius: 14px;
  margin-bottom: 8px;
  transition: all .15s;
}
.expense-item:hover { border-color: var(--border); box-shadow: 0 3px 10px rgba(0,0,0,.06); }
.expense-item__icon-wrap {
  width: 38px; height: 38px; border-radius: 12px;
  background: var(--bg); display: flex; align-items: center; justify-content: center;
  font-size: 18px; flex-shrink: 0;
}
.expense-item__info { flex: 1; }
.expense-item__name { font-size: 13px; font-weight: 700; color: var(--dark); }
.expense-item__detail { font-size: 11px; color: var(--light); margin-top: 1px; }
.expense-item__amt { font-size: 15px; font-weight: 900; color: var(--dark); }
.btn-add-expense {
  width: 100%; padding: 13px;
  border: 1.5px dashed var(--border);
  border-radius: 14px; background: transparent;
  font-family: 'Pretendard',sans-serif; font-size: 13px; font-weight: 700;
  color: var(--light); cursor: pointer; transition: all .2s; margin-top: 4px;
  display: flex; align-items: center; justify-content: center; gap: 6px;
}
.btn-add-expense:hover { border-color: var(--blue); color: var(--blue); background: rgba(137,207,240,.05); }

/* ══════════════════════════════
   투표 패널
══════════════════════════════ */
.vote-panel-inner { flex: 1; overflow-y: auto; padding: 24px; }
.vote-panel-head {
  display: flex; justify-content: space-between; align-items: center;
  margin-bottom: 20px;
}
.vote-panel-title { font-size: 16px; font-weight: 900; color: var(--dark); }
.btn-new-vote {
  padding: 7px 16px; border: none;
  background: var(--grad2); border-radius: 50px;
  color: white; font-family: 'Pretendard',sans-serif;
  font-size: 12px; font-weight: 700; cursor: pointer;
  box-shadow: 0 4px 12px rgba(137,207,240,.3);
  transition: all .2s;
}
.btn-new-vote:hover { transform: translateY(-1px); }
.vote-cards-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 14px; }
.vote-card {
  background: var(--white); border: 1.5px solid var(--border);
  border-radius: 18px; padding: 18px;
  transition: all .2s;
}
.vote-card:hover { box-shadow: 0 6px 20px rgba(0,0,0,.07); border-color: transparent; }
.vote-card__emoji { font-size: 22px; margin-bottom: 8px; }
.vote-card__title { font-size: 14px; font-weight: 800; color: var(--dark); margin-bottom: 3px; line-height: 1.3; }
.vote-card__sub { font-size: 11px; color: var(--light); margin-bottom: 14px; display: flex; align-items: center; gap: 4px; }
.vote-card__sub-dot { width: 3px; height: 3px; background: var(--border); border-radius: 50%; }
.vote-option { margin-bottom: 10px; }
.vote-option__top { display: flex; justify-content: space-between; align-items: center; margin-bottom: 5px; }
.vote-option__name { font-size: 12px; font-weight: 600; color: var(--dark); }
.vote-option__pct { font-size: 12px; font-weight: 900; color: var(--blue); }
.vote-bar-bg { height: 7px; background: var(--bg); border-radius: 50px; overflow: hidden; }
.vote-bar-fill { height: 100%; background: var(--grad2); border-radius: 50px; transition: width .6s var(--ease); }
.vote-card__divider { height: 1px; background: var(--border); margin: 12px 0; }
.btn-vote {
  width: 100%; padding: 10px 12px;
  border: 1.5px solid var(--border); border-radius: 10px;
  background: transparent; font-family: 'Pretendard',sans-serif;
  font-size: 12px; font-weight: 700; color: var(--mid); cursor: pointer; transition: all .2s;
}
.btn-vote:hover { border-color: var(--blue); color: var(--blue); background: rgba(137,207,240,.05); }
.btn-vote.voted {
  background: var(--grad2); border-color: transparent; color: white;
  box-shadow: 0 4px 14px rgba(137,207,240,.35);
}

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

/* ═══════════════════════════════════════════
   뷰 모드 토글
═══════════════════════════════════════════ */

/* 토글 버튼 그룹 */
.view-toggle {
  display: flex;
  background: var(--bg);
  border: 1px solid var(--border);
  border-radius: 10px;
  padding: 3px;
  gap: 2px;
  flex-shrink: 0;
}
.view-toggle-btn {
  display: flex; align-items: center; gap: 5px;
  padding: 5px 12px;
  border: none; border-radius: 7px;
  background: transparent;
  font-family: 'Pretendard', sans-serif;
  font-size: 12px; font-weight: 700;
  color: var(--light);
  cursor: pointer;
  transition: all .2s;
  white-space: nowrap;
}
.view-toggle-btn svg { flex-shrink: 0; }
.view-toggle-btn.active {
  background: var(--white);
  color: var(--dark);
  box-shadow: 0 1px 6px rgba(0,0,0,.08);
}
.view-toggle-btn:hover:not(.active) { color: var(--mid); }

/* ── 모드별 레이아웃 변환 ── */

/* 기본: split (지도 + 사이드바) */
.ws-layout { transition: none; }

/* 전체 편집 모드 — 지도 숨김, 사이드바 전체 */
.ws-layout.mode-edit .ws-map-area {
  display: none;
}
.ws-layout.mode-edit .ws-sidebar {
  width: 100% !important;
  max-width: 100%;
  border-right: none;
}
.ws-layout.mode-edit .ws-resizer { display: none; }
.ws-layout.mode-edit .sidebar-width-bar { display: none; }

/* ══════════════════════════════════════════════════
   편집 전체 모드
   구조: [추천 사이드바 280px] [일정 중앙 max-width:680px] [여백]
   ws-layout 자체를 새로 정의
══════════════════════════════════════════════════ */

/* 편집 모드: ws-layout을 가로 3구역으로 */
.ws-layout.mode-edit {
  display: flex;
  flex-direction: row;
}
.ws-layout.mode-edit .ws-sidebar {
  flex-direction: row !important;
  width: 100% !important;
  max-width: 100%;
  border-right: none;
  background: transparent;
  overflow: visible;
}
.ws-layout.mode-edit .ws-resizer { display: none; }
.ws-layout.mode-edit .sidebar-width-bar { display: none; }

/* 좌측 추천 사이드바 */
.edit-recommend-panel {
  display: none;
  width: 380px;
  flex-shrink: 0;
  background: var(--white);
  border-right: 1px solid var(--border);
  overflow-y: auto;
  overflow-x: hidden;
  padding: 0;
  flex-direction: column;
  gap: 0;
  order: -1;
  scrollbar-width: none;
}
.edit-recommend-panel::-webkit-scrollbar { display: none; }
.ws-layout.mode-edit .edit-recommend-panel { display: flex; }

/* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   편집모드 — 공통: 모든 활성 패널
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */
.ws-layout.mode-edit .sidebar-panel.active {
  flex: 1;
  min-width: 0;
  display: flex;
  flex-direction: column;
  background: var(--bg);
  overflow: hidden;
}

/* ━━━ 일정 패널 ━━━ */
.ws-layout.mode-edit #panel-schedule {
  background: var(--bg);
}

/* ━━━ 체크리스트 ━━━ */
.ws-layout.mode-edit #panel-checklist {
  background: var(--bg);
}
.ws-layout.mode-edit #panel-checklist .checklist-panel-inner {
  max-width: 1000px;
  margin: 0 auto;
  padding: 40px 56px;
  overflow-y: auto;
  width: 100%;
  flex: 1;
  display: flex;
  flex-direction: column;
}
.ws-layout.mode-edit #panel-checklist .checklist-header {
  margin-bottom: 16px;
}
.ws-layout.mode-edit #panel-checklist .checklist-progress {
  display: flex;
  margin-bottom: 24px;
}
.ws-layout.mode-edit #panel-checklist .check-categories-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(270px, 1fr));
  gap: 16px;
  align-items: start;
}
.ws-layout.mode-edit #panel-checklist .check-category {
  margin-bottom: 0;
}

/* ━━━ 가계부 ━━━ */
.ws-layout.mode-edit #panel-expense {
  background: var(--bg);
}
.ws-layout.mode-edit #panel-expense .expense-panel-inner {
  max-width: 860px;
  margin: 0 auto;
  padding: 40px 56px;
  overflow-y: auto;
  width: 100%;
  flex: 1;
  display: flex;
  flex-direction: column;
}
.ws-layout.mode-edit #panel-expense .expense-summary {
  border-radius: 22px;
  padding: 28px 32px;
  margin-bottom: 22px;
}
.ws-layout.mode-edit #panel-expense .expense-cats {
  grid-template-columns: repeat(4, 1fr);
  gap: 12px;
  margin-bottom: 24px;
}
.ws-layout.mode-edit #panel-expense .expense-cat {
  padding: 18px 12px;
  border-radius: 18px;
}
.ws-layout.mode-edit #panel-expense .expense-cat__icon { font-size: 28px; }
.ws-layout.mode-edit #panel-expense .expense-cat__amt { font-size: 15px; }
.ws-layout.mode-edit #panel-expense .expense-item {
  padding: 16px 18px;
  border-radius: 16px;
  margin-bottom: 10px;
}
.ws-layout.mode-edit #panel-expense .expense-item__icon-wrap {
  width: 44px; height: 44px; font-size: 22px; border-radius: 14px;
}
.ws-layout.mode-edit #panel-expense .expense-item__name { font-size: 15px; }
.ws-layout.mode-edit #panel-expense .expense-item__amt { font-size: 17px; }

/* ━━━ 투표 ━━━ */
.ws-layout.mode-edit #panel-vote {
  background: var(--bg);
}
.ws-layout.mode-edit #panel-vote .vote-panel-inner {
  max-width: 900px;
  margin: 0 auto;
  padding: 40px 56px;
  overflow-y: auto;
  width: 100%;
  flex: 1;
  display: flex;
  flex-direction: column;
}
.ws-layout.mode-edit #panel-vote .vote-panel-head {
  margin-bottom: 24px;
}
.ws-layout.mode-edit #panel-vote .vote-panel-title {
  font-size: 20px;
}
.ws-layout.mode-edit #panel-vote .btn-new-vote {
  padding: 10px 22px;
  font-size: 13px;
}
.ws-layout.mode-edit #panel-vote .vote-cards-grid {
  grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
  gap: 18px;
}
.ws-layout.mode-edit #panel-vote .vote-card {
  padding: 22px;
  border-radius: 22px;
}
.ws-layout.mode-edit #panel-vote .vote-card__emoji { font-size: 28px; margin-bottom: 10px; }
.ws-layout.mode-edit #panel-vote .vote-card__title { font-size: 16px; margin-bottom: 4px; }
.ws-layout.mode-edit #panel-vote .vote-card__sub { font-size: 12px; margin-bottom: 18px; }
.ws-layout.mode-edit #panel-vote .vote-option { margin-bottom: 12px; }
.ws-layout.mode-edit #panel-vote .vote-option__name { font-size: 14px; }
.ws-layout.mode-edit #panel-vote .vote-option__pct { font-size: 14px; }
.ws-layout.mode-edit #panel-vote .vote-bar-bg { height: 8px; }
.ws-layout.mode-edit #panel-vote .btn-vote { padding: 12px; font-size: 14px; }

/* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   편집모드 — 일정 스크롤 & 카드
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */
.ws-layout.mode-edit .schedule-scroll {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 0;
  padding: 40px 56px 80px;
  overflow-y: auto;
  width: 100%;
  max-width: 920px;
  margin: 0 auto;
  align-self: center;
  align-items: stretch;
  scrollbar-width: thin;
  scrollbar-color: var(--border) transparent;
}

/* Day 섹션: 흰 카드, 여백 넉넉 */
.ws-layout.mode-edit .day-section {
  margin-bottom: 20px;
  padding: 28px 32px 24px;
  border-bottom: none;
  background: var(--white);
  border-radius: 22px;
  box-shadow: 0 2px 20px rgba(0,0,0,.055);
  border: 1.5px solid rgba(226,232,240,.8);
  transition: box-shadow .2s;
}
.ws-layout.mode-edit .day-section:hover { box-shadow: 0 4px 28px rgba(0,0,0,.09); }
.ws-layout.mode-edit .day-section:first-child { margin-top: 0; }
.ws-layout.mode-edit .day-section:last-child { margin-bottom: 0; }

.ws-layout.mode-edit .day-header {
  position: static;
  background: transparent;
  padding: 0 0 18px 0;
  margin-bottom: 18px;
  border-bottom: 1px solid var(--border);
  display: flex; align-items: center; gap: 12px;
}
.ws-layout.mode-edit .day-badge { gap: 10px; padding: 8px 20px 8px 14px; }
.ws-layout.mode-edit .day-badge .day-num { font-size: 24px; }
.ws-layout.mode-edit .day-date { font-size: 14px; font-weight: 700; color: var(--mid); }
.ws-layout.mode-edit .btn-add-place { margin-left: auto; }

/* place-card: 흰 배경, 넉넉한 패딩 */
.ws-layout.mode-edit .place-card {
  padding: 16px 18px;
  background: var(--bg);
  border: 1.5px solid var(--border);
  border-radius: 16px;
}
.ws-layout.mode-edit .place-card:hover {
  border-color: var(--blue);
  box-shadow: 0 4px 18px rgba(137,207,240,.18);
  background: var(--white);
}
.ws-layout.mode-edit .place-num {
  width: 34px; height: 34px;
  font-size: 14px; border-radius: 12px; flex-shrink: 0;
}
.ws-layout.mode-edit .place-name { white-space: normal; font-size: 15px; font-weight: 700; line-height: 1.3; }
.ws-layout.mode-edit .place-addr { white-space: normal; font-size: 12px; margin-top: 3px; }
.ws-layout.mode-edit .place-list { gap: 10px; }
.ws-layout.mode-edit .place-type-badge { font-size: 11px; padding: 3px 10px; margin-top: 6px; }
.ws-layout.mode-edit .memo-chip { margin-top: 8px; padding: 8px 12px; font-size: 12px; border-radius: 10px; }
.ws-layout.mode-edit .place-actions { gap: 6px; }
.ws-layout.mode-edit .place-action-btn { width: 32px; height: 32px; font-size: 15px; border-radius: 10px; }
.ws-layout.mode-edit .drop-zone { margin-top: 12px; padding: 14px; font-size: 13px; border-radius: 14px; }

/* ══════════════════════════════
   추천 사이드바 (편집 모드 좌측)
══════════════════════════════ */

/* 헤더 + 탭 */
.rp-header {
  padding: 16px 16px 0;
  position: sticky; top: 0;
  background: var(--white);
  z-index: 10;
  border-bottom: 1px solid var(--border);
  margin-bottom: 0;
}
.rp-panel-title {
  font-size: 13px; font-weight: 800; color: var(--dark);
  margin-bottom: 12px;
  display: flex; align-items: center; gap: 6px;
}
.rp-tabs {
  display: flex; gap: 0;
  border-bottom: none;
}
.rp-tab {
  flex: 1; padding: 9px 0 10px;
  border: none; border-bottom: 2px solid transparent;
  background: transparent;
  font-family: 'Pretendard', sans-serif;
  font-size: 12px; font-weight: 700;
  color: var(--light); cursor: pointer;
  transition: all .18s;
  white-space: nowrap;
}
.rp-tab.active { color: var(--dark); border-bottom-color: var(--blue); }
.rp-tab:hover:not(.active) { color: var(--mid); }

/* 탭 패널 */
.rp-pane { display: none; flex-direction: column; gap: 0; flex: 1; padding: 16px 14px 32px; overflow-y: auto; scrollbar-width: none; }
.rp-pane::-webkit-scrollbar { display: none; }
.rp-pane.active { display: flex; }

/* 카테고리 필터 */
.rp-filter {
  display: flex; gap: 5px; flex-wrap: wrap;
  padding-bottom: 0;
  border-bottom: none;
  margin-bottom: 0;
}
.rp-filter-btn {
  padding: 5px 11px;
  border: 1.5px solid var(--border);
  border-radius: 50px;
  background: transparent;
  font-family: 'Pretendard', sans-serif;
  font-size: 11px; font-weight: 700;
  color: var(--light); cursor: pointer;
  transition: all .15s;
}
.rp-filter-btn.active {
  border-color: var(--blue);
  color: var(--blue);
  background: rgba(137,207,240,.1);
}
.rp-filter-btn:hover:not(.active) {
  border-color: var(--border);
  color: var(--mid);
  background: var(--bg);
}

/* 검색바 */
.rp-searchbar {
  display: flex; align-items: center; gap: 8px;
  background: var(--bg);
  border: 1.5px solid var(--border);
  border-radius: 10px;
  padding: 7px 12px;
  margin: 10px 0 12px;
  transition: border-color .2s;
}
.rp-searchbar:focus-within { border-color: var(--blue); background: var(--white); }
.rp-search-input {
  flex: 1; border: none; outline: none;
  background: transparent;
  font-family: 'Pretendard', sans-serif;
  font-size: 13px; font-weight: 500; color: var(--dark);
}
.rp-search-input::placeholder { color: var(--light); }
.rp-search-clear {
  border: none; background: none; cursor: pointer;
  color: var(--light); font-size: 12px; padding: 0;
  line-height: 1; transition: color .15s;
}
.rp-search-clear:hover { color: var(--mid); }
.rp-no-result {
  text-align: center; padding: 32px 0;
  color: var(--light); font-size: 13px; font-weight: 600;
  display: none;
}

/* 카드 이미지 래퍼 (배지 겹치기) */
.rp-card-img-wrap { position: relative; }
.rp-card-cat-badge {
  position: absolute; top: 8px; left: 8px;
  background: rgba(26,32,44,.55);
  backdrop-filter: blur(4px);
  color: white; font-size: 10px; font-weight: 700;
  padding: 3px 8px; border-radius: 50px;
}

/* 운영시간/소요시간 행 */
.rp-card-meta-row {
  display: flex; gap: 6px; flex-wrap: wrap;
  margin-bottom: 7px;
}
.rp-meta-item {
  font-size: 10px; font-weight: 600; color: var(--light);
  background: var(--bg); border-radius: 6px;
  padding: 2px 7px; white-space: nowrap;
}

/* 검색 없음 메시지 */
.rp-no-result { grid-column: 1 / -1; }

/* 추천 카드 — 2열 그리드, 세로형 */
.rp-cards {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 10px;
  margin-top: 12px;
}
.rp-card {
  display: flex; flex-direction: column;
  background: var(--white);
  border: 1.5px solid var(--border);
  border-radius: 14px;
  overflow: hidden;
  cursor: pointer;
  transition: all .2s;
}
.rp-card:hover {
  border-color: transparent;
  box-shadow: 0 6px 20px rgba(0,0,0,.11);
  transform: translateY(-2px);
}
.rp-card.hidden { display: none; }
.rp-card-thumb {
  width: 100%; height: 130px;
  object-fit: cover;
  display: block;
  background: var(--bg);
}
.rp-card-thumb-img {
  width: 100%; height: 130px;
  object-fit: cover; display: block;
}
.rp-card-info { padding: 10px 12px 12px; flex: 1; display: flex; flex-direction: column; }
.rp-card-name { font-size: 13px; font-weight: 800; margin-bottom: 3px; color: var(--dark); line-height: 1.3; }
.rp-card-addr { font-size: 11px; color: var(--light); margin-bottom: 5px; line-height: 1.3; }
.rp-card-foot { display: flex; align-items: center; justify-content: space-between; gap: 4px; }
.rp-badge {
  font-size: 10px; font-weight: 700;
  padding: 2px 6px; border-radius: 50px; white-space: nowrap;
}
.rp-badge.blue   { background: rgba(137,207,240,.15); color: #5BABC9; }
.rp-badge.pink   { background: rgba(255,182,193,.15); color: #E8849A; }
.rp-badge.purple { background: rgba(194,184,217,.15); color: #8B7BAE; }
.rp-badge.green  { background: rgba(104,211,145,.15); color: #276749; }
.rp-add-btn {
  font-size: 10px; font-weight: 800;
  color: white;
  background: var(--grad2);
  border: none; border-radius: 50px;
  cursor: pointer; padding: 3px 8px;
  transition: opacity .15s; white-space: nowrap;
  flex-shrink: 0;
}
.rp-add-btn:hover { opacity: .82; }

/* Day 선택 팝업 */
.day-picker-popup {
  position: fixed;
  top: 50%; left: 50%;
  transform: translate(-50%, -50%);
  background: var(--white);
  border-radius: 18px;
  padding: 24px;
  box-shadow: 0 20px 60px rgba(0,0,0,.18);
  z-index: 600;
  width: 280px;
  animation: slideup .25s var(--ease);
}
.dpp-title {
  font-size: 15px; font-weight: 800;
  text-align: center; margin-bottom: 16px;
}
.dpp-days { display: grid; grid-template-columns: 1fr 1fr; gap: 8px; margin-bottom: 12px; }
.dpp-btn {
  padding: 12px 8px;
  border: 1.5px solid var(--border);
  border-radius: 12px;
  background: var(--bg);
  font-family: 'Pretendard', sans-serif;
  font-size: 13px; font-weight: 800;
  color: var(--dark); cursor: pointer;
  transition: all .18s;
  text-align: center; line-height: 1.5;
}
.dpp-btn span { font-size: 10px; font-weight: 500; color: var(--light); display: block; }
.dpp-btn:hover { border-color: var(--blue); background: #EBF8FF; color: var(--blue); }
.dpp-cancel {
  width: 100%; padding: 10px;
  border: none; border-radius: 10px;
  background: var(--bg); font-family: 'Pretendard', sans-serif;
  font-size: 12px; font-weight: 700; color: var(--light);
  cursor: pointer; transition: background .15s;
}
.dpp-cancel:hover { background: var(--border); }

/* 일정 요약 탭 */
/* ── 일정 요약 탭 ── */
.rp-summary-wrap { display: flex; flex-direction: column; gap: 14px; }

/* 완료율 프로그레스 카드 */
/* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   일정 요약 — 아코디언 타임라인
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */
.rp-summary-wrap { display: flex; flex-direction: column; gap: 8px; }
.rp-day-accordion { display: flex; flex-direction: column; gap: 6px; }
.rp-da-item {
  border-radius: 14px; overflow: hidden;
  border: 1.5px solid var(--border); background: var(--white);
  transition: box-shadow .18s;
}
.rp-da-item:hover { box-shadow: 0 3px 12px rgba(0,0,0,.07); }
.rp-da-head {
  display: flex; align-items: center; gap: 9px;
  padding: 12px 14px; cursor: pointer;
  transition: background .15s; user-select: none;
}
.rp-da-head:hover { background: var(--bg); }
.rp-da-dot {
  width: 28px; height: 28px; border-radius: 10px;
  flex-shrink: 0; display: flex; align-items: center; justify-content: center;
  font-size: 9px; font-weight: 900; color: white; letter-spacing: -.5px;
}
.rp-da-date { font-size: 12px; font-weight: 700; color: var(--dark); flex: 1; }
.rp-da-cnt {
  font-size: 10px; font-weight: 800; padding: 3px 9px;
  background: rgba(137,207,240,.1); border-radius: 50px; color: var(--blue);
  border: 1px solid rgba(137,207,240,.25);
}
.rp-da-cnt.empty { background: var(--bg); color: var(--light); border-color: var(--border); }
.rp-da-arrow { font-size: 10px; color: var(--light); transition: transform .22s var(--ease); margin-left: 2px; }
.rp-da-item.open .rp-da-arrow { transform: rotate(180deg); }
.rp-da-body { display: none; padding: 0 14px 12px; }
.rp-da-item.open .rp-da-body { display: block; }
.rp-da-place {
  display: flex; align-items: center; gap: 9px;
  padding: 8px 0; border-bottom: 1px solid var(--bg);
  font-size: 12px; font-weight: 600; color: var(--mid);
  transition: color .15s;
}
.rp-da-place:last-child { border-bottom: none; padding-bottom: 0; }
.rp-da-place:hover { color: var(--dark); }
.rp-da-pnum {
  width: 20px; height: 20px; border-radius: 7px;
  font-size: 9px; font-weight: 900; color: white;
  display: flex; align-items: center; justify-content: center; flex-shrink: 0;
}
.rp-da-pname { flex: 1; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; font-size: 12px; font-weight: 700; color: var(--dark); }
.rp-da-pbadge { font-size: 10px; color: var(--light); flex-shrink: 0; white-space: nowrap; }
.rp-da-empty {
  font-size: 11px; color: var(--light); padding: 10px 0;
  text-align: center; font-weight: 600;
  border: 1.5px dashed var(--border); border-radius: 10px; margin: 2px 0 4px;
}

/* 타임라인 (구 코드 호환) */
.rp-timeline { display: flex; flex-direction: column; gap: 0; }
.rp-tl-day { display: flex; gap: 0; }
.rp-tl-left { display: flex; flex-direction: column; align-items: center; width: 40px; flex-shrink: 0; }
.rp-tl-dot { width: 28px; height: 28px; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-size: 10px; font-weight: 900; color: white; flex-shrink: 0; }
.rp-tl-line { width: 2px; flex: 1; min-height: 12px; background: var(--border); margin: 0 auto; }
.rp-tl-day:last-child .rp-tl-line { display: none; }
.rp-tl-right { flex: 1; padding-bottom: 16px; padding-top: 2px; }
.rp-tl-head { display: flex; align-items: center; gap: 6px; margin-bottom: 8px; }
.rp-tl-date { font-size: 11px; font-weight: 700; color: var(--mid); }
.rp-tl-cnt { font-size: 10px; font-weight: 700; color: var(--light); margin-left: auto; padding: 2px 7px; background: var(--bg); border-radius: 50px; border: 1px solid var(--border); }
.rp-tl-places { display: flex; flex-direction: column; gap: 4px; }
.rp-tl-place { display: flex; align-items: center; gap: 8px; padding: 8px 10px; background: var(--white); border: 1px solid var(--border); border-radius: 10px; font-size: 12px; font-weight: 600; color: var(--dark); transition: all .15s; }
.rp-tl-place:hover { border-color: var(--blue); }
.rp-tl-place-num { width: 18px; height: 18px; border-radius: 50%; font-size: 9px; font-weight: 900; color: white; display: flex; align-items: center; justify-content: center; flex-shrink: 0; }
.rp-tl-place-name { flex: 1; min-width: 0; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
.rp-tl-empty { padding: 12px 10px; background: var(--bg); border: 1.5px dashed var(--border); border-radius: 10px; font-size: 11px; font-weight: 600; color: var(--light); text-align: center; }

/* 여행 정보 탭 */
/* ── 날씨 탭 ── */
.rp-weather { display: flex; flex-direction: column; gap: 8px; }

/* 오늘 날씨 메인 카드 */
.rp-weather-main {
  background: linear-gradient(135deg, #89CFF0 0%, #A8D8F0 50%, #C2B8D9 100%);
  border-radius: 16px;
  padding: 20px 18px;
  color: white;
  display: flex; align-items: center; gap: 14px;
}
.rp-weather-main-icon { font-size: 44px; line-height: 1; }
.rp-weather-main-info { flex: 1; }
.rp-weather-main-city { font-size: 11px; font-weight: 700; opacity: .85; margin-bottom: 2px; }
.rp-weather-main-temp { font-size: 34px; font-weight: 900; letter-spacing: -2px; line-height: 1; }
.rp-weather-main-desc { font-size: 12px; opacity: .9; margin-top: 3px; }
.rp-weather-main-side { text-align: right; }
.rp-weather-main-hi { font-size: 13px; font-weight: 700; }
.rp-weather-main-lo { font-size: 11px; opacity: .75; }
.rp-weather-main-rain { font-size: 11px; margin-top: 4px; opacity: .85; }

/* 날짜별 예보 */
.rp-weather-forecast { display: flex; flex-direction: column; gap: 4px; }
.rp-weather-row {
  display: flex; align-items: center; gap: 0;
  background: var(--white);
  border: 1.5px solid var(--border);
  border-radius: 12px;
  padding: 11px 14px;
  transition: all .15s;
}
.rp-weather-row:hover { border-color: var(--blue); }
.rp-weather-row--warn { border-color: #FFB6C1; background: rgba(255,182,193,.05); }
.rp-wr-day { width: 50px; font-size: 12px; font-weight: 800; color: var(--dark); flex-shrink: 0; }
.rp-wr-icon { width: 28px; font-size: 18px; text-align: center; flex-shrink: 0; }
.rp-wr-desc { flex: 1; font-size: 11px; font-weight: 600; color: var(--light); padding: 0 6px; }
.rp-wr-temp { font-size: 12px; font-weight: 700; color: var(--dark); white-space: nowrap; margin-right: 10px; }
.rp-wr-temp span { color: var(--light); font-weight: 500; font-size: 11px; }
.rp-rain-pill {
  font-size: 10px; font-weight: 800; padding: 3px 8px;
  border-radius: 50px; white-space: nowrap; flex-shrink: 0;
}
.rp-rain-pill.low  { background: rgba(137,207,240,.12); color: #5BABC9; }
.rp-rain-pill.mid  { background: rgba(194,184,217,.12); color: #8B7BAE; }
.rp-rain-pill.high { background: rgba(255,182,193,.2); color: #E8849A; }

.rp-tip-item:last-child { border-bottom: none; }

.rp-link-item:hover { border-color: var(--blue); background: #EBF8FF; }

/* ── 전체 편집 모드 — 체크리스트 2컬럼 ── */
.ws-layout.mode-edit .checklist-panel-inner {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
  gap: 16px;
  padding: 24px 28px;
  flex: none;
  overflow-y: auto;
  height: 100%;
  align-items: start;
}
.ws-layout.mode-edit .checklist-header {
  grid-column: 1 / -1;
}
.ws-layout.mode-edit .check-category {
  background: var(--white);
  border: 1.5px solid var(--border);
  border-radius: 16px;
  padding: 16px;
  margin-bottom: 0;
}

/* ── 전체 편집 모드 — 가계부 와이드 ── */
.ws-layout.mode-edit .expense-panel-inner {
  max-width: 900px;
  margin: 0 auto;
  padding: 24px 28px;
}
.ws-layout.mode-edit .expense-cats {
  grid-template-columns: repeat(4, 1fr);
}

/* ── 편집 모드 상단 모드 배지 ── */
.mode-badge {
  display: none;
  align-items: center; gap: 6px;
  padding: 4px 12px;
  background: linear-gradient(135deg, rgba(137,207,240,.15), rgba(255,182,193,.15));
  border: 1px solid rgba(137,207,240,.3);
  border-radius: 50px;
  font-size: 11px; font-weight: 700; color: var(--mid);
  position: absolute; left: 50%; transform: translateX(-50%);
  white-space: nowrap;
}
.ws-layout.mode-edit ~ .mode-badge,
.ws-topbar .mode-badge.show { display: flex; }

/* 지도 전체 모드 — 사이드바 숨김, 지도 전체 */
.ws-layout.mode-map .ws-sidebar {
  display: none;
}
.ws-layout.mode-map .ws-map-area {
  flex: 1;
}

/* 분할 모드 트랜지션 (split ↔ 나머지) */
.ws-sidebar, .ws-map-area {
  transition: width .32s cubic-bezier(.19,1,.22,1),
              opacity .22s ease;
}
.ws-layout.mode-edit .ws-sidebar,
.ws-layout.mode-map .ws-map-area {
  transition: none;
}
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

/* ═══════════════════════════════════════════
   반응형 — 1024px (태블릿)
═══════════════════════════════════════════ */
@media (max-width: 1024px) {
  .ws-layout.mode-edit .edit-recommend-panel { width: 300px; }
  .ws-layout.mode-edit #panel-checklist .checklist-panel-inner { padding: 28px; }
  .ws-layout.mode-edit #panel-checklist .check-categories-grid { grid-template-columns: 1fr 1fr; }
  .ws-layout.mode-edit #panel-expense .expense-panel-inner { padding: 28px; }
  .ws-layout.mode-edit #panel-vote .vote-panel-inner { padding: 28px; }
  .ws-layout.mode-edit #panel-vote .vote-cards-grid { grid-template-columns: 1fr 1fr; }
  .view-toggle-btn { font-size: 11px; padding: 5px 8px; }
}

/* ═══════════════════════════════════════════
   반응형 — 768px (모바일)
═══════════════════════════════════════════ */
@media (max-width: 768px) {
  :root { --topbar-h: 56px; }

  /* 탑바 */
  .ws-topbar { padding: 0 12px; gap: 8px; height: var(--topbar-h); }
  .ws-topbar__title { font-size: 14px; }
  .ws-topbar__sub { display: none; }
  .ws-topbar__actions .live-badge,
  .ws-topbar__actions .avatar-group { display: none; }
  .view-toggle { gap: 2px; }
  .view-toggle-btn { font-size: 10px; padding: 4px 7px; gap: 3px; }
  .view-toggle-btn svg { width: 11px; height: 11px; }
  .ws-tabs { gap: 2px; }
  .ws-tab { font-size: 11px; padding: 5px 8px; }
  .btn-save { font-size: 12px; padding: 6px 14px; }

  /* 분할 모드: 세로 분할 */
  .ws-layout { flex-direction: column; }
  .ws-sidebar {
    width: 100% !important;
    height: 55vh;
    min-width: unset !important;
    border-right: none;
    border-bottom: 1px solid var(--border);
  }
  .ws-map-area { height: calc(45vh - var(--topbar-h)); flex: none; }
  .ws-resizer { display: none !important; }
  .sidebar-width-bar { display: none !important; }

  /* 편집 모드 모바일: 추천 사이드바 숨김 → 하단 슬라이드로 */
  .ws-layout.mode-edit { flex-direction: column; }
  .ws-layout.mode-edit .ws-sidebar { flex-direction: column !important; width: 100% !important; height: calc(100vh - var(--topbar-h)); }
  .ws-layout.mode-edit .edit-recommend-panel {
    display: none !important; /* 모바일에서 편집 패널 숨김 */
  }
  .ws-layout.mode-edit .sidebar-panel.active { height: calc(100vh - var(--topbar-h)); }
  .ws-layout.mode-edit .schedule-scroll { padding: 20px 16px 40px; }
  .ws-layout.mode-edit #panel-checklist .checklist-panel-inner { padding: 16px; }
  .ws-layout.mode-edit #panel-checklist .check-categories-grid { grid-template-columns: 1fr; }
  .ws-layout.mode-edit #panel-expense .expense-panel-inner { padding: 16px; }
  .ws-layout.mode-edit #panel-expense .expense-cats { grid-template-columns: 1fr 1fr; }
  .ws-layout.mode-edit #panel-vote .vote-panel-inner { padding: 16px; }
  .ws-layout.mode-edit #panel-vote .vote-cards-grid { grid-template-columns: 1fr; }

  /* 지도 모드 */
  .ws-layout.mode-map .ws-sidebar { display: none; }
  .ws-layout.mode-map .ws-map-area { height: calc(100vh - var(--topbar-h)); flex: 1; }

  /* 모달 */
  .modal-box { max-width: 100%; margin: 0; border-radius: 24px 24px 0 0; position: fixed; bottom: 0; left: 0; right: 0; }
}

/* ═══════════════════════════════════════════
   반응형 — 480px (소형 모바일)
═══════════════════════════════════════════ */
@media (max-width: 480px) {
  .ws-topbar__info { display: none; }
  .view-toggle { display: none; } /* 뷰 토글 숨김 → 모드 버튼만 */
  .ws-tabs .ws-tab { font-size: 10px; padding: 4px 6px; }
  .place-card { padding: 10px 12px; }
  .place-name { font-size: 13px; }
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

  <%-- 현재 모드 배지 (중앙) --%>
  <div class="mode-badge" id="modeBadge" style="display:none;">
    <span id="modeBadgeIcon">↔️</span>
    <span id="modeBadgeText">분할 보기</span>
  </div>

    <div class="ws-topbar__actions">
      <div class="live-badge">
        <span class="live-dot"></span>
        실시간 동기화
      </div>

      <div class="avatar-group" title="동행자">
        <div class="avatar" style="background:linear-gradient(135deg,#89CFF0,#A8C8E1)">어진</div>
        <div class="avatar" style="background:linear-gradient(135deg,#FFB6C1,#E0BBC2)">혁찬</div>
        <div class="avatar" style="background:linear-gradient(135deg,#C2B8D9,#A8C8E1)">유원</div>
        <div class="avatar avatar-add" onclick="openModal('inviteModal')" title="동행자 초대">+</div>
      </div>

      <%-- 뷰 토글 --%>
      <div class="view-toggle" id="viewToggle">
        <button class="view-toggle-btn" id="vBtn-edit" onclick="setViewMode('edit')" title="편집 전체 보기">
          <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round"><rect x="3" y="3" width="18" height="18" rx="2"/><line x1="3" y1="9" x2="21" y2="9"/><line x1="3" y1="15" x2="21" y2="15"/></svg>
          편집
        </button>
        <button class="view-toggle-btn active" id="vBtn-split" onclick="setViewMode('split')" title="분할 보기">
          <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round"><rect x="3" y="3" width="18" height="18" rx="2"/><line x1="12" y1="3" x2="12" y2="21"/></svg>
          분할
        </button>
        <button class="view-toggle-btn" id="vBtn-map" onclick="setViewMode('map')" title="지도 전체 보기">
          <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round"><polygon points="1 6 1 22 8 18 16 22 23 18 23 2 16 6 8 2 1 6"/><line x1="8" y1="2" x2="8" y2="18"/><line x1="16" y1="6" x2="16" y2="22"/></svg>
          지도
        </button>
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
<div class="ws-layout" id="wsLayout">

  <%-- ── 사이드바 ── --%>
  <aside class="ws-sidebar" id="wsSidebar">

    <%-- 리사이저 핸들 --%>
    <div class="ws-resizer" id="wsResizer" title="드래그로 크기 조절 / 더블클릭으로 초기화"></div>

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
            <div class="day-badge" style="background:linear-gradient(135deg,#C2B8D9,#E0BBC2)">
              <span class="day-num">3</span><span>DAY</span>
            </div>
            <span class="day-date">3월 12일 (목)</span>
            <button class="btn-add-place" onclick="openAddPlace(3)">+ 장소</button>
          </div>
          <div class="place-list" id="places-3">
            <div class="place-card" draggable="true" data-day="3" data-id="6">
              <div class="place-num" style="background:linear-gradient(135deg,#C2B8D9,#E0BBC2)">1</div>
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

        <%-- 완료율 바 --%>
        <div class="checklist-progress">
          <div class="checklist-progress-bar-bg">
            <div class="checklist-progress-bar" id="checkProgressBar" style="width:44%"></div>
          </div>
          <span class="checklist-progress-txt" id="checkProgressTxt">4 / 9 완료</span>
        </div>

        <%-- 카테고리 그리드 --%>
        <div class="check-categories-grid">

          <div class="check-category">
            <span class="check-cat-label">📋 서류 &amp; 결제</span>
            <div class="check-item done" onclick="toggleCheck(this)">
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
            <span class="check-cat-label">👗 의류 &amp; 용품</span>
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
            <div class="check-item done" onclick="toggleCheck(this)">
              <input type="checkbox" id="c9" checked><label for="c9">상비약 세트</label><span class="check-by">지민</span>
            </div>
          </div>

        </div><%-- /check-categories-grid --%>
      </div>
    </div>

    <%-- 가계부 패널 --%>
    <div class="sidebar-panel" id="panel-expense">
      <div class="expense-panel-inner">

        <%-- 총액 카드 --%>
        <div class="expense-summary">
          <div class="expense-summary__label">총 지출</div>
          <div class="expense-summary__amount">₩ 287,500</div>
          <div class="expense-summary__split">3인 기준</div>
          <div class="expense-summary__per">1인당 약 ₩ 95,833</div>
        </div>

        <%-- 카테고리 4칸 --%>
        <div class="expense-cats">
          <div class="expense-cat">
            <span class="expense-cat__icon">🏨</span>
            <span class="expense-cat__name">숙소</span>
            <span class="expense-cat__amt">₩ 120,000</span>
            <div class="expense-cat__bar"><div class="expense-cat__bar-fill" style="width:42%"></div></div>
          </div>
          <div class="expense-cat">
            <span class="expense-cat__icon">🍽️</span>
            <span class="expense-cat__name">식비</span>
            <span class="expense-cat__amt">₩ 87,500</span>
            <div class="expense-cat__bar"><div class="expense-cat__bar-fill" style="width:30%"></div></div>
          </div>
          <div class="expense-cat">
            <span class="expense-cat__icon">🚗</span>
            <span class="expense-cat__name">교통</span>
            <span class="expense-cat__amt">₩ 45,000</span>
            <div class="expense-cat__bar"><div class="expense-cat__bar-fill" style="width:16%;background:linear-gradient(135deg,#C2B8D9,#E0BBC2)"></div></div>
          </div>
          <div class="expense-cat">
            <span class="expense-cat__icon">🎯</span>
            <span class="expense-cat__name">관광</span>
            <span class="expense-cat__amt">₩ 35,000</span>
            <div class="expense-cat__bar"><div class="expense-cat__bar-fill" style="width:12%;background:linear-gradient(135deg,#A8C8E1,#89CFF0)"></div></div>
          </div>
        </div>

        <%-- 최근 지출 --%>
        <div class="expense-section-head">
          <span class="expense-list-title">최근 지출 내역</span>
          <button class="expense-list-more" onclick="showToast('전체 내역 기능 준비 중')">전체 보기 →</button>
        </div>

        <div class="expense-item">
          <div class="expense-item__icon-wrap">🏨</div>
          <div class="expense-item__info">
            <div class="expense-item__name">스테이 밤편지</div>
            <div class="expense-item__detail">3/10 · 나 결제</div>
          </div>
          <span class="expense-item__amt">₩ 120,000</span>
        </div>
        <div class="expense-item">
          <div class="expense-item__icon-wrap">🍽️</div>
          <div class="expense-item__info">
            <div class="expense-item__name">흑돼지거리 맛집</div>
            <div class="expense-item__detail">3/10 · 지민 결제</div>
          </div>
          <span class="expense-item__amt">₩ 55,500</span>
        </div>
        <div class="expense-item">
          <div class="expense-item__icon-wrap">🚗</div>
          <div class="expense-item__info">
            <div class="expense-item__name">렌터카</div>
            <div class="expense-item__detail">3/10 · 민준 결제</div>
          </div>
          <span class="expense-item__amt">₩ 45,000</span>
        </div>

        <button class="btn-add-expense" onclick="showToast('💸 지출 추가 기능 연동 예정')">
          <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
          지출 추가
        </button>

      </div>
    </div>

    <%-- 투표 패널 --%>
    <div class="sidebar-panel" id="panel-vote">
      <div class="vote-panel-inner">

        <div class="vote-panel-head">
          <span class="vote-panel-title">동행자 투표</span>
          <button class="btn-new-vote" onclick="showToast('투표 생성 기능 연동 예정')">+ 투표 만들기</button>
        </div>

        <div class="vote-cards-grid">

          <div class="vote-card">
            <div class="vote-card__emoji">🍽️</div>
            <div class="vote-card__title">Day2 저녁 어디서 먹을까요?</div>
            <div class="vote-card__sub">
              <span>3명 참여</span>
              <span class="vote-card__sub-dot"></span>
              <span>12시간 남음</span>
            </div>
            <div class="vote-option">
              <div class="vote-option__top"><span class="vote-option__name">흑돼지 전문점 A</span><span class="vote-option__pct">67%</span></div>
              <div class="vote-bar-bg"><div class="vote-bar-fill" style="width:67%"></div></div>
            </div>
            <div class="vote-option">
              <div class="vote-option__top"><span class="vote-option__name">해물뚝배기 B</span><span class="vote-option__pct">33%</span></div>
              <div class="vote-bar-bg"><div class="vote-bar-fill" style="width:33%;background:linear-gradient(135deg,#C2B8D9,#E0BBC2)"></div></div>
            </div>
            <div class="vote-card__divider"></div>
            <button class="btn-vote voted">✓ 흑돼지로 투표함</button>
          </div>

          <div class="vote-card">
            <div class="vote-card__emoji">🏄</div>
            <div class="vote-card__title">Day3 오후 액티비티</div>
            <div class="vote-card__sub">
              <span>2명 참여</span>
              <span class="vote-card__sub-dot"></span>
              <span>진행 중</span>
            </div>
            <div class="vote-option">
              <div class="vote-option__top"><span class="vote-option__name">서핑 체험</span><span class="vote-option__pct">50%</span></div>
              <div class="vote-bar-bg"><div class="vote-bar-fill" style="width:50%"></div></div>
            </div>
            <div class="vote-option">
              <div class="vote-option__top"><span class="vote-option__name">스노클링</span><span class="vote-option__pct">50%</span></div>
              <div class="vote-bar-bg"><div class="vote-bar-fill" style="width:50%;background:linear-gradient(135deg,#C2B8D9,#E0BBC2)"></div></div>
            </div>
            <div class="vote-card__divider"></div>
            <button class="btn-vote" onclick="castVote(this)">투표하기</button>
          </div>

        </div><%-- /vote-cards-grid --%>
      </div>
    </div>

    <%-- 편집 모드: 좌측 추천 사이드바 --%>
    <div class="edit-recommend-panel" id="editRecommendPanel">

      <%-- 헤더 + 검색바 + 탭 --%>
      <div class="rp-header">
      
        <div class="rp-searchbar">
          <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" style="flex-shrink:0;color:var(--light)"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
          <input type="text" class="rp-search-input" placeholder="장소 이름으로 검색…" id="rpSearchInput" oninput="searchRpCards(this.value)">
          <button class="rp-search-clear" id="rpSearchClear" onclick="clearRpSearch()" style="display:none">✕</button>
        </div>
        <div class="rp-tabs">
          <button class="rp-tab active" id="rpTab-suggest" onclick="switchRpTab('suggest',this)">추천 장소</button>
          <button class="rp-tab" id="rpTab-summary" onclick="switchRpTab('summary',this)">일정 요약</button>
          <button class="rp-tab" id="rpTab-weather" onclick="switchRpTab('weather',this)">날씨</button>
        </div>
      </div>

      <%-- ── 탭: 추천 장소 ── --%>
      <div class="rp-pane active" id="rpPane-suggest">
        <div class="rp-filter">
          <button class="rp-filter-btn active" onclick="filterRec(this,'all')">전체</button>
          <button class="rp-filter-btn" onclick="filterRec(this,'stay')">🏨 숙소</button>
          <button class="rp-filter-btn" onclick="filterRec(this,'tour')">🏔 관광</button>
          <button class="rp-filter-btn" onclick="filterRec(this,'eat')">🍽 맛집</button>
          <button class="rp-filter-btn" onclick="filterRec(this,'cafe')">☕ 카페</button>
        </div>

        <div class="rp-cards" id="rpCards">

          <div class="rp-card" data-cat="stay" data-name="스테이 밤편지">
            <div class="rp-card-img-wrap">
              <img class="rp-card-thumb-img" src="https://images.unsplash.com/photo-1566073771259-6a8506099945?w=400&q=80&auto=format&fit=crop" alt="스테이 밤편지" loading="lazy" onerror="this.style.display='none'">
              <span class="rp-card-cat-badge">🏨 숙소</span>
            </div>
            <div class="rp-card-info">
              <div class="rp-card-name">스테이 밤편지</div>
              <div class="rp-card-addr">서귀포 남원읍 · 오션뷰 독채</div>
              <div class="rp-card-meta-row">
                <span class="rp-meta-item">🕐 체크인 15:00</span>
                <span class="rp-meta-item">⏱ 1박</span>
              </div>
              <div class="rp-card-foot">
                <span class="rp-badge purple">🏨 숙소</span>
                <button class="rp-add-btn" onclick="event.stopPropagation();openAddToDay('스테이 밤편지','서귀포 남원읍')">+ 일정 추가</button>
              </div>
            </div>
          </div>
          <div class="rp-card" data-cat="stay" data-name="제주 한옥 스테이">
            <div class="rp-card-img-wrap">
              <img class="rp-card-thumb-img" src="https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=400&q=80&auto=format&fit=crop" alt="제주 한옥 스테이" loading="lazy" onerror="this.style.display='none'">
              <span class="rp-card-cat-badge">🏨 숙소</span>
            </div>
            <div class="rp-card-info">
              <div class="rp-card-name">제주 한옥 스테이</div>
              <div class="rp-card-addr">제주시 애월읍 · 한옥 감성</div>
              <div class="rp-card-meta-row">
                <span class="rp-meta-item">🕐 체크인 15:00</span>
                <span class="rp-meta-item">⏱ 1박</span>
              </div>
              <div class="rp-card-foot">
                <span class="rp-badge purple">🏨 숙소</span>
                <button class="rp-add-btn" onclick="event.stopPropagation();openAddToDay('제주 한옥 스테이','제주시 애월읍')">+ 일정 추가</button>
              </div>
            </div>
          </div>
          <div class="rp-card" data-cat="tour" data-name="한라산 영실 코스">
            <div class="rp-card-img-wrap">
              <img class="rp-card-thumb-img" src="https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?w=400&q=80&auto=format&fit=crop" alt="한라산 영실 코스" loading="lazy" onerror="this.style.display='none'">
              <span class="rp-card-cat-badge">🥾 트레킹</span>
            </div>
            <div class="rp-card-info">
              <div class="rp-card-name">한라산 영실 코스</div>
              <div class="rp-card-addr">서귀포시 · 영실~윗세오름</div>
              <div class="rp-card-meta-row">
                <span class="rp-meta-item">🕐 05:00~12:00</span>
                <span class="rp-meta-item">⏱ 3~4시간</span>
              </div>
              <div class="rp-card-foot">
                <span class="rp-badge blue">🥾 트레킹</span>
                <button class="rp-add-btn" onclick="event.stopPropagation();openAddToDay('한라산 영실 코스','서귀포시 해안동')">+ 일정 추가</button>
              </div>
            </div>
          </div>
          <div class="rp-card" data-cat="tour" data-name="협재해수욕장">
            <div class="rp-card-img-wrap">
              <img class="rp-card-thumb-img" src="https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=400&q=80&auto=format&fit=crop" alt="협재해수욕장" loading="lazy" onerror="this.style.display='none'">
              <span class="rp-card-cat-badge">🏖 해수욕</span>
            </div>
            <div class="rp-card-info">
              <div class="rp-card-name">협재해수욕장</div>
              <div class="rp-card-addr">제주시 한림읍 · 에메랄드 바다</div>
              <div class="rp-card-meta-row">
                <span class="rp-meta-item">🕐 연중무휴</span>
                <span class="rp-meta-item">⏱ 1~2시간</span>
              </div>
              <div class="rp-card-foot">
                <span class="rp-badge pink">🏖 해수욕</span>
                <button class="rp-add-btn" onclick="event.stopPropagation();openAddToDay('협재해수욕장','제주시 한림읍')">+ 일정 추가</button>
              </div>
            </div>
          </div>
          <div class="rp-card" data-cat="tour" data-name="비자림">
            <div class="rp-card-img-wrap">
              <img class="rp-card-thumb-img" src="https://images.unsplash.com/photo-1448375240586-882707db888b?w=400&q=80&auto=format&fit=crop" alt="비자림" loading="lazy" onerror="this.style.display='none'">
              <span class="rp-card-cat-badge">🌳 자연</span>
            </div>
            <div class="rp-card-info">
              <div class="rp-card-name">비자림</div>
              <div class="rp-card-addr">제주시 구좌읍 · 수령 500~800년</div>
              <div class="rp-card-meta-row">
                <span class="rp-meta-item">🕐 09:00~18:00</span>
                <span class="rp-meta-item">⏱ 1~2시간</span>
              </div>
              <div class="rp-card-foot">
                <span class="rp-badge green">🌳 자연</span>
                <button class="rp-add-btn" onclick="event.stopPropagation();openAddToDay('비자림','제주시 구좌읍')">+ 일정 추가</button>
              </div>
            </div>
          </div>
          <div class="rp-card" data-cat="tour" data-name="성산일출봉">
            <div class="rp-card-img-wrap">
              <img class="rp-card-thumb-img" src="https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?w=400&q=80&auto=format&fit=crop" alt="성산일출봉" loading="lazy" onerror="this.style.display='none'">
              <span class="rp-card-cat-badge">🏔 관광</span>
            </div>
            <div class="rp-card-info">
              <div class="rp-card-name">성산일출봉</div>
              <div class="rp-card-addr">서귀포시 성산읍 · 유네스코 세계유산</div>
              <div class="rp-card-meta-row">
                <span class="rp-meta-item">🕐 07:00~20:00</span>
                <span class="rp-meta-item">⏱ 1.5시간</span>
              </div>
              <div class="rp-card-foot">
                <span class="rp-badge blue">🏔 관광</span>
                <button class="rp-add-btn" onclick="event.stopPropagation();openAddToDay('성산일출봉','서귀포시 성산읍')">+ 일정 추가</button>
              </div>
            </div>
          </div>
          <div class="rp-card" data-cat="eat" data-name="돔베고기 연구소">
            <div class="rp-card-img-wrap">
              <img class="rp-card-thumb-img" src="https://images.unsplash.com/photo-1529543544282-ea669407fca3?w=400&q=80&auto=format&fit=crop" alt="돔베고기 연구소" loading="lazy" onerror="this.style.display='none'">
              <span class="rp-card-cat-badge">🍽 맛집</span>
            </div>
            <div class="rp-card-info">
              <div class="rp-card-name">돔베고기 연구소</div>
              <div class="rp-card-addr">제주시 연동 · 현지인 단골맛집</div>
              <div class="rp-card-meta-row">
                <span class="rp-meta-item">🕐 11:30~21:00 (월 휴무)</span>
                <span class="rp-meta-item">⏱ 1~1.5시간</span>
              </div>
              <div class="rp-card-foot">
                <span class="rp-badge pink">🍽 맛집</span>
                <button class="rp-add-btn" onclick="event.stopPropagation();openAddToDay('돔베고기 연구소','제주시 연동')">+ 일정 추가</button>
              </div>
            </div>
          </div>
          <div class="rp-card" data-cat="eat" data-name="갈치조림 골목">
            <div class="rp-card-img-wrap">
              <img class="rp-card-thumb-img" src="https://images.unsplash.com/photo-1498654896293-37aec27f0cf3?w=400&q=80&auto=format&fit=crop" alt="갈치조림 골목" loading="lazy" onerror="this.style.display='none'">
              <span class="rp-card-cat-badge">🍽 맛집</span>
            </div>
            <div class="rp-card-info">
              <div class="rp-card-name">갈치조림 골목</div>
              <div class="rp-card-addr">서귀포시 서홍동 · 제주 향토 해산물</div>
              <div class="rp-card-meta-row">
                <span class="rp-meta-item">🕐 11:00~21:00</span>
                <span class="rp-meta-item">⏱ 1시간</span>
              </div>
              <div class="rp-card-foot">
                <span class="rp-badge pink">🍽 맛집</span>
                <button class="rp-add-btn" onclick="event.stopPropagation();openAddToDay('갈치조림 골목','서귀포시 서홍동')">+ 일정 추가</button>
              </div>
            </div>
          </div>
          <div class="rp-card" data-cat="cafe" data-name="카페 이음">
            <div class="rp-card-img-wrap">
              <img class="rp-card-thumb-img" src="https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?w=400&q=80&auto=format&fit=crop" alt="카페 이음" loading="lazy" onerror="this.style.display='none'">
              <span class="rp-card-cat-badge">☕ 카페</span>
            </div>
            <div class="rp-card-info">
              <div class="rp-card-name">카페 이음</div>
              <div class="rp-card-addr">서귀포시 대정읍 · 마라도 오션뷰</div>
              <div class="rp-card-meta-row">
                <span class="rp-meta-item">🕐 10:00~19:00 (화 휴무)</span>
                <span class="rp-meta-item">⏱ 1~1.5시간</span>
              </div>
              <div class="rp-card-foot">
                <span class="rp-badge purple">☕ 카페</span>
                <button class="rp-add-btn" onclick="event.stopPropagation();openAddToDay('카페 이음','서귀포시 대정읍')">+ 일정 추가</button>
              </div>
            </div>
          </div>
          <div class="rp-card" data-cat="cafe" data-name="카페 숨비소리">
            <div class="rp-card-img-wrap">
              <img class="rp-card-thumb-img" src="https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=400&q=80&auto=format&fit=crop" alt="카페 숨비소리" loading="lazy" onerror="this.style.display='none'">
              <span class="rp-card-cat-badge">☕ 카페</span>
            </div>
            <div class="rp-card-info">
              <div class="rp-card-name">카페 숨비소리</div>
              <div class="rp-card-addr">서귀포시 성산읍 · 일출봉 뷰</div>
              <div class="rp-card-meta-row">
                <span class="rp-meta-item">🕐 09:00~18:00 (수 휴무)</span>
                <span class="rp-meta-item">⏱ 1시간</span>
              </div>
              <div class="rp-card-foot">
                <span class="rp-badge blue">☕ 카페</span>
                <button class="rp-add-btn" onclick="event.stopPropagation();openAddToDay('카페 숨비소리','서귀포시 성산읍')">+ 일정 추가</button>
              </div>
            </div>
          </div>
        <div class="rp-no-result" id="rpNoResult">검색 결과가 없어요 🔍</div>
        </div><%-- /rp-cards --%>
      </div>

      <%-- ── 탭: 일정 요약 ── --%>
      <div class="rp-pane" id="rpPane-summary">
        <div class="rp-summary-wrap">
          <%-- Day별 타임라인 — JS renderDaySummary()로 채워짐 --%>
          <div class="rp-day-accordion" id="rpDayAccordion"></div>
        </div>
      </div>

      <%-- ── 탭: 날씨 ── --%>
      <div class="rp-pane" id="rpPane-weather">
        <div class="rp-weather">

          <%-- 오늘(첫날) 메인 카드 --%>
          <div class="rp-weather-main">
            <div class="rp-weather-main-icon">🌤</div>
            <div class="rp-weather-main-info">
              <div class="rp-weather-main-city">📍 제주도 · 3월 10일 (화)</div>
              <div class="rp-weather-main-temp">14°</div>
              <div class="rp-weather-main-desc">구름 조금, 바람 약함</div>
            </div>
            <div class="rp-weather-main-side">
              <div class="rp-weather-main-hi">최고 17°</div>
              <div class="rp-weather-main-lo">최저 9°</div>
              <div class="rp-weather-main-rain">🌧 강수 10%</div>
            </div>
          </div>

          <%-- 4일 예보 --%>
          <div class="rp-weather-forecast">

            <div class="rp-weather-row">
              <span class="rp-wr-day">3/10 화</span>
              <span class="rp-wr-icon">🌤</span>
              <span class="rp-wr-desc">구름 조금</span>
              <span class="rp-wr-temp">17° <span>/ 9°</span></span>
              <span class="rp-rain-pill low">☔ 10%</span>
            </div>

            <div class="rp-weather-row">
              <span class="rp-wr-day">3/11 수</span>
              <span class="rp-wr-icon">⛅</span>
              <span class="rp-wr-desc">흐림</span>
              <span class="rp-wr-temp">13° <span>/ 8°</span></span>
              <span class="rp-rain-pill mid">☔ 20%</span>
            </div>

            <div class="rp-weather-row rp-weather-row--warn">
              <span class="rp-wr-day">3/12 목</span>
              <span class="rp-wr-icon">🌧</span>
              <span class="rp-wr-desc">비 예보</span>
              <span class="rp-wr-temp">11° <span>/ 7°</span></span>
              <span class="rp-rain-pill high">☔ 70%</span>
            </div>

            <div class="rp-weather-row">
              <span class="rp-wr-day">3/13 금</span>
              <span class="rp-wr-icon">🌤</span>
              <span class="rp-wr-desc">맑음</span>
              <span class="rp-wr-temp">15° <span>/ 10°</span></span>
              <span class="rp-rain-pill low">☔ 5%</span>
            </div>

          </div>
        </div>
      </div>

    </div><%-- /edit-recommend-panel --%>

    <%-- Day별 추가 선택 미니 팝업 --%>
    <div class="day-picker-popup" id="dayPickerPopup" style="display:none;">
      <div class="dpp-title">어느 날에 추가할까요?</div>
      <div class="dpp-days" id="dppDays">
        <button class="dpp-btn" onclick="addRecToDay(1)">DAY 1<br><span>3월 10일</span></button>
        <button class="dpp-btn" onclick="addRecToDay(2)">DAY 2<br><span>3월 11일</span></button>
        <button class="dpp-btn" onclick="addRecToDay(3)">DAY 3<br><span>3월 12일</span></button>
        <button class="dpp-btn" onclick="addRecToDay(4)">DAY 4<br><span>3월 13일</span></button>
      </div>
      <button class="dpp-cancel" onclick="closeDayPicker()">취소</button>
    </div>

    <%-- 너비 상태바 --%>
    <div class="sidebar-width-bar">
      <span class="sidebar-width-label" id="sidebarWidthLabel">360px</span>
      <div class="sidebar-width-btns">
        <button class="sidebar-width-btn" onclick="setSidebarWidth(260)" title="좁게">좁게</button>
        <button class="sidebar-width-btn" onclick="setSidebarWidth(360)" title="기본">기본</button>
        <button class="sidebar-width-btn" onclick="setSidebarWidth(520)" title="넓게">넓게</button>
        <button class="sidebar-width-btn" onclick="setSidebarWidth(720)" title="최대">최대</button>
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
   뷰 모드 전환 (편집 / 분할 / 지도)
══════════════════════════════ */
var currentMode = 'split';
var prevSidebarW = 360;

function setViewMode(mode) {
  if (mode === currentMode) return;

  var layout  = document.getElementById('wsLayout');
  var sidebar = document.getElementById('wsSidebar');
  var badge   = document.getElementById('modeBadge');

  /* 분할 모드에서 나갈 때 너비 저장 */
  if (currentMode === 'split') {
    prevSidebarW = parseInt(sidebar.style.width) || 360;
  }

  /* 레이아웃 클래스 교체 */
  layout.classList.remove('mode-edit', 'mode-map');
  if (mode === 'edit') layout.classList.add('mode-edit');
  if (mode === 'map')  layout.classList.add('mode-map');

  /* 분할로 돌아올 때 너비 복원 */
  if (mode === 'split') {
    requestAnimationFrame(function(){ setSidebarWidth(prevSidebarW); });
  }

  /* 버튼 active */
  document.querySelectorAll('.view-toggle-btn').forEach(function(b){ b.classList.remove('active'); });
  document.getElementById('vBtn-' + mode).classList.add('active');

  /* 중앙 모드 배지 업데이트 */
  var META = {
    edit:  { icon: '📋', label: '편집 전체 보기', toast: '📋 편집 모드 — 일정을 한눈에' },
    split: { icon: '↔️', label: '분할 보기',       toast: '↔️ 분할 모드' },
    map:   { icon: '🗺️', label: '지도 전체 보기',  toast: '🗺️ 지도 모드 — 동선 확인' }
  };
  var meta = META[mode];
  document.getElementById('modeBadgeIcon').textContent = meta.icon;
  document.getElementById('modeBadgeText').textContent = meta.label;
  badge.style.display = (mode === 'split') ? 'none' : 'flex';

  currentMode = mode;
  showToast(meta.toast);
}

/* 키보드 단축키: E=편집 / S=분할 / M=지도 */
document.addEventListener('keydown', function(e) {
  if (['INPUT','TEXTAREA','SELECT'].indexOf(e.target.tagName) !== -1) return;
  if (e.metaKey || e.ctrlKey || e.altKey) return;
  var k = e.key.toUpperCase();
  if (k === 'E') setViewMode('edit');
  if (k === 'S') setViewMode('split');
  if (k === 'M') setViewMode('map');
});

/* ══════════════════════════════
   사이드바 리사이저
══════════════════════════════ */
(function(){
  var sidebar  = document.getElementById('wsSidebar');
  var resizer  = document.getElementById('wsResizer');
  var label    = document.getElementById('sidebarWidthLabel');
  var MIN = 260, MAX = 720, DEFAULT = 360;
  var startX, startW, isDragging = false;

  // 툴팁
  var tip = document.createElement('div');
  tip.className = 'resize-tooltip';
  document.body.appendChild(tip);

  function setWidth(w) {
    w = Math.round(Math.max(MIN, Math.min(MAX, w)));
    sidebar.style.width = w + 'px';
    label.textContent = w + 'px';
    // 넓을 때 텍스트 wrap 허용
    sidebar.setAttribute('data-wide', w >= 480 ? 'true' : 'false');
  }

  function showTip(x, y, w) {
    tip.textContent = Math.round(w) + 'px';
    tip.style.left = (x + 14) + 'px';
    tip.style.top  = (y - 14) + 'px';
    tip.classList.add('show');
  }
  function hideTip() { tip.classList.remove('show'); }

  resizer.addEventListener('mousedown', function(e) {
    e.preventDefault();
    isDragging = true;
    startX = e.clientX;
    startW = sidebar.getBoundingClientRect().width;
    resizer.classList.add('dragging');
    document.body.classList.add('resizing');
    showTip(e.clientX, e.clientY, startW);
  });

  document.addEventListener('mousemove', function(e) {
    if (!isDragging) return;
    var w = startW + (e.clientX - startX);
    setWidth(w);
    showTip(e.clientX, e.clientY, w);
  });

  document.addEventListener('mouseup', function() {
    if (!isDragging) return;
    isDragging = false;
    resizer.classList.remove('dragging');
    document.body.classList.remove('resizing');
    hideTip();
    var w = sidebar.getBoundingClientRect().width;
    showToast('↔ ' + Math.round(w) + 'px 로 조절됨');
  });

  // 더블클릭 → 기본값 복귀
  resizer.addEventListener('dblclick', function() {
    sidebar.style.transition = 'width .3s cubic-bezier(.19,1,.22,1)';
    setWidth(DEFAULT);
    setTimeout(function(){ sidebar.style.transition = ''; }, 320);
    showToast('↔ 기본 너비로 초기화됨');
  });

  // 버튼 프리셋
  window.setSidebarWidth = function(w) {
    sidebar.style.transition = 'width .28s cubic-bezier(.19,1,.22,1)';
    setWidth(w);
    setTimeout(function(){ sidebar.style.transition = ''; }, 300);
  };

  // 초기값
  setWidth(DEFAULT);
})();

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
   추천 사이드바 인터랙션
══════════════════════════════ */

/* 탭 전환 */
function switchRpTab(name, btn) {
  document.querySelectorAll('.rp-tab').forEach(function(t){ t.classList.remove('active'); });
  document.querySelectorAll('.rp-pane').forEach(function(p){ p.classList.remove('active'); });
  btn.classList.add('active');
  document.getElementById('rpPane-' + name).classList.add('active');
  if (name === 'summary') renderDaySummary();
}

/* 카테고리 필터 */
var currentRpCat = 'all';
function filterRec(btn, cat) {
  currentRpCat = cat;
  document.querySelectorAll('.rp-filter-btn').forEach(function(b){ b.classList.remove('active'); });
  btn.classList.add('active');
  applyRpFilter();
}

/* 검색 + 필터 동시 적용 */
function applyRpFilter() {
  var q = (document.getElementById('rpSearchInput').value || '').trim().toLowerCase();
  var visCount = 0;
  document.querySelectorAll('.rp-card').forEach(function(card){
    var catOk = (currentRpCat === 'all' || card.getAttribute('data-cat') === currentRpCat);
    var nameOk = !q || (card.getAttribute('data-name') || '').toLowerCase().indexOf(q) !== -1 ||
                 (card.querySelector('.rp-card-addr') && card.querySelector('.rp-card-addr').textContent.toLowerCase().indexOf(q) !== -1);
    if (catOk && nameOk) { card.classList.remove('hidden'); visCount++; }
    else { card.classList.add('hidden'); }
  });
  var noResult = document.getElementById('rpNoResult');
  if (noResult) noResult.style.display = visCount === 0 ? 'block' : 'none';
}

function searchRpCards(val) {
  var clearBtn = document.getElementById('rpSearchClear');
  if (clearBtn) clearBtn.style.display = val ? 'block' : 'none';
  applyRpFilter();
}
function clearRpSearch() {
  var inp = document.getElementById('rpSearchInput');
  if (inp) inp.value = '';
  document.getElementById('rpSearchClear').style.display = 'none';
  applyRpFilter();
}

/* 일정에 추가 — Day 선택 팝업 열기 */
var pendingRecName = '', pendingRecAddr = '';
function openAddToDay(name, addr) {
  pendingRecName = name;
  pendingRecAddr = addr;
  var popup = document.getElementById('dayPickerPopup');
  popup.style.display = 'block';
  // 오버레이 역할 dim
  var dim = document.getElementById('dppDim');
  if (!dim) {
    dim = document.createElement('div');
    dim.id = 'dppDim';
    dim.style.cssText = 'position:fixed;inset:0;background:rgba(26,32,44,.3);z-index:599;';
    dim.onclick = closeDayPicker;
    document.body.appendChild(dim);
  }
  dim.style.display = 'block';
}
function closeDayPicker() {
  document.getElementById('dayPickerPopup').style.display = 'none';
  var dim = document.getElementById('dppDim');
  if (dim) dim.style.display = 'none';
}
function addRecToDay(day) {
  addPlaceToDay(null, pendingRecName, pendingRecAddr);
  // addPlaceToDay는 currentAddDay를 씀 — 여기선 직접 처리
  currentAddDay = day;
  var list = document.getElementById('places-' + day);
  var count = list.querySelectorAll('.place-card').length + 1;
  var colors = [
    'linear-gradient(135deg,#89CFF0,#FFB6C1)',
    'linear-gradient(135deg,#C2B8D9,#E0BBC2)',
    'linear-gradient(135deg,#A8C8E1,#89CFF0)',
    'linear-gradient(135deg,#89CFF0,#C2B8D9)'
  ];
  var color = colors[(day - 1) % colors.length];
  var card = document.createElement('div');
  card.className = 'place-card';
  card.draggable = true;
  card.setAttribute('data-day', day);
  card.innerHTML =
    '<div class="place-num" style="background:' + color + '">' + count + '</div>' +
    '<div class="place-info">' +
      '<div class="place-name">' + pendingRecName + '</div>' +
      '<div class="place-addr">' + pendingRecAddr + '</div>' +
      '<span class="place-type-badge">📍 장소</span>' +
    '</div>' +
    '<div class="place-actions">' +
      '<button class="place-action-btn" onclick="openMemo(this)">📝</button>' +
      '<button class="place-action-btn" onclick="removePlace(this)">🗑</button>' +
    '</div>';
  initDrag(card);
  list.appendChild(card);
  renumberPlaces(day);
  closeDayPicker();
  showToast('📍 DAY ' + day + '에 ' + pendingRecName + ' 추가됨!');
}

/* 일정 요약 렌더 — 심플 타임라인 */
function renderDaySummary() {
  var accordion = document.getElementById('rpDayAccordion');
  if (!accordion) return;

  var dayColors = [
    'linear-gradient(135deg,#89CFF0,#FFB6C1)',
    'linear-gradient(135deg,#C2B8D9,#E0BBC2)',
    'linear-gradient(135deg,#A8C8E1,#89CFF0)',
    'linear-gradient(135deg,#89CFF0,#C2B8D9)'
  ];
  var dayDates = ['3월 10일 (화)','3월 11일 (수)','3월 12일 (목)','3월 13일 (금)'];
  var html = '';

  for (var d = 1; d <= 4; d++) {
    var placeList = document.getElementById('places-' + d);
    var cards = placeList ? placeList.querySelectorAll('.place-card') : [];
    var isEmpty = cards.length === 0;

    html += '<div class="rp-da-item open" id="rpDa-' + d + '">';
    html += '<div class="rp-da-head" onclick="toggleDaItem(' + d + ')">';
    html += '<div class="rp-da-dot" style="background:' + dayColors[d-1] + '">D' + d + '</div>';
    html += '<span class="rp-da-date">' + dayDates[d-1] + '</span>';
    html += '<span class="rp-da-cnt' + (isEmpty ? ' empty' : '') + '">' + (isEmpty ? '없음' : cards.length + '개') + '</span>';
    html += '<span class="rp-da-arrow">▾</span>';
    html += '</div>';
    html += '<div class="rp-da-body">';
    if (isEmpty) {
      html += '<div class="rp-da-empty">아직 장소가 없어요</div>';
    } else {
      Array.prototype.forEach.call(cards, function(card, i) {
        var name = card.querySelector('.place-name') ? card.querySelector('.place-name').textContent : '';
        var badge = card.querySelector('.place-type-badge');
        var typeText = badge ? badge.textContent.trim() : '';
        html += '<div class="rp-da-place">';
        html += '<div class="rp-da-pnum" style="background:' + dayColors[d-1] + '">' + (i+1) + '</div>';
        html += '<span class="rp-da-pname">' + name + '</span>';
        if (typeText) html += '<span class="rp-da-pbadge">' + typeText + '</span>';
        html += '</div>';
      });
    }
    html += '</div></div>';
  }

  accordion.innerHTML = html;
}

function toggleDaItem(d) {
  var el = document.getElementById('rpDa-' + d);
  if (el) el.classList.toggle('open');
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
