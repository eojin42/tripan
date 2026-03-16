/**
 * workspace.weather.js  ★ Tripan 날씨 v5
 * - 검색창만, 버튼 없음
 * - 오늘~D+3 단기예보 4일 카드 (크고 가독성 좋게)
 * - 지역명 강조
 */

var _weatherInitialized = false;
var _wthrCache       = {};
var _wthrInputTimer  = null;
var _wthrCurrentCity = null;

var WTHR_ALL_CITIES = [
  '서울','인천','수원','고양','춘천','강릉','속초','원주','동해','태백',
  '대전','청주','천안','세종','충주','전주','광주','순천','여수','목포',
  '나주','군산','남원','대구','부산','울산','창원','포항','안동','진주',
  '거제','통영','경주','구미','제주','서귀포'
];

/* ══════════════════════════════════════════════
   1. 초기화
══════════════════════════════════════════════ */
function loadWeatherIfNeeded() {
  if (_weatherInitialized) return;
  _weatherInitialized = true;
  _buildWeatherPanel();
}

function _buildWeatherPanel() {
  var wrap = document.getElementById('rpPane-weather');
  if (!wrap) return;

  wrap.innerHTML =
    '<div class="wv5-search-wrap">' +
      '<div class="wv5-search-box">' +
        '<svg class="wv5-search-ico" viewBox="0 0 20 20" fill="none">' +
          '<circle cx="8.5" cy="8.5" r="5.5" stroke="#A0AEC0" stroke-width="1.8"/>' +
          '<path d="M13 13l3.5 3.5" stroke="#A0AEC0" stroke-width="1.8" stroke-linecap="round"/>' +
        '</svg>' +
        '<input id="wthrInput" class="wv5-input" type="text" ' +
          'placeholder="도시 검색  예) 서울, 부산, 제주" ' +
          'oninput="_wv5Input(this.value)" ' +
          'onkeydown="if(event.key===\'Enter\'){_wv5Submit();}" />' +
        '<button class="wv5-clear" id="wthrClear" onclick="_wv5Clear()" style="display:none">✕</button>' +
      '</div>' +
      '<div id="wv5Suggest" class="wv5-suggest"></div>' +
    '</div>' +
    '<div id="wv5Result"></div>';

  // 여행 도시 자동 로드
  if (typeof TRIP_CITIES !== 'undefined' && TRIP_CITIES.length > 0) {
    var city = TRIP_CITIES[0].trim();
    setTimeout(function() { _wv5Search(city); }, 200);
  }
}

/* ══════════════════════════════════════════════
   2. 검색창 이벤트
══════════════════════════════════════════════ */
function _wv5Input(val) {
  var clr = document.getElementById('wthrClear');
  if (clr) clr.style.display = val ? 'block' : 'none';

  clearTimeout(_wthrInputTimer);
  var sg = document.getElementById('wv5Suggest');
  if (!sg) return;
  if (!val || !val.trim()) { _wv5CloseSuggest(); return; }

  _wthrInputTimer = setTimeout(function() {
    var q = val.trim();
    var hits = WTHR_ALL_CITIES.filter(function(n) { return n.indexOf(q) !== -1; }).slice(0, 6);
    if (!hits.length) { _wv5CloseSuggest(); return; }
    sg.innerHTML = hits.map(function(n) {
      var hi = n.replace(q, '<mark>' + _e(q) + '</mark>');
      return '<div class="wv5-sug-item" onclick="_wv5Search(\'' + _e(n) + '\')">' +
               '<span class="wv5-sug-pin">📍</span>' + hi + '</div>';
    }).join('');
    sg.classList.add('show');
  }, 120);
}

function _wv5Submit() {
  var inp = document.getElementById('wthrInput');
  if (inp && inp.value.trim()) _wv5Search(inp.value.trim());
}

