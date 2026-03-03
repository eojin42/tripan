<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%
  String cp     = request.getContextPath();
  String fTitle = "부산 2박3일 핫플 뚜시기 — 로컬이 알려주는 진짜 부산";
  String fUser  = "@travel_holic";
  String fDate  = "2026.02.20";
  String fCity  = "부산"; String fDays = "2박 3일";
  int fPeople=2, fBudget=320000, fLikes=890, fViews=4200, fScraps=312;
  String fThumb = "https://picsum.photos/seed/bsn01/1400/700";
  String[] relT = {"제주 동쪽 감성 숙소 투어","속초 1박2일 맛집 지도","강릉 드라이브 코스","경주 한옥스테이 추천"};
  String[] relI = {"https://picsum.photos/seed/jju01/500/340","https://picsum.photos/seed/sc01/500/340","https://picsum.photos/seed/gl01/500/340","https://picsum.photos/seed/gj01/500/340"};
  String[] relU = {"@jeju_vibe","@n_bread_master","@world_driver","@gyeongju_s"};
  int[] relL={750,620,540,430}; int[] relId={2,3,4,5};
%>
<jsp:include page="../layout/header.jsp" />
<link href="https://fonts.googleapis.com/css2?family=Pretendard:wght@300;400;500;600;700;800;900&display=swap" rel="stylesheet">
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

/* ━━━ 페이지 래퍼 ━━━ */
.dp { max-width: 1100px; margin: 0 auto; padding: 116px 40px 80px; }

/* ━━━ 브레드크럼 ━━━ */
.bc{display:flex;align-items:center;gap:6px;margin-bottom:24px;animation:fu .4s var(--ez) both;}
.bc a{font-size:12px;color:var(--lt);text-decoration:none;font-weight:600;transition:color .2s;}
.bc a:hover{color:var(--b);}
.bc-sep{font-size:11px;color:var(--bd);}
.bc-cur{font-size:12px;color:var(--md);font-weight:700;}

