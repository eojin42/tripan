/**
 * workspace.festival.js  v2
 * ──────────────────────────────────────────────
 * 수정 내역:
 *  - 카드 렌더링 깨짐 수정 (left padding 추가)
 *  - 지역/카테고리 필터 칩 추가
 *  - 스크롤 영역 명시
 *  - 일정에 추가 버튼 → DAY 선택 팝업 → addPlaceToDay()
 *  - "프로그램" → "상세설명"
 *  - 상세 모달 폰트/디자인 개선
 *  - 이미지 클릭 시 전체화면 뷰어 모달 (좌/우 이동 가능)
 *  - 캐러셀 높이 축소 (240px)
 */

/* ══════════════════════════════════════════════
   상태 변수
══════════════════════════════════════════════ */
var _festivalList      = [];
var _festivalFiltered  = [];
var _festivalLoaded    = false;
var _festivalRegion    = 'all';   // 현재 선택된 지역 필터

var _carouselCurrent = 0;
var _carouselImages  = [];

/* 일정 추가용: 모달에서 선택한 축제 데이터 임시 저장 */
var _pendingFestival  = null;


/* ══════════════════════════════════════════════
   1. 축제 목록 로드
══════════════════════════════════════════════ */
function loadFestivalTab() {
  var container = document.getElementById('festivalListWrap');
  if (!container) return;
  if (_festivalLoaded) return;

  var start = (typeof TRIP_START_DATE !== 'undefined') ? TRIP_START_DATE : '';
  var end   = (typeof TRIP_END_DATE   !== 'undefined') ? TRIP_END_DATE   : '';

  if (!start || !end) {
    container.innerHTML = _festivalEmptyHtml('여행 날짜 정보가 없어요');
    return;
  }

  container.innerHTML =
    '<div class="festival-loading">' +
      '<div class="festival-loading-dot"></div>' +
      '<div class="festival-loading-dot"></div>' +
      '<div class="festival-loading-dot"></div>' +
    '</div>';

  fetch(CTX_PATH + '/api/festivals/by-trip'
      + '?tripStart=' + encodeURIComponent(start)
      + '&tripEnd='   + encodeURIComponent(end))
    .then(function(r) {
      if (!r.ok) throw new Error('HTTP ' + r.status);
      return r.json();
    })
    .then(function(list) {
      _festivalList   = list || [];
      _festivalLoaded = true;
      _buildRegionFilter(_festivalList);
      _applyFestivalFilter();
    })
    .catch(function(err) {
      console.error('[Festival] 로드 실패:', err);
      container.innerHTML = _festivalEmptyHtml('축제 정보를 불러오지 못했어요 😢');
    });
}


/* ══════════════════════════════════════════════
   2. 지역 필터 칩 생성
   이미지 기준 14개 지역: 서울/부산/제주/강원/경상/전라/충청/경기/인천/대전/대구/광주/울산/세종
══════════════════════════════════════════════ */

/* 지역 정의 — 이미지 순서 그대로 */
var _REGION_DEFS = [
  { key: '서울', label: '서울', icon: '🗼', keywords: ['서울'] },
  { key: '부산', label: '부산', icon: '🌊', keywords: ['부산'] },
  { key: '제주', label: '제주', icon: '🍊', keywords: ['제주'] },
  { key: '강원', label: '강원', icon: '🏔️', keywords: ['강원'] },
  { key: '경상', label: '경상', icon: '🏯', keywords: ['경상', '경남', '경북'] },
  { key: '전라', label: '전라', icon: '🌿', keywords: ['전라', '전남', '전북', '전북특별자치도'] },
  { key: '충청', label: '충청', icon: '🌸', keywords: ['충청', '충남', '충북', '세종특별자치시'] },
  { key: '경기', label: '경기', icon: '🏰', keywords: ['경기'] },
  { key: '인천', label: '인천', icon: '✈️', keywords: ['인천'] },
  { key: '대전', label: '대전', icon: '🔬', keywords: ['대전'] },
  { key: '대구', label: '대구', icon: '🍎', keywords: ['대구'] },
  { key: '광주', label: '광주', icon: '🌺', keywords: ['광주'] },
  { key: '울산', label: '울산', icon: '🏭', keywords: ['울산'] },
  { key: '세종', label: '세종', icon: '🏛️', keywords: ['세종'] }
];

