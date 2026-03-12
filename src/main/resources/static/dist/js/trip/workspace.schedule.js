/**
 * workspace.schedule.js
 * ──────────────────────────────────────────────
 * 담당: 장소 CRUD · 드래그앤드롭 · 메모 & 이미지
 *       ← JSP 인라인 openMemo / saveMemo / _memoImages +
 *          DnD 전체 (onCardDragStart 등 refreshPlaceNums 등) 이동
 *
 * 의존: workspace.ui.js (showToast, openModal, closeModal)
 *       TRIP_ID, CTX_PATH
 * ──────────────────────────────────────────────
 */

/* ══════════════════════════════
   장소 추가 모달
══════════════════════════════ */
var currentAddDay = 1;

function openAddPlace(day) {
  currentAddDay = day;
  openModal('addPlaceModal');
  var results = document.getElementById('placeResults');
  if (results) {
    results.innerHTML =
      '<div style="text-align:center;padding:28px 20px;color:#A0AEC0;">' +
      '<div style="font-size:28px;margin-bottom:8px;">🔍</div>' +
      '<div style="font-size:13px;">장소명을 2글자 이상 입력하면 검색해요</div></div>';
  }
  var input = document.getElementById('placeSearchInput');
  if (input) { input.value = ''; input.focus(); }
}

function selectPlaceType(btn, type) {
  document.querySelectorAll('.place-type-tab').forEach(function (t) { t.classList.remove('active'); });
  btn.classList.add('active');
}

/* ══════════════════════════════
   장소 검색 (debounce)
══════════════════════════════ */
var _searchTimer = null;

function searchPlace(q) {
  clearTimeout(_searchTimer);
  var resultWrap = document.getElementById('placeResults');
  if (!q || q.trim().length < 2) {
    if (resultWrap) resultWrap.innerHTML =
      '<div style="text-align:center;padding:28px 20px;color:#A0AEC0;">' +
      '<div style="font-size:28px;margin-bottom:8px;">🔍</div>' +
      '<div style="font-size:13px;">장소명을 2글자 이상 입력하면 검색해요</div></div>';
    return;
  }
  _searchTimer = setTimeout(function () {
    if (resultWrap) resultWrap.innerHTML = '<div style="text-align:center;padding:20px;color:#A0AEC0;">검색 중...</div>';
    fetch(CTX_PATH + '/api/place/search?keyword=' + encodeURIComponent(q.trim()))
      .then(function (res) { return res.ok ? res.json() : []; })
      .then(function (places) {
        if (!resultWrap) return;
        if (!places || !places.length) {
          resultWrap.innerHTML =
            '<div style="text-align:center;padding:28px 20px;color:#A0AEC0;">' +
            '<div style="font-size:28px;margin-bottom:8px;">😥</div>' +
            '<div style="font-size:13px;font-weight:600;">검색 결과가 없어요</div>' +
            '<div style="font-size:12px;margin-top:4px;">"' + _esc(q.trim()) + '" 로 등록된 장소가 없습니다</div></div>';
          return;
        }
        var html = places.map(function (p) {
          var icon = _categoryIcon(p.categoryName || p.category);
          var pn   = _esc(p.placeName);
          var pa   = _esc(p.address || '');
          var lat  = p.latitude  || 0;
          var lng  = p.longitude || 0;
          var api  = _esc(p.apiPlaceId || '');
          return '<div class="place-result-item" onclick="addPlaceToDay(this,\'' + pn + '\',\'' + pa + '\',' + lat + ',' + lng + ',\'' + api + '\')">'
            + '<div class="place-result-icon">' + icon + '</div>'
            + '<div><div class="place-result-name">' + pn + '</div>'
            + '<div class="place-result-addr">' + pa + '</div></div></div>';
        }).join('');
        resultWrap.innerHTML = html;
      })
      .catch(function () {
        if (resultWrap) resultWrap.innerHTML =
          '<div style="text-align:center;padding:20px;color:#A0AEC0;">검색에 실패했어요</div>';
      });
  }, 300);
}