function _wv5Clear() {
  var inp = document.getElementById('wthrInput');
  if (inp) { inp.value = ''; inp.focus(); }
  var clr = document.getElementById('wthrClear');
  if (clr) clr.style.display = 'none';
  _wv5CloseSuggest();
}

function _wv5CloseSuggest() {
  var sg = document.getElementById('wv5Suggest');
  if (sg) { sg.innerHTML = ''; sg.classList.remove('show'); }
}

/* ══════════════════════════════════════════════
   3. API 호출
══════════════════════════════════════════════ */
function _wv5Search(cityName) {
  if (!cityName || !cityName.trim()) return;
  cityName = cityName.trim();

  _wv5CloseSuggest();
  var inp = document.getElementById('wthrInput');
  if (inp) inp.value = cityName;
  var clr = document.getElementById('wthrClear');
  if (clr) clr.style.display = 'block';

  _wthrCurrentCity = cityName;
  var result = document.getElementById('wv5Result');
  if (!result) return;

  if (_wthrCache[cityName]) {
    _wv5Render(cityName, _wthrCache[cityName]);
    return;
  }

  result.innerHTML =
    '<div class="wv5-loading">' +
      '<div class="wv5-spin"></div>' +
      '<span>' + _e(cityName) + ' 날씨 불러오는 중</span>' +
    '</div>';

  var now = new Date();
  var todayStr = now.toISOString().split('T')[0];
  var end3 = new Date(now); end3.setDate(end3.getDate() + 3);
  var end3Str = end3.toISOString().split('T')[0];

  fetch(CTX_PATH + '/api/weather?city=' + encodeURIComponent(cityName)
      + '&startDate=' + todayStr + '&endDate=' + end3Str)
    .then(function(r) {
      if (!r.ok) return r.text().then(function(t){ return Promise.reject('HTTP ' + r.status); });
      return r.json();
    })
    .then(function(data) {
      if (_wthrCurrentCity !== cityName) return;
      _wthrCache[cityName] = data;
      _wv5Render(cityName, data);
    })
    .catch(function(err) {
      if (_wthrCurrentCity !== cityName) return;
      if (result) result.innerHTML =
        '<div class="wv5-err">' +
          '<div style="font-size:36px;margin-bottom:10px;">⚠️</div>' +
          '<div class="wv5-err-msg">날씨 정보를 불러오지 못했어요</div>' +
          '<button class="wv5-retry" onclick="delete _wthrCache[\'' + cityName + '\'];_wv5Search(\'' + cityName + '\')">다시 시도</button>' +
        '</div>';
    });
}