/** 주소 → 지역 키 매핑 */
function _getRegionKey(address) {
  if (!address) return null;
  for (var i = 0; i < _REGION_DEFS.length; i++) {
    var def = _REGION_DEFS[i];
    for (var j = 0; j < def.keywords.length; j++) {
      if (address.indexOf(def.keywords[j]) >= 0) return def.key;
    }
  }
  return null;
}

function _buildRegionFilter(list) {
  var filterWrap = document.getElementById('festivalRegionFilter');
  if (!filterWrap) return;

  /* 각 지역 카운트 집계 */
  var countMap = {};
  list.forEach(function(f) {
    var key = _getRegionKey(f.eventPlace || '');
    if (key) countMap[key] = (countMap[key] || 0) + 1;
  });

  /* 전체 버튼 */
  var html =
    '<button class="festival-region-chip active" data-region="all" onclick="selectFestivalRegion(this,\'all\')">' +
    '전체 <span>' + list.length + '</span></button>';

  /* 이미지 순서 그대로, 해당 지역 데이터 있을 때만 표시 */
  _REGION_DEFS.forEach(function(def) {
    if (!countMap[def.key]) return;  // 데이터 없는 지역은 표시 안 함
    html +=
      '<button class="festival-region-chip" data-region="' + def.key + '" ' +
      'onclick="selectFestivalRegion(this,\'' + def.key + '\')">' +
      def.icon + ' ' + def.label + ' <span>' + countMap[def.key] + '</span></button>';
  });

  filterWrap.innerHTML = html;
}

function selectFestivalRegion(btn, region) {
  _festivalRegion = region;
  document.querySelectorAll('.festival-region-chip').forEach(function(c) { c.classList.remove('active'); });
  btn.classList.add('active');
  _applyFestivalFilter();
}

function _applyFestivalFilter() {
  if (_festivalRegion === 'all') {
    _festivalFiltered = _festivalList.slice();
  } else {
    var def = _REGION_DEFS.find(function(d) { return d.key === _festivalRegion; });
    _festivalFiltered = _festivalList.filter(function(f) {
      if (!def) return false;
      var addr = f.eventPlace || '';
      return def.keywords.some(function(kw) { return addr.indexOf(kw) >= 0; });
    });
  }
  _renderFestivalList(document.getElementById('festivalListWrap'), _festivalFiltered);
}


/* ══════════════════════════════════════════════
   3. 카드 목록 렌더링
══════════════════════════════════════════════ */
function _renderFestivalList(container, list) {
  if (!container) return;

  if (!list || !list.length) {
    container.innerHTML = _festivalEmptyHtml(
      _festivalRegion === 'all'
        ? '여행 기간(' + TRIP_START_DATE + ' ~ ' + TRIP_END_DATE + ')에<br>진행되는 축제가 없어요 🎭'
        : '"' + _festivalRegion + '" 지역 축제가 없어요 🎭'
    );
    return;
  }

  var html = '';
  list.forEach(function(f, idx) {
    /* _festivalList 기준 실제 인덱스를 구해야 detail 모달에서 정확히 찾음 */
    var realIdx = _festivalList.indexOf(f);

    var imgSrc  = f.firstimage || '';
    var title   = _fEsc(f.title || '축제');
    var place   = _fEsc(f.eventPlace || '');
    var dateStr = _formatDateRange(f.eventStartDate, f.eventEndDate);

    html +=
      '<div class="festival-card" onclick="openFestivalDetailModal(' + realIdx + ')">' +
        /* 썸네일 */
        '<div class="festival-card__thumb">' +
          (imgSrc
            ? '<img src="' + _fEsc(imgSrc) + '" alt="' + title + '" loading="lazy" ' +
              'onerror="this.parentElement.classList.add(\'festival-card__thumb--empty\')">'
            : '<div class="festival-card__thumb-empty-icon">🎉</div>') +
          '<span class="festival-card__badge">🎉 축제</span>' +
        '</div>' +
        /* 정보 (카드 전체가 상세모달 트리거) */
        '<div class="festival-card__body">' +
          '<div class="festival-card__title">' + title + '</div>' +
          '<div class="festival-card__meta">' +
            '<svg width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round"><rect x="3" y="4" width="18" height="18" rx="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>' +
            '<span>' + dateStr + '</span>' +
          '</div>' +
          (place
            ? '<div class="festival-card__meta">' +
                '<svg width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round"><path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z"/><circle cx="12" cy="10" r="3"/></svg>' +
                '<span>' + place + '</span>' +
              '</div>'
            : '') +
        '</div>' +
      '</div>';
  });

  container.innerHTML = html;
}


