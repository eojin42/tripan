<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <title>TripanSuper — 쿠폰 ${param.id != null ? '수정' : '등록'}</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/dist/css/admin.css">
  <style>
    /* 스크롤 보장 */
    html, body { height: auto; overflow-y: auto; }
    .main-wrapper { overflow-y: auto; }
    .main-content { padding-bottom: 60px; }

    .form-page { max-width: 960px; margin: 0 auto; }

    /* 2컬럼 폼 카드 */
    .form-card {
      background: #fff;
      border: 1px solid var(--border);
      border-radius: 18px;
      padding: 28px 32px;
      box-shadow: 0 4px 20px rgba(0,0,0,.04);
      margin-bottom: 16px;
      overflow: visible; /* 드롭다운이 카드 밖으로 나올 수 있도록 */
    }
    .form-card.partner-card {
      position: relative;
      z-index: 10; /* 아래 카드보다 위에 쌓여야 드롭다운이 안 가려짐 */
    }
	
    .card-title {
      font-size: 13px; font-weight: 800; color: var(--text);
      margin: 0 0 20px; padding-bottom: 14px;
      border-bottom: 1px solid var(--border);
      display: flex; align-items: center; gap: 8px;
    }
    .card-title i { color: var(--primary); font-size: 14px; }

    .grid-2 { display: grid; grid-template-columns: 1fr 1fr; gap: 16px; }
    .grid-3 { display: grid; grid-template-columns: 1fr 1fr 1fr; gap: 16px; }
    .col-span-2 { grid-column: span 2; }

    .fg { display: flex; flex-direction: column; gap: 6px; }
    .fg label {
      font-size: 11px; font-weight: 800; color: var(--muted);
      text-transform: uppercase; letter-spacing: .6px;
    }
    .fg select, .fg input, .fg textarea {
      width: 100%; border: 1.5px solid var(--border); border-radius: 10px;
      padding: 10px 14px; font-size: 14px; font-weight: 600;
      background: #fff; outline: none; transition: border-color .2s;
      box-sizing: border-box; font-family: inherit; color: var(--text);
    }
    .fg select:focus, .fg input:focus { border-color: var(--primary); box-shadow: 0 0 0 3px var(--primary-10); }
    .fg .hint { font-size: 11px; color: var(--muted); margin-top: -2px; }
    .input-wrap { position: relative; }
    .input-wrap input { padding-right: 36px; }
    .input-suffix {
      position: absolute; right: 12px; top: 50%;
      transform: translateY(-50%); font-size: 13px;
      color: var(--muted); font-weight: 700; pointer-events: none;
    }

    .condition-banner {
      padding: 11px 16px; border-radius: 10px; font-size: 13px;
      font-weight: 600; display: flex; align-items: center; gap: 8px;
      margin-top: 4px; margin-bottom: 20px;
    }
	.share-info {
	  display: flex;
	  align-items: flex-end; /* 입력창 하단 라인에 맞춤 */
	  padding-bottom: 10px;  /* 입력창과 시각적 높이 조절 */
	  font-size: 13px;
	  color: var(--muted);
	  font-weight: 600;
	  white-space: nowrap;
	}
    /* 하단 버튼 고정 */
    .form-actions {
      display: flex;
	  gap: 12px;
	  position: sticky; 
	  bottom: 0;
	  background: #fff;
	  padding: 16px 32px;
	  border-top: 1px solid var(--border);
	  border-radius: 0 0 18px 18px;
	  margin: 32px -32px -28px;
    }
    .btn-cancel {
      height: 44px; padding: 0 28px; border-radius: 10px; font-weight: 800;
      font-size: 14px; border: 1.5px solid var(--border);
      background: var(--bg); color: var(--text);
      cursor: pointer; font-family: inherit; transition: opacity .15s;
    }
    .btn-submit {
      flex: 1; height: 44px; border-radius: 10px; font-weight: 800;
      font-size: 14px; border: none; background: var(--primary); color: #fff;
      cursor: pointer; font-family: inherit; transition: opacity .15s;
    }
    .btn-cancel:hover, .btn-submit:hover { opacity: .82; }

    .back-link {
      display: inline-flex; align-items: center; gap: 6px;
      font-size: 13px; font-weight: 700; color: var(--muted);
      text-decoration: none; margin-bottom: 16px; transition: color .15s;
    }
    .back-link:hover { color: var(--text); }

    @media (max-width: 640px) {
      .grid-2, .grid-3 { grid-template-columns: 1fr; }
      .col-span-2 { grid-column: span 1; }
    }

    /* ── 적용 대상 섹션 ── */
    .target-search-row {
      display: flex; gap: 8px; align-items: center;
    }
    .target-search-row input {
      flex: 1; border: 1.5px solid var(--border); border-radius: 10px;
      padding: 10px 14px; font-size: 14px; font-weight: 600;
      background: #fff; outline: none; transition: border-color .2s;
      font-family: inherit; color: var(--text); box-sizing: border-box;
    }
    .target-search-row input:focus { border-color: var(--primary); box-shadow: 0 0 0 3px var(--primary-10); }
    .btn-search-icon {
      width: 42px; height: 42px; border-radius: 10px; border: 1.5px solid var(--border);
      background: var(--bg); cursor: pointer; font-size: 16px;
      display: flex; align-items: center; justify-content: center;
      transition: all .15s; flex-shrink: 0;
    }
    .btn-search-icon:hover { background: var(--primary); border-color: var(--primary); color: #fff; }

    .target-tags {
      display: flex; flex-wrap: wrap; gap: 8px;
      min-height: 40px; padding: 10px 12px;
      border: 1.5px dashed var(--border); border-radius: 10px;
      margin-top: 8px; background: var(--bg);
    }
    .target-tag {
      display: inline-flex; align-items: center; gap: 6px;
      padding: 4px 10px 4px 12px; border-radius: 20px;
      font-size: 12px; font-weight: 700;
    }
    .target-tag.include { background: #EFF6FF; color: #1D4ED8; border: 1px solid #BFDBFE; }
    .target-tag.exclude { background: #FFF1F2; color: #BE123C; border: 1px solid #FECDD3; }
    .target-tag button {
      background: none; border: none; cursor: pointer; padding: 0;
      font-size: 13px; line-height: 1; opacity: .6;
      color: inherit; font-weight: 900;
    }
    .target-tag button:hover { opacity: 1; }
    .target-empty-hint {
      font-size: 12px; color: var(--muted); align-self: center; font-style: italic;
    }

    /* ── 통합 모달 ── */
    .modal-backdrop {
      position: fixed; inset: 0; background: rgba(0,0,0,.45);
      z-index: 9000; display: flex; align-items: center; justify-content: center;
    }
    .modal-box {
      background: #fff; border-radius: 18px; width: 580px; max-width: 96vw;
      max-height: 82vh; display: flex; flex-direction: column;
      box-shadow: 0 24px 60px rgba(0,0,0,.2);
    }
    .modal-header {
      padding: 18px 24px 0; display: flex; align-items: center; justify-content: space-between;
    }
    .modal-header h3 { margin: 0; font-size: 15px; font-weight: 800; }
    .modal-close { background: none; border: none; font-size: 20px; cursor: pointer; color: var(--muted); line-height:1; }
    .modal-tabs {
      display: flex; padding: 12px 24px 0; border-bottom: 1px solid var(--border);
    }
    .modal-tab {
      padding: 8px 16px 10px; font-size: 13px; font-weight: 700; cursor: pointer;
      border: none; background: none; border-bottom: 2.5px solid transparent;
      color: var(--muted); font-family: inherit; transition: all .15s; margin-bottom: -1px;
    }
    .modal-tab.active { color: var(--primary); border-bottom-color: var(--primary); }
    .modal-tab:hover:not(.active) { color: var(--text); }
    .modal-search-row {
      padding: 14px 24px; display: flex; gap: 8px; border-bottom: 1px solid var(--border);
    }
    .modal-search-row input {
      flex: 1; border: 1.5px solid var(--border); border-radius: 10px;
      padding: 9px 14px; font-size: 14px; font-weight: 600;
      outline: none; font-family: inherit; transition: border-color .2s;
    }
    .modal-search-row input:focus { border-color: var(--primary); box-shadow: 0 0 0 3px var(--primary-10); }
    .modal-search-row button {
      padding: 0 18px; border-radius: 10px; border: none; height: 40px;
      background: var(--primary); color: #fff; font-weight: 700; font-size: 13px;
      cursor: pointer; font-family: inherit;
    }
    .modal-list { flex: 1; overflow-y: auto; padding: 4px 0; min-height: 200px; }
    .modal-pre-search {
      display: flex; flex-direction: column; align-items: center; justify-content: center;
      padding: 50px 0; color: var(--muted); gap: 10px;
    }
    .modal-pre-search .icon { font-size: 32px; opacity: .4; }
    .modal-pre-search p { margin: 0; font-size: 13px; font-weight: 600; }
    .modal-acc-row {
      display: flex; align-items: center; gap: 12px;
      padding: 10px 24px; cursor: pointer; transition: background .1s; user-select: none;
    }
    .modal-acc-row:hover { background: var(--bg); }
    .modal-acc-row input[type=checkbox] { width: 16px; height: 16px; cursor: pointer; accent-color: var(--primary); flex-shrink:0; }
    .modal-acc-info { flex: 1; }
    .modal-acc-name { font-size: 14px; font-weight: 700; }
    .modal-acc-sub  { font-size: 12px; color: var(--muted); margin-top: 2px; }
    .modal-acc-expand {
      font-size: 11px; font-weight: 700; color: var(--primary); padding: 3px 9px;
      background: none; border: 1px solid var(--primary); border-radius: 6px;
      cursor: pointer; white-space: nowrap; font-family: inherit; opacity: .7; transition: all .15s;
    }
    .modal-acc-expand:hover { opacity: 1; background: var(--primary); color: #fff; }
    .modal-room-row {
      display: flex; align-items: center; gap: 12px;
      padding: 8px 24px 8px 52px; cursor: pointer; transition: background .1s;
      background: #FAFBFC; border-left: 3px solid #E0E7FF; user-select: none;
    }
    .modal-room-row:hover { background: #EEF2FF; }
    .modal-room-row input[type=checkbox] { width: 15px; height: 15px; cursor: pointer; accent-color: var(--primary); flex-shrink:0; }
    .modal-room-name { font-size: 13px; font-weight: 600; flex: 1; }
    .modal-room-sub  { font-size: 11px; color: var(--muted); }
    .modal-loading { padding: 40px 0; text-align: center; color: var(--muted); font-size: 13px; }
    .modal-empty   { padding: 40px 0; text-align: center; color: var(--muted); font-size: 13px; }
    .modal-footer {
      padding: 12px 24px; border-top: 1px solid var(--border);
      display: flex; align-items: center; gap: 10px;
    }
    .modal-sel-count { flex: 1; font-size: 12px; color: var(--muted); font-weight: 600; }
    .modal-footer .btn-cancel {
      height: 38px; padding: 0 18px; border-radius: 8px; font-weight: 800;
      font-size: 13px; border: 1.5px solid var(--border);
      background: var(--bg); color: var(--text); cursor: pointer; font-family: inherit;
    }
    .modal-footer .btn-ok {
      height: 38px; padding: 0 18px; border-radius: 8px; border: none;
      background: var(--primary); color: #fff; font-weight: 800;
      font-size: 13px; cursor: pointer; font-family: inherit;
    }
  </style>
</head>
<body>

<div class="admin-layout">
  <jsp:include page="../layout/sidebar.jsp"><jsp:param name="activePage" value="coupon"/></jsp:include>
  <div class="main-wrapper">
    <jsp:include page="../layout/header.jsp" />

    <div id="app">
    <main class="main-content">
      <div class="form-page">

        <a href="${pageContext.request.contextPath}/admin/coupon/main" class="back-link">← 쿠폰 목록으로</a>

        <div class="page-header fade-up" style="margin-bottom:20px;">
          <div>
            <h1>{{ isEdit ? '쿠폰 수정' : '쿠폰 직접 등록' }}</h1>
            <p>{{ isEdit ? '쿠폰 정보를 수정합니다.' : '관리자가 직접 플랫폼 쿠폰을 등록합니다.' }}</p>
          </div>
        </div>

        <!-- ── 카드 4: 적용 대상 ── -->
        

        <div class="form-card fade-up">
          <div class="card-title">📋 기본 정보</div>

          <!-- 쿠폰명 -->
          <div class="fg" style="margin-bottom:16px;">
            <label>쿠폰명 <span style="color:var(--danger);">*</span></label>
            <input type="text" v-model="form.couponName" placeholder="예) 신규 가입 10% 할인">
          </div>

          <div class="grid-3" style="margin-bottom:16px;">
            <!-- 할인 유형 -->
            <div class="fg">
              <label>할인 유형 <span style="color:var(--danger);">*</span></label>
              <select v-model="form.discountType" @change="form.discountAmount=''">
                <option value="FIXED">정액 (원)</option>
                <option value="PERCENT">정률 (%)</option>
              </select>
            </div>
            <!-- 할인 금액/율 -->
            <div class="fg">
              <label>할인 금액/율 <span style="color:var(--danger);">*</span></label>
              <div class="input-wrap">
                <input v-if="form.discountType==='FIXED'" type="text" inputmode="numeric"
                       :value="formatNumber(form.discountAmount)"
                       @input="e => form.discountAmount = parseNumber(e.target.value)"
                       placeholder="예) 5,000">
                <input v-else type="number" v-model="form.discountAmount" min="1" max="100"
                       @input="e => { if(e.target.value>100) form.discountAmount=100; if(e.target.value<1&&e.target.value!=='') form.discountAmount=1; }"
                       placeholder="예) 10">
                <span class="input-suffix">{{ form.discountType==='FIXED' ? '원' : '%' }}</span>
              </div>
            </div>
            <!-- 최대 할인 (정률만) / 최소 주문 금액 -->
            <div class="fg" v-if="form.discountType==='PERCENT'">
              <label>최대 할인 금액 (선택)</label>
              <div class="input-wrap">
                <input type="text" inputmode="numeric"
                       :value="formatNumber(form.maxDiscountAmount)"
                       @input="e => form.maxDiscountAmount = parseNumber(e.target.value)"
                       placeholder="제한 없으면 비워두세요">
                <span class="input-suffix">원</span>
              </div>
            </div>
            <div class="fg" v-else>
              <label>최소 주문 금액 (선택)</label>
              <div class="input-wrap">
                <input type="text" inputmode="numeric"
                       :value="formatNumber(form.minOrderAmount)"
                       @input="e => form.minOrderAmount = parseNumber(e.target.value)"
                       placeholder="제한 없으면 비워두세요">
                <span class="input-suffix">원</span>
              </div>
            </div>
          </div>

          <!-- 정률일 때 최소 주문 금액 별도 행 -->
          <div class="fg" v-if="form.discountType==='PERCENT'" style="margin-bottom:16px;">
            <label>최소 주문 금액 (선택)</label>
            <div class="input-wrap">
              <input type="text" inputmode="numeric"
                     :value="formatNumber(form.minOrderAmount)"
                     @input="e => form.minOrderAmount = parseNumber(e.target.value)"
                     placeholder="예) 30,000 (제한 없으면 비워두세요)">
              <span class="input-suffix">원</span>
            </div>
            <span class="hint">입력 시 해당 금액 이상 결제할 때만 쿠폰 사용 가능</span>
          </div>

          <!-- 유효기간 -->
          <div class="grid-2">
            <div class="fg">
              <label>유효기간 시작 <span style="color:var(--danger);">*</span></label>
              <input type="datetime-local" v-model="form.validFrom">
            </div>
            <div class="fg">
              <label>유효기간 만료 <span style="color:var(--danger);">*</span></label>
              <input type="datetime-local" v-model="form.validUntil">
            </div>
          </div>
        </div>

        <!-- 파트너 & 부담 비율 -->
        <div class="form-card partner-card fade-up">
		  <div class="card-title">🤝 파트너 & 부담 비율</div>
		
		  <div class="grid-3">
		    <div class="fg col-span-2" style="position:relative; z-index:100;">
		      <label>파트너사 (비우면 플랫폼 쿠폰)</label>
		      <input type="text" v-model="partnerSearch"
		             placeholder="파트너사명 검색 (비우면 플랫폼 쿠폰)"
		             @input="onPartnerSearch" @focus="showPartnerDropdown=true"
		             @blur="hidePartnerDropdown" autocomplete="off">
		      
		      <div v-if="showPartnerDropdown && filteredPartners.length > 0"
		           style="position:absolute;top:calc(100% + 4px);left:0;right:0;background:#fff;border:1.5px solid var(--border);border-radius:10px;box-shadow:0 12px 30px rgba(0,0,0,.15);z-index:9999;max-height:200px;overflow-y:auto;">
		        <div style="padding:8px 14px;font-size:12px;color:var(--muted);cursor:pointer;border-bottom:1px solid var(--border);"
		             @mousedown.prevent="selectPartner(null,'')">플랫폼 쿠폰 (파트너 없음)</div>
		        <div v-for="p in filteredPartners" :key="p.partnerId"
		             style="padding:10px 14px;font-size:14px;font-weight:600;cursor:pointer;"
		             @mousedown.prevent="selectPartner(p.partnerId, p.partnerName)"
		             @mouseover="$event.target.style.background='var(--bg)'"
		             @mouseout="$event.target.style.background=''">{{ p.partnerName }}</div>
		      </div>
		    </div>
		
		    <div style="display: flex; gap: 12px;">
		        <div class="fg" style="flex: 1;">
		          <label>플랫폼 비율 (%)</label>
		          <div class="input-wrap">
		            <input type="number" v-model="form.platformShare" min="0" max="100"
		                   :disabled="!form.partnerId"
		                   :style="!form.partnerId?'background:var(--bg);color:var(--muted);':''">
		            <span class="input-suffix">%</span>
		          </div>
		        </div>
		        
		        <div class="share-info">
		            <span>파트너: <strong style="color:var(--text);">{{ 100 - form.platformShare }}%</strong></span>
		        </div>
		    </div>
		  </div>
		
		  <div v-if="!form.partnerId" style="margin-top:12px; font-size:12px; color:#C2410C; font-weight:600;">
		    ⚠ 플랫폼 쿠폰은 100% 플랫폼 부담으로 고정됩니다.
		  </div>
		</div>
		
		<div class="form-card fade-up">
          <div class="card-title">🏨 적용 대상</div>

          <!-- 숙소 타입 필터 -->
          <div class="fg" style="margin-bottom:20px;">
            <label>숙소 타입 (선택)</label>
            <select v-model="form.targetAccType" multiple style="height:auto;min-height:42px;">
              <option value="">전체 타입</option>
              <option v-for="t in accTypeOptions" :key="t" :value="t">{{ t }}</option>
            </select>
            <span class="hint">Ctrl(Cmd)+클릭으로 여러 타입 선택</span>
          </div>

          <!-- 적용 숙소 -->
          <div style="margin-bottom:20px;">
            <label style="font-size:11px;font-weight:800;color:var(--muted);text-transform:uppercase;letter-spacing:.6px;display:block;margin-bottom:8px;">
              적용 숙소 지정 (선택)
            </label>
            <div class="target-search-row">
              <input type="text" v-model="includeSearchKeyword" placeholder="숙소명 검색 후 추가..." readonly @click="openModal('include')" style="cursor:pointer;">
              <button class="btn-search-icon" @click="openModal('include')" title="숙소 검색">🔍</button>
            </div>
            <div class="target-tags">
              <span v-if="form.includeAccommodations.length===0" class="target-empty-hint">숙소 타입 조건에 해당하는 전체 숙소에 적용됩니다</span>
              <span v-for="acc in form.includeAccommodations" :key="acc.placeId" class="target-tag include">
                🏨 {{ acc.name }}
                <button @click="removeInclude(acc.placeId)">×</button>
              </span>
            </div>
          </div>

          <!-- 제외 숙소 / 제외 객실 -->
          <div>
            <label style="font-size:11px;font-weight:800;color:var(--muted);text-transform:uppercase;letter-spacing:.6px;display:block;margin-bottom:8px;">
              제외 대상 (선택)
            </label>
            <div style="display:flex;gap:8px;margin-bottom:8px;">
              <button type="button" style="flex:1;padding:9px 0;border:1.5px dashed #FECDD3;border-radius:10px;background:#FFF1F2;color:#BE123C;font-size:13px;font-weight:700;cursor:pointer;font-family:inherit;"
                      @click="openModal('excludeAcc')">🚫 제외 숙소 선택</button>
              <button type="button" style="flex:1;padding:9px 0;border:1.5px dashed #DDD6FE;border-radius:10px;background:#F5F3FF;color:#6D28D9;font-size:13px;font-weight:700;cursor:pointer;font-family:inherit;"
                      @click="openModal('excludeRoom')">🛏 제외 객실 선택</button>
            </div>
            <div class="target-tags">
              <span v-if="form.excludeAccommodations.length===0 && form.excludeRooms.length===0" class="target-empty-hint">제외 대상 없음</span>
              <span v-for="acc in form.excludeAccommodations" :key="'ea-'+acc.placeId" class="target-tag exclude">
                🚫 {{ acc.name }}
                <button @click="removeExclude(acc.placeId)">×</button>
              </span>
              <span v-for="room in form.excludeRooms" :key="'er-'+room.roomId"
                    style="display:inline-flex;align-items:center;gap:6px;padding:4px 10px 4px 12px;border-radius:20px;font-size:12px;font-weight:700;background:#F5F3FF;color:#6D28D9;border:1px solid #DDD6FE;">
                🛏 {{ room.accName }} · {{ room.roomName }}
                <button @click="removeExcludeRoom(room.roomId)" style="background:none;border:none;cursor:pointer;padding:0;font-size:13px;line-height:1;opacity:.6;color:inherit;font-weight:900;">×</button>
              </span>
            </div>
          </div>

          <div style="margin-top:14px;padding:11px 16px;background:#F8FAFC;border:1.5px solid var(--border);border-radius:10px;font-size:12px;color:var(--muted);font-weight:600;line-height:1.7;">
            📌 적용 범위:
            <span v-if="form.includeAccommodations.length>0">지정 숙소 {{ form.includeAccommodations.length }}개</span>
            <span v-else>타입<span v-if="form.targetAccType.filter(v=>v).length"> ({{ form.targetAccType.filter(v=>v).join(', ') }})</span></span>
            <span v-if="form.excludeAccommodations.length>0"> → 제외 숙소 {{ form.excludeAccommodations.length }}개</span>
            <span v-if="form.excludeRooms.length>0"> → 제외 객실 {{ form.excludeRooms.length }}개</span>
            <span v-if="form.includeAccommodations.length===0 && !form.targetAccType.filter(v=>v).length"> 전체 숙소</span>
          </div>
        </div>

        <!-- ── 통합 숙소/객실 선택 모달 ── -->
        <teleport to="body">
          <div v-if="showAccModal" class="modal-backdrop" @click.self="closeModal">
            <div class="modal-box">

              <!-- 헤더 -->
              <div class="modal-header">
                <h3>🏨 적용 대상 선택</h3>
                <button class="modal-close" @click="closeModal">✕</button>
              </div>

              <!-- 탭: 적용숙소 / 제외숙소 / 제외객실 -->
              <div class="modal-tabs">
                <button class="modal-tab" :class="{active: modalTab==='include'}"
                        @click="switchTab('include')">✅ 적용 숙소</button>
                <button class="modal-tab" :class="{active: modalTab==='excludeAcc'}"
                        @click="switchTab('excludeAcc')">🚫 제외 숙소</button>
                <button class="modal-tab" :class="{active: modalTab==='excludeRoom'}"
                        @click="switchTab('excludeRoom')">🛏 제외 객실</button>
              </div>

              <!-- 검색 바 -->
              <div class="modal-search-row">
                <input type="text" v-model="modalKeyword"
                       :placeholder="modalTab==='excludeRoom' ? '숙소명으로 검색 후 객실 선택...' : '숙소명 또는 지역으로 검색...'"
                       @keyup.enter="runSearch">
                <button @click="runSearch">검색</button>
              </div>

              <!-- 목록 -->
              <div class="modal-list">

                <!-- 검색 전 안내 -->
                <div v-if="!modalSearched" class="modal-pre-search">
                  <div class="icon">🔍</div>
                  <p>검색어를 입력하고 검색 버튼을 눌러주세요</p>
                </div>

                <!-- 로딩 -->
                <div v-else-if="modalLoading" class="modal-loading">검색 중...</div>

                <!-- 결과 없음 -->
                <div v-else-if="modalAccResults.length===0" class="modal-empty">검색 결과가 없습니다</div>

                <!-- 적용/제외숙소 탭: 숙소 체크박스 목록 -->
                <template v-else-if="modalTab !== 'excludeRoom'">
                  <div v-for="acc in modalAccResults" :key="acc.placeId"
                       class="modal-acc-row" @click="toggleAccSelect(acc)">
                    <input type="checkbox" :checked="isAccSelected(acc.placeId)" @click.stop="toggleAccSelect(acc)">
                    <div class="modal-acc-info">
                      <div class="modal-acc-name">{{ acc.name }}</div>
                      <div class="modal-acc-sub">{{ acc.accommodationType || '숙소 타입 미지정' }}</div>
                    </div>
                  </div>
                </template>

                <!-- 제외객실 탭: 숙소 클릭 → 객실 펼침 (2단계) -->
                <template v-else>
                  <template v-for="acc in modalAccResults" :key="acc.placeId">
                    <!-- 숙소 행 -->
                    <div class="modal-acc-row" @click="toggleRoomExpand(acc.placeId)">
                      <div class="modal-acc-info">
                        <div class="modal-acc-name">
                          {{ expandedAccId === acc.placeId ? '▼' : '▶' }} {{ acc.name }}
                        </div>
                        <div class="modal-acc-sub">{{ acc.accommodationType || '숙소 타입 미지정' }}
                          <span v-if="countSelectedRooms(acc.placeId) > 0"
                                style="color:var(--primary);font-weight:700;">
                            &nbsp;· {{ countSelectedRooms(acc.placeId) }}개 객실 선택됨
                          </span>
                        </div>
                      </div>
                      <button class="modal-acc-expand" @click.stop="toggleRoomExpand(acc.placeId)">
                        {{ expandedAccId === acc.placeId ? '접기' : '객실 보기' }}
                      </button>
                    </div>
                    <!-- 객실 행 (펼침) -->
                    <template v-if="expandedAccId === acc.placeId">
                      <div v-if="roomLoading" class="modal-loading" style="padding:16px 0 16px 52px;">객실 불러오는 중...</div>
                      <div v-for="room in expandedRooms" :key="room.roomId"
                           class="modal-room-row" @click="toggleRoomSelect(room, acc)">
                        <input type="checkbox" :checked="isRoomSelected(room.roomId)" @click.stop="toggleRoomSelect(room, acc)">
                        <span class="modal-room-name">{{ room.roomName }}</span>
                        <span class="modal-room-sub">기준 {{ room.roombasecount }}인 · 최대 {{ room.maxCapacity }}인</span>
                      </div>
                    </template>
                  </template>
                </template>

              </div>

              <!-- 푸터 -->
              <div class="modal-footer">
                <span class="modal-sel-count">
                  <template v-if="modalTab==='include'">적용 숙소 {{ form.includeAccommodations.length }}개 선택됨</template>
                  <template v-else-if="modalTab==='excludeAcc'">제외 숙소 {{ form.excludeAccommodations.length }}개 선택됨</template>
                  <template v-else>제외 객실 {{ form.excludeRooms.length }}개 선택됨</template>
                </span>
                <button class="btn-cancel" @click="closeModal">닫기</button>
                <button class="btn-ok" @click="closeModal">확인</button>
              </div>

            </div>
          </div>
        </teleport>

        <!-- ── 카드 3: 발급 조건 ── -->
        <div class="form-card fade-up">
          <div class="card-title">🎯 자동 발급 조건</div>

          <div class="grid-2" style="margin-bottom:14px;">
            <div class="fg">
              <label>발급 대상 조건</label>
              <select v-model="form.issueConditionType" @change="form.issueConditionValue=''">
                <option value="NONE">조건 없음 — 수동 발급</option>
                <option value="NEW_MEMBER">신규 회원가입</option>
                <option value="BOOKING_COUNT">숙소 예약 N회 달성</option>
                <option value="REVIEW_COUNT">리뷰 N개 작성</option>
                <option value="AMOUNT_SPENT">누적 결제 N원 이상</option>
              </select>
            </div>

            <!-- 조건값 입력 (숫자형) -->
            <div class="fg" v-if="['BOOKING_COUNT','REVIEW_COUNT'].includes(form.issueConditionType)">
              <label>
                {{ form.issueConditionType==='BOOKING_COUNT' ? '예약 완료 횟수' : '리뷰 작성 수' }}
                <span style="color:var(--danger);">*</span>
              </label>
              <div class="input-wrap">
                <input type="number" v-model="form.issueConditionValue" min="1"
                       :placeholder="form.issueConditionType==='BOOKING_COUNT' ? '예) 3' : '예) 5'">
                <span class="input-suffix">{{ form.issueConditionType==='BOOKING_COUNT' ? '회' : '개' }}</span>
              </div>
            </div>

            <!-- 금액형 -->
            <div class="fg" v-if="form.issueConditionType==='AMOUNT_SPENT'">
              <label>누적 결제 기준 금액 <span style="color:var(--danger);">*</span></label>
              <div class="input-wrap">
                <input type="text" inputmode="numeric"
                       :value="formatNumber(form.issueConditionValue)"
                       @input="e => form.issueConditionValue = parseNumber(e.target.value)"
                       placeholder="예) 100,000">
                <span class="input-suffix">원</span>
              </div>
            </div>
          </div>

          <!-- 조건 안내 배너 -->
          <div v-if="form.issueConditionType==='NONE'"
               class="condition-banner" style="background:#F8FAFC;border:1.5px solid var(--border);color:var(--muted);">
            📋 조건 없이 등록됩니다. 관리자가 직접 발급하거나 다른 방식으로 지급하세요.
          </div>
          <div v-if="form.issueConditionType==='NEW_MEMBER'"
               class="condition-banner" style="background:#EFF6FF;border:1.5px solid #BFDBFE;color:#1D4ED8;">
            🎉 회원가입 완료 시 자동으로 해당 회원의 쿠폰함에 발급됩니다.
          </div>
          <div v-if="form.issueConditionType==='BOOKING_COUNT'"
               class="condition-banner" style="background:#F0FDF4;border:1.5px solid #BBF7D0;color:#15803D;">
            🏨 숙소 예약을 입력한 횟수만큼 완료한 회원에게 자동 발급됩니다.
          </div>
          <div v-if="form.issueConditionType==='REVIEW_COUNT'"
               class="condition-banner" style="background:#FFFBEB;border:1.5px solid #FDE68A;color:#B45309;">
            ⭐ 리뷰를 입력한 개수 이상 작성한 회원에게 자동 발급됩니다.
          </div>
          <div v-if="form.issueConditionType==='AMOUNT_SPENT'"
               class="condition-banner" style="background:#FDF4FF;border:1.5px solid #E9D5FF;color:#7C3AED;">
            💳 누적 결제 금액이 기준 금액 이상인 회원에게 자동 발급됩니다.
          </div>

          <!-- 하단 버튼 (카드 내부 sticky) -->
          <div class="form-actions">
            <button class="btn-cancel" @click="goBack">취소</button>
            <button class="btn-submit" @click="submitForm">
              {{ isEdit ? '수정 저장' : '쿠폰 등록' }}
            </button>
          </div>
        </div>

      </div><!-- /form-page -->
    </main>
    </div><!-- /#app -->
  </div>
</div>



<jsp:include page="/WEB-INF/views/layout/vue_cdn.jsp" />

<script type="module">
import { createApp, ref, reactive, computed, onMounted } from 'vue';
import axios from 'axios';

const contextPath = '${pageContext.request.contextPath}' === '/' ? '' : '${pageContext.request.contextPath}';
  const _rawId = '${param.id}'; 
  const couponId = (_rawId && _rawId !== 'null' && _rawId !== '') ? _rawId : null;

  console.log('[Module 확인] 실제 사용할 ID:', couponId);
  
  createApp({
    setup() {

      const isEdit = ref(!!couponId);

      const form = reactive({
        couponName: '', discountType: 'FIXED', discountAmount: '',
        maxDiscountAmount: '', minOrderAmount: '', platformShare: 100, partnerId: '',
        validFrom: '', validUntil: '',
        issueConditionType: 'NONE', issueConditionValue: '',
        // ── 적용 대상 ──
        targetAccType: [],
        includeAccommodations: [],
        excludeAccommodations: [],
        excludeRooms: []          // [{roomId, roomName, placeId, accName}]
      });

      /* ── 숙소 타입 옵션 ── */
      const accTypeOptions = ref([]);

      const fetchAccTypeOptions = async () => {
        try {
          const res = await axios.get(`${contextPath}/api/admin/coupon/accommodation/types`);
          accTypeOptions.value = res.data;
        } catch(e) { console.error('숙소타입 옵션 오류', e); }
      };

      /* ── 적용/제외 태그 관리 ── */
      const includeSearchKeyword = ref('');
      const excludeSearchKeyword = ref('');

      const removeInclude = (placeId) => {
        form.includeAccommodations = form.includeAccommodations.filter(a => a.placeId !== placeId);
      };
      const removeExclude = (placeId) => {
        form.excludeAccommodations = form.excludeAccommodations.filter(a => a.placeId !== placeId);
      };
      const removeExcludeRoom = (roomId) => {
        form.excludeRooms = form.excludeRooms.filter(r => r.roomId !== roomId);
      };

      /* ── 통합 모달 상태 ── */
      const showAccModal    = ref(false);
      const modalTab        = ref('include');   // 'include' | 'excludeAcc' | 'excludeRoom'
      const modalKeyword    = ref('');
      const modalSearched   = ref(false);       // 검색 실행 여부 (true일 때만 결과 표시)
      const modalAccResults = ref([]);
      const modalLoading    = ref(false);

      // 제외 객실 탭 전용: 펼쳐진 숙소 + 로드된 객실
      const expandedAccId  = ref(null);
      const expandedRooms  = ref([]);
      const roomLoading    = ref(false);

      const openModal = (tab) => {
        modalTab.value      = tab;
        modalKeyword.value  = '';
        modalSearched.value = false;
        modalAccResults.value = [];
        expandedAccId.value = null;
        expandedRooms.value = [];
        showAccModal.value  = true;
      };
      const closeModal = () => { showAccModal.value = false; };

      const switchTab = (tab) => {
        modalTab.value      = tab;
        modalKeyword.value  = '';
        modalSearched.value = false;
        modalAccResults.value = [];
        expandedAccId.value = null;
        expandedRooms.value = [];
      };

      /* 숙소 검색 */
      const runSearch = async () => {
        if (!modalKeyword.value.trim()) return;
        modalLoading.value  = true;
        modalSearched.value = true;
        expandedAccId.value = null;
        expandedRooms.value = [];
        try {
          const res = await axios.get(`${contextPath}/api/admin/coupon/accommodation/search`, {
            params: { keyword: modalKeyword.value }
          });
          modalAccResults.value = res.data;
        } catch(e) {
          console.error('숙소 검색 오류', e);
          modalAccResults.value = [];
        } finally {
          modalLoading.value = false;
        }
      };

      /* 적용/제외숙소 탭 — 숙소 체크박스 토글 */
      const isAccSelected = (placeId) => {
        if (modalTab.value === 'include')
          return form.includeAccommodations.some(a => a.placeId === placeId);
        return form.excludeAccommodations.some(a => a.placeId === placeId);
      };
      const toggleAccSelect = (acc) => {
        if (modalTab.value === 'include') {
          const idx = form.includeAccommodations.findIndex(a => a.placeId === acc.placeId);
          idx >= 0 ? form.includeAccommodations.splice(idx, 1) : form.includeAccommodations.push(acc);
        } else {
          const idx = form.excludeAccommodations.findIndex(a => a.placeId === acc.placeId);
          idx >= 0 ? form.excludeAccommodations.splice(idx, 1) : form.excludeAccommodations.push(acc);
        }
      };

      /* 제외객실 탭 — 숙소 펼치기/접기 */
      const toggleRoomExpand = async (placeId) => {

	
        if (expandedAccId.value === placeId) {
          expandedAccId.value = null;
          expandedRooms.value = [];
          return;
        }
        expandedAccId.value = placeId;
        expandedRooms.value = [];
        roomLoading.value   = true;
        try {
		const url = `${contextPath}/api/admin/coupon/accommodation/${placeId}/rooms`;
console.log('placeId:', placeId);
console.log('room url:', url);
			
          const res = await axios.get(url);
          expandedRooms.value = res.data;
        } catch(e) {
           console.error('객실 목록 오류', e);
  console.error('응답 상태:', e?.response?.status);
  console.error('응답 데이터:', e?.response?.data);
  expandedRooms.value = [];
        } finally {
          roomLoading.value = false;
        }
      };

      const isRoomSelected = (roomId) => form.excludeRooms.some(r => r.roomId === roomId);
      const countSelectedRooms = (placeId) => form.excludeRooms.filter(r => r.placeId === placeId).length;

      const toggleRoomSelect = (room, acc) => {
        const idx = form.excludeRooms.findIndex(r => r.roomId === room.roomId);
        if (idx >= 0) {
          form.excludeRooms.splice(idx, 1);
        } else {
          form.excludeRooms.push({
            roomId:   room.roomId,
            roomName: room.roomName,
            placeId:  acc.placeId,
            accName:  acc.name
          });
        }
      };


      /* ── 숫자 포맷 ── */
      const formatNumber = (val) => {
        if (val === '' || val == null) return '';
        const num = Number(String(val).replace(/,/g, ''));
        return isNaN(num) ? '' : num.toLocaleString('ko-KR');
      };
      const parseNumber = (val) => {
        const num = Number(String(val).replace(/,/g, ''));
        return isNaN(num) ? '' : num;
      };

      /* ── 파트너 검색 ── */
      const partnerOptions      = ref([]);
      const partnerSearch       = ref('');
      const showPartnerDropdown = ref(false);
      const filteredPartners    = computed(() => {
        if (!partnerSearch.value.trim()) return partnerOptions.value;
        return partnerOptions.value.filter(p =>
          p.partnerName.toLowerCase().includes(partnerSearch.value.toLowerCase())
        );
      });
      const onPartnerSearch = () => {
        showPartnerDropdown.value = true;
        // 입력창을 직접 지우면 파트너 선택 해제 + 비율 100 리셋
        if (!partnerSearch.value.trim()) {
          form.partnerId = '';
          form.platformShare = 100;
        }
      };
      const hidePartnerDropdown = () => { setTimeout(() => { showPartnerDropdown.value = false; }, 150); };
      const selectPartner = (partnerId, partnerName) => {
        form.partnerId = partnerId || '';
        partnerSearch.value = partnerName || '';
        showPartnerDropdown.value = false;
        if (!partnerId) form.platformShare = 100;
      };

      /* ── 기존 쿠폰 불러오기 (수정 모드) ── */
      const loadCoupon = async () => {
        if (!couponId) {
        console.log("등록 모드입니다. 데이터를 불러오지 않습니다.");
        return;			
      }

        try {
          const res = await axios.get(`${contextPath}/api/admin/coupon/`+couponId);
          const c = res.data;
          const toDatetimeLocal = (val) => {
            if (!val) return '';
            let s = String(val).trim();
  
  			if (s.length <= 10) {
    			s += 'T00:00';
 			 } else {
    			s = s.replace(' ', 'T');
  		}
 		 return s.slice(0, 16);

          };

          Object.assign(form, {
            couponName:          c.couponName          || '',
            discountType:        c.discountType        || 'FIXED',
            discountAmount:      c.discountAmount      || '',
            maxDiscountAmount:   c.maxDiscountAmount   || '',
            minOrderAmount:      c.minOrderAmount      || '',
            platformShare:       c.platformShare       ?? 100,
            partnerId:           c.partnerId           || '',
            validFrom:           toDatetimeLocal(c.validFrom),
            validUntil:          toDatetimeLocal(c.validUntil),
            issueConditionType:  c.issueConditionType  || 'NONE',
            issueConditionValue: c.issueConditionValue || '',
            // 적용 대상
            targetAccType: c.targets ? [...new Set(c.targets.filter(t=>t.targetType==='ACC_TYPE' && t.isExclude==='N').map(t=>t.targetValue))] : [],
            includeAccommodations: c.targets ? c.targets.filter(t=>t.targetType==='ACCOMMODATION' && t.isExclude==='N').map(t=>({placeId:t.targetValue, name:t.displayName||t.targetValue})) : [],
            excludeAccommodations: c.targets ? c.targets.filter(t=>t.targetType==='ACCOMMODATION' && t.isExclude==='Y').map(t=>({placeId:t.targetValue, name:t.displayName||t.targetValue})) : [],
            excludeRooms: c.targets ? c.targets.filter(t=>t.targetType==='ROOM' && t.isExclude==='Y').map(t=>({roomId:t.targetValue, roomName:t.displayName, placeId:t.accId, accName:t.accName})) : []
          });
          partnerSearch.value = c.partnerName || '';
        } catch(e) {
          console.error('[loadCoupon] 실패 - ID:', couponId, e);
          const status = e.response ? e.response.status : '네트워크오류';
          alert(`쿠폰 정보를 불러올 수 없습니다.\n• ID: ${couponId}\n• HTTP 상태: ${status}\n\n백엔드에 GET /api/admin/coupon/${couponId} 엔드포인트가 있는지 확인해주세요.`);
        }
      };

      /* ── 파트너 옵션 ── */
      const fetchPartnerOptions = async () => {
        try {
          const res = await axios.get(`${contextPath}/admin/api/partner/options`);
          partnerOptions.value = res.data;
        } catch(e) { console.error('파트너 옵션 오류', e); }
      };

      /* ── 저장 ── */
      const submitForm = async () => {
        if (!form.couponName.trim() || !form.discountAmount || !form.validFrom || !form.validUntil) {
          alert('쿠폰명, 할인 금액/율, 유효기간은 필수입니다.');
          return;
        }
        if (['BOOKING_COUNT','REVIEW_COUNT','AMOUNT_SPENT'].includes(form.issueConditionType)
            && !form.issueConditionValue) {
          alert('발급 조건 수치를 입력해주세요.');
          return;
        }
        const payload = {
          couponName:          form.couponName,
          discountType:        form.discountType,
          discountAmount:      form.discountAmount,
          maxDiscountAmount:   form.maxDiscountAmount  || null,
          minOrderAmount:      form.minOrderAmount     || null,
          platformShare:       form.platformShare,
          partnerId:           form.partnerId          || null,
          validFrom:           form.validFrom,
          validUntil:          form.validUntil,
          issueCondition:      form.issueConditionType,
          issueConditionValue: form.issueConditionValue|| null,
          // ── 적용 대상 ──
          targets: [
            ...form.targetAccType.filter(v=>v).map(v => ({ targetType:'ACC_TYPE',      targetValue: v,                 isExclude:'N' })),
            ...form.includeAccommodations.map(a =>      ({ targetType:'ACCOMMODATION', targetValue: String(a.placeId), isExclude:'N', displayName: a.name })),
            ...form.excludeAccommodations.map(a =>      ({ targetType:'ACCOMMODATION', targetValue: String(a.placeId), isExclude:'Y', displayName: a.name })),
            ...form.excludeRooms.map(r =>               ({ targetType:'ROOM',          targetValue: String(r.roomId),  isExclude:'Y', displayName: r.roomName, accId: r.placeId, accName: r.accName }))
          ]
        };
        try {
          if (isEdit.value) {
            await axios.put(`${contextPath}/api/admin/coupon/${couponId}`, payload);
            alert('쿠폰이 수정되었습니다.');
          } else {
            await axios.post(`${contextPath}/api/admin/coupon/register`, payload);
            alert('쿠폰이 등록되었습니다.');
          }
          location.href = contextPath + '/admin/coupon';
        } catch(e) {
          console.error('저장 오류', e);
          alert('처리 중 오류가 발생했습니다.');
        }
      };

      const goBack = () => { location.href = contextPath + '/admin/coupon'; };

      onMounted(() => {
        fetchPartnerOptions();
        fetchAccTypeOptions();
        loadCoupon();
      });

      return {
        isEdit, form,
        formatNumber, parseNumber,
        partnerOptions, partnerSearch, showPartnerDropdown, filteredPartners,
        onPartnerSearch, hidePartnerDropdown, selectPartner,
        accTypeOptions,
        includeSearchKeyword, excludeSearchKeyword,
        removeInclude, removeExclude, removeExcludeRoom,
        showAccModal, modalTab, modalKeyword, modalSearched, modalAccResults, modalLoading,
        expandedAccId, expandedRooms, roomLoading,
        openModal, closeModal, switchTab, runSearch,
        isAccSelected, toggleAccSelect,
        toggleRoomExpand, isRoomSelected, countSelectedRooms, toggleRoomSelect,
        submitForm, goBack
      };
    }
  }).mount('#app');
</script>

</body>
</html>
