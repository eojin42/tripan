/**
 * workspace.recommend.js
 * ──────────────────────────────────────────────────────
 * 담당: 추천 장소 패널 · 키워드 검색 · 나만의 장소 등록
 *
 * [API 연동]
 *  GET  /api/places/recommend?category=&city=&limit=12  → 추천 카드
 *  GET  /api/places/search?keyword=                     → 장소 추가 모달 검색
 *  GET  /api/places/my                                  → 나만의 장소 목록
 *  POST /api/places/my                                  → 나만의 장소 등록
 * ──────────────────────────────────────────────────────
 */

/* ══════════════════════════════
   상태
══════════════════════════════ */
var _rpCategory   = 'all';
var _rpAllCards   = [];
var _searchTimer  = null;

/* ══════════════════════════════
   1. 추천 장소 로드 (페이지 진입 시 자동)
══════════════════════════════ */

document.addEventListener('DOMContentLoaded', function () {
  var cities = (typeof KAKAO_CITIES !== 'undefined' && KAKAO_CITIES.length > 0) ? KAKAO_CITIES.join(',') : '';
  loadRecommendCards('all', cities);
});

function loadRecommendCards(category, city) {
  _rpCategory = category;
  var loading = document.getElementById('rpCardsLoading');
  var grid    = document.getElementById('rpCards');
  if (loading) loading.style.display = 'block';

  var url = CTX_PATH + '/api/places/recommend'
          + '?category=' + encodeURIComponent(category)
          + '&city='     + encodeURIComponent(city || '')
          + '&limit=12';

  fetch(url)
    .then(function (r) { return r.json(); })
    .then(function (list) {
      _rpAllCards = list;
      renderRpCards(list);
      if (loading) loading.style.display = 'none';
    })
    .catch(function () {
      if (loading) loading.innerHTML =
        '<div style="text-align:center;padding:32px;color:#A0AEC0;">' +
        '<div style="font-size:32px;margin-bottom:8px;">⚠️</div>' +
        '<div style="font-size:13px;">추천 장소를 불러오지 못했어요<br><span style="font-size:11px;color:#CBD5E0;">잠시 후 다시 시도해 주세요</span></div>' +
        '</div>';
    });
}

/* ══════════════════════════════
   2. 추천 카드 렌더링
══════════════════════════════ */
function renderRpCards(list) {
  var grid = document.getElementById('rpCards');
  if (!grid) return;

  var noResult = document.getElementById('rpNoResult');

  // 기존 카드 제거 (로딩 div 유지)
  Array.from(grid.querySelectorAll('.rp-card')).forEach(function (el) { el.remove(); });

  if (!list || list.length === 0) {
    if (noResult) {
      noResult.innerHTML =
        '<div style="text-align:center;padding:24px;color:#A0AEC0;">' +
        '<div style="font-size:28px;margin-bottom:8px;">🗺️</div>' +
        '<div style="font-size:13px;color:#718096;">아직 추천 장소 데이터가 없어요</div>' +
        '<div style="font-size:11px;color:#CBD5E0;margin-top:4px;">여행지 키워드로 직접 검색해 보세요</div>' +
        '</div>';
      noResult.style.display = 'block';
    }
    return;
  }
  if (noResult) noResult.style.display = 'none';

  list.forEach(function (p) {
    var card = document.createElement('div');
    card.className = 'rp-card';
    card.setAttribute('data-name',     p.placeName  || '');
    card.setAttribute('data-address',  p.address    || '');
    card.setAttribute('data-category', p.category   || '');
    card.setAttribute('data-place-id', p.placeId    || '');
    card.setAttribute('data-lat',      p.latitude   || 0);
    card.setAttribute('data-lng',      p.longitude  || 0);
    card.setAttribute('data-custom',   p.isCustom ? '1' : '0');

    var img      = p.imageUrl  ? p.imageUrl  : '';
    var badge    = _categoryBadge(p.category);
    var customTag = p.isCustom ? '<span class="rp-custom-tag">⭐ 나만의</span>' : '';

    card.innerHTML =
      '<div class="rp-card__img">' +
        (img
          ? '<img src="' + _escHtml(img) + '" alt="' + _escHtml(p.placeName) + '" loading="lazy" onerror="this.parentElement.innerHTML=\'📍\'">'
          : '<div class="rp-card__img-empty">📍</div>') +
        badge + customTag +
      '</div>' +
      '<div class="rp-card__body">' +
        '<div class="rp-card__name">' + _escHtml(p.placeName) + '</div>' +
        '<div class="rp-card__addr">' + _escHtml(p.address || '') + '</div>' +
      '</div>' +
      '<button class="rp-card__add-btn" onclick="rpAddToDay(this)" title="일정에 추가">+</button>';

    grid.appendChild(card);
  });
}

