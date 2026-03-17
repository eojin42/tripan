<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <title>TripanSuper — 쿠폰 관리</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/dist/css/admin.css">
  <style>
    html, body { overflow-y: auto !important; height: auto !important; }
    .main-wrapper { overflow-y: auto !important; }
    .col-check { width: 44px; text-align: center; }
    input[type="checkbox"] { width: 16px; height: 16px; cursor: pointer; accent-color: var(--primary); }

    /* bulk bar */
    .bulk-bar {
      display: none; align-items: center; gap: 12px;
      padding: 12px 20px; background: #EFF6FF;
      border: 1.5px solid #BFDBFE; border-radius: 14px;
      margin-bottom: 16px; animation: slideDown 0.2s ease;
    }
    .bulk-bar.visible { display: flex; }
    @keyframes slideDown { from{opacity:0;transform:translateY(-6px);} to{opacity:1;transform:translateY(0);} }
    .bulk-count       { font-size:13px; font-weight:800; color:#1D4ED8; background:#DBEAFE; padding:4px 12px; border-radius:20px; }
    .bulk-bar-label   { font-size:13px; font-weight:700; color:var(--text); }
    .bulk-bar-actions { display:flex; gap:8px; margin-left:auto; }
    .btn-bulk { height:36px; padding:0 16px; border-radius:9px; font-size:13px; font-weight:800; border:none; cursor:pointer; transition:opacity 0.15s; }
    .btn-bulk-danger { background:#DC2626; color:#fff; }
    .btn-bulk-excel  { background:var(--bg); color:var(--text); border:1px solid var(--border); }
    .btn-bulk:hover  { opacity:0.8; }

    /* modal */
    .modal-overlay {
      position: fixed; inset: 0; background: rgba(15,23,42,0.5);
      backdrop-filter: blur(6px); display: none;
      justify-content: center; align-items: center;
      z-index: 3000; padding: 24px;
    }
    .modal-overlay.open { display: flex; }
    .modal-sheet {
      background: #fff; width: 100%; max-width: 520px;
      border-radius: 22px; overflow: hidden;
      box-shadow: 0 24px 64px rgba(0,0,0,0.16);
      animation: modalUp 0.3s cubic-bezier(0.16,1,0.3,1);
      display: flex; flex-direction: column; max-height: 90vh;
    }
    @keyframes modalUp { from{opacity:0;transform:translateY(20px)} to{opacity:1;transform:translateY(0)} }
    .ms-head    { padding: 26px 28px 18px; border-bottom: 1px solid var(--border); flex-shrink:0; }
    .ms-head h3 { font-size: 17px; font-weight: 900; margin: 0 0 4px; }
    .ms-head p  { font-size: 13px; color: var(--muted); margin: 0; }
    .ms-body    { padding: 22px 28px; display: flex; flex-direction: column; gap: 16px; overflow-y:auto; }
    .ms-foot    { padding: 16px 28px; border-top: 1px solid var(--border); display: flex; gap: 10px; flex-shrink:0; }
    .fg         { display: flex; flex-direction: column; gap: 7px; }
    .fg label   { font-size: 11px; font-weight: 800; color: var(--muted); text-transform: uppercase; letter-spacing: 0.6px; }
    .fg select, .fg textarea, .fg input {
      width: 100%; border: 1.5px solid var(--border); border-radius: 10px;
      padding: 10px 14px; font-size: 14px; font-weight: 600;
      background: #fff; outline: none; transition: border-color 0.2s;
      box-sizing: border-box; font-family: inherit; color: var(--text);
    }
    .fg select:focus,.fg textarea:focus,.fg input:focus { border-color:var(--primary); box-shadow:0 0 0 3px var(--primary-10); }
    .fg textarea { resize:vertical; min-height:72px; line-height:1.5; }
    .btn-m         { flex:1; height:46px; border-radius:11px; font-weight:800; font-size:14px; border:none; cursor:pointer; transition:opacity 0.15s; }
    .btn-m-ghost   { background:var(--bg); color:var(--text); }
    .btn-m-primary { background:#111; color:#fff; }
    .btn-m-success { background:#F0FDF4; color:#15803D; }
    .btn-m-danger  { background:#DC2626; color:#fff; }
    .btn-m-warn    { background:#FFFBEB; color:#B45309; }
    .btn-m:hover   { opacity:0.84; }
    .filter-row .btn { display:inline-flex; align-items:center; gap:6px; }
    .btn-reset { background: var(--bg); color: var(--muted); border: 1.5px solid var(--border); border-radius: 10px; height: 38px; padding: 0 14px; font-size: 13px; font-weight: 700; cursor: pointer; display: inline-flex; align-items: center; gap: 5px; transition: all 0.15s; }
    .btn-reset:hover { background: #F1F5F9; color: var(--text); border-color: #94A3B8; }
    .btn-reset svg { transition: transform 0.35s cubic-bezier(0.34,1.56,0.64,1); }
    .btn-reset:hover svg { transform: rotate(-180deg); }

    /* 탭 */
    .tab-bar { display:flex; gap:4px; border-bottom:2px solid var(--border); margin-bottom:24px; }
    .tab-btn {
      padding:10px 20px; font-size:13px; font-weight:800; color:var(--muted);
      border:none; background:none; cursor:pointer;
      border-bottom:2px solid transparent; margin-bottom:-2px; transition:all 0.15s;
      display:flex; align-items:center; gap:6px;
    }
    .tab-btn.active { color:var(--primary); border-bottom-color:var(--primary); }
    .tab-badge {
      font-size:11px; font-weight:800; padding:2px 7px; border-radius:20px;
      background:#FEE2E2; color:#DC2626;
    }
    .tab-btn.active .tab-badge { background:#DBEAFE; color:#1D4ED8; }

    /* 쿠폰 badge */
    .badge-active   { background:#F0FDF4; color:#15803D; }
    .badge-waiting  { background:#FFF7ED; color:#C2410C; }
    .badge-expired  { background:#F1F5F9; color:#94A3B8; }
    .badge-inactive { background:#FEF2F2; color:#DC2626; }
    .badge-rejected { background:#FEF2F2; color:#DC2626; }

    .discount-chip {
      display:inline-flex; align-items:center; gap:4px;
      padding:3px 10px; border-radius:20px; font-size:12px; font-weight:800;
    }
    .chip-fixed   { background:#EEF2FF; color:#4338CA; }
    .chip-percent { background:#FFF7ED; color:#C2410C; }

    .badge-platform { background:#EFF6FF; color:#1D4ED8; }
    .badge-partner  { background:#F0FDF4; color:#15803D; }

    /* 발급 현황 */
    .badge-used     { background:#F0FDF4; color:#15803D; }
    .badge-unused   { background:#EFF6FF; color:#1D4ED8; }
    .badge-canceled { background:#F1F5F9; color:#94A3B8; }

    /* 승인 처리 버튼 */
    .btn-row { display:flex; gap:6px; justify-content:flex-end; }

    /* 위험 배너 */
    .danger-banner {
      padding:14px 16px; background:#FEF2F2; border:1.5px solid #FECACA;
      border-radius:12px; font-size:13px; font-weight:700; color:#DC2626;
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

      <!-- 페이지 헤더 -->
      <div class="page-header fade-up">
        <div>
          <h1>쿠폰 관리</h1>
          <p>플랫폼 쿠폰을 직접 등록하고, 파트너사가 신청한 쿠폰을 승인·관리합니다.</p>
        </div>
        <div style="margin-left:auto;">
          <a href="${pageContext.request.contextPath}/admin/coupon/form"
             class="btn btn-primary" style="display:inline-flex;align-items:center;gap:6px;text-decoration:none;">
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
              <line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/>
            </svg>
            쿠폰 직접 등록
          </a>
        </div>
      </div>

      <!-- KPI -->
      <div class="kpi-grid">
        <div class="card kpi-card fade-up fade-up-1">
          <div class="kpi-label">전체 쿠폰</div>
          <div class="kpi-value">{{ kpi.total }}</div>
          <div class="kpi-sub">플랫폼 {{ kpi.platform }} / 파트너 {{ kpi.partner }}</div>
        </div>
        <div class="card kpi-card fade-up fade-up-2">
          <div class="kpi-label">승인 대기</div>
          <div class="kpi-value" style="color:#C2410C;">{{ kpi.waiting }}</div>
          <div class="kpi-sub">파트너 쿠폰 검토 필요</div>
        </div>
        <div class="card kpi-card fade-up fade-up-3">
          <div class="kpi-label">이번 달 발급</div>
          <div class="kpi-value" style="color:var(--primary)">{{ kpi.issuedThisMonth }}</div>
          <div class="kpi-sub">회원 발급 건수</div>
        </div>
        <div class="card kpi-card fade-up fade-up-4">
          <div class="kpi-label">이번 달 사용</div>
          <div class="kpi-value">{{ kpi.usedThisMonth }}</div>
          <div class="kpi-sub">실제 결제 적용</div>
        </div>
      </div>

      <!-- 탭 -->
      <div class="tab-bar fade-up">
        <button class="tab-btn" :class="{ active: activeTab === 'all' }" @click="switchTab('all')">
          전체 쿠폰
        </button>
        <button class="tab-btn" :class="{ active: activeTab === 'pending' }" @click="switchTab('pending')">
          승인 대기
          <span class="tab-badge" v-if="kpi.waiting > 0">{{ kpi.waiting }}</span>
        </button>
        <button class="tab-btn" :class="{ active: activeTab === 'issued' }" @click="switchTab('issued')">
          회원 발급 현황
        </button>
      </div>

      <!-- 전체 쿠폰 탭 -->
      <template v-if="activeTab === 'all'">
        <div class="card filter-card fade-up">
          <div class="filter-row">
            <div class="filter-label">쿠폰 검색</div>
            <select class="filter-select" v-model="couponFilter.discountType" style="width:130px;">
              <option value="ALL">전체 유형</option>
              <option value="FIXED">정액 할인</option>
              <option value="PERCENT">정률 할인</option>
            </select>
            <select class="filter-select" v-model="couponFilter.status" style="width:130px;">
              <option value="ALL">전체 상태</option>
              <option value="ACTIVE">활성</option>
              <option value="WAITING">승인 대기</option>
              <option value="EXPIRED">만료</option>
              <option value="INACTIVE">비활성</option>
              <option value="REJECTED">반려</option>
            </select>
            <select class="filter-select" v-model="couponFilter.issuer" style="width:140px;">
              <option value="ALL">전체 발급 주체</option>
              <option value="PLATFORM">플랫폼</option>
              <option value="PARTNER">파트너사</option>
            </select>
            <input type="text" class="keyword-input" v-model="couponFilter.keyword"
                   placeholder="쿠폰명 검색" @keyup.enter="fetchCoupons(1)" style="flex:1;">
            <button class="btn-reset" @click="resetCouponFilter()" title="검색 초기화">
              <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><polyline points="1 4 1 10 7 10"/><path d="M3.51 15a9 9 0 1 0 .49-3.51"/></svg>
              초기화
            </button>
            <button class="btn btn-primary" @click="fetchCoupons(1)">
              <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
              검색
            </button>
          </div>
        </div>

        <div class="card table-card fade-up">
          <!-- bulk bar -->
          <div class="bulk-bar" :class="{ visible: selectedIds.length > 0 }">
            <span class="bulk-count">{{ selectedIds.length }}개 선택</span>
            <span class="bulk-bar-label">선택된 쿠폰에 일괄 작업을 수행합니다.</span>
            <div class="bulk-bar-actions">
              <button class="btn-bulk btn-bulk-danger" @click="openBulkDeleteModal">일괄 삭제</button>
              <button class="btn-bulk btn-bulk-excel"  @click="downloadExcel">엑셀 다운로드</button>
            </div>
          </div>

          <div class="w-header" style="display:flex;justify-content:space-between;align-items:center;margin-bottom:16px;">
            <h2>전체 쿠폰 목록</h2>
            <span style="font-size:13px;color:var(--muted);">총 {{ couponTotal }}개</span>
          </div>

          <div class="table-responsive">
            <table>
              <thead>
                <tr>
                  <th class="col-check"><input type="checkbox" @change="toggleCheckAll" :checked="isAllChecked"></th>
                  <th>쿠폰명</th>
                  <th>발급 주체</th>
                  <th>할인 유형</th>
                  <th>할인 금액/율</th>
                  <th>부담 비율 (플랫폼/파트너)</th>
                  <th>유효기간</th>
                  <th>발급 수</th>
                  <th>상태</th>
                  <th class="right">관리</th>
                </tr>
              </thead>
              <tbody>
                <tr v-if="!couponSearched">
                  <td colspan="10" style="text-align:center;padding:50px 0;color:var(--muted);">
                    검색 조건을 설정한 후 <strong>[검색]</strong> 버튼을 눌러주세요.
                  </td>
                </tr>
                <tr v-else-if="couponList.length === 0">
                  <td colspan="10" style="text-align:center;padding:50px 0;color:var(--muted);">검색 결과가 없습니다.</td>
                </tr>
                <tr v-for="c in couponList" :key="c.couponId">
                  <td class="col-check"><input type="checkbox" :value="c.couponId" v-model="selectedIds" @click.stop></td>
                  <td><strong>{{ c.couponName }}</strong></td>
                  <td>
                    <span class="badge" :class="c.partnerId ? 'badge-partner' : 'badge-platform'">
                      {{ c.partnerId ? c.partnerName : '플랫폼' }}
                    </span>
                  </td>
                  <td>
                    <span class="discount-chip" :class="c.discountType === 'FIXED' ? 'chip-fixed' : 'chip-percent'">
                      {{ c.discountType === 'FIXED' ? '정액' : '정률' }}
                    </span>
                  </td>
                  <td class="num">
                    <span v-if="c.discountType === 'FIXED'">{{ c.discountAmount.toLocaleString() }}원</span>
                    <span v-else>
                      {{ c.discountAmount }}%
                      <span v-if="c.maxDiscountAmount" style="color:var(--muted);font-size:11px;">(최대 {{ c.maxDiscountAmount.toLocaleString() }}원)</span>
                    </span>
                  </td>
                  <td class="num" style="font-size:12px;">{{ c.platformShare }}% / {{ c.partnerShare }}%</td>
                  <td style="font-size:12px;color:var(--muted);">{{ c.validFrom }} ~ {{ c.validUntil }}</td>
                  <td class="num">{{ c.issuedCount }}</td>
                  <td>
                    <span v-if="c.status === 'ACTIVE'"    class="badge badge-active">활성</span>
                    <span v-else-if="c.status === 'WAITING'"  class="badge badge-waiting">승인 대기</span>
                    <span v-else-if="c.status === 'EXPIRED'"  class="badge badge-expired">만료</span>
                    <span v-else-if="c.status === 'REJECTED'" class="badge badge-rejected">반려</span>
                    <span v-else class="badge badge-inactive">비활성</span>
                  </td>
                  <td class="right">
                    <div class="btn-row">
                      <button v-if="c.status === 'WAITING'"
                              class="btn btn-sm"
                              style="background:#EFF6FF;color:#1D4ED8;border:1px solid #BFDBFE;"
                              @click="openApproveModal(c)">심사</button>
                      <button class="btn btn-outline btn-sm"
                              @click="goToEdit(c)">수정</button>
                      <button class="btn btn-sm"
                              style="background:#FEF2F2;color:#DC2626;border:1px solid #FECACA;"
                              @click="openDeleteConfirm(c)">삭제</button>
                    </div>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>

          <div class="list-footer" v-if="couponPagination">
            <div class="pagination">
              <button class="pg-btn pg-arrow" v-if="couponPagination.showPrev" @click="fetchCoupons(couponPagination.firstPage)">«</button>
              <button class="pg-btn pg-arrow" v-if="couponPagination.showPrev" @click="fetchCoupons(couponPagination.prevBlockPage)">‹</button>
              <button class="pg-btn" v-for="pg in couponPagination.pages" :key="pg" @click="fetchCoupons(pg)" :class="{ active: couponPageNo === pg }">{{ pg }}</button>
              <button class="pg-btn pg-arrow" v-if="couponPagination.showNext" @click="fetchCoupons(couponPagination.nextBlockPage)">›</button>
              <button class="pg-btn pg-arrow" v-if="couponPagination.showNext" @click="fetchCoupons(couponPagination.lastPage)">»</button>
            </div>
          </div>
        </div>
      </template>

      <!-- ══════════════════════════════
           승인 대기 탭
      ══════════════════════════════ -->
      <template v-if="activeTab === 'pending'">
        <div class="card table-card fade-up">
          <div class="w-header" style="display:flex;justify-content:space-between;align-items:center;margin-bottom:16px;">
            <h2 style="display:inline-flex;align-items:center;gap:8px;">
              <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/>
              </svg>
              파트너 쿠폰 승인 대기
            </h2>
            <span style="font-size:13px;color:var(--muted);">{{ kpi.waiting }}건 대기 중</span>
          </div>

          <div class="table-responsive">
            <table>
              <thead>
                <tr>
                  <th>파트너사</th>
                  <th>쿠폰명</th>
                  <th>할인 유형</th>
                  <th>할인 금액/율</th>
                  <th>부담 비율 (플랫폼/파트너)</th>
                  <th>유효기간</th>
                  <th>신청일</th>
                  <th class="right">처리</th>
                </tr>
              </thead>
              <tbody>
                <tr v-if="pendingList.length === 0">
                  <td colspan="8" style="text-align:center;padding:50px 0;color:var(--muted);">
                    승인 대기 중인 쿠폰이 없습니다.
                  </td>
                </tr>
                <tr v-for="c in pendingList" :key="c.couponId">
                  <td><span class="badge badge-partner">{{ c.partnerName }}</span></td>
                  <td><strong>{{ c.couponName }}</strong></td>
                  <td>
                    <span class="discount-chip" :class="c.discountType === 'FIXED' ? 'chip-fixed' : 'chip-percent'">
                      {{ c.discountType === 'FIXED' ? '정액' : '정률' }}
                    </span>
                  </td>
                  <td class="num">
                    <span v-if="c.discountType === 'FIXED'">{{ c.discountAmount.toLocaleString() }}원</span>
                    <span v-else>{{ c.discountAmount }}%
                      <span v-if="c.maxDiscountAmount" style="color:var(--muted);font-size:11px;">(최대 {{ c.maxDiscountAmount.toLocaleString() }}원)</span>
                    </span>
                  </td>
                  <td class="num" style="font-size:12px;">{{ c.platformShare }}% / {{ c.partnerShare }}%</td>
                  <td style="font-size:12px;color:var(--muted);">{{ c.validFrom }} ~ {{ c.validUntil }}</td>
                  <td style="font-size:12px;color:var(--muted);">{{ c.createdAt }}</td>
                  <td class="right">
                    <div class="btn-row">
                      <button class="btn btn-sm"
                              style="background:#F0FDF4;color:#15803D;border:1px solid #BBF7D0;"
                              @click="openApproveModal(c)">승인/반려</button>
                    </div>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </template>

      <!-- ══════════════════════════════
           회원 발급 현황 탭
      ══════════════════════════════ -->
      <template v-if="activeTab === 'issued'">
        <div class="card filter-card fade-up">
          <div class="filter-row">
            <div class="filter-label">발급 검색</div>
            <select class="filter-select" v-model="issuedFilter.status" style="width:130px;">
              <option value="ALL">전체 상태</option>
              <option value="UNUSED">미사용</option>
              <option value="USED">사용 완료</option>
              <option value="CANCELED">취소</option>
            </select>
            <input type="text" class="keyword-input" v-model="issuedFilter.couponKeyword"
                   placeholder="쿠폰명 검색" style="width:180px;flex:unset;">
            <input type="text" class="keyword-input" v-model="issuedFilter.memberKeyword"
                   placeholder="회원 ID 검색" style="width:180px;flex:unset;">
            <button class="btn-reset" @click="resetIssuedFilter()" title="검색 초기화">
              <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><polyline points="1 4 1 10 7 10"/><path d="M3.51 15a9 9 0 1 0 .49-3.51"/></svg>
              초기화
            </button>
            <button class="btn btn-primary" @click="fetchIssued(1)">
              <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
              검색
            </button>
          </div>
        </div>

        <div class="card table-card fade-up">
          <div class="w-header" style="display:flex;justify-content:space-between;align-items:center;margin-bottom:16px;">
            <h2>회원 발급 현황</h2>
            <span style="font-size:13px;color:var(--muted);">총 {{ issuedTotal }}건</span>
          </div>
          <div class="table-responsive">
            <table>
              <thead>
                <tr>
                  <th>발급 번호</th>
                  <th>쿠폰명</th>
                  <th>발급 주체</th>
                  <th>회원 ID</th>
                  <th>할인 유형</th>
                  <th>할인 금액/율</th>
                  <th>발급일</th>
                  <th>유효기간 만료일</th>
                  <th>상태</th>
                </tr>
              </thead>
              <tbody>
                <tr v-if="!issuedSearched">
                  <td colspan="9" style="text-align:center;padding:50px 0;color:var(--muted);">
                    검색 조건을 설정한 후 <strong>[검색]</strong> 버튼을 눌러주세요.
                  </td>
                </tr>
                <tr v-else-if="issuedList.length === 0">
                  <td colspan="9" style="text-align:center;padding:50px 0;color:var(--muted);">검색 결과가 없습니다.</td>
                </tr>
                <tr v-for="i in issuedList" :key="i.memberCouponId">
                  <td class="num" style="color:var(--muted);font-size:12px;">{{ i.memberCouponId }}</td>
                  <td><strong>{{ i.couponName }}</strong></td>
                  <td>
                    <span class="badge" :class="i.partnerId ? 'badge-partner' : 'badge-platform'">
                      {{ i.partnerId ? i.partnerName : '플랫폼' }}
                    </span>
                  </td>
                  <td>{{ i.memberId }}</td>
                  <td>
                    <span class="discount-chip" :class="i.discountType === 'FIXED' ? 'chip-fixed' : 'chip-percent'">
                      {{ i.discountType === 'FIXED' ? '정액' : '정률' }}
                    </span>
                  </td>
                  <td class="num">
                    <span v-if="i.discountType === 'FIXED'">{{ i.discountAmount.toLocaleString() }}원</span>
                    <span v-else>{{ i.discountAmount }}%</span>
                  </td>
                  <td style="font-size:12px;color:var(--muted);">{{ i.issuedAt }}</td>
                  <td style="font-size:12px;color:var(--muted);">{{ i.validUntil }}</td>
                  <td>
                    <span v-if="i.status === 'UNUSED'"   class="badge badge-unused">미사용</span>
                    <span v-else-if="i.status === 'USED'"    class="badge badge-used">사용 완료</span>
                    <span v-else class="badge badge-canceled">취소</span>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
          <div class="list-footer" v-if="issuedPagination">
            <div class="pagination">
              <button class="pg-btn pg-arrow" v-if="issuedPagination.showPrev" @click="fetchIssued(issuedPagination.firstPage)">«</button>
              <button class="pg-btn pg-arrow" v-if="issuedPagination.showPrev" @click="fetchIssued(issuedPagination.prevBlockPage)">‹</button>
              <button class="pg-btn" v-for="pg in issuedPagination.pages" :key="pg" @click="fetchIssued(pg)" :class="{ active: issuedPageNo === pg }">{{ pg }}</button>
              <button class="pg-btn pg-arrow" v-if="issuedPagination.showNext" @click="fetchIssued(issuedPagination.nextBlockPage)">›</button>
              <button class="pg-btn pg-arrow" v-if="issuedPagination.showNext" @click="fetchIssued(issuedPagination.lastPage)">»</button>
            </div>
          </div>
        </div>
      </template>

    </main>

    <!-- ══════════ 파트너 쿠폰 승인/반려 모달 ══════════ -->
    <div class="modal-overlay" :class="{ open: showApproveModal }" @click.self="closeApproveModal">
      <div class="modal-sheet" style="max-width:480px;">
        <div class="ms-head">
          <h3>파트너 쿠폰 심사</h3>
          <p>{{ approveTarget ? approveTarget.partnerName : '' }} — {{ approveTarget ? approveTarget.couponName : '' }}</p>
        </div>
        <div class="ms-body" v-if="approveTarget">
          <!-- 쿠폰 요약 정보 -->
          <div style="display:grid;grid-template-columns:1fr 1fr;gap:12px;padding:16px;background:var(--bg);border-radius:12px;font-size:13px;">
            <div>
              <div style="color:var(--muted);font-size:11px;font-weight:800;margin-bottom:4px;">할인 유형</div>
              <div style="font-weight:700;">{{ approveTarget.discountType === 'FIXED' ? '정액' : '정률' }} — {{ approveTarget.discountType === 'FIXED' ? approveTarget.discountAmount.toLocaleString() + '원' : approveTarget.discountAmount + '%' }}</div>
            </div>
            <div>
              <div style="color:var(--muted);font-size:11px;font-weight:800;margin-bottom:4px;">부담 비율</div>
              <div style="font-weight:700;">플랫폼 {{ approveTarget.platformShare }}% / 파트너 {{ approveTarget.partnerShare }}%</div>
            </div>
            <div>
              <div style="color:var(--muted);font-size:11px;font-weight:800;margin-bottom:4px;">유효기간</div>
              <div style="font-weight:700;">{{ approveTarget.validFrom.replace('T', ' ') }}
   						 <br>~ {{ approveTarget.validUntil.replace('T', ' ') }}</div>
            </div>
          </div>

          <div class="fg">
            <label>심사 결과 <span style="color:var(--danger);">*</span></label>
            <select v-model="approveForm.result">
              <option value="">결과를 선택하세요</option>
              <option value="ACTIVE">✅ 승인</option>
              <option value="REJECTED">❌ 반려</option>
            </select>
          </div>
          <div class="fg">
            <label>
              <span v-if="approveForm.result === 'REJECTED'">반려 사유 <span style="color:var(--danger);">*</span></span>
              <span v-else>메모 (선택)</span>
            </label>
            <textarea v-model="approveForm.memo"
                      :placeholder="approveForm.result === 'REJECTED' ? '반려 사유를 입력하세요.' : '승인 메모 (선택)'">
            </textarea>
          </div>
        </div>
        <div class="ms-foot">
          <button class="btn-m btn-m-ghost" @click="closeApproveModal">취소</button>
          <button class="btn-m btn-m-success" v-if="approveForm.result === 'ACTIVE'"   @click="submitApprove">승인</button>
          <button class="btn-m btn-m-danger"  v-else-if="approveForm.result === 'REJECTED'" @click="submitApprove">반려</button>
          <button class="btn-m btn-m-primary" v-else disabled style="opacity:0.4;">결과 선택 후 처리</button>
        </div>
      </div>
    </div>

    <!-- ══════════ 삭제 확인 모달 ══════════ -->
    <div class="modal-overlay" :class="{ open: showDeleteModal }" @click.self="closeDeleteModal">
      <div class="modal-sheet" style="max-width:420px;">
        <div class="ms-head">
          <h3>쿠폰 삭제</h3>
          <p>이 작업은 되돌릴 수 없습니다.</p>
        </div>
        <div class="ms-body">
          <div class="danger-banner">
            <strong>{{ deleteTarget ? deleteTarget.couponName : selectedIds.length + '개 쿠폰' }}</strong>을(를) 삭제합니다.
            이미 발급된 쿠폰은 회원이 사용할 수 없게 됩니다.
          </div>
        </div>
        <div class="ms-foot">
          <button class="btn-m btn-m-ghost"  @click="closeDeleteModal">취소</button>
          <button class="btn-m btn-m-danger" @click="submitDelete">삭제 확인</button>
        </div>
      </div>
    </div>

    </div><!-- /#app -->

  </div><!-- /main-wrapper -->
</div><!-- /admin-layout -->

<script>
  const contextPath = (function() {
    const cp = '${pageContext.request.contextPath}';
    return cp === '/' ? '' : cp;
  })();
</script>

<jsp:include page="/WEB-INF/views/layout/vue_cdn.jsp" />

<script type="module">
  import { createApp, ref, reactive, computed, onMounted } from 'vue';
  import axios from 'axios';

  createApp({
    setup() {

      /* ── KPI ── */
      const kpi = reactive({ total:0, platform:0, partner:0, waiting:0, issuedThisMonth:0, usedThisMonth:0 });

      /* ── 탭 ── */
      const activeTab = ref('all');
      const switchTab = (tab) => {
        activeTab.value = tab;
        if (tab === 'pending') fetchPending();
      };

      /* ── 쿠폰 목록 ── */
      const couponFilter    = reactive({ discountType:'ALL', status:'ALL', issuer:'ALL', keyword:'' });
      const couponList      = ref([]);
      const couponTotal     = ref(0);
      const couponPageNo    = ref(1);
      const couponPagination = ref(null);
      const couponSearched  = ref(false);
      const selectedIds     = ref([]);

      const isAllChecked = computed(() =>
        couponList.value.length > 0 &&
        selectedIds.value.length === couponList.value.length
      );

      /* ── 승인 대기 ── */
      const pendingList = ref([]);

      /* ── 발급 현황 ── */
      const issuedFilter    = reactive({ status:'ALL', couponKeyword:'', memberKeyword:'' });
      const issuedList      = ref([]);
      const issuedTotal     = ref(0);
      const issuedPageNo    = ref(1);
      const issuedPagination = ref(null);
      const issuedSearched  = ref(false);

      /* ── 파트너 옵션 ── */
      const partnerOptions = ref([]);

      /* ── 승인 모달 ── */
      const showApproveModal = ref(false);
      const approveTarget    = ref(null);
      const approveForm      = reactive({ result:'', memo:'' });

      /* ── 삭제 모달 ── */
      const showDeleteModal = ref(false);
      const deleteTarget    = ref(null);

      /* ── API ── */
      const fetchKpi = async () => {
        try {
          const res = await axios.get(`${contextPath}/api/admin/coupon/kpi`);
          Object.assign(kpi, res.data);
        } catch(e) { console.error('KPI 오류', e); }
      };

      const fetchPartnerOptions = async () => {
        try {
          const res = await axios.get(`${contextPath}/admin/api/partner/options`);
          partnerOptions.value = res.data;
        } catch(e) { console.error('파트너 옵션 오류', e); }
      };

      const fetchCoupons = async (page = 1) => {
        couponPageNo.value = page;
        try {
          const res = await axios.get(`${contextPath}/api/admin/coupon/list`, {
            params: { page, discountType: couponFilter.discountType, status: couponFilter.status, issuer: couponFilter.issuer, keyword: couponFilter.keyword }
          });
          couponList.value       = res.data.list;
          couponTotal.value      = res.data.totalCount;
          couponPagination.value = res.data.pagination;
          couponSearched.value   = true;
          selectedIds.value      = [];
        } catch(e) { console.error('목록 오류', e); alert('목록을 불러오는 중 오류가 발생했습니다.'); }
      };

      const fetchPending = async () => {
        try {
          const res = await axios.get(`${contextPath}/api/admin/coupon/pending`);
          pendingList.value = res.data;
        } catch(e) { console.error('승인 대기 오류', e); }
      };

      const fetchIssued = async (page = 1) => {
        issuedPageNo.value = page;
        try {
          const res = await axios.get(`${contextPath}/api/admin/coupon/issued`, {
            params: { page, status: issuedFilter.status, couponKeyword: issuedFilter.couponKeyword, memberKeyword: issuedFilter.memberKeyword }
          });
          issuedList.value       = res.data.list;
          issuedTotal.value      = res.data.totalCount;
          issuedPagination.value = res.data.pagination;
          issuedSearched.value   = true;
        } catch(e) { console.error('발급 현황 오류', e); alert('목록을 불러오는 중 오류가 발생했습니다.'); }
      };

      const toggleCheckAll = (e) => {
        selectedIds.value = e.target.checked ? couponList.value.map(c => c.couponId) : [];
      };

      const downloadExcel = () => {
        const target = selectedIds.value.length > 0
          ? couponList.value.filter(c => selectedIds.value.includes(c.couponId))
          : couponList.value;

        if (target.length === 0) {
          alert('다운로드할 데이터가 없습니다. 먼저 검색을 실행해주세요.');
          return;
        }

        const statusMap = { ACTIVE:'활성', WAITING:'승인대기', EXPIRED:'만료', INACTIVE:'비활성', REJECTED:'반려' };
        const typeMap   = { FIXED:'정액', PERCENT:'정률' };

        let csv = '\uFEFF' + '쿠폰ID,쿠폰명,발급주체,할인유형,할인금액/율,최대할인,플랫폼부담%,파트너부담%,유효기간시작,유효기간만료,발급수,상태\n';
        target.forEach(c => {
          csv += [
            c.couponId,
            '"' + (c.couponName || '') + '"',
            '"' + (c.partnerId ? (c.partnerName || '') : '플랫폼') + '"',
            typeMap[c.discountType] || c.discountType,
            c.discountAmount || '',
            c.maxDiscountAmount || '',
            c.platformShare || '',
            c.partnerShare  || '',
            c.validFrom     || '',
            c.validUntil    || '',
            c.issuedCount   || 0,
            statusMap[c.status] || c.status
          ].join(',') + '\n';
        });

        const blob = new Blob([csv], { type: 'text/csv;charset=utf-8;' });
        const link = document.createElement('a');
        link.href = URL.createObjectURL(blob);
        link.download = '쿠폰목록_' + new Date().toISOString().slice(0, 10) + '.csv';
        document.body.appendChild(link);
        link.click();
        document.body.removeChild(link);
      };

      /* ── 승인/반려 ── */
      const openApproveModal = (c) => {
        approveTarget.value = c;
        Object.assign(approveForm, { result:'', memo:'' });
        showApproveModal.value = true;
      };
      const closeApproveModal = () => { showApproveModal.value = false; };
      const submitApprove = async () => {
        if (!approveForm.result) return;
        if (approveForm.result === 'REJECTED' && !approveForm.memo.trim()) {
          alert('반려 사유를 입력해주세요.');
          return;
        }
        try {
          await axios.post(`${contextPath}/api/admin/coupon/${approveTarget.value.couponId}/review`, {
            result: approveForm.result,
            memo:   approveForm.memo
          });
          const label = approveForm.result === 'ACTIVE' ? '승인' : '반려';
          alert(approveTarget.value.couponName + ' 쿠폰이 ' + label + ' 처리되었습니다.');
          closeApproveModal();
          fetchPending();
          fetchKpi();
          if (couponSearched.value) fetchCoupons(couponPageNo.value);
        } catch(e) { console.error('심사 오류', e); alert('처리 중 오류가 발생했습니다.'); }
      };

      /* ── 삭제 ── */
      const openDeleteConfirm  = (c)  => { deleteTarget.value = c;    showDeleteModal.value = true; };
      const openBulkDeleteModal = ()  => { deleteTarget.value = null; showDeleteModal.value = true; };
      const closeDeleteModal    = ()  => { showDeleteModal.value = false; };
      const submitDelete = async () => {
        const ids = deleteTarget.value ? [deleteTarget.value.couponId] : selectedIds.value;
        try {
          await axios.delete(`${contextPath}/api/admin/coupon`, { data: { couponIds: ids } });
          alert(ids.length + '개 쿠폰이 삭제되었습니다.');
          closeDeleteModal();
          fetchCoupons(couponPageNo.value);
          fetchKpi();
        } catch(e) { console.error('삭제 오류', e); alert('처리 중 오류가 발생했습니다.'); }
      };

      onMounted(() => { fetchKpi(); fetchPartnerOptions(); fetchCoupons(1); });

      return {
        kpi, activeTab, switchTab,
        couponFilter, couponList, couponTotal, couponPageNo, couponPagination, couponSearched,
        selectedIds, isAllChecked, pendingList,
        issuedFilter, issuedList, issuedTotal, issuedPageNo, issuedPagination, issuedSearched,
        partnerOptions,
        showApproveModal, approveTarget, approveForm,
        showDeleteModal, deleteTarget,
        fetchCoupons, fetchIssued, toggleCheckAll, downloadExcel,
        openApproveModal, closeApproveModal, submitApprove,
        openDeleteConfirm, openBulkDeleteModal, closeDeleteModal, submitDelete,
        goToEdit: (c) => {
          const id = c.couponId ?? c.coupon_id ?? c.id;
          if (!id) { console.error('[goToEdit] 쿠폰 객체:', c); alert('쿠폰 ID를 찾을 수 없습니다. 콘솔(F12)을 확인해주세요.'); return; }
          location.href = contextPath + '/admin/coupon/form?id=' + id;
        },
        resetCouponFilter: () => { couponFilter.discountType = 'ALL'; couponFilter.status = 'ALL'; couponFilter.issuer = 'ALL'; couponFilter.keyword = ''; fetchCoupons(1); },
        resetIssuedFilter: () => { issuedFilter.status = 'ALL'; issuedFilter.couponKeyword = ''; issuedFilter.memberKeyword = ''; fetchIssued(1); }
      };
    }
  }).mount('#app');
</script>

</body>
</html>
