/**
 * workspace.recommend.js  ★ v5 FINAL
 * ─────────────────────────────────────────────────────────────
 *
 * 수정 내역 (이번 버전):
 *
 * [BUG 1] PLACE_TYPE 중복 선언 → SyntaxError
 *   - 원인: recommend.js에서 `var PLACE_TYPE` 폴백 선언 후,
 *            JSP 마지막 <script> 블록의 `const PLACE_TYPE`이 재선언되어 충돌
 *   - 해결: recommend.js의 폴백을 window.PLACE_TYPE으로 변경
 *   - 추가 필요: workspace.jsp 994번 줄
 *       const PLACE_TYPE = { ... }
 *       → window.PLACE_TYPE = { ... }  (window 할당으로 교체)
 *
 * [BUG 2] 지도 → 일정 추가 시 아무것도 안 됨
 *   - 원인 1: addRecToDay()에서 addPlaceToDay(dayNumber, name, ...)로 호출
 *             → schedule.js 시그니처: addPlaceToDay(el, name, addr, lat, lng, apiPlaceId)
 *               el은 사용 안 하지만, 첫 번째 파라미터가 dayNumber면 name="name"이 됨
 *             → currentAddDay(schedule.js 전역)에 dayNumber 주입 후 null로 el 전달
 *   - 원인 2: openDayPicker()에서 팝업이 화면 밖에 숨어서 안 보임
 *             → position:fixed + 중앙 정렬로 강제 설정
 *   - 원인 3: map.js가 window._selectedRecPlace에 set하지만
 *             recommend.js에서 var _selectedRecPlace (로컬)로 별도 관리 → 동기화 안 됨
 *             → Object.defineProperty로 window._selectedRecPlace와 _selectedRecPlace 동기화
 *
 * [BUG 3] 이미지 안 나오는 문제
 *   - 원인: KTO areaBasedList2의 firstimage는 optional → 빈 문자열("")로 저장됨
 *           → PlaceMapper.xml WHERE 조건에 image_url != '' 없음
 *           → JS에서도 빈 문자열 체크 없이 그냥 '' img src로 넣음
 *   - 해결: PlaceMapper.xml에 image_url IS NOT NULL AND image_url != '' 조건 추가 (별도 파일)
 *           + JS에서도 빈 문자열 명시적 체크 후 placeholder 표시
 *
 * [BUG 4] 카테고리 필터 아무것도 안 뜸
 *   - 원인: filterRec()이 loadRecommendCards(category, city) 호출하는데
 *           내부에서 아무 에러 없이 동작하지만 결과가 0건인 경우:
 *           → DB에 해당 카테고리값('TOUR' 등)으로 저장된 데이터가 없거나
 *             KAKAO_CITIES 도시명과 실제 address 컬럼의 도시명이 불일치
 *   - 해결: 카테고리 'all'인 경우 category 조건 제거 확인 + 콘솔 로깅 추가
 *           + 검색 실패 시 토스트로 원인 표시
 *
 * [BUG 5] 무한스크롤 없음
 *   - 해결: IntersectionObserver + offset 파라미터 추가
 *           컨트롤러도 offset 지원하도록 별도 수정 필요 (TripPlaceApiController 수정본)
 *
 * ─────────────────────────────────────────────────────────────
 * workspace.jsp 수정 사항 (1줄만):
 *   994번 줄: const PLACE_TYPE = { OFFICIAL: 'OFFICIAL', CUSTOM: 'CUSTOM' };
 *   →         window.PLACE_TYPE = { OFFICIAL: 'OFFICIAL', CUSTOM: 'CUSTOM' };
 * ─────────────────────────────────────────────────────────────
 */

/* ══════════════════════════
   [BUG 1] PLACE_TYPE — window 할당 (const 충돌 방지)
══════════════════════════ */
if (typeof window.PLACE_TYPE === 'undefined') {
  window.PLACE_TYPE = { OFFICIAL: 'OFFICIAL', CUSTOM: 'CUSTOM' };
}

/* ══════════════════════════
   상태 변수
══════════════════════════ */
var _rpCategory  = 'all';
var _rpAllCards  = [];      // 전체 로드된 카드 (로컬 검색용)
var _rpOffset    = 0;       // 무한스크롤 현재 위치
var _rpLimit     = 12;      // 페이지당 건수
var _rpHasMore   = true;    // 다음 페이지 여부
var _rpLoading   = false;   // 중복 요청 방지

var _searchTimer    = null;
var _placeType      = 'all';
var _pendingRpCard  = null;  // 추천패널 + 버튼에서 선택한 장소

