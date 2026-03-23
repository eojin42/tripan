<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
  String cp = request.getContextPath();
  com.tripan.app.domain.dto.TripDto trip =
      (com.tripan.app.domain.dto.TripDto) request.getAttribute("trip");
  if (trip == null) { response.sendRedirect(cp + "/feed/feed_list"); return; }

  Long   tripId    = trip.getTripId();
  String tripName  = trip.getTripName()       != null ? trip.getTripName()       : "";
  String thumb     = trip.getThumbnailUrl()   != null ? trip.getThumbnailUrl()   : "";
  String cities    = trip.getCitiesStr()      != null ? trip.getCitiesStr()      : "";
  String leader    = trip.getLeaderNickname() != null ? trip.getLeaderNickname() : "트리패너";
  String startDate = trip.getStartDate()      != null ? trip.getStartDate()      : "";
  String endDate   = trip.getEndDate()        != null ? trip.getEndDate()        : "";
  String desc      = trip.getDescription()    != null ? trip.getDescription()    : "";
  int    scrapCnt  = trip.getScrapCount();
%>
<jsp:include page="../layout/header.jsp" />
<link href="https://fonts.googleapis.com/css2?family=Pretendard:wght@300;400;500;600;700;800;900&display=swap" rel="stylesheet">
<link href="https://cdn.quilljs.com/1.3.7/quill.snow.css" rel="stylesheet">
<style>
:root{
  --b:#89CFF0;--pk:#FFB6C1;--oc:#C2B8D9;
  --dk:#1A202C;--md:#4A5568;--lt:#A0AEC0;
  --wh:#fff;--bg:#F3F6FB;--bd:#E2EAF4;
  --g2:linear-gradient(135deg,#89CFF0,#FFB6C1);
  --ez:cubic-bezier(.19,1,.22,1);
  --s1:0 2px 14px rgba(0,0,0,.07);
  --s2:0 12px 40px rgba(0,0,0,.13);
}
*,*::before,*::after{box-sizing:border-box;margin:0;padding:0;}
body{font-family:'Pretendard',sans-serif;background:var(--bg);color:var(--dk);}
@keyframes fu{from{opacity:0;transform:translateY(20px)}to{opacity:1;transform:translateY(0)}}
@keyframes ti{from{opacity:0;transform:translateX(-50%) translateY(8px)}to{opacity:1;transform:translateX(-50%) translateY(0)}}

.dp{max-width:1100px;margin:0 auto;padding:116px 40px 80px;}

.cover{width:100%;aspect-ratio:16/5;border-radius:20px;overflow:hidden;position:relative;margin-bottom:32px;box-shadow:var(--s2);animation:fu .5s .05s var(--ez) both;}
.cover img{width:100%;height:100%;object-fit:cover;display:block;transition:transform 1.4s var(--ez);}
.cover:hover img{transform:scale(1.03);}
.cover.no-img{background:var(--g2);}
.cover-gd{position:absolute;inset:0;background:linear-gradient(to top,rgba(10,16,30,.82) 0%,rgba(10,16,30,.1) 50%,transparent 100%);}
.cover-body{position:absolute;bottom:0;left:0;right:0;padding:28px 32px;}
.c-tags{display:flex;gap:6px;margin-bottom:10px;flex-wrap:wrap;}
.c-tag{padding:3px 11px;background:rgba(255,255,255,.13);backdrop-filter:blur(8px);border:1px solid rgba(255,255,255,.18);border-radius:50px;font-size:10px;font-weight:700;color:rgba(255,255,255,.9);}
.c-title{font-size:26px;font-weight:900;color:#fff;line-height:1.25;letter-spacing:-.5px;word-break:keep-all;text-shadow:0 2px 12px rgba(0,0,0,.3);}

.meta-bar{display:flex;align-items:center;justify-content:space-between;background:var(--wh);border-radius:14px;padding:14px 20px;margin-bottom:28px;box-shadow:var(--s1);animation:fu .5s .1s var(--ez) both;flex-wrap:wrap;gap:12px;}
.meta-auth{display:flex;align-items:center;gap:10px;}
.m-av{width:36px;height:36px;border-radius:50%;background:var(--g2);flex-shrink:0;overflow:hidden;}
.m-av img{width:100%;height:100%;object-fit:cover;}
.m-un{font-size:14px;font-weight:800;color:var(--dk);}
.m-dt{font-size:11px;color:var(--lt);margin-top:1px;}
.meta-stats{display:flex;gap:16px;}
.m-s{font-size:12px;color:var(--lt);font-weight:600;display:flex;align-items:center;gap:4px;}
.HT{color:#E8849A;}

.cols{display:grid;grid-template-columns:1fr 280px;gap:32px;align-items:start;}
.sb{position:sticky;top:24px;display:flex;flex-direction:column;gap:12px;}
.ic,.ac{background:var(--wh);border-radius:16px;padding:20px;box-shadow:var(--s1);}
.ic h4{font-size:10px;font-weight:800;letter-spacing:2.5px;color:var(--lt);text-transform:uppercase;margin-bottom:14px;}
.ir{display:flex;justify-content:space-between;align-items:center;padding:9px 0;border-bottom:1px solid var(--bd);}
.ir:last-child{border-bottom:none;}
.ik{font-size:11px;color:var(--lt);font-weight:600;}
.iv{font-size:13px;font-weight:800;}
.ba,.bs,.bsh{width:100%;padding:11px;border-radius:11px;margin-bottom:7px;font-family:'Pretendard',sans-serif;font-size:12px;font-weight:800;cursor:pointer;transition:all .27s var(--ez);display:flex;align-items:center;justify-content:center;gap:7px;}
.ba{background:var(--g2);border:none;color:#fff;box-shadow:0 4px 12px rgba(137,207,240,.3);}
.ba:hover{transform:translateY(-3px);box-shadow:0 8px 22px rgba(137,207,240,.46);}
.ba.on{background:linear-gradient(135deg,#FFB6C1,#E0BBC2);}
.bs{background:var(--bg);border:1.5px solid var(--bd);color:var(--md);}
.bs:hover{border-color:var(--b);color:var(--b);background:#EBF8FF;transform:translateY(-2px);}
.bs.on{background:linear-gradient(135deg,#C2B8D9,#A8C8E1);border-color:transparent;color:#fff;}
.bsh{background:var(--bg);border:1.5px solid var(--bd);color:var(--md);margin-bottom:0;}
.bsh:hover{background:#EDF2F7;transform:translateY(-2px);}

.art{animation:fu .5s .15s var(--ez) both;}
.sub{background:linear-gradient(135deg,rgba(137,207,240,.07),rgba(255,182,193,.07));border:1.5px solid rgba(137,207,240,.2);border-radius:14px;padding:18px 22px;margin-bottom:28px;}
.sub p{font-size:14px;line-height:1.85;color:var(--md);font-weight:500;}
.ah{font-size:15px;font-weight:900;letter-spacing:-.3px;margin:28px 0 14px;display:flex;align-items:center;gap:8px;}
.ah::before{content:'';display:block;width:3px;height:15px;border-radius:2px;background:var(--g2);flex-shrink:0;}

/* Day 블록 */
.day-block{margin-bottom:20px;background:var(--wh);border-radius:16px;overflow:hidden;box-shadow:var(--s1);}
.day-header{display:flex;align-items:center;gap:10px;padding:14px 20px;border-bottom:1px solid var(--bd);}
.day-badge{background:var(--g2);color:#fff;font-size:10px;font-weight:900;padding:4px 14px;border-radius:50px;white-space:nowrap;}
.day-date-lbl{font-size:11px;color:var(--lt);font-weight:600;}
.day-body{padding:16px 20px;}

/* 장소 */
.place-list{display:flex;flex-direction:column;gap:10px;margin-bottom:14px;}
.place-item{display:flex;gap:12px;padding:12px 14px;background:var(--bg);border-radius:12px;align-items:flex-start;}
.place-num{width:22px;height:22px;border-radius:50%;background:var(--g2);color:#fff;font-size:9px;font-weight:900;display:flex;align-items:center;justify-content:center;flex-shrink:0;margin-top:2px;}
.place-info{flex:1;min-width:0;}
.place-name{font-size:13px;font-weight:800;margin-bottom:2px;}
.place-addr{font-size:10px;color:var(--lt);margin-bottom:4px;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;}
.place-imgs{display:flex;gap:6px;margin-top:8px;flex-wrap:wrap;}
.place-img{width:72px;height:72px;border-radius:8px;object-fit:cover;cursor:pointer;transition:transform .2s;}
.place-img:hover{transform:scale(1.05);}

/* Quill 읽기전용 */
.ql-container.ql-snow{border:none!important;font-family:'Pretendard',sans-serif;}
.ql-editor{padding:4px 0!important;font-size:12px;line-height:1.8;color:var(--md);min-height:0!important;}
.ql-toolbar{display:none!important;}
.ql-container.ql-disabled .ql-editor{cursor:default;}
.day-memo-wrap{margin-top:10px;padding-top:10px;border-top:1px dashed var(--bd);}
.day-memo-lbl{font-size:9px;font-weight:700;color:var(--lt);letter-spacing:1.5px;text-transform:uppercase;margin-bottom:4px;}
/* 장소 메모 Quill */
.place-memo-quill{background:var(--wh);border-radius:8px;padding:6px 10px;margin-top:4px;}

/* 태그 */
.tags{display:flex;flex-wrap:wrap;gap:6px;margin:18px 0;}
.tag{padding:5px 12px;border:1.5px solid var(--bd);border-radius:50px;font-size:11px;font-weight:700;color:var(--md);}

/* 연관 피드 */
.rw{max-width:1100px;margin:0 auto;padding:0 40px 48px;}
.rh{font-size:16px;font-weight:900;margin-bottom:16px;}
.rg{display:grid;grid-template-columns:repeat(4,1fr);gap:14px;}
.rc{border-radius:14px;overflow:hidden;background:var(--wh);box-shadow:var(--s1);text-decoration:none;color:inherit;transition:all .3s var(--ez);display:block;opacity:0;transform:translateY(12px);}
.rc.in{opacity:1;transform:translateY(0);}
.rc:hover{transform:translateY(-5px);box-shadow:var(--s2);}
.ri{height:138px;overflow:hidden;background:var(--g2);}
.ri img{width:100%;height:100%;object-fit:cover;display:block;}
.rb{padding:11px 12px 12px;}
.rt{font-size:12px;font-weight:800;margin-bottom:6px;line-height:1.35;word-break:keep-all;}
.rf{display:flex;justify-content:space-between;font-size:10px;color:var(--lt);font-weight:600;align-items:center;}
.rf-usr{display:flex;align-items:center;gap:5px;}
.rf-av{width:16px;height:16px;border-radius:50%;background:var(--g2);overflow:hidden;flex-shrink:0;}
.rf-av img{width:100%;height:100%;object-fit:cover;}

/* 라이트박스 */
#lb{display:none;position:fixed;inset:0;background:rgba(0,0,0,.88);z-index:9990;align-items:center;justify-content:center;}
#lb.on{display:flex;}
#lb img{max-width:90vw;max-height:88vh;border-radius:12px;}
#lb-close{position:absolute;top:20px;right:24px;color:#fff;font-size:28px;cursor:pointer;background:none;border:none;}

/* ━━━ 담아오기 안내 모달 ━━━ */
.modal-overlay{display:none;position:fixed;inset:0;background:rgba(10,16,30,.6);backdrop-filter:blur(6px);z-index:9980;align-items:center;justify-content:center;}
.modal-overlay.open{display:flex;}
.scrap-guide-box{background:#fff;border-radius:24px;padding:36px 32px;max-width:400px;width:90%;text-align:center;box-shadow:0 20px 60px rgba(0,0,0,.2);animation:sgIn .4s cubic-bezier(.19,1,.22,1) both;}
@keyframes sgIn{from{opacity:0;transform:scale(.92) translateY(20px)}to{opacity:1;transform:scale(1) translateY(0)}}
.sg-icon{font-size:44px;margin-bottom:12px;}
.sg-title{font-size:20px;font-weight:900;color:var(--dk);margin-bottom:10px;letter-spacing:-.4px;}
.sg-desc{font-size:13px;color:var(--md);line-height:1.8;margin-bottom:18px;}
.sg-desc strong{color:var(--dk);font-weight:800;}
.sg-tips{background:var(--bg);border-radius:12px;padding:14px 16px;margin-bottom:20px;text-align:left;display:flex;flex-direction:column;gap:7px;}
.sg-tip{font-size:12px;color:var(--md);font-weight:600;}
.sg-btns{display:flex;flex-direction:column;gap:8px;}
.sg-btn-primary{display:block;padding:13px;border-radius:12px;background:var(--g2);color:#fff;font-size:13px;font-weight:800;text-decoration:none;transition:all .25s var(--ez);}
.sg-btn-primary:hover{transform:translateY(-2px);box-shadow:0 6px 20px rgba(137,207,240,.4);}
.sg-btn-secondary{padding:11px;border-radius:12px;background:var(--bg);border:1.5px solid var(--bd);color:var(--md);font-family:'Pretendard',sans-serif;font-size:12px;font-weight:700;cursor:pointer;transition:all .2s;}
.sg-btn-secondary:hover{border-color:var(--b);color:var(--b);}

.loading{text-align:center;padding:40px;color:var(--lt);font-size:13px;}
#TB{display:none;position:fixed;bottom:22px;left:50%;transform:translateX(-50%);background:#1A202C;color:#fff;padding:10px 20px;border-radius:50px;font-size:12px;font-weight:700;z-index:9999;box-shadow:0 8px 24px rgba(0,0,0,.18);white-space:nowrap;}

@media(max-width:960px){.cols{grid-template-columns:1fr;}.sb{position:static;}.rg{grid-template-columns:repeat(2,1fr);}}
@media(max-width:768px){.dp{padding:80px 20px 60px;}.rw{padding-left:20px;padding-right:20px;}.c-title{font-size:20px;}}
</style>

<div class="dp">
  <%-- 커버 --%>
  <div class="cover<%= thumb.isEmpty() ? " no-img" : "" %>">
    <% if (!thumb.isEmpty()) { %><img src="<%= thumb %>" alt="<%= tripName %>"><% } %>
    <div class="cover-gd"></div>
    <div class="cover-body">
      <div class="c-tags" id="coverTagWrap">
        <% for (String c : cities.split("[,\\s]+")) { if (!c.trim().isEmpty()) { %>
        <span class="c-tag">#<%= c.trim() %></span>
        <% }} %>
      </div>
      <div class="c-title"><%= tripName %></div>
    </div>
  </div>

  <%-- 메타 바 --%>
  <div class="meta-bar">
    <div class="meta-auth">
      <div class="m-av" id="authorAv"></div>
      <div>
        <div class="m-un">@<%= leader %></div>
        <div class="m-dt"><%= startDate %> ~ <%= endDate %></div>
      </div>
    </div>
    <div class="meta-stats">
      <span class="m-s"><span class="HT">&#9829;</span> <span id="likeNum">-</span></span>
      <span class="m-s">&#128278; <span id="scrapNum"><%= scrapCnt %></span></span>
    </div>
  </div>

  <%-- 본문 --%>
  <div class="cols">
    <article class="art">
      <% if (!desc.isEmpty()) { %>
      <div class="sub"><p><%= desc %></p></div>
      <% } %>
      <div class="ah">여행 일정</div>
      <div id="dayList"><div class="loading">일정 불러오는 중...</div></div>
    </article>

    <aside class="sb">
      <div class="ic">
        <h4>여행 정보</h4>
        <div class="ir"><span class="ik">여행지</span><span class="iv"><%= cities %></span></div>
        <div class="ir"><span class="ik">기간</span><span class="iv"><%= startDate %> ~ <%= endDate %></span></div>
        <div class="ir"><span class="ik">유형</span><span class="iv" id="sbType">-</span></div>
      </div>
      <div class="ac">
        <button class="ba" id="bL" onclick="toggleLike()">&#9829; 좋아요 <span id="sbLike">-</span></button>
        <button class="bs" id="bS" onclick="doScrap()">&#128278; 내 여행에 담기 <span id="sbScrap"><%= scrapCnt %></span></button>
      </div>
    </aside>
  </div>
</div>

<%-- 비슷한 여행 --%>
<div class="rw">
  <div class="rh">비슷한 여행 피드</div>
  <div class="rg" id="relGrid"><div class="loading" style="grid-column:1/-1">불러오는 중...</div></div>
</div>

<%-- ━━━ 담아오기 안내 모달 ━━━ --%>
<div class="modal-overlay" id="scrapGuideModal" onclick="closeScrapGuideModal()" style="z-index:9980;">
  <div class="scrap-guide-box" onclick="event.stopPropagation()">
    <div class="sg-icon">🗂️</div>
    <h3 class="sg-title">여행을 담아왔어요!</h3>
    <p class="sg-desc">
      이 여행 일정이 <strong>내 여행 목록</strong>에 저장됐어요.<br>
      상세보기에서 <strong>수정</strong>을 통해 나만의 여행으로 꾸며보세요!
    </p>
    <div class="sg-tips">
      <div class="sg-tip">✏️ 장소를 추가하거나 순서를 바꿔보세요</div>
      <div class="sg-tip">📅 날짜와 일정을 내 상황에 맞게 조정하세요</div>
      <div class="sg-tip">👥 동행자를 초대해 함께 계획하세요</div>
    </div>
    <div class="sg-btns">
      <a class="sg-btn-primary" id="scrapGuideLink" href="#">✈️ 내 여행 보러가기</a>
      <button class="sg-btn-secondary" onclick="closeScrapGuideModal()">나중에 할게요</button>
    </div>
  </div>
</div>

<div id="lb" onclick="closeLb()">
  <button id="lb-close" onclick="closeLb()">&#10005;</button>
  <img id="lb-img" src="" alt="">
</div>
<div id="TB"></div>

<jsp:include page="../layout/footer.jsp" />
<script src="https://cdn.quilljs.com/1.3.7/quill.min.js"></script>
<script>
var CP     = '<%= cp %>';
var TRIPID = <%= tripId %>;
var _liked = false;

var CAT = {FOOD:'🍽 식당',RESTAURANT:'🍽 식당',ACCOMMODATION:'🏨 숙소',ATTRACTION:'🎯 관광',SHOPPING:'🛍 쇼핑',LEISURE:'🎢 액티비티',CAFE:'☕ 카페',FESTIVAL:'🎉 축제',NONE:'📍 장소'};
var TTYPE = {COUPLE:'💑 커플',FAMILY:'👨‍👩‍👧 가족',FRIENDS:'🤝 친구',SOLO:'🧳 혼자',BUSINESS:'💼 비즈니스'};

/* ━━━ 상세 데이터 fetch ━━━ */
fetch(CP + '/feed/detail-data?tripId=' + TRIPID)
  .then(function(r){ return r.json(); })
  .then(function(d) {
    /* 좋아요 */
    _liked = d.myLike;
    document.getElementById('likeNum').textContent = d.likeCount;
    document.getElementById('sbLike').textContent  = d.likeCount;
    if (_liked) document.getElementById('bL').classList.add('on');

    /* 작성자 프로필 이미지 */
    var t = d.trip;
    var profSrc = CP + '/dist/images/trip_icon.png'; // 기본 이미지
    if (t && t.leaderProfileImage) {
      profSrc = t.leaderProfileImage.startsWith('http')
        ? t.leaderProfileImage
        : CP + '/' + t.leaderProfileImage;
    }
    document.getElementById('authorAv').innerHTML = '<img src="'+esc(profSrc)+'" alt="">';

    /* 여행 유형 */
    if (t && t.tripType) document.getElementById('sbType').textContent = TTYPE[t.tripType] || t.tripType;

    /* 태그 → 커버 이미지 안에 추가 */
    if (d.tags && d.tags.length) {
      var wrap = document.getElementById('coverTagWrap');
      if (wrap) {
        d.tags.forEach(function(tag){
          var s = document.createElement('span');
          s.className = 'c-tag';
          s.textContent = tag;
          wrap.appendChild(s);
        });
      }
    }

    /* Day 일정 */
    renderDays(d.days);

    /* 비슷한 여행 */
    renderRelated(d.related);
  })
  .catch(function(e){ console.error('[FeedDetail]', e); });

/* ━━━ Day 렌더링 ━━━ */
function renderDays(days) {
  var el = document.getElementById('dayList');
  if (!days || !days.length) { el.innerHTML = '<div class="loading">등록된 일정이 없어요.</div>'; return; }

  el.innerHTML = days.map(function(day) {
    var items = (day.items || []).filter(function(it){ return it.placeName; });
    var placesHtml = items.map(function(item, idx){
      var cat = CAT[item.categoryName] || CAT[item.category] || '📍';
      var memoId = 'memo_' + item.itemId;
      var imgHtml = '';
      if (item.images && item.images.length) {
        imgHtml = '<div class="place-imgs">'
          + item.images.map(function(img){
              var s = img.imageUrl
                ? (img.imageUrl.startsWith('http') ? img.imageUrl : CP + img.imageUrl)
                : '';
              return s ? '<img class="place-img" src="'+esc(s)+'" onclick="openLb(\''+esc(s)+'\')" alt="">' : '';
            }).join('')
          + '</div>';
      }
      return '<div class="place-item">'
        + '<div class="place-num">'+(idx+1)+'</div>'
        + '<div class="place-info">'
        + '<div class="place-name">'+esc(item.placeName)+'</div>'
        + '<div class="place-addr">'+cat+(item.address?' · '+esc(item.address):'')+'</div>'
        + (item.memo ? '<div id="'+memoId+'" class="place-memo-quill"></div>' : '')
        + imgHtml
        + '</div></div>';
    }).join('');

    var memoSecHtml = day.dayMemo
      ? '<div class="day-memo-wrap"><div class="day-memo-lbl">Day 메모</div><div id="dm_'+day.dayId+'"></div></div>'
      : '';

    return '<div class="day-block">'
      + '<div class="day-header">'
      + '<span class="day-badge">DAY '+day.dayNumber+'</span>'
      + '<span class="day-date-lbl">'+(day.tripDate||'')+'</span>'
      + '</div>'
      + '<div class="day-body">'
      + (items.length ? '<div class="place-list">'+placesHtml+'</div>' : '<div style="color:var(--lt);font-size:12px">장소가 없어요.</div>')
      + memoSecHtml
      + '</div></div>';
  }).join('');

  /* Quill 읽기전용 렌더링 — DOM 생성 완료 후 실행 */
  setTimeout(function(){
    days.forEach(function(day){
      if (day.dayMemo) {
        var e = document.getElementById('dm_'+day.dayId);
        if (e) {
          var q = new Quill(e, {theme:'snow',readOnly:true,modules:{toolbar:false}});
          try { q.setContents(JSON.parse(day.dayMemo)); } catch(ex){ q.setText(day.dayMemo); }
        }
      }
      (day.items||[]).forEach(function(item){
        if (item.memo) {
          var e2 = document.getElementById('memo_'+item.itemId);
          if (e2) {
            var q2 = new Quill(e2, {theme:'snow',readOnly:true,modules:{toolbar:false}});
            try { q2.setContents(JSON.parse(item.memo)); } catch(ex){ q2.setText(item.memo); }
          }
        }
      });
    });
  }, 50);
}

/* ━━━ 비슷한 여행 렌더링 ━━━ */
function renderRelated(list) {
  var el = document.getElementById('relGrid');
  if (!list || !list.length) { el.innerHTML = '<div style="color:var(--lt);font-size:13px;grid-column:1/-1">비슷한 여행이 없어요.</div>'; return; }
  el.innerHTML = list.map(function(t, i){
    var thumb  = t.thumbnailUrl ? (t.thumbnailUrl.startsWith('http') ? t.thumbnailUrl : CP+t.thumbnailUrl) : '';
    var profImg = t.leaderProfileImage || '';
    var avSrc  = profImg ? (profImg.startsWith('http') ? profImg : CP+'/'+profImg) : CP+'/dist/images/trip_icon.png';
    return '<a href="'+CP+'/feed/feed_detail?tripId='+t.tripId+'" class="rc" style="transition:opacity .32s '+(i*.09)+'s,transform .32s '+(i*.09)+'s var(--ez)">'
      + '<div class="ri">'+(thumb?'<img src="'+esc(thumb)+'" alt="">':'')+'</div>'
      + '<div class="rb"><div class="rt">'+esc(t.tripName||'여행')+'</div>'
      + '<div class="rf">'
      + '<div class="rf-usr"><div class="rf-av"><img src="'+esc(avSrc)+'" alt=""></div><span>@'+esc(t.leaderNickname||'트리패너')+'</span></div>'
      + '<span>&#9829; '+(t.scrapCount||0)+'</span>'
      + '</div></div></a>';
  }).join('');
  var ob = new IntersectionObserver(function(en){en.forEach(function(e){if(e.isIntersecting){e.target.classList.add('in');ob.unobserve(e.target);}});},{threshold:.1});
  document.querySelectorAll('.rc').forEach(function(c){ ob.observe(c); });
}

/* ━━━ 좋아요 ━━━ */
function toggleLike(){
  fetch(CP+'/feed/like?tripId='+TRIPID,{method:'POST'})
    .then(function(r){return r.json();})
    .then(function(d){
      if(d.success===false){sT('로그인이 필요합니다');return;}
      _liked=d.liked;
      document.getElementById('likeNum').textContent=d.count;
      document.getElementById('sbLike').textContent=d.count;
      document.getElementById('bL').classList.toggle('on',_liked);
      sT(_liked?'❤️ 좋아요!':'좋아요 취소');
    });
}

/* ━━━ 담아오기 ━━━ */
function doScrap(){
  var btn=document.getElementById('bS');
  if(btn.classList.contains('done')){sT('이미 내 여행에 담겨있어요 🗂');return;}
  btn.disabled=true;
  fetch(CP+'/feed/scrap?tripId='+TRIPID,{method:'POST'})
    .then(function(r){return r.json();})
    .then(function(d){
      btn.disabled=false;
      if(d.success){
        btn.classList.add('on','done');
        // 스크랩 수 +1 반영
        var numEl=document.getElementById('sbScrap');
        var metaEl=document.getElementById('scrapNum');
        if(numEl) numEl.textContent=parseInt(numEl.textContent||0)+1;
        if(metaEl) metaEl.textContent=parseInt(metaEl.textContent||0)+1;
        // 안내 모달 표시
        openScrapGuideModal(d.newTripId);
      } else {
        sT(d.message||'로그인이 필요합니다');
      }
    }).catch(function(){btn.disabled=false;sT('오류가 발생했습니다');});
}

/* ━━━ 담아오기 안내 모달 ━━━ */
function openScrapGuideModal(newTripId) {
  var m = document.getElementById('scrapGuideModal');
  if (!m) return;
  // 워크스페이스 링크 세팅
  var link = document.getElementById('scrapGuideLink');
  if (link && newTripId) link.href = CP + '/trip/' + newTripId + '/workspace';
  m.classList.add('open');
}
function closeScrapGuideModal() {
  var m = document.getElementById('scrapGuideModal');
  if (m) m.classList.remove('open');
}

/* ━━━ 라이트박스 ━━━ */
function openLb(src){document.getElementById('lb-img').src=src;document.getElementById('lb').classList.add('on');}
function closeLb(){document.getElementById('lb').classList.remove('on');}

/* ━━━ 유틸 ━━━ */
function esc(s){return String(s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;');}
function sT(m){var t=document.getElementById('TB');t.innerHTML=m;t.style.cssText='display:block;position:fixed;bottom:22px;left:50%;transform:translateX(-50%);background:#1A202C;color:#fff;padding:10px 20px;border-radius:50px;font-size:12px;font-weight:700;z-index:9999;box-shadow:0 8px 24px rgba(0,0,0,.18);animation:ti .3s ease;white-space:nowrap;font-family:Pretendard,sans-serif;';clearTimeout(window._tt);window._tt=setTimeout(function(){t.style.display='none';},2400);}
var _s=document.createElement('style');_s.textContent='@keyframes ti{from{opacity:0;transform:translateX(-50%) translateY(8px)}to{opacity:1;transform:translateX(-50%) translateY(0)}}';document.head.appendChild(_s);
</script>
