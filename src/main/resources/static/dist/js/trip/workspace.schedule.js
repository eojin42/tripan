/**
 * workspace.schedule.js  ★ ULTIMATE V3
 */

// 🟢 [전역] 카테고리 영문 DB값 ➔ 예쁜 한글 UI 변환기
window.getTripanCategory = function(cat) {
  var c = (cat || '').toUpperCase();
  if (c.includes('RESTAURANT') || c.includes('음식') || c.includes('맛집')) return { icon: '🍽️', label: '맛집', value: 'RESTAURANT' };
  if (c.includes('ACCOMMODATION') || c.includes('STAY') || c.includes('숙박') || c.includes('숙소') || c.includes('호텔')) return { icon: '🏨', label: '숙소', value: 'ACCOMMODATION' };
  if (c.includes('TOUR') || c.includes('관광') || c.includes('ATTRACTION')) return { icon: '⛰️', label: '관광', value: 'TOUR' };
  if (c.includes('CULTURE') || c.includes('문화')) return { icon: '🎭', label: '문화', value: 'CULTURE' };
  if (c.includes('LEISURE') || c.includes('레포츠')) return { icon: '🏄', label: '레포츠', value: 'LEISURE' };
  if (c.includes('SHOPPING') || c.includes('쇼핑')) return { icon: '🛍️', label: '쇼핑', value: 'SHOPPING' };
  if (c.includes('FESTIVAL') || c.includes('축제')) return { icon: '🎉', label: '축제', value: 'FESTIVAL' };
  return { icon: '⭐', label: '나만의', value: 'NONE' }; 
};

/* ══════════════════════════════
   페이지 로딩 시
══════════════════════════════ */
document.addEventListener('DOMContentLoaded', function () {
  document.querySelectorAll('.place-card').forEach(function (card) {
    
    var badge = card.querySelector('.place-type-badge');
    if (badge) {
        var rawText = badge.textContent.trim();
        var catInfo = window.getTripanCategory(rawText);
        badge.innerHTML = catInfo.icon + ' ' + catInfo.label;
    }
    
    _bindCardClickToMap(card); 
    _bindChipClick(card);
    initDrag(card);
  });
});

var currentAddDay = 1;

function openAddPlace(day) {
  currentAddDay = day;
  openModal('addPlaceModal');
  var results = document.getElementById('placeResults');
  if (results) {
    results.innerHTML = '<div style="text-align:center;padding:28px 20px;color:#A0AEC0;"><div style="font-size:28px;margin-bottom:8px;">🔍</div><div style="font-size:13px;">장소명을 2글자 이상 입력하면 검색해요</div></div>';
  }
  var input = document.getElementById('placeSearchInput');
  if (input) { input.value = ''; input.focus(); }
}

function searchPlace(q) {
  clearTimeout(_searchTimer);
  var resultWrap = document.getElementById('placeResults');
  
  if (!q || q.trim().length < 2) {
    if (resultWrap) resultWrap.innerHTML = '<div style="text-align:center;padding:28px 20px;color:#A0AEC0;"><div style="font-size:28px;margin-bottom:8px;">🔍</div><div style="font-size:13px;">장소명을 2글자 이상 입력하면 추천 장소를 검색해요</div></div>';
    return;
  }
  
  _searchTimer = setTimeout(function () {
    if (resultWrap) resultWrap.innerHTML = '<div style="text-align:center;padding:20px;color:#A0AEC0;">검색 중...</div>';
    fetch(CTX_PATH + '/api/place/search?keyword=' + encodeURIComponent(q.trim()))
      .then(function (res) { return res.ok ? res.json() : []; })
      .then(function (places) {
        if (!resultWrap) return;
        
        // 검색 결과가 없을 때: 지도 검색으로 유도
        if (!places || !places.length) {
          resultWrap.innerHTML = 
            '<div style="text-align:center;padding:32px 20px;color:#A0AEC0;">' +
              '<div style="font-size:32px;margin-bottom:10px;">😥</div>' +
              '<div style="font-size:14px;font-weight:800;color:#4A5568;margin-bottom:6px;">추천 목록에 없는 장소예요</div>' +
              '<div style="font-size:13px;line-height:1.6;">"' + _esc(q.trim()) + '" 장소는 아직 추천 목록에 없습니다.<br>상단 중앙의 <b>카카오 지도 검색창</b>을 이용해 직접 추가해 보세요!</div>' +
            '</div>';
          return;
        }
        
        var html = places.map(function (p) {
          var catInfo = window.getTripanCategory(p.categoryName || p.category);
          var pn   = _esc(p.placeName);
          var pa   = _esc(p.address || '');
          var lat  = p.latitude  || 0;
          var lng  = p.longitude || 0;
          var api  = _esc(p.apiPlaceId || '');
          var catForSave = catInfo.value;

          return '<div class="place-result-item" onclick="addPlaceToDay(this,\'' + pn + '\',\'' + pa + '\',' + lat + ',' + lng + ',\'' + api + '\',\'' + catForSave + '\')">'
            + '<div class="place-result-icon">' + catInfo.icon + '</div>'
            + '<div><div class="place-result-name">' + pn + '</div>'
            + '<div class="place-result-addr">' + pa + '</div></div></div>';
        }).join('');
        resultWrap.innerHTML = html;
      })
      .catch(function () {
        if (resultWrap) resultWrap.innerHTML = '<div style="text-align:center;padding:20px;color:#A0AEC0;">검색에 실패했어요</div>';
      });
  }, 300);
}

