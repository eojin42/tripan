/* ── KPI 로드 ── */
function stlLoadKpi() {
  var month = document.getElementById('filterMonth').value;
  var params = month ? '?settlementMonth=' + month : '';
  fetch(STL_CTX + '/admin/settlement/partner/kpi' + params)
    .then(function(r) { return r.json(); })
    .then(function(d) {
      document.getElementById('kpiGmv').textContent        = stlWon(d.totalGmv);
      document.getElementById('kpiCommission').textContent = stlWon(d.totalCommission);
      document.getElementById('kpiPending').textContent    = stlWon(d.pendingAmt);
      document.getElementById('kpiDone').textContent       = stlWon(d.doneAmt);
      document.getElementById('kpiPendingCount').textContent = d.pendingCount + '개 파트너';
      document.getElementById('kpiDoneCount').textContent    = d.doneCount + '개 파트너';
      if (d.totalGmv > 0) {
        document.getElementById('kpiCommissionRate').textContent =
          (d.totalCommission / d.totalGmv * 100).toFixed(1) + '% 수수료율';
      }
    })
    .catch(function() {});
}

/* settlement.js
 * 위치: src/main/resources/static/dist/js/admin/settlement.js
 * main.jsp 전용
 */

var STL_CTX = (function () {
  var scripts = document.getElementsByTagName('script');
  for (var i = 0; i < scripts.length; i++) {
    if (scripts[i].src && scripts[i].src.indexOf('settlement.js') !== -1) {
      return scripts[i].src.replace(/\/dist\/js\/admin\/settlement\.js.*/, '');
    }
  }
  return '';
}());

/* ── 포맷 유틸 ── */
function stlWon(n) {
  if (n == null || n === '') return '-';
  return '\u20a9' + Number(n).toLocaleString('ko-KR');
}

function stlShowToast(msg) {
  var t = document.getElementById('toast');
  t.textContent = msg;
  t.classList.add('show');
  setTimeout(function () { t.classList.remove('show'); }, 2800);
}

function stlStatusBadge(s) {
  if (s === 'done')    return '<span class="badge badge-done">정산 완료</span>';
  if (s === 'partial') return '<span class="badge badge-partial">부분 승인</span>';
  return '<span class="badge badge-wait">정산 대기</span>';
}

/* ── 목록 로드 (AJAX) ── */
function stlLoad() {
  var params = new URLSearchParams({
    settlementMonth : document.getElementById('filterMonth').value,
    status          : document.getElementById('filterStatus').value,
    region          : document.getElementById('filterRegion').value,
    keyword         : document.getElementById('searchInput').value.trim(),
    page            : 1,
    size            : 20
  });

  stlLoadKpi();
  fetch(STL_CTX + '/admin/settlement/partner/list?' + params.toString())
    .then(function (r) { return r.json(); })
    .then(function (data) { stlRenderTable(data.list, data.total); })
    .catch(function () { stlShowToast('데이터 조회 중 오류가 발생했습니다.'); });
}

/* ── 테이블 렌더 ── */
var stlCurrentList = [];

function stlRenderTable(list, total) {
  stlCurrentList = list || [];
  var tbody = document.getElementById('settlementTbody');
  document.getElementById('tableCountBadge').textContent = '(' + total + '개)';

  if (!stlCurrentList.length) {
    tbody.innerHTML = '<tr class="no-result"><td colspan="10">검색 결과가 없습니다.</td></tr>';
    return;
  }

  var html = '';
  for (var i = 0; i < stlCurrentList.length; i++) {
    var p  = stlCurrentList[i];
    var ps = p.settlementStatus;
    // memberId = partner_id (서버에서 AS memberId로 반환)
    var detailUrl = STL_CTX + '/admin/settlement/partner/detail/' + p.memberId + '?month=' + p.settlementMonth;
    var commRate  = p.commissionRate ? p.commissionRate + '%' : '-';
    var ab = (ps === 'done')
      ? '<button class="btn-sm btn-done-sm" disabled>승인완료</button>'
      : '<button class="btn-sm btn-approve-sm" onclick="stlQuickApprove(' + p.memberId + ',\'' + p.settlementMonth + '\',this)">전체 승인</button>';

    html += '<tr>'
      /* 체크박스: 파트너사(partner_id) 단위 — 한 멤버가 여러 파트너사 가질 수 있으므로 partner_id 기준 */
      + '<td style="text-align:center;"><input type="checkbox" class="stl-chk"'
      +   ' data-partner-id="' + p.memberId + '"'
      +   ' data-month="' + p.settlementMonth + '"'
      +   ' data-nickname="' + (p.nickname||'') + '"'
      +   ' style="width:15px;height:15px;cursor:pointer;"></td>'
      + '<td><div class="td-partner">'
      +   '<div class="partner-info">'
      +     '<h4>' + (p.nickname || '') + '</h4>'
      +     '<p>#' + (p.loginId || '') + '</p>'
      +   '</div>'
      + '</div></td>'
      + '<td><span style="color:var(--muted);font-weight:600;">' + p.settlementMonth + '</span><br><small style="font-size:11px;color:var(--muted);">체크아웃 ' + (p.checkedOutCount||0) + '/' + (p.totalReservationCount||0) + '건</small></td>'
      + '<td><span class="badge" style="background:var(--bg);color:var(--text);">' + p.placeCount + '개</span></td>'
      + '<td><span class="num">' + stlWon(p.totalGmv) + '</span></td>'
      + '<td><span class="num" style="color:#DC2626;">- ' + stlWon(p.totalCommission) + '</span><br><small style="font-weight:600;color:#94A3B8;">(' + commRate + ')</small></td>'
      + '<td><span class="num" style="color:#C2410C;">- ' + stlWon(p.totalCouponPartner) + '</span></td>'
      + '<td><span class="num amount-net">' + stlWon(p.totalNetPayout) + '</span></td>'
      + '<td>' + stlStatusBadge(ps) + '</td>'
      + '<td><div class="btn-actions">'
      /* 상세보기: onclick으로 이동 (a 태그 클릭 막히는 경우 방지) */
      +   '<button class="btn-sm btn-detail-sm" onclick="location.href=\'' + detailUrl + '\'"'
      +     ' style="display:inline-flex;align-items:center;justify-content:center;line-height:1;">상세 보기</button>'
      +   ab
      + '</div></td>'
      + '</tr>';
  }
  tbody.innerHTML = html;
}

