/* settlementDetail.js
 * 위치: src/main/resources/static/dist/js/admin/settlementDetail.js
 * detail.jsp 전용
 */

var STL_CTX = (function () {
  var scripts = document.getElementsByTagName('script');
  for (var i = 0; i < scripts.length; i++) {
    if (scripts[i].src && scripts[i].src.indexOf('settlementDetail.js') !== -1) {
      return scripts[i].src.replace(/\/dist\/js\/admin\/settlementDetail\.js.*/, '');
    }
  }
  return '';
}());

/* ── 토스트 ── */
function showToast(msg) {
  var t = document.getElementById('toast');
  t.textContent = msg;
  t.classList.add('show');
  setTimeout(function () { t.classList.remove('show'); }, 2800);
}

/* ── 아코디언 토글 ── */
function togglePlace(placeId) {
  var det = document.getElementById('detail_' + placeId);
  var chv = document.getElementById('chevron_' + placeId);
  if (!det) return;
  var isOpen = det.classList.contains('open');
  document.querySelectorAll('.place-detail').forEach(function (el) { el.classList.remove('open'); });
  document.querySelectorAll('.chevron').forEach(function (el) { el.classList.remove('open'); });
  if (!isOpen) {
    det.classList.add('open');
    chv.classList.add('open');
  }
}

/* ── 숙소 단위 승인 ── */
function approvePlace(placeId, month, btn) {
  if (!confirm('이 숙소의 정산을 승인하시겠습니까?')) return;
  btn.disabled = true;
  btn.textContent = '처리중...';

  fetch(STL_CTX + '/admin/settlement/approve/place', {
    method  : 'POST',
    headers : { 'Content-Type': 'application/x-www-form-urlencoded' },
    body    : 'placeId=' + placeId + '&month=' + month
  })
  .then(function (r) { return r.json(); })
  .then(function (res) {
    if (res.success) {
      btn.innerHTML = '&#10003; 승인 완료';
      btn.style.background = 'var(--border)';
      btn.style.color = 'var(--muted)';
      /* 헤더 뱃지 갱신 */
      var card = document.getElementById('placeCard_' + placeId);
      if (card) {
        var badge = card.querySelector('.badge');
        if (badge) { badge.className = 'badge badge-done'; badge.textContent = '승인완료'; }
      }
      updateBarCount(1);
      showToast('정산 승인이 완료되었습니다.');
    } else {
      btn.disabled = false;
      btn.innerHTML = '&#10003; 이 숙소 정산 승인';
      showToast('오류: ' + (res.message || '승인에 실패했습니다.'));
    }
  })
  .catch(function () {
    btn.disabled = false;
    btn.innerHTML = '&#10003; 이 숙소 정산 승인';
    showToast('통신 오류가 발생했습니다.');
  });
}

/* ── 전체 일괄 승인 ── */
function approveAll(memberId, month) {
  if (!confirm('미승인 숙소를 전체 정산 승인하시겠습니까?')) return;
  var bulkBtn = document.getElementById('bulkApproveBtn');
  bulkBtn.disabled = true;
  bulkBtn.textContent = '처리중...';

  fetch(STL_CTX + '/admin/settlement/approve/partner', {
    method  : 'POST',
    headers : { 'Content-Type': 'application/x-www-form-urlencoded' },
    body    : 'memberId=' + memberId + '&month=' + month
  })
  .then(function (r) { return r.json(); })
  .then(function (res) {
    if (res.success) {
      document.querySelectorAll('.btn-approve-place:not(:disabled)').forEach(function (b) {
        b.disabled = true;
        b.innerHTML = '&#10003; 승인 완료';
        b.style.background = 'var(--border)';
        b.style.color = 'var(--muted)';
      });
      document.querySelectorAll('.badge.badge-wait').forEach(function (b) {
        b.className = 'badge badge-done';
        b.textContent = '승인완료';
      });
      var total = document.querySelectorAll('.place-card').length;
      var barCount = document.getElementById('barApprovedCount');
      if (barCount) barCount.textContent = total;
      bulkBtn.innerHTML = '&#10003;&nbsp; 전체 승인 완료';
      showToast('전체 정산 승인이 완료되었습니다.');
    } else {
      bulkBtn.disabled = false;
      bulkBtn.innerHTML = '&#10003;&nbsp; 미승인 전체 승인';
      showToast('오류: ' + (res.message || '승인에 실패했습니다.'));
    }
  })
  .catch(function () {
    bulkBtn.disabled = false;
    bulkBtn.innerHTML = '&#10003;&nbsp; 미승인 전체 승인';
    showToast('통신 오류가 발생했습니다.');
  });
}