/* [BUG 2-3] map.js와 window._selectedRecPlace 완전 동기화
   map.js의 openDayPickerForMap()이 window._selectedRecPlace를 직접 set하므로
   로컬 _selectedRecPlace 대신 window._selectedRecPlace를 그대로 참조 */
window._selectedRecPlace = null;

/* ══════════════════════════
   1. 초기화
══════════════════════════ */
document.addEventListener('DOMContentLoaded', function () {
  var city = _getCityParam();
  loadRecommendCards('all', city, 0);
  _initInfiniteScroll();

  // dayPickerPopup 외부 클릭 닫기
  document.addEventListener('click', function (e) {
    var popup = document.getElementById('dayPickerPopup');
    if (!popup || popup.style.display === 'none') return;
    if (!popup.contains(e.target)) closeDayPicker();
  });
});

function _getCityParam() {
  return (typeof KAKAO_CITIES !== 'undefined' && KAKAO_CITIES.length > 0)
    ? KAKAO_CITIES.join(',') : '';
}

/* ══════════════════════════
   2. 추천 장소 로드 (offset 페이징)
══════════════════════════ */
function loadRecommendCards(category, city, offset) {
  if (_rpLoading) return;
  _rpLoading  = true;
  _rpCategory = category;

  var loading = document.getElementById('rpCardsLoading');
  var grid    = document.getElementById('rpCards');

  if (offset === 0) {
    // 첫 페이지: 기존 카드 전부 제거
    if (grid) Array.from(grid.querySelectorAll('.rp-card')).forEach(function (el) { el.remove(); });
    _rpAllCards = [];
    if (loading) loading.style.display = 'block';
  } else {
    // 추가 페이지: 로딩 스피너만 하단에 추가
    if (loading) loading.style.display = 'block';
  }

  var url = CTX_PATH + '/api/places/recommend'
    + '?category=' + encodeURIComponent(category)
    + '&city='     + encodeURIComponent(city || '')
    + '&limit='    + _rpLimit
    + '&offset='   + offset;

  console.log('[Recommend] 로드:', url);

  fetch(url)
    .then(function (r) { if (!r.ok) throw new Error('HTTP ' + r.status); return r.json(); })
    .then(function (data) {
      // ★ 컨트롤러가 List<PlaceDto> 배열로 반환 (현재 구버전) 또는
      //   { places, hasMore, total } 신버전 모두 처리
      var list, hasMore;
      if (Array.isArray(data)) {
        list    = data;
        hasMore = (list.length === _rpLimit); // 배열이면 개수로 추정
      } else {
        list    = data.places || [];
        hasMore = !!data.hasMore;
      }

      console.log('[Recommend] 응답:', list.length, '건, hasMore:', hasMore);

      _rpAllCards = _rpAllCards.concat(list);
      _rpOffset   = offset + list.length;
      _rpHasMore  = hasMore;

      _appendRpCards(list);
      if (loading) loading.style.display = 'none';

      var noResult = document.getElementById('rpNoResult');
      if (noResult) noResult.style.display = (_rpAllCards.length === 0 ? 'block' : 'none');

      _rpLoading = false;
    })
    .catch(function (err) {
      console.error('[Recommend] 로드 실패:', err);
      _rpLoading = false;
      if (offset === 0 && loading) {
        loading.innerHTML =
          '<div style="text-align:center;padding:20px;color:#A0AEC0;">' +
          '추천 장소를 불러오지 못했어요 😢<br><small style="color:#CBD5E0;">' + err.message + '</small></div>';
      }
    });
}

/* ── 카드 DOM 생성 & append ── */
function _appendRpCards(list) {
  var grid = document.getElementById('rpCards');
  if (!grid) return;

  list.forEach(function (p) {
    var card = document.createElement('div');
    card.className = 'rp-card';
    card.setAttribute('data-name',     p.placeName  || '');
    card.setAttribute('data-address',  p.address    || '');
    card.setAttribute('data-lat',      p.latitude   || 0);
    card.setAttribute('data-lng',      p.longitude  || 0);
    card.setAttribute('data-place-id', p.placeId    || '');
    card.setAttribute('data-category', p.category   || '');

    var bi  = _categoryBadgeInfo(p.category);
    var ph  = _categoryPlaceholder(p.category);

    // [BUG 3] 이미지 빈 문자열 명시적 체크
    var hasImg = p.imageUrl && p.imageUrl.trim() !== '';

    var imgHtml = hasImg
      ? '<img class="rp-card-thumb-img" src="' + _esc(p.imageUrl) + '" loading="lazy" '
          + 'onerror="this.onerror=null;this.parentElement.innerHTML='
          + "'<div style=\\'width:100%;height:130px;background:var(--bg,#F7FAFC);display:flex;"
          + "align-items:center;justify-content:center;font-size:32px;\\'>" + ph + "</div>'"
          + '">'
      : '<div style="width:100%;height:130px;background:var(--bg,#F7FAFC);display:flex;'
          + 'align-items:center;justify-content:center;font-size:32px;">' + ph + '</div>';

    card.innerHTML =
      '<div class="rp-card-img-wrap">' + imgHtml +
        '<span class="rp-card-cat-badge rp-badge ' + bi.color + '">' + bi.label + '</span>' +
      '</div>' +
      '<div class="rp-card-info">' +
        '<div class="rp-card-name">' + _esc(p.placeName || '') + '</div>' +
        '<div class="rp-card-addr">' + _esc(p.address   || '') + '</div>' +
        '<div class="rp-card-foot">' +
          '<button class="rp-add-btn" onclick="rpAddToDay(this);event.stopPropagation();">+ 추가</button>' +
        '</div>' +
      '</div>';

    card.addEventListener('click', function () { openPlaceDetailModal(p); });
    grid.appendChild(card);
  });
}

