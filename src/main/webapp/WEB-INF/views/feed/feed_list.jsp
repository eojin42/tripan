<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
  String cp = request.getContextPath();
%>
<jsp:include page="../layout/header.jsp" />
<link href="https://fonts.googleapis.com/css2?family=Pretendard:wght@300;400;500;600;700;800;900&display=swap" rel="stylesheet">
<style>
/* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   TRIPAN — feed_list.jsp  (리디자인)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */
:root{
  --b:#89CFF0; --p:#FFB6C1; --oc:#C2B8D9;
  --dk:#1A202C; --md:#4A5568; --lt:#A0AEC0;
  --wh:#fff; --bg:#F3F6FB; --bd:#E2EAF4;
  --g2:linear-gradient(135deg,#89CFF0,#FFB6C1);
  --g3:linear-gradient(135deg,#a8d8f0,#f0b8c8);
  --ez:cubic-bezier(.19,1,.22,1);
  --s1:0 2px 12px rgba(0,0,0,.06);
  --s2:0 12px 40px rgba(0,0,0,.14);
  --s3:0 4px 20px rgba(137,207,240,.25);
}
*,*::before,*::after{box-sizing:border-box;margin:0;padding:0;}
body{font-family:'Pretendard',sans-serif;background:var(--bg);color:var(--dk);}

@keyframes fu{from{opacity:0;transform:translateY(20px)}to{opacity:1;transform:translateY(0)}}
@keyframes ti{from{opacity:0;transform:translateX(-50%) translateY(8px)}to{opacity:1;transform:translateX(-50%) translateY(0)}}

.W{max-width:1240px;margin:0 auto;padding:0 40px;}

.SH{display:flex;justify-content:space-between;align-items:flex-end;margin-bottom:24px;animation:fu .5s var(--ez) both;}
.SH-L h2{font-size:20px;font-weight:900;letter-spacing:-.5px;}
.SH-L p{font-size:12px;color:var(--lt);margin-top:4px;}
a.SH-R{font-size:12px;font-weight:700;color:var(--lt);text-decoration:none;transition:color .2s;}
a.SH-R:hover{color:var(--b);}

/* ━━━ 섹션 A — 인기 피드 ━━━ */
.A{padding:48px 0 56px;}
.car-w{position:relative;}
.car-o{overflow:hidden;}
.car-t{display:flex;gap:20px;transition:transform .5s var(--ez);}

.HC{
  flex:0 0 calc(25% - 15px);
  background:var(--wh);border-radius:20px;overflow:hidden;
  box-shadow:var(--s1);text-decoration:none;color:inherit;display:block;
  transition:transform .35s var(--ez),box-shadow .35s;
  animation:fu .5s var(--ez) both;
  border:1px solid rgba(226,234,244,.8);
}
.HC:nth-child(1){animation-delay:.05s}.HC:nth-child(2){animation-delay:.1s}
.HC:nth-child(3){animation-delay:.15s}.HC:nth-child(4){animation-delay:.2s}
.HC:hover{transform:translateY(-8px);box-shadow:var(--s2);}

.HC-img{position:relative;height:200px;overflow:hidden;}
.HC-img img{width:100%;height:100%;object-fit:cover;display:block;transition:transform 1.6s var(--ez);}
.HC:hover .HC-img img{transform:scale(1.08);}
.HC-dim{position:absolute;inset:0;background:linear-gradient(to top,rgba(10,16,30,.65) 0%,transparent 55%);}
.HC-img.no-img{background:var(--g3);}

.HC-rank{position:absolute;top:12px;left:12px;background:var(--g2);color:#fff;font-size:9px;font-weight:900;letter-spacing:2px;padding:4px 12px;border-radius:50px;box-shadow:0 2px 8px rgba(137,207,240,.4);}

/* 통계 뱃지 — 좋아요+담기 나란히 */
.HC-stats{position:absolute;top:12px;right:12px;display:flex;gap:5px;}
.HC-stat{background:rgba(255,255,255,.92);backdrop-filter:blur(10px);border-radius:50px;padding:4px 9px;font-size:10px;font-weight:800;color:var(--dk);display:flex;align-items:center;gap:3px;}
.HC-stat.like{color:#E8849A;}
.HC-stat.scrap{color:#5BA7CE;}

.HC-bd{padding:14px 16px 16px;}
.HC-loc{font-size:9px;font-weight:700;letter-spacing:.5px;color:var(--b);text-transform:uppercase;margin-bottom:5px;}
.HC-tit{font-size:14px;font-weight:800;line-height:1.4;margin-bottom:10px;word-break:keep-all;}
.HC-usr{display:flex;align-items:center;gap:7px;}
.AV{width:22px;height:22px;border-radius:50%;background:var(--g2);flex-shrink:0;overflow:hidden;border:1.5px solid var(--wh);box-shadow:0 1px 4px rgba(0,0,0,.1);}
.AV img{width:100%;height:100%;object-fit:cover;}
.UN{font-size:11px;font-weight:600;color:var(--md);}

.CB{position:absolute;top:100px;width:38px;height:38px;border-radius:50%;background:var(--wh);border:1.5px solid var(--bd);box-shadow:0 4px 14px rgba(0,0,0,.1);cursor:pointer;display:flex;align-items:center;justify-content:center;color:var(--md);font-size:14px;transition:all .2s;z-index:10;}
.CB:hover{background:var(--b);color:#fff;border-color:var(--b);transform:scale(1.08);}
.CB:disabled{opacity:.2;cursor:not-allowed;}
.CB.pv{left:-19px;}.CB.nx{right:-19px;}
.dots{display:flex;justify-content:center;gap:5px;margin-top:20px;}
.dot{width:6px;height:6px;border-radius:50%;background:var(--bd);border:none;cursor:pointer;padding:0;transition:all .35s var(--ez);}
.dot.on{width:22px;border-radius:3px;background:var(--g2);}

/* ━━━ 섹션 B — 전체 피드 ━━━ */
.B-bg{background:var(--wh);}
.B{padding:48px 0 64px;}

.FB{display:flex;align-items:center;gap:6px;margin-bottom:24px;flex-wrap:wrap;}
.FC{padding:7px 16px;border-radius:50px;border:1.5px solid var(--bd);background:transparent;font-family:'Pretendard',sans-serif;font-size:11px;font-weight:700;color:var(--md);cursor:pointer;transition:all .2s;white-space:nowrap;}
.FC:hover{border-color:var(--b);color:var(--b);}
.FC.on{border-color:transparent;background:var(--g2);color:#fff;box-shadow:var(--s3);}
.FR{margin-left:auto;display:flex;gap:6px;align-items:center;}
.SS{padding:7px 14px;border:1.5px solid var(--bd);border-radius:50px;font-family:'Pretendard',sans-serif;font-size:11px;font-weight:600;color:var(--md);background:transparent;outline:none;cursor:pointer;appearance:none;}

.FG{display:grid;grid-template-columns:repeat(4,1fr);gap:20px;}

.FD{
  background:var(--wh);border-radius:20px;overflow:hidden;
  text-decoration:none;color:inherit;display:block;
  border:1.5px solid rgba(226,234,244,.7);
  box-shadow:var(--s1);
  transition:all .35s var(--ez);
  opacity:0;transform:translateY(18px);
}
.FD.in{opacity:1;transform:translateY(0);}
.FD:hover{transform:translateY(-8px);box-shadow:var(--s2);border-color:rgba(137,207,240,.35);}

.FD-img{position:relative;height:186px;overflow:hidden;}
.FD-img img{width:100%;height:100%;object-fit:cover;display:block;transition:transform 1.2s var(--ez);}
.FD:hover .FD-img img{transform:scale(1.07);}
.FD-img.no-img{background:var(--g3);}
.FD-dim{position:absolute;inset:0;background:linear-gradient(to top,rgba(10,16,30,.3),transparent 55%);}

/* 카드 이미지 위 통계 */
.FD-overlay-stats{position:absolute;bottom:10px;right:10px;display:flex;gap:4px;}
.FD-stat{background:rgba(255,255,255,.88);backdrop-filter:blur(8px);border-radius:50px;padding:3px 8px;font-size:9px;font-weight:800;display:flex;align-items:center;gap:2px;}
.FD-stat.like{color:#E8849A;}
.FD-stat.scrap{color:#5BA7CE;}

.FD-bd{padding:14px 15px 15px;}
.FD-loc{font-size:9px;font-weight:700;color:var(--b);letter-spacing:.5px;margin-bottom:5px;}
.FD-tit{font-size:13px;font-weight:800;margin-bottom:12px;line-height:1.4;word-break:keep-all;}
.FD-ft{display:flex;justify-content:space-between;align-items:center;border-top:1px solid var(--bd);padding-top:9px;}
.FD-usr{display:flex;align-items:center;gap:5px;font-size:10px;font-weight:600;color:var(--md);}

#loadMore{text-align:center;padding:36px 0;}
.spinner{display:inline-block;width:24px;height:24px;border:3px solid var(--bd);border-top-color:var(--b);border-radius:50%;animation:spin .7s linear infinite;}
@keyframes spin{to{transform:rotate(360deg)}}
#noMore{text-align:center;padding:36px 0;font-size:12px;color:var(--lt);font-weight:600;display:none;}
.empty{text-align:center;padding:60px 0;color:var(--lt);font-size:13px;}

@media(max-width:1100px){.FG{grid-template-columns:repeat(3,1fr);}.HC{flex:0 0 calc(33.333% - 14px);}}
@media(max-width:768px){.W{padding:0 20px;}.FG{grid-template-columns:repeat(2,1fr);}.HC{flex:0 0 calc(50% - 10px);}.FR{margin-left:0;width:100%;}}
@media(max-width:480px){.FG{grid-template-columns:1fr;}.HC{flex:0 0 100%;}}
</style>

<%-- ━━━ 섹션 A : 인기 피드 ━━━ --%>
<div class="W">
  <section class="A">
    <div class="SH" style="animation-delay:.05s">
      <div class="SH-L"><h2>실시간 인기 피드 &#128293;</h2><p>지금 가장 많이 담겨진 여행 코스</p></div>
    </div>
    <div class="car-w">
      <button class="CB pv" id="cP" onclick="cMv(-1)" disabled>&#8592;</button>
      <div class="car-o">
        <div class="car-t" id="cT">
          <%-- JS로 채워짐 --%>
        </div>
      </div>
      <button class="CB nx" id="cN" onclick="cMv(1)">&#8594;</button>
    </div>
    <div class="dots" id="cD"></div>
  </section>
</div>

<%-- ━━━ 섹션 B : 전체 피드 (무한스크롤) ━━━ --%>
<div class="B-bg">
  <div class="W">
    <section class="B">
      <div class="SH" style="animation-delay:.1s">
        <div class="SH-L"><h2>전체 피드</h2><p>트리판 유저들의 생생한 여행 이야기</p></div>
      </div>
      <div class="FG" id="fg"></div>
      <div id="loadMore"><div class="spinner"></div></div>
      <div id="noMore">더 이상 피드가 없어요 ✈️</div>
    </section>
  </div>
</div>

<jsp:include page="../layout/footer.jsp" />
<script>
var CP = '<%= cp %>';

/* ━━━ 캐러셀 초기화 (API로 채움) ━━━ */
var ci = 0;
function cpv(){return window.innerWidth<480?1:window.innerWidth<768?2:window.innerWidth<1100?3:4;}
function bld(){
  var cD=document.getElementById('cD');
  cD.innerHTML='';
  var cs=document.querySelectorAll('#cT .HC'), tot=cs.length;
  if(!tot) return;
  var p=Math.ceil(tot/cpv());
  for(var i=0;i<p;i++){
    var d=document.createElement('button');
    d.className='dot'+(i===ci?' on':'');
    (function(x){d.onclick=function(){gt(x);};})(i);
    cD.appendChild(d);
  }
}
function gt(i){
  var cs=document.querySelectorAll('#cT .HC'), tot=cs.length;
  var c=cpv(), m=Math.max(0,Math.ceil(tot/c)-1);
  ci=Math.max(0,Math.min(i,m));
  var w=cs[0]?cs[0].offsetWidth+16:0;
  document.getElementById('cT').style.transform='translateX(-'+(ci*c*w)+'px)';
  document.getElementById('cP').disabled=ci===0;
  document.getElementById('cN').disabled=ci>=m;
  document.querySelectorAll('.dot').forEach(function(d,j){d.classList.toggle('on',j===ci);});
}
function cMv(d){gt(ci+d);}
window.addEventListener('resize',function(){bld();gt(0);});

/* 인기 캐러셀 카드 생성 */
function makeHotCard(t, rank) {
  var thumb   = t.thumbnailUrl || '';
  var cities  = t.citiesStr || '';
  var name    = t.tripName || '여행';
  var leader  = t.leaderNickname || '트리패너';
  var scrap   = t.scrapCount || 0;
  var likes   = t.likeCount || 0;
  var profImg = t.leaderProfileImage || '';

  var imgInner = thumb
    ? '<img src="'+esc(thumb)+'" alt="'+esc(name)+'" loading="lazy"><div class="HC-dim"></div>'
    : '<div class="HC-dim"></div>';
  var imgCls = thumb ? 'HC-img' : 'HC-img no-img';

  var locLabel = cities
    ? cities.split(',').slice(0,2).map(function(c){return c.trim();}).filter(Boolean).join(' · ')
    : '국내여행';

  // 프로필 이미지
  var avHtml = profImg
    ? '<div class="AV"><img src="'+esc(profImg.startsWith('http')?profImg:CP+'/'+profImg)+'" alt=""></div>'
    : '<div class="AV"><img src="'+CP+'/dist/images/trip_icon.png" alt=""></div>';

  return '<a href="'+CP+'/feed/feed_detail?tripId='+t.tripId+'" class="HC">'
    +'<div class="'+imgCls+'">'+ imgInner
    +'<span class="HC-rank">HOT '+rank+'</span>'
    +'<div class="HC-stats">'
    +'<span class="HC-stat like">❤️ '+likes+'</span>'
    +'<span class="HC-stat scrap">🗂 '+scrap+'</span>'
    +'</div>'
    +'</div>'
    +'<div class="HC-bd">'
    +'<div class="HC-loc">📍 '+esc(locLabel)+'</div>'
    +'<div class="HC-tit">'+esc(name)+'</div>'
    +'<div class="HC-usr">'+avHtml+'<span class="UN">@'+esc(leader)+'</span></div>'
    +'</div></a>';
}

/* 인기 TOP 8 로드 */
fetch(CP + '/feed/public-trips?page=0&size=8')
  .then(function(r){ return r.json(); })
  .then(function(list) {
    var cT = document.getElementById('cT');
    var items = list.slice(0, 8);
    if (items.length === 0) {
      cT.innerHTML = '<div style="padding:40px;color:var(--lt);font-size:13px;">공개된 여행이 아직 없어요.</div>';
      return;
    }
    cT.innerHTML = items.map(function(t, i){ return makeHotCard(t, i+1); }).join('');
    bld();
  })
  .catch(function(e){ console.error('[Hot] 로드 실패', e); });

/* ━━━ 무한스크롤 ━━━ */
var PAGE = 0;
var SIZE = 12;
var loading = false;
var done = false;

/* 카드 HTML 생성 */
function makeCard(t) {
  var thumb   = t.thumbnailUrl || '';
  var cities  = t.citiesStr || '';
  var name    = t.tripName || '여행';
  var leader  = t.leaderNickname || '트리패너';
  var scrap   = t.scrapCount || 0;
  var likes   = t.likeCount || 0;
  var profImg = t.leaderProfileImage || '';

  var imgHtml = thumb
    ? '<img src="' + esc(thumb) + '" alt="' + esc(name) + '" loading="lazy"><div class="FD-dim"></div>'
    : '';
  var imgCls = thumb ? 'FD-img' : 'FD-img no-img';

  var locLabel = cities
    ? cities.split(',').slice(0,2).map(function(c){return c.trim();}).filter(Boolean).join(' · ')
    : '국내여행';

  var avHtml = profImg
    ? '<div class="AV"><img src="'+esc(profImg.startsWith('http')?profImg:CP+'/'+profImg)+'" alt=""></div>'
    : '<div class="AV"><img src="'+CP+'/dist/images/trip_icon.png" alt=""></div>';

  return '<a href="' + CP + '/feed/feed_detail?tripId=' + t.tripId + '" class="FD">'
    + '<div class="' + imgCls + '">' + imgHtml
    + '<div class="FD-overlay-stats">'
    + '<span class="FD-stat like">❤️ ' + likes + '</span>'
    + '<span class="FD-stat scrap">🗂 ' + scrap + '</span>'
    + '</div>'
    + '</div>'
    + '<div class="FD-bd">'
    + '<div class="FD-loc">📍 ' + esc(locLabel) + '</div>'
    + '<div class="FD-tit">' + esc(name) + '</div>'
    + '<div class="FD-ft">'
    + '<div class="FD-usr">' + avHtml + '<span>@' + esc(leader) + '</span></div>'
    + '</div>'
    + '</div>'
    + '</a>';
}

function esc(s) {
  return String(s)
    .replace(/&/g,'&amp;').replace(/</g,'&lt;')
    .replace(/>/g,'&gt;').replace(/"/g,'&quot;');
}

/* 스크롤 인 애니메이션 감지 */
var ob = new IntersectionObserver(function(en){
  en.forEach(function(e){
    if(e.isIntersecting){ e.target.classList.add('in'); ob.unobserve(e.target); }
  });
}, {threshold:.07, rootMargin:'0px 0px -20px 0px'});

/* 데이터 fetch */
function loadMore() {
  if (loading || done) return;
  loading = true;

  fetch(CP + '/feed/public-trips?page=' + PAGE + '&size=' + SIZE)
    .then(function(r){ return r.json(); })
    .then(function(list) {
      var fg = document.getElementById('fg');
      var hasMore = list.length > SIZE; // size+1개 요청했으므로 초과분이 있으면 다음 페이지 존재

      // 실제 렌더링은 SIZE개만
      var renderList = hasMore ? list.slice(0, SIZE) : list;

      if (PAGE === 0 && renderList.length === 0) {
        fg.innerHTML = '<div class="empty">공개된 여행이 아직 없어요 ✈️</div>';
        document.getElementById('loadMore').style.display = 'none';
        document.getElementById('noMore').style.display = 'block';
        loading = false;
        return;
      }

      renderList.forEach(function(t, i) {
        var wrapper = document.createElement('div');
        wrapper.innerHTML = makeCard(t);
        var card = wrapper.firstChild;
        // 스태거 애니메이션
        card.style.transition = 'opacity .34s ' + (i % 4 * 0.07) + 's, transform .34s ' + (i % 4 * 0.07) + 's cubic-bezier(.19,1,.22,1)';
        fg.appendChild(card);
        ob.observe(card);
      });

      PAGE++;
      loading = false;

      if (!hasMore) {
        done = true;
        document.getElementById('loadMore').style.display = 'none';
        document.getElementById('noMore').style.display = 'block';
      }
    })
    .catch(function(e) {
      console.error('[FeedList] 데이터 로드 실패', e);
      loading = false;
    });
}

/* 스크롤 감지 — 바닥 200px 전에 다음 페이지 로드 */
var sentinel = document.getElementById('loadMore');
var scrollOb = new IntersectionObserver(function(en) {
  en.forEach(function(e) {
    if (e.isIntersecting) loadMore();
  });
}, { rootMargin: '0px 0px 200px 0px' });
scrollOb.observe(sentinel);

/* 초기 로드 */
loadMore();

/* ━━━ 토스트 ━━━ */
var _t=null;
function sT(m){if(_t)_t.remove();_t=document.createElement('div');_t.textContent=m;_t.style.cssText='position:fixed;bottom:22px;left:50%;transform:translateX(-50%);background:#1A202C;color:#fff;padding:10px 20px;border-radius:50px;font-size:12px;font-weight:700;z-index:9999;box-shadow:0 8px 24px rgba(0,0,0,.18);animation:ti .3s ease;white-space:nowrap;font-family:Pretendard,sans-serif;';document.body.appendChild(_t);setTimeout(function(){if(_t){_t.style.opacity='0';_t.style.transition='opacity .25s';setTimeout(function(){if(_t)_t.remove();},260);}},2200);}
var _s=document.createElement('style');_s.textContent='@keyframes ti{from{opacity:0;transform:translateX(-50%) translateY(8px)}to{opacity:1;transform:translateX(-50%) translateY(0)}}';document.head.appendChild(_s);
</script>
