/**
 * workspace.map.js
 * ──────────────────────────────────────────────
 * 담당: 카카오맵 초기화 · 마커 · 검색 · 컨트롤 · 범례
 */

/* ══════════════════════════════
   도시별 기준 좌표 (국내+주요 해외)
══════════════════════════════ */
var _CITY_COORDS = {
  /* 국내 */
  '서울':   { lat: 37.5665, lng: 126.9780, level: 8 },
  '부산':   { lat: 35.1796, lng: 129.0756, level: 8 },
  '제주':   { lat: 33.4996, lng: 126.5312, level: 10 },
  '경주':   { lat: 35.8562, lng: 129.2247, level: 9 },
  '강릉':   { lat: 37.7519, lng: 128.8761, level: 9 },
  '속초':   { lat: 38.2070, lng: 128.5918, level: 9 },
  '여수':   { lat: 34.7604, lng: 127.6622, level: 9 },
  '인천':   { lat: 37.4563, lng: 126.7052, level: 9 },
  '대구':   { lat: 35.8714, lng: 128.6014, level: 9 },
  '대전':   { lat: 36.3504, lng: 127.3845, level: 9 },
  '광주':   { lat: 35.1595, lng: 126.8526, level: 9 },
  '수원':   { lat: 37.2636, lng: 127.0286, level: 9 },
  '전주':   { lat: 35.8242, lng: 127.1480, level: 9 },
  '춘천':   { lat: 37.8813, lng: 127.7298, level: 9 },
  '통영':   { lat: 34.8544, lng: 128.4330, level: 9 },
  '안동':   { lat: 36.5684, lng: 128.7294, level: 9 },
  '거제':   { lat: 34.8803, lng: 128.6213, level: 9 },
  '울산':   { lat: 35.5384, lng: 129.3114, level: 9 },
  '포항':   { lat: 36.0190, lng: 129.3435, level: 9 },
  '평창':   { lat: 37.3704, lng: 128.3920, level: 9 },
  '남해':   { lat: 34.8375, lng: 127.8924, level: 9 },
  '담양':   { lat: 35.3213, lng: 126.9878, level: 9 },
  /* 기본 (한국 중심) */
  'default': { lat: 36.5, lng: 127.5, level: 10 }
};

/* ══════════════════════════════
   전역 상태
══════════════════════════════ */
var _map        = null;
var _geocoder   = null; // 🟢 추가: 주소 검색용
var _markers    = [];
var _infowindow = null;

var DAY_COLORS = [
  '#89CFF0', '#FFB6C1', '#C2B8D9', '#A8C8E1',
  '#F6C9A0', '#A8E6CF', '#FADA9C', '#D5B8E8'
];


// 카카오 로드 
kakao.maps.load(initKakaoMap);

/* ══════════════════════════════
   초기화 함수 (DOMContentLoaded 대신 호출됨)
══════════════════════════════ */
function initKakaoMap() {
  var container = document.getElementById('kakaoMap');
  if (!container) return;

  /* 여행 도시 중 랜덤 1개로 중심 결정 */
  var cities  = (typeof KAKAO_CITIES !== 'undefined' && KAKAO_CITIES.length > 0) ? KAKAO_CITIES : [];
  var picked  = cities.length > 0 ? cities[Math.floor(Math.random() * cities.length)] : null;
  var coord   = (picked && _CITY_COORDS[picked]) ? _CITY_COORDS[picked] : _CITY_COORDS['default'];

  var options = {
    center: new kakao.maps.LatLng(coord.lat, coord.lng),
    level:  coord.level
  };
  _map = new kakao.maps.Map(container, options);
  
  // 🟢 추가: 주소 검색기 초기화 (사전에 없는 도시 검색용)
  _geocoder = new kakao.maps.services.Geocoder();

  // 🟢 추가: 사전에 없는 도시일 경우 카카오 API로 검색해서 이동
  if (picked && !_CITY_COORDS[picked]) {
      _geocoder.addressSearch(picked, function (result, status) {
          if (status === kakao.maps.services.Status.OK) {
              var newCoords = new kakao.maps.LatLng(result[0].y, result[0].x);
              _map.setCenter(newCoords);
              _map.setLevel(8);
          }
      });
  }

  // 🟢 추가: 회색 지도 버그 방지를 위한 강제 릴아웃 및 중앙 정렬 보정
  setTimeout(function() { 
      if(_map) {
          _map.relayout(); 
          _map.setCenter(new kakao.maps.LatLng(coord.lat, coord.lng)); 
      }
  }, 300);

  // 🟢 추가: 창 크기 변경 시 지도 깨짐 방지
  window.addEventListener('resize', function() {
      if (_map) _map.relayout();
  });

  /* 지도 클릭 시 인포윈도우 닫기 */
  kakao.maps.event.addListener(_map, 'click', function () {
    if (_infowindow) { _infowindow.close(); _infowindow = null; }
  });

  /* DB 일정 마커 초기화 */
  initMapMarkers();

  /* 범례 렌더 */
  renderMapLegend();

  /* 지도 검색 Enter 키 */
  var searchInput = document.getElementById('mapSearchInput');
  if (searchInput) {
    searchInput.addEventListener('keydown', function (e) {
      if (e.key === 'Enter') mapSearch();
    });
  }
}