/* ── [BUG 5] 무한스크롤 IntersectionObserver ── */
function _initInfiniteScroll() {
  var pane = document.getElementById('rpPane-suggest') || document.getElementById('rpCards');
  if (!pane) return;

  var sentinel = document.getElementById('rpScrollSentinel');
  if (!sentinel) {
    sentinel = document.createElement('div');
    sentinel.id    = 'rpScrollSentinel';
    sentinel.style.cssText = 'height:4px;width:100%;';
    pane.appendChild(sentinel);
  }

  if (!window.IntersectionObserver) return; // 구형 브라우저 폴백 없음

  new IntersectionObserver(function (entries) {
    if (entries[0].isIntersecting && _rpHasMore && !_rpLoading) {
      loadRecommendCards(_rpCategory, _getCityParam(), _rpOffset);
    }
  }, { threshold: 0.1 }).observe(sentinel);
}

/* ── 로컬 검색 (이미 렌더된 카드 show/hide) ── */
function searchRpCards(keyword) {
  var kw    = keyword.trim();
  var clear = document.getElementById('rpSearchClear');
  if (clear) clear.style.display = kw ? 'block' : 'none';

  var grid = document.getElementById('rpCards');
  if (!grid) return;
  var upper = kw.toUpperCase();

  Array.from(grid.querySelectorAll('.rp-card')).forEach(function (c) {
    if (!kw) { c.style.display = ''; return; }
    var nm = (c.getAttribute('data-name')    || '').toUpperCase();
    var ad = (c.getAttribute('data-address') || '').toUpperCase();
    c.style.display = (nm.indexOf(upper) !== -1 || ad.indexOf(upper) !== -1) ? '' : 'none';
  });
}

function clearRpSearch() {
  var input = document.getElementById('rpSearchInput');
  if (input) { input.value = ''; searchRpCards(''); }
  var clear = document.getElementById('rpSearchClear');
  if (clear) clear.style.display = 'none';
}

/* ══════════════════════════
   3. 카테고리 필터 / 탭 전환
══════════════════════════ */

/** JSP: onclick="filterRec(this,'TOUR')" */
function filterRec(btn, category) {
  document.querySelectorAll('.rp-filter-btn').forEach(function (b) { b.classList.remove('active'); });
  btn.classList.add('active');

  // offset 초기화 후 서버 재요청
  _rpOffset  = 0;
  _rpHasMore = true;
  loadRecommendCards(category, _getCityParam(), 0);
}

/** JSP: onclick="switchRpTab('suggest',this)" */
function switchRpTab(tab, btn) {
  document.querySelectorAll('.rp-tab').forEach(function (b) { b.classList.remove('active'); });
  btn.classList.add('active');
  document.querySelectorAll('.rp-pane').forEach(function (el) { el.classList.remove('active'); });
  var t = document.getElementById('rpPane-' + tab);
  if (t) t.classList.add('active');
}

/* ══════════════════════════
   4. dayPickerPopup
══════════════════════════ */

/** 카드 "+ 추가" 버튼 */
function rpAddToDay(btn) {
  var card = btn.closest('.rp-card');
  if (!card) return;
  _pendingRpCard = {
    placeName : card.getAttribute('data-name'),
    address   : card.getAttribute('data-address'),
    latitude  : parseFloat(card.getAttribute('data-lat'))  || 0,
    longitude : parseFloat(card.getAttribute('data-lng'))  || 0,
    placeId   : card.getAttribute('data-place-id'),
    category  : card.getAttribute('data-category') || 'ETC'
  };
  openDayPicker();
}

