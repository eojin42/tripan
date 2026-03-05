/**
 * workspace.recommend.js
 * 추천 사이드바 · 일정요약
 * 로드 순서: workspace.jsp 하단 <script> 참고
 */


/* 탭 전환 */
function switchRpTab(name, btn) {
  document.querySelectorAll('.rp-tab').forEach(function(t){ t.classList.remove('active'); });
  document.querySelectorAll('.rp-pane').forEach(function(p){ p.classList.remove('active'); });
  btn.classList.add('active');
  document.getElementById('rpPane-' + name).classList.add('active');
  if (name === 'summary') renderDaySummary();
}

/* 카테고리 필터 */
var currentRpCat = 'all';
function filterRec(btn, cat) {
  currentRpCat = cat;
  document.querySelectorAll('.rp-filter-btn').forEach(function(b){ b.classList.remove('active'); });
  btn.classList.add('active');
  applyRpFilter();
}

/* 검색 + 필터 동시 적용 */
function applyRpFilter() {
  var q = (document.getElementById('rpSearchInput').value || '').trim().toLowerCase();
  var visCount = 0;
  document.querySelectorAll('.rp-card').forEach(function(card){
    var catOk = (currentRpCat === 'all' || card.getAttribute('data-cat') === currentRpCat);
    var nameOk = !q || (card.getAttribute('data-name') || '').toLowerCase().indexOf(q) !== -1 ||
                 (card.querySelector('.rp-card-addr') && card.querySelector('.rp-card-addr').textContent.toLowerCase().indexOf(q) !== -1);
    if (catOk && nameOk) { card.classList.remove('hidden'); visCount++; }
    else { card.classList.add('hidden'); }
  });
  var noResult = document.getElementById('rpNoResult');
  if (noResult) noResult.style.display = visCount === 0 ? 'block' : 'none';
}

function searchRpCards(val) {
  var clearBtn = document.getElementById('rpSearchClear');
  if (clearBtn) clearBtn.style.display = val ? 'block' : 'none';
  applyRpFilter();
}
function clearRpSearch() {
  var inp = document.getElementById('rpSearchInput');
  if (inp) inp.value = '';
  document.getElementById('rpSearchClear').style.display = 'none';
  applyRpFilter();
}

/* 일정에 추가 — Day 선택 팝업 열기 */
var pendingRecName = '', pendingRecAddr = '';
function openAddToDay(name, addr) {
  pendingRecName = name;
  pendingRecAddr = addr;
  var popup = document.getElementById('dayPickerPopup');
  popup.style.display = 'block';
  // 오버레이 역할 dim
  var dim = document.getElementById('dppDim');
  if (!dim) {
    dim = document.createElement('div');
    dim.id = 'dppDim';
    dim.style.cssText = 'position:fixed;inset:0;background:rgba(26,32,44,.3);z-index:599;';
    dim.onclick = closeDayPicker;
    document.body.appendChild(dim);
  }
  dim.style.display = 'block';
}
function closeDayPicker() {
  document.getElementById('dayPickerPopup').style.display = 'none';
  var dim = document.getElementById('dppDim');
  if (dim) dim.style.display = 'none';
}
function addRecToDay(day) {
  addPlaceToDay(null, pendingRecName, pendingRecAddr);
  // addPlaceToDay는 currentAddDay를 씀 — 여기선 직접 처리
  currentAddDay = day;
  var list = document.getElementById('places-' + day);
  var count = list.querySelectorAll('.place-card').length + 1;
  var colors = [
    'linear-gradient(135deg,#89CFF0,#FFB6C1)',
    'linear-gradient(135deg,#C2B8D9,#E0BBC2)',
    'linear-gradient(135deg,#A8C8E1,#89CFF0)',
    'linear-gradient(135deg,#89CFF0,#C2B8D9)'
  ];
  var color = colors[(day - 1) % colors.length];
  var card = document.createElement('div');
  card.className = 'place-card';
  card.draggable = true;
  card.setAttribute('data-day', day);
  card.innerHTML =
    '<div class="place-num" style="background:' + color + '">' + count + '</div>' +
    '<div class="place-info">' +
      '<div class="place-name">' + pendingRecName + '</div>' +
      '<div class="place-addr">' + pendingRecAddr + '</div>' +
      '<span class="place-type-badge">📍 장소</span>' +
    '</div>' +
    '<div class="place-actions">' +
      '<button class="place-action-btn" onclick="openMemo(this)">📝</button>' +
      '<button class="place-action-btn" onclick="removePlace(this)">🗑</button>' +
    '</div>';
  initDrag(card);
  list.appendChild(card);
  renumberPlaces(day);
  closeDayPicker();
  showToast('📍 DAY ' + day + '에 ' + pendingRecName + ' 추가됨!');
}

/* 일정 요약 렌더 — 심플 타임라인 */
function renderDaySummary() {
  var accordion = document.getElementById('rpDayAccordion');
  if (!accordion) return;

  var dayColors = [
    'linear-gradient(135deg,#89CFF0,#FFB6C1)',
    'linear-gradient(135deg,#C2B8D9,#E0BBC2)',
    'linear-gradient(135deg,#A8C8E1,#89CFF0)',
    'linear-gradient(135deg,#89CFF0,#C2B8D9)'
  ];
  var dayDates = ['3월 10일 (화)','3월 11일 (수)','3월 12일 (목)','3월 13일 (금)'];
  var html = '';

  for (var d = 1; d <= 4; d++) {
    var placeList = document.getElementById('places-' + d);
    var cards = placeList ? placeList.querySelectorAll('.place-card') : [];
    var isEmpty = cards.length === 0;

    html += '<div class="rp-da-item open" id="rpDa-' + d + '">';
    html += '<div class="rp-da-head" onclick="toggleDaItem(' + d + ')">';
    html += '<div class="rp-da-dot" style="background:' + dayColors[d-1] + '">D' + d + '</div>';
    html += '<span class="rp-da-date">' + dayDates[d-1] + '</span>';
    html += '<span class="rp-da-cnt' + (isEmpty ? ' empty' : '') + '">' + (isEmpty ? '없음' : cards.length + '개') + '</span>';
    html += '<span class="rp-da-arrow">▾</span>';
    html += '</div>';
    html += '<div class="rp-da-body">';
    if (isEmpty) {
      html += '<div class="rp-da-empty">아직 장소가 없어요</div>';
    } else {
      Array.prototype.forEach.call(cards, function(card, i) {
        var name = card.querySelector('.place-name') ? card.querySelector('.place-name').textContent : '';
        var badge = card.querySelector('.place-type-badge');
        var typeText = badge ? badge.textContent.trim() : '';
        html += '<div class="rp-da-place">';
        html += '<div class="rp-da-pnum" style="background:' + dayColors[d-1] + '">' + (i+1) + '</div>';
        html += '<span class="rp-da-pname">' + name + '</span>';
        if (typeText) html += '<span class="rp-da-pbadge">' + typeText + '</span>';
        html += '</div>';
      });
    }
    html += '</div></div>';
  }

  accordion.innerHTML = html;
}

function toggleDaItem(d) {
  var el = document.getElementById('rpDa-' + d);
  if (el) el.classList.toggle('open');
}

/* ══════════════════════════════
   카카오맵 초기화 (API 연동 시)
══════════════════════════════ */
// function initKakaoMap() {
//   var container = document.getElementById('kakaoMap');
//   var options = { center: new kakao.maps.LatLng(33.3617, 126.5292), level: 10 };
//   var map = new kakao.maps.Map(container, options);
//   // 마커 추가 로직 ...
// }
// window.onload = initKakaoMap;