/* ══════════════════════════════
   3. 카테고리 필터 탭 클릭
══════════════════════════════ */
function filterRec(btn, category) {
  document.querySelectorAll('.rp-filter-btn').forEach(function (b) {
    b.classList.remove('active');
  });
  btn.classList.add('active');

  var city = (typeof KAKAO_CITIES !== 'undefined' && KAKAO_CITIES.length > 0)
    ? KAKAO_CITIES[0] : '';
  loadRecommendCards(category, city);
}

/* ══════════════════════════════
   4. 추천 카드 내 검색 필터 (클라이언트 사이드)
══════════════════════════════ */
function searchRpCards(keyword) {
  var clear = document.getElementById('rpSearchClear');
  if (clear) clear.style.display = keyword ? 'block' : 'none';

  if (!keyword || keyword.trim().length < 1) {
    renderRpCards(_rpAllCards);
    return;
  }
  var kw = keyword.trim().toUpperCase();
  var filtered = _rpAllCards.filter(function (p) {
    return (p.placeName  && p.placeName.toUpperCase().indexOf(kw)  !== -1) ||
           (p.address    && p.address.toUpperCase().indexOf(kw)    !== -1);
  });
  renderRpCards(filtered);
}

function clearRpSearch() {
  var input = document.getElementById('rpSearchInput');
  if (input) { input.value = ''; searchRpCards(''); }
}

/* ══════════════════════════════
   5. 장소 추가 모달 — 카카오 API 실시간 검색
   (기존 workspace.schedule.js의 searchPlace 대체)
══════════════════════════════ */
var _placeType = 'all';

function selectPlaceType(btn, type) {
  document.querySelectorAll('.place-type-tab').forEach(function (b) {
    b.classList.remove('active');
  });
  btn.classList.add('active');
  _placeType = type;

  if (type === 'my') {
    // 나만의 장소 탭 → 내 장소 목록 로드
    loadMyPlaces();
  } else {
    var kw = document.getElementById('placeSearchInput');
    var keyword = kw ? kw.value.trim() : '';
    if (keyword.length >= 2) {
      searchPlace(keyword);
    } else {
      // 검색어 없으면 카테고리 기준으로 추천 장소 미리보기
      _loadCategoryPreview(type);
    }
  }
}

/** 카테고리 탭 클릭 시 검색어 없을 때 DB에서 미리보기 로드 */
function _loadCategoryPreview(category) {
  var results = document.getElementById('placeResults');
  if (!results) return;
  results.innerHTML = '<div style="text-align:center;padding:20px;color:#A0AEC0;">🔍 검색 중...</div>';

  var city = (typeof KAKAO_CITIES !== 'undefined' && KAKAO_CITIES.length > 0) ? KAKAO_CITIES[0] : '';
  var url = CTX_PATH + '/api/places/recommend'
          + '?category=' + encodeURIComponent(category === 'all' ? 'all' : category)
          + '&city='     + encodeURIComponent(city)
          + '&limit=20';

  fetch(url)
    .then(function(r) { return r.json(); })
    .then(function(list) { renderPlaceResults(list); })
    .catch(function() { renderPlaceResults([]); });
}

function searchPlace(keyword) {
  clearTimeout(_searchTimer);
  if (!keyword || keyword.trim().length < 2) {
    if (_placeType === 'my') { loadMyPlaces(); return; }
    _loadCategoryPreview(_placeType);
    return;
  }

  var results = document.getElementById('placeResults');
  if (results) results.innerHTML = '<div style="text-align:center;padding:20px;color:#A0AEC0;">🔍 검색 중...</div>';

  _searchTimer = setTimeout(function () {
    // ① 나만의 장소 탭이면 내 장소만
    if (_placeType === 'my') { loadMyPlaces(keyword); return; }

    // ② 카카오 장소 API 먼저 (실시간성 우선)
    _searchKakaoPlaces(keyword);
  }, 350);
}