/** dayPickerPopup 열기 (화면 중앙 고정) */
function openDayPicker() {
  var popup = document.getElementById('dayPickerPopup');
  if (!popup) {
    console.warn('[dayPicker] #dayPickerPopup 없음 — JSP 확인 필요');
    return;
  }
  // [BUG 2] position:fixed + 중앙 정렬로 강제 표시
  popup.style.cssText =
    'display:block !important;' +
    'position:fixed !important;' +
    'top:50% !important;' +
    'left:50% !important;' +
    'transform:translate(-50%,-50%) !important;' +
    'z-index:9999 !important;';
}

/** JSP 취소 버튼: onclick="closeDayPicker()" */
function closeDayPicker() {
  var popup = document.getElementById('dayPickerPopup');
  if (popup) popup.style.display = 'none';
  _pendingRpCard            = null;
  window._selectedRecPlace  = null;
}

/**
 * JSP dpp-btn: onclick="addRecToDay(${day.dayNumber})"
 *
 * [BUG 2] addPlaceToDay 시그니처 불일치 수정
 *   schedule.js 실제 시그니처: addPlaceToDay(el, name, addr, lat, lng, apiPlaceId)
 *   - el: 첫 번째 파라미터지만 함수 내부에서 사용 안 함 (null 전달 OK)
 *   - currentAddDay: schedule.js 전역 변수 → dayNumber 주입 필수
 */
function addRecToDay(dayNumber) {
  var p = _pendingRpCard || window._selectedRecPlace;
  if (!p) { closeDayPicker(); return; }

  var name    = p.placeName || p.name  || '';
  var address = p.address              || '';
  var lat     = p.latitude  || p.lat  || 0;
  var lng     = p.longitude || p.lng  || 0;
  var placeId = p.placeId              || null;

  // ★ schedule.js의 currentAddDay 전역에 dayNumber 주입
  if (typeof currentAddDay !== 'undefined') {
    currentAddDay = dayNumber;
  }

  if (typeof addPlaceToDay === 'function') {
    // schedule.js: addPlaceToDay(el, name, addr, lat, lng, apiPlaceId)
    // el은 null OK (함수 내부에서 currentAddDay를 사용하므로)
    var _addCat = (_pendingRpCard && _pendingRpCard.category) || (window._selectedRecPlace && window._selectedRecPlace.category) || 'ETC';
    addPlaceToDay(null, name, address, lat, lng, placeId, _addCat);
    if (typeof showToast === 'function') showToast('📍 DAY ' + dayNumber + '에 추가 중...');
  } else {
    if (typeof showToast === 'function')
      showToast('⚠️ 일정 추가 함수를 찾을 수 없어요 (workspace.schedule.js 확인)');
  }

  closeDayPicker();
}

/* ══════════════════════════
   5. 장소 상세 모달 (카드 클릭)
══════════════════════════ */
function openPlaceDetailModal(p) {
  var modal = document.getElementById('rpPlaceDetailModal');
  if (!modal) {
    modal = document.createElement('div');
    modal.id = 'rpPlaceDetailModal';
    modal.style.cssText =
      'position:fixed;top:0;left:0;width:100%;height:100%;z-index:2000;' +
      'display:flex;align-items:center;justify-content:center;' +
      'background:rgba(0,0,0,.5);backdrop-filter:blur(4px);';
    modal.addEventListener('click', function (e) {
      if (e.target === modal) closePlaceDetailModal();
    });
    document.body.appendChild(modal);
  }

  var bi  = _categoryBadgeInfo(p.category);
  var ph  = _categoryPlaceholder(p.category);
  var hasImg = p.imageUrl && p.imageUrl.trim() !== '';

  var imgSec = hasImg
    ? '<img src="' + _esc(p.imageUrl) + '" '
        + 'style="width:100%;height:200px;object-fit:cover;border-radius:20px 20px 0 0;display:block;" '
        + 'onerror="this.style.display=\'none\'">'
    : '<div style="width:100%;height:100px;background:var(--bg,#F7FAFC);border-radius:20px 20px 0 0;'
        + 'display:flex;align-items:center;justify-content:center;font-size:48px;">' + ph + '</div>';

  modal.innerHTML =
    '<div style="background:#fff;border-radius:20px;width:380px;max-width:92vw;' +
               'max-height:82vh;overflow-y:auto;box-shadow:0 24px 64px rgba(0,0,0,.22);">' +
      imgSec +
      '<div style="padding:20px 22px 24px;">' +
        '<div style="display:flex;align-items:center;justify-content:space-between;margin-bottom:12px;">' +
          '<span style="font-size:11px;font-weight:700;padding:3px 10px;border-radius:50px;' +
                       'background:rgba(137,207,240,.15);color:#5BABC9;">' + bi.label + '</span>' +
          '<button onclick="closePlaceDetailModal()" '
            + 'style="background:none;border:none;font-size:22px;cursor:pointer;color:#CBD5E0;line-height:1;">×</button>' +
        '</div>' +
        '<div style="font-size:18px;font-weight:800;color:#1A202C;margin-bottom:8px;line-height:1.3;">'
          + _esc(p.placeName || '') + '</div>' +
        (p.address     ? '<div style="font-size:12px;color:#718096;margin-bottom:8px;display:flex;gap:4px;"><span>📍</span><span>' + _esc(p.address) + '</span></div>' : '') +
        (p.phoneNumber ? '<div style="font-size:12px;color:#718096;margin-bottom:8px;">📞 ' + _esc(p.phoneNumber) + '</div>' : '') +
        (p.description
          ? '<div style="font-size:12px;color:#4A5568;line-height:1.75;margin-bottom:18px;' +
              'padding:12px;background:#F7FAFC;border-radius:12px;max-height:120px;overflow-y:auto;">' +
              _esc((p.description || '').substring(0, 300)) + (p.description.length > 300 ? '…' : '') +
            '</div>'
          : '') +
        '<button id="rpDetailAddBtn" '
          + 'style="width:100%;padding:14px;border:none;border-radius:14px;'
          + 'background:linear-gradient(135deg,#89CFF0,#B8A9D9);'
          + 'color:#fff;font-size:14px;font-weight:800;cursor:pointer;">+ 일정에 추가하기</button>' +
      '</div>' +
    '</div>';

  // 추가 버튼: 안전하게 addEventListener로 처리
  document.getElementById('rpDetailAddBtn').addEventListener('click', function () {
    _pendingRpCard = {
      placeName : p.placeName  || '',
      address   : p.address    || '',
      latitude  : p.latitude   || 0,
      longitude : p.longitude  || 0,
      placeId   : p.placeId    || null
    };
    closePlaceDetailModal();
    openDayPicker();
  });

  modal.style.display = 'flex';
}

