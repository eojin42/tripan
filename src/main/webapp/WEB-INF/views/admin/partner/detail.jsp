<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <title>TripanSuper — 파트너사 상세</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/dist/css/admin.css">
  <style>
    .detail-grid { display:grid; grid-template-columns:repeat(2,minmax(0,1fr)); gap:16px; }
    .detail-card { background:#fff; border:1px solid var(--border); border-radius:18px; padding:20px; box-shadow:0 10px 24px rgba(15,23,42,.04); }
    .detail-card h3 { margin:0 0 14px; font-size:16px; font-weight:900; }
    .detail-list { display:grid; grid-template-columns:140px 1fr; gap:10px 16px; }
    .detail-list dt { color:var(--muted); font-weight:800; font-size:12px; text-transform:uppercase; }
    .detail-list dd { margin:0; font-weight:600; word-break:break-all; }
    .section-table { width:100%; border-collapse:collapse; }
    .section-table th,.section-table td { padding:12px 10px; border-bottom:1px solid var(--border); text-align:left; font-size:13px; }
    .section-table tbody tr { transition: background 0.15s; }
    .section-table tbody tr:hover { background: #F8FAFC; }
    .section-table tbody tr[style*="cursor:pointer"]:hover td { color: var(--primary); }
    .empty-box { padding:36px 0; text-align:center; color:var(--muted); }
    .top-actions { display:flex; gap:8px; margin-left:auto; }
    .btn-download {
      font-size:13px; font-weight:700; color:var(--primary);
      background:none; border:none; cursor:pointer; padding:0;
      display:inline-flex; align-items:center; gap:4px;
    }
    .btn-download:hover { text-decoration:underline; }
    .btn-download:disabled { color:var(--muted); cursor:not-allowed; }
    @media (max-width: 980px) { .detail-grid { grid-template-columns:1fr; } }
  </style>
</head>
<body>
<div class="admin-layout">
  <jsp:include page="../layout/sidebar.jsp"><jsp:param name="activePage" value="partners"/></jsp:include>
  <div class="main-wrapper">
    <jsp:include page="../layout/header.jsp" />
    <div id="app" style="flex:1;display:flex;flex-direction:column;min-height:0;overflow:hidden;">
      <main class="main-content" style="flex:1;overflow-y:auto;">
        <div class="page-header fade-up">
          <div>
            <h1>파트너사 상세</h1>
            <p>기본 정보, 계약 정보, 운영 숙소, 예약 내역을 한 번에 확인합니다.</p>
          </div>
          <div class="top-actions">
            <button class="btn btn-outline" @click="goBack">목록으로</button>
            <button class="btn btn-primary" @click="reloadData">새로고침</button>
          </div>
        </div>

        <div class="card fade-up" v-if="loading" style="padding:48px; text-align:center; color:var(--muted);">
          상세 정보를 불러오는 중입니다.
        </div>

        <div class="card fade-up" v-else-if="errorMessage" style="padding:48px; text-align:center; color:var(--danger);">
          {{ errorMessage }}
        </div>

        <template v-else>
          <!-- 기본 정보 + 계약 정보 -->
          <div class="detail-grid fade-up">
            <section class="detail-card">
              <h3>파트너사 기본 정보</h3>
              <dl class="detail-list">
                <dt>파트너 ID</dt><dd>{{ detail.partnerId || '-' }}</dd>
                <dt>파트너사명</dt><dd>{{ detail.partnerName || '-' }}</dd>
                <dt>사업자번호</dt><dd>{{ detail.businessNumber || '-' }}</dd>
                <dt>담당자명</dt><dd>{{ detail.contactName || '-' }}</dd>
                <dt>연락처</dt><dd>{{ detail.contactPhone || '-' }}</dd>
                <dt>이메일</dt><dd>{{ detail.contactEmail || '-' }}</dd>
                <dt>상태</dt><dd>{{ statusLabel(detail.statusCode, detail.status) }}</dd>
                <dt>등록일</dt><dd>{{ formatDate(detail.createdAt) }}</dd>
              </dl>
            </section>

            <section class="detail-card">
              <h3>계약 정보</h3>
              <dl class="detail-list">
                <dt>수수료율</dt><dd>{{ numberOrDash(detail.commissionRate) }}%</dd>
                <dt>은행명</dt><dd>{{ detail.bankName || '-' }}</dd>
                <dt>계좌번호</dt><dd>{{ detail.accountNumber || '-' }}</dd>
                <dt>계약 종료일</dt><dd>{{ formatDate(detail.contractEndDate) }}</dd>
                <dt>상태 메모</dt><dd>{{ detail.statusMemo || '-' }}</dd>
              </dl>
            </section>
          </div>

          <!-- 제출 서류 -->
          <section class="detail-card fade-up" style="margin-top:16px;">
            <h3>제출 서류</h3>
            <div v-if="docsLoading" class="empty-box">서류 목록을 불러오는 중...</div>
            <div v-else-if="docs.length === 0" class="empty-box">제출된 서류가 없습니다.</div>
            <table v-else class="section-table">
              <thead>
                <tr>
                  <th>파일명</th>
                  <th>업로드일</th>
                  <th style="text-align:center; width:100px;">다운로드</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="doc in docs" :key="doc.docId">
                  <td>
                    <span style="font-size:16px;margin-right:6px;">📄</span>
                    {{ doc.docName || '-' }}
                  </td>
                  <td style="color:var(--muted);font-size:13px;">{{ doc.uploadDate || '-' }}</td>
                  <td style="text-align:center;">
                    <button class="btn-download"
                            :disabled="!doc.url"
                            @click="downloadDoc(doc)">
                      ⬇ 다운로드
                    </button>
                  </td>
                </tr>
              </tbody>
            </table>
          </section>

          <!-- 운영중인 숙소 리스트 -->
          <section class="detail-card fade-up" style="margin-top:16px;">
            <h3>운영중인 숙소 리스트</h3>
            <div v-if="placesLoading" class="empty-box">불러오는 중...</div>
            <div v-else-if="places.length === 0" class="empty-box">운영중인 숙소가 없습니다.</div>
            <table v-else class="section-table">
              <thead>
                <tr>
                  <th>숙소명</th>
                  <th>주소</th>
                  <th>유형</th>
                  <th>평점</th>
                  <th>리뷰수</th>
                  <th>상태</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="pl in places" :key="pl.placeId"
                    style="cursor:pointer;"
                    @click="goToPlace(pl.placeId)">
                  <td>{{ pl.placeName || '-' }}</td>
                  <td style="color:var(--muted);font-size:12px;">{{ pl.address || '-' }}</td>
                  <td>{{ pl.placeType || '-' }}</td>
                  <td>
                    <span style="color:#F59E0B; font-weight:700;">★ {{ Number(pl.rating || 0).toFixed(1) }}</span>
                  </td>
                  <td>{{ pl.reviewCount || 0 }}</td>
                  <td>
                    <span v-if="String(pl.status) === '1'" class="badge badge-active">운영중</span>
                    <span v-else class="badge badge-suspended">중지</span>
                  </td>
                </tr>
              </tbody>
            </table>
          </section>

          <!-- 예약 내역 리스트 -->
          <section class="detail-card fade-up" style="margin-top:16px;">
            <h3>예약 내역 리스트</h3>
            <div v-if="reservationsLoading" class="empty-box">불러오는 중...</div>
            <div v-else-if="reservations.length === 0" class="empty-box">예약 내역이 없습니다.</div>
            <table v-else class="section-table">
              <thead>
                <tr>
                  <th>예약번호</th>
                  <th>숙소명</th>
                  <th>예약자</th>
                  <th>체크인</th>
                  <th>체크아웃</th>
                  <th>결제금액</th>
                  <th>상태</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="rv in reservations" :key="rv.reservationId">
                  <td style="font-size:12px; color:var(--muted);">{{ rv.reservationId }}</td>
                  <td>{{ rv.placeName || '-' }}</td>
                  <td>{{ rv.memberNickname || '-' }}</td>
                  <td>{{ formatDate(rv.checkInDate) }}</td>
                  <td>{{ formatDate(rv.checkOutDate) }}</td>
                  <td style="font-weight:700;">
                    {{ rv.totalPrice != null ? Number(rv.totalPrice).toLocaleString() + '원' : '-' }}
                  </td>
                  <td>
                    <span v-if="rv.status === 'SUCCESS'" class="badge badge-active">완료</span>
                    <span v-else-if="rv.status === 'CANCELED'" class="badge badge-suspended">취소</span>
                    <span v-else class="badge badge-pending">{{ rv.status || '-' }}</span>
                  </td>
                </tr>
              </tbody>
            </table>
          </section>
        </template>
      </main>
    </div>
  </div>
</div>

<script src="https://unpkg.com/vue@3/dist/vue.global.prod.js"></script>
<script src="https://cdn.jsdelivr.net/npm/axios/dist/axios.min.js"></script>
<script>
(() => {
  const { createApp, ref, reactive, onMounted } = Vue;
  const contextPath = '${pageContext.request.contextPath}';

  // ✅ partnerId: URL 파라미터에서 숫자만 추출 (혹시 모를 문자 오염 방지)
  const rawPartnerId = new URLSearchParams(window.location.search).get('partnerId');
  const partnerId    = rawPartnerId ? String(parseInt(rawPartnerId, 10)) : null;

  console.log('[detail] contextPath =', contextPath, '/ partnerId =', partnerId);

  createApp({
    setup() {
      const loading             = ref(true);
      const errorMessage        = ref('');
      const detail              = reactive({});
      const docs                = ref([]);
      const docsLoading         = ref(false);
      const places              = ref([]);
      const placesLoading       = ref(false);
      const reservations        = ref([]);
      const reservationsLoading = ref(false);

      /* ── 유틸 ── */
      const formatDate = (value) => value ? String(value).substring(0, 10) : '-';
      const numberOrDash = (value) =>
        (value === null || value === undefined || value === '') ? '-' : Number(value).toFixed(0);
      const statusLabel = (statusCode, status) => {
        const map = {
          PENDING: '승인 대기', ACTIVE: '활성', APPROVED: '승인',
          REJECTED: '반려', SUSPENDED: '이용정지', BLOCKED: '영구차단'
        };
        if (statusCode && map[statusCode]) return map[statusCode];
        if (String(status) === '1') return '활성';
        if (String(status) === '0') return '비활성';
        return '-';
      };

      /* ── 파일 다운로드
       *  form GET 방식으로 전송 → 한글 파일명 인코딩 안전
       *  contextPath가 '/' 일 때 '//' 방지
       * ── */
      const downloadDoc = (doc) => {
        console.log('[downloadDoc] doc =', JSON.stringify(doc));
        if (!doc.url) { alert('다운로드 URL이 없습니다.\n(file_url 컬럼이 비어있습니다)'); return; }

        // contextPath = '/' 이면 빈 문자열로 처리해서 //api/... 방지
        const base = (contextPath === '/' || contextPath === '') ? '' : contextPath;

        const form = document.createElement('form');
        form.method = 'GET';
        form.action = base + '/api/admin/partner/apply/docs/download';

        const inputUrl = document.createElement('input');
        inputUrl.type  = 'hidden';
        inputUrl.name  = 'fileUrl';
        inputUrl.value = doc.url;

        const inputName = document.createElement('input');
        inputName.type  = 'hidden';
        inputName.name  = 'fileName';
        inputName.value = doc.docName || 'download';

        form.appendChild(inputUrl);
        form.appendChild(inputName);
        document.body.appendChild(form);
        form.submit();
        document.body.removeChild(form);
      };

      /* ── 제출 서류 목록 ── */
      const loadDocs = async () => {
        if (!partnerId) return;
        docsLoading.value = true;
        try {
          const res = await axios.get(contextPath + '/api/admin/partner/apply/docs', {
            params: { applyId: partnerId }
          });
          docs.value = res.data || [];
        } catch(e) {
          console.error('서류 조회 오류', e);
          docs.value = [];
        } finally {
          docsLoading.value = false;
        }
      };

      /* ── 운영중인 숙소 ── */
      const loadPlaces = async () => {
        if (!partnerId) return;
        placesLoading.value = true;
        try {
          const base = (contextPath === '/' || contextPath === '') ? '' : contextPath;
          const res = await axios.get(base + '/api/admin/partner/detail/' + partnerId + '/places');
          places.value = res.data || [];
        } catch(e) {
          console.error('숙소 조회 오류', e);
          places.value = [];
        } finally {
          placesLoading.value = false;
        }
      };

      /* ── 예약 내역 ── */
      const loadReservations = async () => {
        if (!partnerId) return;
        reservationsLoading.value = true;
        try {
          const base = (contextPath === '/' || contextPath === '') ? '' : contextPath;
          const res = await axios.get(base + '/api/admin/partner/detail/' + partnerId + '/reservations');
          reservations.value = res.data || [];
        } catch(e) {
          console.error('예약 조회 오류', e);
          reservations.value = [];
        } finally {
          reservationsLoading.value = false;
        }
      };

      /* ── 기본 상세 ── */
      const loadDetail = async () => {
        loading.value      = true;
        errorMessage.value = '';
        if (!partnerId) {
          errorMessage.value = 'partnerId가 없습니다.';
          loading.value = false;
          return;
        }
        try {
          const res = await axios.get(contextPath + '/api/admin/partner/detail/' + partnerId);
          Object.keys(detail).forEach(key => delete detail[key]);
          Object.assign(detail, res.data || {});
        } catch (e) {
          console.error('상세 조회 오류', e?.response || e);
          errorMessage.value = e?.response?.data || '상세 정보를 불러오지 못했습니다.';
        } finally {
          loading.value = false;
        }
      };

      const goBack     = () => { window.location.href = contextPath + '/admin/partner/main'; };
      const reloadData = () => { loadDetail(); loadDocs(); loadPlaces(); loadReservations(); };
      const goToPlace  = (placeId) => {
        const base = (contextPath === '/' || contextPath === '') ? '' : contextPath;
        window.open(base + '/accommodation/detail/' + placeId, '_blank');
      };

      onMounted(() => { loadDetail(); loadDocs(); loadPlaces(); loadReservations(); });

      return {
        loading, errorMessage, detail,
        docs, docsLoading,
        places, placesLoading,
        reservations, reservationsLoading,
        formatDate, numberOrDash, statusLabel,
        goBack, reloadData, downloadDoc, goToPlace
      };
    }
  }).mount('#app');
})();
</script>
</body>
</html>