function _esc(str) {
  if (!str) return '';
  return str.replace(/\\/g, '\\\\').replace(/'/g, "\\'").replace(/"/g, '&quot;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
}

/* ══════════════════════════════
   장소 추가 (POST)
══════════════════════════════ */
function addPlaceToDay(el, name, addr, lat, lng, apiPlaceId, categoryName) {
  var cat = categoryName || 'NONE'; 
  showToast('🔄 저장 중...');
  
  fetch(CTX_PATH + '/api/itinerary/trip/' + TRIP_ID + '/day/' + currentAddDay + '/place', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      placeName:    name,
      address:      addr || '',
      latitude:     lat  || 0,
      longitude:    lng  || 0,
      apiPlaceId:   apiPlaceId || ('custom_' + Date.now()),
      categoryName: cat, 
      customPlace:  !apiPlaceId
    })
  })
  .then(function (r) { return r.json(); })
  .then(function (data) {
    if (data.success) {
      _appendPlaceCard(currentAddDay, data.itemId, name, addr || '', lat || 0, lng || 0, cat);
      closeModal('addPlaceModal');
      if (typeof notifySummaryChanged === 'function') notifySummaryChanged();
      showToast('📍 ' + name + ' 일정이 추가됐어요!');
      
      if (typeof mapAddMarkerExternal === 'function' && lat && lng) {
        var dayCards = document.querySelectorAll('#places-' + currentAddDay + ' .place-card');
        mapAddMarkerExternal(lat, lng, name, currentAddDay, dayCards.length, data.itemId, cat, addr);
      }
    } else {
      showToast('⚠️ 추가 실패: ' + (data.message || '알 수 없는 오류'));
    }
  })
  .catch(function (err) { console.error(err); showToast('⚠️ 통신 오류'); });
}

function _appendPlaceCard(dayNum, itemId, name, addr, lat, lng, categoryName) {
  var list = document.getElementById('places-' + dayNum);
  if (!list) return;
  
  var count = list.querySelectorAll('.place-card').length + 1;
  var catInfo = window.getTripanCategory(categoryName); 
  
  var card  = document.createElement('div');
  card.className = 'place-card';
  card.draggable = true;
  card.setAttribute('data-day',    dayNum);
  card.setAttribute('data-id',     itemId);
  card.setAttribute('data-name',   name);
  card.setAttribute('data-memo',   '');
  card.setAttribute('data-imgurl', '');
  card.setAttribute('data-images', '[]');
  card.setAttribute('data-lat',    lat || 0);
  card.setAttribute('data-lng',    lng || 0);
  
  card.innerHTML =
    '<div class="place-num">' + count + '</div>' +
    '<div class="place-info" style="cursor:pointer;" title="클릭하면 지도로 이동합니다!">' + 
      '<div class="place-name">' + name + '</div>' +
      (addr ? '<div class="place-addr">' + addr + '</div>' : '') +
      '<span class="place-type-badge">' + catInfo.icon + ' ' + catInfo.label + '</span>' + 
      '<div class="place-chips"></div>' +
    '</div>' +
    '<div class="place-actions">' +
      '<button class="place-action-btn" onclick="openMemo(this)" title="메모/사진">📝</button>' +
      '<button class="place-action-btn" onclick="removePlace(this)" title="삭제">🗑</button>' +
    '</div>';
    
  _bindCardClickToMap(card); 
  _bindChipClick(card);
  initDrag(card);
  list.appendChild(card);
  refreshPlaceNums(list);
}

