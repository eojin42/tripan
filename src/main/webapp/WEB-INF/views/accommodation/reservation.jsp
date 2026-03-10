<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<jsp:include page="../layout/header.jsp" />

<style>
  .reserve-page-wrapper { background-color: #ffffff; padding: 120px 0 100px; font-family: var(--font-sans); color: #111; }
  .reserve-container { max-width: 1060px; margin: 0 auto; padding: 0 20px; }
  
  .page-title { font-size: 24px; font-weight: 800; margin-bottom: 40px; display: flex; align-items: center; gap: 12px; }
  .page-title span { cursor: pointer; color: #718096; }

  .reserve-layout { display: flex; gap: 60px; align-items: flex-start; }
  .form-section { flex: 1; min-width: 0; }
  .summary-section { width: 360px; flex-shrink: 0; position: sticky; top: 100px; }

  /* 좌측 폼 스타일 (스테이폴리오 스타일) */
  .info-group { border-bottom: 1px solid #E2E8F0; padding: 32px 0; }
  .info-group:first-child { border-top: 2px solid #111; padding-top: 32px; }
  
  .info-row { display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 24px; }
  .info-row:last-child { margin-bottom: 0; }
  .info-label { font-size: 15px; font-weight: 800; color: #111; width: 140px; flex-shrink: 0; }
  .info-value { font-size: 15px; color: #4A5568; flex: 1; text-align: right; }
  
  .input-textarea { width: 100%; padding: 16px; border: 1px solid #E2E8F0; border-radius: 4px; font-size: 14px; font-family: inherit; resize: vertical; min-height: 100px; margin-top: 12px; outline: none; }
  .input-textarea:focus { border-color: #111; }

  /* 결제 수단 라디오 버튼 */
  .pay-method-wrap { display: flex; flex-direction: column; gap: 12px; margin-top: 16px; }
  .pay-method-label { display: flex; align-items: center; padding: 16px; border: 1px solid #E2E8F0; border-radius: 4px; cursor: pointer; transition: all 0.2s; font-size: 15px; font-weight: 600; gap: 12px; }
  .pay-method-label:has(input:checked) { border-color: #111; font-weight: 800; }
  .pay-method-label input { width: 18px; height: 18px; accent-color: #111; }

  /* 약관 및 환불 규정 */
  .terms-wrap { margin-top: 16px; border: 1px solid #E2E8F0; border-radius: 4px; }
  .terms-header { padding: 16px; background: #F8F9FA; font-size: 14px; font-weight: 800; border-bottom: 1px solid #E2E8F0; }
  .terms-item { padding: 16px; font-size: 14px; color: #4A5568; border-bottom: 1px solid #E2E8F0; display: flex; justify-content: space-between; cursor: pointer; }
  .terms-item:last-child { border-bottom: none; }
  
  .refund-table { width: 100%; border-collapse: collapse; margin-top: 12px; font-size: 13px; text-align: center; display: none; }
  .refund-table th { background: #F8F9FA; padding: 10px; border: 1px solid #E2E8F0; font-weight: 700; }
  .refund-table td { padding: 10px; border: 1px solid #E2E8F0; color: #4A5568; }

  /* 우측 결제 요약 (Sticky) */
  .summary-card { border: 1px solid #E2E8F0; border-radius: 4px; padding: 24px; background: #fff; }
  .s-room-title { font-size: 18px; font-weight: 800; margin-bottom: 16px; }
  .s-room-img { width: 100%; height: 160px; object-fit: cover; border-radius: 4px; margin-bottom: 16px; }
  .s-room-info { font-size: 13px; color: #718096; line-height: 1.6; margin-bottom: 24px; }
  
  .s-price-row { display: flex; justify-content: space-between; align-items: center; margin-bottom: 12px; font-size: 14px; color: #4A5568; }
  .s-total-price { display: flex; justify-content: space-between; align-items: center; margin-top: 24px; padding-top: 24px; border-top: 1px solid #111; font-size: 20px; font-weight: 900; color: #111; }
  
  .btn-submit-pay { width: 100%; background: #111; color: #fff; border: none; padding: 18px; font-size: 16px; font-weight: 800; margin-top: 24px; cursor: pointer; border-radius: 4px; transition: background 0.2s; }
  .btn-submit-pay:hover { background: #333; }

  @media (max-width: 768px) {
    .reserve-layout { flex-direction: column; gap: 40px; }
    .summary-section { width: 100%; position: static; }
  }
</style>

<div class="reserve-page-wrapper">
  <div class="reserve-container">
    
    <div class="page-title">
      <span onclick="history.back()">〈</span> 예약 확인 및 결제
    </div>

    <div class="reserve-layout">
      
      <div class="form-section">
        
        <div class="info-group">
          <div class="info-row">
            <div class="info-label">예약 일정</div>
            <div class="info-value" style="font-weight:700; color:#111;">${checkin} ~ ${checkout}</div>
          </div>
          <div class="info-row">
            <div class="info-label">예약 인원</div>
            <div class="info-value">성인 ${adult}명, 아동 ${child}명</div>
          </div>
        </div>

        <div class="info-group">
          <div class="info-row">
            <div class="info-label">예약자 정보</div>
            <div class="info-value">
              <div style="font-weight:700; color:#111; margin-bottom:4px;">${sessionScope.loginUser.nickname != null ? sessionScope.loginUser.nickname : '게스트'}</div>
              <div>010-XXXX-XXXX</div>
            </div>
          </div>
        </div>

        <div class="info-group">
          <div class="info-label" style="margin-bottom: 8px;">요청사항</div>
          <textarea class="input-textarea" placeholder="요청사항을 입력해 주세요. (예: 아기 침대 추가 부탁드립니다)"></textarea>
        </div>

        <div class="info-group">
          <div class="info-label" style="margin-bottom: 16px;">결제 수단</div>
          <div class="pay-method-wrap">
            <label class="pay-method-label">
              <input type="radio" name="payMethod" value="card" checked> 일반 신용카드 (최대 6개월 무이자 할부)
            </label>
            <label class="pay-method-label">
              <input type="radio" name="payMethod" value="tosspay"> <span style="color:#0050FF; font-weight:900;">toss</span> 머니/계좌 결제
            </label>
            <label class="pay-method-label">
              <input type="radio" name="payMethod" value="kakaopay"> <span style="color:#FEE500; background:#111; padding:2px 6px; border-radius:4px; font-size:12px;">pay</span> 카카오페이
            </label>
          </div>
        </div>

        <div class="terms-wrap">
          <div class="terms-header">
            <label style="display:flex; align-items:center; gap:8px; cursor:pointer;">
              <input type="checkbox" id="chkAllTerms"> 사용자 약관 전체 동의
            </label>
          </div>
          <div class="terms-item"><span>(필수) 개인정보 제 3자 제공 동의</span> <span>〉</span></div>
          <div class="terms-item"><span>(필수) 미성년자(청소년) 투숙 기준 동의</span> <span>〉</span></div>
          <div class="terms-item" onclick="toggleRefundTable()">
            <span>(필수) 스테이 환불 규정</span> <span id="refundArrow">∨</span>
          </div>
          <table class="refund-table" id="refundTable">
            <tr><th>기준일</th><th>환불 금액</th></tr>
            <tr><td>이용 10일전까지</td><td>총 결제금액의 100% 환불</td></tr>
            <tr><td>이용 9일전까지</td><td>총 결제금액의 90% 환불</td></tr>
            <tr><td>이용 8일전까지</td><td>총 결제금액의 80% 환불</td></tr>
            <tr><td>이용 7일전까지</td><td>총 결제금액의 70% 환불</td></tr>
            <tr><td>이용 6일전까지</td><td>총 결제금액의 60% 환불</td></tr>
            <tr><td>이용 5일전까지</td><td>총 결제금액의 50% 환불</td></tr>
            <tr><td>이용 4일전까지</td><td>총 결제금액의 40% 환불</td></tr>
            <tr><td>이용 3일전부터</td><td>변경 / 환불 불가</td></tr>
          </table>
        </div>

      </div>

      <div class="summary-section">
        <div class="summary-card">
          <div class="s-room-title">${roomName}</div>
          <img src="https://images.unsplash.com/photo-1598928506311-c55ded91a20c?w=600" class="s-room-img" alt="객실 이미지">
          
          <div class="s-room-info">
            객실 번호: ${roomId}호<br>
            기준 2명 (최대 4명)<br>
            체크인 15:00 / 체크아웃 11:00
          </div>

          <div class="s-price-row">
            <span>객실 요금</span>
            <span><fmt:formatNumber value="${amount}" pattern="#,###"/>원</span>
          </div>
          <div class="s-price-row" style="color: #E53E3E;">
            <span>쿠폰 할인</span>
            <span>- 0원</span>
          </div>

          <div class="s-total-price">
            <span>총 결제금액</span>
            <span><fmt:formatNumber value="${amount}" pattern="#,###"/>원</span>
          </div>

          <button class="btn-submit-pay" onclick="requestPayment()">결제하기</button>
        </div>
      </div>

    </div>
  </div>
</div>

<script src="https://cdn.iamport.kr/v1/iamport.js"></script>

<script>
  // 1. 주소 맵핑 수정: /reservation/ -> /accommodation/
  window.addEventListener("beforeunload", function (e) {
      const payload = JSON.stringify({ roomId: '${roomId}', checkin: '${checkin}' });
      const url = '${pageContext.request.contextPath}/accommodation/release-lock'; 
      navigator.sendBeacon(url, new Blob([payload], {type: 'application/json'}));
  });

  function toggleRefundTable() {
    const table = document.getElementById('refundTable');
    const arrow = document.getElementById('refundArrow');
    if (table.style.display === 'table') {
      table.style.display = 'none';
      arrow.innerText = '∨';
    } else {
      table.style.display = 'table';
      arrow.innerText = '∧';
    }
  }

  function requestPayment() {
    if(!document.getElementById('chkAllTerms').checked) {
      alert("필수 약관에 모두 동의해주세요.");
      return;
    }
    
    const payMethod = document.querySelector('input[name="payMethod"]:checked').value;
    let pgType = "";
    
    // 2. PG 파라미터 에러 해결: 카카오페이 테스트용 공식 코드로 변경
    if (payMethod === 'kakaopay') {
        pgType = "kakaopay.TC0ONETIME"; 
    } else if (payMethod === 'tosspay') {
        pgType = "tosspay";       
    } else {
        pgType = "html5_inicis";  
    }

    var IMP = window.IMP;
    IMP.init("imp27678455"); // 내 식별코드 

    IMP.request_pay({
        pg: pgType,
        pay_method: "card",
        merchant_uid: "ORDER_" + new Date().getTime(), 
        name: "${roomName}",                           
        amount: ${amount},                             
        buyer_name: "${sessionScope.loginUser.nickname != null ? sessionScope.loginUser.nickname : '게스트'}",
        buyer_tel: "010-1234-5678"                     
    }, function (rsp) { 
        if (rsp.success) {
            console.log("결제 성공 응답:", rsp);
            
            // 3. 누락되었던 AJAX 코드 추가 및 /accommodation/complete 로 주소 맵핑!
            const requestData = {
                impUid: rsp.imp_uid,
                merchantUid: rsp.merchant_uid,
                roomId: '${roomId}',
                checkin: '${checkin}',
                checkout: '${checkout}',
                adult: ${adult},
                child: ${child},
                amount: ${amount},
                payMethod: payMethod
            };

            // 🌟 대망의 백엔드 통신 부분!
            fetch('${pageContext.request.contextPath}/accommodation/complete', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(requestData)
            })
            .then(res => res.json())
            .then(data => {
                if(data.success) {
                    alert("예약 및 결제가 완벽하게 처리되었습니다! 🎉\n결제번호: " + rsp.imp_uid);
                    // 성공하면 홈 화면으로 이동 (나중에는 예약 내역 페이지로 바꾸시면 됩니다!)
                    location.href = '${pageContext.request.contextPath}/accommodation/home'; 
                } else {
                    alert("DB 저장 중 문제가 발생했습니다.\n에러: " + data.message);
                }
            })
            .catch(err => {
                console.error("서버 통신 에러:", err);
                alert("서버와 통신 중 에러가 발생했습니다.");
            });

        } else {
            alert("결제에 실패하였습니다.\n에러 내용: " + rsp.error_msg);
        }
    });
  }
</script>

<jsp:include page="../layout/footer.jsp" />