/** 카카오 장소 API 검색 → 카테고리 필터 적용 후 렌더, 결과 없으면 KTO DB fallback */
function _searchKakaoPlaces(keyword) {
  if (typeof kakao === 'undefined' || !kakao.maps) {
    _searchKtoPlaces(keyword);
    return;
  }
  var ps = new kakao.maps.services.Places();
  ps.keywordSearch(keyword, function (data, status) {
    if (status === kakao.maps.services.Status.OK && data.length > 0) {
      var mapped = data.map(function (item) {
        return {
          placeId:   null,
          placeName: item.place_name,
          address:   item.address_name,
          latitude:  parseFloat(item.y),
          longitude: parseFloat(item.x),
          category:  _kakaoCategory(item.category_group_code),
          imageUrl:  '',
          phone:     item.phone,
          isCustom:  false,
          kakaoId:   item.id
        };
      });
      // 카테고리 탭 필터 적용 (all이 아닐 때)
      var filtered = mapped;
      if (_placeType && _placeType !== 'all') {
        filtered = mapped.filter(function(p) {
          return p.category === _placeType;
        });
        // 카테고리 필터 후 결과 없으면 전체 표시
        if (filtered.length === 0) filtered = mapped;
      }
      renderPlaceResults(filtered);
    } else {
      // 카카오 결과 없음 → KTO DB 검색
      _searchKtoPlaces(keyword);
    }
  });
}

/** KTO DB 검색 (백엔드 /api/places/search) */
function _searchKtoPlaces(keyword) {
  fetch(CTX_PATH + '/api/places/search?keyword=' + encodeURIComponent(keyword))
    .then(function (r) { return r.json(); })
    .then(function (list) { renderPlaceResults(list); })
    .catch(function () { renderPlaceResults([]); });
}

/** 카카오 카테고리 코드 → 내부 category */
function _kakaoCategory(code) {
  var map = { FD6: 'RESTAURANT', CE7: 'CAFE', AT4: 'TOUR', AD5: 'STAY', SW8: 'SHOPPING' };
  return map[code] || 'ETC';
}

/* ══════════════════════════════
   6. 장소 검색 결과 렌더링 (장소 추가 모달 내)
══════════════════════════════ */
function renderPlaceResults(list) {
  var wrap = document.getElementById('placeResults');
  if (!wrap) return;

  if (!list || list.length === 0) {
    wrap.innerHTML =
      '<div style="text-align:center;padding:28px;color:#A0AEC0;">' +
      '<div style="font-size:28px;margin-bottom:8px;">😅</div>' +
      '<div style="font-size:13px;">검색 결과가 없어요</div></div>';
    return;
  }

  wrap.innerHTML = list.map(function (p) {
    var customTag = p.isCustom ? '<span style="font-size:10px;background:#FFF3CD;color:#856404;padding:2px 6px;border-radius:4px;margin-left:4px;">나만의</span>' : '';
    return '<div class="place-result-item" ' +
      'data-name="'    + _escHtml(p.placeName  || '') + '" ' +
      'data-address="' + _escHtml(p.address    || '') + '" ' +
      'data-lat="'     + (p.latitude  || 0)           + '" ' +
      'data-lng="'     + (p.longitude || 0)           + '" ' +
      'data-place-id="'+ (p.placeId   || '')          + '" ' +
      'onclick="selectPlaceResult(this)">' +
      '<div style="font-size:13px;font-weight:700;color:#2D3748;">' + _escHtml(p.placeName) + customTag + '</div>' +
      '<div style="font-size:12px;color:#A0AEC0;margin-top:3px;">' + _escHtml(p.address || '') + '</div>' +
      '</div>';
  }).join('');
}

/* ══════════════════════════════
   7. 나만의 장소 목록 로드
══════════════════════════════ */
function loadMyPlaces(keyword) {
  fetch(CTX_PATH + '/api/places/my')
    .then(function (r) { return r.json(); })
    .then(function (list) {
      var filtered = list;
      if (keyword) {
        var kw = keyword.toUpperCase();
        filtered = list.filter(function (p) {
          return (p.placeName && p.placeName.toUpperCase().indexOf(kw) !== -1) ||
                 (p.address   && p.address.toUpperCase().indexOf(kw)   !== -1);
        });
      }
      // 상단에 "나만의 장소 등록" 버튼 포함해서 렌더
      renderMyPlaceResults(filtered);
    })
    .catch(function () { renderPlaceResults([]); });
}