function initDrag(card) {
  card.setAttribute('ondragstart', 'onCardDragStart(event, this)');
  card.setAttribute('ondragend',   'onCardDragEnd(event, this)');  // ✅ 누락됐던 ondragend 추가
}

/* ══════════════════════════════
  장소 클릭 시 지도로 
══════════════════════════════ */
function _bindCardClickToMap(card) {
  if (card.dataset.mapBound === '1') return;
  card.dataset.mapBound = '1';
  
  var infoArea = card.querySelector('.place-info');
  if(infoArea) {
      infoArea.addEventListener('click', function (e) {
        if (e.target.closest('.place-action-btn') || e.target.closest('.place-chip')) return;
        
        var lat = parseFloat(card.getAttribute('data-lat'));
        var lng = parseFloat(card.getAttribute('data-lng'));
        
        // JSP가 위도 경도를 안 뱉었을 경우, 지도 데이터(_markerMap)에서 강제 추출! (무적의 폴백)
        if ((!lat || !lng || isNaN(lat)) && typeof _markerMap !== 'undefined') {
            var itemId = card.getAttribute('data-id');
            var mEntry = _markerMap[String(itemId)];
            if (mEntry && mEntry.marker) {
                lat = mEntry.marker.getPosition().getLat();
                lng = mEntry.marker.getPosition().getLng();
            }
        }

        if (lat && lng && typeof mapFlyTo === 'function') {
            mapFlyTo(lat, lng);
        }
      });
  }
}

function _bindChipClick(card) {
  if (card.dataset.chipBound === '1') return;
  card.dataset.chipBound = '1';
  card.addEventListener('click', function (e) {
    var chip = e.target.closest('.place-chip');
    if (!chip) return;
    e.stopPropagation();
    openMemoView(card);
  });
}


/* ══════════════════════════════
   장소 삭제
══════════════════════════════ */
function removePlace(btn) {
  var card   = btn.closest('.place-card');
  var itemId = card.getAttribute('data-id');
  var day    = card.getAttribute('data-day');

  if (!itemId) { card.remove(); renumberPlaces(day); return; }

  fetch(CTX_PATH + '/api/itinerary/' + itemId, { method: 'DELETE' })
    .then(function (r) { return r.json(); })
    .then(function (data) {
      if (data.success) {
        card.style.transition = 'opacity .3s, transform .3s';
        card.style.opacity    = '0';
        card.style.transform  = 'translateX(-20px)';
        setTimeout(function () {
          card.remove();
          var list = document.getElementById('places-' + day);
          if (list) refreshPlaceNums(list);
          if (typeof mapRemoveMarker === 'function') mapRemoveMarker(itemId);
        }, 300);
        if (typeof notifySummaryChanged === 'function') notifySummaryChanged();
        showToast('🗑 장소 삭제됨');
      } else {
        showToast('⚠️ 삭제 실패');
      }
    })
    .catch(function () { showToast('⚠️ 서버 오류'); });
}

/* ══════════════════════════════
   드래그앤드롭 (LexoRank) & 마커 완벽 재정렬
══════════════════════════════ */
// ✅ 순서값 생성: 항상 000001 형식 (DB 기존값과 호환, LexoRank 제거)
function toRank(idx) { return String(idx + 1).padStart(6, '0'); }

var _dragCard    = null;
var _dragDayFrom = null;

function onCardDragStart(e, el) {
  _dragCard    = el;
  _dragDayFrom = parseInt(el.dataset.day);
  e.dataTransfer.effectAllowed = 'move';
  e.dataTransfer.setData('text/plain', el.dataset.id || '');
  setTimeout(function () { if (_dragCard) _dragCard.classList.add('dragging'); }, 0);
}

function onCardDragEnd(e, el) {
  el.classList.remove('dragging');
  document.querySelectorAll('.place-card.drag-over').forEach(function (c) { c.classList.remove('drag-over'); });
  document.querySelectorAll('.drop-zone.dz-active').forEach(function (z) { z.classList.remove('dz-active'); });
  document.querySelectorAll('.place-list.list-drag-over').forEach(function (l) { l.classList.remove('list-drag-over'); });
  _dragCard = null;
}

