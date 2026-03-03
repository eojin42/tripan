<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>TripanSuper Admin — 숙소별 매출 통계</title>
  
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link href="https://fonts.googleapis.com/css2?family=Sora:wght@600;700;800&family=Noto+Sans+KR:wght@400;500;700;900&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/dist/css/admin.css">
</head>
<body>

<jsp:include page="../layout/header.jsp" />

<main class="main-content">
  <div class="page-header fade-up">
    <div>
      <h1>🏨 숙소별 매출 통계</h1>
      <p>플랫폼에 등록된 전체 숙소의 실적과 운영 상태를 모니터링합니다.</p>
    </div>
  </div>

  <div class="card filter-card fade-up fade-up-1">
    
    <div class="filter-row">
      <span class="filter-label">날짜조회</span>
      <div class="date-range">
        <input type="date" class="date-input" value="2026-03-01">
        <span class="date-sep">~</span>
        <input type="date" class="date-input" value="2026-03-31">
      </div>
    </div>

    <div class="filter-row">
      <span class="filter-label">상태필터</span>
      <select class="filter-select">
        <option value="">전체 지역</option>
        <option value="jeju">제주특별자치도</option>
        <option value="seoul">서울특별시</option>
        <option value="busan">부산광역시</option>
        <option value="gyeongju">경상북도 경주시</option>
      </select>

      <select class="filter-select">
        <option value="">운영상태 (전체)</option>
        <option value="active">🟢 운영중</option>
        <option value="blocked">🔴 노출차단</option>
      </select>
    </div>

    <div class="filter-row">
      <span class="filter-label">키워드</span>
      <input type="text" class="keyword-input" placeholder="숙소명 또는 ID 입력...">
      
      <div class="filter-actions">
        <button class="btn-search" aria-label="검색">
          <svg viewBox="0 0 24 24" width="16" height="16" fill="none" stroke="currentColor" stroke-width="2"><circle cx="11" cy="11" r="8"></circle><line x1="21" y1="21" x2="16.65" y2="16.65"></line></svg>
          검색
        </button>
        <button class="btn-reset" aria-label="초기화">
          <svg viewBox="0 0 24 24" width="16" height="16" fill="none" stroke="currentColor" stroke-width="2"><polyline points="1 4 1 10 7 10"></polyline><polyline points="23 20 23 14 17 14"></polyline><path d="M20.49 9A9 9 0 0 0 5.64 5.64L1 10m22 4l-4.64 4.36A9 9 0 0 1 3.51 15"></path></svg>
          초기화
        </button>
      </div>
    </div>
  </div>

  <div class="card table-card fade-up fade-up-2">
    
    <div class="result-header" style="margin-top: 20px;">
      <div class="result-count">총 <strong>1,204</strong>개의 숙소</div>
      
      <div class="result-actions" style="display: flex; gap: 8px; align-items: center;">
        <select class="filter-select select-sm">
          <option value="gmv_desc">매출액 낮은 순</option>
          <option value="gmv_asc">매출액 높은 순</option>
          <option value="book_desc">예약건수 많은 순</option>
          <option value="book_asc">예약건수 적은 순</option>
        </select>
        
        <button class="btn btn-ghost btn-sm" onclick="alert('엑셀 다운로드 준비 중입니다.')">
          <svg viewBox="0 0 24 24" width="14" height="14" fill="none" stroke="currentColor" stroke-width="2"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"></path><polyline points="7 10 12 15 17 10"></polyline><line x1="12" y1="15" x2="12" y2="3"></line></svg>
          엑셀 다운로드
        </button>
      </div>
    </div>

    <div class="table-responsive">
      <table>
        <thead>
          <tr>
            <th style="width: 60px; text-align: center;">순위</th>
            <th>숙소 정보</th>
            <th>지역</th>
            <th class="right">누적 매출액(GMV)</th>
            <th class="right">예약 건수</th>
            <th style="text-align: center;">운영 상태</th>
            <th style="text-align: center;">관리</th>
          </tr>
        </thead>
        <tbody>
          <tr>
            <td style="text-align: center;"><span class="num num-strong">1</span></td>
            <td>
              <div class="stay-cell">
                <img src="https://images.unsplash.com/photo-1571003123894-1f0594d2b5d9?w=100&q=80" class="stay-thumb" alt="아만 스위트 리저브">
                <div class="stay-info">
                  <h4>아만 스위트 리저브</h4>
                  <p>ID: #ST001</p>
                </div>
              </div>
            </td>
            <td style="font-weight: 600;">제주</td>
            <td class="right"><span class="num num-strong num-primary">₩ 45,000,000</span></td>
            <td class="right"><span class="num">124건</span></td>
            <td style="text-align: center;"><span class="badge badge-done"><span class="status-dot dot-success"></span>운영중</span></td>
            <td style="text-align: center;"><button class="btn btn-ghost btn-sm">차단</button></td>
          </tr>
          <tr>
            <td style="text-align: center;"><span class="num num-strong">2</span></td>
            <td>
              <div class="stay-cell">
                <img src="https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=100&q=80" class="stay-thumb" alt="신라 더 파크 호텔">
                <div class="stay-info">
                  <h4>신라 더 파크 호텔</h4>
                  <p>ID: #ST002</p>
                </div>
              </div>
            </td>
            <td style="font-weight: 600;">서울</td>
            <td class="right"><span class="num num-strong">₩ 38,500,000</span></td>
            <td class="right"><span class="num">98건</span></td>
            <td style="text-align: center;"><span class="badge badge-done"><span class="status-dot dot-success"></span>운영중</span></td>
            <td style="text-align: center;"><button class="btn btn-ghost btn-sm">차단</button></td>
          </tr>
          <tr>
            <td style="text-align: center;"><span class="num num-strong">5</span></td>
            <td>
              <div class="stay-cell">
                <img src="https://images.unsplash.com/photo-1555854877-bab0e564b8d5?w=100&q=80" class="stay-thumb" alt="경주 한옥 스테이">
                <div class="stay-info">
                  <h4>경주 한옥 스테이</h4>
                  <p>ID: #ST005</p>
                </div>
              </div>
            </td>
            <td style="font-weight: 600;">경주</td>
            <td class="right"><span class="num num-strong">₩ 14,200,000</span></td>
            <td class="right"><span class="num">45건</span></td>
            <td style="text-align: center;"><span class="badge badge-danger"><span class="status-dot dot-danger"></span>노출차단</span></td>
            <td style="text-align: center;"><button class="btn btn-primary btn-sm">해제</button></td>
          </tr>
        </tbody>
      </table>
    </div>

    <div class="pagination">
      <button class="page-btn arrow">←</button>
      <button class="page-btn active">1</button>
      <button class="page-btn">2</button>
      <button class="page-btn">3</button>
      <button class="page-btn">4</button>
      <button class="page-btn">5</button>
      <button class="page-btn arrow">→</button>
    </div>
  </div>
</main>

<jsp:include page="../layout/footer.jsp" />

</body>
</html>