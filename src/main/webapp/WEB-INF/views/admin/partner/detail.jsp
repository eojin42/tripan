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
    .empty-box { padding:36px 0; text-align:center; color:var(--muted); }
    .top-actions { display:flex; gap:8px; margin-left:auto; }
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
                <dt>계약서</dt>
                <dd>
                  <a v-if="detail.contractFileUrl" :href="detail.contractFileUrl" target="_blank" rel="noopener">계약서 보기</a>
                  <span v-else>-</span>
                </dd>
              </dl>
            </section>
          </div>

          <!-- 제출 서류 섹션 -->
          <section class="detail-card fade-up" style="margin-top:16px;">
            <h3>제출 서류</h3>
            <div v-if="docsLoading" class="empty-box">서류 목록을 불러오는 중...</div>
            <div v-else-if="docs.length === 0" class="empty-box">제출된 서류가 없습니다.</div>
            <table v-else class="section-table">
              <thead>
                <tr>
                  <th>파일명</th>
                  <th>업로드일</th>
                  <th style="text-align:center;">열기</th>
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
                    <button @click="downloadDoc(doc)"
                            style="font-size:13px;font-weight:700;color:var(--primary);background:none;border:none;cursor:pointer;padding:0;">
                      ⬇ 다운로드
                    </button>
                  </td>
                </tr>
              </tbody>
            </table>
          </section>

          <section class="detail-card fade-up" style="margin-top:16px;">
            <h3>운영중인 숙소 리스트</h3>
            <div class="empty-box">현재 제공된 API에는 숙소 목록 필드가 없습니다. 상세 API 확장 시 이 영역에 연결하면 됩니다.</div>
          </section>

          <section class="detail-card fade-up" style="margin-top:16px;">
            <h3>예약 내역 리스트</h3>
            <div class="empty-box">현재 제공된 API에는 예약 내역 필드가 없습니다. 예약 조회 API 연결 시 이 영역에 렌더링하면 됩니다.</div>
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
  const params = new URLSearchParams(window.location.search);
  const partnerId = params.get('partnerId');

  createApp({
    setup() {
      const loading = ref(true);
      const errorMessage = ref('');
      const detail = reactive({});
      const docs = ref([]);
      const docsLoading = ref(false);

      const formatDate = (value) => value ? String(value).substring(0, 10) : '-';
      const numberOrDash = (value) => value === null || value === undefined || value === '' ? '-' : Number(value).toFixed(0);
      const statusLabel = (statusCode, status) => {
        const map = {
          PENDING: '승인 대기',
          ACTIVE: '활성',
          APPROVED: '승인',
          REJECTED: '반려',
          SUSPENDED: '이용정지',
          BLOCKED: '영구차단'
        };
        if (statusCode && map[statusCode]) return map[statusCode];
        if (String(status) === '1') return '활성';
        if (String(status) === '0') return '비활성';
        return '-';
      };

      const downloadDoc = (doc) => {
        const a = document.createElement('a');
        a.href = doc.url;
        a.download = doc.docName || 'download';
        a.target = '_blank';
        document.body.appendChild(a);
        a.click();
        document.body.removeChild(a);
      };

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

      const loadDetail = async () => {
        loading.value = true;
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

      const goBack = () => {
        window.location.href = contextPath + '/admin/partner/main';
      };

      const reloadData = () => loadDetail();

      onMounted(() => { loadDetail(); loadDocs(); });

      return { loading, errorMessage, detail, docs, docsLoading, formatDate, numberOrDash, statusLabel, goBack, reloadData, downloadDoc };
    }
  }).mount('#app');
})();
</script>
</body>
</html>
