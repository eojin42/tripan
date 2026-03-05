/**
 * workspace.schedule.js
 * 장소 CRUD · 드래그앤드롭
 * 로드 순서: workspace.jsp 하단 <script> 참고
 */

var currentAddDay = 1;
function openAddPlace(day) {
  currentAddDay = day;
  openModal('addPlaceModal');
}
function selectPlaceType(btn, type) {
  document.querySelectorAll('.place-type-tab').forEach(function(t){ t.classList.remove('active'); });
  btn.classList.add('active');
  showToast('🔍 ' + type + ' 카테고리 필터 (카카오 API 연동 후 동작)');
}
function searchPlace(q) {
  if (!q) return;
  showToast('🔍 "' + q + '" 검색 중… (카카오 API 연동 예정)');
}
function addPlaceToDay(el, name, addr) {
  var list = document.getElementById('places-' + currentAddDay);
  var count = list.querySelectorAll('.place-card').length + 1;
  var colors = [
    'linear-gradient(135deg,#89CFF0,#FFB6C1)',
    'linear-gradient(135deg,#C2B8D9,#E0BBC2)',
    'linear-gradient(135deg,#A8C8E1,#89CFF0)'
  ];
  var color = colors[(currentAddDay - 1) % 3];
  var card = document.createElement('div');
  card.className = 'place-card';
  card.draggable = true;
  card.setAttribute('data-day', currentAddDay);
  card.innerHTML =
    '<div class="place-num" style="background:' + color + '">' + count + '</div>' +
    '<div class="place-info">' +
      '<div class="place-name">' + name + '</div>' +
      '<div class="place-addr">' + addr + '</div>' +
      '<span class="place-type-badge">📍 장소</span>' +
    '</div>' +
    '<div class="place-actions">' +
      '<button class="place-action-btn" onclick="openMemo(this)">📝</button>' +
      '<button class="place-action-btn" onclick="removePlace(this)">🗑</button>' +
    '</div>';
  initDrag(card);
  list.appendChild(card);
  closeModal('addPlaceModal');
  showToast('📍 ' + name + ' 추가됨!');
  renumberPlaces(currentAddDay);
}

/* ══════════════════════════════
   메모
══════════════════════════════ */
function openMemo(btn) {
  openModal('memoModal');
}
function saveMemo() {
  closeModal('memoModal');
  showToast('📝 메모 저장됨!');
}

/* ══════════════════════════════
   삭제
══════════════════════════════ */
function removePlace(btn) {
  var card = btn.closest('.place-card');
  var day = card.getAttribute('data-day');
  card.style.transition = 'opacity .3s, transform .3s';
  card.style.opacity = '0';
  card.style.transform = 'translateX(-20px)';
  setTimeout(function() {
    card.remove();
    renumberPlaces(day);
    showToast('🗑 장소 삭제됨');
  }, 300);
}
function renumberPlaces(day) {
  var cards = document.querySelectorAll('#places-' + day + ' .place-card');
  cards.forEach(function(card, i) {
    card.querySelector('.place-num').textContent = i + 1;
  });
}

/* ══════════════════════════════
   드래그 앤 드롭
══════════════════════════════ */
var dragging = null;
function initDrag(card) {
  card.addEventListener('dragstart', function() {
    dragging = this;
    setTimeout(function() { card.classList.add('dragging'); }, 0);
  });
  card.addEventListener('dragend', function() {
    this.classList.remove('dragging');
    dragging = null;
    document.querySelectorAll('.place-card').forEach(function(c){ c.classList.remove('drag-over'); });
  });
  card.addEventListener('dragover', function(e) {
    e.preventDefault();
    if (dragging && dragging !== this) this.classList.add('drag-over');
  });
  card.addEventListener('dragleave', function() { this.classList.remove('drag-over'); });
  card.addEventListener('drop', function(e) {
    e.preventDefault();
    this.classList.remove('drag-over');
    if (dragging && dragging !== this) {
      var list = this.parentNode;
      var allCards = Array.from(list.querySelectorAll('.place-card'));
      var fromIdx = allCards.indexOf(dragging);
      var toIdx   = allCards.indexOf(this);
      if (fromIdx < toIdx) list.insertBefore(dragging, this.nextSibling);
      else list.insertBefore(dragging, this);
      var day = this.getAttribute('data-day');
      renumberPlaces(day);
      showToast('↕️ 순서 변경됨');
    }
  });
}
document.querySelectorAll('.place-card').forEach(function(card) { initDrag(card); });

