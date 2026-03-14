document.addEventListener('DOMContentLoaded', function () {
  const svg = d3.select('#mini-map-svg');
  const width = 500, height = 600;

  const projection = d3.geoMercator()
    .center([127.7, 35.9])
    .scale(4900)
    .translate([width / 2, height / 2]);

  const path = d3.geoPath().projection(projection);
  const tooltip = d3.select('#map-tooltip');
  const g = svg.append('g');

  let visitedDataMap = {};

  // ── 줌 ──
  const zoom = d3.zoom()
    .scaleExtent([1, 12])
    .on('zoom', e => g.attr('transform', e.transform));
  svg.call(zoom);
  document.getElementById('btn-zoom-in').onclick    = () => svg.transition().duration(300).call(zoom.scaleBy, 1.5);
  document.getElementById('btn-zoom-out').onclick   = () => svg.transition().duration(300).call(zoom.scaleBy, 0.67);
  document.getElementById('btn-zoom-reset').onclick = () => svg.transition().duration(300).call(zoom.transform, d3.zoomIdentity);

  function getDisplayLabel(props) {
    return props.name || '';
  }

  // ── SVG 그라데이션 ──
  svg.append('defs').append('linearGradient')
    .attr('id', 'sido-grad')
    .attr('x1', '0%').attr('y1', '0%')
    .attr('x2', '100%').attr('y2', '100%')
    .selectAll('stop')
    .data([
      { offset: '0%',   color: '#89CFF0' },
      { offset: '100%', color: '#FFB6C1' }
    ])
    .enter().append('stop')
    .attr('offset', d => d.offset)
    .attr('stop-color', d => d.color);

  const geoUrl = 'https://raw.githubusercontent.com/southkorea/southkorea-maps/master/kostat/2013/json/skorea_municipalities_geo_simple.json';

  d3.json(geoUrl).then(data => {
    g.selectAll('path.region')
      .data(data.features)
      .enter().append('path')
      .attr('class', 'mini-region region')
      .attr('d', path)
      .attr('data-key', d => getDisplayLabel(d.properties))
      .style('fill', '#EDF2F7')
      .style('stroke', '#fff')
      .style('stroke-width', '0.5px')
      .style('cursor', 'pointer')
      .on('mouseover', function (event, d) {
        const label = getDisplayLabel(d.properties);
        tooltip.style('opacity', 1).text(label);
        d3.select(this).style('fill-opacity', 0.65).style('stroke', '#89CFF0').style('stroke-width', '1.5px');
      })
      .on('mousemove', function (event) {
        tooltip.style('left', (event.clientX + 15) + 'px')
               .style('top',  (event.clientY - 28) + 'px');
      })
      .on('mouseout', function (event, d) {
        tooltip.style('opacity', 0);
        const key = getDisplayLabel(d.properties);
        d3.select(this)
          .style('fill', visitedDataMap[key]?.colorCode || '#EDF2F7')
          .style('fill-opacity', 1)
          .style('stroke', '#fff')
          .style('stroke-width', '0.5px');
      })
      .on('click', function (event, d) {
        openDetailModal(getDisplayLabel(d.properties));
      });

    // ── 시도 경계선 ──
    const sidoUrl = 'https://raw.githubusercontent.com/southkorea/southkorea-maps/master/kostat/2013/json/skorea_provinces_geo_simple.json';
    d3.json(sidoUrl).then(sidoData => {
      g.selectAll('path.sido-border')
        .data(sidoData.features)
        .enter().append('path')
        .attr('class', 'sido-border')
        .attr('d', path)
        .style('fill', 'none')
        .style('stroke', 'url(#sido-grad)')
        .style('stroke-width', '1px')
        .style('stroke-linejoin', 'round')
        .style('stroke-linecap', 'round')
        .style('opacity', '0.75')
        .style('pointer-events', 'none');
    }).catch(() => {});

    loadVisitedData();
  }).catch(err => console.error('지도 로드 실패:', err));

  // ── 서버 데이터 로드 ──
  function loadVisitedData() {
    fetch(ctxPath + '/mypage/api/visited-regions-data')
      .then(r => r.ok ? r.json() : [])
      .then(list => {
        visitedDataMap = {};
        list.forEach(item => {
          visitedDataMap[item.sigunguName] = item;
          g.select('path[data-key="' + item.sigunguName + '"]')
           .style('fill', item.colorCode || '#89CFF0');
        });
        updateStats(list);
        renderVisitedTags(list);
      }).catch(() => {});
  }

  function updateStats(list) {
    const cnt = list.length;
    const pct = Math.round(cnt / 229 * 100);
    document.getElementById('cnt-visited').textContent = cnt;
    document.getElementById('cnt-pct').textContent = pct;
    document.getElementById('progress-fill').style.width = pct + '%';
  }

  function renderVisitedTags(list) {
    const el = document.getElementById('visited-tags');
    if (!list.length) {
      el.innerHTML = '<span style="font-size:12px;color:var(--muted);">지도에서 지역을 클릭해 기록을 남겨보세요!</span>';
      return;
    }
    el.innerHTML = list.map(item =>
      '<span class="region-tag" onclick="openDetailModalByName(\'' + escJs(item.sigunguName) + '\')">'
      + '<span class="region-dot" style="background:' + (item.colorCode || '#89CFF0') + '"></span>'
      + item.sigunguName + '</span>'
    ).join('');
  }

  // ── 모달 ──
  window.openDetailModalByName = function(name) { openDetailModal(name); };

  function openDetailModal(regionName) {
    document.getElementById('modal-sigungu').value = regionName;
    const existing = visitedDataMap[regionName];
    if (existing) {
      showView(regionName, existing);
    } else {
      showForm(regionName, null);
    }
    document.getElementById('detailModal').classList.add('active');
  }

  function showView(regionName, data) {
    document.getElementById('modal-view').style.display = 'block';
    document.getElementById('modal-form').style.display = 'none';
    document.getElementById('view-region-name').textContent = regionName;

    // 색상
    const color = data.colorCode || '#89CFF0';
    document.getElementById('view-color-dot').style.background = color;
    document.getElementById('view-color-label').textContent = color.toUpperCase();

    // 여행 기간
    const dateRow = document.getElementById('view-date-row');
    if (data.startDate || data.endDate) {
      const s = data.startDate ? data.startDate.slice(0, 10) : '';
      const e = data.endDate   ? data.endDate.slice(0, 10)   : '';
      document.getElementById('view-date').textContent = s && e ? s + ' ~ ' + e : s || e;
      dateRow.style.display = 'block';
    } else {
      dateRow.style.display = 'none';
    }

    // 메모
    const memoRow = document.getElementById('view-memo-row');
    if (data.memo) {
      document.getElementById('view-memo').textContent = data.memo;
      memoRow.style.display = 'block';
    } else {
      memoRow.style.display = 'none';
    }

    // 사진 (다중)
    renderPhotosInView(data.photoList);
  }

  function showForm(regionName, existing) {
    document.getElementById('modal-view').style.display = 'none';
    document.getElementById('modal-form').style.display = 'block';
    document.getElementById('form-region-name').textContent = regionName;
    document.getElementById('modal-color').value = existing?.colorCode || '#89CFF0';
    document.getElementById('modal-start').value = existing?.startDate?.slice(0, 10) || '';
    document.getElementById('modal-end').value   = existing?.endDate?.slice(0, 10)   || '';
    document.getElementById('modal-memo').value  = existing?.memo || '';
    document.getElementById('modal-photo').value = '';

    // 기존 사진 목록 (수정 모드)
    renderPhotosInForm(existing?.photoList);

    // 수정 모드면 취소 버튼 표시
    document.getElementById('btn-cancel-edit').style.display = existing ? 'block' : 'none';
  }

  // ── 사진 렌더링 (조회 뷰) ──
  function renderPhotosInView(photos) {
    const wrap = document.getElementById('view-photos');
    const list = document.getElementById('view-photo-list');
    if (!photos || !photos.length) { wrap.style.display = 'none'; return; }

    wrap.style.display = 'block';
    list.innerHTML = photos.map(p => `
      <img src="${ctxPath}${p.photoUrl}" alt="여행사진"
           style="width:80px;height:80px;object-fit:cover;border-radius:10px;
                  border:1px solid var(--border);cursor:pointer;"
           onclick="window.open('${ctxPath}${p.photoUrl}','_blank')">`
    ).join('');
  }

  // ── 사진 렌더링 (수정 폼 - 삭제 버튼 포함) ──
  function renderPhotosInForm(photos) {
    const wrap = document.getElementById('form-existing-photos');
    const list = document.getElementById('form-photo-list');
    if (!photos || !photos.length) { wrap.style.display = 'none'; return; }

    wrap.style.display = 'block';
    list.innerHTML = photos.map(p => `
      <div style="position:relative;">
        <img src="${ctxPath}${p.photoUrl}"
             style="width:72px;height:72px;object-fit:cover;border-radius:10px;
                    border:1px solid var(--border);">
        <button onclick="deletePhoto(${p.photoId}, this)"
                style="position:absolute;top:-6px;right:-6px;
                       width:20px;height:20px;border-radius:50%;
                       background:#FC8181;border:none;color:#fff;
                       font-size:11px;cursor:pointer;line-height:1;">✕</button>
      </div>`
    ).join('');
  }

  // ── 사진 단건 삭제 ──
  window.deletePhoto = async function(photoId, btn) {
    if (!confirm('이 사진을 삭제할까요?')) return;
    const csrfToken  = document.querySelector("meta[name='_csrf']")?.content;
    const csrfHeader = document.querySelector("meta[name='_csrf_header']")?.content;
    const headers = {};
    if (csrfToken && csrfHeader) headers[csrfHeader] = csrfToken;

    const res = await fetch(ctxPath + '/mypage/api/visited-regions-photo/' + photoId, {
      method: 'DELETE', headers
    });
    if (res.ok) {
      btn.closest('div').remove();
      // visitedDataMap에서도 제거
      const name = document.getElementById('modal-sigungu').value;
      if (visitedDataMap[name]?.photoList) {
        visitedDataMap[name].photoList =
          visitedDataMap[name].photoList.filter(p => p.photoId !== photoId);
      }
    } else {
      alert('사진 삭제에 실패했습니다.');
    }
  };

  window.switchToEdit = function() {
    const name = document.getElementById('modal-sigungu').value;
    showForm(name, visitedDataMap[name]);
  };

  window.switchToView = function() {
    const name = document.getElementById('modal-sigungu').value;
    showView(name, visitedDataMap[name]);
  };

  window.closeModal = function () {
    document.getElementById('detailModal').classList.remove('active');
  };

  // ── 저장 ──
  document.getElementById('btn-save-region').onclick = function () {
    const formData = new FormData();
    formData.append('sigunguName', document.getElementById('modal-sigungu').value);
    formData.append('colorCode',   document.getElementById('modal-color').value);
    formData.append('startDate',   document.getElementById('modal-start').value);
    formData.append('endDate',     document.getElementById('modal-end').value);
    formData.append('memo',        document.getElementById('modal-memo').value);

    // 여러 장 사진 append
    const photos = document.getElementById('modal-photo').files;
    for (const f of photos) {
      formData.append('photos', f); 
    }

    const csrfToken  = document.querySelector("meta[name='_csrf']")?.content;
    const csrfHeader = document.querySelector("meta[name='_csrf_header']")?.content;
    const headers = {};
    if (csrfToken && csrfHeader) headers[csrfHeader] = csrfToken;

    fetch(ctxPath + '/mypage/api/visited-regions-save', { method: 'POST', headers, body: formData })
      .then(r => {
        if (r.ok) { closeModal(); loadVisitedData(); }
        else r.text().then(t => alert('저장 오류: ' + t));
      }).catch(() => alert('서버 연결에 실패했습니다.'));
  };

  // ── 기록 삭제 ──
  document.getElementById('btn-delete-region').onclick = function () {
    const name = document.getElementById('modal-sigungu').value;
    if (!confirm(name + ' 기록을 삭제할까요?')) return;
    const csrfToken  = document.querySelector("meta[name='_csrf']")?.content;
    const csrfHeader = document.querySelector("meta[name='_csrf_header']")?.content;
    const headers = { 'Content-Type': 'application/json' };
    if (csrfToken && csrfHeader) headers[csrfHeader] = csrfToken;
    fetch(ctxPath + '/mypage/api/visited-regions-delete', {
      method: 'DELETE', headers, body: JSON.stringify({ sigunguName: name })
    }).then(r => { if (r.ok) { closeModal(); loadVisitedData(); } })
      .catch(() => {});
  };

  // ── 이미지 저장 ──
  document.getElementById('btn-save-image').onclick = function () {
    const header = document.querySelector('.map-card-header');
    header.style.display = 'none';
    html2canvas(document.getElementById('map-container'), { backgroundColor: '#F8FAFC', scale: 2 })
      .then(canvas => {
        header.style.display = '';
        const a = document.createElement('a');
        a.download = 'My_Tripan_Map.png';
        a.href = canvas.toDataURL('image/png');
        a.click();
      })
      .catch(() => { header.style.display = ''; alert('이미지 저장에 실패했습니다.'); });
  };

  function escJs(s) { return s ? s.replace(/'/g, "\\'") : ''; }

});  // DOMContentLoaded 끝