function renderMyPlaceResults(list) {
  var wrap = document.getElementById('placeResults');
  if (!wrap) return;

  var html =
    '<div style="padding:12px 0 8px;">' +
    '<button class="btn-primary" style="margin:0;padding:10px;font-size:13px;" ' +
    'onclick="openRegisterMyPlaceForm()">+ 나만의 장소 직접 등록</button></div>';

  if (!list || list.length === 0) {
    html += '<div style="text-align:center;padding:20px;color:#A0AEC0;font-size:13px;">아직 등록한 나만의 장소가 없어요</div>';
  } else {
    html += list.map(function (p) {
      return '<div class="place-result-item" ' +
        'data-name="'    + _escHtml(p.placeName || '') + '" ' +
        'data-address="' + _escHtml(p.address   || '') + '" ' +
        'data-lat="'     + (p.latitude  || 0)          + '" ' +
        'data-lng="'     + (p.longitude || 0)          + '" ' +
        'data-place-id="'+ (p.placeId   || '')         + '" ' +
        'onclick="selectPlaceResult(this)">' +
        '<div style="font-size:13px;font-weight:700;color:#2D3748;">⭐ ' + _escHtml(p.placeName) + '</div>' +
        '<div style="font-size:12px;color:#A0AEC0;margin-top:3px;">' + _escHtml(p.address || '') + '</div>' +
        '</div>';
    }).join('');
  }
  wrap.innerHTML = html;
}

/* ══════════════════════════════
   8. 나만의 장소 등록 폼 (인라인)
══════════════════════════════ */
function openRegisterMyPlaceForm() {
  var wrap = document.getElementById('placeResults');
  if (!wrap) return;
  wrap.innerHTML =
    '<div style="padding:16px;background:#F8FAFC;border-radius:12px;display:flex;flex-direction:column;gap:10px;">' +
    '<div style="font-size:13px;font-weight:800;color:#2D3748;">나만의 장소 등록</div>' +
    '<input id="myp-name"    class="form-input" placeholder="장소명 *" style="margin:0">' +
    '<input id="myp-address" class="form-input" placeholder="주소" style="margin:0">' +
    '<input id="myp-lat"     class="form-input" placeholder="위도 (예: 37.5665)" style="margin:0" type="number" step="any">' +
    '<input id="myp-lng"     class="form-input" placeholder="경도 (예: 126.9780)" style="margin:0" type="number" step="any">' +
    '<select id="myp-cat" class="form-input" style="margin:0">' +
    '  <option value="RESTAURANT">🍽️ 음식점</option>' +
    '  <option value="TOUR">🏔️ 관광지</option>' +
    '  <option value="STAY">🏨 숙박</option>' +
    '  <option value="CAFE">☕ 카페</option>' +
    '  <option value="SHOPPING">🛍️ 쇼핑</option>' +
    '  <option value="ETC">📦 기타</option>' +
    '</select>' +
    '<div style="display:flex;gap:8px;">' +
    '  <button class="btn-primary" style="margin:0;flex:1;padding:10px;font-size:13px;" onclick="submitRegisterMyPlace()">등록</button>' +
    '  <button style="flex:1;padding:10px;border-radius:10px;border:1.5px solid #E2E8F0;background:#fff;cursor:pointer;font-size:13px;" onclick="loadMyPlaces()">취소</button>' +
    '</div></div>';
}

function submitRegisterMyPlace() {
  var name    = (document.getElementById('myp-name')    || {}).value || '';
  var address = (document.getElementById('myp-address') || {}).value || '';
  var lat     = parseFloat((document.getElementById('myp-lat') || {}).value || 0);
  var lng     = parseFloat((document.getElementById('myp-lng') || {}).value || 0);
  var cat     = (document.getElementById('myp-cat')     || {}).value || 'ETC';

  if (!name.trim()) { if (typeof showToast === 'function') showToast('⚠️ 장소명은 필수입니다'); return; }

  fetch(CTX_PATH + '/api/places/my', {
    method:  'POST',
    headers: { 'Content-Type': 'application/json' },
    body:    JSON.stringify({ placeName: name, address: address, latitude: lat, longitude: lng, category: cat })
  })
  .then(function (r) { return r.json(); })
  .then(function (res) {
    if (res.success) {
      if (typeof showToast === 'function') showToast('⭐ 나만의 장소가 등록됐어요!');
      loadMyPlaces();
    }
  })
  .catch(function () {
    if (typeof showToast === 'function') showToast('⚠️ 등록에 실패했어요');
  });
}