function _categoryIcon(cat) {
  if (!cat) return '📍';
  if (cat.indexOf('숙소') >= 0 || cat.indexOf('호텔') >= 0) return '🏨';
  if (cat.indexOf('음식') >= 0 || cat.indexOf('맛집') >= 0) return '🍽️';
  if (cat.indexOf('카페') >= 0) return '☕';
  if (cat.indexOf('관광') >= 0) return '🏔️';
  if (cat.indexOf('교통') >= 0) return '🚗';
  return '📍';
}

function _esc(str) {
  if (!str) return '';
  return str.replace(/\\/g, '\\\\').replace(/'/g, "\\'").replace(/"/g, '&quot;')
            .replace(/</g, '&lt;').replace(/>/g, '&gt;');
}

/* ══════════════════════════════
   장소 추가 (POST)
══════════════════════════════ */
function addPlaceToDay(el, name, addr, lat, lng, apiPlaceId) {
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
      categoryName: '장소',
      customPlace:  !apiPlaceId
    })
  })
  .then(function (r) { return r.json(); })
  .then(function (data) {
    if (data.success) {
      _appendPlaceCard(currentAddDay, data.itemId, name, addr || '', lat || 0, lng || 0);
      closeModal('addPlaceModal');
      showToast('📍 ' + name + ' 일정이 추가됐어요!');
      // 지도에도 마커 추가
      if (typeof mapAddMarkerExternal === 'function' && lat && lng) {
        var dayCards = document.querySelectorAll('#places-' + currentAddDay + ' .place-card');
        mapAddMarkerExternal(lat, lng, name, currentAddDay, dayCards.length);
      }
    } else {
      showToast('⚠️ 추가 실패: ' + (data.message || '알 수 없는 오류'));
    }
  })
  .catch(function (err) {
    console.error('[addPlaceToDay]', err);
    showToast('⚠️ 서버와 통신 중 오류가 발생했어요.');
  });
}

function _appendPlaceCard(dayNum, itemId, name, addr, lat, lng) {
  var list = document.getElementById('places-' + dayNum);
  if (!list) return;
  var count = list.querySelectorAll('.place-card').length + 1;
  var card  = document.createElement('div');
  card.className = 'place-card';
  card.draggable = true;
  card.setAttribute('data-day',    dayNum);
  card.setAttribute('data-id',     itemId);
  card.setAttribute('data-name',   name);
  card.setAttribute('data-memo',   '');
  card.setAttribute('data-imgurl', '');
  card.setAttribute('data-lat',    lat || 0);
  card.setAttribute('data-lng',    lng || 0);
  card.innerHTML =
    '<div class="place-num">' + count + '</div>' +
    '<div class="place-info">' +
      '<div class="place-name">' + name + '</div>' +
      (addr ? '<div class="place-addr">' + addr + '</div>' : '') +
      '<span class="place-type-badge">📍 장소</span>' +
      '<div class="place-chips"></div>' +
    '</div>' +
    '<div class="place-actions">' +
      '<button class="place-action-btn" onclick="openMemo(this)" title="메모/사진">📝</button>' +
      '<button class="place-action-btn" onclick="removePlace(this)" title="삭제">🗑</button>' +
    '</div>';
  initDrag(card);
  list.appendChild(card);
  refreshPlaceNums(list);
}

/* ws.js에서도 호출 — public */
function initDrag(card) {
  card.setAttribute('ondragstart', 'onCardDragStart(event, this)');
  card.setAttribute('ondragend',   'onCardDragEnd(event, this)');
}

