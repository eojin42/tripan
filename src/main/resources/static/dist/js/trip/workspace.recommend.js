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

var _rpSearchTimer = null;

function searchRpCards(keyword) {
  var kw = keyword.trim();
  var clear = document.getElementById('rpSearchClear');
  if (clear) clear.style.display = kw ? 'block' : 'none';

  clearTimeout(_rpSearchTimer);

  if (!kw) {
    // 검색어가 없으면 원래 추천 리스트 다시 로드
    _rpOffset = 0;
    _rpHasMore = true;
    loadRecommendCards(_rpCategory, _getCityParam(), 0);
    return;
  }

  var grid = document.getElementById('rpCards');
  if (grid) grid.innerHTML = '<div style="text-align:center;padding:32px;color:#A0AEC0;"><div style="font-size:32px;margin-bottom:8px;">🔍</div><div>검색 중...</div></div>';

  _rpSearchTimer = setTimeout(function() {
    // ★ 현재 선택된 카테고리를 쿼리에 포함 → 지역 검색 시에도 카테고리 필터 작동
    var catParam = (_rpCategory && _rpCategory !== 'all') ? _rpCategory : '';
    var url = CTX_PATH + '/api/places/search?keyword=' + encodeURIComponent(kw)
      + (catParam ? '&category=' + encodeURIComponent(catParam) : '');

    fetch(url)
      .then(function(r) { return r.json(); })
      .then(function(res) {
         var list = Array.isArray(res) ? res : (res.officialPlaces || []);

         // ★ 클라이언트 2차 필터 — 서버가 category를 무시했을 경우 안전망
         if (catParam) {
           // DB category 값 매핑 (필터 버튼 value → DB 저장값)
           var catMap = {
             'RESTAURANT':    ['RESTAURANT','FOOD','FD6','음식점','식당','맛집'],
             'ACCOMMODATION': ['ACCOMMODATION','HOTEL','STAY','숙박','숙소'],
             'TOUR':          ['TOUR','ATTRACTION','TRAVEL','관광','여행','명소'],
             'CULTURE':       ['CULTURE','CT1','문화시설','문화','공연','전시'],
             'LEISURE':       ['LEISURE','SPORTS','CE7','레포츠','스포츠','레저'],
             'SHOPPING':      ['SHOPPING','MT1','마트','쇼핑']
           };
           var accepts = catMap[catParam] || [catParam];
           list = list.filter(function(p) {
             var c = (p.category || p.categoryName || '').toUpperCase();
             return accepts.some(function(v) { return c.includes(v.toUpperCase()); });
           });
         }

         // 여행지 도시 주소 우선 정렬
         if (typeof KAKAO_CITIES !== 'undefined' && KAKAO_CITIES.length > 0) {
           list.sort(function(a, b) {
             var aMatch = KAKAO_CITIES.some(function(city) { return (a.address || '').includes(city); });
             var bMatch = KAKAO_CITIES.some(function(city) { return (b.address || '').includes(city); });
             if (aMatch && !bMatch) return -1;
             if (!aMatch && bMatch) return 1;
             return 0;
           });
         }

         if (grid) grid.innerHTML = '';
         _rpHasMore = false; // 검색 상태에선 무한 스크롤 중지

         var noResult = document.getElementById('rpNoResult');
         if (list.length === 0) {
           if (noResult) noResult.style.display = 'block';
         } else {
           if (noResult) noResult.style.display = 'none';
           _appendRpCards(list);
         }
      })
      .catch(function() {
         if (grid) grid.innerHTML = '<div style="text-align:center;padding:32px;color:#A0AEC0;">검색 실패 😢</div>';
      });
  }, 350);
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

  _rpCategory = category; // ★ 카테고리 상태 먼저 업데이트

  // 검색어가 있으면 → 현재 검색어로 재검색 (카테고리 필터 반영)
  var inp = document.getElementById('rpSearchInput');
  var kw = inp ? inp.value.trim() : '';
  if (kw) {
    searchRpCards(kw);
    return;
  }

  // 검색어 없으면 → 카테고리별 추천 로드
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

  // ★ 추천 장소 탭일 때만 검색바 표시
  var searchbar = document.getElementById('rpSearchbar');
  if (searchbar) {
    searchbar.style.display = (tab === 'suggest') ? '' : 'none';
  }

  // 탭 전환 시 검색어 초기화
  if (tab !== 'suggest') {
    var inp = document.getElementById('rpSearchInput');
    if (inp && inp.value) { inp.value = ''; searchRpCards(''); }
  }
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
              'padding:12px;background:#F7FAFC;border-radius:12px;max-height:160px;overflow-y:auto;">' +
              _esc(p.description || '') +
            '</div>'
          : '') +
        '<button id="rpDetailAddBtn" '
          + 'style="width:100%;padding:14px;border:none;border-radius:14px;'
          + 'background:linear-gradient(135deg,#89CFF0,#B8A9D9);'
          + 'color:#fff;font-size:14px;font-weight:800;cursor:pointer;">+ 일정에 추가하기</button>' +
      '</div>' +
    '</div>';

	// 추가 버튼: 안전하게 addEventListener로 처리
	  document.getElementById('rpDetailAddBtn').addEventListener('click', function (e) {
	    e.stopPropagation(); 
	    _pendingRpCard = {
	      placeName : p.placeName  || '',
	      address   : p.address    || '',
	      latitude  : p.latitude   || 0,
	      longitude : p.longitude  || 0,
	      placeId   : p.placeId    || null,
	      category  : p.category   || 'ETC' 
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
  if (kw.length >= 2) {
    searchPlace(kw);
  } else {
    _loadCategoryPreview(type);
  }
}
function searchPlace(keyword) {
  clearTimeout(_searchTimer);
  if (!keyword || keyword.length < 2) {
    _loadCategoryPreview(_placeType);
    return;
  }
  var results = document.getElementById('placeResults');
  if (results) results.innerHTML = '<div style="text-align:center;padding:24px;color:#A0AEC0;">🔍 검색 중...</div>';

  _searchTimer = setTimeout(function () {
    // ✅ 버그 수정: category 파라미터 추가 → 서버에서 1차 필터
    var catParam = (_placeType && _placeType !== 'all') ? _placeType : '';
    fetch(CTX_PATH + '/api/places/search?keyword=' + encodeURIComponent(keyword)
          + (catParam ? '&category=' + encodeURIComponent(catParam) : ''))
      .then(function (r) { return r.json(); })
      .then(function (res) {
        
        // ★ 여행지 우선 정렬 함수
        var sortFn = function(a, b) {
            var aMatch = KAKAO_CITIES.some(function(c) { return (a.address || '').includes(c); });
            var bMatch = KAKAO_CITIES.some(function(c) { return (b.address || '').includes(c); });
            if (aMatch && !bMatch) return -1;
            if (!aMatch && bMatch) return 1;
            return 0;
        };

        // ✅ 버그 수정: 클라이언트 2차 필터 (서버가 category를 지원 안 해도 안전)
        var filterByCat = function(list) {
          if (!catParam || !list) return list;
          // DB category값 매핑 (탭 value → DB 저장값)
          var catMap = {
            'RESTAURANT':    ['RESTAURANT','음식점','맛집'],
            'ACCOMMODATION': ['ACCOMMODATION','STAY','숙박','숙소'],
            'TOUR':          ['TOUR','관광','ATTRACTION'],
            'CULTURE':       ['CULTURE','문화'],
            'LEISURE':       ['LEISURE','레포츠'],
            'SHOPPING':      ['SHOPPING','쇼핑'],
          };
          var allowed = catMap[catParam] || [catParam];
          return list.filter(function(p) {
            var c = (p.category || p.categoryName || '').toUpperCase();
            return allowed.some(function(a) { return c.includes(a.toUpperCase()); });
          });
        };

        if (Array.isArray(res)) {
          var filtered = filterByCat(res);
          filtered.sort(sortFn);
          renderSearchResults({ officialPlaces: [], myPlaces: filtered });
        } else {
          if (res.officialPlaces) { res.officialPlaces = filterByCat(res.officialPlaces); res.officialPlaces.sort(sortFn); }
          if (res.myPlaces)       { res.myPlaces       = filterByCat(res.myPlaces);       res.myPlaces.sort(sortFn); }
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
  var wrap = document.getElementById('myPlaceResults');
  if (wrap) wrap.innerHTML =
    '<div style="text-align:center;padding:32px;color:#A0AEC0;font-size:13px;">' +
    '<div style="font-size:28px;margin-bottom:8px;">⭐</div>불러오는 중...</div>';

  fetch(CTX_PATH + '/api/places/my')
    .then(function(r) { return r.json(); })
    .then(function(list) {
      if (!Array.isArray(list)) list = [];

      // 나만의 장소만 필터링
      var myOnly = list.filter(function(p) {
        var api = String(p.apiContentId || p.apiPlaceId || p.api_place_id || '');
        var cat = String(p.category || p.categoryName || '').toUpperCase();
        return api.startsWith('custom_') || cat === 'NONE' || cat === '' || p.memberId != null;
      });

      if (keyword) {
        var kw = keyword.toUpperCase();
        myOnly = myOnly.filter(function(p) {
          return (p.placeName || '').toUpperCase().indexOf(kw) !== -1 ||
                 (p.address   || '').toUpperCase().indexOf(kw) !== -1;
        });
      }

      renderMyPlaceResults(myOnly);
    })
    .catch(function() { renderMyPlaceResults([]); });
}

/** 현재 일정 DOM의 place-card 중 NONE 카테고리(나만의 장소) 수집 */
function _collectNoneCategoryFromDom() {
  var result = [];
  document.querySelectorAll('.place-card').forEach(function(card) {
    var cat = card.getAttribute('data-category') || '';
    // NONE 이거나 카테고리가 아예 없는 카드 (카카오 지도로 추가된 장소)
    if (cat === 'NONE' || cat === '') {
      var name = card.getAttribute('data-name') || '';
      if (!name) return;
      result.push({
        placeName : name,
        address   : card.getAttribute('data-address') || '',
        latitude  : parseFloat(card.getAttribute('data-lat'))  || 0,
        longitude : parseFloat(card.getAttribute('data-lng'))  || 0,
        placeId   : card.getAttribute('data-id') || null,
        category  : 'NONE'
      });
    }
  });
  return result;
}

function renderMyPlaceResults(list) {
  var wrap = document.getElementById('myPlaceResults');
  if (!wrap) return;

  var html =
    '<div style="padding:10px 14px 8px;">' +
      '<button onclick="openRegisterMyPlaceForm()" ' +
        'style="width:100%;padding:12px 16px;' +
        'border:1.5px dashed rgba(137,207,240,.6);border-radius:12px;' +
        'background:linear-gradient(135deg,rgba(137,207,240,.07),rgba(194,184,217,.07));' +
        'font-size:13px;font-weight:700;color:#5A8DBE;cursor:pointer;font-family:inherit;' +
        'display:flex;align-items:center;justify-content:center;gap:7px;transition:all .2s;" ' +
        'onmouseover="this.style.background=\'rgba(137,207,240,.18)\';this.style.borderStyle=\'solid\'" ' +
        'onmouseout="this.style.background=\'linear-gradient(135deg,rgba(137,207,240,.07),rgba(194,184,217,.07))\';this.style.borderStyle=\'dashed\'">' +
        ' + 나만의 장소 직접 등록' +
      '</button>' +
    '</div>';

  if (!list || !list.length) {
    html +=
      '<div style="text-align:center;padding:32px 20px;">' +
        '<div style="font-size:40px;margin-bottom:12px;">⭐</div>' +
        '<div style="font-size:14px;font-weight:800;color:#4A5568;margin-bottom:6px;">등록된 나만의 장소가 없어요</div>' +
        '<div style="font-size:12px;color:#A0AEC0;line-height:1.8;">' +
          '위 버튼으로 직접 등록하거나<br>카카오 지도 검색 후 추가하세요' +
        '</div>' +
      '</div>';
  } else {
    list.forEach(function(p) {
      var name = p.placeName || '';
      var addr = p.address   || '';
      var lat  = p.latitude  || 0;
      var lng  = p.longitude || 0;
      var pid  = p.placeId   || p.tripPlaceId || '';

      html +=
        '<div style="display:flex;align-items:center;' +
          'border-bottom:1px solid #F0F4F8;transition:background .12s;" ' +
          'onmouseover="this.style.background=\'#F7FAFC\'" ' +
          'onmouseout="this.style.background=\'\'">' +

          /* 클릭 영역 (일정 추가) */
          '<div style="flex:1;min-width:0;padding:11px 14px;cursor:pointer;' +
            'display:flex;align-items:center;gap:10px;" ' +
            'data-name="'     + _esc(name)       + '" ' +
            'data-address="'  + _esc(addr)        + '" ' +
            'data-lat="'      + lat               + '" ' +
            'data-lng="'      + lng               + '" ' +
            'data-place-id="' + _esc(String(pid)) + '" ' +
            'data-category="NONE" ' +
            'onclick="selectPlaceResult(this)">' +

            '<div style="width:36px;height:36px;border-radius:10px;flex-shrink:0;' +
              'background:linear-gradient(135deg,rgba(137,207,240,.2),rgba(194,184,217,.2));' +
              'display:flex;align-items:center;justify-content:center;font-size:18px;">⭐</div>' +

            '<div style="min-width:0;flex:1;">' +
              '<div style="font-size:13px;font-weight:700;color:#1A202C;margin-bottom:2px;' +
                'white-space:nowrap;overflow:hidden;text-overflow:ellipsis;">' + _esc(name) + '</div>' +
              '<div style="font-size:11px;color:#A0AEC0;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;">' +
                (addr || '주소 없음') +
              '</div>' +
            '</div>' +

            '<span style="font-size:10px;font-weight:800;padding:3px 10px;border-radius:20px;flex-shrink:0;margin-right:4px;' +
              'background:linear-gradient(120deg,rgba(168,200,225,.22),rgba(194,184,217,.22));' +
              'border:1px solid rgba(194,184,217,.55);color:#5A4E8C;">나만의</span>' +
          '</div>' +

          /* 삭제 버튼 */
          (pid ?
            '<button onclick="deleteMyPlace(' + pid + ',this);event.stopPropagation();" ' +
              'style="width:30px;height:30px;border:1px solid #FED7D7;border-radius:8px;' +
              'background:#FFF5F5;color:#E53E3E;cursor:pointer;flex-shrink:0;margin-right:10px;' +
              'display:flex;align-items:center;justify-content:center;font-size:14px;' +
              'transition:all .15s;" ' +
              'onmouseover="this.style.background=\'#FED7D7\';this.style.borderColor=\'#FC8181\'" ' +
              'onmouseout="this.style.background=\'#FFF5F5\';this.style.borderColor=\'#FED7D7\'" ' +
              'title="삭제">🗑</button>'
          : '') +
        '</div>';
    });
  }

  wrap.innerHTML = html;
}





/* ══════════════════════════════════════════
   나만의 장소 등록 모달
   - 주소 검색 + 지도 클릭 두 가지 방법
   - 위도/경도 숨김 (내부 저장용)
   - 지도 초기 중심 = 현재 여행지 (KAKAO_CITIES 기준)
══════════════════════════════════════════ */
function openRegisterMyPlaceForm() {
  var old = document.getElementById('customPlaceRegModal');
  if (old) { old.remove(); return; }

  var modalHtml =
    '<div id="customPlaceRegModal" ' +
      'style="position:fixed;top:0;left:0;width:100%;height:100%;' +
      'background:rgba(0,0,0,.6);z-index:10000;' +
      'display:flex;align-items:center;justify-content:center;' +
      'font-family:\'Pretendard Variable\',Pretendard,sans-serif;">' +

      /* ── 모달 박스 (600px, 큰 지도) ── */
      '<div style="background:#fff;border-radius:22px;' +
        'width:min(640px,97vw);max-height:95vh;overflow:hidden;' +
        'display:flex;flex-direction:column;' +
        'box-shadow:0 28px 80px rgba(0,0,0,.28);">' +

        /* ─ 헤더 ─ */
        '<div style="display:flex;align-items:center;justify-content:space-between;' +
          'padding:20px 26px 16px;flex-shrink:0;border-bottom:1px solid #EDF2F7;">' +
          '<div>' +
            '<div style="font-size:17px;font-weight:900;color:#1A202C;' +
              'display:flex;align-items:center;gap:8px;">' +
              '<span style="display:inline-flex;align-items:center;justify-content:center;' +
                'width:32px;height:32px;border-radius:10px;font-size:16px;' +
                'background:linear-gradient(135deg,rgba(137,207,240,.25),rgba(194,184,217,.25));">📍</span>' +
              '나만의 장소 등록' +
            '</div>' +
            '<div style="font-size:12px;color:#A0AEC0;margin-top:4px;padding-left:40px;">' +
              '주소를 검색하거나 지도를 클릭해서 위치를 선택하세요' +
            '</div>' +
          '</div>' +
          '<button ' +
            'onclick="document.getElementById(\'customPlaceRegModal\').remove();' +
            'window._customRegMap=null;window._customRegPlaceFunc=null;" ' +
            'style="width:32px;height:32px;border:1.5px solid #E2E8F0;background:#F7FAFC;' +
            'border-radius:9px;cursor:pointer;font-size:15px;color:#718096;' +
            'display:flex;align-items:center;justify-content:center;flex-shrink:0;' +
            'transition:all .15s;" ' +
            'onmouseover="this.style.background=\'#EDF2F7\'" ' +
            'onmouseout="this.style.background=\'#F7FAFC\'">✕</button>' +
        '</div>' +

        /* ─ 주소 검색바 ─ */
        '<div style="padding:14px 26px 0;flex-shrink:0;">' +
          '<div style="display:flex;gap:9px;">' +
            '<div style="flex:1;position:relative;">' +
              '<input id="customPlaceAddrSearch" ' +
                'placeholder="장소명 또는 주소로 검색…" ' +
                'style="width:100%;padding:11px 14px 11px 40px;' +
                'border:1.5px solid #E2E8F0;border-radius:11px;' +
                'font-size:13px;font-family:inherit;outline:none;box-sizing:border-box;' +
                'transition:border-color .15s,box-shadow .15s;" ' +
                'onfocus="this.style.borderColor=\'#89CFF0\';this.style.boxShadow=\'0 0 0 3px rgba(137,207,240,.14)\'" ' +
                'onblur="this.style.borderColor=\'#E2E8F0\';this.style.boxShadow=\'none\'" ' +
                'onkeydown="if(event.key===\'Enter\')searchCustomPlaceAddr()">' +
              '<svg style="position:absolute;left:13px;top:50%;transform:translateY(-50%);' +
                'color:#A0AEC0;pointer-events:none;" ' +
                'width="15" height="15" viewBox="0 0 24 24" fill="none" ' +
                'stroke="currentColor" stroke-width="2.5" stroke-linecap="round">' +
                '<circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/>' +
              '</svg>' +
            '</div>' +
            '<button onclick="searchCustomPlaceAddr()" ' +
              'style="padding:11px 20px;border:none;border-radius:11px;' +
              'background:linear-gradient(120deg,#89CFF0,#C2B8D9);' +
              'color:#fff;font-size:13px;font-weight:700;cursor:pointer;' +
              'white-space:nowrap;flex-shrink:0;' +
              'box-shadow:0 3px 12px rgba(137,207,240,.35);transition:opacity .15s;" ' +
              'onmouseover="this.style.opacity=\'.85\'" ' +
              'onmouseout="this.style.opacity=\'1\'">검색</button>' +
          '</div>' +
          /* 검색 드롭다운 */
          '<div id="customPlaceAddrResults" ' +
            'style="display:none;max-height:180px;overflow-y:auto;' +
            'border:1.5px solid #E2E8F0;border-radius:11px;margin-top:5px;background:#fff;' +
            'box-shadow:0 8px 24px rgba(0,0,0,.1);position:relative;z-index:1;"></div>' +
        '</div>' +

        /* ─ 지도 (높이 320px) ─ */
        '<div id="customPlaceRegMap" ' +
          'style="width:100%;height:320px;background:#EDF2F7;flex-shrink:0;' +
          'position:relative;margin-top:12px;">' +
          '<div style="position:absolute;inset:0;display:flex;align-items:center;' +
            'justify-content:center;flex-direction:column;gap:8px;color:#A0AEC0;">' +
            '<div style="font-size:32px;">🗺️</div>' +
            '<div style="font-size:13px;font-weight:600;">지도 로딩 중...</div>' +
          '</div>' +
        '</div>' +
        '<div style="padding:6px 26px 10px;font-size:11px;font-weight:700;' +
          'background:linear-gradient(135deg,#EBF8FF,#EDE7F6);color:#2B6CB0;flex-shrink:0;">' +
          '🖱️ 지도를 클릭하면 마커가 이동하고 주소가 자동으로 입력돼요' +
        '</div>' +

        /* ─ 폼 영역 ─ */
        '<div style="padding:16px 26px 22px;display:flex;flex-direction:column;' +
          'gap:12px;overflow-y:auto;flex-shrink:0;">' +

          /* 선택된 주소 */
          '<div>' +
            '<label style="font-size:11px;font-weight:800;color:#9B8DBE;' +
              'letter-spacing:.6px;text-transform:uppercase;display:block;margin-bottom:5px;">' +
              '선택된 주소' +
            '</label>' +
            '<div style="position:relative;">' +
              '<input id="customPlaceRegAddr" readonly ' +
                'placeholder="검색하거나 지도를 클릭하면 자동 입력돼요" ' +
                'style="width:100%;padding:10px 14px 10px 38px;' +
                'border:1.5px solid #EDF2F7;border-radius:11px;' +
                'font-size:13px;font-family:inherit;outline:none;' +
                'background:#F7FAFC;box-sizing:border-box;color:#4A5568;">' +
              '<svg style="position:absolute;left:12px;top:50%;transform:translateY(-50%);color:#C2B8D9;" ' +
                'width="14" height="14" viewBox="0 0 24 24" fill="none" ' +
                'stroke="currentColor" stroke-width="2.5" stroke-linecap="round">' +
                '<path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z"/>' +
                '<circle cx="12" cy="10" r="3"/>' +
              '</svg>' +
            '</div>' +
          '</div>' +

          /* 장소명 */
          '<div>' +
            '<label style="font-size:11px;font-weight:800;color:#9B8DBE;' +
              'letter-spacing:.6px;text-transform:uppercase;display:block;margin-bottom:5px;">' +
              '장소명 <span style="color:#FC8181;text-transform:none;letter-spacing:0;font-weight:600;">*</span>' +
            '</label>' +
            '<input id="customPlaceRegName" ' +
              'placeholder="예: 우리 동네 공원, 단골 카페" maxlength="100" ' +
              'style="width:100%;padding:11px 14px;border:1.5px solid #E2E8F0;border-radius:11px;' +
              'font-size:13px;font-family:inherit;outline:none;box-sizing:border-box;' +
              'transition:border-color .15s,box-shadow .15s;" ' +
              'onfocus="this.style.borderColor=\'#89CFF0\';this.style.boxShadow=\'0 0 0 3px rgba(137,207,240,.14)\'" ' +
              'onblur="this.style.borderColor=\'#E2E8F0\';this.style.boxShadow=\'none\'">' +
          '</div>' +

          /* 숨김 필드 */
          '<input id="customPlaceRegLat" type="hidden">' +
          '<input id="customPlaceRegLng" type="hidden">' +

          /* 버튼 */
          '<div style="display:flex;gap:10px;margin-top:2px;">' +
            '<button ' +
              'onclick="document.getElementById(\'customPlaceRegModal\').remove();' +
              'window._customRegMap=null;window._customRegPlaceFunc=null;" ' +
              'style="flex:1;padding:13px;border:1.5px solid #E2E8F0;border-radius:12px;' +
              'background:#fff;color:#718096;font-size:13px;font-weight:700;cursor:pointer;' +
              'font-family:inherit;transition:all .15s;" ' +
              'onmouseover="this.style.background=\'#F7FAFC\'" ' +
              'onmouseout="this.style.background=\'#fff\'">취소</button>' +
            '<button id="customPlaceRegSubmitBtn" onclick="submitCustomPlaceReg()" ' +
              'style="flex:2.5;padding:13px;border:none;border-radius:12px;' +
              'background:linear-gradient(120deg,#89CFF0 0%,#C2B8D9 50%,#FFB6C1 100%);' +
              'color:#fff;font-size:14px;font-weight:800;cursor:pointer;font-family:inherit;' +
              'box-shadow:0 5px 18px rgba(137,207,240,.4);transition:opacity .15s;" ' +
              'onmouseover="this.style.opacity=\'.87\'" ' +
              'onmouseout="this.style.opacity=\'1\'">📍 등록하기</button>' +
          '</div>' +

        '</div>' +
      '</div>' +
    '</div>';

  document.body.insertAdjacentHTML('beforeend', modalHtml);

  /* ─ 카카오맵 초기화 ─ */
  kakao.maps.load(function() {
    var container = document.getElementById('customPlaceRegMap');
    if (!container) return;

    var CITY_COORDS  = (typeof _CITY_COORDS !== 'undefined') ? _CITY_COORDS : {};
    var DEFAULT_COORD = { lat: 36.5, lng: 127.5, level: 10 };
    var cities = (typeof KAKAO_CITIES !== 'undefined' && KAKAO_CITIES.length > 0) ? KAKAO_CITIES : [];
    var center = (cities.length > 0 && CITY_COORDS[cities[0]]) ? CITY_COORDS[cities[0]] : DEFAULT_COORD;

    var regMap = new kakao.maps.Map(container, {
      center: new kakao.maps.LatLng(center.lat, center.lng),
      level: center.level || 8
    });
    var regGeocoder = new kakao.maps.services.Geocoder();
    var regMarker   = null;

    function placeMarkerAndFill(latlng) {
      if (!regMarker) {
        regMarker = new kakao.maps.Marker({ position: latlng, map: regMap });
      } else {
        regMarker.setPosition(latlng);
      }
      regMap.panTo(latlng);

      var lat = latlng.getLat(), lng = latlng.getLng();
      var latEl = document.getElementById('customPlaceRegLat');
      var lngEl = document.getElementById('customPlaceRegLng');
      if (latEl) latEl.value = lat.toFixed(8);
      if (lngEl) lngEl.value = lng.toFixed(8);

      regGeocoder.coord2Address(lng, lat, function(result, status) {
        if (status === kakao.maps.services.Status.OK) {
          var addrEl = document.getElementById('customPlaceRegAddr');
          if (addrEl) {
            var road  = result[0].road_address;
            var jibun = result[0].address;
            addrEl.value = road ? road.address_name : (jibun ? jibun.address_name : '');
          }
        }
      });
    }

    kakao.maps.event.addListener(regMap, 'click', function(mouseEvent) {
      placeMarkerAndFill(mouseEvent.latLng);
    });

    window._customRegMap       = regMap;
    window._customRegGeocoder  = regGeocoder;
    window._customRegPlaceFunc = placeMarkerAndFill;
  });
}


/* ══════════════════════════════════════════
   주소 검색 (카카오 키워드 검색)
══════════════════════════════════════════ */
function searchCustomPlaceAddr() {
  var input = document.getElementById('customPlaceAddrSearch');
  var q = input ? input.value.trim() : '';
  if (!q) return;

  if (!window._customRegMap) {
    alert('지도가 아직 로딩 중이에요. 잠시 후 다시 시도해 주세요.');
    return;
  }

  var ps = new kakao.maps.services.Places();
  ps.keywordSearch(q, function(data, status) {
    var resultBox = document.getElementById('customPlaceAddrResults');
    if (!resultBox) return;

    if (status !== kakao.maps.services.Status.OK || !data.length) {
      resultBox.innerHTML =
        '<div style="padding:14px 16px;font-size:12px;color:#A0AEC0;font-family:Pretendard,sans-serif;">' +
        '😅 검색 결과가 없어요</div>';
      resultBox.style.display = 'block';
      return;
    }

    var html = '';
    data.slice(0, 7).forEach(function(p) {
      html +=
        '<div style="padding:11px 16px;border-bottom:1px solid #F7FAFC;cursor:pointer;' +
        'font-family:Pretendard,sans-serif;transition:background .1s;" ' +
        'onmouseover="this.style.background=\'#EBF8FF\'" ' +
        'onmouseout="this.style.background=\'#fff\'" ' +
        'onclick="selectCustomPlaceAddrResult(' + p.y + ',' + p.x + ',\'' +
          p.place_name.replace(/'/g, "\\'") + '\',\'' +
          (p.road_address_name || p.address_name || '').replace(/'/g, "\\'") + '\')">' +
          '<div style="font-size:13px;font-weight:700;color:#1A202C;">' + p.place_name + '</div>' +
          '<div style="font-size:11px;color:#A0AEC0;margin-top:2px;">' +
            (p.road_address_name || p.address_name) +
          '</div>' +
        '</div>';
    });

    resultBox.innerHTML = html;
    resultBox.style.display = 'block';
  });
}

function selectCustomPlaceAddrResult(lat, lng, placeName, address) {
  var resultBox = document.getElementById('customPlaceAddrResults');
  if (resultBox) resultBox.style.display = 'none';
  var searchInput = document.getElementById('customPlaceAddrSearch');
  if (searchInput) searchInput.value = '';

  if (window._customRegPlaceFunc) {
    window._customRegPlaceFunc(new kakao.maps.LatLng(lat, lng));
    setTimeout(function() {
      var addrEl = document.getElementById('customPlaceRegAddr');
      if (addrEl && address) addrEl.value = address;
      var nameEl = document.getElementById('customPlaceRegName');
      if (nameEl && !nameEl.value.trim()) nameEl.value = placeName;
    }, 120);
  }
  if (window._customRegMap) window._customRegMap.setLevel(4);
}




/* ══════════════════════════════════════════
   나만의 장소 등록 요청 (POST)
══════════════════════════════════════════ */
function submitCustomPlaceReg() {
  var name = (document.getElementById('customPlaceRegName') || {}).value || '';
  var addr = (document.getElementById('customPlaceRegAddr') || {}).value || '';
  var lat  = (document.getElementById('customPlaceRegLat')  || {}).value || '';
  var lng  = (document.getElementById('customPlaceRegLng')  || {}).value || '';

  var nameEl = document.getElementById('customPlaceRegName');
  if (!name.trim()) {
    if (nameEl) {
      nameEl.style.borderColor = '#FC8181';
      nameEl.style.boxShadow   = '0 0 0 3px rgba(252,129,129,.14)';
      nameEl.focus();
    }
    return;
  }
  if (!lat || !lng) {
    alert('주소를 검색하거나 지도를 클릭해서 위치를 선택해 주세요.');
    return;
  }

  var btn = document.getElementById('customPlaceRegSubmitBtn');
  if (btn) { btn.disabled = true; btn.textContent = '등록 중…'; btn.style.opacity = '.55'; }

  fetch(CTX_PATH + '/api/places/my', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      placeName : name.trim(),
      address   : addr,
      latitude  : parseFloat(lat),
      longitude : parseFloat(lng),
      category  : 'NONE'
    })
  })
  .then(function(r) { return r.ok ? r.json() : Promise.reject(r.status); })
  .then(function() {
    window._customRegMap = null;
    window._customRegPlaceFunc = null;
    var modal = document.getElementById('customPlaceRegModal');
    if (modal) modal.remove();
    if (typeof showToast === 'function') showToast('⭐ 나만의 장소가 등록됐어요!');
    if (typeof loadMyPlaces === 'function') loadMyPlaces();
  })
  .catch(function(err) {
    alert('등록에 실패했습니다. (status: ' + err + ')');
    if (btn) { btn.disabled = false; btn.textContent = '📍 등록하기'; btn.style.opacity = '1'; }
  });
}



/**
 * 검색 결과 클릭 → 일정에 추가
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
  var myInput = document.getElementById('myPlaceSearchInput');
  if (myInput) { myInput.value = ''; }

  // ★ currentAddDay를 schedule.js와 공유
  if (typeof currentAddDay !== 'undefined') currentAddDay = dayNumber;

  // 메인 탭 초기화 — 항상 추천 장소 패널로 시작
  var recTab = document.getElementById('apmTabRecommend');
  var myTab  = document.getElementById('apmTabMy');
  var recPanel = document.getElementById('apmPanelRecommend');
  var myPanel  = document.getElementById('apmPanelMy');
  if (recTab)   recTab.classList.add('active');
  if (myTab)    myTab.classList.remove('active');
  if (recPanel) recPanel.style.display = '';
  if (myPanel)  myPanel.style.display  = 'none';

  // 카테고리 탭 초기화
  document.querySelectorAll('.place-type-tab').forEach(function(b) { b.classList.remove('active'); });
  var allTab = document.querySelector('.place-type-tab[onclick*="all"]');
  if (allTab) allTab.classList.add('active');
  _placeType = 'all';

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


/* ══════════════════════════════════════
   나만의 장소 삭제 (DELETE /api/places/my/{id})
══════════════════════════════════════ */
function deleteMyPlace(placeId, btnEl) {
  if (!confirm('이 나만의 장소를 삭제할까요?\n삭제하면 되돌릴 수 없어요.')) return;

  if (btnEl) { btnEl.disabled = true; btnEl.innerHTML = '…'; }

  fetch(CTX_PATH + '/api/places/my/' + placeId, { method: 'DELETE' })
    .then(function(r) { return r.json(); })
    .then(function(d) {
      if (d.success) {
        if (typeof showToast === 'function') showToast('🗑️ 나만의 장소가 삭제됐어요');
        loadMyPlaces();
      } else {
        alert('삭제 실패: ' + (d.message || '오류가 발생했습니다'));
        if (btnEl) { btnEl.disabled = false; btnEl.innerHTML = '🗑'; }
      }
    })
    .catch(function() {
      alert('네트워크 오류가 발생했습니다');
      if (btnEl) { btnEl.disabled = false; btnEl.innerHTML = '🗑'; }
    });
}




/* ══════════════════════════════════════════════════════
   추천 장소 모달 — 메인 탭 전환 (추천 ↔ 나만의)
══════════════════════════════════════════════════════ */
function switchAddPlaceMainTab(tabName, btnEl) {
  /* ── 탭 버튼 active 전환 ── */
  var recTab = document.getElementById('apmTabRecommend');
  var myTab  = document.getElementById('apmTabMy');
  if (recTab) recTab.classList.toggle('active', tabName === 'recommend');
  if (myTab)  myTab.classList.toggle('active',  tabName === 'my');

  /* ── 패널 show/hide ── */
  var recPanel = document.getElementById('apmPanelRecommend');
  var myPanel  = document.getElementById('apmPanelMy');
  if (recPanel) recPanel.style.display = (tabName === 'recommend') ? '' : 'none';
  if (myPanel)  myPanel.style.display  = (tabName === 'my')        ? '' : 'none';

  /* ── 나만의 탭 열릴 때 목록 로드 ── */
  if (tabName === 'my') {
    var kw = ((document.getElementById('myPlaceSearchInput') || {}).value || '').trim();
    loadMyPlaces(kw.length >= 1 ? kw : undefined);
  }
}