/**
 * workspace.map.js
 * ──────────────────────────────────────────────
 * 담당: 카카오맵 초기화 · 마커 · 검색 · 컨트롤 · 범례
 */

/* ══════════════════════════════
   도시별 기준 좌표 (국내+주요 해외)
══════════════════════════════ */
var _CITY_COORDS = {
	/* 광역시 / 특별시 */
	  '서울':   { lat: 37.5665, lng: 126.9780, level: 8 },
	  '부산':   { lat: 35.1796, lng: 129.0756, level: 8 },
	  '인천':   { lat: 37.4563, lng: 126.7052, level: 9 },
	  '대전':   { lat: 36.3504, lng: 127.3845, level: 9 },
	  '대구':   { lat: 35.8714, lng: 128.6014, level: 9 },
	  '광주':   { lat: 35.1595, lng: 126.8526, level: 9 },
	  '울산':   { lat: 35.5384, lng: 129.3114, level: 9 },
	  '세종':   { lat: 36.4800, lng: 127.2890, level: 8 },

	  /* 도 단위 (넓게 보이도록 level을 10~12로 세팅) */
	  '제주':   { lat: 33.3616, lng: 126.5291, level: 10 }, // 한라산 중심 (제주도 전체 뷰)
	  '강원':   { lat: 37.8228, lng: 128.1555, level: 11 }, // 강원도 중앙 뷰
	  '경기':   { lat: 37.4000, lng: 127.1000, level: 10 }, // 경기도 중앙 뷰
	  '충청':   { lat: 36.6000, lng: 127.3000, level: 11 }, // 충청남북도 중앙 뷰
	  '전라':   { lat: 35.3000, lng: 126.9000, level: 11 }, // 전라남북도 중앙 뷰
	  '경상':   { lat: 35.8500, lng: 128.5600, level: 11 }, // 경상남북도 중앙 뷰
	  
  /* 기본 (한국 중심) */
  'default': { lat: 36.5, lng: 127.5, level: 10 }
};

/* ══════════════════════════════
   전역 상태
══════════════════════════════ */
var _map        = null;
var _geocoder   = null;
var _markers    = [];           // 순서용 배열 (fitBounds 등)
var _markerMap  = {};           // itemId → {marker, iw, dayNum, order, name, lat, lng}
var _infowindow = null;

// DAY별 색상 — 8가지 순환 (명확히 구분되는 컬러)
var DAY_COLORS = [
  '#FF6B6B', '#82E0AA', '#45B7D1', '#FFA07A',
  '#98D8C8', '#F7DC6F', '#BB8FCE', '#4ECDC4' 
];


// 카카오 로드 
kakao.maps.load(initKakaoMap);