function closePlaceDetailModal() {
  var modal = document.getElementById('rpPlaceDetailModal');
  if (modal) modal.style.display = 'none';
}

/* ══════════════════════════
   6. 장소 추가 모달 내 검색
══════════════════════════ */
function selectPlaceType(btn, type) {
  document.querySelectorAll('.place-type-tab').forEach(function (b) { b.classList.remove('active'); });
  btn.classList.add('active');
  _placeType = type;
  var kw = ((document.getElementById('placeSearchInput') || {}).value || '').trim();
  if (kw.length >= 2) searchPlace(kw);
  else _loadCategoryPreview(type);
}

function searchPlace(keyword) {
  clearTimeout(_searchTimer);
  if (!keyword || keyword.length < 2) {
    if (_placeType === 'my') loadMyPlaces(); else _loadCategoryPreview(_placeType);
    return;
  }
  var results = document.getElementById('placeResults');
  if (results) results.innerHTML =
    '<div style="text-align:center;padding:24px;color:#A0AEC0;">🔍 검색 중...</div>';

  _searchTimer = setTimeout(function () {
    if (_placeType === 'my') { loadMyPlaces(keyword); return; }

    fetch(CTX_PATH + '/api/places/search?keyword=' + encodeURIComponent(keyword))
      .then(function (r) { return r.json(); })
      .then(function (res) {
        // 구버전: List<TripPlaceDto> 배열 / 신버전: { officialPlaces, myPlaces }
        if (Array.isArray(res)) {
          renderSearchResults({ officialPlaces: [], myPlaces: res });
        } else {
          renderSearchResults(res);
        }
      })
      .catch(function () {
        var w = document.getElementById('placeResults');
        if (w) w.innerHTML = '<div style="text-align:center;padding:20px;color:#A0AEC0;">검색 실패 😢</div>';
      });
  }, 350);
}

function renderSearchResults(data) {
  var wrap = document.getElementById('placeResults');
  if (!wrap) return;
  wrap.innerHTML = '';
  // 센티넬 초기화 (무한스크롤용)
  _prObserver = null;

  var PT    = window.PLACE_TYPE || { OFFICIAL: 'OFFICIAL', CUSTOM: 'CUSTOM' };
  var hasOff = data.officialPlaces && data.officialPlaces.length > 0;
  var hasMy  = data.myPlaces       && data.myPlaces.length > 0;

  if (!hasOff && !hasMy) {
    wrap.innerHTML = '<div style="text-align:center;padding:32px;color:#A0AEC0;font-size:13px;">검색 결과가 없어요 😅</div>';
    return;
  }
  var html = '';
  if (hasOff) {
    data.officialPlaces.forEach(function (p) { html += _searchItemHtml(p, PT.OFFICIAL); });
  }
  if (hasMy) {
    if (hasOff) html += '<div style="height:1px;background:#F0F4F8;margin:4px 0;"></div>';
    html += '<div style="font-size:10px;font-weight:700;color:#9B8DBE;padding:8px 14px 2px;letter-spacing:.5px;">나의 저장 장소</div>';
    data.myPlaces.forEach(function (p) { html += _searchItemHtml(p, PT.CUSTOM); });
  }
  wrap.innerHTML = html;
  // 무한스크롤 sentinel 재등록
  setTimeout(_initPlaceResultsScroll, 50);
}