/* ══════════════════════════════════════════════
   4. 일정에 추가 — DAY 선택 팝업
══════════════════════════════════════════════ */
function openFestivalDayPicker(festivalIdx, e) {
  if (e) e.stopPropagation();
  _pendingFestival = _festivalList[festivalIdx];
  if (!_pendingFestival) return;

  /* 기존 뷰어 팝업 닫기 */
  var old = document.getElementById('festivalDayPickerModal');
  if (old) old.remove();

  var days = (typeof KAKAO_DAY_NUMS !== 'undefined') ? KAKAO_DAY_NUMS : [1];
  var btnHtml = days.map(function(d) {
    return '<button class="fdp-day-btn" onclick="addFestivalToDay(' + d + ')">DAY ' + d + '</button>';
  }).join('');

  var html =
    '<div id="festivalDayPickerModal" class="fdp-overlay" onclick="closeFestivalDayPicker()">' +
      '<div class="fdp-box" onclick="event.stopPropagation()">' +
        '<div class="fdp-title">📅 어느 날에 추가할까요?</div>' +
        '<div class="fdp-subtitle">' + _fEsc(_pendingFestival.title || '축제') + '</div>' +
        '<div class="fdp-days">' + btnHtml + '</div>' +
        '<button class="fdp-cancel" onclick="closeFestivalDayPicker()">취소</button>' +
      '</div>' +
    '</div>';

  document.body.insertAdjacentHTML('beforeend', html);
}

function closeFestivalDayPicker() {
  var m = document.getElementById('festivalDayPickerModal');
  if (m) m.remove();
  _pendingFestival = null;
}

function addFestivalToDay(dayNumber) {
  var f = _pendingFestival;
  if (!f) { closeFestivalDayPicker(); return; }

  closeFestivalDayPicker();

  /* schedule.js의 currentAddDay + addPlaceToDay 재사용 */
  if (typeof currentAddDay !== 'undefined') currentAddDay = dayNumber;

  var name = f.title || '축제';
  var addr = f.eventPlace || '';
  var lat  = f.mapy || 0;
  var lng  = f.mapx || 0;

  if (typeof addPlaceToDay === 'function') {
    addPlaceToDay(null, name, addr, lat, lng, null, 'FESTIVAL');
    if (typeof showToast === 'function') showToast('🎉 DAY ' + dayNumber + '에 ' + name + ' 추가 중...');
  } else {
    alert('일정 추가 기능을 찾을 수 없어요 (workspace.schedule.js 확인 필요)');
  }
}