/* ══════════════════════════════
   장소 삭제 (DELETE)
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
        }, 300);
        showToast('🗑 장소 삭제됨');
      } else {
        showToast('⚠️ 삭제 실패');
      }
    })
    .catch(function () { showToast('⚠️ 서버 오류'); });
}

/* ══════════════════════════════
   드래그앤드롭 (LexoRank 방식)
   ← JSP 인라인에서 이동
══════════════════════════════ */
var _dragCard    = null;
var _dragDayFrom = null;

function toLexoRank(idx) {
  return String(idx + 1).padStart(6, '0');
}

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
  if (after == null)        list.appendChild(_dragCard);
  else if (after !== _dragCard) list.insertBefore(_dragCard, after);
  refreshPlaceNums(list);
}

function onListDragLeave(e) {
  if (!e.currentTarget.contains(e.relatedTarget)) {
    e.currentTarget.classList.remove('list-drag-over');
  }
}

function onListDrop(e) {
  e.preventDefault(); e.stopPropagation();
  if (!_dragCard) return;
  var list  = e.currentTarget;
  var dayTo = parseInt(list.dataset.day);
  list.classList.remove('list-drag-over');
  _dragCard.dataset.day = dayTo;
  refreshPlaceNums(list);
  persistPlaceOrder(list, dayTo);
  showToast('✅ 일정 순서가 변경됐어요');
}

function onDropZoneDragOver(e) {
  e.preventDefault(); e.stopPropagation();
  if (!_dragCard) return;
  e.dataTransfer.dropEffect = 'move';
  e.currentTarget.classList.add('dz-active');
}

function onDropZoneDragLeave(e) {
  e.currentTarget.classList.remove('dz-active');
}

function onDropZoneDrop(e) {
  e.preventDefault(); e.stopPropagation();
  e.currentTarget.classList.remove('dz-active');
  if (!_dragCard) return;
  var dayTo = parseInt(e.currentTarget.dataset.day);
  var list  = document.getElementById('places-' + dayTo);
  if (!list) return;
  _dragCard.dataset.day = dayTo;
  list.appendChild(_dragCard);
  refreshPlaceNums(list);
  persistPlaceOrder(list, dayTo);
  showToast('📍 DAY ' + dayTo + '로 이동됐어요');
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

function refreshPlaceNums(list) {
  list.querySelectorAll('.place-card').forEach(function (card, i) {
    var n = card.querySelector('.place-num');
    if (n) n.textContent = i + 1;
    card.dataset.order = toLexoRank(i);
  });
}

// alias (ws.js에서 renumberPlaces 호출)
function renumberPlaces(day) {
  var list = document.getElementById('places-' + day);
  if (list) refreshPlaceNums(list);
}

function persistPlaceOrder(list, dayTo) {
  var cards    = Array.from(list.querySelectorAll('.place-card'));
  var promises = cards.map(function (card, idx) {
    var itemId     = card.dataset.id;
    var visitOrder = toLexoRank(idx);
    if (!itemId) return Promise.resolve();
    card.dataset.order = visitOrder;
    return fetch(CTX_PATH + '/api/itinerary/' + itemId + '/move', {
      method: 'PATCH',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ dayNumber: dayTo, visitOrder: visitOrder })
    }).catch(function (err) { console.warn('[DnD] 저장 실패 itemId=' + itemId, err); });
  });
  Promise.all(promises).then(function () {
    console.log('[DnD] 순서 저장 완료, dayTo=' + dayTo);
  });
}

/* ══════════════════════════════
   메모 & 이미지
   ← JSP 인라인 openMemo / saveMemo 이동
══════════════════════════════ */
var _memoImages = [];   // { base64, file } or { src, existing }

function openMemo(btn) {
  var card     = btn.closest('.place-card');
  var itemId   = card.dataset.id    || '';
  var itemName = card.dataset.name  || '장소';
  var memo     = card.dataset.memo  || '';
  var imgUrl   = card.dataset.imgurl || '';

  document.getElementById('memoItemId').value        = itemId;
  document.getElementById('memoPlaceName').textContent = itemName;
  document.getElementById('memoText').value           = memo;
  _memoImages = [];
  renderMemoImgGrid(imgUrl ? [{ src: imgUrl, existing: true }] : []);
  openModal('memoModal');
}