function _searchItemHtml(p, type) {
  var PT    = window.PLACE_TYPE || { OFFICIAL: 'OFFICIAL', CUSTOM: 'CUSTOM' };
  var isOff = (type === PT.OFFICIAL);
  // ★ 공식 배지 제거됨

  return '<div style="padding:11px 14px;border-bottom:1px solid #F0F4F8;cursor:pointer;background:'
    + (isOff ? 'rgba(137,207,240,.04)' : '#fff') + ';" '
    + 'data-name="'     + _esc(p.placeName || '') + '" '
    + 'data-address="'  + _esc(p.address   || '') + '" '
    + 'data-lat="'      + (p.latitude  || 0) + '" '
    + 'data-lng="'      + (p.longitude || 0) + '" '
    + 'data-place-id="' + _esc(String(p.placeId || '')) + '" '
    + 'data-category="' + _esc(p.category || p.categoryName || '') + '" '
    + 'onmouseover="this.style.background=\'#F7FAFC\'" '
    + 'onmouseout="this.style.background=\'#fff\'" '
    + 'onclick="selectPlaceResult(this)">'
    + '<div style="font-size:13px;font-weight:700;color:#1A202C;margin-bottom:3px;">'
    + (isOff ? '' : '⭐ ') + _esc(p.placeName || '')
    + _catLabel(p.category || p.categoryName || '')
    + '</div>'
    + '<div style="font-size:11px;color:#A0AEC0;">' + _esc(p.address || '') + '</div>'
    + '</div>';
}

/* ══════════════════════════
   7. 나만의 장소
══════════════════════════ */
function loadMyPlaces(keyword) {
  fetch(CTX_PATH + '/api/places/my')
    .then(function (r) { return r.json(); })
    .then(function (list) {
      if (!Array.isArray(list)) list = [];
      if (keyword) {
        var kw = keyword.toUpperCase();
        list = list.filter(function (p) {
          return (p.placeName || '').toUpperCase().indexOf(kw) !== -1 ||
                 (p.address   || '').toUpperCase().indexOf(kw) !== -1;
        });
      }
      renderMyPlaceResults(list);
    });
}

function renderMyPlaceResults(list) {
  var wrap = document.getElementById('placeResults');
  if (!wrap) return;
  var html = '<div style="padding:10px 14px;">'
    + '<button onclick="openRegisterMyPlaceForm()" '
    + 'style="width:100%;padding:10px;border:1.5px dashed #E2E8F0;border-radius:10px;'
    + 'background:none;font-size:13px;font-weight:700;color:#718096;cursor:pointer;font-family:inherit;">'
    + '+ 나만의 장소 직접 등록</button></div>';

  if (!list || !list.length) {
    html += '<div style="text-align:center;padding:20px;color:#A0AEC0;font-size:13px;">등록된 장소가 없어요</div>';
  } else {
    list.forEach(function (p) {
      html += '<div style="padding:11px 14px;border-bottom:1px solid #F0F4F8;cursor:pointer;" '
        + 'data-name="'     + _esc(p.placeName || '') + '" '
        + 'data-address="'  + _esc(p.address   || '') + '" '
        + 'data-lat="'      + (p.latitude  || 0) + '" '
        + 'data-lng="'      + (p.longitude || 0) + '" '
        + 'data-place-id="' + _esc(String(p.placeId || '')) + '" '
        + 'onmouseover="this.style.background=\'#F7FAFC\'" onmouseout="this.style.background=\'\'" '
        + 'onclick="selectPlaceResult(this)">'
        + '<div style="font-size:13px;font-weight:700;margin-bottom:2px;">⭐ ' + _esc(p.placeName || '') + '</div>'
        + '<div style="font-size:11px;color:#A0AEC0;">' + _esc(p.address || '') + '</div>'
        + '</div>';
    });
  }
  wrap.innerHTML = html;
}

