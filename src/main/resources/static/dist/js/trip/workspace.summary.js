/* ══════════════════════════════
   이모지 JS 렌더링
   (JSP 컴파일러의 4바이트 UTF-8 이모지 깨짐 방지)
══════════════════════════════ */
(function fixTripInfoIcons() {
  var TRIP_TYPE_ICONS = {
    'COUPLE'  : '💑',
    'FAMILY'  : '👨\u200D👩\u200D👧',
    'FRIENDS' : '🤝',
    'SOLO'    : '🧳',
    'BUSINESS': '💼'
  };

  function render() {
    // 여행 유형 아이콘
    var typeEl = document.getElementById('tInfoTypeIcon');
    if (typeEl && typeof TRIP_META !== 'undefined') {
      typeEl.textContent = TRIP_TYPE_ICONS[TRIP_META.tripType] || '✈️';
    }
    // 공개 여부 아이콘
    var pubEl = document.getElementById('tInfoPublicIcon');
    if (pubEl) {
      var chk = document.getElementById('editIsPublic');
      pubEl.textContent = (chk && chk.checked) ? '🌐' : '🔒';
    }
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', render);
  } else {
    render();
  }
})();

/* ══════════════════════════════
   일정 요약 렌더
══════════════════════════════ */
function renderDaySummary() {
  var accordion = document.getElementById('rpDayAccordion');
  if (!accordion) return;

  // DOM에서 실시간 카드 정보 읽기 (장소 추가/삭제 반영)
  var dayNums = (typeof KAKAO_DAY_NUMS !== 'undefined') ? KAKAO_DAY_NUMS : [];
  var colors  = (typeof DAY_COLORS !== 'undefined') ? DAY_COLORS
    : ['#FF6B6B', '#4ECDC4', '#45B7D1', '#FFA07A', '#98D8C8', '#F7DC6F', '#BB8FCE', '#82E0AA'];

  if (!dayNums.length) {
    accordion.innerHTML =
      '<div style="text-align:center;padding:32px 16px;color:#A0AEC0;">' +
      '<div style="font-size:32px;margin-bottom:8px;">📋</div>' +
      '<div style="font-size:13px;">아직 일정이 없어요</div></div>';
    return;
  }

  var html = '';
  dayNums.forEach(function(dayNum, idx) {
    var color = colors[(dayNum - 1) % colors.length];
    // DOM에서 해당 DAY 카드 직접 읽기
    var cards = Array.from(document.querySelectorAll('.place-card[data-day="' + dayNum + '"]'));

    // 날짜 표시: schedule 패널의 day-header에서 읽기
    var daySection = document.getElementById('day-' + dayNum);
    var dateEl = daySection ? daySection.querySelector('.day-date') : null;
    var dateStr = dateEl ? dateEl.textContent.trim() : ('DAY ' + dayNum);

    html += '<div class="rp-day-item">';
    html += '<div class="rp-day-item__head" onclick="toggleDaySummary(this)">';
    html +=   '<div class="rp-day-badge2" style="background:' + color + ';color:#fff;">' + dayNum + '</div>';
    html +=   '<div class="rp-day-item__title">DAY ' + dayNum + '</div>';
    html +=   '<div class="rp-day-item__date">' + dateStr + '</div>';
    html +=   '<div class="rp-day-item__count">' + cards.length + '개</div>';
    html +=   '<div class="rp-day-item__arrow">▾</div>';
    html += '</div>';
    html += '<div class="rp-day-item__body">';

    if (cards.length === 0) {
      html += '<div style="padding:12px 16px;font-size:12px;color:#A0AEC0;">장소가 없어요</div>';
    } else {
      cards.forEach(function(card, i) {
        var name     = card.getAttribute('data-name')     || '(이름 없음)';
        var memo     = card.getAttribute('data-memo')     || '';
        var cat      = card.getAttribute('data-category') || 'ETC';
        var itemId   = card.getAttribute('data-id')       || '';
        var imagesRaw = card.getAttribute('data-images')  || '[]';
        var imageUrls = [];
        try { imageUrls = JSON.parse(imagesRaw); } catch(e) {}
        var hasImg   = imageUrls.length > 0;
        var addr  = card.querySelector('.place-addr');
        var addrTxt = addr ? addr.textContent.trim() : '';
        var badge = _sumCatBadge(cat);

        html += '<div class="rp-place-row">';
        html +=   '<div class="rp-place-row__num" style="background:' + color + ';color:#fff;">' + (i+1) + '</div>';
        html +=   '<div class="rp-place-row__info">';
        html +=     '<div class="rp-place-row__name">' + _escSumm(name) + '</div>';
        if (addrTxt) html += '<div class="rp-place-row__addr">' + _escSumm(addrTxt) + '</div>';
        html +=     '<div style="display:flex;flex-wrap:wrap;gap:4px;margin-top:4px;">';
        html +=       '<span class="rp-place-row__cat">' + badge + '</span>';
        if (memo)   html += '<span class="place-chip memo" style="cursor:pointer" onclick="openMemoById(' + itemId + ')" title="메모 보기">📝 메모</span>';
        if (hasImg) html += '<span class="place-chip img"  style="cursor:pointer" onclick="openMemoById(' + itemId + ')" title="사진 보기">🖼 사진</span>';
        html +=     '</div>';
        html +=   '</div>';
        html += '</div>';
        // 이동 화살표 (마지막 제외)
        if (i < cards.length - 1) {
          html += '<div class="rp-place-arrow">↓</div>';
        }
      });
    }

    html += '</div></div>'; // body, item
  });

  accordion.innerHTML = html;
}

