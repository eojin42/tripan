/**
 * workspace.expense.js
 * 가계부 · 정산
 * 로드 순서: workspace.jsp 하단 <script> 참고
 */

function copyInviteLink() {
  var link = document.getElementById('inviteLinkText').textContent;
  if (navigator.clipboard) {
    navigator.clipboard.writeText(link).then(function() { showToast('🔗 링크 복사됨!'); });
  } else {
    showToast('🔗 링크: ' + link);
  }
}

/* ══════════════════════════════
   정산 요청 [DB] expense_participant.is_settled UPDATE
══════════════════════════════ */
function requestSettle(btn) {
  btn.textContent = '📨 요청 전송';
  btn.style.borderColor = '#89CFF0';
  btn.style.color = '#3a8fb7';
  btn.style.background = 'rgba(137,207,240,.08)';
  btn.onclick = null;
  showToast('📨 정산 요청 알림을 보냈어요!');
}

/* ══════════════════════════════
   지출 추가 [DB] expense INSERT
══════════════════════════════ */
function submitExpense() {
  var name = document.getElementById('exp-name').value.trim();
  var amt  = document.getElementById('exp-amt').value.trim();
  if (!name || !amt) { showToast('⚠️ 항목명과 금액을 입력해주세요'); return; }
  var payer    = document.getElementById('exp-payer');
  var cat      = document.getElementById('exp-cat');
  var isPriv   = document.getElementById('exp-private').checked;
  var payerTxt = payer.options[payer.selectedIndex].text;
  var catTxt   = cat.options[cat.selectedIndex].text;
  var catIcons = {'FOOD':'🍽️','ACCOMMODATION':'🏨','TRANSPORT':'🚗','TOUR':'🎯','CAFE':'☕','SHOPPING':'🛍️','ETC':'📦'};
  var icon = catIcons[cat.value] || '💸';

  /* 목록에 새 아이템 추가 */
  var list = document.querySelector('#panel-expense .expense-panel-inner .btn-add-expense');
  var item = document.createElement('div');
  item.className = 'expense-item';
  item.innerHTML =
    '<div class="expense-item__icon-wrap">' + icon + '</div>' +
    '<div class="expense-item__info">' +
      '<div class="expense-item__name">' + name + (isPriv ? ' <span class="expense-private-badge">🔒 나만 보기</span>' : '') + '</div>' +
      '<div class="expense-item__detail">' +
        '<span>' + document.getElementById('exp-date').value + '</span>' +
        '<span class="expense-payer-chip">💳 ' + payerTxt.split(' ')[0] + '</span>' +
        '<span class="expense-cat-chip">' + catTxt + '</span>' +
      '</div>' +
    '</div>' +
    '<span class="expense-item__amt">₩ ' + Number(amt).toLocaleString() + '</span>';
  list.parentNode.insertBefore(item, list);

  closeModal('addExpenseModal');
  document.getElementById('exp-name').value = '';
  document.getElementById('exp-amt').value  = '';
  document.getElementById('exp-private').checked = false;
  showToast('💸 지출이 추가됐어요!');
}