/* ══════════════════════════════════════════════
   4. 렌더링 — 단기예보(D~D+3) 4일 카드
══════════════════════════════════════════════ */
function _wv5Render(city, data) {
  var result = document.getElementById('wv5Result');
  if (!result) return;

  var days = (data.shortForecast || []).slice(0, 4); // D~D+3 최대 4일

  if (!days.length) {
    result.innerHTML =
      '<div class="wv5-err">' +
        '<div style="font-size:36px;margin-bottom:10px;">🌥</div>' +
        '<div class="wv5-err-msg">예보 데이터가 없어요</div>' +
        '<button class="wv5-retry" onclick="delete _wthrCache[\'' + city + '\'];_wv5Search(\'' + city + '\')">다시 시도</button>' +
      '</div>';
    return;
  }

  /* 오늘(day[0]) 대형 히어로 */
  var d0   = days[0];
  var rep0 = _wv5Rep(d0.hourly);
  var sky0 = rep0 && rep0.sky ? rep0.sky : null;

  var html =
    '<div class="wv5-hero">' +
      /* 왼쪽: 지역명 + 날씨 설명 + 기온 */
      '<div class="wv5-hero-left">' +
        '<div class="wv5-hero-region">' + _e(city) + '</div>' +
        '<div class="wv5-hero-date">' + _e(d0.dayLabel || '') + ' · 오늘</div>' +
        '<div class="wv5-hero-main">' +
          '<span class="wv5-hero-big-icon">' + _wv5Icon(sky0) + '</span>' +
          '<span class="wv5-hero-temp">' + _wv5V(rep0 && rep0.temp != null ? rep0.temp : null) + '<span class="wv5-hero-unit">°</span></span>' +
        '</div>' +
        '<div class="wv5-hero-sky">' + _e(sky0 || '--') + '</div>' +
      '</div>' +
      /* 오른쪽: 최고/최저/강수 */
      '<div class="wv5-hero-right">' +
        '<div class="wv5-stat">' +
          '<span class="wv5-stat-label">최고</span>' +
          '<span class="wv5-stat-val wv5-hi">' + _wv5V(d0.tmax, '°') + '</span>' +
        '</div>' +
        '<div class="wv5-stat">' +
          '<span class="wv5-stat-label">최저</span>' +
          '<span class="wv5-stat-val wv5-lo">' + _wv5V(d0.tmin, '°') + '</span>' +
        '</div>' +
        '<div class="wv5-stat">' +
          '<span class="wv5-stat-label">강수</span>' +
          '<span class="wv5-stat-val wv5-rn">' + _wv5V(rep0 && rep0.rainProb != null ? rep0.rainProb : null, '%') + '</span>' +
        '</div>' +
      '</div>' +
    '</div>';

  /* D+1 ~ D+3 가로 3칸 카드 */
  if (days.length > 1) {
    html += '<div class="wv5-3day">';
    days.slice(1).forEach(function(day) {
      var rep  = _wv5Rep(day.hourly);
      var sky  = rep && rep.sky ? rep.sky : null;
      var rp   = rep && rep.rainProb != null ? rep.rainProb : null;
      var rcls = rp == null ? '' : rp >= 60 ? 'high' : rp >= 30 ? 'mid' : 'low';
      var warn = rp != null && rp >= 60 ? ' wv5-card-warn' : '';

      html +=
        '<div class="wv5-card' + warn + '">' +
          '<div class="wv5-card-date">' + _e(day.dayLabel || '--') + '</div>' +
          '<div class="wv5-card-icon">' + _wv5Icon(sky) + '</div>' +
          '<div class="wv5-card-sky">' + _e(sky || '--') + '</div>' +
          '<div class="wv5-card-temps">' +
            '<span class="wv5-chi">' + _wv5V(day.tmax, '°') + '</span>' +
            '<span class="wv5-csep"> / </span>' +
            '<span class="wv5-clo">' + _wv5V(day.tmin, '°') + '</span>' +
          '</div>' +
          '<div class="wv5-card-rain ' + rcls + '">☔ ' + _wv5V(rp, '%') + '</div>' +
        '</div>';
    });
    html += '</div>';
  }

  result.innerHTML = html;
}

/* ══════════════════════════════════════════════
   5. 유틸
══════════════════════════════════════════════ */
function _wv5Icon(sky) {
  if (!sky) return '🌤';
  if (sky.includes('맑'))     return '☀️';
  if (sky.includes('구름많') || sky.includes('흐리고')) return '⛅';
  if (sky.includes('흐림') || sky.includes('흐린'))    return '☁️';
  if (sky.includes('소나기')) return '🌦';
  if (sky.includes('뇌우'))   return '⛈️';
  if (sky.includes('비'))     return '🌧';
  if (sky.includes('눈'))     return '❄️';
  return '🌤';
}
function _wv5Rep(hourly) {
  if (!hourly || !hourly.length) return null;
  return hourly.find(function(h){ return h.time==='12'||h.time==='09'; }) || hourly[0];
}
function _wv5V(v, suffix) {
  return (v == null || v === undefined) ? '--' : (v + (suffix || ''));
}
function _e(s) {
  if (s == null) return '';
  return String(s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;');
}

/* 하위 호환 — 구버전에서 _wthrSearch 호출하는 경우 대비 */
function _wthrSearch(c) { _wv5Search(c); }
