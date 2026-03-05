/**
 * workspace.checklist.js
 * 체크리스트 CRUD
 * 로드 순서: workspace.jsp 하단 <script> 참고
 */


/* 진행률 재계산 */
function updateCheckProgress() {
  var all   = document.querySelectorAll('#checkGrid .check-item').length;
  var done  = document.querySelectorAll('#checkGrid .check-item.done').length;
  var pct   = all === 0 ? 0 : Math.round(done / all * 100);
  var bar   = document.getElementById('checkProgressBar');
  var txt   = document.getElementById('checkProgressTxt');
  if (bar) bar.style.width = pct + '%';
  if (txt) txt.textContent = done + ' / ' + all + ' 완료';
}

/* 체크 토글 */
function toggleCheck(item) {
  /* [DB] trip_checklist 항목 is_checked UPDATE */
  var cb = item.querySelector('input[type=checkbox]');
  cb.checked = !cb.checked;
  item.classList.toggle('done', cb.checked);
  updateCheckProgress();
}

/* 아이템 삭제 */
/* [DB] trip_checklist DELETE by checklist_id */
function delCheckItem(btn) {
  var item = btn.closest('.check-item');
  item.style.transition = 'opacity .25s, transform .25s';
  item.style.opacity = '0';
  item.style.transform = 'translateX(-12px)';
  setTimeout(function(){
    item.remove();
    updateCheckProgress();
  }, 250);
}

/* 인라인 항목 추가 열기 */
function openInlineAdd(catId) {
  /* 다른 열려있는 행 닫기 */
  document.querySelectorAll('.check-add-row.open').forEach(function(r){ r.classList.remove('open'); r.querySelector('.check-add-input').value=''; });
  var row = document.getElementById('add-row-' + catId);
  if (row) {
    row.classList.add('open');
    row.querySelector('.check-add-input').focus();
  }
}

function cancelInlineAdd(catId) {
  var row = document.getElementById('add-row-' + catId);
  if (row) { row.classList.remove('open'); row.querySelector('.check-add-input').value = ''; }
}

/* 인라인 항목 확정 추가 */
/* [DB] trip_checklist INSERT */
function confirmInlineAdd(catId) {
  var row   = document.getElementById('add-row-' + catId);
  var input = row.querySelector('.check-add-input');
  var val   = input.value.trim();
  if (!val) { input.focus(); return; }

  var cat  = document.getElementById(catId);
  var newId = 'c_' + Date.now();
  var item = document.createElement('div');
  item.className = 'check-item';
  item.onclick = function(){ toggleCheck(this); };
  item.innerHTML =
    '<input type="checkbox" id="' + newId + '">' +
    '<label for="' + newId + '">' + val + '</label>' +
    '<span class="check-by">나</span>' +
    '<button class="check-item-del" onclick="event.stopPropagation();delCheckItem(this)" title="삭제">✕</button>';
  cat.insertBefore(item, row);
  input.value = '';
  input.focus();
  updateCheckProgress();
  showToast('✅ 항목 추가됨');
}

/* Enter 키 지원 */
function checkAddKeydown(e, catId) {
  if (e.key === 'Enter') confirmInlineAdd(catId);
  if (e.key === 'Escape') cancelInlineAdd(catId);
}

/* 새 카테고리 추가 */
function addNewCategory() {
  var name = prompt('카테고리 이름을 입력하세요 (예: 🧴 세면도구)');
  if (!name || !name.trim()) return;
  var catId = 'cat-' + Date.now();
  var addCard = document.querySelector('.check-category-add-card');
  var cat = document.createElement('div');
  cat.className = 'check-category';
  cat.id = catId;
  cat.innerHTML =
    '<div class="check-cat-label">' +
      '<span class="check-cat-label-left">' + name.trim() + '</span>' +
      '<button class="check-cat-add" onclick="openInlineAdd(\'' + catId + '\')">+ 항목</button>' +
    '</div>' +
    '<div class="check-add-row open" id="add-row-' + catId + '">' +
      '<input type="text" class="check-add-input" placeholder="첫 항목 입력…" onkeydown="checkAddKeydown(event,\'' + catId + '\')">' +
      '<button class="check-add-confirm" onclick="confirmInlineAdd(\'' + catId + '\')">추가</button>' +
      '<button class="check-add-cancel" onclick="cancelInlineAdd(\'' + catId + '\')">취소</button>' +
    '</div>';
  addCard.parentNode.insertBefore(cat, addCard);
  setTimeout(function(){ cat.querySelector('.check-add-input').focus(); }, 50);
  showToast('📋 카테고리 추가됨');
}

/* + 추가 버튼 (헤더) → 첫 카테고리에 인라인 추가 열기 */
function openAddCheckModal() {
  var firstCat = document.querySelector('#checkGrid .check-category');
  if (firstCat) openInlineAdd(firstCat.id);
}

