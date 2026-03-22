let currentPage = 1;
let currentDetailReservationId = null;

document.addEventListener('DOMContentLoaded', () => {
  loadKpi();
});

function resetSearch() {
  document.getElementById('startDate').value     = '';
  document.getElementById('endDate').value       = '';
  document.getElementById('status').value        = '';
  document.getElementById('paymentStatus').value = '';
  document.getElementById('keywordType').value   = 'reservationId';
  document.getElementById('keyword').value       = '';
  document.getElementById('reservationTbody').innerHTML =
    '<tr><td colspan="9" style="text-align:center;padding:50px 0;color:var(--muted);">상단의 검색 조건을 설정한 후 <strong>[검색]</strong> 버튼을 눌러주세요.</td></tr>';
  document.getElementById('pagination').innerHTML = '';
  loadKpi();
}

async function loadKpi() {
  try {
    const res  = await fetch(contextPath + '/api/admin/reservations/kpi');
    const data = await res.json();
    renderKpi(data);
  } catch(e) {
    console.error('KPI 로드 실패', e);
  }
}

async function searchReservations(page) {
  currentPage = page;

  const params = new URLSearchParams({
    page,
    size:          10,
    startDate:     document.getElementById('startDate').value,
    endDate:       document.getElementById('endDate').value,
    status:        document.getElementById('status').value,
    paymentStatus: document.getElementById('paymentStatus').value,
    keywordType:   document.getElementById('keywordType').value,
    keyword:       document.getElementById('keyword').value
  });

  try {
    const [listRes, kpiRes] = await Promise.all([
      fetch(contextPath + '/api/admin/reservations?' + params),
      fetch(contextPath + '/api/admin/reservations/kpi?' + params)
    ]);

    const listData = await listRes.json();
    const kpiData  = await kpiRes.json();

    renderKpi(kpiData);
    renderTable(listData.list || []);
    renderPagination(listData.page || 1, listData.totalPages || 1);
  } catch(e) {
    console.error('검색 실패', e);
  }
}

function renderKpi(kpi) {
  document.getElementById('kpiTotalCount').textContent = numberFormat(kpi.totalCount     || 0);
  document.getElementById('kpiReserved').textContent   = numberFormat(kpi.reservedCount  || 0);
  document.getElementById('kpiUsed').textContent       = numberFormat(kpi.usedCount      || 0);
  document.getElementById('kpiCancelled').textContent  = numberFormat(kpi.cancelledCount || 0);
}

function renderTable(list) {
  const tbody = document.getElementById('reservationTbody');
  if (!list.length) {
    tbody.innerHTML = '<tr><td colspan="9" class="empty-row">조회된 예약이 없습니다.</td></tr>';
    return;
  }
  tbody.innerHTML = list.map(item => `
    <tr>
      <td>
        <div class="cell-stack">
          <span class="reservation-number">${escapeHtml(String(item.reservationId || '-'))}</span>
          <span class="reservation-sub">${escapeHtml(item.orderId || '-')}</span>
        </div>
      </td>
      <td>
        <div class="cell-stack">
          <strong>${escapeHtml(item.placeName || '-')}</strong>
          <span class="reservation-sub">${escapeHtml(item.roomName || '-')}</span>
        </div>
      </td>
      <td>${escapeHtml(item.memberName || '-')}</td>
      <td>
        <div class="cell-stack">
          <strong>${escapeHtml(item.checkInDate || '-')}</strong>
          <span class="reservation-sub">~ ${escapeHtml(item.checkOutDate || '-')}</span>
        </div>
      </td>
      <td class="right amount">${numberFormat(item.amount)}원</td>
      <td class="right amount">${numberFormat(item.refundAmount)}원</td>
      <td>${buildStatusBadge(item.status)}</td>
      <td>${buildPaymentBadge(item.paymentStatus)}</td>
      <td>
        <button class="btn btn-sm btn-ghost" type="button"
          onclick="openDetailModal(${item.reservationId})">상세</button>
      </td>
    </tr>
  `).join('');
}

function renderPagination(page, totalPages) {
  const pagination = document.getElementById('pagination');
  if (totalPages <= 1) { pagination.innerHTML = ''; return; }
  let html = `<button class="pg-btn pg-arrow" ${page <= 1 ? 'disabled' : ''} onclick="searchReservations(${page - 1})">&lt;</button>`;
  for (let i = 1; i <= totalPages; i++) {
    html += i === page
      ? `<button class="pg-btn active">${i}</button>`
      : `<button class="pg-btn" onclick="searchReservations(${i})">${i}</button>`;
  }
  html += `<button class="pg-btn pg-arrow" ${page >= totalPages ? 'disabled' : ''} onclick="searchReservations(${page + 1})">&gt;</button>`;
  pagination.innerHTML = html;
}