function toggleDaySummary(headEl) {
  var body = headEl.nextElementSibling;
  var arrow = headEl.querySelector('.rp-day-item__arrow');
  if (!body) return;
  var isOpen = body.classList.toggle('open');
  if (arrow) arrow.textContent = isOpen ? '▴' : '▾';
}

function _sumCatBadge(cat) {
  var m = {
    RESTAURANT:'🍽️ 식당', CAFE:'☕ 카페', TOUR:'🗺️ 관광지',
    ACCOMMODATION:'🏨 숙박', CULTURE:'🎭 문화', LEISURE:'🏄 레포츠',
    SHOPPING:'🛍️ 쇼핑', FESTIVAL:'🎉 축제', ETC:'📍 장소'
  };
  return m[(cat||'ETC').toUpperCase()] || '📍 장소';
}
function _escSumm(str) {
  if (!str) return '';
  return String(str).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;');
}

/* ══════════════════════════════
   탭 전환 시 자동 렌더
══════════════════════════════ */
(function() {
  var origSwitch = window.switchRpTab;
  window.switchRpTab = function(tab, btn) {
    if (typeof origSwitch === 'function') origSwitch(tab, btn);
    if (tab === 'summary') {
      setTimeout(renderDaySummary, 50);
    }
  };
})();

document.addEventListener('DOMContentLoaded', function() {
  // 초기 렌더 (탭이 이미 열려있는 경우 대비)
  var summaryPane = document.getElementById('rpPane-summary');
  if (summaryPane && summaryPane.classList.contains('active')) {
    renderDaySummary();
  }
});

/* ══════════════════════════════
   일정 변경 시 자동 업데이트
   schedule.js의 addPlaceToDay / removePlace / DnD 완료 후
   커스텀 이벤트 'tripan:schedule-changed'를 dispatch하면 자동 재렌더
══════════════════════════════ */
var _summaryUpdateTimer = null;

document.addEventListener('tripan:schedule-changed', function() {
  var summaryPane = document.getElementById('rpPane-summary');
  if (!summaryPane || !summaryPane.classList.contains('active')) return;
  // 디바운스 100ms (한 번에 여러 이벤트가 오는 경우 합치기)
  clearTimeout(_summaryUpdateTimer);
  _summaryUpdateTimer = setTimeout(renderDaySummary, 120);
});

// 외부에서 호출 가능한 유틸 함수
window.notifySummaryChanged = function() {
  document.dispatchEvent(new CustomEvent('tripan:schedule-changed'));
};

/* 요약 탭에서 메모/사진 뱃지 클릭 시 모달 오픈 */
window.openMemoById = function(itemId) {
  var card = document.querySelector('.place-card[data-id="' + itemId + '"]');
  if (!card) { showToast('⚠️ 일정 패널에서 장소를 찾을 수 없어요'); return; }
  var btn = card.querySelector('.place-action-btn[onclick*="openMemo"]');
  if (btn) btn.click();
};