/* ━━━ 커버 이미지 (16:5 비율, 둥근 모서리) ━━━ */
.cover{
  width:100%;aspect-ratio:16/5;
  border-radius:20px;overflow:hidden;
  position:relative;margin-bottom:32px;
  box-shadow:var(--s2);
  animation:fu .5s .05s var(--ez) both;
}
.cover img{width:100%;height:100%;object-fit:cover;display:block;transition:transform 1.4s var(--ez);}
.cover:hover img{transform:scale(1.03);}
.cover-gd{
  position:absolute;inset:0;
  background:linear-gradient(to top,rgba(10,16,30,.82) 0%,rgba(10,16,30,.1) 50%,transparent 100%);
}
/* 커버 안 하단 — 태그 + 제목 */
.cover-body{
  position:absolute;bottom:0;left:0;right:0;
  padding:28px 32px;
  animation:fu .6s .12s var(--ez) both;
}
.c-tags{display:flex;gap:6px;margin-bottom:10px;flex-wrap:wrap;}
.c-tag{padding:3px 11px;background:rgba(255,255,255,.13);backdrop-filter:blur(8px);border:1px solid rgba(255,255,255,.18);border-radius:50px;font-size:10px;font-weight:700;color:rgba(255,255,255,.9);}
.c-title{font-size:26px;font-weight:900;color:#fff;line-height:1.25;letter-spacing:-.5px;word-break:keep-all;text-shadow:0 2px 12px rgba(0,0,0,.3);}

/* ━━━ 메타 바 (작성자 + 통계) ━━━ */
.meta-bar{
  display:flex;align-items:center;justify-content:space-between;
  background:var(--wh);border-radius:14px;
  padding:14px 20px;margin-bottom:28px;
  box-shadow:var(--s1);
  animation:fu .5s .1s var(--ez) both;
  flex-wrap:wrap;gap:12px;
}
.meta-auth{display:flex;align-items:center;gap:10px;}
.m-av{width:36px;height:36px;border-radius:50%;background:var(--g2);flex-shrink:0;}
.m-un{font-size:14px;font-weight:800;color:var(--dk);}
.m-dt{font-size:11px;color:var(--lt);margin-top:1px;}
.meta-stats{display:flex;gap:16px;}
.m-s{font-size:12px;color:var(--lt);font-weight:600;display:flex;align-items:center;gap:4px;}
.HT{color:#E8849A;}

/* ━━━ 2컬럼 레이아웃 ━━━ */
.cols{display:grid;grid-template-columns:1fr 280px;gap:32px;align-items:start;}

/* ━━━ 사이드바 ━━━ */
.sb{position:sticky;top:24px;display:flex;flex-direction:column;gap:12px;}
.ic,.ac{background:var(--wh);border-radius:16px;padding:20px;box-shadow:var(--s1);animation:fu .6s .18s var(--ez) both;}
.ic h4{font-size:10px;font-weight:800;letter-spacing:2.5px;color:var(--lt);text-transform:uppercase;margin-bottom:14px;}
.ir{display:flex;justify-content:space-between;align-items:center;padding:9px 0;border-bottom:1px solid var(--bd);}
.ir:last-child{border-bottom:none;}
.ik{font-size:11px;color:var(--lt);font-weight:600;}
.iv{font-size:13px;font-weight:800;}
.ac{animation-delay:.24s;}
.ba,.bs,.bsh{
  width:100%;padding:11px;border-radius:11px;margin-bottom:7px;
  font-family:'Pretendard',sans-serif;font-size:12px;font-weight:800;
  cursor:pointer;transition:all .27s var(--ez);
  display:flex;align-items:center;justify-content:center;gap:7px;
}
.ba{background:var(--g2);border:none;color:#fff;box-shadow:0 4px 12px rgba(137,207,240,.3);}
.ba:hover{transform:translateY(-3px);box-shadow:0 8px 22px rgba(137,207,240,.46);}
.ba.on{background:linear-gradient(135deg,#FFB6C1,#E0BBC2);}
.bs{background:var(--bg);border:1.5px solid var(--bd);color:var(--md);}
.bs:hover{border-color:var(--b);color:var(--b);background:#EBF8FF;transform:translateY(-2px);}
.bs.on{background:linear-gradient(135deg,#C2B8D9,#A8C8E1);border-color:transparent;color:#fff;}
.bsh{background:var(--bg);border:1.5px solid var(--bd);color:var(--md);margin-bottom:0;}
.bsh:hover{background:#EDF2F7;transform:translateY(-2px);}

/* ━━━ 아티클 ━━━ */
.art{animation:fu .5s .15s var(--ez) both;}
.sub{background:linear-gradient(135deg,rgba(137,207,240,.07),rgba(255,182,193,.07));border:1.5px solid rgba(137,207,240,.2);border-radius:14px;padding:18px 22px;margin-bottom:28px;}
.sub p{font-size:14px;line-height:1.85;color:var(--md);font-weight:500;}
.sub strong{color:var(--dk);font-weight:800;}
.ah{font-size:15px;font-weight:900;letter-spacing:-.3px;margin:28px 0 14px;display:flex;align-items:center;gap:8px;}
.ah::before{content:'';display:block;width:3px;height:15px;border-radius:2px;background:var(--g2);flex-shrink:0;}

/* 타임라인 */
.td{margin-bottom:22px;}
.tdh{display:flex;align-items:center;gap:9px;margin-bottom:12px;}
.tb{background:var(--g2);color:#fff;font-size:10px;font-weight:900;padding:4px 13px;border-radius:50px;white-space:nowrap;}
.tdt{font-size:11px;color:var(--lt);font-weight:600;}
.tl{border-left:2px solid var(--bd);margin-left:11px;padding-left:18px;}
.ti{position:relative;padding-bottom:16px;}
.ti:last-child{padding-bottom:0;}
.ti::before{content:'';position:absolute;left:-25px;top:5px;width:9px;height:9px;border-radius:50%;background:var(--g2);box-shadow:0 0 0 3px rgba(137,207,240,.18);}
.ttp{display:inline-flex;font-size:10px;font-weight:700;padding:2px 8px;border-radius:50px;margin-bottom:3px;}
.ttf{background:rgba(255,182,193,.15);color:#D4708A;}
.tts{background:rgba(194,184,217,.15);color:#8B7BAE;}
.ttt{background:rgba(137,207,240,.15);color:#5BA7CE;}
.tpl{font-size:14px;font-weight:800;margin-bottom:2px;}
.tad{font-size:11px;color:var(--lt);margin-bottom:5px;}
.tmo{font-size:12px;color:var(--md);background:var(--bg);border-radius:9px;padding:9px 13px;line-height:1.7;}

/* 갤러리 */
.gal{display:grid;grid-template-columns:repeat(3,1fr);grid-template-rows:auto auto;gap:8px;margin:16px 0 28px;}
.gi{border-radius:11px;overflow:hidden;}
.gi img{width:100%;height:100%;object-fit:cover;display:block;transition:transform 1s var(--ez);}
.gi:hover img{transform:scale(1.06);}
.gi:not(.tall){aspect-ratio:4/3;}
.gi.tall{grid-row:span 2;}

/* 가계부 */
.btot{background:var(--g2);border-radius:14px;padding:18px 20px;color:#fff;margin-bottom:9px;}
.blbl{font-size:10px;font-weight:700;opacity:.78;letter-spacing:2px;text-transform:uppercase;}
.bamt{font-size:28px;font-weight:900;letter-spacing:-.8px;margin:3px 0;}
.bper{font-size:12px;opacity:.82;}
.bgr{display:grid;grid-template-columns:1fr 1fr;gap:8px;margin-bottom:24px;}
.bi{background:var(--bg);border-radius:11px;padding:13px 15px;}
.bct{font-size:10px;color:var(--lt);font-weight:700;margin-bottom:3px;}
.bvl{font-size:15px;font-weight:900;}

/* 태그 */
.tags{display:flex;flex-wrap:wrap;gap:6px;margin:18px 0;}
.tag{padding:5px 12px;border:1.5px solid var(--bd);border-radius:50px;font-size:11px;font-weight:700;color:var(--md);text-decoration:none;transition:all .2s;}
.tag:hover{border-color:var(--b);color:var(--b);}

/* ━━━ 연관 피드 ━━━ */
.rw{max-width:1100px;margin:0 auto;padding:0 40px 48px;}
.rh{font-size:16px;font-weight:900;margin-bottom:16px;letter-spacing:-.3px;}
.rg{display:grid;grid-template-columns:repeat(4,1fr);gap:14px;}
.rc{border-radius:14px;overflow:hidden;background:var(--wh);box-shadow:var(--s1);text-decoration:none;color:inherit;transition:all .3s var(--ez);display:block;opacity:0;transform:translateY(12px);}
.rc.in{opacity:1;transform:translateY(0);}
.rc:hover{transform:translateY(-5px);box-shadow:var(--s2);}
.ri{height:138px;overflow:hidden;}
.ri img{width:100%;height:100%;object-fit:cover;display:block;transition:transform .9s var(--ez);}
.rc:hover .ri img{transform:scale(1.07);}
.rb{padding:11px 12px 12px;}
.rt{font-size:12px;font-weight:800;margin-bottom:6px;line-height:1.35;word-break:keep-all;}
.rf{display:flex;justify-content:space-between;font-size:10px;color:var(--lt);font-weight:600;}

/* ━━━ 댓글 ━━━ */
.cw{max-width:780px;margin:0 auto;padding:0 40px 64px;}
.ch{font-size:15px;font-weight:900;margin-bottom:18px;}
.ci{display:flex;gap:9px;margin-bottom:22px;align-items:flex-start;}
.cav{width:34px;height:34px;border-radius:50%;background:var(--g2);flex-shrink:0;margin-top:2px;}
.cta{flex:1;padding:11px 14px;height:72px;border:1.5px solid var(--bd);border-radius:11px;resize:none;font-family:'Pretendard',sans-serif;font-size:13px;outline:none;transition:border-color .2s;background:var(--wh);}
.cta:focus{border-color:var(--b);}
.csb{padding:8px 18px;border:none;border-radius:50px;background:var(--g2);color:#fff;font-family:'Pretendard',sans-serif;font-size:12px;font-weight:800;cursor:pointer;align-self:flex-end;white-space:nowrap;box-shadow:0 3px 10px rgba(137,207,240,.28);transition:all .25s var(--ez);}
.cl{display:flex;flex-direction:column;gap:12px;}
.cm{display:flex;gap:9px;}
.cbody{flex:1;background:var(--wh);border-radius:13px;padding:12px 15px;box-shadow:var(--s1);}
.ctop{display:flex;justify-content:space-between;align-items:center;margin-bottom:5px;}
.cnm{font-size:12px;font-weight:800;}
.cdt{font-size:10px;color:var(--lt);}
.ctx{font-size:13px;color:var(--md);line-height:1.7;}
.cac{display:flex;gap:8px;margin-top:6px;}
.cab{font-size:10px;font-weight:700;color:var(--lt);background:none;border:none;cursor:pointer;padding:0;transition:color .2s;}
.cab:hover{color:var(--b);}

#TB{display:none;position:fixed;bottom:22px;left:50%;transform:translateX(-50%);background:var(--dk);color:#fff;padding:10px 20px;border-radius:50px;font-size:12px;font-weight:700;z-index:9999;box-shadow:0 8px 24px rgba(0,0,0,.18);white-space:nowrap;}

@media(max-width:960px){.cols{grid-template-columns:1fr;}.sb{position:static;}.rg{grid-template-columns:repeat(2,1fr);}}
@media(max-width:768px){.dp{padding:24px 20px 60px;}.rw,.cw{padding-left:20px;padding-right:20px;}.gal{grid-template-columns:repeat(2,1fr);}.gi.tall{grid-row:span 1;aspect-ratio:4/3;}.c-title{font-size:20px;}}
</style>

<div class="dp">

  <%-- 커버 이미지 --%>
  <div class="cover">
    <img src="<%= fThumb %>" alt="<%= fTitle %>">
    <div class="cover-gd"></div>
    <div class="cover-body">
      <div class="c-tags">
        <span class="c-tag">#부산</span><span class="c-tag">#해운대</span>
        <span class="c-tag">#핫플</span><span class="c-tag">2박3일</span>
      </div>
      <div class="c-title"><%= fTitle %></div>
    </div>
  </div>

  <%-- 메타 바 --%>
  <div class="meta-bar">
    <div class="meta-auth">
      <div class="m-av"></div>
      <div>
        <div class="m-un"><%= fUser %></div>
        <div class="m-dt"><%= fDate %> · 조회 <%= String.format("%,d",fViews) %></div>
      </div>
    </div>
    <div class="meta-stats">
      <span class="m-s"><span class="HT">&#9829;</span> <%= fLikes %></span>
      <span class="m-s">&#128278; <%= fScraps %></span>
      <span class="m-s">&#128172; 12</span>
    </div>
  </div>

  <%-- 본문 + 사이드바 --%>
  <div class="cols">
    <article class="art">
      <div class="sub"><p>부산 현지인도 인정한 <strong>뚜벅이 2박3일 코스</strong>예요. 해운대·광안리·서면을 효율적으로 돌면서도 줄 서지 않는 <strong>숨겨진 핫플</strong>을 집중 공략했어요. 총 예산 <strong>32만원</strong>으로 N빵 정산까지 완벽하게 해결했습니다 &#127754;</p></div>

      <div class="ah">여행 일정</div>
      <div class="td">
        <div class="tdh"><span class="tb">DAY 1</span><span class="tdt">3월 10일 (화) — 도착 &amp; 야경</span></div>
        <div class="tl">
          <div class="ti"><span class="ttp tts">&#127968; 숙소</span><div class="tpl">해운대 파크하얏트</div><div class="tad">부산 해운대구 해운대해변로 58</div><div class="tmo">체크인 15:00 / 오션뷰 룸 업그레이드 성공!</div></div>
          <div class="ti"><span class="ttp ttf">&#127860; 맛집</span><div class="tpl">해운대 원조 할매국밥</div><div class="tad">부산 해운대구 구남로 34</div><div class="tmo">오전 10시 이전에 가야 웨이팅 없어요.</div></div>
          <div class="ti"><span class="ttp ttt">&#127754; 야경</span><div class="tpl">달맞이길 카페 골목</div><div class="tad">부산 해운대구 달맞이길</div><div class="tmo">저녁 6시 이후 감성 최고.</div></div>
        </div>
      </div>
      <div class="td">
        <div class="tdh"><span class="tb" style="background:linear-gradient(135deg,#C2B8D9,#E0BBC2)">DAY 2</span><span class="tdt">3월 11일 (수) — 감천 &amp; 광안리</span></div>
        <div class="tl">
          <div class="ti"><span class="ttp ttt">&#127912; 관광</span><div class="tpl">감천문화마을</div><div class="tad">부산 사하구 감내2로</div><div class="tmo">오전 10시 전 가면 사람 없어요.</div></div>
          <div class="ti"><span class="ttp ttf">&#127860; 맛집</span><div class="tpl">서면 흑돼지거리</div><div class="tad">부산 부산진구 서면로 68</div><div class="tmo">대창집 → 뒷골목 포차 순서.</div></div>
          <div class="ti"><span class="ttp ttt">&#127751; 야경</span><div class="tpl">광안대교 야경 포인트</div><div class="tad">부산 수영구 광안해변로</div><div class="tmo">삼각대 펼치면 인생샷 보장!</div></div>
        </div>
      </div>
      <div class="td">
        <div class="tdh"><span class="tb" style="background:linear-gradient(135deg,#A8C8E1,#89CFF0)">DAY 3</span><span class="tdt">3월 12일 (목) — 남포동 &amp; 귀가</span></div>
        <div class="tl">
          <div class="ti"><span class="ttp ttf">&#127829; 맛집</span><div class="tpl">BIFF 광장 씨앗호떡 + 국제시장</div><div class="tad">부산 중구 BIFF광장로</div><div class="tmo">아침 일찍 씨앗호떡으로 간단히.</div></div>
        </div>
      </div>

      <div class="ah">여행 사진</div>
      <div class="gal">
        <div class="gi tall"><img src="https://picsum.photos/seed/bsn_g1/400/600" alt="" loading="lazy"></div>
        <div class="gi"><img src="https://picsum.photos/seed/bsn_g2/400/290" alt="" loading="lazy"></div>
        <div class="gi"><img src="https://picsum.photos/seed/bsn_g3/400/290" alt="" loading="lazy"></div>
        <div class="gi"><img src="https://picsum.photos/seed/bsn_g4/400/290" alt="" loading="lazy"></div>
        <div class="gi"><img src="https://picsum.photos/seed/bsn_g5/400/290" alt="" loading="lazy"></div>
      </div>

      <div class="ah">여행 가계부 (2인 기준)</div>
      <div class="btot"><div class="blbl">총 지출</div><div class="bamt">&#8361; <%= String.format("%,d",fBudget*2) %></div><div class="bper">1인당 <strong>&#8361; <%= String.format("%,d",fBudget) %></strong></div></div>
      <div class="bgr">
        <div class="bi"><div class="bct">&#127968; 숙소</div><div class="bvl">&#8361;240,000</div></div>
        <div class="bi"><div class="bct">&#127860; 식비</div><div class="bvl">&#8361;156,000</div></div>
        <div class="bi"><div class="bct">&#128652; 교통</div><div class="bvl">&#8361;86,000</div></div>
        <div class="bi"><div class="bct">&#127919; 관광/기타</div><div class="bvl">&#8361;158,000</div></div>
      </div>

      <div class="tags">
        <a href="#" class="tag">#부산여행</a><a href="#" class="tag">#해운대</a>
        <a href="#" class="tag">#감천문화마을</a><a href="#" class="tag">#광안리야경</a>
        <a href="#" class="tag">#서면맛집</a><a href="#" class="tag">#2박3일</a>
      </div>
    </article>

    <aside class="sb">
      <div class="ic">
        <h4>여행 정보</h4>
        <div class="ir"><span class="ik">여행지</span><span class="iv"><%= fCity %></span></div>
        <div class="ir"><span class="ik">일정</span><span class="iv"><%= fDays %></span></div>
        <div class="ir"><span class="ik">인원</span><span class="iv"><%= fPeople %>명</span></div>
        <div class="ir"><span class="ik">1인 예산</span><span class="iv">&#8361;<%= String.format("%,d",fBudget) %></span></div>
      </div>
      <div class="ac">
        <button class="ba" id="bL" onclick="tL()">&#9829; 좋아요 <%= fLikes %></button>
        <button class="bs" id="bS" onclick="tS()">&#128278; 담아오기 <%= fScraps %></button>
        <button class="bsh" onclick="cL()">&#128279; 링크 복사</button>
      </div>
    </aside>
  </div>
</div>

<%-- 연관 피드 --%>
<div class="rw">
  <div class="rh">비슷한 여행 피드</div>
  <div class="rg">
    <% for(int i=0;i<relT.length;i++){ %>
    <a href="<%= cp %>/community/feed_detail.jsp?feedId=<%= relId[i] %>" class="rc">
      <div class="ri"><img src="<%= relI[i] %>" alt="<%= relT[i] %>" loading="lazy"></div>
      <div class="rb"><div class="rt"><%= relT[i] %></div><div class="rf"><span><%= relU[i] %></span><span>&#9829; <%= relL[i] %></span></div></div>
    </a>
    <% } %>
  </div>
</div>

<%-- 댓글 --%>
<div class="cw">
  <div class="ch">댓글 <span style="color:var(--b)">12</span></div>
  <div class="ci">
    <div class="cav"></div>
    <textarea class="cta" placeholder="여행 후기나 질문을 남겨주세요!"></textarea>
    <button class="csb" onclick="sCmt()">등록</button>
  </div>
  <div class="cl">
    <div class="cm"><div class="cav" style="background:linear-gradient(135deg,#C2B8D9,#E0BBC2)"></div><div class="cbody"><div class="ctop"><span class="cnm">@busan_lover</span><span class="cdt">2026.02.21</span></div><div class="ctx">감천문화마을 오전 팁 정말 유용했어요! &#128522;</div><div class="cac"><button class="cab">&#9829; 3</button><button class="cab">답글</button></div></div></div>
    <div class="cm"><div class="cav" style="background:linear-gradient(135deg,#A8C8E1,#89CFF0)"></div><div class="cbody"><div class="ctop"><span class="cnm">@trip_planner99</span><span class="cdt">2026.02.22</span></div><div class="ctx">흑돼지거리 대창집 이름이 뭔가요?</div><div class="cac"><button class="cab">&#9829; 1</button><button class="cab">답글</button></div></div></div>
    <div class="cm"><div class="cav"></div><div class="cbody"><div class="ctop"><span class="cnm">@travel_holic</span><span class="cdt">2026.02.22</span></div><div class="ctx">@trip_planner99 '원조대창집'이에요! &#128522;</div><div class="cac"><button class="cab">&#9829; 5</button><button class="cab">답글</button></div></div></div>
  </div>
</div>

<div id="TB"></div>
<jsp:include page="../layout/footer.jsp" />
<script>
var lk=false,sc=false;
function tL(){lk=!lk;var b=document.getElementById('bL');b.innerHTML='&#9829; 좋아요 '+(lk?891:890);b.classList.toggle('on',lk);sT(lk?'&#9829; 좋아요!':'좋아요 취소');}
function tS(){sc=!sc;var b=document.getElementById('bS');b.innerHTML='&#128278; 담아오기 '+(sc?313:312);b.classList.toggle('on',sc);sT(sc?'&#128278; 담아왔어요!':'담아오기 취소');}
function cL(){if(navigator.clipboard){navigator.clipboard.writeText(location.href).then(function(){sT('&#128279; 링크 복사됨!');});}else sT('링크: '+location.href);}
function sCmt(){var ta=document.querySelector('.cta');if(!ta.value.trim()){sT('댓글을 입력해주세요');return;}sT('&#128172; 댓글 등록됨!');ta.value='';}
function sT(m){var t=document.getElementById('TB');t.innerHTML=m;t.style.cssText='display:block;position:fixed;bottom:22px;left:50%;transform:translateX(-50%);background:#1A202C;color:#fff;padding:10px 20px;border-radius:50px;font-size:12px;font-weight:700;z-index:9999;box-shadow:0 8px 24px rgba(0,0,0,.18);animation:ti .3s ease;white-space:nowrap;font-family:Pretendard,sans-serif;';clearTimeout(window._tt);window._tt=setTimeout(function(){t.style.display='none';},2300);}
var _s=document.createElement('style');_s.textContent='@keyframes ti{from{opacity:0;transform:translateX(-50%) translateY(8px)}to{opacity:1;transform:translateX(-50%) translateY(0)}}';document.head.appendChild(_s);
var ob=new IntersectionObserver(function(en){en.forEach(function(e){if(e.isIntersecting){e.target.classList.add('in');ob.unobserve(e.target);}});},{threshold:.1});
document.querySelectorAll('.rc').forEach(function(el,i){el.style.transition='opacity .32s '+(i*.09)+'s,transform .32s '+(i*.09)+'s cubic-bezier(.19,1,.22,1)';ob.observe(el);});
</script>
