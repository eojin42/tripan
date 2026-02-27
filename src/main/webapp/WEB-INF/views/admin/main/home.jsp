<%@ page contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
<link rel="icon" href="data:;base64,iVBORw0KGgo=">
</head>
<body>
<div class="admin-container" style="display: flex; background: var(--bg-light); min-height: 100vh;">
  
  <aside class="admin-sidebar" style="width: 280px; background: var(--bg-white); padding: 40px 20px; border-right: 1px solid var(--bg-beige);">
    <div class="brand-logo" style="margin-bottom: 50px;">
      <span class="trip" style="color: var(--text-black);">Tri</span><span class="an">pan</span> <small style="font-size: 12px; color: var(--point-blue);">Admin</small>
    </div>
    <ul class="admin-menu" style="display: flex; flex-direction: column; gap: 10px;">
      <li class="active" style="background: var(--bg-beige); padding: 15px; border-radius: 12px; font-weight: 800;">대시보드 홈</li>
      <li style="padding: 15px; font-weight: 600;">입점 및 승인 관리</li>
      <li style="padding: 15px; font-weight: 600;">회원/권한 관리</li>
      <li style="padding: 15px; font-weight: 600;">커뮤니티 모니터링</li>
      <li style="padding: 15px; font-weight: 600;">API 사용량 점검</li>
    </ul>
  </aside>

  <main class="admin-content" style="flex: 1; padding: 40px 5%;">
    
    <header style="margin-bottom: 40px; display: flex; justify-content: space-between; align-items: center;">
      <h2 style="font-size: 28px; font-weight: 900;">플랫폼 리포트 🏆</h2>
      <div class="admin-profile" style="display: flex; align-items: center; gap: 10px;">
        <span style="font-weight: 700;">최고관리자님</span>
        <div class="author-pic" style="width: 40px; height: 40px; background: var(--point-blue);"></div>
      </div>
    </header>

    <div class="stats-grid" style="display: grid; grid-template-columns: repeat(4, 1fr); gap: 24px; margin-bottom: 40px;">
      <div class="list-item" style="padding: 24px; text-align: center;">
        <span class="tag">Total GMV</span>
        <h3 style="font-size: 24px; margin-top: 10px;">₩ 125,400,000</h3>
      </div>
      <div class="list-item" style="padding: 24px; text-align: center;">
        <span class="tag" style="color: var(--point-blue);">신규 입점 신청</span>
        <h3 style="font-size: 24px; margin-top: 10px;">12건</h3>
      </div>
      </div>

    <div style="display: grid; grid-template-columns: 2fr 1fr; gap: 30px;">
      
      <section class="admin-section" style="background: white; border-radius: 24px; padding: 30px; box-shadow: 0 10px 30px rgba(0,0,0,0.02);">
        <h3 style="margin-bottom: 20px;">신규 입점 심사 대기</h3>
        <table style="width: 100%; border-collapse: collapse;">
          <thead>
            <tr style="text-align: left; border-bottom: 2px solid var(--bg-light); color: var(--text-gray); font-size: 14px;">
              <th style="padding: 15px;">업체명</th>
              <th>신청일</th>
              <th>상태</th>
              <th>관리</th>
            </tr>
          </thead>
          <tbody>
            <tr style="border-bottom: 1px solid var(--bg-light);">
              <td style="padding: 15px; font-weight: 700;">스테이 오션 파크</td>
              <td>2026-02-25</td>
              <td><span style="color: var(--point-coral);">검토 대기</span></td>
              <td><button class="btn-more" style="padding: 5px 15px;">상세보기</button></td>
            </tr>
          </tbody>
        </table>
      </section>

      <section class="admin-section" style="background: white; border-radius: 24px; padding: 30px; box-shadow: 0 10px 30px rgba(0,0,0,0.02);">
        <h3 style="margin-bottom: 20px; color: #ff6b6b;">실시간 신고 현황</h3>
        <ul style="display: flex; flex-direction: column; gap: 15px;">
          <li style="font-size: 14px; padding: 10px; border-left: 4px solid var(--point-coral); background: #fff5f5;">
            <strong>자유게시판:</strong> 욕설 및 비방 게시물 신고
          </li>
          <li style="font-size: 14px; padding: 10px; border-left: 4px solid var(--point-blue); background: var(--bg-light);">
            <strong>시스템:</strong> Google Map API 호출 급증 경고
          </li>
        </ul>
      </section>

    </div>
  </main>
</div>
</body>
</html>
