<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <title>TripanSuper — 입점 심사 및 승인 처리</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/dist/css/admin.css">
  <style>
    /* ── 공통 재사용 ── */
    .col-check { width: 44px; text-align: center; }
    input[type="checkbox"] { width: 16px; height: 16px; cursor: pointer; accent-color: var(--primary); }

    .modal-overlay {
      position: fixed; inset: 0; background: rgba(15,23,42,0.5);
      backdrop-filter: blur(6px); display: none;
      justify-content: center; align-items: center;
      z-index: 3000; padding: 24px;
    }
    .modal-overlay.open { display: flex; }
    .modal-sheet {
      background: #fff; width: 100%; max-width: 560px;
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
    .fg textarea { resize:vertical; min-height:80px; line-height:1.5; }
    .btn-m        { flex:1; height:46px; border-radius:11px; font-weight:800; font-size:14px; border:none; cursor:pointer; transition:opacity 0.15s; }
    .btn-m-ghost  { background:var(--bg); color:var(--text); }
    .btn-m-primary{ background:#111; color:#fff; }
    .btn-m-success{ background:#F0FDF4; color:#15803D; }
    .btn-m-danger { background:#FEF2F2; color:#DC2626; }
    .btn-m-warn   { background:#FFFBEB; color:#B45309; }
    .btn-m:hover  { opacity:0.84; }
    .filter-row .btn { display:inline-flex; align-items:center; gap:6px; }
    .btn-reset { background: var(--bg); color: var(--muted); border: 1.5px solid var(--border); border-radius: 10px; height: 38px; padding: 0 14px; font-size: 13px; font-weight: 700; cursor: pointer; display: inline-flex; align-items: center; gap: 5px; transition: all 0.15s; }
    .btn-reset:hover { background: #F1F5F9; color: var(--text); border-color: #94A3B8; }
    .btn-reset svg { transition: transform 0.35s cubic-bezier(0.34,1.56,0.64,1); }
    .btn-reset:hover svg { transform: rotate(-180deg); }

    /* ── 입점 심사 전용 ── */
    .apply-status-tabs {
      display: flex; gap: 8px; margin-bottom: 4px;
    }
    .status-tab {
      padding: 8px 20px; border-radius: 10px; font-size: 13px; font-weight: 800;
      border: 1.5px solid var(--border); background: var(--bg); color: var(--muted);
      cursor: pointer; transition: all 0.15s;
    }
    .status-tab.active         { border-color:#111; background:#111; color:#fff; }
    .status-tab.tab-pending    { border-color:#FED7AA; background:#FFF7ED; color:#C2410C; }
    .status-tab.tab-pending.active { background:#C2410C; border-color:#C2410C; color:#fff; }
    .status-tab.tab-approved   { border-color:#BBF7D0; background:#F0FDF4; color:#15803D; }
    .status-tab.tab-approved.active { background:#15803D; border-color:#15803D; color:#fff; }
    .status-tab.tab-rejected   { border-color:#FECACA; background:#FEF2F2; color:#DC2626; }
    .status-tab.tab-rejected.active { background:#DC2626; border-color:#DC2626; color:#fff; }
    .status-tab.tab-supplement { border-color:#BFDBFE; background:#EFF6FF; color:#1D4ED8; }
    .status-tab.tab-supplement.active { background:#1D4ED8; border-color:#1D4ED8; color:#fff; }

    .doc-list { display:flex; flex-direction:column; gap:8px; }
    .doc-item {
      display:flex; align-items:center; gap:10px;
      padding:10px 14px; border:1.5px solid var(--border);
      border-radius:10px; background:var(--bg);
      font-size:13px; font-weight:600; cursor:pointer;
      transition: border-color 0.15s;
    }
    .doc-item:hover { border-color:var(--primary); }
    .doc-icon { font-size:18px; }
    .doc-name { flex:1; }
    .doc-link { font-size:12px; color:var(--primary); font-weight:700; text-decoration:none; }

    /* 상세 info grid */
    .info-grid {
      display:grid; grid-template-columns:1fr 1fr; gap:12px;
    }
    .info-item { display:flex; flex-direction:column; gap:4px; }
    .info-item .i-label { font-size:11px; font-weight:800; color:var(--muted); text-transform:uppercase; letter-spacing:0.5px; }
    .info-item .i-value { font-size:14px; font-weight:700; color:var(--text); }

    /* 수수료 input */
    .rate-input-wrap { position:relative; }
    .rate-input-wrap input { padding-right:36px; }
    .rate-unit { position:absolute; right:14px; top:50%; transform:translateY(-50%); font-size:14px; font-weight:800; color:var(--muted); }

    /* 뱃지 보조 */
    .badge-pending    { background:#FFF7ED; color:#C2410C; }
    .badge-approved   { background:#F0FDF4; color:#15803D; }
    .badge-rejected   { background:#FEF2F2; color:#DC2626; }
    .badge-supplement { background:#EFF6FF; color:#1D4ED8; }

    /* ── 일괄처리 바 ── */
    .bulk-bar {
      display: none; align-items: center; gap: 12px;
      padding: 12px 20px; background: #F0FDF4;
      border: 1.5px solid #BBF7D0; border-radius: 14px;
      margin-bottom: 16px; animation: slideDown 0.2s ease;
    }
    .bulk-bar.visible { display: flex; }
    @keyframes slideDown { from{opacity:0;transform:translateY(-6px);} to{opacity:1;transform:translateY(0);} }
    .bulk-count     { font-size:13px; font-weight:800; color:#15803D; background:#DCFCE7; padding:4px 12px; border-radius:20px; }
    .bulk-bar-label { font-size:13px; font-weight:700; color:var(--text); }
    .bulk-bar-actions { display:flex; gap:8px; margin-left:auto; }
    .btn-bulk         { height:36px; padding:0 16px; border-radius:9px; font-size:13px; font-weight:800; border:none; cursor:pointer; transition:opacity 0.15s; }
    .btn-bulk-success { background:#15803D; color:#fff; }
    .btn-bulk-danger  { background:#DC2626; color:#fff; }
    .btn-bulk-copy    { background:var(--bg); color:var(--text); border:1px solid var(--border); }
    .btn-bulk:hover   { opacity:0.8; }
  </style>
</head>
<body>

<div class="admin-layout">
  <jsp:include page="../layout/sidebar.jsp"><jsp:param name="activePage" value="partner-apply"/></jsp:include>
  <div class="main-wrapper">
    <jsp:include page="../layout/header.jsp" />

    <div id="app" style="flex:1;display:flex;flex-direction:column;min-height:0;overflow:hidden;">
    <main class="main-content" style="flex:1;overflow-y:auto;">

      <!-- 페이지 헤더 -->
      <div class="page-header fade-up">
        <div>
          <h1>입점 심사 및 승인 처리</h1>
          <p>파트너사가 제출한 신청서와 증빙 서류를 검토하고 승인 여부를 결정합니다.</p>
        </div>
      </div>

      <!-- KPI 카드 -->
      <div class="kpi-grid">
        <div class="card kpi-card fade-up fade-up-1">
          <div class="kpi-label">전체 신청</div>
          <div class="kpi-value">{{ allApplies.length || kpi.total }}</div>
          <div class="kpi-sub">누적 입점 신청 수</div>
        </div>
        <div class="card kpi-card fade-up fade-up-2">
          <div class="kpi-label">심사 대기</div>
          <div class="kpi-value" style="color:#C2410C;">{{ kpi.pending }}</div>
          <div class="kpi-sub">즉시 처리 필요</div>
        </div>
        <div class="card kpi-card fade-up fade-up-3">
          <div class="kpi-label">서류 보완 요청</div>
          <div class="kpi-value" style="color:#1D4ED8;">{{ kpi.supplement }}</div>
          <div class="kpi-sub">재제출 대기 중</div>
        </div>
        <div class="card kpi-card fade-up fade-up-4">
          <div class="kpi-label">이번 달 승인</div>
          <div class="kpi-value" style="color:var(--success)">{{ kpi.approvedThisMonth }}</div>
          <div class="kpi-sub">신규 입점 확정</div>
        </div>
      </div>

      <!-- 상태 탭 + 필터 -->
      <div class="card filter-card fade-up">
        <!-- 상태 탭 -->
        <div class="apply-status-tabs" style="margin-bottom:16px;">
          <button class="status-tab"
                  :class="{ active: filter.status === 'ALL' }"
                  @click="setTab('ALL')">전체 ({{ kpi.total }})</button>
          <button class="status-tab tab-pending"
                  :class="{ active: filter.status === 'PENDING' }"
                  @click="setTab('PENDING')">심사 대기 ({{ kpi.pending }})</button>

          <button class="status-tab tab-approved"
                  :class="{ active: filter.status === 'APPROVED' }"
                  @click="setTab('APPROVED')">승인 ({{ kpi.active }})</button>
          <button class="status-tab tab-rejected"
                  :class="{ active: filter.status === 'REJECTED' }"
                  @click="setTab('REJECTED')">반려 ({{ kpi.rejected }})</button>
        </div>
        <!-- 검색 필터 -->
        <div class="filter-row">
          <div class="filter-label">신청사 검색</div>
          <select class="filter-select" v-model="filter.category" style="width:130px;">
            <option value="ALL">전체 카테고리</option>
            <option value="HOTEL">호텔/숙박</option>
            <option value="TOUR">투어/체험</option>
            <option value="FLIGHT">항공</option>
            <option value="RENT">렌터카</option>
            <option value="ETC">기타</option>
          </select>
          <input type="text" class="keyword-input" v-model="filter.keyword"
                 placeholder="파트너사명 또는 사업자번호 검색"
                 @keyup.enter="fetchList(1)"
                 style="flex:1;">
          <button class="btn-reset" @click="resetFilter()" title="검색 초기화">
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><polyline points="1 4 1 10 7 10"/><path d="M3.51 15a9 9 0 1 0 .49-3.51"/></svg>
            초기화
          </button>
          <button class="btn btn-primary" @click="fetchList(1)">
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
            검색
          </button>
        </div>
      </div>

      <!-- 테이블 카드 -->
      <div class="card table-card fade-up">
        <!-- 일괄처리 바 -->
        <div class="bulk-bar" :class="{ visible: selectedIds.length > 0 }">
          <span class="bulk-count">{{ selectedIds.length }}개 선택</span>
          <span class="bulk-bar-label">선택된 파트너사에 일괄 작업을 수행합니다.</span>
          <div class="bulk-bar-actions">
            <button class="btn-bulk btn-bulk-copy"    @click="copySelectedNames">파트너사명 복사</button>
            <button class="btn-bulk btn-bulk-success" @click="openBulkReviewModal('APPROVED')">일괄 승인</button>
            <button class="btn-bulk btn-bulk-danger"  @click="openBulkReviewModal('REJECTED')">일괄 반려</button>
          </div>
        </div>

        <div class="w-header" style="display:flex; justify-content:space-between; align-items:center; margin-bottom:16px;">
          <h2 style="display:inline-flex; align-items:center; gap:8px;">
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/>
              <polyline points="14 2 14 8 20 8"/>
            </svg>
            입점 신청 목록
          </h2>
          <span style="font-size:13px; color:var(--muted);">총 {{ totalCount }}건</span>
        </div>

        <div class="table-responsive">
          <table>
            <thead>
              <tr>
                <th class="col-check">
                  <input type="checkbox" @change="toggleCheckAll" :checked="isAllChecked">
                </th>
                <th>신청 번호</th>
                <th>파트너사명</th>
                <th>카테고리</th>
                <th>사업자번호</th>
                <th>담당자</th>
                <th>심사 상태</th>
                <th>서류</th>
                <th>신청일</th>
                <th class="right">처리</th>
              </tr>
            </thead>
            <tbody>
              <tr v-if="!searched">
                <td colspan="10" style="text-align:center; padding:50px 0; color:var(--muted);">
                  상단의 탭이나 검색 조건을 선택하면 목록이 표시됩니다.
                </td>
              </tr>
              <tr v-else-if="applyList.length === 0">
                <td colspan="10" style="text-align:center; padding:50px 0; color:var(--muted);">
                  해당 조건의 신청 내역이 없습니다.
                </td>
              </tr>
              <tr v-for="item in applyList" :key="item.partnerId" class="apply-row">
                <td class="col-check">
                  <input type="checkbox" :value="item.partnerId" v-model="selectedIds" @click.stop>
                </td>
                <td class="num" style="color:var(--muted); font-size:12px;">{{ item.partnerId }}</td>
                <td><strong>{{ item.partnerName }}</strong></td>
                <td><span class="category-chip" style="display:inline-block;padding:2px 10px;border-radius:20px;font-size:12px;font-weight:700;background:#EFF6FF;color:#1D4ED8;">{{ item.categoryLabel || '-' }}</span></td>
                <td>{{ item.businessNumber }}</td>
                <td>{{ item.contactName }}</td>
                <td>
                  <span v-if="item.status === 'PENDING'"    class="badge badge-pending">심사 대기</span>
                  <span v-else-if="item.status === 'APPROVED'"  class="badge badge-approved">승인</span>
                  <span v-else-if="item.status === 'REJECTED'"  class="badge badge-rejected">반려</span>
                  <span v-else-if="item.status === 'ACTIVE'"    class="badge badge-approved">승인</span>
                </td>
                <td>
                  <button class="btn btn-outline btn-sm"
                          style="display:inline-flex;align-items:center;gap:4px;"
                          @click="openDocModal(item)">
                    <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
                      <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/>
                      <polyline points="14 2 14 8 20 8"/>
                    </svg>
                    서류 ({{ item.docCount }})
                  </button>
                </td>
                <td class="num date-cell">{{ item.createdAt ? String(item.createdAt).substring(0,10) : '-' }}</td>
                <td class="right">
                  <button class="btn btn-primary btn-sm" @click="openReviewModal(item)">심사 처리</button>
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
            <button class="pg-btn" v-for="p in pagination.pages" :key="p"
                    @click="fetchList(p)" :class="{ active: pageNo === p }">{{ p }}</button>
            <button class="pg-btn pg-arrow" v-if="pagination.showNext" @click="fetchList(pagination.nextBlockPage)">›</button>
            <button class="pg-btn pg-arrow" v-if="pagination.showNext" @click="fetchList(pagination.lastPage)">≫</button>
          </template>
          <template v-else>
            <button class="pg-btn active">1</button>
          </template>
        </div>
      </div>

    </main>

    <!-- ══════════════════════════════════════
         심사 처리 모달
    ════════════════════════════════════════ -->
    <div class="modal-overlay" :class="{ open: showReviewModal }" @click.self="closeReviewModal">
      <div class="modal-sheet" style="max-width:580px;">
        <div class="ms-head">
          <h3>입점 심사 처리</h3>
          <p>{{ reviewTarget.partnerName }} — 파트너 ID {{ reviewTarget.partnerId }}</p>
        </div>
        <div class="ms-body">

          <!-- 기본 정보 -->
          <div class="info-grid">
            <div class="info-item">
              <span class="i-label">파트너사명</span>
              <span class="i-value">{{ reviewTarget.partnerName }}</span>
            </div>
            <div class="info-item">
              <span class="i-label">카테고리</span>
              <span class="i-value">{{ '-' }}</span>
            </div>
            <div class="info-item">
              <span class="i-label">사업자번호</span>
              <span class="i-value">{{ reviewTarget.businessNumber }}</span>
            </div>
            <div class="info-item">
              <span class="i-label">담당자</span>
              <span class="i-value">{{ reviewTarget.contactName }}</span>
            </div>
            <div class="info-item">
              <span class="i-label">담당자 연락처</span>
              <span class="i-value">{{ reviewTarget.contactPhone }}</span>
            </div>
            <div class="info-item">
              <span class="i-label">신청일</span>
              <span class="i-value">{{ reviewTarget.createdAt ? String(reviewTarget.createdAt).substring(0,10) : '-' }}</span>
            </div>
          </div>

          <hr style="border:none; border-top:1px solid var(--border);">

          <!-- 처리 결과 선택 -->
          <div class="fg">
            <label>심사 결과 <span style="color:var(--danger);">*</span></label>
            <select v-model="review.result">
              <option value="">결과를 선택하세요</option>
              <option value="APPROVED">✅ 승인</option>
              <option value="REJECTED">❌ 반려</option>
            </select>
          </div>

          <!-- 중개 수수료율 (승인 시만 표시) -->
          <div class="fg" v-if="review.result === 'APPROVED'">
            <label>중개 수수료율 <span style="color:var(--danger);">*</span></label>
            <div class="rate-input-wrap">
              <input type="number" v-model="review.commissionRate"
                     placeholder="예) 5.0" min="0" max="50" step="0.1">
              <span class="rate-unit">%</span>
            </div>
            <span style="font-size:12px; color:var(--muted); margin-top:-2px;">
              이 파트너에게 적용될 중개 수수료율입니다. (0 ~ 50%)
            </span>
          </div>

          <!-- 사유/메시지 -->
          <div class="fg">
            <label>
              <span v-if="review.result === 'APPROVED'">승인 메시지 (선택)</span>
              <span v-else-if="review.result === 'REJECTED'">반려 사유 <span style="color:var(--danger);">*</span></span>
              <span v-else>처리 메시지</span>
            </label>
            <textarea v-model="review.message"
                      :placeholder="review.result === 'APPROVED' ? '승인 축하 메시지 (생략 가능)'
                                  : review.result === 'REJECTED' ? '반려 사유를 구체적으로 입력하세요.'
                                  : '처리 메시지를 입력하세요.'">
            </textarea>
          </div>

          <!-- 알림 발송 옵션 -->
          <div style="display:flex; align-items:center; gap:8px; font-size:13px; font-weight:700;">
            <input type="checkbox" v-model="review.sendNotify" id="chk-notify"
                   style="width:16px;height:16px;accent-color:var(--primary);">
            <label for="chk-notify" style="cursor:pointer;">
              심사 결과를 파트너사 담당자에게 알림톡/이메일로 자동 발송
            </label>
          </div>
        </div>
        <div class="ms-foot">
          <button class="btn-m btn-m-ghost"    @click="closeReviewModal">취소</button>
          <button class="btn-m btn-m-success"  v-if="review.result === 'APPROVED'"   @click="submitReview">승인 처리</button>
          <button class="btn-m btn-m-danger"   v-else-if="review.result === 'REJECTED'"   @click="submitReview">반려 처리</button>
          <button class="btn-m btn-m-primary"  v-else disabled style="opacity:0.4;">결과 선택 후 처리</button>
        </div>
      </div>
    </div>

    <!-- ══════════════════════════════════════
         서류 확인 모달
    ════════════════════════════════════════ -->
    <div class="modal-overlay" :class="{ open: showDocModal }" @click.self="closeDocModal">
      <div class="modal-sheet" style="max-width:480px;">
        <div class="ms-head">
          <h3>제출 서류 확인</h3>
          <p>{{ docTarget.partnerName }}이(가) 제출한 서류 목록입니다.</p>
        </div>
        <div class="ms-body">
          <div class="doc-list">
            <div v-for="doc in docTarget.docs" :key="doc.docId" class="doc-item"
                 @click="openDoc(doc.url)">
              <span class="doc-icon">📄</span>
              <span class="doc-name">{{ doc.docName }}</span>
              <span style="font-size:12px; color:var(--muted);">{{ doc.uploadDate }}</span>
              <a class="doc-link" @click.stop="openDoc(doc.url)">열기 →</a>
            </div>
            <div v-if="!docTarget.docs || docTarget.docs.length === 0"
                 style="text-align:center; padding:30px 0; color:var(--muted); font-size:14px;">
              제출된 서류가 없습니다.
            </div>
          </div>
        </div>
        <div class="ms-foot">
          <button class="btn-m btn-m-ghost" @click="closeDocModal">닫기</button>
          <button class="btn-m btn-m-primary" @click="() => { closeDocModal(); openReviewModal(docTarget); }">
            심사 처리로 이동
          </button>
        </div>
      </div>
    </div>


    <!-- ══════════════════════════════════════
         일괄 심사 처리 모달
    ════════════════════════════════════════ -->
    <div class="modal-overlay" :class="{ open: showBulkReviewModal }" @click.self="closeBulkReviewModal">
      <div class="modal-sheet" style="max-width:480px;">
        <div class="ms-head">
          <h3 v-if="bulkReview.result === 'APPROVED'">일괄 승인 처리</h3>
          <h3 v-else>일괄 반려 처리</h3>
          <p>선택된 파트너사 <strong>{{ selectedIds.length }}개</strong>를 일괄 처리합니다.</p>
        </div>
        <div class="ms-body">
          <div class="fg" v-if="bulkReview.result === 'APPROVED'">
            <label>중개 수수료율 <span style="color:var(--danger);">*</span></label>
            <div class="rate-input-wrap">
              <input type="number" v-model="bulkReview.commissionRate"
                     placeholder="예) 5.0" min="0" max="50" step="0.1">
              <span class="rate-unit">%</span>
            </div>
          </div>
          <div class="fg">
            <label v-if="bulkReview.result === 'REJECTED'">반려 사유 <span style="color:var(--danger);">*</span></label>
            <label v-else>승인 메시지 (선택)</label>
            <textarea v-model="bulkReview.message"
                      :placeholder="bulkReview.result === 'REJECTED' ? '반려 사유를 입력하세요.' : '승인 메시지 (생략 가능)'">
            </textarea>
          </div>
        </div>
        <div class="ms-foot">
          <button class="btn-m btn-m-ghost"    @click="closeBulkReviewModal">취소</button>
          <button class="btn-m btn-m-success"  v-if="bulkReview.result === 'APPROVED'" @click="submitBulkReview">일괄 승인</button>
          <button class="btn-m btn-m-danger"   v-else @click="submitBulkReview">일괄 반려</button>
        </div>
      </div>
    </div>
    </div><!-- /#app -->

  </div><!-- /main-wrapper -->
</div><!-- /admin-layout -->

<script>
  const contextPath = '${pageContext.request.contextPath}';
</script>

<jsp:include page="/WEB-INF/views/layout/vue_cdn.jsp" />

<script type="module">
  import { createApp, ref, reactive, computed, onMounted } from 'vue';
  import axios from 'axios';

  createApp({
    setup() {

      /* ── 상태 ── */
      const kpi = reactive({
        total: 0, pending: 0, supplement: 0,
        approved: 0, rejected: 0, approvedThisMonth: 0
      });

      const filter = reactive({ status: 'ALL', category: 'ALL', keyword: '' });

      const selectedIds = ref([]);
      const isAllChecked = computed(() =>
        applyList.value.length > 0 && selectedIds.value.length === applyList.value.length
      );
      const toggleCheckAll = (e) => {
        selectedIds.value = e.target.checked ? applyList.value.map(p => p.partnerId) : [];
      };

      const applyList  = ref([]);
      const totalCount = ref(0);
      const pageNo     = ref(1);
      const pagination = ref(null);
      const searched   = ref(true);

      /* 심사 처리 모달 */
      const showReviewModal = ref(false);
      const reviewTarget = reactive({
        partnerId: '', partnerName: '', businessNumber: '',
        contactName: '', contactPhone: ''
      });
      const review = reactive({
        result: '', commissionRate: '', message: '', sendNotify: true
      });

      /* 일괄 심사 모달 */
      const showBulkReviewModal = ref(false);
      const bulkReview = reactive({ result: '', commissionRate: '', message: '' });

      /* 서류 확인 모달 */
      const showDocModal = ref(false);
      const docTarget = reactive({ partnerName: '', docs: [] });

      /* ── KPI ── */
      const fetchKpi = async () => {
        try {
          const res = await axios.get(`${contextPath}/admin/partner/kpi`);
          Object.assign(kpi, res.data);
        } catch(e) { console.error('KPI 오류', e); }
      };

      /* ── 전체 목록 캐시 (프론트 페이징용) ── */
      const allApplies = ref([]);
      const PAGE_SIZE  = 10;

      const buildPagination = (total, page) => {
        const totalPages = Math.ceil(total / PAGE_SIZE);
        if (totalPages <= 1) return null;
        const blockSize  = 10;
        const blockStart = Math.floor((page - 1) / blockSize) * blockSize + 1;
        const blockEnd   = Math.min(blockStart + blockSize - 1, totalPages);
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
        let list = [...allApplies.value];

        // 상태 필터 (APPROVED 탭은 ACTIVE도 포함 — 승인 후 ACTIVE로 저장되므로)
        if (filter.status && filter.status !== 'ALL') {
          list = list.filter(p => {
            const s = (p.status || '').toUpperCase();
            if (filter.status === 'APPROVED') return s === 'APPROVED' || s === 'ACTIVE';
            return s === filter.status.toUpperCase();
          });
        }
        // 키워드 필터
        if (filter.keyword.trim()) {
          const keywords = filter.keyword.split(',').map(k => k.trim()).filter(k => k);
          list = list.filter(p =>
            keywords.some(k =>
              (p.partnerName || '').includes(k) || (p.businessNumber || '').includes(k)
            )
          );
        }

        totalCount.value = list.length;
        pagination.value = buildPagination(list.length, page);
        const start = (page - 1) * PAGE_SIZE;
        applyList.value  = list.slice(start, start + PAGE_SIZE);
        searched.value   = true;
      };

      /* ── 탭 클릭 ── */
      const setTab = (status) => {
        filter.status = status;
        applyFilter(1);
      };

      /* ── 목록 조회 (전체 1회 로드 후 캐시) ── */
      const fetchList = async (page = 1) => {
        try {
          if (page === 1 || allApplies.value.length === 0) {
            const res = await axios.get(`${contextPath}/admin/partner/list`, {
              params: { page: 1, status: 'ALL', keyword: '' }
            });
            allApplies.value = res.data.list || [];
          }
          applyFilter(page);
          selectedIds.value = [];
        } catch(e) {
          console.error('목록 오류', e);
          alert('목록을 불러오는 중 오류가 발생했습니다.');
        }
      };

      /* ── 파트너사명 복사 ── */
      const copySelectedNames = () => {
        const names = allApplies.value
          .filter(p => selectedIds.value.includes(p.partnerId))
          .map(p => p.partnerName);
        if (names.length === 0) { alert('선택된 항목이 없습니다.'); return; }
        navigator.clipboard.writeText(names.join(', ')).then(() => {
          alert('✅ ' + names.length + '개 파트너사명이 복사됐습니다.\n검색창에 붙여넣기 하세요.');
        }).catch(() => { prompt('아래를 복사하세요:', names.join(', ')); });
      };

      /* ── 심사 처리 모달 ── */
      const openReviewModal = (item) => {
        Object.assign(reviewTarget, item);
        Object.assign(review, { result: '', commissionRate: '', message: '', sendNotify: true });
        showReviewModal.value = true;
      };
      const closeReviewModal = () => { showReviewModal.value = false; };

      /* ── 일괄 심사 처리 ── */
      const openBulkReviewModal = (result) => {
        if (selectedIds.value.length === 0) { alert('처리할 파트너사를 선택해주세요.'); return; }
        Object.assign(bulkReview, { result, commissionRate: '', message: '' });
        showBulkReviewModal.value = true;
      };
      const closeBulkReviewModal = () => { showBulkReviewModal.value = false; };
      const submitBulkReview = async () => {
        if (bulkReview.result === 'REJECTED' && !bulkReview.message.trim()) {
          alert('반려 사유를 입력해주세요.'); return;
        }
        if (bulkReview.result === 'APPROVED' && !bulkReview.commissionRate) {
          alert('수수료율을 입력해주세요.'); return;
        }
        try {
          await Promise.all(selectedIds.value.map(id =>
            axios.post(contextPath + '/admin/partner/apply/review', {
              applyId:        id,
              result:         bulkReview.result,
              commissionRate: bulkReview.commissionRate,
              message:        bulkReview.message
            })
          ));
          const label = bulkReview.result === 'APPROVED' ? '승인' : '반려';
          alert(selectedIds.value.length + '개 파트너사 일괄 ' + label + ' 완료.');
          closeBulkReviewModal();
          allApplies.value = [];
          fetchList(1);
          fetchKpi();
        } catch(e) {
          console.error('일괄 처리 오류', e);
          alert('처리 중 오류가 발생했습니다.');
        }
      };

      const submitReview = async () => {
        if (!review.result) return;
        if (review.result === 'REJECTED' && !review.message.trim()) { alert('반려 사유를 입력해주세요.'); return; }
        if (review.result === 'APPROVED' && !review.commissionRate)  { alert('수수료율을 입력해주세요.'); return; }

        try {
          await axios.post(`${contextPath}/admin/partner/apply/review`, {
            applyId:        reviewTarget.partnerId,
            result:         review.result,
            commissionRate: review.commissionRate,
            message:        review.message,
            sendNotify:     review.sendNotify
          });
          const label = { APPROVED:'승인', REJECTED:'반려' }[review.result] || '처리';
          alert(label + ' 처리가 완료되었습니다.' + (review.sendNotify ? ' (알림톡/이메일이 발송됩니다.)' : ''));
          closeReviewModal();
          allApplies.value = []; // 캐시 초기화 → 목록 재조회
          fetchList(1);
          fetchKpi();
        } catch(e) {
          console.error('처리 오류', e);
          alert('처리 중 오류가 발생했습니다.');
        }
      };

      /* ── 서류 확인 모달 ── */
      const openDocModal = async (item) => {
        docTarget.partnerName = item.partnerName;
        docTarget.docs        = [];
        Object.assign(docTarget, item); // applyId 포함
        showDocModal.value = true;
        try {
          const res = await axios.get(`${contextPath}/admin/partner/apply/docs`, {
            params: { applyId: item.partnerId }
          });
          docTarget.docs = res.data;
        } catch(e) { console.error('서류 조회 오류', e); }
      };
      const closeDocModal = () => { showDocModal.value = false; };
      const openDoc = (url) => { window.open(url, '_blank'); };

      onMounted(() => {
        fetchKpi();
        setTab('PENDING'); // 기본: 심사 대기 탭
      });

      return {
        kpi, filter, applyList, allApplies, totalCount, pageNo, pagination, searched,
        selectedIds, isAllChecked, toggleCheckAll,
        showReviewModal, reviewTarget, review,
        showDocModal, docTarget,
        setTab, fetchList, copySelectedNames,
        openReviewModal, closeReviewModal, submitReview,
        openBulkReviewModal, closeBulkReviewModal, submitBulkReview, bulkReview, showBulkReviewModal,
        openDocModal, closeDocModal, openDoc,
        resetFilter: () => { filter.category = 'ALL'; filter.keyword = ''; allApplies.value = []; fetchList(1); }
      };
    }
  }).mount('#app');
</script>

</body>
</html>