async function openDetailModal(reservationId) {
  currentDetailReservationId = reservationId;

  try {
    const res    = await fetch(contextPath + '/api/admin/reservations/' + reservationId);
    const data   = await res.json();
    const detail = data.detail || data;
    const coupons = data.coupons || [];

    if (!detail || !detail.reservationId) {
      alert('예약 정보를 불러올 수 없습니다.');
      return;
    }

    document.getElementById('modalReservationId').textContent    = detail.reservationId || '-';
    document.getElementById('modalMemberName').textContent       = detail.memberName    || '-';
    document.getElementById('modalPlaceName').textContent        = detail.placeName     || '-';
    document.getElementById('modalRoomName').textContent         = detail.roomName      || '-';
    document.getElementById('modalPartnerName').textContent      = detail.partnerName   || '-';
    document.getElementById('modalCheckIn').textContent          = detail.checkInDate   || '-';
    document.getElementById('modalCheckOut').textContent         = detail.checkOutDate  || '-';
    document.getElementById('modalGuestCount').textContent       = detail.guestCount    || '-';
    document.getElementById('modalRequest').textContent          = detail.request       || '-';
    document.getElementById('modalAmount').textContent           = numberFormat(detail.amount) + '원';
    document.getElementById('modalRefundAmount').textContent     = numberFormat(detail.refundAmount) + '원';
    document.getElementById('modalPointDiscount').textContent    = numberFormat(detail.pointDiscount) + '원';
    document.getElementById('modalCommissionRate').textContent   = (detail.commissionRate || 0) + '%';
    document.getElementById('modalPaymentStatus').textContent    = detail.paymentStatus  || '-';
    document.getElementById('modalSettlementTarget').textContent = numberFormat(detail.settlementTargetAmount) + '원';

    const couponWrap = document.getElementById('modalCouponList');
    couponWrap.innerHTML = coupons.length
      ? coupons.map(c => `
          <div class="coupon-item">
            <span class="coupon-name">${escapeHtml(c.couponName)}</span>
            <span class="coupon-amount">-${numberFormat(c.discountAmount)}원</span>
            <span class="coupon-share">(플랫폼 ${c.platformShare ?? '-'}% · 파트너 ${c.partnerShare ?? '-'}%)</span>
          </div>`).join('')
      : '<span style="color:var(--muted);font-size:13px;">사용된 쿠폰 없음</span>';

    document.getElementById('modalStatusBadge').outerHTML =
      buildStatusBadge(detail.status, 'modalStatusBadge');
    document.getElementById('detailModal').classList.add('open');
  } catch(e) {
    console.error('상세 로드 실패', e);
  }
}

function closeDetailModal() {
  document.getElementById('detailModal').classList.remove('open');
}

async function changeReservationStatus(status) {
  if (!currentDetailReservationId) return;
  if (!confirm('예약 상태를 변경하시겠습니까?')) return;

  const res  = await fetch(
    contextPath + '/api/admin/reservations/' + currentDetailReservationId + '/statusByResId',
    { method: 'PUT', headers: {'Content-Type': 'application/json'}, body: JSON.stringify({ status }) }
  );
  const data = await res.json();
  alert(data.message || '처리되었습니다.');
  closeDetailModal();
  searchReservations(currentPage);
}

function buildStatusBadge(status, id) {
  const cls = status === 'CANCELED' ? 'badge badge-danger' : 'badge badge-done';
  return `<span ${id ? `id="${id}"` : ''} class="${cls}">${escapeHtml(status || '-')}</span>`;
}

function buildPaymentBadge(status) {
  const danger = ['취소처리중', '취소완료'];
  const cls = danger.includes(status) ? 'badge badge-danger' : 'badge badge-done';
  return `<span class="${cls}">${escapeHtml(status || '-')}</span>`;
}

function numberFormat(value) {
  return Number(value || 0).toLocaleString('ko-KR');
}

function escapeHtml(str) {
  return String(str ?? '')
    .replaceAll('&', '&amp;').replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;').replaceAll('"', '&quot;').replaceAll("'", '&#39;');
}