/* ══════════════════════════════════════════════
   5. 축제 상세 대형 모달
══════════════════════════════════════════════ */
function openFestivalDetailModal(idx) {
  var f = _festivalList[idx];
  if (!f) return;

  /* 이미지 배열 */
  _carouselImages  = [];
  _carouselCurrent = 0;
  if (f.imageList && f.imageList.length > 0) {
    f.imageList.forEach(function(img) { if (img.originImgUrl) _carouselImages.push(img.originImgUrl); });
  }
  if (_carouselImages.length === 0 && f.firstimage) _carouselImages.push(f.firstimage);

  var title    = _fEsc(f.title || '축제');
  var place    = _fEsc(f.eventPlace || '-');
  var dateStr  = _formatDateRange(f.eventStartDate, f.eventEndDate);
  var program  = _formatClob(f.program);
  var subEvent = _formatClob(f.subEvent);
  var usageFee = _fEsc(f.usageFee  || '정보 없음');
  var playTime = _fEsc(f.playTime  || '-');
  var sponsor1 = _fEsc(f.sponsor1  || '-');
  var tel      = _fEsc(f.sponsor1Tel || '');

  /* ─ 캐러셀 ─ */
  var carouselHtml;
  if (_carouselImages.length === 0) {
    carouselHtml =
      '<div class="fmodal-carousel">' +
        '<div class="fmodal-carousel__no-img">🎉<div style="font-size:14px;margin-top:8px;color:#A0AEC0;">이미지 없음</div></div>' +
      '</div>';
  } else {
    var slidesHtml = _carouselImages.map(function(url, i) {
      return '<div class="fmodal-carousel__slide' + (i === 0 ? ' active' : '') + '">' +
               '<img src="' + _fEsc(url) + '" alt="' + title + ' 이미지 ' + (i+1) + '" loading="lazy" ' +
                    'onclick="openFestivalImageViewer(' + i + ')" style="cursor:zoom-in;">' +
             '</div>';
    }).join('');

    var arrowHtml = _carouselImages.length > 1
      ? '<button class="fmodal-carousel__btn fmodal-carousel__btn--prev" onclick="carouselMove(-1)">' +
          '<svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round"><polyline points="15 18 9 12 15 6"/></svg></button>' +
        '<button class="fmodal-carousel__btn fmodal-carousel__btn--next" onclick="carouselMove(1)">' +
          '<svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round"><polyline points="9 18 15 12 9 6"/></svg></button>' +
        '<div class="fmodal-carousel__dots">' +
          _carouselImages.map(function(_, i) {
            return '<button class="fmodal-carousel__dot' + (i === 0 ? ' active' : '') + '" onclick="carouselGoTo(' + i + ')"></button>';
          }).join('') +
        '</div>' +
        '<div class="fmodal-carousel__hint">이미지 클릭 시 크게 볼 수 있어요 🔍</div>'
      : '<div class="fmodal-carousel__hint">이미지 클릭 시 크게 볼 수 있어요 🔍</div>';

    carouselHtml =
      '<div class="fmodal-carousel" id="fmodalCarousel">' +
        '<div class="fmodal-carousel__track">' + slidesHtml + '</div>' +
        arrowHtml +
      '</div>';
  }

  /* ─ 정보 그리드 ─ */
  var infoRows = [
    { icon: '📅', label: '기간',    value: '<strong>' + dateStr + '</strong>' },
    { icon: '📍', label: '장소',    value: place },
    { icon: '⏰', label: '공연시간', value: playTime },
    { icon: '💰', label: '요금',    value: usageFee },
    { icon: '📞', label: '주최',    value: sponsor1 + (tel ? ' · ' + tel : '') },
  ];

  var infoHtml = infoRows.map(function(row) {
    return '<div class="fmodal-info__row">' +
             '<span class="fmodal-info__icon">' + row.icon + '</span>' +
             '<div class="fmodal-info__content">' +
               '<span class="fmodal-info__label">' + row.label + '</span>' +
               '<span class="fmodal-info__value">' + row.value + '</span>' +
             '</div>' +
           '</div>';
  }).join('');

  var html =
    '<div id="festivalDetailModal" class="fmodal-overlay">' +
      '<div class="fmodal-box">' +

        '<button class="fmodal-close" id="fmodalCloseBtn" aria-label="닫기">' +
          '<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>' +
        '</button>' +

        carouselHtml +

        '<div class="fmodal-body">' +

          /* 헤더 + 추가 버튼 */
          '<div class="fmodal-header">' +
            '<div class="fmodal-header__left">' +
              '<span class="fmodal-header__badge">🎉 축제</span>' +
              '<h2 class="fmodal-header__title">' + title + '</h2>' +
            '</div>' +
            '<button class="fmodal-add-btn" onclick="openFestivalDayPicker(' + idx + ',event)">' +
              '<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>' +
              '일정에 추가' +
            '</button>' +
          '</div>' +

          /* 정보 그리드 */
          '<div class="fmodal-info">' + infoHtml + '</div>' +

          /* 상세설명 */
          (program
            ? '<div class="fmodal-section">' +
                '<div class="fmodal-section__title">📋 상세설명</div>' +
                '<div class="fmodal-section__content">' + program + '</div>' +
              '</div>'
            : '') +

          /* 부대행사 */
          (subEvent
            ? '<div class="fmodal-section">' +
                '<div class="fmodal-section__title">🎪 부대행사</div>' +
                '<div class="fmodal-section__content">' + subEvent + '</div>' +
              '</div>'
            : '') +

        '</div>' +
      '</div>' +
    '</div>';

  document.body.insertAdjacentHTML('beforeend', html);

  /* 이벤트 바인딩 */
  var overlay = document.getElementById('festivalDetailModal');
  var closeBtn = document.getElementById('fmodalCloseBtn');

  overlay.addEventListener('click', function(e) {
    if (e.target === overlay) _closeFmodalAnim(overlay);
  });
  closeBtn.addEventListener('click', function() {
    _closeFmodalAnim(overlay);
  });

  document.addEventListener('keydown', _festivalEscListener);
}