/* ══════════════════════════════
   초기화 함수 (DOMContentLoaded 대신 호출됨)
══════════════════════════════ */
function initKakaoMap() {
  var container = document.getElementById('kakaoMap');
  if (!container) return;

  var cities  = (typeof KAKAO_CITIES !== 'undefined' && KAKAO_CITIES.length > 0) ? KAKAO_CITIES : [];
  var picked  = cities.length > 0 ? cities[Math.floor(Math.random() * cities.length)] : null;
  var coord   = (picked && _CITY_COORDS[picked]) ? _CITY_COORDS[picked] : _CITY_COORDS['default'];

  var options = {
    center: new kakao.maps.LatLng(coord.lat, coord.lng),
    level:  coord.level
  };
  _map = new kakao.maps.Map(container, options);
  
  _geocoder = new kakao.maps.services.Geocoder();

  if (picked && !_CITY_COORDS[picked]) {
      _geocoder.addressSearch(picked, function (result, status) {
          if (status === kakao.maps.services.Status.OK) {
              var newCoords = new kakao.maps.LatLng(result[0].y, result[0].x);
              _map.setCenter(newCoords);
              _map.setLevel(8);
          }
      });
  }

  setTimeout(function() { 
      if(_map) {
          _map.relayout(); 
          _map.setCenter(new kakao.maps.LatLng(coord.lat, coord.lng)); 
      }
  }, 300);

  window.addEventListener('resize', function() {
      if (_map) _map.relayout();
  });

  kakao.maps.event.addListener(_map, 'click', function () {
    if (_infowindow) { _infowindow.close(); _infowindow = null; }
  });

  initMapMarkers();
  renderMapLegend();

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
    addMapMarker(p.lat, p.lng, p.name, p.dayNum, p.order,
      p.itemId || null, p.category || 'ETC', p.address || '');
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
function addMapMarker(lat, lng, name, dayNum, order, itemId, category, address) {
  if (!_map || !lat || !lng) return null;
  var color = DAY_COLORS[(dayNum - 1) % DAY_COLORS.length];
  var catInfo = (typeof window.getTripanCategory === 'function') ? window.getTripanCategory(category) : { icon: '📍', label: category || '장소' };

  var finalLat = lat, finalLng = lng;
  var OFFSET_STEP = 0.00008; // 약 8m
  var sameCoordCount = _markers.filter(function(m) {
    return Math.abs(m._lat - lat) < 0.000001 && Math.abs(m._lng - lng) < 0.000001;
  }).length;
  if (sameCoordCount > 0) {
    // 겹친 개수만큼 시계방향으로 조금씩 밀어냄
    var angle = (sameCoordCount * 90) * (Math.PI / 180);
    finalLat = lat + OFFSET_STEP * Math.cos(angle);
    finalLng = lng + OFFSET_STEP * Math.sin(angle);
  }

  var svg = [
    '<svg xmlns="http://www.w3.org/2000/svg" width="36" height="46" viewBox="0 0 36 46">',
    '<filter id="sh' + (itemId||order) + '">',
    '<feDropShadow dx="0" dy="3" stdDeviation="2.5" flood-opacity="0.28"/></filter>',
    '<ellipse cx="18" cy="44" rx="6" ry="2.5" fill="rgba(0,0,0,0.15)"/>',
    '<path d="M18 2C10.27 2 4 8.27 4 16c0 10 14 28 14 28S32 26 32 16C32 8.27 25.73 2 18 2z"',
    ' fill="', color, '" filter="url(#sh', (itemId||order), ')"/>',
    '<circle cx="18" cy="16" r="9" fill="white" opacity="0.95"/>',
    '<text x="18" y="20" text-anchor="middle" font-size="9" font-weight="800" fill="#2D3748">', order, '</text>',
    '</svg>'
  ].join('');

  var markerImg = new kakao.maps.MarkerImage(
    'data:image/svg+xml;charset=utf-8,' + encodeURIComponent(svg),
    new kakao.maps.Size(36, 46),
    { offset: new kakao.maps.Point(18, 46) }
  );

  var marker = new kakao.maps.Marker({
    position: new kakao.maps.LatLng(finalLat, finalLng),
    image:    markerImg,
    map:      _map
  });

  var addrHtml = address ? '<div style="font-size:11px;color:#718096;margin-top:2px;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;max-width:220px;">📍 ' + _escIw(address) + '</div>' : '';
  var iwContent =
    '<div style="padding:14px 16px;min-width:200px;max-width:260px;font-family:Pretendard,sans-serif;border-radius:14px;">' +
      '<div style="display:flex;align-items:center;gap:6px;margin-bottom:6px;">' +
        '<div style="width:28px;height:28px;border-radius:50%;background:' + color + ';display:flex;align-items:center;justify-content:center;font-size:13px;font-weight:800;color:#fff;flex-shrink:0;">' + order + '</div>' +
        '<div>' +
          '<div style="font-size:11px;font-weight:700;color:' + color.replace('#','') + ';letter-spacing:.3px;">DAY ' + dayNum + '</div>' +
          '<div style="font-size:13px;font-weight:800;color:#1A202C;line-height:1.3;">' + _escIw(name) + '</div>' +
        '</div>' +
      '</div>' +
      (addrHtml ? addrHtml : '') +
      '<div style="display:flex;gap:6px;margin-top:10px;">' +
        '<span style="font-size:10px;font-weight:700;padding:3px 9px;border-radius:50px;background:rgba(0,0,0,.06);color:#4A5568;">' + catInfo.icon + ' ' + catInfo.label + '</span>' +
        '<button onclick="mapFlyTo(' + lat + ',' + lng + ')" style="flex:1;padding:5px 8px;border:none;border-radius:8px;background:linear-gradient(135deg,#89CFF0,#B8A9D9);color:#fff;font-size:11px;font-weight:700;cursor:pointer;">🗺️ 지도 중심</button>' +
      '</div>' +
    '</div>';

  var iw = new kakao.maps.InfoWindow({ content: iwContent, removable: true });

  kakao.maps.event.addListener(marker, 'click', function () {
    if (_infowindow) _infowindow.close();
    iw.open(_map, marker);
    _infowindow = iw;
  });

  marker._itemId  = itemId;
  marker._dayNum  = parseInt(dayNum);
  marker._order   = parseInt(order);
  marker._name    = name;
  marker._lat     = lat;
  marker._lng     = lng;

  _markers.push(marker);
  if (itemId) _markerMap[String(itemId)] = { marker: marker, iw: iw };
  return marker;
}

function _escIw(str) {
  if (!str) return '';
  return String(str).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;');
}

window.mapFlyTo = function(lat, lng) {
  if (!_map) return;
  var latlng   = new kakao.maps.LatLng(lat, lng);
  var curLevel = _map.getLevel();

  if (curLevel <= 4) {
    // 이미 충분히 가까우면 부드럽게 이동만
    _map.panTo(latlng);
  } else {
    // 멀리서 볼 때: 먼저 setCenter+setLevel로 즉시 이동 후 panTo 효과
    // panTo는 현재 뷰포트 기반이라 멀리 있으면 이상하게 튀므로 setCenter 사용
    _map.setCenter(latlng);
    _map.setLevel(4, { animate: { duration: 350 } });
  }
};

function mapAddMarkerExternal(lat, lng, name, dayNum, order, itemId, category, address) {
  if (!_map) return;
  addMapMarker(lat, lng, name, dayNum, order, itemId, category, address);
  _map.setCenter(new kakao.maps.LatLng(lat, lng));
  _map.setLevel(7);
}

function mapRemoveMarker(itemId) {
  var key = String(itemId);
  var entry = _markerMap[key];
  if (!entry) return;
  entry.marker.setMap(null);
  if (entry.iw) entry.iw.close();
  _markers = _markers.filter(function(m) { return m !== entry.marker; });
  delete _markerMap[key];
  _reorderMarkersForDay(entry.marker._dayNum);
}

function _reorderMarkersForDay(dayNum) {
  var list = document.getElementById('places-' + dayNum);
  if (!list) return;
  
  var cards = Array.from(list.querySelectorAll('.place-card'));
  var color = DAY_COLORS[(dayNum - 1) % DAY_COLORS.length];

  cards.forEach(function(card, idx) {
    var itemId = card.getAttribute('data-id');
    if (!itemId) return;
    var entry = _markerMap[String(itemId)];
    
    if (entry && entry.marker) {
      var m = entry.marker;
      var newOrder = idx + 1;
      m._dayNum = parseInt(dayNum);
      m._order  = newOrder;

      // ── 마커 SVG 이미지 갱신 ──────────────────────────────
      var svg = [
        '<svg xmlns="http://www.w3.org/2000/svg" width="36" height="46" viewBox="0 0 36 46">',
        '<ellipse cx="18" cy="44" rx="6" ry="2.5" fill="rgba(0,0,0,0.15)"/>',
        '<path d="M18 2C10.27 2 4 8.27 4 16c0 10 14 28 14 28S32 26 32 16C32 8.27 25.73 2 18 2z" fill="', color, '"/>',
        '<circle cx="18" cy="16" r="9" fill="white" opacity="0.95"/>',
        '<text x="18" y="20" text-anchor="middle" font-size="9" font-weight="800" fill="#2D3748">', newOrder, '</text>',
        '</svg>'
      ].join('');
      
      var img = new kakao.maps.MarkerImage(
        'data:image/svg+xml;charset=utf-8,' + encodeURIComponent(svg),
        new kakao.maps.Size(36, 46), { offset: new kakao.maps.Point(18, 46) }
      );
      m.setImage(img);

      // ── ✅ InfoWindow content도 번호 동기화 ───────────────
      // D&D 후 마커 클릭 시 말풍선에 예전 번호가 표시되던 버그 수정
      var address  = card.getAttribute('data-address') || '';
      var catRaw   = card.getAttribute('data-category') || 'ETC';
      var catInfo  = (typeof window.getTripanCategory === 'function')
                     ? window.getTripanCategory(catRaw)
                     : { icon: '📍', label: catRaw };
      var lat = m._lat, lng = m._lng, name = m._name;

      var addrHtml = address
        ? '<div style="font-size:11px;color:#718096;margin-top:2px;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;max-width:220px;">📍 ' + _escIw(address) + '</div>'
        : '';

      var newIwContent =
        '<div style="padding:14px 16px;min-width:200px;max-width:260px;font-family:Pretendard,sans-serif;border-radius:14px;">' +
          '<div style="display:flex;align-items:center;gap:6px;margin-bottom:6px;">' +
            '<div style="width:28px;height:28px;border-radius:50%;background:' + color + ';display:flex;align-items:center;justify-content:center;font-size:13px;font-weight:800;color:#fff;flex-shrink:0;">' + newOrder + '</div>' +
            '<div>' +
              '<div style="font-size:11px;font-weight:700;color:#4A5568;letter-spacing:.3px;">DAY ' + dayNum + '</div>' +
              '<div style="font-size:13px;font-weight:800;color:#1A202C;line-height:1.3;">' + _escIw(name) + '</div>' +
            '</div>' +
          '</div>' +
          addrHtml +
          '<div style="display:flex;gap:6px;margin-top:10px;">' +
            '<span style="font-size:10px;font-weight:700;padding:3px 9px;border-radius:50px;background:rgba(0,0,0,.06);color:#4A5568;">' + catInfo.icon + ' ' + catInfo.label + '</span>' +
            '<button onclick="mapFlyTo(' + lat + ',' + lng + ')" style="flex:1;padding:5px 8px;border:none;border-radius:8px;background:linear-gradient(135deg,#89CFF0,#B8A9D9);color:#fff;font-size:11px;font-weight:700;cursor:pointer;">🗺️ 지도 중심</button>' +
          '</div>' +
        '</div>';

      var newIw = new kakao.maps.InfoWindow({ content: newIwContent, removable: true });
      // 기존 열려있던 창 닫기
      if (entry.iw) { try { entry.iw.close(); } catch(e) {} }
      // 클릭 이벤트 재바인딩
      kakao.maps.event.removeListener(m, 'click');
      kakao.maps.event.addListener(m, 'click', (function(marker, iw) {
        return function() {
          if (_infowindow) _infowindow.close();
          iw.open(_map, marker);
          _infowindow = iw;
        };
      })(m, newIw));
      entry.iw = newIw;
    }
  });
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
var _tempMarkers = []; 
var _mapSearchTimer = null; 

function debounceMapSearch() {
  var input = document.getElementById('mapSearchInput');
  var q = input ? input.value.trim() : '';
  var resultBox = document.getElementById('mapSearchResults');

  if (!q) {
    if (resultBox) resultBox.style.display = 'none';
    clearTimeout(_mapSearchTimer);
    return;
  }
  clearTimeout(_mapSearchTimer);
  _mapSearchTimer = setTimeout(function() { mapSearch(); }, 300);
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
      var html = '';
      data.forEach(function(p) {
        var safeName = p.place_name.replace(/'/g, "\\'");
        var safeAddr = (p.address_name || '').replace(/'/g, "\\'");
        var safeCat  = (p.category_group_name || '장소').replace(/'/g, "\\'"); 

        html += '<div style="padding:12px 16px; border-bottom:1px solid #f1f5f9; cursor:pointer;" ' +
                'onclick="selectMapSearchResult(' + p.y + ', ' + p.x + ', \'' + safeName + '\', \'' + safeAddr + '\', \'' + safeCat + '\')" ' +
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

// 전역 변수로 선택한 장소 데이터 임시 저장 (문자열 충돌 완벽 방지)
window._currentMapPlace = null;

function selectMapSearchResult(lat, lng, name, address, categoryName) { 
  var latlng = new kakao.maps.LatLng(lat, lng);
  _map.setCenter(latlng);
  _map.setLevel(4);
  _tempMarkers.forEach(function(m) { m.setMap(null); });
  _tempMarkers = [];

  var svg = [
    '<svg xmlns="http://www.w3.org/2000/svg" width="32" height="40" viewBox="0 0 32 40">',
    '<ellipse cx="16" cy="38" rx="5" ry="2" fill="rgba(0,0,0,0.15)"/>',
    '<path d="M16 2C9.4 2 4 7.4 4 14c0 8.6 12 24 12 24S28 22.6 28 14C28 7.4 22.6 2 16 2z" fill="#667EEA"/>',
    '<circle cx="16" cy="14" r="6" fill="white" opacity="0.9"/>',
    '<text x="16" y="18" text-anchor="middle" font-size="9" font-weight="bold" fill="#667EEA">📍</text>',
    '</svg>'
  ].join('');
  var markerImg = new kakao.maps.MarkerImage('data:image/svg+xml;charset=utf-8,' + encodeURIComponent(svg), new kakao.maps.Size(32, 40), { offset: new kakao.maps.Point(16, 40) });
  var marker = new kakao.maps.Marker({ position: latlng, image: markerImg, map: _map });
  _tempMarkers.push(marker);

  window._currentMapPlace = { name: name, addr: address, lat: lat, lng: lng, cat: categoryName };

  var iwContent =
    '<div style="padding:14px;width:230px;font-family:Pretendard,sans-serif;">' +
    '<div style="font-weight:800;font-size:14px;color:#2d3748;margin-bottom:3px;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;">' + name + '</div>' +
    '<div style="font-size:12px;color:#718096;margin-bottom:12px;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;">' + address + '</div>' +
    '<button onclick="triggerMapAddModal()" style="width:100%;padding:9px 0;background:linear-gradient(135deg,#89CFF0,#B8A9D9);color:#fff;border:none;border-radius:8px;font-weight:700;font-size:13px;cursor:pointer;letter-spacing:0.3px;">+ 일정에 추가</button>' +
    '</div>';

  if (_infowindow) _infowindow.close();
  _infowindow = new kakao.maps.InfoWindow({ content: iwContent });
  _infowindow.open(_map, marker);

  var rb = document.getElementById('mapSearchResults');
  if (rb) rb.style.display = 'none';
}

window.triggerMapAddModal = function() {
    var p = window._currentMapPlace;
    if (!p) return;

    var oldModal = document.getElementById('customMapAddModal');
    if (oldModal) oldModal.remove();

    var maxDay = (typeof KAKAO_DAY_NUMS !== 'undefined') ? KAKAO_DAY_NUMS.length : 1;
    if(maxDay < 1) maxDay = 1;
    var dayOptions = '';
    for(var i=1; i<=maxDay; i++) {
        var sel = (i === (window.currentAddDay||1)) ? 'selected' : '';
        dayOptions += '<option value="' + i + '" ' + sel + '>DAY ' + i + '</option>';
    }

    var modalHtml = 
    '<div id="customMapAddModal" class="modal-overlay" style="display:flex;align-items:center;justify-content:center;position:fixed;top:0;left:0;width:100%;height:100%;background:rgba(0,0,0,0.5);z-index:9999;">' +
        '<div class="modal-box" style="background:#fff;padding:24px;border-radius:16px;width:320px;box-shadow:0 10px 25px rgba(0,0,0,0.1);font-family:Pretendard,sans-serif;">' +
            '<div style="font-size:16px;font-weight:800;margin-bottom:16px;color:#2D3748;">📌 일정에 추가하기</div>' +
            '<div style="font-size:13px;color:#718096;margin-bottom:16px;line-height:1.4;">' +
                '<strong>' + p.name + '</strong><br>' + p.addr +
            '</div>' +
            '<div style="margin-bottom:12px;">' +
                '<label style="font-size:12px;font-weight:700;color:#4A5568;display:block;margin-bottom:6px;">추가할 날짜 (DAY)</label>' +
                '<select id="customMapAddDay" style="width:100%;padding:10px;border-radius:8px;border:1px solid #E2E8F0;font-size:14px;outline:none;font-family:Pretendard,sans-serif;">' + dayOptions + '</select>' +
            '</div>' +
            '<div style="margin-bottom:20px;">' +
                '<label style="font-size:12px;font-weight:700;color:#4A5568;display:block;margin-bottom:6px;">카테고리</label>' +
                '<select id="customMapAddCat" style="width:100%;padding:10px;border-radius:8px;border:1px solid #E2E8F0;font-size:14px;outline:none;font-family:Pretendard,sans-serif;">' +
                    '<option value="NONE">⭐ 나만의 장소 (기타)</option>' +
                    '<option value="RESTAURANT">🍽️ 맛집</option>' +
                    '<option value="ACCOMMODATION">🏨 숙소</option>' +
                    '<option value="TOUR">⛰️ 관광지</option>' +
                    '<option value="CULTURE">🎭 문화</option>' +
                    '<option value="LEISURE">🏄 레포츠</option>' +
                    '<option value="SHOPPING">🛍️ 쇼핑</option>' +
                    '<option value="FESTIVAL">🎉 축제</option>' +
                '</select>' +
            '</div>' +
            '<div style="display:flex;gap:10px;">' +
                '<button onclick="document.getElementById(\'customMapAddModal\').remove()" style="flex:1;padding:12px;border-radius:8px;border:none;background:#EDF2F7;color:#4A5568;font-weight:700;cursor:pointer;">취소</button>' +
                '<button onclick="executeMapAdd()" style="flex:1;padding:12px;border-radius:8px;border:none;background:linear-gradient(135deg,#89CFF0,#B8A9D9);color:#fff;font-weight:700;cursor:pointer;">추가하기</button>' +
            '</div>' +
        '</div>' +
    '</div>';
    
    document.body.insertAdjacentHTML('beforeend', modalHtml);
    
    // 카테고리 자동 매칭
    var catSelect = document.getElementById('customMapAddCat');
    var rawCat = (p.cat || '').toUpperCase();
    if (rawCat.includes('음식') || rawCat.includes('RESTAURANT')) catSelect.value = 'RESTAURANT';
    else if (rawCat.includes('숙박') || rawCat.includes('ACCOMMODATION')) catSelect.value = 'ACCOMMODATION';
    else if (rawCat.includes('관광') || rawCat.includes('TOUR')) catSelect.value = 'TOUR';
    else if (rawCat.includes('문화') || rawCat.includes('CULTURE')) catSelect.value = 'CULTURE';
    else if (rawCat.includes('레포츠') || rawCat.includes('LEISURE')) catSelect.value = 'LEISURE';
    else if (rawCat.includes('쇼핑') || rawCat.includes('SHOPPING')) catSelect.value = 'SHOPPING';
    else if (rawCat.includes('축제') || rawCat.includes('FESTIVAL')) catSelect.value = 'FESTIVAL';
};

window.executeMapAdd = function() {
    var p = window._currentMapPlace;
    var day = document.getElementById('customMapAddDay').value;
    var cat = document.getElementById('customMapAddCat').value; // NONE, RESTAURANT 등 영문 DB값으로 저장
    
    document.getElementById('customMapAddModal').remove();
    if (_infowindow) _infowindow.close();

    if (typeof addPlaceToDay !== 'function') return;

    // 검색용 임시 핀 제거
    _tempMarkers.forEach(function(m) { m.setMap(null); });
    _tempMarkers = [];
    window.currentAddDay = parseInt(day);

    // ★ 카테고리가 NONE(나만의 장소)이면 /api/places/my 에 먼저 등록해서
    //   "나만의" 탭에서 바로 검색·재사용 가능하도록 저장
    if (cat === 'NONE') {
        fetch(CTX_PATH + '/api/places/my', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                placeName : p.name,
                address   : p.addr   || '',
                latitude  : p.lat    || 0,
                longitude : p.lng    || 0,
                category  : 'NONE'
            })
        })
        .then(function(r) { return r.ok ? r.json() : null; })
        .catch(function() { return null; }) // 실패해도 일정 추가는 진행
        .then(function(saved) {
            // saved.place.placeId 가 있으면 apiPlaceId 로 넘겨서 중복 방지
            var pid = (saved && saved.place && saved.place.placeId) ? String(saved.place.placeId) : null;
            addPlaceToDay(null, p.name, p.addr, p.lat, p.lng, pid, cat);
        });
    } else {
        addPlaceToDay(null, p.name, p.addr, p.lat, p.lng, null, cat);
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
    return '<div class="legend-item" onclick="if(typeof mapFilterDay===\'function\') mapFilterDay(' + d + ')" style="cursor:pointer;">' +
      '<div class="legend-dot" style="background:' + c + ';width:12px;height:12px;border-radius:50%;display:inline-block;margin-right:4px;"></div>' +
      'Day ' + d + '</div>';
  }).join('');
}

function triggerMapResize() {
  if (_map) kakao.maps.event.trigger(_map, 'resize');
}

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

document.addEventListener('click', function(e) {
  var container = document.querySelector('.map-search-bar');
  var resultBox = document.getElementById('mapSearchResults');
  if (container && resultBox && !container.contains(e.target) && e.target !== resultBox) {
    resultBox.style.display = 'none';
  }
});