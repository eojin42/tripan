<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <title>TripanSuper — 쿠폰 관리</title>
  <meta name="_csrf" content="${_csrf.token}"/>
  <meta name="_csrf_header" content="${_csrf.headerName}"/>
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
    .badge-scheduled { background:#EEF2FF; color:#4338CA; }

    .discount-chip {
      display:inline-flex; align-items:center; gap:4px;
      padding:3px 10px; border-radius:20px; font-size:12px; font-weight:800;
    }
    .chip-fixed   { background:#EEF2FF; color:#4338CA; }
    .chip-percent { background:#FFF7ED; color:#C2410C; }

    /* 발급 현황 */
    .badge-used     { background:#F0FDF4; color:#15803D; }
    .badge-unused   { background:#EFF6FF; color:#1D4ED8; }
    .badge-canceled { background:#F1F5F9; color:#94A3B8; }
    .badge-platform { background:#EFF6FF; color:#1D4ED8; }
    .badge-partner  { background:#F0FDF4; color:#15803D; }

    /* 버튼 행 */
    .btn-row { display:flex; gap:6px; justify-content:flex-end; }

    /* 위험 배너 */
    .danger-banner {
      padding:14px 16px; background:#FEF2F2; border:1.5px solid #FECACA;
      border-radius:12px; font-size:13px; font-weight:700; color:#DC2626;
    }

    /* 회원 검색 자동완성 */
    .member-search-wrap { position:relative; }
    .member-dropdown {
      position:absolute; top:calc(100% + 4px); left:0; right:0;
      background:#fff; border:1.5px solid var(--border); border-radius:10px;
      box-shadow:0 8px 24px rgba(0,0,0,0.10); z-index:100;
      max-height:200px; overflow-y:auto;
    }
    .member-dropdown-item {
      padding:10px 14px; cursor:pointer; font-size:13px;
      display:flex; align-items:center; gap:10px;
      border-bottom:1px solid var(--border); transition:background 0.1s;
    }
    .member-dropdown-item:last-child { border-bottom:none; }
    .member-dropdown-item:hover { background:var(--bg); }
    .member-dropdown-item .mid { font-weight:800; color:var(--text); }
    .member-dropdown-item .mname { font-size:12px; color:var(--muted); }
    .member-selected {
      display:flex; align-items:center; gap:10px;
      padding:10px 14px; background:#F0FDF4; border:1.5px solid #BBF7D0;
      border-radius:10px; font-size:13px;
    }
    .member-selected .mid { font-weight:800; color:#15803D; }
    .member-selected .mname { font-size:12px; color:#15803D; }
    .member-clear { margin-left:auto; background:none; border:none; cursor:pointer; color:#94A3B8; font-size:16px; line-height:1; }
    .member-clear:hover { color:#DC2626; }
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
          <p>플랫폼 쿠폰을 직접 등록하고 관리합니다.</p>
        </div>
        <div style="margin-left:auto;display:flex;gap:10px;">
          <button class="btn" style="background:#F0FDF4;color:#15803D;border:1px solid #BBF7D0;display:inline-flex;align-items:center;gap:6px;"
                  @click="openGrantModal">
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
              <path d="M20 12v10H4V12"/><rect x="2" y="7" width="20" height="5"/><path d="M12 22V7"/><path d="M12 7H7.5a2.5 2.5 0 0 1 0-5C11 2 12 7 12 7z"/><path d="M12 7h4.5a2.5 2.5 0 0 0 0-5C13 2 12 7 12 7z"/>
            </svg>
            회원 쿠폰 지급
          </button>
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
          <div class="kpi-sub">총 등록 쿠폰</div>
        </div>
        <div class="card kpi-card fade-up fade-up-2">
          <div class="kpi-label">현재 사용 가능</div>
          <div class="kpi-value" style="color:#15803D;">{{ kpi.active }}</div>
          <div class="kpi-sub">유효기간 내 활성 쿠폰</div>
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
              <option value="SCHEDULED">예정</option>
              <option value="EXPIRED">만료</option>
              <option value="INACTIVE">비활성</option>
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
                  <th style="width:60px;">ID</th>
                  <th>쿠폰명</th>
                  <th>발급 주체</th>
                  <th>할인 유형</th>
                  <th>할인 금액/율</th>
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
                  <td class="num" style="color:var(--muted);font-size:12px;">{{ c.couponId }}</td>
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
                  <td
					  style="font-size:12px;color:var(--muted);"
					  v-html="String(c.validFrom || '').replace('T', ' ') + ' ~<br>' + String(c.validUntil || '').replace('T', ' ')">
					</td>
                  <td class="num">{{ c.issuedCount }}</td>
                  <td>
                    <template v-if="c.status === 'INACTIVE'">
                      <span class="badge badge-inactive">비활성</span>
                    </template>
                    <template v-else>
                      <template v-if="c.validFrom && new Date(c.validFrom.replace('T',' ')) > new Date()">
                        <span class="badge badge-scheduled">예정</span>
                      </template>
                      <template v-else-if="c.validUntil && new Date(c.validUntil.replace('T',' ')) < new Date()">
                        <span class="badge badge-expired">만료</span>
                      </template>
                      <template v-else>
                        <span class="badge badge-active">활성</span>
                      </template>
                    </template>
                  </td>
                  <td class="right">
                    <div class="btn-row">
                      <button class="btn btn-sm"
                              style="background:#EFF6FF;color:#1D4ED8;border:1px solid #BFDBFE;"
                              @click="openDetailModal(c.couponId)">상세</button>
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
           회원 발급 현황 탭
      ══════════════════════════════ -->
      <template v-if="activeTab === 'issued'">
        <div class="card filter-card fade-up">
          <div class="filter-row">
            <div class="filter-label">발급 검색</div>
            <select class="filter-select" v-model="issuedFilter.status" style="width:130px;">
              <option value="ALL">전체 상태</option>
              <option value="AVAILABLE">사용 가능</option>
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
                  <th class="right">관리</th>
                </tr>
              </thead>
              <tbody>
                <tr v-if="!issuedSearched">
                  <td colspan="10" style="text-align:center;padding:50px 0;color:var(--muted);">
                    검색 조건을 설정한 후 <strong>[검색]</strong> 버튼을 눌러주세요.
                  </td>
                </tr>
                <tr v-else-if="issuedList.length === 0">
                  <td colspan="10" style="text-align:center;padding:50px 0;color:var(--muted);">검색 결과가 없습니다.</td>
                </tr>
                <tr v-for="i in issuedList" :key="i.memberCouponId">
                  <td class="num" style="color:var(--muted);font-size:12px;">{{ i.memberCouponId }}</td>
                  <td><strong>{{ i.couponName }}</strong></td>
                  <td>
                    <span class="badge" :class="i.partnerId ? 'badge-partner' : 'badge-platform'">
                      {{ i.partnerId ? i.partnerName : '플랫폼' }}
                    </span>
                  </td>
                  <td>{{ i.loginId }}</td>
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
                  <td style="font-size:12px;color:var(--muted);">{{ i.expiredAt }}</td>
                  <td>
                    <span v-if="i.status === 'AVAILABLE'" class="badge badge-unused">사용 가능</span>
                    <span v-else-if="i.status === 'UNUSED'"  class="badge badge-unused">미사용</span>
                    <span v-else-if="i.status === 'USED'"    class="badge badge-used">사용 완료</span>
                    <span v-else-if="i.status === 'CANCELED'" class="badge badge-canceled">취소</span>
                    <span v-else class="badge badge-canceled">{{ i.status }}</span>
                  </td>
                  <td class="right">
                    <button v-if="i.status === 'AVAILABLE' || i.status === 'UNUSED'"
                            class="btn btn-sm"
                            style="background:#FFF7ED;color:#C2410C;border:1px solid #FED7AA;"
                            @click="openRevokeModal(i)">회수</button>
                    <span v-else style="font-size:12px;color:var(--muted);">—</span>
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

    <!-- ══════════ 쿠폰 상세 모달 ══════════ -->
    <div class="modal-overlay" :class="{ open: showDetailModal }" @click.self="closeDetailModal">
      <div class="modal-sheet" style="max-width:540px;">
        <div class="ms-head">
          <h3>{{ detailCoupon ? detailCoupon.couponName : '' }}</h3>
          <p style="display:flex;align-items:center;gap:8px;">
            <span class="badge" :class="detailCoupon && detailCoupon.partnerId ? 'badge-partner' : 'badge-platform'">
              {{ detailCoupon && detailCoupon.partnerId ? detailCoupon.partnerName : '플랫폼' }}
            </span>
            <span v-if="detailCoupon" class="badge"
                  :class="{
                    'badge-active': detailCoupon.status === 'ACTIVE',
                    'badge-expired': detailCoupon.status === 'EXPIRED',
                    'badge-scheduled': detailCoupon.status === 'SCHEDULED',
                    'badge-inactive': detailCoupon.status === 'INACTIVE'
                  }">
              {{ {ACTIVE:'활성', EXPIRED:'만료', SCHEDULED:'예정', INACTIVE:'비활성'}[detailCoupon.status] || detailCoupon.status }}
            </span>
          </p>
        </div>
        <div class="ms-body" v-if="detailCoupon">

          <!-- 파트너사 + 부담 비율 (파트너 쿠폰일 때만) -->
          <div v-if="detailCoupon.partnerId" style="display:grid;grid-template-columns:1fr 1fr;gap:12px;">
            <div style="padding:14px 16px;background:#F0FDF4;border:1px solid #BBF7D0;border-radius:12px;">
              <div style="font-size:11px;font-weight:800;color:#15803D;margin-bottom:6px;">파트너사</div>
              <div style="font-weight:800;font-size:15px;color:#15803D;">{{ detailCoupon.partnerName }}</div>
            </div>
            <div style="padding:14px 16px;background:var(--bg);border-radius:12px;">
              <div style="font-size:11px;font-weight:800;color:var(--muted);margin-bottom:6px;">부담 비율</div>
              <div style="font-weight:700;font-size:13px;">
                플랫폼 <strong>{{ detailCoupon.platformShare }}%</strong>
                &nbsp;/&nbsp;
                파트너 <strong>{{ detailCoupon.partnerShare }}%</strong>
              </div>
            </div>
          </div>

          <!-- 할인 정보 -->
          <div style="display:grid;grid-template-columns:1fr 1fr;gap:12px;">
            <div style="padding:14px 16px;background:var(--bg);border-radius:12px;">
              <div style="font-size:11px;font-weight:800;color:var(--muted);margin-bottom:6px;">할인 유형</div>
              <div style="font-weight:800;font-size:15px;">
                <span class="discount-chip" :class="detailCoupon.discountType === 'FIXED' ? 'chip-fixed' : 'chip-percent'">
                  {{ detailCoupon.discountType === 'FIXED' ? '정액' : '정률' }}
                </span>
              </div>
            </div>
            <div style="padding:14px 16px;background:var(--bg);border-radius:12px;">
              <div style="font-size:11px;font-weight:800;color:var(--muted);margin-bottom:6px;">할인 금액/율</div>
              <div style="font-weight:800;font-size:15px;">
                <span v-if="detailCoupon.discountType === 'FIXED'">{{ Number(detailCoupon.discountAmount).toLocaleString() }}원</span>
                <span v-else>{{ detailCoupon.discountAmount }}%</span>
              </div>
            </div>
            <div style="padding:14px 16px;background:var(--bg);border-radius:12px;" v-if="detailCoupon.maxDiscountAmount">
              <div style="font-size:11px;font-weight:800;color:var(--muted);margin-bottom:6px;">최대 할인 금액</div>
              <div style="font-weight:800;font-size:15px;">{{ Number(detailCoupon.maxDiscountAmount).toLocaleString() }}원</div>
            </div>
            <div style="padding:14px 16px;background:var(--bg);border-radius:12px;" v-if="detailCoupon.minOrderAmount">
              <div style="font-size:11px;font-weight:800;color:var(--muted);margin-bottom:6px;">최소 결제 금액</div>
              <div style="font-weight:800;font-size:15px;">{{ Number(detailCoupon.minOrderAmount).toLocaleString() }}원 이상</div>
            </div>
          </div>

          <!-- 유효기간 -->
          <div style="padding:14px 16px;background:var(--bg);border-radius:12px;">
            <div style="font-size:11px;font-weight:800;color:var(--muted);margin-bottom:6px;">유효기간</div>
            <div style="font-weight:700;font-size:14px;">
              {{ String(detailCoupon.validFrom || '').replace('T', ' ') }}
              &nbsp;~&nbsp;
              {{ String(detailCoupon.validUntil || '').replace('T', ' ') }}
            </div>
          </div>

          <!-- 발급 조건 -->
          <div style="padding:14px 16px;background:var(--bg);border-radius:12px;" v-if="detailCoupon.issueConditionType && detailCoupon.issueConditionType !== 'NONE'">
            <div style="font-size:11px;font-weight:800;color:var(--muted);margin-bottom:6px;">발급 조건</div>
            <div style="font-weight:700;font-size:14px;">
              <span v-if="detailCoupon.issueConditionType === 'NEW_MEMBER'">신규 가입 후 {{ detailCoupon.issueConditionValue }}일 이내</span>
              <span v-else-if="detailCoupon.issueConditionType === 'BOOKING_COUNT'">예약 {{ detailCoupon.issueConditionValue }}회 이상</span>
              <span v-else-if="detailCoupon.issueConditionType === 'REVIEW_COUNT'">리뷰 {{ detailCoupon.issueConditionValue }}개 이상</span>
              <span v-else-if="detailCoupon.issueConditionType === 'AMOUNT_SPENT'">누적 결제 {{ Number(detailCoupon.issueConditionValue).toLocaleString() }}원 이상</span>
              <span v-else>{{ detailCoupon.issueConditionType }} / {{ detailCoupon.issueConditionValue }}</span>
            </div>
          </div>
          <div style="padding:14px 16px;background:var(--bg);border-radius:12px;" v-else>
            <div style="font-size:11px;font-weight:800;color:var(--muted);margin-bottom:6px;">발급 조건</div>
            <div style="font-weight:700;font-size:14px;color:var(--muted);">조건 없음 (누구나 발급 가능)</div>
          </div>

          <!-- 발급 수 -->
          <div style="padding:14px 16px;background:var(--bg);border-radius:12px;">
            <div style="font-size:11px;font-weight:800;color:var(--muted);margin-bottom:6px;">총 발급 수</div>
            <div style="font-weight:800;font-size:15px;">{{ detailCoupon.issuedCount }}건</div>
          </div>

        </div>
        <div class="ms-foot">
          <button class="btn-m btn-m-ghost" @click="closeDetailModal">닫기</button>
          <button class="btn-m btn-m-primary" @click="() => { closeDetailModal(); goToEdit(detailCoupon); }">수정하기</button>
        </div>
      </div>
    </div>

    <!-- ══════════ 회원 쿠폰 지급 모달 ══════════ -->
    <div class="modal-overlay" :class="{ open: showGrantModal }" @click.self="closeGrantModal">
      <div class="modal-sheet" style="max-width:480px;">
        <div class="ms-head">
          <h3>회원 쿠폰 지급</h3>
          <p>특정 회원에게 쿠폰을 직접 지급합니다.</p>
        </div>
        <div class="ms-body">

          <!-- 회원 검색 -->
          <div class="fg">
            <label>회원 검색 <span style="color:var(--danger);">*</span></label>
            <!-- 선택된 회원 표시 -->
            <div v-if="grantForm.selectedMember" class="member-selected">
              <div>
                <div class="mid">{{ grantForm.selectedMember.loginId }}</div>
                <div class="mname">{{ grantForm.selectedMember.username }} · {{ grantForm.selectedMember.email }}</div>
              </div>
              <button class="member-clear" @click="clearMember" title="다시 선택">✕</button>
            </div>
            <!-- 검색 입력 -->
            <div v-else class="member-search-wrap">
              <input type="text" v-model="grantForm.memberKeyword"
                     placeholder="회원 ID 또는 이름으로 검색"
                     @input="searchMembers"
                     @keydown.escape="memberSearchResults = []"
                     autocomplete="off" />
              <!-- 검색 결과 드롭다운 -->
              <div class="member-dropdown" v-if="memberSearchResults.length > 0">
                <div class="member-dropdown-item"
                     v-for="m in memberSearchResults" :key="m.memberId"
                     @click="selectMember(m)">
                  <div>
                    <div class="mid">{{ m.loginId }}</div>
                    <div class="mname">{{ m.username }} · {{ m.email }}</div>
                  </div>
                </div>
              </div>
              <div class="member-dropdown" v-if="memberSearched && memberSearchResults.length === 0">
                <div class="member-dropdown-item" style="color:var(--muted);cursor:default;">검색 결과가 없습니다.</div>
              </div>
            </div>
          </div>

          <!-- 쿠폰 선택 -->
          <div class="fg">
            <label>지급할 쿠폰 <span style="color:var(--danger);">*</span></label>
            <select v-model="grantForm.couponId">
              <option value="">쿠폰을 선택하세요</option>
              <option v-for="c in activeCouponOptions" :key="c.couponId" :value="c.couponId">
                {{ c.couponName }} ({{ c.discountType === 'FIXED' ? Number(c.discountAmount).toLocaleString() + '원' : c.discountAmount + '%' }})
              </option>
            </select>
          </div>

          <div v-if="grantForm.selectedMember && grantForm.couponId"
               style="padding:12px 16px;background:#F0FDF4;border:1.5px solid #BBF7D0;border-radius:10px;font-size:13px;color:#15803D;font-weight:700;">
            ✅ <strong>{{ grantForm.selectedMember.loginId }}</strong> 회원에게 즉시 지급됩니다.
          </div>
        </div>
        <div class="ms-foot">
          <button class="btn-m btn-m-ghost" @click="closeGrantModal">취소</button>
          <button class="btn-m btn-m-success" @click="submitGrant"
                  :disabled="!grantForm.selectedMember || !grantForm.couponId"
                  :style="(!grantForm.selectedMember || !grantForm.couponId) ? 'opacity:0.4;cursor:not-allowed;' : ''">
            지급 확인
          </button>
        </div>
      </div>
    </div>

    <!-- ══════════ 쿠폰 회수 확인 모달 ══════════ -->
    <div class="modal-overlay" :class="{ open: showRevokeModal }" @click.self="closeRevokeModal">
      <div class="modal-sheet" style="max-width:420px;">
        <div class="ms-head">
          <h3>쿠폰 회수</h3>
          <p>회원의 미사용 쿠폰을 회수합니다.</p>
        </div>
        <div class="ms-body">
          <div class="danger-banner" style="background:#FFF7ED;border-color:#FED7AA;color:#C2410C;">
            <strong>{{ revokeTarget ? revokeTarget.loginId : '' }}</strong> 회원의
            <strong>{{ revokeTarget ? revokeTarget.couponName : '' }}</strong> 쿠폰을 회수합니다.
            회수 후 해당 회원은 이 쿠폰을 사용할 수 없습니다.
          </div>
        </div>
        <div class="ms-foot">
          <button class="btn-m btn-m-ghost"  @click="closeRevokeModal">취소</button>
          <button class="btn-m btn-m-warn" @click="submitRevoke">회수 확인</button>
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

  /* CSRF 토큰 설정 */
  const csrfToken = document.querySelector('meta[name="_csrf"]')?.getAttribute('content');
  const csrfHeader = document.querySelector('meta[name="_csrf_header"]')?.getAttribute('content');
  if (csrfToken && csrfHeader) {
    axios.defaults.headers.common[csrfHeader] = csrfToken;
  }

  createApp({
    setup() {

      /* ── KPI ── */
      const kpi = reactive({ total:0, active:0, issuedThisMonth:0, usedThisMonth:0 });

      /* ── 탭 ── */
      const activeTab = ref('all');
      const switchTab = (tab) => {
        activeTab.value = tab;
      };

      /* ── 쿠폰 목록 ── */
      const couponFilter    = reactive({ discountType:'ALL', status:'ALL', keyword:'' });
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

      /* ── 발급 현황 ── */
      const issuedFilter    = reactive({ status:'ALL', couponKeyword:'', memberKeyword:'' });
      const issuedList      = ref([]);
      const issuedTotal     = ref(0);
      const issuedPageNo    = ref(1);
      const issuedPagination = ref(null);
      const issuedSearched  = ref(false);

      /* ── 삭제 모달 ── */
      const showDeleteModal = ref(false);
      const deleteTarget    = ref(null);

      /* ── 상세 모달 ── */
      const showDetailModal = ref(false);
      const detailCoupon    = ref(null);

      const openDetailModal = async (couponId) => {
        try {
          const url = (contextPath + '/api/admin/coupon/' + couponId).replace(/([^:])\/\//g, '$1/');
          const res = await axios.get(url);
          detailCoupon.value = res.data;
          showDetailModal.value = true;
        } catch(e) { console.error('상세 조회 오류', e); alert('상세 정보를 불러오는 중 오류가 발생했습니다.'); }
      };
      const closeDetailModal = () => {
        showDetailModal.value = false;
        setTimeout(() => { detailCoupon.value = null; }, 300);
      };

      /* ── 회수 모달 ── */
      const showRevokeModal = ref(false);
      const revokeTarget    = ref(null);

      /* ── 지급 모달 ── */
      const showGrantModal      = ref(false);
      const grantForm           = reactive({ memberKeyword:'', selectedMember:null, couponId:'' });
      const memberSearchResults = ref([]);
      const memberSearched      = ref(false);
      let   memberSearchTimer   = null;

      const activeCouponOptions = computed(() =>
        couponList.value.filter(c => c.status === 'ACTIVE')
      );

      const searchMembers = () => {
        memberSearched.value = false;
        clearTimeout(memberSearchTimer);
        if (!grantForm.memberKeyword.trim()) { memberSearchResults.value = []; return; }
        memberSearchTimer = setTimeout(async () => {
          try {
            const res = await axios.get(`${contextPath}/api/admin/coupon/member/search`, {
              params: { keyword: grantForm.memberKeyword.trim() }
            });
            memberSearchResults.value = res.data;
            memberSearched.value = true;
          } catch(e) { console.error('회원 검색 오류', e); }
        }, 300);
      };

      const selectMember = (m) => {
        grantForm.selectedMember = m;
        memberSearchResults.value = [];
        memberSearched.value = false;
      };

      const clearMember = () => {
        grantForm.selectedMember = null;
        grantForm.memberKeyword  = '';
        memberSearchResults.value = [];
        memberSearched.value = false;
      };

      /* ── API ── */
      const fetchKpi = async () => {
        try {
          const res = await axios.get(`${contextPath}/api/admin/coupon/kpi`);
          Object.assign(kpi, res.data);
        } catch(e) { console.error('KPI 오류', e); }
      };

      /* 유효기간 기준으로 활성 쿠폰 수 재계산 (백엔드 active 필드 보완) */
      const recomputeActiveKpi = (list) => {
        const now = new Date();
        const activeCount = list.filter(c => {
          if (c.status === 'INACTIVE') return false;
          const from  = c.validFrom  ? new Date(c.validFrom.replace('T',' '))  : null;
          const until = c.validUntil ? new Date(c.validUntil.replace('T',' ')) : null;
          return (!from || from <= now) && (!until || until >= now);
        }).length;
        if (activeCount > 0 || kpi.active === 0) kpi.active = activeCount;
      };

      const fetchCoupons = async (page = 1) => {
        couponPageNo.value = page;
        try {
          const res = await axios.get(`${contextPath}/api/admin/coupon/list`, {
            params: { page, discountType: couponFilter.discountType, status: couponFilter.status, keyword: couponFilter.keyword }
          });
          couponList.value       = res.data.list;
          couponTotal.value      = res.data.totalCount;
          couponPagination.value = res.data.pagination;
          couponSearched.value   = true;
          selectedIds.value      = [];
          recomputeActiveKpi(res.data.list);
        } catch(e) { console.error('목록 오류', e); alert('목록을 불러오는 중 오류가 발생했습니다.'); }
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

        const statusMap = { ACTIVE:'활성', EXPIRED:'만료', INACTIVE:'비활성' };
        const typeMap   = { FIXED:'정액', PERCENT:'정률' };

        let csv = '\uFEFF' + '쿠폰ID,쿠폰명,할인유형,할인금액/율,최대할인,유효기간시작,유효기간만료,발급수,상태\n';
        target.forEach(c => {
          csv += [
            c.couponId,
            '"' + (c.couponName || '') + '"',
            typeMap[c.discountType] || c.discountType,
            c.discountAmount || '',
            c.maxDiscountAmount || '',
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

      /* ── 삭제 ── */
      const openDeleteConfirm  = (c)  => { deleteTarget.value = c;    showDeleteModal.value = true; };
      const openBulkDeleteModal = ()  => { deleteTarget.value = null; showDeleteModal.value = true; };
      const closeDeleteModal    = ()  => { showDeleteModal.value = false; };
      const submitDelete = async () => {
        const ids = deleteTarget.value ? [deleteTarget.value.couponId] : selectedIds.value;
        try {
          await axios.post(`${contextPath}/api/admin/coupon/delete`, { couponIds: ids });
          alert(ids.length + '개 쿠폰이 삭제되었습니다.');
          closeDeleteModal();
          fetchCoupons(couponPageNo.value);
          fetchKpi();
        } catch(e) { console.error('삭제 오류', e); alert('처리 중 오류가 발생했습니다.'); }
      };

      /* ── 회수 ── */
      const openRevokeModal  = (i) => {
        revokeTarget.value = i;
        showRevokeModal.value = true;
      };
      const closeRevokeModal = ()  => { showRevokeModal.value = false; };
      const submitRevoke = async () => {
        const id = revokeTarget.value.memberCouponId ?? revokeTarget.value.member_coupon_id;
        if (!id) {
          alert('회수할 쿠폰 ID를 찾을 수 없습니다.');
          return;
        }
        try {
          const revokeUrl = (contextPath + '/api/admin/coupon/issued/' + id + '/revoke').replace(/([^:])\/\//g, '$1/');
          await axios.post(revokeUrl);
          alert(revokeTarget.value.loginId + ' 회원의 [' + revokeTarget.value.couponName + '] 쿠폰이 회수되었습니다.');
          closeRevokeModal();
          fetchIssued(issuedPageNo.value);
          fetchKpi();
        } catch(e) { console.error('회수 오류', e); alert('처리 중 오류가 발생했습니다.'); }
      };

      /* ── 지급 ── */
      const openGrantModal  = () => {
        Object.assign(grantForm, { memberKeyword:'', selectedMember:null, couponId:'' });
        memberSearchResults.value = [];
        memberSearched.value = false;
        showGrantModal.value = true;
        if (couponList.value.length === 0) fetchCoupons(1);
      };
      const closeGrantModal = () => { showGrantModal.value = false; };
      const submitGrant = async () => {
        if (!grantForm.selectedMember || !grantForm.couponId) return;
        try {
          await axios.post(`${contextPath}/api/admin/coupon/grant`, {
            loginId:  grantForm.selectedMember.loginId,
            couponId: grantForm.couponId
          });
          alert('[' + grantForm.selectedMember.loginId + '] 회원에게 쿠폰이 지급되었습니다.');
          closeGrantModal();
          if (activeTab.value === 'issued') fetchIssued(1);
          fetchKpi();
        } catch(e) {
          if (e.response?.status === 404) alert('존재하지 않는 회원입니다.');
          else { console.error('지급 오류', e); alert('처리 중 오류가 발생했습니다.'); }
        }
      };

      onMounted(() => { fetchKpi(); fetchCoupons(1); });

      return {
        kpi, activeTab, switchTab,
        couponFilter, couponList, couponTotal, couponPageNo, couponPagination, couponSearched,
        selectedIds, isAllChecked,
        issuedFilter, issuedList, issuedTotal, issuedPageNo, issuedPagination, issuedSearched,
        showDeleteModal, deleteTarget,
        showDetailModal, detailCoupon, openDetailModal, closeDetailModal,
        showRevokeModal, revokeTarget,
        showGrantModal, grantForm, activeCouponOptions, memberSearchResults, memberSearched,
        fetchCoupons, fetchIssued, toggleCheckAll, downloadExcel,
        openDeleteConfirm, openBulkDeleteModal, closeDeleteModal, submitDelete,
        openRevokeModal, closeRevokeModal, submitRevoke,
        openGrantModal, closeGrantModal, submitGrant,
        searchMembers, selectMember, clearMember,
        goToEdit: (c) => {
          const id = c.couponId ?? c.coupon_id ?? c.id;
          if (!id) { console.error('[goToEdit] 쿠폰 객체:', c); alert('쿠폰 ID를 찾을 수 없습니다. 콘솔(F12)을 확인해주세요.'); return; }
          location.href = contextPath + '/admin/coupon/form?id=' + id;
        },
        resetCouponFilter: () => { couponFilter.discountType = 'ALL'; couponFilter.status = 'ALL'; couponFilter.keyword = ''; fetchCoupons(1); },
        resetIssuedFilter: () => { issuedFilter.status = 'ALL'; issuedFilter.couponKeyword = ''; issuedFilter.memberKeyword = ''; fetchIssued(1); }
      };
    }
  }).mount('#app');
</script>

</body>
</html>
