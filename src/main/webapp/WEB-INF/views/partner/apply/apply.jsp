<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <title>Tripan - 파트너 입점 신청</title>
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/gh/orioncactus/pretendard@v1.3.8/dist/web/static/pretendard.css">
  <style>
    /* ── 3색 몽환 테마 토큰 ── */
    :root {
      --color-ice: #A8C8E1; --color-orchid: #C2B8D9; --color-rose: #E0BBC2;
      --grad-dreamy: linear-gradient(120deg, var(--color-ice) 0%, var(--color-orchid) 50%, var(--color-rose) 100%);
      --text-black: #111111; --text-gray: #777777; --bg-light: #f8f9fa; --border-light: #eeeeee;
    }
    * { margin: 0; padding: 0; box-sizing: border-box; }
    body { font-family: 'Pretendard', sans-serif; color: var(--text-black); line-height: 1.6; }
    
    /* 로고 & 내비게이션 */
    #navbar { height: 80px; padding: 0 40px; display: flex; align-items: center; border-bottom: 1px solid var(--border-light); position: sticky; top: 0; background: rgba(255,255,255,0.85); backdrop-filter: blur(10px); z-index: 1000; }
    .brand-logo { font-size: 26px; font-weight: 900; text-decoration: none; color: var(--text-black); }
    .brand-logo .an { background: var(--grad-dreamy); -webkit-background-clip: text; -webkit-text-fill-color: transparent; }

    /* 히어로 */
    .apply-hero { padding: 100px 20px; text-align: center; background: linear-gradient(180deg, #fff 0%, var(--bg-light) 100%); }
    .apply-hero h1 { font-size: 44px; font-weight: 900; letter-spacing: -1.5px; }
    .apply-hero h1 span { background: var(--grad-dreamy); -webkit-background-clip: text; -webkit-text-fill-color: transparent; }

    /* 폼 레이아웃 */
    .form-container { max-width: 850px; margin: 0 auto; padding: 60px 20px; }
    .form-section { margin-bottom: 80px; }
    .section-header { border-bottom: 2px solid var(--text-black); padding-bottom: 16px; margin-bottom: 40px; }
    .input-row { display: flex; align-items: center; margin-bottom: 28px; gap: 40px; }
    .label { width: 180px; font-size: 15px; font-weight: 800; }
    .label span { color: var(--color-orchid); }
    .input-field { width: 100%; padding: 16px 20px; border-radius: 14px; border: 1px solid #ddd; outline: none; transition: 0.3s; }
    .input-field:focus { border-color: var(--color-orchid); }

    /* 🌟 수정된 중앙 정렬 agreement-box */
    .agreement-box { background: var(--bg-light); border: 1px solid var(--border-light); padding: 30px; width: 100%; max-width: 600px; margin: 0 auto 40px auto; border-radius: 16px; text-align: center; }
    .agreement-content { font-size: 13px; color: var(--text-gray); height: 130px; overflow-y: auto; margin-bottom: 20px; text-align: left; }

    .btn-submit { width: 100%; max-width: 420px; padding: 22px; background: var(--grad-dreamy); color: white; border-radius: 100px; font-size: 19px; font-weight: 900; border: none; cursor: pointer; transition: 0.4s; }
    .btn-submit:hover { transform: translateY(-4px); box-shadow: 0 15px 35px rgba(194, 184, 217, 0.6); }
  </style>
</head>
<body>
  <nav id="navbar">
    <a href="${pageContext.request.contextPath}/" class="brand-logo">Tri<span class="an">pan</span></a>
  </nav>

  <header class="apply-hero">
    <h1>ARE YOU A <span>HOST</span>?</h1>
    <p>트리판의 몽환적인 감성 여행 코스에 당신의 스테이를 담아보세요.</p>
  </header>

  <main class="form-container">
    <form action="${pageContext.request.contextPath}/partner/apply" method="POST" enctype="multipart/form-data">
      
      <section class="form-section">
        <div class="section-header"><h2>담당자 정보</h2></div>
        <div class="input-row">
          <label class="label">담당자 성함<span>*</span></label>
          <input type="text" name="contactName" class="input-field" required>
        </div>
        <div class="input-row">
          <label class="label">연락처<span>*</span></label>
          <input type="tel" name="contactPhone" class="input-field" placeholder="'-' 제외 숫자만" required>
        </div>
      </section>

      <section class="form-section">
        <div class="section-header"><h2>스테이 정보</h2></div>
        <div class="input-row">
          <label class="label">스테이 이름<span>*</span></label>
          <input type="text" name="partnerName" class="input-field" required>
        </div>
        <div class="input-row">
          <label class="label">사업자 번호<span>*</span></label>
          <input type="text" name="businessNumber" class="input-field" required>
        </div>
      </section>

      <div class="agreement-box">
        <div class="agreement-content">
          <p><strong>개인정보 수집 및 이용 동의</strong></p>
          <p>1. 수집 항목 : 스테이 이름, 담당자 정보 등</p>
          <p>2. 보유 기간 : 검토 완료 후 3개월 간 보관</p>
        </div>
        <label style="font-weight:800;"><input type="checkbox" required> 동의합니다.</label>
      </div>

      <div style="text-align:center;">
        <button type="submit" class="btn-submit">입점 신청하기 ✨</button>
      </div>
    </form>
  </main>
</body>
</html>