/* ══════════════════════════════
   페이지 초기 마커 (JSP 주입 데이터)
══════════════════════════════ */
function initMapMarkers() {
  if (!_map) return;
  _markers.forEach(function (m) { m.setMap(null); });
  _markers = [];

  var places = (typeof KAKAO_PLACES !== 'undefined') ? KAKAO_PLACES : [];
  places.forEach(function (p) {
    addMapMarker(p.lat, p.lng, p.name, p.dayNum, p.order);
  });

  if (places.length >= 2) {
    mapFitAll();
  } else if (places.length === 1) {
    _map.setCenter(new kakao.maps.LatLng(places[0].lat, places[0].lng));
    _map.setLevel(8);
  }
}

/* ══════════════════════════════
   마커 추가 유틸
══════════════════════════════ */
function addMapMarker(lat, lng, name, dayNum, order) {
  if (!_map || !lat || !lng) return null;
  var color = DAY_COLORS[(dayNum - 1) % DAY_COLORS.length];

  var svg = [
    '<svg xmlns="http://www.w3.org/2000/svg" width="34" height="42" viewBox="0 0 34 42">',
    '<filter id="sh"><feDropShadow dx="0" dy="2" stdDeviation="2" flood-opacity="0.25"/></filter>',
    '<ellipse cx="17" cy="40" rx="6" ry="2" fill="rgba(0,0,0,0.15)"/>',
    '<path d="M17 2C9.82 2 4 7.82 4 15c0 9.25 13 25 13 25S30 24.25 30 15C30 7.82 24.18 2 17 2z"',
    ' fill="', color, '" filter="url(#sh)"/>',
    '<circle cx="17" cy="15" r="7" fill="white" opacity="0.9"/>',
    '<text x="17" y="19" text-anchor="middle" font-size="10" font-weight="bold" fill="#4A5568">', order, '</text>',
    '</svg>'
  ].join('');

  var markerImg = new kakao.maps.MarkerImage(
    'data:image/svg+xml;charset=utf-8,' + encodeURIComponent(svg),
    new kakao.maps.Size(34, 42),
    { offset: new kakao.maps.Point(17, 42) }
  );

  var marker = new kakao.maps.Marker({
    position: new kakao.maps.LatLng(lat, lng),
    image:    markerImg,
    map:      _map
  });

  var iw = new kakao.maps.InfoWindow({
    content: '<div style="padding:6px 12px;font-size:12px;font-weight:700;' +
             'white-space:nowrap;border-radius:6px;line-height:1.6;">' +
             'DAY' + dayNum + ' · ' + name + '</div>'
  });

  kakao.maps.event.addListener(marker, 'click', function () {
    if (_infowindow) _infowindow.close();
    iw.open(_map, marker);
    _infowindow = iw;
  });

  _markers.push(marker);
  return marker;
}

/* ══════════════════════════════
   장소 추가 시 외부 호출 (schedule.js → 여기)
══════════════════════════════ */
function mapAddMarkerExternal(lat, lng, name, dayNum, order) {
  if (!_map) return;
  addMapMarker(lat, lng, name, dayNum, order);
  _map.setCenter(new kakao.maps.LatLng(lat, lng));
  _map.setLevel(8);
}

/* ══════════════════════════════
   지도 컨트롤 버튼
══════════════════════════════ */
function mapZoomIn()  { if (_map) _map.setLevel(_map.getLevel() - 1); }
function mapZoomOut() { if (_map) _map.setLevel(_map.getLevel() + 1); }

function mapFitAll() {
  if (!_map || _markers.length === 0) return;
  var bounds = new kakao.maps.LatLngBounds();
  _markers.forEach(function (m) { bounds.extend(m.getPosition()); });
  _map.setBounds(bounds);
}