function renderMemoImgGrid(imgs) {
  var grid = document.getElementById('memoImgGrid');
  if (!grid) return;
  var html = '';
  imgs.forEach(function (img, idx) {
    var src = img.base64 || img.src || '';
    html += '<div style="position:relative;">'
      + '<img src="' + src + '" class="memo-img-thumb" onclick="previewMemoImg(\'' + src + '\')">'
      + '<button onclick="removeMemoImg(' + idx + ')" style="position:absolute;top:2px;right:2px;width:20px;height:20px;border-radius:50%;background:#FC8181;border:1.5px solid white;color:white;font-size:10px;font-weight:700;cursor:pointer;display:flex;align-items:center;justify-content:center;">✕</button>'
      + '</div>';
  });
  if (imgs.length < 3) {
    html += '<div class="memo-img-add" onclick="document.getElementById(\'memoImgInput\').click()">'
      + '<span style="font-size:22px;">📷</span><span>추가</span></div>';
  }
  grid.innerHTML = html;
}

function onMemoImgSelect(event) {
  var files  = Array.from(event.target.files);
  var remain = 3 - _memoImages.length;
  files.slice(0, remain).forEach(function (file) {
    if (file.size > 5 * 1024 * 1024) { showToast('⚠️ 5MB 이하 이미지만 가능해요'); return; }
    var reader = new FileReader();
    reader.onload = function (e) {
      _memoImages.push({ base64: e.target.result, file: file });
      renderMemoImgGrid(_memoImages);
    };
    reader.readAsDataURL(file);
  });
  event.target.value = '';
}

function removeMemoImg(idx) {
  _memoImages.splice(idx, 1);
  renderMemoImgGrid(_memoImages);
}

function previewMemoImg(src) {
  window.open(src, '_blank');
}

function saveMemo() {
  var itemId = document.getElementById('memoItemId').value;
  var memo   = document.getElementById('memoText').value.trim();
  if (!itemId) { showToast('⚠️ 저장할 장소가 없어요'); return; }

  var btnTxt = document.getElementById('saveMemoTxt');
  if (btnTxt) btnTxt.textContent = '저장 중…';

  var imageBase64 = _memoImages.length > 0 ? _memoImages[0].base64 : null;

  fetch(CTX_PATH + '/api/itinerary/' + itemId + '/memo', {
    method: 'PATCH',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ memo: memo, imageBase64: imageBase64 })
  })
  .then(function (r) { return r.ok ? r.json() : Promise.reject(r.status); })
  .then(function (data) {
    if (btnTxt) btnTxt.textContent = '저장';
    if (data.success) {
      var card = document.querySelector('.place-card[data-id="' + itemId + '"]');
      if (card) {
        card.dataset.memo   = memo;
        card.dataset.imgurl = data.imageUrl || '';
        var chips   = card.querySelector('.place-chips');
        if (chips) {
          var memoChip = chips.querySelector('.place-chip.memo');
          var imgChip  = chips.querySelector('.place-chip.img');
          if (memo && !memoChip)         chips.insertAdjacentHTML('beforeend', '<span class="place-chip memo">📝 메모</span>');
          if (!memo && memoChip)         memoChip.remove();
          if (data.imageUrl && !imgChip) chips.insertAdjacentHTML('beforeend', '<span class="place-chip img">🖼 사진</span>');
          if (!data.imageUrl && imgChip) imgChip.remove();
        }
      }
      closeModal('memoModal');
      showToast('✅ 메모가 저장됐어요');
    } else {
      showToast('⚠️ ' + (data.message || '저장 실패'));
    }
  })
  .catch(function (err) {
    if (btnTxt) btnTxt.textContent = '저장';
    showToast('⚠️ 서버 오류 (' + err + ')');
  });
}