function onListDragOver(e) {
  if (e.target && e.target.classList && e.target.classList.contains('drop-zone')) return;
  e.preventDefault();
  if (!_dragCard) return;
  e.dataTransfer.dropEffect = 'move';
  var list = e.currentTarget;
  list.classList.add('list-drag-over');

  var after = getDragAfterElement(list, e.clientY);
  if (after == null) list.appendChild(_dragCard);
  else if (after !== _dragCard) list.insertBefore(_dragCard, after);

  // ✅ refreshPlaceNums 제거 — 드래그 중 중간 리스트에서 호출하면
  // data-day가 아직 안 바뀐 카드들의 dataset.order가 오염됨
  // 번호 갱신은 드롭 확정(onListDrop/onDropZoneDrop) 시에만 수행
}

function onListDragLeave(e) {
  if (!e.currentTarget.contains(e.relatedTarget)) {
    e.currentTarget.classList.remove('list-drag-over');
  }
}

// ✅ 같은 날짜 안에서 드롭
function onListDrop(e) {
  e.preventDefault(); e.stopPropagation();
  if (!_dragCard) return;

  var list  = e.currentTarget;
  var dayTo = parseInt(list.dataset.day);
  list.classList.remove('list-drag-over');

  // ✅ dataset.day 먼저 확정 후 refreshPlaceNums 호출 (filter 기준이 됨)
  _dragCard.dataset.day = dayTo;

  var oldList = document.getElementById('places-' + _dragDayFrom);

  // 다른 날 이동: oldList에서 _dragCard가 이미 빠진 상태이므로 바로 refresh
  if (oldList && oldList !== list) {
    refreshPlaceNums(oldList);
    refreshPlaceNums(list);
    _persistListOrder(list, dayTo);
    _persistListOrder(oldList, _dragDayFrom);
  } else {
    // 같은 날 이동: list 하나만 처리
    refreshPlaceNums(list);
    _persistListOrder(list, dayTo);
  }

  showToast('✅ 일정 순서가 변경됐어요');
  if (typeof _reorderMarkersForDay === 'function') {
    _reorderMarkersForDay(dayTo);
    if (_dragDayFrom && _dragDayFrom !== dayTo) _reorderMarkersForDay(_dragDayFrom);
  }
  if (typeof notifySummaryChanged === 'function') notifySummaryChanged();
}

function onDropZoneDragOver(e) {
  e.preventDefault(); e.stopPropagation();
  if (!_dragCard) return;
  e.dataTransfer.dropEffect = 'move';
  e.currentTarget.classList.add('dz-active');
}

function onDropZoneDragLeave(e) { e.currentTarget.classList.remove('dz-active'); }

// ✅ 다른 날짜(빈 공간)로 완전히 넘길 때
function onDropZoneDrop(e) {
  e.preventDefault(); e.stopPropagation();
  e.currentTarget.classList.remove('dz-active');
  if (!_dragCard) return;

  var dayTo = parseInt(e.currentTarget.dataset.day);
  var list  = document.getElementById('places-' + dayTo);
  if (!list) return;

  _dragCard.dataset.day = dayTo;
  list.appendChild(_dragCard);

  var oldList = document.getElementById('places-' + _dragDayFrom);
  if (oldList && oldList !== list) refreshPlaceNums(oldList);
  refreshPlaceNums(list);

  _persistListOrder(list, dayTo);
  if (oldList && oldList !== list) _persistListOrder(oldList, _dragDayFrom);

  showToast('📍 DAY ' + dayTo + '로 이동됐어요');
  if (typeof _reorderMarkersForDay === 'function') {
    _reorderMarkersForDay(dayTo);
    if (_dragDayFrom && _dragDayFrom !== dayTo) _reorderMarkersForDay(_dragDayFrom);
  }
  if (typeof notifySummaryChanged === 'function') notifySummaryChanged();
}

function getDragAfterElement(container, y) {
  var items = Array.from(container.querySelectorAll('.place-card:not(.dragging)'));
  return items.reduce(function (closest, child) {
    var box    = child.getBoundingClientRect();
    var offset = y - box.top - box.height / 2;
    if (offset < 0 && offset > closest.offset) return { offset: offset, element: child };
    return closest;
  }, { offset: Number.NEGATIVE_INFINITY }).element;
}