function mapMoveToMyLocation() {
  if (!navigator.geolocation) {
    if (typeof showToast === 'function') showToast('⚠️ 브라우저가 위치 정보를 지원하지 않아요');
    return;
  }
  navigator.geolocation.getCurrentPosition(
    function (pos) {
      if (!_map) return;
      _map.setCenter(new kakao.maps.LatLng(pos.coords.latitude, pos.coords.longitude));
      _map.setLevel(5);
      if (typeof showToast === 'function') showToast('📍 내 위치로 이동했어요');
    },
    function () {
      if (typeof showToast === 'function') showToast('⚠️ 위치 정보 접근이 거부됐어요');
    }
  );
}

/* ══════════════════════════════
   지도 내 장소 검색
══════════════════════════════ */
var _tempMarkers = []; // 검색용 임시 마커
var _mapSearchTimer = null; // 디바운스 타이머 변수

// 입력이 끝나고 0.3초 뒤에만 실제 검색 실행
function debounceMapSearch() {
  var input = document.getElementById('mapSearchInput');
  var q = input ? input.value.trim() : '';
  var resultBox = document.getElementById('mapSearchResults');

  // 검색어가 다 지워지면 즉시 드롭다운 닫기
  if (!q) {
    if (resultBox) resultBox.style.display = 'none';
    clearTimeout(_mapSearchTimer);
    return;
  }

  // 이전 타이머 취소 후 새 타이머 설정 (300ms)
  clearTimeout(_mapSearchTimer);
  _mapSearchTimer = setTimeout(function() {
    mapSearch();
  }, 300);
}