/* ══════════════════════════════
   9. 추천 카드 → 일정 추가 (Day 선택 팝업)
══════════════════════════════ */
var _pendingRpCard = null;

function rpAddToDay(btn) {
  _pendingRpCard = btn.closest('.rp-card');
  var popup = document.getElementById('dayPickerPopup');
  if (popup) popup.style.display = 'block';
}

function closeDayPicker() {
  var popup = document.getElementById('dayPickerPopup');
  if (popup) popup.style.display = 'none';
  _pendingRpCard = null;
}

function addRecToDay(dayNumber) {
  if (!_pendingRpCard) { closeDayPicker(); return; }
  var card = _pendingRpCard;
  closeDayPicker();

  var name    = card.getAttribute('data-name')    || '';
  var address = card.getAttribute('data-address') || '';
  var lat     = parseFloat(card.getAttribute('data-lat')  || 0);
  var lng     = parseFloat(card.getAttribute('data-lng')  || 0);
  var placeId = card.getAttribute('data-place-id') || null;

  // workspace.schedule.js 의 addPlaceToDay 함수 호출
  if (typeof addPlaceToDay === 'function') {
    addPlaceToDay(dayNumber, name, address, lat, lng, placeId);
  } else {
    if (typeof showToast === 'function') showToast('⚠️ 일정 추가 함수를 찾을 수 없어요');
  }
}

/* ══════════════════════════════
   10. 장소 추가 모달에서 결과 클릭 → 현재 열린 Day에 추가
══════════════════════════════ */
var _currentAddDay = null;

function openAddPlace(dayNumber) {
  _currentAddDay = dayNumber;
  // 검색 input 초기화
  var input = document.getElementById('placeSearchInput');
  if (input) input.value = '';
  renderPlaceResults([]);
  _placeType = 'all';
  document.querySelectorAll('.place-type-tab').forEach(function (b) { b.classList.remove('active'); });
  var allTab = document.querySelector('.place-type-tab');
  if (allTab) allTab.classList.add('active');
  if (typeof openModal === 'function') openModal('addPlaceModal');
}

function selectPlaceResult(el) {
  var name    = el.getAttribute('data-name')    || '';
  var address = el.getAttribute('data-address') || '';
  var lat     = parseFloat(el.getAttribute('data-lat') || 0);
  var lng     = parseFloat(el.getAttribute('data-lng') || 0);
  var placeId = el.getAttribute('data-place-id') || null;

  if (typeof closeModal === 'function') closeModal('addPlaceModal');

  if (typeof addPlaceToDay === 'function') {
    addPlaceToDay(_currentAddDay, name, address, lat, lng, placeId);
  }
}

/* ══════════════════════════════
   유틸
══════════════════════════════ */
function _escHtml(str) {
  if (!str) return '';
  return String(str)
    .replace(/&/g, '&amp;').replace(/</g, '&lt;')
    .replace(/>/g, '&gt;').replace(/"/g, '&quot;');
}

function _categoryBadge(cat) {
  var map = {
    RESTAURANT: '🍽️ 맛집', CAFE: '☕ 카페', TOUR: '🏔️ 관광',
    STAY: '🏨 숙박', CULTURE: '🎭 문화', LEISURE: '🏄 레포츠',
    SHOPPING: '🛍️ 쇼핑', ETC: '📍 장소'
  };
  var label = map[cat] || '📍 장소';
  return '<span class="rp-card__badge">' + label + '</span>';
}

/* 탭 전환 (추천·요약·날씨) */
function switchRpTab(name, btn) {
  document.querySelectorAll('.rp-tab').forEach(function (t) { t.classList.remove('active'); });
  document.querySelectorAll('.rp-pane').forEach(function (p) { p.classList.remove('active'); });
  if (btn) btn.classList.add('active');
  var pane = document.getElementById('rpPane-' + name);
  if (pane) pane.classList.add('active');
}