/* ── 체크박스 선택 CSV 다운로드 ── */
function stlDownloadCheckedCsv() {
  var checked = document.querySelectorAll('.stl-chk:checked');
  if (!checked.length) { stlShowToast('다운로드할 파트너를 선택해주세요.'); return; }
  var month = checked[0].dataset.month;
  var ids = Array.from(checked).map(function(c) { return c.dataset.partnerId; });
  // 선택된 파트너 각각 순차 다운로드
  ids.forEach(function(id, idx) {
    setTimeout(function() {
      stlDownloadCsv(id, checked[idx].dataset.month);
    }, idx * 500);
  });
}

/* ── 전체 체크박스 토글 ── */
function stlToggleAll(el) {
  document.querySelectorAll('.stl-chk').forEach(function(c) { c.checked = el.checked; });
}

/* ── 필터 초기화 ── */
function stlReset() {
  document.getElementById('filterMonth').value  = '';
  document.getElementById('filterStatus').value = '';
  document.getElementById('filterRegion').value = '';
  document.getElementById('searchInput').value  = '';
  stlLoad();
}

/* ── 전체 승인 — partner_id 단위 ── */
function stlQuickApprove(memberId, month, btn) {
  if (!confirm('이 파트너의 전체 숙소를 정산 승인하시겠습니까?')) return;
  btn.disabled = true;
  fetch(STL_CTX + '/admin/settlement/partner/approve/place', {
    method  : 'POST',
    headers : { 'Content-Type': 'application/x-www-form-urlencoded' },
    body    : 'partnerId=' + memberId + '&settlementMonth=' + month
  })
  .then(function (r) { return r.text(); })
  .then(function (res) {
    if (res === 'ok') {
      stlShowToast('전체 정산 승인이 완료되었습니다.');
      stlLoad();
    } else {
      btn.disabled = false;
      stlShowToast(res || '승인에 실패했습니다.');
    }
  })
  .catch(function () { btn.disabled = false; stlShowToast('통신 오류가 발생했습니다.'); });
}

/* ════════════════════════════════════════════
   CSV 다운로드 (회원관리와 동일한 방식)
   ════════════════════════════════════════════ */

/* 현재 목록 전체를 CSV로 다운로드 (필터 결과) */
function stlDownloadListCsv() {
  if (!stlCurrentList.length) {
    alert('다운로드할 데이터가 없습니다. 먼저 검색을 실행해주세요.');
    return;
  }

  var csv = '\uFEFF' + '파트너명,로그인ID,정산월,숙소수,총결제액,수수료,쿠폰파트너부담,최종지급액,정산상태\n';
  stlCurrentList.forEach(function (p) {
    var statusTxt = p.settlementStatus === 'done' ? '정산완료'
                  : p.settlementStatus === 'partial' ? '부분승인' : '정산대기';
    csv += '"' + (p.nickname         || '') + '",'
         + '"' + (p.loginId          || '') + '",'
         + '"' + (p.settlementMonth  || '') + '",'
         +       (p.placeCount       || 0)  + ','
         +       (p.totalGmv         || 0)  + ','
         +       (p.totalCommission  || 0)  + ','
         +       (p.totalCouponPartner || 0) + ','
         +       (p.totalNetPayout   || 0)  + ','
         + '"' + statusTxt + '"\n';
  });

  stlSaveCsv(csv, '정산목록_' + new Date().toISOString().slice(0, 10) + '.csv');
}

/* 특정 파트너의 예약 건별 상세 CSV (서버에서 JSON 받아서 변환) */
function stlDownloadCsv(memberId, month) {
  fetch(STL_CTX + '/admin/settlement/partner/csv/partner?memberId=' + memberId + '&month=' + month)
    .then(function (r) { return r.json(); })
    .then(function (rows) {
      if (!rows || !rows.length) {
        stlShowToast('다운로드할 데이터가 없습니다.');
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

      stlSaveCsv(csv, '파트너정산_' + month + '.csv');
      stlShowToast('CSV 다운로드가 완료되었습니다.');
    })
    .catch(function () { stlShowToast('CSV 다운로드 중 오류가 발생했습니다.'); });
}

/* ── CSV 저장 공통 ── */
function stlSaveCsv(csvContent, filename) {
  var blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' });
  var link = document.createElement('a');
  link.href = URL.createObjectURL(blob);
  link.download = filename;
  document.body.appendChild(link);
  link.click();
  document.body.removeChild(link);
}

/* 페이지 로드 시 KPI 자동 로드 */
stlLoadKpi();