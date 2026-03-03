<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%
  String cp = request.getContextPath();
  /* ────────────────────────────────
     더미 데이터 — 실제는 model attribute 사용
  ──────────────────────────────── */
  String[] hotT  = {"부산 2박3일 핫플 뚜시기","제주 동쪽 감성 숙소 투어","속초 1박2일 맛집 지도","강릉 드라이브 코스","경주 한옥스테이 추천","여수 밤바다 여행","통영 섬투어 코스","전주 한옥 막걸리"};
  String[] hotTag= {"#부산 #해운대","#제주도 #오션뷰","#속초 #바다","#강릉 #드라이브","#경주 #한옥","#여수 #야경","#통영 #섬","#전주 #한옥"};
  String[] hotU  = {"@travel_holic","@jeju_vibe","@n_bread_master","@world_driver","@gyeongju_s","@yeosu_night","@tongyeong_k","@jeonju_fan"};
  int[]    hotL  = {890,750,620,540,430,380,310,285};
  String[] hotD  = {"담아오기 1,204회 기록 돌파!","오션뷰 숙소만 엄선","가성비 N빵 공개","인생샷 보장 로드트립","고즈넉한 한옥스테이","야경 맛집 총정리","섬 일주 완벽 가이드","막걸리+비빔밥 코스"};
  String[] hotI  = {"https://picsum.photos/seed/bsn01/700/460","https://picsum.photos/seed/jju01/700/460","https://picsum.photos/seed/sc01/700/460","https://picsum.photos/seed/gl01/700/460","https://picsum.photos/seed/gj01/700/460","https://picsum.photos/seed/ys01/700/460","https://picsum.photos/seed/tg01/700/460","https://picsum.photos/seed/jj01/700/460"};
  int[]    hotId = {1,2,3,4,5,6,7,8};

  String[] allT  = {"서울 성수동 카페 투어","전주 한옥마을 1박","남해 독일마을 드라이브","통영 한려수도 유람","안동 찜닭 성지 순례","제주 올레길 완주 후기","부산 광안리 야경","강화도 당일치기","춘천 닭갈비+소양강","대구 근대골목 탐방","담양 메타세쿼이아","양평 카페거리"};
  String[] allTag= {"#서울 #성수","#전주 #한옥","#남해 #드라이브","#통영 #바다","#안동 #맛집","#제주 #올레길","#부산 #야경","#강화도","#춘천 #닭갈비","#대구 #골목","#담양 #숲","#양평 #카페"};
  int[]    allL  = {312,289,245,210,198,187,165,143,132,118,104,98};
  int[]    allV  = {4200,3800,3100,2900,2600,2400,2100,1900,1700,1500,1300,1100};
  String[] allU  = {"@seoul_local","@jeonju_fan","@namhae_go","@tongyeong_s","@andong_food","@jeju_walker","@busan_night","@ganghwa_t","@chuncheon_e","@daegu_alley","@damyang_f","@yangpyeong_c"};
  String[] allI  = {"https://picsum.photos/seed/ss01/500/340","https://picsum.photos/seed/jj02/500/340","https://picsum.photos/seed/nh01/500/340","https://picsum.photos/seed/tg02/500/340","https://picsum.photos/seed/ad01/500/340","https://picsum.photos/seed/ol01/500/340","https://picsum.photos/seed/ga01/500/340","https://picsum.photos/seed/gh01/500/340","https://picsum.photos/seed/cc01/500/340","https://picsum.photos/seed/dg01/500/340","https://picsum.photos/seed/dy01/500/340","https://picsum.photos/seed/yp01/500/340"};
  int[]    allId = {1,2,3,4,5,6,7,8,9,10,11,12};