// ✅ UI 번호 갱신 + dataset.order를 000001 형식으로 동기화
function refreshPlaceNums(list) {
  list.querySelectorAll('.place-card').forEach(function (card, i) {
    var n = card.querySelector('.place-num');
    if (n) n.textContent = i + 1;
    card.dataset.order = toRank(i); // 항상 000001 형식으로 갱신
  });
}

// ✅ 리스트 전체 순서를 서버에 저장 (카드마다 순서대로 PATCH)
// refreshPlaceNums 호출 이후 dataset.order가 최신 상태가 된 뒤 호출
function _persistListOrder(list, dayNum) {
  // data-day가 일치하는 카드만 (다른 날로 이미 이동된 카드 제외)
  var cards = Array.from(list.querySelectorAll('.place-card'))
    .filter(function(card) { return parseInt(card.dataset.day) === dayNum; });

  cards.forEach(function(card, idx) {
    var itemId     = card.dataset.id;
    var visitOrder = toRank(idx);
    if (!itemId) return;
    card.dataset.order = visitOrder;
    // 기존 /move 엔드포인트 사용 (이미 배포돼 있고 WS broadcast 포함)
    fetch(CTX_PATH + '/api/itinerary/' + itemId + '/move', {
      method: 'PATCH',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ dayNumber: dayNum, visitOrder: visitOrder })
    }).catch(function(err) {
      console.warn('[DnD] 순서 저장 실패 itemId=' + itemId, err);
    });
  });
}

function renumberPlaces(day) {
  var list = document.getElementById('places-' + day);
  if (list) refreshPlaceNums(list);
}
/* ══════════════════════════════════════════════════════════
   메모 & 이미지 — 편집 모달 (📝 버튼)
══════════════════════════════════════════════════════════ */
var _memoImages  = []; 
var _memoEditCard = null; 

function openMemo(btn) {
  var card     = btn.closest ? btn.closest('.place-card') : btn;
  if (!card) return;
  _memoEditCard = card;

  var itemId   = card.dataset.id    || '';
  var itemName = card.dataset.name  || '장소';
  var memo     = card.dataset.memo  || '';
  var existingImages = _parseDataImages(card);

  document.getElementById('memoItemId').value          = itemId;
  document.getElementById('memoPlaceName').textContent = itemName;
  document.getElementById('memoText').value            = memo;

  _memoImages = existingImages.map(function (url) { return { src: url, existing: true }; });
  renderMemoImgGrid(_memoImages);
  openModal('memoModal');
}