function _closeFmodalAnim(el) {
  el.classList.add('fmodal-overlay--closing');
  setTimeout(function() { if (el.parentNode) el.remove(); }, 220);
  document.removeEventListener('keydown', _festivalEscListener);
}

function _festivalEscListener(e) {
  if (e.key === 'Escape') {
    var m = document.getElementById('festivalDetailModal');
    if (m) _closeFmodalAnim(m);
    var vw = document.getElementById('festivalImageViewer');
    if (vw) vw.remove();
  }
}


/* ══════════════════════════════════════════════
   6. 이미지 전체화면 뷰어
══════════════════════════════════════════════ */
function openFestivalImageViewer(startIdx) {
  var old = document.getElementById('festivalImageViewer');
  if (old) old.remove();

  if (!_carouselImages.length) return;
  _carouselCurrent = startIdx || 0;

  var html =
    '<div id="festivalImageViewer" class="fviewer-overlay">' +
      '<button class="fviewer-close" id="fviewerClose">✕</button>' +
      '<div class="fviewer-counter" id="fviewerCounter">' + (_carouselCurrent + 1) + ' / ' + _carouselImages.length + '</div>' +

      (_carouselImages.length > 1
        ? '<button class="fviewer-btn fviewer-btn--prev" onclick="viewerMove(-1)">' +
            '<svg width="26" height="26" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><polyline points="15 18 9 12 15 6"/></svg>' +
          '</button>' +
          '<button class="fviewer-btn fviewer-btn--next" onclick="viewerMove(1)">' +
            '<svg width="26" height="26" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><polyline points="9 18 15 12 9 6"/></svg>' +
          '</button>'
        : '') +

      '<div class="fviewer-img-wrap" id="fviewerImgWrap">' +
        '<img id="fviewerImg" src="' + _fEsc(_carouselImages[_carouselCurrent]) + '" alt="축제 이미지">' +
      '</div>' +
    '</div>';

  document.body.insertAdjacentHTML('beforeend', html);

  document.getElementById('fviewerClose').addEventListener('click', function() {
    document.getElementById('festivalImageViewer').remove();
  });
  document.getElementById('festivalImageViewer').addEventListener('click', function(e) {
    if (e.target.id === 'festivalImageViewer') this.remove();
  });
}

function viewerMove(dir) {
  _carouselCurrent = (_carouselCurrent + dir + _carouselImages.length) % _carouselImages.length;
  var img = document.getElementById('fviewerImg');
  var counter = document.getElementById('fviewerCounter');
  if (img) img.src = _carouselImages[_carouselCurrent];
  if (counter) counter.textContent = (_carouselCurrent + 1) + ' / ' + _carouselImages.length;
}


/* ══════════════════════════════════════════════
   7. 캐러셀 컨트롤 (상세 모달 내)
══════════════════════════════════════════════ */
function carouselMove(dir) {
  if (_carouselImages.length <= 1) return;
  carouselGoTo((_carouselCurrent + dir + _carouselImages.length) % _carouselImages.length);
}

function carouselGoTo(idx) {
  _carouselCurrent = idx;
  document.querySelectorAll('.fmodal-carousel__slide').forEach(function(s, i) {
    s.classList.toggle('active', i === idx);
  });
  document.querySelectorAll('.fmodal-carousel__dot').forEach(function(d, i) {
    d.classList.toggle('active', i === idx);
  });
}


/* ══════════════════════════════════════════════
   유틸
══════════════════════════════════════════════ */
function _fEsc(str) {
  if (!str && str !== 0) return '';
  return String(str)
    .replace(/&/g, '&amp;').replace(/</g, '&lt;')
    .replace(/>/g, '&gt;').replace(/"/g, '&quot;');
}

function _formatDateRange(start, end) {
  function fmt(d) {
    if (!d) return '';
    var s = String(d);
    return s.length >= 10 ? s.substring(0, 10).replace(/-/g, '.') : s;
  }
  var s = fmt(start), e = fmt(end);
  if (!s && !e) return '날짜 미정';
  if (s === e) return s;
  return s + ' ~ ' + e;
}

function _formatClob(text) {
  if (!text || !String(text).trim()) return '';
  return _fEsc(String(text).trim()).replace(/(\r\n|\n|\r)/g, '<br>');
}

function _festivalEmptyHtml(msg) {
  return '<div class="festival-empty">' +
           '<div class="festival-empty__icon">🎭</div>' +
           '<div class="festival-empty__msg">' + msg + '</div>' +
         '</div>';
}
