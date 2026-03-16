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

        <a href="${pageContext.request.contextPath}/admin/coupon" class="back-link">← 쿠폰 목록으로</a>

        <div class="page-header fade-up" style="margin-bottom:20px;">
          <div>
            <h1>{{ isEdit ? '쿠폰 수정' : '쿠폰 직접 등록' }}</h1>
            <p>{{ isEdit ? '쿠폰 정보를 수정합니다.' : '관리자가 직접 플랫폼 쿠폰을 등록합니다.' }}</p>
          </div>
        </div>

        <!-- ── 카드 1: 기본 정보 ── -->
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

        <!-- ── 카드 2: 파트너 & 부담 비율 ── -->
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

<script>
  const contextPath = (function() {
    const cp = '${pageContext.request.contextPath}';
    return cp === '/' ? '' : cp;
  })();
  const couponId = '${param.id}' || null;
</script>

<jsp:include page="/WEB-INF/views/layout/vue_cdn.jsp" />

<script type="module">
  import { createApp, ref, reactive, computed, onMounted } from 'vue';
  import axios from 'axios';

  createApp({
    setup() {

      const isEdit = ref(!!couponId);

      const form = reactive({
        couponName: '', discountType: 'FIXED', discountAmount: '',
        maxDiscountAmount: '', minOrderAmount: '', platformShare: 100, partnerId: '',
        validFrom: '', validUntil: '',
        issueConditionType: 'NONE', issueConditionValue: ''
      });

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
        if (!couponId) return;
        try {
          const res = await axios.get(`${contextPath}/api/admin/coupon/${couponId}`);
          const c = res.data;
          Object.assign(form, {
            couponName:          c.couponName,
            discountType:        c.discountType,
            discountAmount:      c.discountAmount,
            maxDiscountAmount:   c.maxDiscountAmount  || '',
            minOrderAmount:      c.minOrderAmount     || '',
            platformShare:       c.platformShare,
            partnerId:           c.partnerId          || '',
            validFrom:           c.validFrom          || '',
            validUntil:          c.validUntil         || '',
            issueConditionType:  c.issueConditionType || 'NONE',
            issueConditionValue: c.issueConditionValue|| ''
          });
          partnerSearch.value = c.partnerName || '';
        } catch(e) {
          console.error('쿠폰 불러오기 실패', e);
          alert('쿠폰 정보를 불러올 수 없습니다.');
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
          issueConditionValue: form.issueConditionValue|| null
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
        loadCoupon();
      });

      return {
        isEdit, form,
        formatNumber, parseNumber,
        partnerOptions, partnerSearch, showPartnerDropdown, filteredPartners,
        onPartnerSearch, hidePartnerDropdown, selectPartner,
        submitForm, goBack
      };
    }
  }).mount('#app');
</script>

</body>
</html>