function openRegisterMyPlaceForm() {
  var wrap = document.getElementById('placeResults');
  if (!wrap) return;
  wrap.innerHTML =
    '<div style="padding:16px;display:flex;flex-direction:column;gap:8px;">'
    + '<input id="myp-name" placeholder="장소명 *" style="padding:9px 12px;border:1.5px solid #E2E8F0;border-radius:10px;font-size:13px;font-family:inherit;outline:none;">'
    + '<input id="myp-address" placeholder="주소" style="padding:9px 12px;border:1.5px solid #E2E8F0;border-radius:10px;font-size:13px;font-family:inherit;outline:none;">'
    + '<div style="display:flex;gap:6px;">'
      + '<input id="myp-lat" type="number" placeholder="위도" style="flex:1;padding:9px 12px;border:1.5px solid #E2E8F0;border-radius:10px;font-size:13px;font-family:inherit;outline:none;">'
      + '<input id="myp-lng" type="number" placeholder="경도" style="flex:1;padding:9px 12px;border:1.5px solid #E2E8F0;border-radius:10px;font-size:13px;font-family:inherit;outline:none;">'
    + '</div>'
    + '<button onclick="submitRegisterMyPlace()" style="padding:11px;border:none;border-radius:10px;background:linear-gradient(135deg,#89CFF0,#B8A9D9);color:#fff;font-size:13px;font-weight:800;cursor:pointer;font-family:inherit;">등록</button>'
    + '<button onclick="loadMyPlaces()" style="padding:10px;border:none;border-radius:10px;background:#F7FAFC;font-size:12px;font-weight:700;color:#718096;cursor:pointer;font-family:inherit;">취소</button>'
    + '</div>';
}

function submitRegisterMyPlace() {
  var name    = (document.getElementById('myp-name')    || {}).value || '';
  var address = (document.getElementById('myp-address') || {}).value || '';
  var lat     = (document.getElementById('myp-lat')     || {}).value || '';
  var lng     = (document.getElementById('myp-lng')     || {}).value || '';
  if (!name.trim()) { alert('장소명은 필수입니다'); return; }
  fetch(CTX_PATH + '/api/places/my', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ placeName: name, address: address, latitude: lat, longitude: lng })
  })
  .then(function () { loadMyPlaces(); if (typeof showToast === 'function') showToast('📍 나만의 장소 등록 완료!'); })
  .catch(function () { alert('등록 실패'); });
}

/**
 * 검색 결과 클릭 → 일정에 추가
 * [BUG 2] schedule.js 시그니처: addPlaceToDay(el, name, addr, lat, lng, apiPlaceId)
 *   - currentAddDay는 openAddPlace(dayNumber)에서 이미 schedule.js가 set함
 *   - 따라서 여기선 null(el) + 파라미터 순서만 맞추면 됨
 */
function selectPlaceResult(el) {
  var name    = el.getAttribute('data-name');
  var address = el.getAttribute('data-address');
  var lat     = parseFloat(el.getAttribute('data-lat'));
  var lng     = parseFloat(el.getAttribute('data-lng'));
  var placeId = el.getAttribute('data-place-id');

  var _srCat = el.getAttribute('data-category') || 'ETC';
  if (typeof closeModal    === 'function') closeModal('addPlaceModal');
  if (typeof addPlaceToDay === 'function') addPlaceToDay(null, name, address, lat, lng, placeId, _srCat);
}

function openAddPlace(dayNumber) {
  var input = document.getElementById('placeSearchInput');
  if (input) { input.value = ''; }

  // ★ currentAddDay를 schedule.js와 공유
  if (typeof currentAddDay !== 'undefined') currentAddDay = dayNumber;

  // 탭 초기화
  document.querySelectorAll('.place-type-tab').forEach(function(b) { b.classList.remove('active'); });
  var allTab = document.querySelector('.place-type-tab[onclick*="all"]');
  if (allTab) allTab.classList.add('active');

  // 즉시 전체 카테고리 미리보기 로드
  _loadCategoryPreview('all');

  if (typeof openModal === 'function') openModal('addPlaceModal');
}

/* 장소 추가 모달 - 카테고리 프리뷰 + 무한스크롤 */
var _prOffset   = 0;
var _prLimit    = 20;
var _prCategory = 'all';
var _prLoading  = false;
var _prHasMore  = true;
var _prObserver = null;

