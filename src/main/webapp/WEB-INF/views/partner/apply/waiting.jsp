<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Tripan Partner — 심사 현황</title>
  
  <c:choose>
      <c:when test="${entryPoint == 'MAIN'}">
          <jsp:include page="/WEB-INF/views/layout/headerResources.jsp" />
      </c:when>
      <c:otherwise>
          <jsp:include page="/WEB-INF/views/partner/layout/headerResources.jsp" />
      </c:otherwise>
  </c:choose>

  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link href="https://fonts.googleapis.com/css2?family=Sora:wght@600;700;800&family=Noto+Sans+KR:wght@400;500;700;900&display=swap" rel="stylesheet">
  
  <style>
    /* 대기 화면 전용 추가 CSS */
    :root {
      --bg: #F0F2F8; --surface: #FFFFFF; --text: #0D1117; --muted: #8B92A5; --border: rgba(0,0,0,0.07);
      --primary: #3B6EF8; --primary-10: rgba(59,110,248,0.10);
      --danger: #EF4444;
      --radius-md: 12px; --radius-xl: 24px; --radius-full: 100px;
      --shadow-lg: 0 20px 60px rgba(0,0,0,0.12);
    }
    
    .waiting-body-wrap { 
      background: var(--bg); font-family: 'Noto Sans KR', sans-serif; color: var(--text); font-size: 14px; 
      min-height: 80vh; display: flex; flex-direction: column; 
    }
    
    .btn-wait { display: inline-flex; align-items: center; justify-content: center; gap: 6px; padding: 14px 20px; border-radius: var(--radius-full); font-size: 15px; font-weight: 700; transition: all .2s; border: none; }
    .btn-ghost { background: rgba(0,0,0,.05); color: var(--text); }
    .btn-ghost:hover { background: rgba(0,0,0,.09); }
    .btn-primary-wait { background: var(--primary); color: white; box-shadow: 0 4px 12px rgba(59,110,248,0.3); }
    .btn-primary-wait:hover { opacity: 0.9; transform: translateY(-2px); }

    .waiting-container { flex: 1; display: flex; align-items: center; justify-content: center; padding: 60px 20px; margin-top: 50px; }
    .waiting-card { background: var(--surface); width: 100%; max-width: 550px; border-radius: var(--radius-xl); box-shadow: var(--shadow-lg); padding: 50px 40px; text-align: center; border: 1px solid rgba(255,255,255,0.8); position: relative; overflow: hidden; animation: fadeUp 0.5s ease; }
    
    @keyframes fadeUp { from { opacity:0; transform:translateY(20px); } to { opacity:1; transform:translateY(0); } }

    .step-wrapper { display: flex; justify-content: space-between; position: relative; margin-bottom: 40px; }
    .step-wrapper::before { content: ''; position: absolute; top: 15px; left: 10%; right: 10%; height: 2px; background: var(--border); z-index: 1; }
    .step { position: relative; z-index: 2; display: flex; flex-direction: column; align-items: center; gap: 8px; flex: 1; }
    .step-circle { width: 32px; height: 32px; border-radius: 50%; background: var(--surface); border: 2px solid var(--border); color: var(--muted); font-weight: 800; display: flex; align-items: center; justify-content: center; font-size: 14px; transition: 0.3s; }
    .step-label { font-size: 12px; font-weight: 700; color: var(--muted); }
    
    .step.completed .step-circle { background: var(--primary); border-color: var(--primary); color: white; }
    .step.completed .step-label { color: var(--text); }
    .step.active .step-circle { border-color: var(--primary); color: var(--primary); box-shadow: 0 0 0 4px var(--primary-10); }
    .step.active .step-label { color: var(--primary); }
    .step.danger .step-circle { border-color: var(--danger); color: var(--danger); box-shadow: 0 0 0 4px rgba(239, 68, 68, 0.1); }
    .step.danger .step-label { color: var(--danger); }

    .status-icon { font-size: 60px; margin-bottom: 20px; display: inline-block; }
    .bounce-icon { animation: bounce 2s infinite ease-in-out; }
    @keyframes bounce { 0%, 100% { transform: translateY(0); } 50% { transform: translateY(-10px); } }
    .status-title { font-size: 24px; font-weight: 900; margin-bottom: 12px; color: var(--text); letter-spacing: -0.5px; }
    .status-desc { font-size: 15px; color: var(--muted); line-height: 1.6; margin-bottom: 30px; word-break: keep-all; }

    .reject-box { background: #FEF2F2; border: 1px solid #FECACA; border-radius: var(--radius-md); padding: 20px; text-align: left; margin-bottom: 30px; }
    .reject-box h4 { color: var(--danger); font-size: 14px; font-weight: 800; margin-bottom: 8px; display: flex; align-items: center; gap: 6px; }
    .reject-box p { color: #991B1B; font-size: 14px; font-weight: 600; line-height: 1.5; margin: 0; }
  </style>
</head>
<body>

<c:choose>
    <c:when test="${entryPoint == 'MAIN'}">
        <jsp:include page="/WEB-INF/views/layout/header.jsp" />
    </c:when>
    <c:otherwise>
        <jsp:include page="/WEB-INF/views/partner/layout/header.jsp" />
    </c:otherwise>
</c:choose>

<div class="waiting-body-wrap">
  <div class="waiting-container">
    <div class="waiting-card">
      
      <div class="step-wrapper">
        <div class="step completed">
          <div class="step-circle">✓</div>
          <div class="step-label">가입 및 서류제출</div>
        </div>
        
        <c:choose>
            <c:when test="${partnerStatus == 'REJECTED'}">
                <div class="step danger">
                  <div class="step-circle">!</div>
                  <div class="step-label">보완 요청</div>
                </div>
            </c:when>
            <c:otherwise>
                <div class="step active">
                  <div class="step-circle">2</div>
                  <div class="step-label">입점 심사중</div>
                </div>
            </c:otherwise>
        </c:choose>

        <div class="step">
          <div class="step-circle">3</div>
          <div class="step-label">승인 및 시작</div>
        </div>
      </div>

      <c:choose>
        <c:when test="${partnerStatus == 'REJECTED'}">
            <div>
              <div class="status-icon">🚨</div>
              <h2 class="status-title">입점 서류 보완이 필요합니다</h2>
              <p class="status-desc">
                Tripan 파트너 입점을 위해 <strong>일부 정보의 수정 및 보완</strong>이 필요합니다.<br>
                아래 사유를 확인하신 후 다시 신청해 주시기 바랍니다.
              </p>
              
              <div class="reject-box">
                <h4>⚠️ 관리자 요청 사유</h4>
                <p>${not empty rejectReason ? rejectReason : '제출하신 서류 확인이 불가하여 보완을 요청합니다.'}</p>
              </div>
              
              <button class="btn-wait btn-primary-wait" style="width: 100%;" onclick="location.href='${pageContext.request.contextPath}/partner/apply?mode=edit'">📝 신청서 수정하기</button>
            </div>
        </c:when>
        
        <c:otherwise>
            <div>
              <div class="status-icon bounce-icon">⏳</div>
              <h2 class="status-title">입점 심사가 진행 중입니다</h2>
              <p class="status-desc">
                제출해주신 소중한 사업자 정보와 서류를 꼼꼼하게 확인하고 있습니다.<br>
                심사는 <strong>영업일 기준 1~3일 정도 소요</strong>되며,<br>완료 시 알림 및 이메일로 결과를 안내해 드립니다.
              </p>
              <button class="btn-wait btn-ghost" style="width: 100%;" onclick="alert('고객센터(1588-1234)로 연결합니다.')">📞 고객센터 문의하기</button>
            </div>
        </c:otherwise>
      </c:choose>

    </div>
  </div>
</div>

<c:choose>
    <c:when test="${entryPoint == 'MAIN'}">
        <jsp:include page="/WEB-INF/views/layout/footer.jsp" />
        <jsp:include page="/WEB-INF/views/layout/footerResources.jsp" />
    </c:when>
    <c:otherwise>
        <jsp:include page="/WEB-INF/views/partner/layout/footer.jsp" />
    </c:otherwise>
</c:choose>

</body>
</html>