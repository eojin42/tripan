<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<title>TripanSuper — 콘텐츠 관리</title>
<link rel="stylesheet" href="${pageContext.request.contextPath}/dist/css/admin.css">
<link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@700;900&display=swap" rel="stylesheet">
<style>
/* ── 이 파일에서만 쓰는 추가 스타일 (admin.css 토큰 그대로 사용) ── */

/* 탭 */
.tab-bar{display:flex;gap:4px;background:var(--surface);border:1px solid var(--border);border-radius:var(--radius-lg);padding:5px;width:fit-content;margin-bottom:28px}
.tab-btn{padding:9px 28px;font-size:13px;font-weight:800;border:none;background:transparent;border-radius:var(--radius-md);cursor:pointer;color:var(--muted);transition:all .2s;font-family:inherit}
.tab-btn.on{background:var(--text);color:#fff}
.panel{display:none}.panel.on{display:block}

/* 배너 카드 리스트 */
.bn-list{display:flex;flex-direction:column;gap:12px}
.bn-row{display:flex;align-items:center;gap:16px;padding:16px 20px;background:var(--surface);border:1px solid var(--border);border-radius:var(--radius-lg);transition:box-shadow .2s;cursor:default}
.bn-row:hover{box-shadow:var(--shadow-sm)}
.bn-thumb{width:108px;height:66px;border-radius:var(--radius-md);object-fit:cover;background:var(--bg);flex-shrink:0}
.bn-thumb-ph{width:108px;height:66px;border-radius:var(--radius-md);background:var(--bg);display:flex;align-items:center;justify-content:center;font-size:22px;flex-shrink:0}
.bn-info{flex:1;min-width:0}
.bn-info h4{font-size:14px;font-weight:800;margin-bottom:3px;white-space:nowrap;overflow:hidden;text-overflow:ellipsis}
.bn-info p{font-size:12px;color:var(--muted)}
.drag-h{font-size:17px;color:#CBD5E0;cursor:grab;padding:0 4px;user-select:none}

/* 모달 */
.mo-overlay{position:fixed;inset:0;background:rgba(15,23,42,.52);backdrop-filter:blur(6px);display:none;justify-content:center;align-items:flex-start;z-index:3000;padding:32px 20px;overflow-y:auto}
.mo-overlay.open{display:flex}
.mo-box{background:var(--surface);border-radius:var(--radius-xl);width:90%;max-width:780px;padding:36px;position:relative;animation:moUp .3s cubic-bezier(.16,1,.3,1);margin:auto;box-shadow:var(--shadow-lg)}
@keyframes moUp{from{opacity:0;transform:translateY(20px)}to{opacity:1;transform:translateY(0)}}
.mo-x{position:absolute;top:16px;right:18px;font-size:20px;cursor:pointer;color:var(--muted);background:none;border:none;line-height:1;transition:color .2s}
.mo-x:hover{color:var(--text)}
.mo-title{font-size:20px;font-weight:900;margin-bottom:26px;letter-spacing:-.3px}

/* 폼 그룹 */
.fg{display:flex;flex-direction:column;gap:7px;margin-bottom:14px}
.fg-2{display:grid;grid-template-columns:1fr 1fr;gap:16px}
.fg label{font-size:11px;font-weight:800;color:var(--muted);text-transform:uppercase;letter-spacing:.6px}
.fg input,.fg select,.fg textarea{width:100%;border:1.5px solid var(--border);border-radius:var(--radius-md);padding:10px 14px;font-size:13px;font-weight:600;background:var(--bg);outline:none;transition:border-color .2s;font-family:inherit;color:var(--text)}
.fg input:focus,.fg select:focus,.fg textarea:focus{border-color:var(--primary);box-shadow:0 0 0 3px var(--primary-10)}
.fg textarea{resize:vertical;min-height:80px;line-height:1.6}

/* 이미지 업로더 */
.iu{border:2px dashed var(--border);border-radius:var(--radius-lg);background:var(--bg);padding:28px 20px;text-align:center;cursor:pointer;position:relative;overflow:hidden;transition:all .2s}
.iu:hover{border-color:var(--primary);background:rgba(59,110,248,.03)}
.iu.has{padding:0;border-style:solid;border-color:var(--border)}
.iu input{position:absolute;inset:0;opacity:0;cursor:pointer;width:100%;height:100%;padding:0;border:none;background:none}
.iu-ph .iu-icon{font-size:28px;margin-bottom:8px}
.iu-ph .iu-t{font-size:13px;font-weight:700;color:var(--text)}
.iu-ph .iu-s{font-size:12px;color:var(--muted);margin-top:4px}
.iu-prev{width:100%;height:190px;object-fit:cover;border-radius:var(--radius-md);display:none}
.iu.has .iu-prev{display:block}.iu.has .iu-ph{display:none}

/* 배너 미리보기 */
.bn-pv{position:relative;border-radius:var(--radius-lg);overflow:hidden;height:170px;background:#0D1117;display:flex;align-items:center;justify-content:center;margin-bottom:16px}
.bn-pv img{position:absolute;inset:0;width:100%;height:100%;object-fit:cover;opacity:.5}
.bn-pv-inner{position:relative;text-align:center;color:#fff;padding:20px}
.bn-pv-inner .ey{font-size:10px;letter-spacing:3px;opacity:.8;margin-bottom:7px}
.bn-pv-inner .ti{font-size:22px;font-weight:900;line-height:1.2;text-shadow:0 2px 12px rgba(0,0,0,.4)}
.bn-pv-inner .sb{font-size:11px;margin-top:9px;opacity:.8}

/* 블록 에디터 */
.be-wrap{display:flex;gap:20px;align-items:flex-start}
.be-palette{width:172px;flex-shrink:0;background:var(--surface);border:1px solid var(--border);border-radius:var(--radius-lg);padding:16px;position:sticky;top:80px}
.be-palette h5{font-size:10px;font-weight:800;letter-spacing:1.5px;text-transform:uppercase;color:var(--muted);margin-bottom:12px}
.bk-btn{display:flex;align-items:center;gap:8px;width:100%;padding:9px 12px;background:var(--bg);border:1.5px solid var(--border);border-radius:var(--radius-md);font-size:12px;font-weight:800;cursor:pointer;margin-bottom:7px;color:var(--text);font-family:inherit;transition:all .2s;text-align:left}
.bk-btn:hover{border-color:var(--primary);background:rgba(59,110,248,.04);color:var(--primary)}
.bk-btn .ico{width:18px;text-align:center;font-size:14px}
.be-canvas{flex:1;min-width:0}
.canvas-empty{border:2px dashed var(--border);border-radius:var(--radius-lg);padding:52px 20px;text-align:center;color:var(--muted)}
.canvas-empty .ce-ico{font-size:32px;margin-bottom:10px}
.canvas-empty p{font-size:14px;font-weight:700}
.canvas-empty span{font-size:12px;color:#A0AEC0}

/* 개별 블록 */
.block{background:var(--surface);border:1.5px solid var(--border);border-radius:var(--radius-lg);margin-bottom:10px;overflow:hidden;transition:box-shadow .2s,border-color .2s}
.block:hover{border-color:rgba(59,110,248,.4);box-shadow:var(--shadow-xs)}
.block.drag-over{border-color:var(--primary);box-shadow:0 0 0 3px var(--primary-10)}
.blk-head{display:flex;align-items:center;gap:9px;padding:10px 14px;background:var(--bg);border-bottom:1px solid var(--border);cursor:grab}
.blk-head:active{cursor:grabbing}
.blk-drag{font-size:16px;color:#CBD5E0;user-select:none}
.blk-lbl{font-size:10px;font-weight:900;letter-spacing:1.5px;text-transform:uppercase;flex:1}
.blk-lbl-text{color:var(--secondary)}.blk-lbl-h3{color:var(--warning)}.blk-lbl-img{color:var(--primary)}.blk-lbl-pair{color:var(--success)}.blk-lbl-quote{color:#DB2777}.blk-lbl-caption{color:var(--muted)}
.blk-toggle{border:none;background:none;cursor:pointer;color:#CBD5E0;font-size:13px;padding:0 2px;line-height:1;transition:transform .2s}
.blk-toggle.closed{transform:rotate(-90deg)}
.blk-del{border:none;background:none;cursor:pointer;color:#CBD5E0;font-size:16px;padding:0;line-height:1;transition:color .2s}
.blk-del:hover{color:var(--danger)}
.blk-body{padding:14px}
.blk-body.hidden{display:none}

/* 블록 내 이미지 업로더 */
.biu{border:2px dashed var(--border);border-radius:var(--radius-md);background:var(--bg);padding:16px;text-align:center;cursor:pointer;position:relative;overflow:hidden;transition:all .2s}
.biu:hover{border-color:var(--primary);background:rgba(59,110,248,.03)}
.biu.has{padding:0;border-style:solid}
.biu input{position:absolute;inset:0;opacity:0;cursor:pointer;width:100%;height:100%;padding:0;border:none;background:none}
.biu-ph{font-size:12px;font-weight:700;color:var(--muted)}
.biu-ph span{font-size:20px;display:block;margin-bottom:5px}
.biu-prev{width:100%;height:140px;object-fit:cover;border-radius:8px;display:none}
.biu.has .biu-prev{display:block}.biu.has .biu-ph{display:none}
.img-pair-up{display:grid;grid-template-columns:1fr 1fr;gap:10px}

/* 리치 에디터 */
.rt{display:flex;gap:3px;padding:7px 9px;background:var(--bg);border:1.5px solid var(--border);border-bottom:none;border-radius:var(--radius-md) var(--radius-md) 0 0}
.rt button{width:28px;height:28px;border:none;background:transparent;border-radius:6px;font-size:12px;font-weight:800;cursor:pointer;color:var(--text);display:flex;align-items:center;justify-content:center;transition:background .15s;font-family:inherit}
.rt button:hover{background:var(--border)}
.rt-div{width:1px;background:var(--border);margin:3px 2px}
.rc{min-height:120px;padding:12px;border:1.5px solid var(--border);border-radius:0 0 var(--radius-md) var(--radius-md);outline:none;font-size:14px;line-height:1.8;background:var(--bg);font-family:inherit}
.rc:focus{border-color:var(--primary);background:var(--surface);box-shadow:0 0 0 3px var(--primary-10)}

/* 태그 인풋 */
.ti-wrap{display:flex;flex-wrap:wrap;gap:7px;padding:8px 12px;border:1.5px solid var(--border);border-radius:var(--radius-md);background:var(--bg);cursor:text;transition:border .2s}
.ti-wrap:focus-within{border-color:var(--primary);background:var(--surface);box-shadow:0 0 0 3px var(--primary-10)}
.tag-chip{display:inline-flex;align-items:center;gap:4px;padding:3px 10px;background:rgba(59,110,248,.1);border-radius:var(--radius-full);font-size:12px;font-weight:800;color:var(--primary)}
.tag-chip button{border:none;background:none;cursor:pointer;font-size:13px;color:var(--primary);line-height:1;padding:0}
.ti-wrap input{border:none;background:transparent;outline:none;font-size:13px;padding:3px 4px;min-width:70px;flex:1;font-family:inherit;box-shadow:none}

.hr{border:none;border-top:1px solid var(--border);margin:20px 0}
.mo-foot{display:flex;justify-content:flex-end;gap:10px}
</style>
</head>
<body>
<div class="admin-layout" id="adminLayout">

  <jsp:include page="../layout/sidebar.jsp">
    <jsp:param name="activePage" value="curation"/>
  </jsp:include>

  <div class="main-wrapper">
    <jsp:include page="../layout/header.jsp"/>

    <main class="main-content">

      <div class="page-header fade-up">
        <div>
          <h1>콘텐츠 관리</h1>
          <p>메인 배너와 매거진 아티클을 등록·수정·삭제합니다.</p>
        </div>
      </div>

      <!-- ── KPI ── -->
      <div class="kpi-grid">
        <div class="card kpi-card fade-up fade-up-1">
          <div class="kpi-label">등록된 배너</div>
          <div class="kpi-value">${banners.size()}</div>
          <div class="kpi-sub">노출 중 <c:forEach var="b" items="${banners}"><c:if test="${b.isVisible eq 'Y'}">✓</c:if></c:forEach></div>
        </div>
        <div class="card kpi-card fade-up fade-up-2">
          <div class="kpi-label">전체 아티클</div>
          <div class="kpi-value">${articles.size()}</div>
          <div class="kpi-sub">게시 중 / 임시저장 포함</div>
        </div>
        <div class="card kpi-card fade-up fade-up-3">
          <div class="kpi-label">게시 중 아티클</div>
          <div class="kpi-value" style="color:var(--success)">
            <c:set var="pubCnt" value="0"/>
            <c:forEach var="a" items="${articles}"><c:if test="${a.status eq 1}"><c:set var="pubCnt" value="${pubCnt+1}"/></c:if></c:forEach>
            ${pubCnt}
          </div>
          <div class="kpi-sub">프론트 노출 중</div>
        </div>
        <div class="card kpi-card fade-up fade-up-4">
          <div class="kpi-label">임시저장</div>
          <div class="kpi-value" style="color:var(--warning)">
            <c:set var="draftCnt" value="0"/>
            <c:forEach var="a" items="${articles}"><c:if test="${a.status eq 2}"><c:set var="draftCnt" value="${draftCnt+1}"/></c:if></c:forEach>
            ${draftCnt}
          </div>
          <div class="badge badge-wait">검토 필요</div>
        </div>
      </div>

      <!-- ── TABS ── -->
      <div class="tab-bar fade-up">
        <button class="tab-btn on" id="tb-banner"   onclick="sw('banner')">🖼️ 메인 배너</button>
        <button class="tab-btn"    id="tb-magazine" onclick="sw('magazine')">📰 매거진</button>
      </div>

      <!-- ════ PANEL: BANNER ════ -->
      <div class="panel on fade-up" id="panel-banner">
        <div class="w-header" style="margin-bottom:18px">
          <div>
            <h2>메인 배너 목록</h2>
            <p style="font-size:12px;color:var(--muted);margin-top:3px">홈 히어로 섹션 배너 · 최대 5개 · 드래그로 순서 변경</p>
          </div>
          <button class="btn btn-primary btn-sm" onclick="openBanner()">+ 새 배너 추가</button>
        </div>

        <div class="card" style="padding:20px">
          <div class="bn-list" id="bnList">
            <c:forEach var="b" items="${banners}" varStatus="vs">
              <div class="bn-row fade-up" style="animation-delay:${vs.index * 0.05}s">
                <span class="drag-h">⠿</span>
                <c:choose>
                  <c:when test="${not empty b.imageUrl}">
                    <img class="bn-thumb" src="${b.imageUrl}" alt="${b.bannerName}">
                  </c:when>
                  <c:otherwise>
                    <div class="bn-thumb-ph">🏞️</div>
                  </c:otherwise>
                </c:choose>
                <div class="bn-info">
                  <h4>${b.bannerName}</h4>
                  <p>${b.mainTitle}</p>
                </div>
                <c:choose>
                  <c:when test="${b.isVisible eq 'Y'}"><span class="badge badge-done">노출중</span></c:when>
                  <c:otherwise><span class="badge">숨김</span></c:otherwise>
                </c:choose>
                <div style="display:flex;gap:8px">
                  <button class="btn btn-ghost btn-sm"
                          onclick="openBanner('edit', ${b.bannerId})">수정</button>
                  <button class="btn btn-sm"
                          style="background:#FEF2F2;color:var(--danger);border:1px solid #FECACA"
                          onclick="deleteBanner(${b.bannerId}, this)">삭제</button>
                </div>
              </div>
            </c:forEach>
            <c:if test="${empty banners}">
              <div style="text-align:center;padding:48px 0;color:var(--muted)">
                <div style="font-size:32px;margin-bottom:12px">🏞️</div>
                <p style="font-weight:700">등록된 배너가 없습니다</p>
              </div>
            </c:if>
          </div>
        </div>
      </div>

      <!-- ════ PANEL: MAGAZINE ════ -->
      <div class="panel fade-up" id="panel-magazine">
        <div class="w-header" style="margin-bottom:18px">
          <div>
            <h2>매거진 아티클</h2>
            <p style="font-size:12px;color:var(--muted);margin-top:3px">큐레이션 목록·상세 페이지에 표시됩니다</p>
          </div>
          <button class="btn btn-primary btn-sm" onclick="openMag()">+ 새 아티클 작성</button>
        </div>

        <div class="card" style="padding:0;overflow:hidden">
          <div class="table-responsive">
            <table>
              <thead>
                <tr>
                  <th>썸네일</th>
                  <th>제목 / 카테고리</th>
                  <th>레이아웃</th>
                  <th>상태</th>
                  <th>발행일</th>
                  <th class="right">관리</th>
                </tr>
              </thead>
              <tbody>
                <c:forEach var="a" items="${articles}" varStatus="vs">
                  <tr class="fade-up" style="animation-delay:${vs.index * 0.04}s">
                    <td>
                      <c:choose>
                        <c:when test="${not empty a.thumbnailUrl}">
                          <img src="${a.thumbnailUrl}" alt="${a.title}"
                               style="width:68px;height:46px;border-radius:var(--radius-md);object-fit:cover">
                        </c:when>
                        <c:otherwise>
                          <div style="width:68px;height:46px;border-radius:var(--radius-md);background:var(--bg);display:flex;align-items:center;justify-content:center;font-size:18px">📰</div>
                        </c:otherwise>
                      </c:choose>
                    </td>
                    <td>
                      <div style="font-size:14px;font-weight:800;margin-bottom:3px">${a.title}</div>
                      <div style="font-size:11px;color:var(--muted)">${a.categoryLabel}</div>
                    </td>
                    <td><span class="badge">${a.layoutLabel}</span></td>
                    <td>
                      <c:choose>
                        <c:when test="${a.status eq 1}"><span class="badge badge-done">게시중</span></c:when>
                        <c:when test="${a.status eq 2}"><span class="badge badge-wait">임시저장</span></c:when>
                        <c:otherwise><span class="badge">숨김</span></c:otherwise>
                      </c:choose>
                    </td>
                    <td class="num">
                      <fmt:formatDate value="${a.pubDate}" pattern="yyyy.MM.dd"/>
                    </td>
                    <td class="right">
                      <div style="display:flex;gap:6px;justify-content:flex-end">
                        <button class="btn btn-ghost btn-sm" onclick="openMag('edit', ${a.articleId})">수정</button>
                        <button class="btn btn-sm"
                                style="background:#FEF2F2;color:var(--danger);border:1px solid #FECACA"
                                onclick="deleteMag(${a.articleId}, this)">삭제</button>
                      </div>
                    </td>
                  </tr>
                </c:forEach>
                <c:if test="${empty articles}">
                  <tr>
                    <td colspan="6" style="text-align:center;padding:48px 0;color:var(--muted)">
                      작성된 아티클이 없습니다. <strong>새 아티클 작성</strong>을 눌러 시작하세요.
                    </td>
                  </tr>
                </c:if>
              </tbody>
            </table>
          </div>
        </div>
      </div>

    </main>
  </div>
</div>

<!-- ════════════════════════════════════════
     MODAL: 배너 등록/수정
════════════════════════════════════════ -->
<div class="mo-overlay" id="moBanner">
  <div class="mo-box">
    <button class="mo-x" onclick="closeMo('moBanner')">✕</button>
    <div class="mo-title" id="bnTitle">새 배너 추가</div>

    <form id="bnForm">
      <input type="hidden" id="bnId" name="bannerId" value="0">

      <div class="fg">
        <label>배너 이미지 *</label>
        <div class="iu" id="bnIU">
          <input type="file" name="imageFile" accept="image/*" onchange="prevIU(this,'bnIU','bnPrev')">
          <div class="iu-ph">
            <div class="iu-icon">🏞️</div>
            <div class="iu-t">클릭하여 이미지 업로드</div>
            <div class="iu-s">권장: 1920×900px · JPG, PNG, WebP · 최대 5MB</div>
          </div>
          <img class="iu-prev" id="bnPrev" alt="">
        </div>
      </div>

      <div class="fg-2">
        <div class="fg">
          <label>배너 제목 (내부용) *</label>
          <input type="text" id="bnName" name="bannerName" placeholder="ex) 여름 해변 메인 배너" required>
        </div>
        <div class="fg">
          <label>링크 URL</label>
          <input type="url" id="bnLink" name="linkUrl" placeholder="ex) /trip/create">
        </div>
      </div>

      <div class="fg">
        <label>Eyebrow 텍스트</label>
        <input type="text" id="bnEyebrow" name="eyebrowText" value="여행 플래너 Tripan"
               oninput="updatePv()">
      </div>
      <div class="fg">
        <label>메인 타이틀 * <span style="font-weight:400;text-transform:none;font-size:11px">줄바꿈 가능</span></label>
        <textarea id="bnMainTitle" name="mainTitle" rows="2"
                  oninput="updatePv()">다음 여행을,
더 가볍고 선명하게</textarea>
      </div>
      <div class="fg">
        <label>서브타이틀</label>
        <input type="text" id="bnSub" name="subTitle"
               value="일정은 같이, 정산은 쉽게 — 여행의 처음부터 끝까지 한 곳에서"
               oninput="updatePv()">
      </div>

      <div class="fg-2">
        <div class="fg">
          <label>표시 순서</label>
          <input type="number" id="bnOrder" name="sortOrder" value="1" min="1" max="5">
        </div>
        <div class="fg">
          <label>노출 여부</label>
          <select id="bnVisible" name="isVisible">
            <option value="Y">노출</option>
            <option value="N">숨김</option>
          </select>
        </div>
      </div>

      <div class="hr"></div>

      <!-- 실시간 미리보기 -->
      <div class="fg" style="margin-bottom:20px">
        <label>📐 배너 미리보기</label>
        <div class="bn-pv">
          <img id="pvImg" src="https://images.unsplash.com/photo-1507525428034-b723cf961d3e?q=80&w=800" alt="">
          <div class="bn-pv-inner">
            <p class="ey" id="pvEy">여행 플래너 Tripan</p>
            <h2 class="ti" id="pvTi">다음 여행을,<br>더 가볍고 선명하게</h2>
            <p class="sb" id="pvSb">일정은 같이, 정산은 쉽게 — 여행의 처음부터 끝까지 한 곳에서</p>
          </div>
        </div>
      </div>

      <div class="hr"></div>
      <div class="mo-foot">
        <button type="button" class="btn btn-ghost" onclick="closeMo('moBanner')">취소</button>
        <button type="button" class="btn btn-primary" onclick="submitBanner()">💾 저장하기</button>
      </div>
    </form>
  </div>
</div>

<!-- ════════════════════════════════════════
     MODAL: 매거진 아티클 작성/수정
════════════════════════════════════════ -->
<div class="mo-overlay" id="moMag">
  <div class="mo-box" style="max-width:900px">
    <button class="mo-x" onclick="closeMo('moMag')">✕</button>
    <div class="mo-title" id="magMoTitle">새 아티클 작성</div>

    <form id="magForm">
      <input type="hidden" id="magId" name="articleId" value="0">

      <div class="fg">
        <label>히어로 이미지 <span style="font-weight:400;text-transform:none">(상세 페이지 풀스크린)</span></label>
        <div class="iu" id="magHeroIU">
          <input type="file" name="heroFile" accept="image/*" onchange="prevIU(this,'magHeroIU','magHeroPrev')">
          <div class="iu-ph">
            <div class="iu-icon">📷</div>
            <div class="iu-t">클릭하여 히어로 이미지 업로드</div>
            <div class="iu-s">권장: 1800×1200px · 최대 10MB</div>
          </div>
          <img class="iu-prev" id="magHeroPrev" alt="">
        </div>
      </div>

      <div class="fg">
        <label>목록 썸네일 *</label>
        <div class="iu" id="magThumbIU">
          <input type="file" name="thumbFile" accept="image/*" onchange="prevIU(this,'magThumbIU','magThumbPrev')">
          <div class="iu-ph">
            <div class="iu-icon">🖼️</div>
            <div class="iu-t">클릭하여 썸네일 업로드</div>
            <div class="iu-s">권장: 800×600px</div>
          </div>
          <img class="iu-prev" id="magThumbPrev" alt="">
        </div>
      </div>

      <div class="fg-2">
        <div class="fg">
          <label>카테고리 *</label>
          <select id="magCat" name="category">
            <option value="EDITOR_CHOICE">EDITOR'S CHOICE</option>
            <option value="TASTE">TASTE</option>
            <option value="JOURNEY">JOURNEY</option>
            <option value="LIFESTYLE">LIFESTYLE</option>
            <option value="SPECIAL_REPORT">SPECIAL REPORT</option>
          </select>
        </div>
        <div class="fg">
          <label>목록 레이아웃 *</label>
          <select id="magLayout" name="layoutType">
            <option value="hero">히어로 (최상단 대형)</option>
            <option value="item-v">세로형 (3/4 비율)</option>
            <option value="item-h">가로형 (16/10)</option>
            <option value="item-full">전체 너비</option>
          </select>
        </div>
      </div>

      <div class="fg">
        <label>아티클 제목 *</label>
        <input type="text" id="magTitle" name="title" placeholder="ex) 제주, 온전한 쉼을 위한 비밀스러운 공간들">
      </div>
      <div class="fg">
        <label>리드(Lead) 문구 <span style="font-weight:400;text-transform:none">(상세 페이지 흰 카드 안에 표시)</span></label>
        <textarea id="magLead" name="leadText" placeholder="파도 소리만 들리는 프라이빗한 숙소부터..."></textarea>
      </div>

      <div class="hr"></div>

      <!-- 블록 에디터 -->
      <div style="margin-bottom:12px">
        <label style="font-size:11px;font-weight:800;color:var(--muted);text-transform:uppercase;letter-spacing:.6px;display:block;margin-bottom:4px">📝 본문 블록 편집</label>
        <span style="font-size:12px;color:var(--muted)">블록 추가 → 드래그로 순서 변경 → ▾ 접기/펼치기</span>
      </div>
      <div class="be-wrap">
        <div class="be-palette">
          <h5>블록 추가</h5>
          <button type="button" class="bk-btn" onclick="addBlock('text')"><span class="ico">¶</span>본문 텍스트</button>
          <button type="button" class="bk-btn" onclick="addBlock('h3')"><span class="ico">H</span>섹션 제목</button>
          <button type="button" class="bk-btn" onclick="addBlock('img')"><span class="ico">🖼</span>이미지 단독</button>
          <button type="button" class="bk-btn" onclick="addBlock('pair')"><span class="ico">⊞</span>이미지 2컬럼</button>
          <button type="button" class="bk-btn" onclick="addBlock('quote')"><span class="ico">"</span>인용구</button>
          <button type="button" class="bk-btn" onclick="addBlock('caption')"><span class="ico">✏</span>캡션</button>
        </div>
        <div class="be-canvas" id="beCanvas">
          <div class="canvas-empty" id="emptyHint">
            <div class="ce-ico">✦</div>
            <p>왼쪽에서 블록을 추가해보세요</p>
            <span>텍스트, 이미지, 인용구 등을 자유롭게 배치</span>
          </div>
        </div>
      </div>

      <div class="hr"></div>

      <div class="fg-2">
        <div class="fg">
          <label>해시태그</label>
          <div class="ti-wrap" id="tagWrap">
            <input type="text" id="tagIn" placeholder="태그 입력 후 Enter" onkeydown="addTag(event)">
          </div>
        </div>
        <div class="fg">
          <label>게시 상태</label>
          <select id="magStatus" name="status">
            <option value="1">게시</option>
            <option value="2">임시저장</option>
            <option value="3">숨김</option>
          </select>
        </div>
      </div>

      <div class="hr"></div>
      <div class="mo-foot">
        <button type="button" class="btn btn-ghost" onclick="closeMo('moMag')">취소</button>
        <button type="button" class="btn btn-ghost" onclick="submitMag(2)">임시저장</button>
        <button type="button" class="btn btn-primary" onclick="submitMag(1)">📰 게시하기</button>
      </div>
    </form>
  </div>
</div>

<script>
const CP = '${pageContext.request.contextPath}';

/* ── TAB ── */
function sw(t){
  document.querySelectorAll('.panel').forEach(p=>p.classList.remove('on'));
  document.querySelectorAll('.tab-btn').forEach(b=>b.classList.remove('on'));
  document.getElementById('panel-'+t).classList.add('on');
  document.getElementById('tb-'+t).classList.add('on');
}

/* ── MODAL ── */
function openBanner(mode, bannerId){
  document.getElementById('bnTitle').textContent = mode==='edit' ? '배너 수정' : '새 배너 추가';
  if(mode==='edit' && bannerId){
    fetch(CP+'/admin/curation/banner/'+bannerId)
      .then(r=>r.json()).then(d=>{
        document.getElementById('bnId').value        = d.bannerId;
        document.getElementById('bnName').value      = d.bannerName || '';
        document.getElementById('bnLink').value      = d.linkUrl || '';
        document.getElementById('bnEyebrow').value   = d.eyebrowText || '';
        document.getElementById('bnMainTitle').value = d.mainTitle || '';
        document.getElementById('bnSub').value       = d.subTitle || '';
        document.getElementById('bnOrder').value     = d.sortOrder || 1;
        document.getElementById('bnVisible').value   = d.isVisible || 'Y';
        if(d.imageUrl){ document.getElementById('pvImg').src = d.imageUrl; }
        updatePv();
      });
  } else {
    document.getElementById('bnForm').reset();
    document.getElementById('bnId').value = '0';
  }
  document.getElementById('moBanner').classList.add('open');
}

function openMag(mode, articleId){
  document.getElementById('magMoTitle').textContent = mode==='edit' ? '아티클 수정' : '새 아티클 작성';
  resetCanvas();
  if(mode==='edit' && articleId){
    fetch(CP+'/admin/curation/magazine/'+articleId)
      .then(r=>r.json()).then(d=>{
        document.getElementById('magId').value      = d.articleId;
        document.getElementById('magCat').value     = d.category || 'EDITOR_CHOICE';
        document.getElementById('magLayout').value  = d.layoutType || 'hero';
        document.getElementById('magTitle').value   = d.title || '';
        document.getElementById('magLead').value    = d.leadText || '';
        document.getElementById('magStatus').value  = d.status || 1;
        // 블록 복원
        if(d.blocks) d.blocks.forEach(b=>addBlockFromData(b));
        // 태그 복원
        if(d.tags) d.tags.forEach(t=>appendTagChip(t));
        // 썸네일 미리보기
        if(d.thumbnailUrl){
          const iu = document.getElementById('magThumbIU');
          iu.classList.add('has');
          document.getElementById('magThumbPrev').src = d.thumbnailUrl;
        }
        if(d.heroImgUrl){
          const iu = document.getElementById('magHeroIU');
          iu.classList.add('has');
          document.getElementById('magHeroPrev').src = d.heroImgUrl;
        }
      });
  } else {
    document.getElementById('magForm').reset();
    document.getElementById('magId').value = '0';
  }
  document.getElementById('moMag').classList.add('open');
}

function closeMo(id){
  document.getElementById(id).classList.remove('open');
}
document.querySelectorAll('.mo-overlay').forEach(o=>{
  o.addEventListener('click', e=>{ if(e.target===o) o.classList.remove('open'); });
});

/* ── IMAGE PREVIEW ── */
function prevIU(input, wrId, prevId){
  const f = input.files[0]; if(!f) return;
  const r = new FileReader();
  r.onload = e=>{
    const wr = document.getElementById(wrId);
    wr.classList.add('has');
    document.getElementById(prevId).src = e.target.result;
    if(wrId==='bnIU') document.getElementById('pvImg').src = e.target.result;
  };
  r.readAsDataURL(f);
}

/* ── BANNER LIVE PREVIEW ── */
function updatePv(){
  document.getElementById('pvEy').textContent = document.getElementById('bnEyebrow').value;
  document.getElementById('pvTi').innerHTML   = document.getElementById('bnMainTitle').value.replace(/\n/g,'<br>');
  document.getElementById('pvSb').textContent = document.getElementById('bnSub').value;
}

/* ── BANNER SUBMIT ── */
function submitBanner(){
  const id    = document.getElementById('bnId').value;
  const url   = id && id !== '0'
      ? CP+'/admin/curation/banner/update'
      : CP+'/admin/curation/banner/save';
  const fd = new FormData(document.getElementById('bnForm'));
  fetch(url,{method:'POST',body:fd})
    .then(r=>r.json()).then(d=>{
      if(d.success){ closeMo('moBanner'); showToast('배너가 저장되었습니다 🎉'); location.reload(); }
      else alert(d.message || '저장 실패');
    });
}

/* ── DELETE BANNER ── */
function deleteBanner(bannerId, btn){
  if(!confirm('배너를 삭제하시겠습니까?')) return;
  fetch(CP+'/admin/curation/banner/delete',{
    method:'POST',
    headers:{'Content-Type':'application/x-www-form-urlencoded'},
    body:'bannerId='+bannerId
  }).then(r=>r.json()).then(d=>{
    if(d.success){ btn.closest('.bn-row').remove(); showToast('배너가 삭제되었습니다'); }
    else alert('삭제 실패');
  });
}

/* ── BLOCK EDITOR ── */
let blkId = 0, dragSrc = null;

function resetCanvas(){
  const c = document.getElementById('beCanvas');
  c.innerHTML = '<div class="canvas-empty" id="emptyHint"><div class="ce-ico">✦</div><p>왼쪽에서 블록을 추가해보세요</p><span>텍스트, 이미지, 인용구 등을 자유롭게 배치</span></div>';
  document.getElementById('tagWrap').querySelectorAll('.tag-chip').forEach(t=>t.remove());
}

function addBlock(type, data){
  document.getElementById('emptyHint')?.remove();
  const id  = 'blk-'+(blkId++);
  const blk = document.createElement('div');
  blk.className='block'; blk.id=id; blk.draggable=true;
  blk.innerHTML = blkHTML(type, id, data);
  document.getElementById('beCanvas').appendChild(blk);
  // drag
  blk.addEventListener('dragstart', e=>{ dragSrc=blk; e.dataTransfer.effectAllowed='move'; blk.style.opacity='.4'; });
  blk.addEventListener('dragend',   ()=>{ blk.style.opacity='1'; document.querySelectorAll('.block').forEach(b=>b.classList.remove('drag-over')); });
  blk.addEventListener('dragover',  e=>{ e.preventDefault(); blk.classList.add('drag-over'); });
  blk.addEventListener('dragleave', ()=>blk.classList.remove('drag-over'));
  blk.addEventListener('drop', e=>{
    e.preventDefault(); blk.classList.remove('drag-over');
    if(dragSrc && dragSrc!==blk){
      const all=[...document.getElementById('beCanvas').querySelectorAll('.block')];
      all.indexOf(dragSrc)<all.indexOf(blk) ? blk.after(dragSrc) : blk.before(dragSrc);
    }
  });
  // inner image upload
  blk.querySelectorAll('.biu input').forEach(inp=>{
    inp.addEventListener('change', function(){
      const f=this.files[0]; if(!f) return;
      const wr=this.parentElement, prev=wr.querySelector('.biu-prev');
      const reader=new FileReader();
      reader.onload=e=>{ wr.classList.add('has'); prev.src=e.target.result; };
      reader.readAsDataURL(f);
    });
  });
}

function addBlockFromData(d){ addBlock(d.blockType, d); }

const LABELS={text:'본문 텍스트',h3:'섹션 제목',img:'이미지 단독',pair:'이미지 2컬럼',quote:'인용구',caption:'캡션'};
const COLORS={text:'blk-lbl-text',h3:'blk-lbl-h3',img:'blk-lbl-img',pair:'blk-lbl-pair',quote:'blk-lbl-quote',caption:'blk-lbl-caption'};
const ICONS={text:'¶',h3:'H',img:'🖼',pair:'⊞',quote:'"',caption:'✏'};

function blkHTML(type, id, d){
  d = d || {};
  let inner = '';
  if(type==='text'){
    inner=`<div class="rt">
      <button type="button" onclick="fmt('bold')"><b>B</b></button>
      <button type="button" onclick="fmt('italic')"><i>I</i></button>
      <button type="button" onclick="fmt('underline')"><u>U</u></button>
      <div class="rt-div"></div>
      <button type="button" onclick="fmt('insertUnorderedList')">≡</button>
    </div>
    <div class="rc" contenteditable="true">${d.content||'본문 텍스트를 입력하세요...'}</div>`;
  } else if(type==='h3'){
    inner=`<input type="text" style="font-size:15px;font-weight:800" value="${d.content||''}" placeholder="섹션 제목 (예: 첫 번째 장소: 스테이 밤편지)">`;
  } else if(type==='img'){
    inner=`<div class="biu${d.imageUrl?' has':''}">
      <input type="file" accept="image/*">
      <div class="biu-ph"><span>🖼️</span>클릭하여 이미지 업로드<br><span style="font-size:11px">권장: 1400×788px</span></div>
      <img class="biu-prev" src="${d.imageUrl||''}" alt="">
    </div>`;
  } else if(type==='pair'){
    inner=`<div class="img-pair-up">
      <div class="biu${d.imageLeft?' has':''}">
        <input type="file" accept="image/*">
        <div class="biu-ph"><span>🖼️</span>왼쪽 이미지</div>
        <img class="biu-prev" src="${d.imageLeft||''}" alt="">
      </div>
      <div class="biu${d.imageRight?' has':''}">
        <input type="file" accept="image/*">
        <div class="biu-ph"><span>🖼️</span>오른쪽 이미지</div>
        <img class="biu-prev" src="${d.imageRight||''}" alt="">
      </div>
    </div>`;
  } else if(type==='quote'){
    inner=`<textarea style="min-height:72px;font-size:14px;font-style:italic" placeholder='"서두르지 않아도 괜찮은 이곳에서..."'>${d.content||''}</textarea>
    <input type="text" style="margin-top:8px;font-size:12px;font-weight:700;letter-spacing:2px;text-transform:uppercase" value="${d.citeText||''}" placeholder="EDITOR. TRIPAN">`;
  } else if(type==='caption'){
    inner=`<input type="text" style="font-size:12px;color:var(--muted);text-align:center" value="${d.content||''}" placeholder="이미지 캡션 텍스트 (예: 따뜻한 온기가 남아 있는 스테이의 거실)">`;
  }
  return `
    <div class="blk-head">
      <span class="blk-drag">⠿</span>
      <span class="blk-lbl ${COLORS[type]}">${ICONS[type]}&nbsp;${LABELS[type]}</span>
      <button type="button" class="blk-toggle" onclick="toggleBlk(this)">▾</button>
      <button type="button" class="blk-del" onclick="document.getElementById('${id}').remove();checkEmpty()">✕</button>
    </div>
    <div class="blk-body">${inner}</div>`;
}

function toggleBlk(btn){
  btn.closest('.block').querySelector('.blk-body').classList.toggle('hidden');
  btn.classList.toggle('closed');
}
function checkEmpty(){
  if(!document.getElementById('beCanvas').querySelector('.block'))
    document.getElementById('beCanvas').innerHTML='<div class="canvas-empty" id="emptyHint"><div class="ce-ico">✦</div><p>왼쪽에서 블록을 추가해보세요</p><span>텍스트, 이미지, 인용구 등을 자유롭게 배치</span></div>';
}
function fmt(cmd){ document.execCommand(cmd,false,null); }

/* ── MAG SUBMIT ── */
function submitMag(status){
  // 블록 직렬화
  const blocks = [];
  document.querySelectorAll('#beCanvas .block').forEach((blk,i)=>{
    const type = blk.querySelector('.blk-lbl').textContent.trim();
    const body = blk.querySelector('.blk-body');
    const obj  = {blockType:'', sortOrder:i, content:'', imageUrl:'', imageLeft:'', imageRight:'', citeText:''};
    if(body.querySelector('.rc'))      { obj.blockType='text';    obj.content=body.querySelector('.rc').innerHTML; }
    else if(body.querySelector('input[style*="font-weight:800"]')){ obj.blockType='h3'; obj.content=body.querySelector('input').value; }
    else if(body.querySelector('.img-pair-up')){ obj.blockType='pair';
      const imgs=body.querySelectorAll('.biu-prev');
      obj.imageLeft=imgs[0]?.src||''; obj.imageRight=imgs[1]?.src||'';
    } else if(body.querySelector('.biu') && !body.querySelector('input[style*="italic"]')){ obj.blockType='img'; obj.imageUrl=body.querySelector('.biu-prev')?.src||''; }
    else if(body.querySelector('textarea')){ obj.blockType='quote'; obj.content=body.querySelector('textarea').value;
      obj.citeText=body.querySelector('input[style*="uppercase"]')?.value||'';
    } else { obj.blockType='caption'; obj.content=body.querySelector('input').value; }
    blocks.push(obj);
  });

  // 태그 직렬화
  const tags = [...document.querySelectorAll('#tagWrap .tag-chip')]
      .map(c=>c.textContent.trim().replace('×','').trim());

  document.getElementById('magStatus').value = status;

  const id  = document.getElementById('magId').value;
  const url = id && id!=='0' ? CP+'/admin/curation/magazine/update' : CP+'/admin/curation/magazine/save';
  const fd  = new FormData(document.getElementById('magForm'));
  fd.set('blocksJson', JSON.stringify(blocks));
  fd.set('tagsJson',   JSON.stringify(tags));

  fetch(url,{method:'POST',body:fd})
    .then(r=>r.json()).then(d=>{
      if(d.success){
        closeMo('moMag');
        showToast(status===2 ? '임시저장되었습니다 📝' : '아티클이 게시되었습니다 📰');
        location.reload();
      } else alert(d.message||'저장 실패');
    });
}

/* ── DELETE MAG ── */
function deleteMag(articleId, btn){
  if(!confirm('아티클을 삭제하시겠습니까? 본문 블록도 함께 삭제됩니다.')) return;
  fetch(CP+'/admin/curation/magazine/delete',{
    method:'POST',
    headers:{'Content-Type':'application/x-www-form-urlencoded'},
    body:'articleId='+articleId
  }).then(r=>r.json()).then(d=>{
    if(d.success){ btn.closest('tr').remove(); showToast('아티클이 삭제되었습니다'); }
    else alert('삭제 실패');
  });
}

/* ── TAG INPUT ── */
function addTag(e){
  if(e.key!=='Enter') return; e.preventDefault();
  const inp=document.getElementById('tagIn');
  const v=inp.value.trim().replace(/^#/,'');
  if(!v) return;
  appendTagChip(v);
  inp.value='';
}
function appendTagChip(v){
  const chip=document.createElement('span');
  chip.className='tag-chip';
  chip.innerHTML=`#${v} <button type="button" onclick="this.parentElement.remove()">×</button>`;
  document.getElementById('tagWrap').insertBefore(chip,document.getElementById('tagIn'));
}

/* ── TOAST ── */
function showToast(msg){
  let t=document.getElementById('_toast');
  if(!t){ t=document.createElement('div'); t.id='_toast';
    Object.assign(t.style,{position:'fixed',bottom:'28px',left:'50%',transform:'translateX(-50%) translateY(70px)',
      background:'var(--text)',color:'#fff',padding:'12px 26px',borderRadius:'var(--radius-full)',
      fontSize:'13px',fontWeight:'800',zIndex:'9999',transition:'transform .35s cubic-bezier(.34,1.56,.64,1),opacity .3s',
      opacity:'0',boxShadow:'var(--shadow-md)',fontFamily:'inherit'});
    document.body.appendChild(t);
  }
  t.textContent=msg; t.style.opacity='1'; t.style.transform='translateX(-50%) translateY(0)';
  setTimeout(()=>{ t.style.opacity='0'; t.style.transform='translateX(-50%) translateY(70px)'; },2800);
}
</script>
</body>
</html>