/* ══════════════════════════════════════════════════════════
   메모 & 이미지 — 조회 모달 (뱃지 클릭 시) 전면 개편
══════════════════════════════════════════════════════════ */
function openMemoView(card) {
  var itemName = card.dataset.name   || '장소';
  var memo     = card.dataset.memo   || '';
  var images   = _parseDataImages(card);

  var old = document.getElementById('memoViewModal');
  if (old) old.remove();

  var modal = document.createElement('div');
  modal.id        = 'memoViewModal';
  modal.className = 'modal-overlay open'; // 생성과 동시에 열림 클래스 추가
  modal.style.cssText = 'display:flex;align-items:center;justify-content:center;';

  // 📸 1. 사진 영역 (trip.css의 modern-grid와 openImageViewer 뷰어 적용!)
  var imgsHtml = '';
  if (images.length > 0) {
    imgsHtml = '<div style="margin-top:20px;">'
      + '<label class="form-label-sm" style="margin-bottom: 8px; display: block;">📸 사진</label>'
      + '<div class="modern-grid">' // ← 3열 썸네일 그리드
      + images.map(function (url) {
          // ← 썸네일 클래스와 라이트박스 뷰어 연결
          return '<img src="' + url + '" class="modern-thumb" onclick="openImageViewer(\'' + url + '\')">'; 
        }).join('')
      + '</div></div>';
  }

  // 📝 2. 메모 영역 (모던한 텍스트 박스 스타일)
  var memoHtml = memo
    ? '<div class="modern-textarea" style="background:#F8FAFC !important; border:none !important; cursor:default; white-space:pre-wrap;">'
        + _escHtml(memo) + '</div>'
    : '<div style="color:#A0AEC0;font-size:13px;text-align:center;padding:12px 0;">작성된 메모가 없습니다.</div>';

  // ✨ 3. 전체 모달 HTML 조립 (청량하고 둥근 글래스모피즘 스타일)
  modal.innerHTML =
    '<div class="modal-box" style="max-width: 420px; border-radius: 24px;">' +
      '<div class="modal-box__head" style="border-bottom: none; padding-bottom: 10px;">' +
        '<span class="modal-box__title" style="font-size: 18px; color: var(--dark);">✨ 장소 기록</span>' +
        '<div style="display:flex;gap:8px;align-items:center;">' +
          '<button onclick="closeModal(\'memoViewModal\');openMemo(_memoEditCard || this.closest(\'.modal-overlay\').previousSibling);" ' +
            'style="font-size:12px;font-weight:700;padding:5px 12px;border:1.5px solid #89CFF0;border-radius:10px;background:white;color:#2B6CB0;cursor:pointer; transition:all 0.2s;" ' +
            'onmouseover="this.style.background=\'#EBF8FF\'" onmouseout="this.style.background=\'white\'"' +
            'id="memoViewEditBtn">✏️ 수정</button>' +
          '<button class="modal-close-btn" onclick="this.closest(\'.modal-overlay\').remove()">✕</button>' +
        '</div>' +
      '</div>' +
      '<div class="modal-box__body" style="padding-top: 0;">' +
        '<div class="memo-modern-header">' +
          '<span class="memo-icon">📍</span>' +
          '<span class="memo-title-text">' + _escHtml(itemName) + '</span>' +
        '</div>' +
        memoHtml +
        imgsHtml +
      '</div>' +
    '</div>';

  document.body.appendChild(modal);

  document.getElementById('memoViewEditBtn').addEventListener('click', function () {
    modal.remove();
    openMemo(card);
  });

  modal.addEventListener('click', function (e) {
    if (e.target === modal) modal.remove();
  });
  
  _memoEditCard = card;
}

