<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <title>TripanSuper — 파트너사 관리</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/dist/css/admin.css">
  <style>
    .col-check { width: 44px; text-align: center; }
    input[type="checkbox"] { width: 16px; height: 16px; cursor: pointer; accent-color: var(--primary); }

    .bulk-bar {
      display: none; align-items: center; gap: 12px;
      padding: 12px 20px; background: #FEF2F2;
      border: 1.5px solid #FECACA; border-radius: 14px;
      margin-bottom: 16px; animation: slideDown 0.2s ease;
    }
    .bulk-bar.visible { display: flex; }
    @keyframes slideDown { from{opacity:0;transform:translateY(-6px);} to{opacity:1;transform:translateY(0);} }
    .bulk-count       { font-size:13px; font-weight:800; color:#DC2626; background:#FEE2E2; padding:4px 12px; border-radius:20px; }
    .bulk-bar-label   { font-size:13px; font-weight:700; color:var(--text); }
    .bulk-bar-actions { display:flex; gap:8px; margin-left:auto; }
    .btn-bulk { height:36px; padding:0 16px; border-radius:9px; font-size:13px; font-weight:800; border:none; cursor:pointer; transition:opacity 0.15s; }
    .btn-bulk-danger { background:#DC2626; color:#fff; }
    .btn-bulk-black  { background:#111; color:#fff; }
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
      background: #fff; width: 100%; max-width: 480px;
      border-radius: 22px; overflow: hidden;
      box-shadow: 0 24px 64px rgba(0,0,0,0.16);
      animation: modalUp 0.3s cubic-bezier(0.16,1,0.3,1);
      display: flex; flex-direction: column; max-height: 90vh;
    }
    .modal-sheet-wide { max-width: 720px; }
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
    .fg textarea { resize:vertical; min-height:80px; line-height:1.5; }
    .btn-m         { flex:1; height:46px; border-radius:11px; font-weight:800; font-size:14px; border:none; cursor:pointer; transition:opacity 0.15s; }
    .btn-m-ghost   { background:var(--bg); color:var(--text); }
    .btn-m-primary { background:#111; color:#fff; }
    .btn-m-danger  { background:#DC2626; color:#fff; }
    .btn-m-success { background:#F0FDF4; color:#15803D; }
    .btn-m:hover   { opacity:0.84; }
    .filter-row .btn { display:inline-flex; align-items:center; gap:6px; }
    .btn-reset { background: var(--bg); color: var(--muted); border: 1.5px solid var(--border); border-radius: 10px; height: 38px; padding: 0 14px; font-size: 13px; font-weight: 700; cursor: pointer; display: inline-flex; align-items: center; gap: 5px; transition: all 0.15s; }
    .btn-reset:hover { background: #F1F5F9; color: var(--text); border-color: #94A3B8; }
    .btn-reset svg { transition: transform 0.35s cubic-bezier(0.34,1.56,0.64,1); }
    .btn-reset:hover svg { transform: rotate(-180deg); }

    /* badge */
    .badge-active     { background:#F0FDF4; color:#15803D; }
    .badge-pending    { background:#FFF7ED; color:#C2410C; }
    .badge-suspended  { background:#FEF2F2; color:#DC2626; }
    .badge-approved   { background:#DBEAFE; color:#1D4ED8; }
    .badge-rejected   { background:#FEE2E2; color:#991B1B; }

    /* 별점 */
    .star-wrap  { display:inline-flex; align-items:center; gap:4px; }
    .star-score { font-weight:800; font-size:14px; color:#F59E0B; }
    .star-count { font-size:12px; color:var(--muted); }

    /* 매출 bar */
    .sales-bar-wrap { display:flex; align-items:center; gap:8px; min-width:110px; }
    .sales-bar-bg   { flex:1; height:6px; background:var(--border); border-radius:10px; overflow:hidden; }
    .sales-bar-fill { height:100%; background:var(--primary); border-radius:10px; transition:width 0.4s ease; }
    .sales-amount   { font-size:12px; font-weight:800; color:var(--text); white-space:nowrap; }

    /* 위험 지표 */
    .risk-low  { color:#15803D; font-weight:700; font-size:13px; }
    .risk-mid  { color:#B45309; font-weight:700; font-size:13px; }
    .risk-high { color:#DC2626; font-weight:700; font-size:13px; }

    /* 경고 배너 */
    .danger-banner {
      padding:14px 16px; background:#FEF2F2; border:1.5px solid #FECACA;
      border-radius:12px; font-size:13px; font-weight:700; color:#DC2626;
      display:flex; align-items:center; gap:10px;
    }
    .danger-banner svg { flex-shrink:0; }

    /* 상세 모달 전용 */
    .detail-section-title {
      font-size: 12px; font-weight: 800; color: var(--muted);
      text-transform: uppercase; letter-spacing: 0.6px;
      padding-bottom: 8px; border-bottom: 1.5px solid var(--border);
      margin-bottom: 4px;
    }
    .info-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 12px; }
    .info-item { display: flex; flex-direction: column; gap: 3px; }
    .info-item .i-label { font-size: 11px; font-weight: 700; color: var(--muted); }
    .info-item .i-value { font-size: 14px; font-weight: 700; color: var(--text); word-break: break-all; }
    .info-item .i-value a { color: var(--primary); text-decoration: none; }
    .info-item .i-value a:hover { text-decoration: underline; }
    .detail-empty { text-align:center; padding: 20px 0; color: var(--muted); font-size: 13px; }

    /* 일괄처리 로딩 */
    .btn-m:disabled { opacity: 0.5; cursor: not-allowed; }
  </style>
</head>
<body>

<div class="admin-layout">
  <jsp:include page="../layout/sidebar.jsp"><jsp:param name="activePage" value="partners"/></jsp:include>
  <div class="main-wrapper">
    <jsp:include page="../layout/header.jsp" />

    <div id="app" style="flex:1;display:flex;flex-direction:column;min-height:0;overflow:hidden;">
    <main class="main-content" style="flex:1;overflow-y:auto;">

      <!-- 페이지 헤더 -->
      <div class="page-header fade-up">
        <div>
          <h1>파트너사 관리</h1>
          <p>등록된 파트너사의 매출·평점 현황을 모니터링하고 상태를 통합 관리합니다.</p>
        </div>
        <div style="margin-left:auto;">
          <button class="btn btn-primary" style="display:inline-flex;align-items:center;gap:6px;"
                  @click="openRegisterModal">
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
              <line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/>
            </svg>
            파트너사 등록
          </button>
        </div>
      </div>

      <!-- KPI 카드 -->
      <div class="kpi-grid">
        <div class="card kpi-card fade-up fade-up-1">
          <div class="kpi-label">전체 파트너사</div>
          <div class="kpi-value">{{ kpi.total }}</div>
          <div class="kpi-sub">활성 {{ kpi.active }} / 정지 {{ kpi.suspended }}</div>
        </div>
        <div class="card kpi-card fade-up fade-up-2">
          <div class="kpi-label">승인 대기</div>
          <div class="kpi-value" style="color:var(--warning)">{{ kpi.pending }}</div>
          <div class="kpi-sub">검토 필요 파트너사</div>
        </div>
        <div class="card kpi-card fade-up fade-up-3">
          <div class="kpi-label">이번 달 총 매출</div>
          <div class="kpi-value">{{ kpi.totalSalesLabel }}</div>
          <div class="kpi-sub">전체 파트너 합산</div>
        </div>
        <div class="card kpi-card fade-up fade-up-4">
          <div class="kpi-label">위험 파트너 (저평점)</div>
          <div class="kpi-value" style="color:var(--danger)">{{ kpi.lowRatingCount }}</div>
          <div class="badge badge-danger">즉시 검토 필요</div>
        </div>
      </div>

      <!-- 필터 바 -->
      <div class="card filter-card fade-up">
        <div class="filter-row">
          <div class="filter-label">파트너사 검색</div>
          <select class="filter-select" v-model="filter.status" @change="fetchList(1)" style="width:130px;">
            <option value="ALL">전체 상태</option>
            <option value="PENDING">승인 대기</option>
            <option value="ACTIVE">활성</option>
            <option value="APPROVED">승인완료</option>
            <option value="SUSPENDED">정지</option>
            <option value="REJECTED">반려</option>
            <option value="BLOCKED">영구차단</option>
          </select>
          <select class="filter-select" v-model="filter.sort" style="width:130px;">
            <option value="SALES_DESC">매출 높은순</option>
            <option value="SALES_ASC">매출 낮은순</option>
            <option value="RATING_DESC">평점 높은순</option>
            <option value="RATING_ASC">평점 낮은순</option>
            <option value="REG_DESC">등록일 최신순</option>
          </select>
          <input type="text" class="keyword-input" v-model="filter.keyword"
                 placeholder="파트너사명 검색"
                 @keyup.enter="fetchList(1)"
                 style="flex:1;">
          <button class="btn-reset" @click="resetFilter()" title="검색 초기화">
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><polyline points="1 4 1 10 7 10"/><path d="M3.51 15a9 9 0 1 0 .49-3.51"/></svg>
            초기화
          </button>
          <button class="btn btn-primary" @click="fetchList(1)">
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
              <circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/>
            </svg>
            검색
          </button>
        </div>
      </div>

      <!-- 테이블 카드 -->
      <div class="card table-card fade-up">

        <!-- bulk bar -->
        <div class="bulk-bar" :class="{ visible: selectedIds.length > 0 }">
          <span class="bulk-count">{{ selectedIds.length }}개 선택</span>
          <span class="bulk-bar-label">선택된 파트너사에 일괄 작업을 수행합니다.</span>
          <div class="bulk-bar-actions">
            <button class="btn-bulk btn-bulk-excel"  @click="copySelectedNames">파트너사명 복사</button>
            <button class="btn-bulk btn-bulk-black"  @click="openBulkStatusModal">상태 일괄 변경</button>
            <button class="btn-bulk btn-bulk-danger" @click="openBulkDeactivateModal">일괄 차단</button>
            <button class="btn-bulk btn-bulk-excel"  @click="downloadExcel">엑셀 다운로드</button>
          </div>
        </div>

        <div class="w-header" style="display:flex;justify-content:space-between;align-items:center;margin-bottom:16px;">
          <h2 style="display:inline-flex;align-items:center;gap:8px;">
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <rect x="2" y="7" width="20" height="14" rx="2" ry="2"/>
              <path d="M16 21V5a2 2 0 0 0-2-2h-4a2 2 0 0 0-2 2v16"/>
            </svg>
            파트너사 목록
          </h2>
          <div style="display:flex;align-items:center;gap:8px;">
            <span style="font-size:13px;color:var(--muted);">총 {{ totalCount }}개</span>
            <button class="btn btn-outline btn-sm" @click="downloadExcel"
                    style="display:inline-flex;align-items:center;gap:6px;">
              <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
                <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/>
                <polyline points="7 10 12 15 17 10"/><line x1="12" y1="15" x2="12" y2="3"/>
              </svg>
              엑셀 다운로드
            </button>
          </div>
        </div>

        <div class="table-responsive">
          <table>
            <thead>
              <tr>
                <th class="col-check">
                  <input type="checkbox" @change="toggleCheckAll" :checked="isAllChecked">
                </th>
                <th>파트너사명</th>
                <th>상태</th>
                <th>이번 달 매출</th>
                <th>평점</th>
                <th>상품 수</th>
                <th>수수료율</th>
                <th>위험 지표</th>
                <th style="cursor:pointer;user-select:none;" @click="toggleSort">
                  등록일 <span>{{ sortAsc ? '↑' : '↓' }}</span>
                </th>
                <th class="right">관리</th>
              </tr>
            </thead>
            <tbody>
              <tr v-if="!searched">
                <td colspan="10" style="text-align:center; padding:50px 0; color:var(--muted);">
                  검색 조건을 선택하면 목록이 표시됩니다.
                </td>
              </tr>
              <tr v-else-if="partnerList.length === 0">
                <td colspan="10" style="text-align:center; padding:50px 0; color:var(--muted);">
                  검색 결과가 없습니다.
                </td>
              </tr>
              <tr v-for="p in partnerList" :key="p.partnerId"
                  :style="(p.statusCode === 'SUSPENDED' || p.statusCode === 'BLOCKED') ? 'opacity:0.6;' : ''">
                <td class="col-check">
                  <input type="checkbox" :value="p.partnerId" v-model="selectedIds" @click.stop>
                </td>
                <td>
                  <strong>{{ p.partnerName }}</strong>
                </td>
                <td>
                  <span v-if="p.statusCode === 'ACTIVE'"      class="badge badge-active">활성</span>
                  <span v-else-if="p.statusCode === 'PENDING'"    class="badge badge-pending">승인 대기</span>
                  <span v-else-if="p.statusCode === 'REJECTED'"   class="badge badge-rejected">반려</span>
                  <span v-else-if="p.statusCode === 'SUSPENDED'"  class="badge badge-suspended">이용정지</span>
                  <span v-else-if="p.statusCode === 'BLOCKED'"    class="badge badge-suspended">영구차단</span>
                  <span v-else-if="p.statusCode"                  class="badge">{{ p.statusCode }}</span>
                  <span v-else-if="String(p.status) === '1'"  class="badge badge-active">활성</span>
                  <span v-else-if="String(p.status) === '0'"  class="badge badge-suspended">비활성</span>
                  <span v-else class="badge">-</span>
                </td>
                <td>
                  <div class="sales-bar-wrap">
                    <div class="sales-bar-bg">
                      <div class="sales-bar-fill" :style="{ width: (p.salesRatio || 0) + '%' }"></div>
                    </div>
                    <span class="sales-amount">{{ p.salesLabel || '-' }}</span>
                  </div>
                </td>
                <td>
                  <div class="star-wrap">
                    <span style="color:#F59E0B;">★</span>
                    <span class="star-score"
                          :class="{ 'risk-high': p.rating < 3, 'risk-mid': p.rating >= 3 && p.rating < 4 }">
                      {{ Number(p.rating ?? 0).toFixed(1) }}
                    </span>
                    <span class="star-count">({{ p.reviewCount || 0 }})</span>
                  </div>
                </td>
                <td class="num">{{ p.productCount || 0 }}</td>
                <td class="num">{{ Number(p.commissionRate ?? 0).toFixed(0) }}%</td>
                <td>
                  <span v-if="p.riskLevel === 'HIGH'" class="risk-high">🔴 고위험</span>
                  <span v-else-if="p.riskLevel === 'MID'" class="risk-mid">🟡 주의</span>
                  <span v-else class="risk-low">🟢 정상</span>
                </td>
                <td class="num date-cell">{{ p.createdAt ? String(p.createdAt).substring(0,10) : '-' }}</td>
                <td class="right" style="white-space:nowrap;">
                  <button class="btn btn-primary btn-sm"
                          style="margin-right:4px;"
                          @click="openDetailModal(p)">상세</button>
                  <button v-if="p.statusCode !== 'SUSPENDED' && p.statusCode !== 'BLOCKED'"
                          class="btn btn-sm"
                          style="background:#FEF2F2;color:#DC2626;border:1px solid #FECACA;"
                          @click="openDeactivateModal(p)">차단</button>
                  <button v-else
                          class="btn btn-outline btn-sm"
                          @click="openActivateModal(p)">활성화</button>
                </td>
              </tr>
            </tbody>
          </table>
        </div>

        <!-- 페이지네이션 -->
        <div class="pagination" v-if="totalCount > 0" style="margin-top:24px;">
          <template v-if="pagination">
            <button class="pg-btn pg-arrow" v-if="pagination.showPrev" @click="fetchList(pagination.firstPage)">≪</button>
            <button class="pg-btn pg-arrow" v-if="pagination.showPrev" @click="fetchList(pagination.prevBlockPage)">‹</button>
            <button class="pg-btn" v-for="pg in pagination.pages" :key="pg"
                    @click="fetchList(pg)" :class="{ active: pageNo === pg }">{{ pg }}</button>
            <button class="pg-btn pg-arrow" v-if="pagination.showNext" @click="fetchList(pagination.nextBlockPage)">›</button>
            <button class="pg-btn pg-arrow" v-if="pagination.showNext" @click="fetchList(pagination.lastPage)">≫</button>
          </template>
          <template v-else>
            <button class="pg-btn active">1</button>
          </template>
        </div>
      </div>

    </main>

    <!-- ══════════════ 파트너사 등록 모달 ══════════════ -->
    <div class="modal-overlay" :class="{ open: showRegisterModal }" @click.self="closeRegisterModal">
      <div class="modal-sheet" style="max-width:520px;">
        <div class="ms-head">
          <h3>파트너사 신규 등록</h3>
          <p>기본 정보를 입력하고 저장하면 승인 대기 상태로 등록됩니다.</p>
        </div>
        <div class="ms-body">
          <div class="fg">
            <label>파트너사명 <span style="color:var(--danger);">*</span></label>
            <input type="text" v-model="register.partnerName" placeholder="예) 제주 힐링 투어">
          </div>
          <div style="display:grid;grid-template-columns:1fr 1fr;gap:12px;">
            <div class="fg">
              <label>사업자번호 <span style="color:var(--danger);">*</span></label>
              <input type="text" v-model="register.businessNumber" placeholder="000-00-00000">
            </div>
            <div class="fg">
              <label>수수료율</label>
              <input type="number" v-model="register.commissionRate" placeholder="10">
            </div>
          </div>
          <div style="display:grid;grid-template-columns:1fr 1fr;gap:12px;">
            <div class="fg">
              <label>담당자명</label>
              <input type="text" v-model="register.contactName" placeholder="홍길동">
            </div>
            <div class="fg">
              <label>담당자 연락처</label>
              <input type="text" v-model="register.contactPhone" placeholder="010-0000-0000">
            </div>
          </div>
          <div class="fg">
            <label>담당자 이메일</label>
            <input type="email" v-model="register.managerEmail" placeholder="partner@example.com">
          </div>
          <div class="fg">
            <label>메모</label>
            <textarea v-model="register.memo" placeholder="계약 내용, 특이사항 등을 입력하세요."></textarea>
          </div>
        </div>
        <div class="ms-foot">
          <button class="btn-m btn-m-ghost"   @click="closeRegisterModal">취소</button>
          <button class="btn-m btn-m-primary" @click="submitRegister">등록</button>
        </div>
      </div>
    </div>

    <!-- ══════════════ 상태 일괄 변경 모달 ══════════════ -->
    <div class="modal-overlay" :class="{ open: showBulkStatusModal }" @click.self="closeBulkStatusModal">
      <div class="modal-sheet">
        <div class="ms-head">
          <h3>상태 일괄 변경</h3>
          <p>선택된 파트너사 <strong>{{ selectedIds.length }}개</strong>의 상태를 일괄 변경합니다.</p>
        </div>
        <div class="ms-body">
          <div class="fg">
            <label>변경할 상태</label>
            <select v-model="bulkStatus.status">
              <option value="ACTIVE">활성</option>
              <option value="PENDING">승인 대기</option>
              <option value="SUSPENDED">정지</option>
            </select>
          </div>
          <div class="fg">
            <label>처리 사유</label>
            <textarea v-model="bulkStatus.reason" placeholder="정지 처리 시 반드시 입력하세요."></textarea>
          </div>
        </div>
        <div class="ms-foot">
          <button class="btn-m btn-m-ghost"   @click="closeBulkStatusModal">취소</button>
          <button class="btn-m btn-m-primary" :disabled="bulkLoading" @click="submitBulkStatus">
            {{ bulkLoading ? '처리 중...' : '일괄 적용' }}
          </button>
        </div>
      </div>
    </div>

    <!-- ══════════════ 단건 차단 모달 ══════════════ -->
    <div class="modal-overlay" :class="{ open: showDeactivateModal }" @click.self="closeDeactivateModal">
      <div class="modal-sheet">
        <div class="ms-head">
          <h3>파트너사 즉시 차단</h3>
          <p>{{ deactivateTarget.partnerName }}</p>
        </div>
        <div class="ms-body">
          <div class="danger-banner">
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
              <path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"/>
              <line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/>
            </svg>
            차단 즉시 해당 파트너사의 모든 숙소/상품 노출이 중단됩니다.
          </div>
          <div class="fg">
            <label>차단 사유 <span style="color:var(--danger);">*</span></label>
            <select v-model="deactivate.reason">
              <option value="">사유를 선택하세요</option>
              <option value="CONTRACT_EXPIRE">계약 종료</option>
              <option value="POLICY_VIOLATION">규정 위반</option>
              <option value="FRAUD">사기/허위 정보</option>
              <option value="LOW_RATING">지속적 저평점</option>
              <option value="REQUEST">파트너 요청</option>
              <option value="ETC">기타</option>
            </select>
          </div>
          <div class="fg">
            <label>상세 내용 <span style="color:var(--danger);">*</span></label>
            <textarea v-model="deactivate.detail" placeholder="차단 처리 사유를 상세히 입력하세요."></textarea>
          </div>
        </div>
        <div class="ms-foot">
          <button class="btn-m btn-m-ghost"  @click="closeDeactivateModal">취소</button>
          <button class="btn-m btn-m-danger" @click="submitDeactivate">즉시 차단</button>
        </div>
      </div>
    </div>

    <!-- ══════════════ 단건 활성화 모달 ══════════════ -->
    <div class="modal-overlay" :class="{ open: showActivateModal }" @click.self="closeActivateModal">
      <div class="modal-sheet">
        <div class="ms-head">
          <h3>파트너사 활성화</h3>
          <p>{{ activateTarget.partnerName }}</p>
        </div>
        <div class="ms-body">
          <div class="fg">
            <label>활성화 사유</label>
            <textarea v-model="activate.reason" placeholder="활성화 처리 사유를 입력하세요. (선택)"></textarea>
          </div>
        </div>
        <div class="ms-foot">
          <button class="btn-m btn-m-ghost"   @click="closeActivateModal">취소</button>
          <button class="btn-m btn-m-success" @click="submitActivate">활성화 처리</button>
        </div>
      </div>
    </div>

    <!-- ══════════════ 일괄 차단 모달 ══════════════ -->
    <div class="modal-overlay" :class="{ open: showBulkDeactivateModal }" @click.self="closeBulkDeactivateModal">
      <div class="modal-sheet">
        <div class="ms-head">
          <h3>파트너사 일괄 차단</h3>
          <p>선택된 파트너사 <strong>{{ selectedIds.length }}개</strong>를 즉시 차단합니다.</p>
        </div>
        <div class="ms-body">
          <div class="danger-banner">
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
              <path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"/>
              <line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/>
            </svg>
            선택된 모든 파트너사의 상품 노출이 즉시 중단됩니다.
          </div>
          <div class="fg">
            <label>차단 사유 <span style="color:var(--danger);">*</span></label>
            <select v-model="bulkDeactivate.reason">
              <option value="">사유를 선택하세요</option>
              <option value="CONTRACT_EXPIRE">계약 종료</option>
              <option value="POLICY_VIOLATION">규정 위반</option>
              <option value="FRAUD">사기/허위 정보</option>
              <option value="ETC">기타</option>
            </select>
          </div>
          <div class="fg">
            <label>상세 내용</label>
            <textarea v-model="bulkDeactivate.detail" placeholder="일괄 차단 사유 (선택)"></textarea>
          </div>
        </div>
        <div class="ms-foot">
          <button class="btn-m btn-m-ghost"  @click="closeBulkDeactivateModal">취소</button>
          <button class="btn-m btn-m-danger" :disabled="bulkLoading" @click="submitBulkDeactivate">
            {{ bulkLoading ? '처리 중...' : '일괄 차단' }}
          </button>
        </div>
      </div>
    </div>

    </div><!-- /#app -->

  </div><!-- /main-wrapper -->
</div><!-- /admin-layout -->

<script>
  const contextPath = '${pageContext.request.contextPath}';
  const buildApiUrl = (path) => contextPath + path;
  const normalizePartnerId = (value) => {
    if (value === null || value === undefined) return null;
    const s = String(value).trim();
    return s ? s : null;
  };
</script>

<script src="https://unpkg.com/vue@3/dist/vue.global.prod.js"></script>
<script src="https://cdn.jsdelivr.net/npm/axios/dist/axios.min.js"></script>

<script>
  const { createApp, ref, reactive, computed, onMounted } = Vue;

  createApp({
    setup() {

      /* ── KPI ── */
      const kpi = reactive({
        total: 0, active: 0, suspended: 0, pending: 0,
        totalSalesLabel: '-', lowRatingCount: 0
      });

      /* ── 필터 ── */
      const filter = reactive({
        status: 'ALL', sort: 'SALES_DESC', keyword: ''
      });

      /* ── 목록 ── */
      const partnerList = ref([]);
      const totalCount  = ref(0);
      const pageNo      = ref(1);
      const pagination  = ref(null);
      const searched    = ref(false);
      const sortAsc     = ref(false);
      const selectedIds = ref([]);
      const bulkLoading = ref(false); // ✅ 일괄처리 로딩 상태

      const isAllChecked = computed(() =>
        partnerList.value.length > 0 &&
        selectedIds.value.length === partnerList.value.length
      );

      /* ── 모달 open 상태 ── */
      const showDetailModal         = ref(false);
      const showRegisterModal       = ref(false);
      const showBulkStatusModal     = ref(false);
      const showDeactivateModal     = ref(false);
      const showActivateModal       = ref(false);
      const showBulkDeactivateModal = ref(false);

      /* ── 상세 모달 데이터 ── */
      const detailData    = reactive({});
      const detailLoading = ref(false);

      /* ── 모달 데이터 ── */
      const register = reactive({
        partnerName:'', bizNo:'', commissionRate: 10,
        managerName:'', managerPhone:'', managerEmail:'', memo:''
      });
      const bulkStatus       = reactive({ status: 'ACTIVE', reason: '' });
      const deactivateTarget = reactive({ partnerId:'', partnerName:'' });
      const deactivate       = reactive({ reason:'', detail:'' });
      const activateTarget   = reactive({ partnerId:'', partnerName:'' });
      const activate         = reactive({ reason:'' });
      const bulkDeactivate   = reactive({ reason:'', detail:'' });

      /* ── KPI 조회 ── */
      const fetchKpi = async () => {
        try {
          const res = await axios.get(contextPath + '/api/admin/partner/kpi');
          Object.assign(kpi, res.data);
        } catch(e) { console.error('KPI 오류', e); }
      };

      /* ── 목록 조회 ── */
      const allPartners = ref([]);
      const PAGE_SIZE   = 10;

      const buildPagination = (total, page) => {
        const totalPages = Math.ceil(total / PAGE_SIZE);
        if (totalPages <= 1) return null;
        const blockSize    = 10;
        const blockStart   = Math.floor((page - 1) / blockSize) * blockSize + 1;
        const blockEnd     = Math.min(blockStart + blockSize - 1, totalPages);
        const pages = [];
        for (let i = blockStart; i <= blockEnd; i++) pages.push(i);
        return {
          pages,
          firstPage:     1,
          lastPage:      totalPages,
          prevBlockPage: Math.max(1, blockStart - 1),
          nextBlockPage: Math.min(totalPages, blockEnd + 1),
          showPrev:      blockStart > 1,
          showNext:      blockEnd < totalPages
        };
      };

      const applyFilter = (page = 1) => {
        pageNo.value = page;
        let list = [...allPartners.value];

        // 상태 필터 (statusCode 우선, 없으면 status 숫자 폴백)
        if (filter.status && filter.status !== 'ALL') {
          list = list.filter(p => {
            const sc = (p.statusCode || '').toUpperCase();
            const s  = sc || (p.status != null ? (String(p.status) === '1' ? 'ACTIVE' : 'SUSPENDED') : '');
            return s === filter.status.toUpperCase();
          });
        }

        // 키워드 필터
        if (filter.keyword.trim()) {
          const keywords = filter.keyword.split(',').map(k => k.trim()).filter(k => k);
          list = list.filter(p =>
            keywords.some(k => (p.partnerName || '').includes(k))
          );
        }

        // ✅ 등록일 정렬 (toggleSort 클릭 시 sortAsc 반영)
        list.sort((a, b) => {
          const dateA = new Date(a.createdAt || 0).getTime();
          const dateB = new Date(b.createdAt || 0).getTime();
          return sortAsc.value ? dateA - dateB : dateB - dateA;
        });

        totalCount.value = list.length;
        pagination.value = buildPagination(list.length, page);

        const start = (page - 1) * PAGE_SIZE;
        partnerList.value = list.slice(start, start + PAGE_SIZE);
        selectedIds.value = [];
      };

      const fetchList = async (page = 1) => {
        try {
          if (page === 1 || allPartners.value.length === 0) {
            const res = await axios.get(contextPath + '/api/admin/partner/list', {
              params: { page: 1, status: 'ALL', keyword: '' }
            });
            allPartners.value = res.data.list || [];
          }
          searched.value = true;
          applyFilter(page);
        } catch(e) {
          console.error('목록 오류', e);
          alert('목록을 불러오는 중 오류가 발생했습니다.');
        }
      };

      // ✅ 등록일 정렬 토글 - applyFilter에서 sortAsc 반영하므로 재조회 불필요
      const toggleSort = () => {
        sortAsc.value = !sortAsc.value;
        if (searched.value) applyFilter(pageNo.value);
      };

      const toggleCheckAll = (e) => {
        selectedIds.value = e.target.checked
          ? partnerList.value.map(p => p.partnerId) : [];
      };

      const copySelectedNames = () => {
        const names = allPartners.value
          .filter(p => selectedIds.value.includes(p.partnerId))
          .map(p => p.partnerName);
        if (names.length === 0) { alert('선택된 항목이 없습니다.'); return; }
        navigator.clipboard.writeText(names.join(', ')).then(() => {
          alert('✅ ' + names.length + '개 파트너사명이 복사됐습니다.\n검색창에 붙여넣기 하세요.');
        }).catch(() => { prompt('아래를 복사하세요:', names.join(', ')); });
      };

      const downloadExcel = () => {
        let rows = [];
        if (selectedIds.value.length > 0) {
          rows = allPartners.value.filter(p => selectedIds.value.includes(p.partnerId));
        } else {
          rows = allPartners.value.filter(p => {
            const statusOk = !filter.status || filter.status === 'ALL'
              || (p.statusCode || p.status || '').toUpperCase() === filter.status.toUpperCase();
            const kwOk = !filter.keyword.trim()
              || (p.partnerName || '').includes(filter.keyword.trim());
            return statusOk && kwOk;
          });
        }
        if (rows.length === 0) { alert('다운로드할 데이터가 없습니다.'); return; }

        // ✅ statusCode(문자열) + status(숫자) 둘 다 처리
        const statusLabel = s => {
          if (s == null) return '-';
          const code = String(s).toUpperCase();
          return {
            '1': '정상', '0': '비활성',
            'PENDING':   '승인대기',
            'ACTIVE':    '정상',
            'APPROVED':  '승인완료',
            'REJECTED':  '반려',
            'SUSPENDED': '이용정지',
            'BLOCKED':   '영구차단'
          }[code] || code || '-';
        };

        let csv = '\uFEFF' + '파트너ID,파트너사명,사업자번호,담당자명,담당자연락처,수수료율,상태,이번달매출,평점,등록일\n';
        rows.forEach(p => {
          const cols = [
            p.partnerId      ?? '-',
            p.partnerName    ?? '-',
            p.businessNumber ?? '-',
            p.contactName    ?? '-',
            p.contactPhone   ?? '-',
            p.commissionRate != null ? Number(p.commissionRate).toFixed(1) + '%' : '-',
            statusLabel(p.statusCode || p.status),  // ✅ statusCode 우선
            p.salesLabel     ?? '-',                 // ✅ 매출 레이블 추가
            p.rating != null ? Number(p.rating).toFixed(1) : '-', // ✅ 평점 추가
            p.createdAt ? String(p.createdAt).substring(0,10) : '-'
          ];
          csv += cols.map(v => '"' + String(v).replace(/"/g, '""') + '"').join(',') + '\n';
        });

        const blob = new Blob([csv], { type: 'text/csv;charset=utf-8;' });
        const link = document.createElement('a');
        link.href = URL.createObjectURL(blob);
        link.download = '파트너사목록_' + new Date().toISOString().slice(0,10) + '.csv';
        document.body.appendChild(link); link.click(); document.body.removeChild(link);
      };

      /* ── 상세 페이지 이동 ── */
      const openDetailModal = (p) => {
        const partnerId = normalizePartnerId(p?.partnerId);
        if (!partnerId) { alert('partnerId가 없습니다.'); return; }
        location.href = contextPath + '/admin/partner/detail?partnerId=' + partnerId;
      };
      const closeDetailModal = () => {};

      /* ── 등록 모달 ── */
      const openRegisterModal  = () => { showRegisterModal.value = true; };
      const closeRegisterModal = () => {
        showRegisterModal.value = false;
        Object.assign(register, { partnerName:'', businessNumber:'', commissionRate:10, contactName:'', contactPhone:'', managerEmail:'', memo:'' });
      };
      const submitRegister = async () => {
        if (!register.partnerName.trim() || !register.businessNumber.trim()) {
          alert('파트너사명, 사업자번호는 필수입니다.');
          return;
        }
        try {
          await axios.post(contextPath + '/api/admin/partner/register', register);
          alert('파트너사가 등록되었습니다. (승인 대기 상태)');
          closeRegisterModal();
          fetchList(1);
          fetchKpi();
        } catch(e) { console.error('등록 오류', e); alert('등록 중 오류가 발생했습니다.'); }
      };

      /* ── 상태 일괄 변경 모달 ── */
      const openBulkStatusModal  = () => { showBulkStatusModal.value = true; };
      const closeBulkStatusModal = () => { showBulkStatusModal.value = false; bulkStatus.reason = ''; };
      const submitBulkStatus = async () => {
        if (selectedIds.value.length === 0) { alert('선택된 파트너사가 없습니다.'); return; }
        bulkLoading.value = true; // ✅ 로딩 시작
        try {
          if (bulkStatus.status === 'ACTIVE') {
            await Promise.all(selectedIds.value.map(id =>
              axios.post(buildApiUrl('/api/admin/partner/activate'), {
                partnerId: id,
                reason: bulkStatus.reason
              })
            ));
          } else {
            await Promise.all(selectedIds.value.map(id =>
              axios.post(contextPath + '/api/admin/partner/suspend/' + id)
            ));
          }
          alert('상태가 일괄 변경되었습니다.');
          closeBulkStatusModal();
          fetchList(pageNo.value);
          fetchKpi();
        } catch(e) {
          console.error('일괄 변경 오류', e);
          alert('처리 중 오류가 발생했습니다.');
        } finally {
          bulkLoading.value = false; // ✅ 로딩 종료
        }
      };

      /* ── 단건 차단 모달 ── */
      const openDeactivateModal  = (p) => {
        console.log('partnerId:', p.partnerId, '/ 전체키:', Object.keys(p));
        Object.assign(deactivateTarget, p);
        Object.assign(deactivate, { reason:'', detail:'' });
        showDeactivateModal.value = true;
      };
      const closeDeactivateModal = () => { showDeactivateModal.value = false; };
      const submitDeactivate = async () => {
        if (!deactivate.reason)        { alert('차단 사유를 선택해주세요.'); return; }
        if (!deactivate.detail.trim()) { alert('상세 내용을 입력해주세요.'); return; }
        const partnerId = normalizePartnerId(deactivateTarget.partnerId);
        if (!partnerId) { alert('partnerId가 없습니다.'); return; }
        try {
          await axios.post(contextPath + '/api/admin/partner/suspend/' + partnerId);
          alert(deactivateTarget.partnerName + ' 파트너사가 차단되었습니다.');
          closeDeactivateModal();
          fetchList(pageNo.value);
          fetchKpi();
        } catch(e) {
          console.error('차단 오류', e?.response || e);
          alert(e?.response?.data || '처리 중 오류가 발생했습니다.');
        }
      };

      /* ── 단건 활성화 모달 ── */
      const openActivateModal  = (p) => {
        Object.assign(activateTarget, p);
        activate.reason = '';
        showActivateModal.value = true;
      };
      const closeActivateModal = () => { showActivateModal.value = false; };
      const submitActivate = async () => {
        try {
          await axios.post(contextPath + '/api/admin/partner/activate', {
            partnerId: activateTarget.partnerId,
            reason:    activate.reason
          });
          alert(activateTarget.partnerName + ' 파트너사가 활성화되었습니다.');
          closeActivateModal();
          fetchList(pageNo.value);
          fetchKpi();
        } catch(e) { console.error('활성화 오류', e); alert('처리 중 오류가 발생했습니다.'); }
      };

      /* ── 일괄 차단 모달 ── */
      const openBulkDeactivateModal  = () => {
        Object.assign(bulkDeactivate, { reason:'', detail:'' });
        showBulkDeactivateModal.value = true;
      };
      const closeBulkDeactivateModal = () => { showBulkDeactivateModal.value = false; };
      const submitBulkDeactivate = async () => {
        if (!bulkDeactivate.reason)        { alert('차단 사유를 선택해주세요.'); return; }
        if (selectedIds.value.length === 0) { alert('선택된 파트너사가 없습니다.'); return; }
        bulkLoading.value = true; // ✅ 로딩 시작
        try {
          await Promise.all(selectedIds.value.map(id =>
            axios.post(contextPath + '/api/admin/partner/suspend/' + id)
          ));
          alert(selectedIds.value.length + '개 파트너사가 일괄 차단되었습니다.');
          closeBulkDeactivateModal();
          fetchList(pageNo.value);
          fetchKpi();
        } catch(e) {
          console.error('일괄 차단 오류', e?.response || e);
          alert(e?.response?.data || '처리 중 오류가 발생했습니다.');
        } finally {
          bulkLoading.value = false; // ✅ 로딩 종료
        }
      };

      /* ── 최초 1회 호출 ── */
      onMounted(() => {
        fetchKpi();
      });

      return {
        kpi, filter, partnerList, allPartners, totalCount, pageNo, pagination, searched, sortAsc,
        selectedIds, isAllChecked, bulkLoading,
        showDetailModal, detailData, detailLoading,
        showRegisterModal, register,
        showBulkStatusModal, bulkStatus,
        showDeactivateModal, deactivateTarget, deactivate,
        showActivateModal, activateTarget, activate,
        showBulkDeactivateModal, bulkDeactivate,
        fetchList, toggleSort, toggleCheckAll, downloadExcel, copySelectedNames,
        openDetailModal,         closeDetailModal,
        openRegisterModal,       closeRegisterModal,       submitRegister,
        openBulkStatusModal,     closeBulkStatusModal,     submitBulkStatus,
        openDeactivateModal,     closeDeactivateModal,     submitDeactivate,
        openActivateModal,       closeActivateModal,       submitActivate,
        openBulkDeactivateModal, closeBulkDeactivateModal, submitBulkDeactivate,
        resetFilter: () => {
          filter.status = 'ALL'; filter.sort = 'SALES_DESC'; filter.keyword = '';
          allPartners.value = [];
          fetchList(1);
          fetchKpi();
        }
      };
    }
  }).mount('#app');
</script>

</body>
</html>