/* ── 승인 카운트 갱신 ── */
function updateBarCount(delta) {
  var el = document.getElementById('barApprovedCount');
  if (!el) return;
  var cur = parseInt(el.textContent, 10) || 0;
  el.textContent = cur + delta;
  var total = document.querySelectorAll('.place-card').length;
  if (cur + delta >= total) {
    var bb = document.getElementById('bulkApproveBtn');
    if (bb) { bb.disabled = true; bb.innerHTML = '&#10003;&nbsp; 전체 승인 완료'; }
  }
}

/* ════════════════════════════════════════════
   CSV 다운로드 (회원관리와 동일한 방식)
   ════════════════════════════════════════════ */

/* 파트너 전체 숙소 CSV */
function downloadPartnerCsv(memberId, month) {
  fetch(STL_CTX + '/admin/settlement/csv/partner?memberId=' + memberId + '&month=' + month)
    .then(function (r) { return r.json(); })
    .then(function (rows) { buildAndSaveCsv(rows, '파트너정산_' + month + '.csv'); })
    .catch(function () { showToast('CSV 다운로드 중 오류가 발생했습니다.'); });
}

/* 숙소 단위 CSV */
function downloadPlaceCsv(placeId, month) {
  fetch(STL_CTX + '/admin/settlement/csv/place?placeId=' + placeId + '&month=' + month)
    .then(function (r) { return r.json(); })
    .then(function (rows) { buildAndSaveCsv(rows, '숙소정산_' + month + '.csv'); })
    .catch(function () { showToast('CSV 다운로드 중 오류가 발생했습니다.'); });
}

/* ── CSV 빌더 (회원관리 downloadFilteredExcel 동일 패턴) ── */
function buildAndSaveCsv(rows, filename) {
  if (!rows || !rows.length) {
    showToast('다운로드할 데이터가 없습니다.');
    return;
  }

  var csv = '\uFEFF'
    + '주문번호,예약번호,주문일,예약자,'
    + '총금액,쿠폰할인(전체),포인트할인,실결제액,'
    + '쿠폰-플랫폼부담,쿠폰-파트너부담,'
    + '수수료율(%),수수료액,파트너수취액,'
    + '결제상태,주문상태\n';

  rows.forEach(function (r) {
    csv += '"' + (r.orderId          || '') + '",'
         + '"' + (r.reservationId    || '') + '",'
         + '"' + (r.orderDate        || '') + '",'
         + '"' + (r.guestNickname    || '') + '",'
         +       (r.totalAmount      || 0)  + ','
         +       (r.couponDiscount   || 0)  + ','
         +       (r.pointDiscount    || 0)  + ','
         +       (r.realTotalAmount  || 0)  + ','
         +       (r.couponPlatformAmt || 0) + ','
         +       (r.couponPartnerAmt  || 0) + ','
         +       (r.commissionRate   || 0)  + ','
         +       (r.commissionAmount || 0)  + ','
         +       (r.partnerPayout    || 0)  + ','
         + '"' + (r.paymentStatus    || '') + '",'
         + '"' + (r.orderStatus      || '') + '"\n';
  });

  var blob = new Blob([csv], { type: 'text/csv;charset=utf-8;' });
  var link = document.createElement('a');
  link.href = URL.createObjectURL(blob);
  link.download = filename;
  document.body.appendChild(link);
  link.click();
  document.body.removeChild(link);
  showToast('CSV 다운로드가 완료되었습니다.');
}