function _escHtml(str) { if (!str) return ''; return str.replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;'); }

function _parseDataImages(card) {
  try { var raw = card.getAttribute('data-images') || '[]'; var parsed = JSON.parse(raw); return Array.isArray(parsed) ? parsed.filter(Boolean) : [];
  } catch (e) { var single = card.getAttribute('data-imgurl') || ''; return single ? [single] : []; }
}

function renderMemoImgGrid(imgs) {
  var grid = document.getElementById('memoImgGrid');
  if (!grid) return;
  var html = '';
  imgs.forEach(function (img, idx) {
    var src = img.base64 || img.src || '';
    html += '<div style="position:relative;width:80px;height:80px;"><img src="' + src + '" style="width:80px;height:80px;object-fit:cover;border-radius:8px;border:1.5px solid #E2E8F0;cursor:pointer;" onclick="previewMemoImg(\'' + src + '\')"><button onclick="removeMemoImg(' + idx + ')" style="position:absolute;top:-6px;right:-6px;width:20px;height:20px;border-radius:50%;background:#FC8181;border:1.5px solid white;color:white;font-size:10px;font-weight:700;cursor:pointer;display:flex;align-items:center;justify-content:center;line-height:1;z-index:1;">✕</button></div>';
  });
  if (imgs.length < 3) { html += '<div class="memo-img-add" style="width:80px;height:80px;" onclick="document.getElementById(\'memoImgInput\').click()"><span style="font-size:22px;">📷</span><span>추가</span></div>'; }
  grid.innerHTML = html;
  grid.style.cssText = 'display:flex;flex-wrap:wrap;gap:10px;margin-top:8px;';
}

function onMemoImgSelect(event) {
  var files  = Array.from(event.target.files);
  var remain = 3 - _memoImages.length;
  files.slice(0, remain).forEach(function (file) {
    if (file.size > 5 * 1024 * 1024) { showToast('⚠️ 5MB 이하 이미지만 가능해요'); return; }
    var reader = new FileReader();
    reader.onload = function (e) { _memoImages.push({ base64: e.target.result, file: file }); renderMemoImgGrid(_memoImages); };
    reader.readAsDataURL(file);
  });
  event.target.value = '';
}

function removeMemoImg(idx) { _memoImages.splice(idx, 1); renderMemoImgGrid(_memoImages); }

function previewMemoImg(src) {
  var overlay = document.getElementById('memoImgPreviewOverlay');
  if (!overlay) {
    overlay = document.createElement('div');
    overlay.id = 'memoImgPreviewOverlay';
    overlay.style.cssText = 'position:fixed;top:0;left:0;width:100%;height:100%;z-index:3000;background:rgba(0,0,0,.85);display:flex;align-items:center;justify-content:center;cursor:pointer;';
    overlay.addEventListener('click', function () { overlay.style.display = 'none'; });
    document.body.appendChild(overlay);
  }
  overlay.innerHTML = '<img src="' + src + '" style="max-width:90vw;max-height:85vh;object-fit:contain;border-radius:12px;box-shadow:0 8px 40px rgba(0,0,0,.5);">';
  overlay.style.display = 'flex';
}

function saveMemo() {
  var itemId = document.getElementById('memoItemId').value;
  var memo   = document.getElementById('memoText').value.trim();
  if (!itemId) { showToast('⚠️ 저장할 장소가 없어요'); return; }

  var btnTxt = document.getElementById('saveMemoTxt');
  if (btnTxt) btnTxt.textContent = '저장 중…';

  // ✅ BUG FIX: 기존 이미지 중 유지할 URL 목록을 서버에 함께 전달
  // 이전: newImages(새 업로드)만 전달 → 서버가 기존 이미지 전부 삭제 후 새것만 저장
  // 이후: keepImageUrls 추가 → 서버가 목록에 없는 것만 삭제, 있는 것은 유지
  var newImages       = _memoImages.filter(function (img) { return img.base64 && !img.existing; });
  var keepImageUrls   = _memoImages.filter(function (img) { return img.existing && img.src; })
                                   .map(function (img) { return img.src; });
  var imageBase64List = newImages.map(function (img) { return img.base64; });

  fetch(CTX_PATH + '/api/itinerary/' + itemId + '/memo', {
    method: 'PATCH', headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ memo: memo, imageBase64List: imageBase64List, keepImageUrls: keepImageUrls })
  })
  .then(function (r) { return r.ok ? r.json() : Promise.reject(r.status); })
  .then(function (data) {
    if (btnTxt) btnTxt.textContent = '저장';
    if (data.success) {
      var card = document.querySelector('.place-card[data-id="' + itemId + '"]');
      if (card) {
        card.dataset.memo = memo;
        var imageUrls = data.imageUrls || (data.imageUrl ? [data.imageUrl] : []);
        card.setAttribute('data-images', JSON.stringify(imageUrls));
        card.setAttribute('data-imgurl', imageUrls.length > 0 ? imageUrls[0] : '');
        _updateMemoChips(card, memo, imageUrls);
      }
      closeModal('memoModal');
      showToast('✅ 메모가 저장됐어요');
    } else { showToast('⚠️ ' + (data.message || '저장 실패')); }
  })
  .catch(function (err) { if (btnTxt) btnTxt.textContent = '저장'; showToast('⚠️ 서버 오류 (' + err + ')'); });
}

function _updateMemoChips(card, memo, imageUrls) {
  var chips    = card.querySelector('.place-chips');
  if (!chips) return;
  var memoChip = chips.querySelector('.place-chip.memo');
  var imgChip  = chips.querySelector('.place-chip.img');
  var oldChip  = card.querySelector('.memo-chip');
  if (oldChip) oldChip.remove();

  if (memo && !memoChip) { chips.insertAdjacentHTML('beforeend', '<span class="place-chip memo">📝 메모</span>'); _bindChipClick(card); } 
  else if (!memo && memoChip) { memoChip.remove(); }

  var hasImg = imageUrls && imageUrls.length > 0;
  if (hasImg && !imgChip) { chips.insertAdjacentHTML('beforeend', '<span class="place-chip img">🖼 사진</span>'); _bindChipClick(card); } 
  else if (!hasImg && imgChip) { imgChip.remove(); }
}

function wsUpdateMemoFull(itemId, memo, imageUrls) {
  var card = document.querySelector('.place-card[data-id="' + itemId + '"]');
  if (!card) return;
  card.dataset.memo = memo || '';
  imageUrls = imageUrls || [];
  card.setAttribute('data-images', JSON.stringify(imageUrls));
  card.setAttribute('data-imgurl', imageUrls.length > 0 ? imageUrls[0] : '');
  _updateMemoChips(card, memo, imageUrls);
  _bindChipClick(card);
}