%>
<jsp:include page="../layout/header.jsp" />
<link href="https://fonts.googleapis.com/css2?family=Pretendard:wght@300;400;500;600;700;800;900&display=swap" rel="stylesheet">
<style>
/* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   TRIPAN — feed_list.jsp
   인기피드(회색 bg) + 전체피드(흰 bg)
   완전히 동일한 카드 스펙으로 통일
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */
:root{
  --b:#89CFF0; --p:#FFB6C1; --oc:#C2B8D9;
  --dk:#1A202C; --md:#4A5568; --lt:#A0AEC0;
  --wh:#fff; --bg:#F3F6FB; --bd:#E2EAF4;
  --g2:linear-gradient(135deg,#89CFF0,#FFB6C1);
  --ez:cubic-bezier(.19,1,.22,1);
  --s1:0 1px 8px rgba(0,0,0,.07);
  --s2:0 10px 32px rgba(0,0,0,.13);
}
*,*::before,*::after{box-sizing:border-box;margin:0;padding:0;}
body{font-family:'Pretendard',sans-serif;background:var(--bg);color:var(--dk);}

@keyframes fu{from{opacity:0;transform:translateY(20px)}to{opacity:1;transform:translateY(0)}}
@keyframes ti{from{opacity:0;transform:translateX(-50%) translateY(8px)}to{opacity:1;transform:translateX(-50%) translateY(0)}}

/* ─── 공통 래퍼 ─── */
.W{max-width:1240px;margin:0 auto;padding:0 40px;}

/* ─── 공통 섹션 헤더 — 양쪽 동일 ─── */
.SH{display:flex;justify-content:space-between;align-items:flex-end;margin-bottom:20px;animation:fu .5s var(--ez) both;}
.SH-L h2{font-size:19px;font-weight:900;letter-spacing:-.4px;}
.SH-L p{font-size:12px;color:var(--lt);margin-top:3px;}
a.SH-R{font-size:12px;font-weight:700;color:var(--lt);text-decoration:none;transition:color .2s;}
a.SH-R:hover{color:var(--b);}

/* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   섹션 A — 인기 피드 (배경: --bg 회색)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */
.A{padding:44px 0 52px;}

.car-w{position:relative;}
.car-o{overflow:hidden;}
.car-t{display:flex;gap:16px;transition:transform .5s var(--ez);}

/* ─── 카드 공통 스펙 ─── */
/* HOT 카드 */
.HC{
  flex:0 0 calc(25% - 12px);
  background:var(--wh);border-radius:16px;overflow:hidden;
  box-shadow:var(--s1);text-decoration:none;color:inherit;display:block;
  transition:transform .3s var(--ez),box-shadow .3s;
  animation:fu .5s var(--ez) both;
}
.HC:nth-child(1){animation-delay:.05s}.HC:nth-child(2){animation-delay:.1s}
.HC:nth-child(3){animation-delay:.15s}.HC:nth-child(4){animation-delay:.2s}
.HC:hover{transform:translateY(-7px);box-shadow:var(--s2);}

.HC-img{position:relative;height:196px;overflow:hidden;}
.HC-img img{width:100%;height:100%;object-fit:cover;display:block;transition:transform 1.5s var(--ez);}
.HC:hover .HC-img img{transform:scale(1.09);}
.HC-dim{position:absolute;inset:0;background:linear-gradient(to top,rgba(18,26,38,.55),transparent 52%);}
.HC-rank{position:absolute;top:10px;left:10px;background:var(--g2);color:#fff;font-size:9px;font-weight:900;letter-spacing:2px;padding:3px 10px;border-radius:50px;}
.HC-like{position:absolute;top:10px;right:10px;background:rgba(255,255,255,.93);backdrop-filter:blur(8px);border-radius:50px;padding:4px 10px;font-size:11px;font-weight:800;color:var(--dk);display:flex;align-items:center;gap:3px;}
.HT{color:#E8849A;}

.HC-bd{padding:13px 15px 15px;}
.HC-tag{font-size:10px;font-weight:700;color:var(--b);margin-bottom:4px;}
.HC-tit{font-size:14px;font-weight:800;line-height:1.35;margin-bottom:5px;word-break:keep-all;}
.HC-dsc{font-size:11px;color:var(--lt);margin-bottom:11px;}
.HC-usr{display:flex;align-items:center;gap:6px;}
.AV{width:21px;height:21px;border-radius:50%;background:var(--g2);flex-shrink:0;}
.UN{font-size:11px;font-weight:600;color:var(--md);}

/* 캐러셀 버튼 */
.CB{position:absolute;top:98px;width:36px;height:36px;border-radius:50%;background:var(--wh);border:1.5px solid var(--bd);box-shadow:0 3px 12px rgba(0,0,0,.08);cursor:pointer;display:flex;align-items:center;justify-content:center;color:var(--md);font-size:14px;transition:all .2s;z-index:10;}
.CB:hover{background:var(--b);color:#fff;border-color:var(--b);}
.CB:disabled{opacity:.22;cursor:not-allowed;}
.CB.pv{left:-18px;}.CB.nx{right:-18px;}
.dots{display:flex;justify-content:center;gap:5px;margin-top:18px;}
.dot{width:6px;height:6px;border-radius:50%;background:var(--bd);border:none;cursor:pointer;padding:0;transition:all .3s var(--ez);}
.dot.on{width:20px;border-radius:3px;background:var(--g2);}

/* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   섹션 B — 전체 피드 (배경: 흰색)
   섹션 A와 경계: 배경색만 다름, 나머지 동일
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */
.B-bg{background:var(--wh);}
.B{padding:44px 0 60px;}

/* 필터 바 */
.FB{display:flex;align-items:center;gap:6px;margin-bottom:22px;flex-wrap:wrap;}
.FC{padding:6px 14px;border-radius:50px;border:1.5px solid var(--bd);background:transparent;font-family:'Pretendard',sans-serif;font-size:11px;font-weight:700;color:var(--md);cursor:pointer;transition:all .2s;white-space:nowrap;}
.FC:hover{border-color:var(--b);color:var(--b);}
.FC.on{border-color:transparent;background:var(--g2);color:#fff;box-shadow:0 3px 10px rgba(137,207,240,.3);}
.FR{margin-left:auto;display:flex;gap:6px;align-items:center;}
.SS{padding:7px 13px;border:1.5px solid var(--bd);border-radius:50px;font-family:'Pretendard',sans-serif;font-size:11px;font-weight:600;color:var(--md);background:transparent;outline:none;cursor:pointer;appearance:none;}
.BW{padding:7px 17px;border:none;border-radius:50px;background:var(--g2);color:#fff;font-family:'Pretendard',sans-serif;font-size:11px;font-weight:800;cursor:pointer;box-shadow:0 3px 10px rgba(137,207,240,.28);transition:all .25s var(--ez);}
.BW:hover{transform:translateY(-2px);box-shadow:0 6px 16px rgba(137,207,240,.4);}

/* ─── 전체피드 그리드 — HC와 동일 4열/gap ─── */
.FG{display:grid;grid-template-columns:repeat(4,1fr);gap:16px;}

.FD{
  background:var(--bg);border-radius:16px;overflow:hidden;
  text-decoration:none;color:inherit;display:block;
  border:1.5px solid var(--bd);
  transition:all .3s var(--ez);
  opacity:0;transform:translateY(16px);
}
.FD.in{opacity:1;transform:translateY(0);}
.FD:hover{transform:translateY(-7px);box-shadow:var(--s2);border-color:rgba(137,207,240,.3);background:var(--wh);}

/* 이미지 — HC-img와 동일 높이 */
.FD-img{position:relative;height:196px;overflow:hidden;}
.FD-img img{width:100%;height:100%;object-fit:cover;display:block;transition:transform 1.2s var(--ez);}
.FD:hover .FD-img img{transform:scale(1.08);}
.FD-dim{position:absolute;inset:0;background:linear-gradient(to top,rgba(18,26,38,.28),transparent 50%);}

/* 바디 — HC-bd와 동일 padding */
.FD-bd{padding:13px 15px 15px;}
.FD-tag{font-size:10px;font-weight:700;color:var(--b);margin-bottom:4px;}
.FD-tit{font-size:14px;font-weight:800;margin-bottom:10px;line-height:1.35;word-break:keep-all;}
.FD-ft{display:flex;justify-content:space-between;align-items:center;border-top:1px solid var(--bd);padding-top:8px;}
.FD-usr{display:flex;align-items:center;gap:5px;font-size:10px;font-weight:600;color:var(--md);}
.FD-st{display:flex;gap:6px;font-size:10px;color:var(--lt);font-weight:600;}

/* 더보기 */
.LR{text-align:center;padding-top:32px;}
.BL{padding:11px 42px;border:1.5px solid var(--bd);border-radius:50px;background:transparent;font-family:'Pretendard',sans-serif;font-size:12px;font-weight:700;color:var(--md);cursor:pointer;transition:all .25s var(--ez);}
.BL:hover{border-color:var(--b);color:var(--b);}

@media(max-width:1100px){.FG{grid-template-columns:repeat(3,1fr);}.HC{flex:0 0 calc(33.333% - 11px);}}
@media(max-width:768px){.W{padding:0 20px;}.FG{grid-template-columns:repeat(2,1fr);}.HC{flex:0 0 calc(50% - 8px);}.FR{margin-left:0;width:100%;}}
@media(max-width:480px){.FG{grid-template-columns:1fr;}.HC{flex:0 0 100%;}}
</style>

<%-- ━━━ 섹션 A : 인기 피드 ━━━ --%>
<div class="W">
  <section class="A">
    <div class="SH" style="animation-delay:.05s">
      <div class="SH-L"><h2>실시간 인기 피드 &#128293;</h2><p>지금 이 순간 가장 많이 담겨진 여행 코스</p></div>
      <a href="<%= cp %>/feed/feed_list" class="SH-R">전체보기 &rarr;</a>
    </div>
    <div class="car-w">
      <button class="CB pv" id="cP" onclick="cMv(-1)" disabled>&#8592;</button>
      <div class="car-o">
        <div class="car-t" id="cT">
          <% for(int i=0;i<hotT.length;i++){ %>
          <a href="<%= cp %>/feed/feed_detail" class="HC">
            <div class="HC-img">
              <img src="<%= hotI[i] %>" alt="<%= hotT[i] %>" loading="lazy">
              <div class="HC-dim"></div>
              <span class="HC-rank">HOT <%= i+1 %></span>
              <span class="HC-like"><span class="HT">&#9829;</span> <%= hotL[i] %></span>
            </div>
            <div class="HC-bd">
              <div class="HC-tag"><%= hotTag[i] %></div>
              <div class="HC-tit"><%= hotT[i] %></div>
              <div class="HC-dsc"><%= hotD[i] %></div>
              <div class="HC-usr"><div class="AV"></div><span class="UN"><%= hotU[i] %></span></div>
            </div>
          </a>
          <% } %>
        </div>
      </div>
      <button class="CB nx" id="cN" onclick="cMv(1)">&#8594;</button>
    </div>
    <div class="dots" id="cD"></div>
  </section>
</div>

<%-- ━━━ 섹션 B : 전체 피드 ━━━ --%>
<div class="B-bg">
  <div class="W">
    <section class="B">
      <div class="SH" style="animation-delay:.1s">
        <div class="SH-L"><h2>전체 피드</h2><p>트리판 유저들의 생생한 여행 이야기</p></div>
      </div>
      <div class="FB">
        <button class="FC on" onclick="flt(this)">전체</button>
        <button class="FC" onclick="flt(this)">&#127472;&#127479; 국내</button>
        <button class="FC" onclick="flt(this)">&#127860; 맛집</button>
        <button class="FC" onclick="flt(this)">&#127968; 숙소</button>
        <button class="FC" onclick="flt(this)">&#127940; 액티비티</button>
        <button class="FC" onclick="flt(this)">&#128176; 가성비</button>
        <div class="FR">
          <select class="SS"><option>인기순</option><option>최신순</option><option>담아오기순</option></select>
          <button class="BW">&#9998; 여행 공유하기</button>
        </div>
      </div>
      <div class="FG" id="fg">
        <% for(int i=0;i<allT.length;i++){ %>
        <a href="<%= cp %>/feed/feed_detail" class="FD">
          <div class="FD-img">
            <img src="<%= allI[i] %>" alt="<%= allT[i] %>" loading="lazy">
            <div class="FD-dim"></div>
          </div>
          <div class="FD-bd">
            <div class="FD-tag"><%= allTag[i] %></div>
            <div class="FD-tit"><%= allT[i] %></div>
            <div class="FD-ft">
              <div class="FD-usr"><div class="AV" style="background:linear-gradient(135deg,#A8C8E1,#C2B8D9)"></div><span><%= allU[i] %></span></div>
              <div class="FD-st"><span>&#9829; <%= allL[i] %></span><span>&#128065; <%= String.format("%,d",allV[i]) %></span></div>
            </div>
          </div>
        </a>
        <% } %>
      </div>
      <div class="LR"><button class="BL" onclick="lM()">더 보기 &#8595;</button></div>
    </section>
  </div>
</div>

<jsp:include page="../layout/footer.jsp" />
<script>
/* 캐러셀 */
var cT=document.getElementById('cT'),cP=document.getElementById('cP'),cN=document.getElementById('cN'),cD=document.getElementById('cD'),ci=0;
var cs=cT.querySelectorAll('.HC'),tot=cs.length;
function cpv(){return window.innerWidth<480?1:window.innerWidth<768?2:window.innerWidth<1100?3:4;}
function bld(){cD.innerHTML='';var p=Math.ceil(tot/cpv());for(var i=0;i<p;i++){var d=document.createElement('button');d.className='dot'+(i===ci?' on':'');(function(x){d.onclick=function(){gt(x);};})(i);cD.appendChild(d);}}
function gt(i){var c=cpv(),m=Math.ceil(tot/c)-1;ci=Math.max(0,Math.min(i,m));var w=cs[0].offsetWidth+16;cT.style.transform='translateX(-'+(ci*c*w)+'px)';cP.disabled=ci===0;cN.disabled=ci>=m;document.querySelectorAll('.dot').forEach(function(d,j){d.classList.toggle('on',j===ci);});}
function cMv(d){gt(ci+d);}
window.addEventListener('resize',function(){bld();gt(ci);});
bld();
/* 스크롤 인 */
var ob=new IntersectionObserver(function(en){en.forEach(function(e){if(e.isIntersecting){e.target.classList.add('in');ob.unobserve(e.target);}});},{threshold:.07,rootMargin:'0px 0px -20px 0px'});
document.querySelectorAll('.FD').forEach(function(el,i){el.style.transition='opacity .34s '+(i%4*.07)+'s,transform .34s '+(i%4*.07)+'s cubic-bezier(.19,1,.22,1)';ob.observe(el);});
/* 필터 */
function flt(b){document.querySelectorAll('.FC').forEach(function(c){c.classList.remove('on');});b.classList.add('on');}
function lM(){sT('다음 페이지 로딩 중');}
/* 토스트 */
var _t=null;
function sT(m){if(_t)_t.remove();_t=document.createElement('div');_t.textContent=m;_t.style.cssText='position:fixed;bottom:22px;left:50%;transform:translateX(-50%);background:#1A202C;color:#fff;padding:10px 20px;border-radius:50px;font-size:12px;font-weight:700;z-index:9999;box-shadow:0 8px 24px rgba(0,0,0,.18);animation:ti .3s ease;white-space:nowrap;font-family:Pretendard,sans-serif;';document.body.appendChild(_t);setTimeout(function(){if(_t){_t.style.opacity='0';_t.style.transition='opacity .25s';setTimeout(function(){if(_t)_t.remove();},260);}},2200);}
var _s=document.createElement('style');_s.textContent='@keyframes ti{from{opacity:0;transform:translateX(-50%) translateY(8px)}to{opacity:1;transform:translateX(-50%) translateY(0)}}';document.head.appendChild(_s);
</script>