function _loadCategoryPreview(category, reset) {
  if (reset !== false) {
    _prOffset   = 0;
    _prCategory = category;
    _prHasMore  = true;
    _prLoading  = false;
    // 결과 초기화
    var wrap = document.getElementById('placeResults');
    if (wrap) wrap.innerHTML = '<div style="text-align:center;padding:20px;color:#A0AEC0;">🔍 로드 중...</div>';
  }
  if (!_prHasMore || _prLoading) return;
  _prLoading = true;

  fetch(CTX_PATH + '/api/places/recommend?category='
    + encodeURIComponent(category || _prCategory)
    + '&city='    + encodeURIComponent(_getCityParam())
    + '&limit='   + _prLimit
    + '&offset='  + _prOffset)
    .then(function (r) { return r.json(); })
    .then(function (data) {
      var list    = Array.isArray(data) ? data : (data.places || []);
      var hasMore = Array.isArray(data) ? (list.length === _prLimit) : (data.hasMore !== false && list.length > 0);
      _prOffset  += list.length;
      _prHasMore  = hasMore;
      _prLoading  = false;

      if (_prOffset === list.length) {
        // 첫 페이지: 전체 렌더
        renderSearchResults({ officialPlaces: list, myPlaces: [] });
      } else {
        // 추가 페이지: append
        _appendSearchResults(list);
      }
      _initPlaceResultsScroll();
    })
    .catch(function() { _prLoading = false; });
}

function _appendSearchResults(list) {
  var wrap = document.getElementById('placeResults');
  if (!wrap) return;
  var PT = window.PLACE_TYPE || { OFFICIAL: 'OFFICIAL' };
  list.forEach(function(p) {
    wrap.insertAdjacentHTML('beforeend', _searchItemHtml(p, PT.OFFICIAL));
  });
}

function _initPlaceResultsScroll() {
  if (_prObserver) { _prObserver.disconnect(); _prObserver = null; }
  if (!window.IntersectionObserver) return;
  var wrap = document.getElementById('placeResults');
  if (!wrap) return;

  var sentinel = document.getElementById('placeResultsSentinel');
  if (!sentinel) {
    sentinel = document.createElement('div');
    sentinel.id = 'placeResultsSentinel';
    sentinel.style.cssText = 'height:4px;width:100%;';
    wrap.appendChild(sentinel);
  }

  _prObserver = new IntersectionObserver(function(entries) {
    if (entries[0].isIntersecting && _prHasMore && !_prLoading) {
      _loadCategoryPreview(_prCategory, false);
    }
  }, { root: wrap, threshold: 0.1 });
  _prObserver.observe(sentinel);
}

/* ══════════════════════════
   8. 유틸
══════════════════════════ */
function _esc(str) {
  if (!str) return '';
  return String(str)
    .replace(/&/g, '&amp;').replace(/</g, '&lt;')
    .replace(/>/g, '&gt;').replace(/"/g, '&quot;');
}
// 기존 코드 호환성 (일부 위치에서 _escHtml 사용)
var _escHtml = _esc;

function _categoryBadgeInfo(cat) {
  var m = {
    RESTAURANT:{label:'🍽 맛집',color:'pink'},   CAFE:{label:'☕ 카페',color:'blue'},
    TOUR:{label:'🏔 관광',color:'blue'},          ACCOMMODATION:{label:'🏨 숙박',color:'purple'},
    CULTURE:{label:'🎭 문화',color:'green'},       LEISURE:{label:'🏄 레포츠',color:'blue'},
    SHOPPING:{label:'🛍 쇼핑',color:'pink'},       FESTIVAL:{label:'🎉 축제',color:'pink'},
    ETC:{label:'📍 장소',color:'blue'}
  };
  return m[cat] || {label:'📍 장소',color:'blue'};
}

function _categoryPlaceholder(cat) {
  var m = {
    RESTAURANT:'🍽', CAFE:'☕', TOUR:'🏔', ACCOMMODATION:'🏨',
    CULTURE:'🎭', LEISURE:'🏄', SHOPPING:'🛍', FESTIVAL:'🎉'
  };
  return m[cat] || '📍';
}

function _categoryMiniLabel(cat) {
  var m = {
    RESTAURANT:'식당', CAFE:'카페', TOUR:'관광지',
    ACCOMMODATION:'숙박', CULTURE:'문화', LEISURE:'레포츠',
    SHOPPING:'쇼핑', FESTIVAL:'축제'
  };
  return m[(cat||'').toUpperCase()] || '';
}

function _catLabel(cat) {
  if (!cat) return '';
  var m = {
    RESTAURANT:'🍽️ 식당', CAFE:'☕ 카페',         TOUR:'🏔️ 관광지',
    ACCOMMODATION:'🏨 숙박', CULTURE:'🎭 문화',    LEISURE:'🏄 레포츠',
    SHOPPING:'🛍️ 쇼핑',   FESTIVAL:'🎉 축제',     ETC:''
  };
  var label = m[(cat||'').toUpperCase()];
  if (!label) return '';
  return ' <span style="font-size:10px;font-weight:600;padding:1px 6px;border-radius:50px;background:#F0F4F8;color:#718096;vertical-align:middle;">' + label + '</span>';
}