function mapSearch() {
  var input = document.getElementById('mapSearchInput');
  var q     = input ? input.value.trim() : '';
  if (!q) return;
  if (!_map) { if (typeof showToast === 'function') showToast('⚠️ 지도가 아직 로딩 중이에요'); return; }

  var ps = new kakao.maps.services.Places();
  ps.keywordSearch(q, function (data, status) {
    var resultBox = document.getElementById('mapSearchResults');
    if (status === kakao.maps.services.Status.OK && data.length > 0) {
      // 🟢 검색 결과를 리스트로 쫙 뿌려줍니다!
      var html = '';
      data.forEach(function(p) {
        // 이스케이프 처리 (이름, 주소)
        var safeName = p.place_name.replace(/'/g, "\\'");
        var safeAddr = p.address_name.replace(/'/g, "\\'");
        html += '<div style="padding:12px 16px; border-bottom:1px solid #f1f5f9; cursor:pointer;" ' +
                'onclick="selectMapSearchResult(' + p.y + ', ' + p.x + ', \'' + safeName + '\', \'' + safeAddr + '\')" ' +
                'onmouseover="this.style.background=\'#f8fafc\'" onmouseout="this.style.background=\'none\'">';
        html += '  <div style="font-size:14px; font-weight:700; color:#1a202c;">' + p.place_name + '</div>';
        html += '  <div style="font-size:12px; color:#a0aec0; margin-top:4px;">' + p.address_name + '</div>';
        html += '</div>';
      });
      resultBox.innerHTML = html;
      resultBox.style.display = 'block';
    } else {
      resultBox.style.display = 'none';
      if (typeof showToast === 'function') showToast('😥 검색 결과가 없어요');
    }
  });
}

// 리스트에서 장소를 클릭했을 때 (마커 찍기 + 말풍선 + 일정 추가)
function selectMapSearchResult(lat, lng, name, address) {
  var latlng = new kakao.maps.LatLng(lat, lng);
  _map.setCenter(latlng);
  _map.setLevel(4);

  // 기존 임시 마커 지우기
  _tempMarkers.forEach(function(m) { m.setMap(null); });
  _tempMarkers = [];

  // 보라색 핀 마커 (커스텀 SVG)
  var svg = [
    '<svg xmlns="http://www.w3.org/2000/svg" width="32" height="40" viewBox="0 0 32 40">',
    '<ellipse cx="16" cy="38" rx="5" ry="2" fill="rgba(0,0,0,0.15)"/>',
    '<path d="M16 2C9.4 2 4 7.4 4 14c0 8.6 12 24 12 24S28 22.6 28 14C28 7.4 22.6 2 16 2z" fill="#667EEA"/>',
    '<circle cx="16" cy="14" r="6" fill="white" opacity="0.9"/>',
    '<text x="16" y="18" text-anchor="middle" font-size="9" font-weight="bold" fill="#667EEA">📍</text>',
    '</svg>'
  ].join('');
  var markerImg = new kakao.maps.MarkerImage(
    'data:image/svg+xml;charset=utf-8,' + encodeURIComponent(svg),
    new kakao.maps.Size(32, 40), { offset: new kakao.maps.Point(16, 40) }
  );
  var marker = new kakao.maps.Marker({ position: latlng, image: markerImg, map: _map });
  _tempMarkers.push(marker);

  // 말풍선 - "일정에 추가" 버튼 포함
  var safeN = name.replace(/\\/g, '\\\\').replace(/'/g, "\\'").replace(/"/g, '&quot;');
  var safeA = address.replace(/\\/g, '\\\\').replace(/'/g, "\\'").replace(/"/g, '&quot;');
  var iwContent =
    '<div style="padding:14px;width:230px;font-family:Pretendard,sans-serif;">' +
    '<div style="font-weight:800;font-size:14px;color:#2d3748;margin-bottom:3px;' +
         'white-space:nowrap;overflow:hidden;text-overflow:ellipsis;">' + name + '</div>' +
    '<div style="font-size:12px;color:#718096;margin-bottom:12px;' +
         'white-space:nowrap;overflow:hidden;text-overflow:ellipsis;">' + address + '</div>' +
    '<button onclick="openDayPickerForMap(\'' + safeN + '\', \'' + safeA + '\', ' + lat + ', ' + lng + ')" ' +
    'style="width:100%;padding:9px 0;background:linear-gradient(135deg,#89CFF0,#B8A9D9);' +
           'color:#fff;border:none;border-radius:8px;font-weight:700;font-size:13px;' +
           'cursor:pointer;letter-spacing:0.3px;">+ 일정에 추가</button>' +
    '</div>';

  if (_infowindow) _infowindow.close();
  _infowindow = new kakao.maps.InfoWindow({ content: iwContent });
  _infowindow.open(_map, marker);

  // 검색 드롭다운 닫기
  var rb = document.getElementById('mapSearchResults');
  if (rb) rb.style.display = 'none';
}

// 말풍선의 "일정에 추가" 클릭 → recommend.js의 dayPickerPopup 공유
window.openDayPickerForMap = function(name, addr, lat, lng) {
  if (_infowindow) _infowindow.close();

  // _selectedRecPlace: recommend.js에 선언된 공유 변수
  _selectedRecPlace = { name: name, address: addr, lat: lat, lng: lng, placeId: null };

  var popup = document.getElementById('dayPickerPopup');
  if (popup) {
    // 화면 중앙에 고정 표시
    popup.style.position  = 'fixed';
    popup.style.top       = '50%';
    popup.style.left      = '50%';
    popup.style.transform = 'translate(-50%,-50%)';
    popup.style.zIndex    = '9999';
    popup.style.display   = 'block';
  } else {
    if (typeof showToast === 'function') showToast('⚠️ 일정 추가 팝업을 찾을 수 없어요');
  }
};

/* ══════════════════════════════
   범례 렌더
══════════════════════════════ */
function renderMapLegend() {
  var el = document.getElementById('mapLegend');
  if (!el) return;
  var dayNums = (typeof KAKAO_DAY_NUMS !== 'undefined') ? KAKAO_DAY_NUMS : [];
  el.innerHTML = dayNums.map(function (d) {
    var c = DAY_COLORS[(d - 1) % DAY_COLORS.length];
    // 🟢 수정: if(typeof mapFilterDay === 'function') 로 에러 방지 처리 추가
    return '<div class="legend-item" onclick="if(typeof mapFilterDay===\'function\') mapFilterDay(' + d + ')" style="cursor:pointer;">' +
      '<div class="legend-dot" style="background:' + c + ';width:12px;height:12px;border-radius:50%;display:inline-block;margin-right:4px;"></div>' +
      'Day ' + d + '</div>';
  }).join('');
}

/* ══════════════════════════════
   크기 재계산 (뷰 모드 전환 시)
   ← ui.js setViewMode → triggerMapResize() 호출
══════════════════════════════ */
function triggerMapResize() {
  if (_map) {
    kakao.maps.event.trigger(_map, 'resize');
  }
}

/* ══════════════════════════════
   에러 표시
══════════════════════════════ */
function _showMapError(msg) {
  var el = document.getElementById('kakaoMap');
  if (!el) return;
  el.innerHTML =
    '<div style="display:flex;flex-direction:column;align-items:center;justify-content:center;' +
    'height:100%;color:#A0AEC0;gap:12px;padding:32px;text-align:center;">' +
    '<div style="font-size:48px">🗺️</div>' +
    '<div style="font-size:14px;font-weight:700;color:#4A5568;line-height:1.8;">' + msg + '</div>' +
    '</div>';
}

// 검색창 외부 클릭 시 검색 결과 드롭다운 닫기
document.addEventListener('click', function(e) {
  var container = document.querySelector('.map-search-bar');
  var resultBox = document.getElementById('mapSearchResults');
  if (container && resultBox && !container.contains(e.target) && e.target !== resultBox) {
    resultBox.style.display = 'none';
  }
});