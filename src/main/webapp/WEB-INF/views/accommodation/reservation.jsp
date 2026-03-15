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
  
  .info-group { border-bottom: 1px solid #E2E8F0; padding: 32px 0; }
  .info-group:first-child { border-top: 2px solid #111; padding-top: 32px; }
  .info-row { display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 24px; }
  .info-row:last-child { margin-bottom: 0; }
  .info-label { font-size: 15px; font-weight: 800; color: #111; width: 140px; flex-shrink: 0; }
  .info-value { font-size: 15px; color: #4A5568; flex: 1; text-align: right; }
  
  .input-textarea, .input-select, .input-text { width: 100%; padding: 16px; border: 1px solid #E2E8F0; border-radius: 4px; font-size: 14px; font-family: inherit; outline: none; }
  .input-textarea { resize: vertical; min-height: 100px; margin-top: 12px; }
  .input-textarea:focus, .input-select:focus, .input-text:focus { border-color: #111; }

  /* 쿠폰 / 마일리지 버튼 등 */
  .flex-header { display: flex; justify-content: space-between; margin-bottom: 12px; align-items: center; }
  .sub-text { font-size: 14px; color: #718096; }
  .btn-use-all { padding: 0 24px; background: #F1F3F5; border: none; border-radius: 4px; font-weight: 700; color: #4A5568; cursor: pointer; transition: background 0.2s; white-space: nowrap; }
  .btn-use-all:hover { background: #E2E8F0; }

  /* 요금 상세 영역 */
  .price-detail-box { display: flex; flex-direction: column; gap: 12px; }
  .pd-row { display: flex; justify-content: space-between; font-size: 15px; color: #111; }
  .pd-sub-row { display: flex; justify-content: space-between; font-size: 13px; color: #A0AEC0; margin-top: -8px; margin-bottom: 4px; }
  .pd-row.total { font-size: 18px; font-weight: 800; margin-top: 8px; }

  .pay-method-wrap { display: flex; flex-direction: column; gap: 12px; margin-top: 16px; }
  .pay-method-label { display: flex; align-items: center; padding: 16px; border: 1px solid #E2E8F0; border-radius: 4px; cursor: pointer; transition: all 0.2s; font-size: 15px; font-weight: 600; gap: 12px; }
  .pay-method-label:has(input:checked) { border-color: #111; font-weight: 800; }
  .pay-method-label input, .terms-wrap input[type="checkbox"] { width: 18px; height: 18px; accent-color: #111; cursor: pointer; }

  /* 약관 영역 */
  .terms-wrap { margin-top: 16px; border: 1px solid #E2E8F0; border-radius: 4px; }
  .terms-header { padding: 16px; background: #F8F9FA; font-size: 15px; font-weight: 800; border-bottom: 1px solid #E2E8F0; }
  .terms-item { padding: 16px; font-size: 14px; color: #111; border-bottom: 1px solid #E2E8F0; display: flex; justify-content: space-between; align-items: center; cursor: pointer; }
  .terms-item:last-child { border-bottom: none; }
  .term-content { display: none; padding: 16px; background: #F8F9FA; border-bottom: 1px solid #E2E8F0; font-size: 13px; color: #4A5568; line-height: 1.6; }
  
  .refund-table { width: 100%; border-collapse: collapse; margin-top: 0; font-size: 13px; text-align: center; display: none; }
  .refund-table th { background: #F8F9FA; padding: 10px; border: 1px solid #E2E8F0; border-top: none; font-weight: 700; }
  .refund-table td { padding: 10px; border: 1px solid #E2E8F0; color: #4A5568; }

  /* 우측 써머리 카드 */
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
            <div class="info-value" style="font-weight:700; color:#111;">${checkin} ~ ${checkout} (${nights}박)</div>
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
              <div style="font-weight:700; color:#111; margin-bottom:6px;">${sessionScope.loginUser.username}</div>
              <div style="margin-bottom:4px;">${sessionScope.loginUser.phoneNumber}</div>
              <div style="font-size: 13px; color: #718096;">${sessionScope.loginUser.email}</div>
            </div>
          </div>
        </div>

        <div class="info-group">
          <div class="info-label" style="margin-bottom: 8px;">요청사항</div>
          <textarea id="guestRequest" class="input-textarea" placeholder="요청사항을 입력해 주세요. (예: 아기 침대 추가 부탁드립니다)"></textarea>
        </div>

        <div class="info-group">
          <div class="flex-header">
            <div class="info-label">쿠폰</div>
            <div class="sub-text">0개 쿠폰 사용 가능</div>
          </div>
          <select class="input-select">
            <option>사용 가능한 쿠폰이 없습니다.</option>
          </select>
        </div>

        <div class="info-group">
          <div class="flex-header">
            <div class="info-label">마일리지</div>
            <div class="sub-text">보유 마일리지 0원</div>
          </div>
          <div style="display: flex; gap: 12px;">
            <input type="text" class="input-text" placeholder="0" style="background:#F8F9FA;" readonly>
            <button type="button" class="btn-use-all">모두 사용</button>
          </div>
        </div>

        <div class="info-group">
          <div class="info-label" style="margin-bottom: 16px;">요금 상세</div>
          <div class="price-detail-box">
             <div class="pd-row"><span>객실 요금</span><span>₩<fmt:formatNumber value="${room.amount}" pattern="#,###"/></span></div>
             <div class="pd-sub-row"><span>└ ${checkin}</span><span>₩<fmt:formatNumber value="${room.amount}" pattern="#,###"/></span></div>
             <div class="pd-row"><span>인원 추가</span><span>₩<fmt:formatNumber value="${(amount / nights) - room.amount}" pattern="#,###"/></span></div>
             <div class="pd-row"><span>옵션</span><span>₩0</span></div>
             <div class="pd-row"><span>요금 할인</span><span>- ₩0</span></div>
             <div class="pd-sub-row"><span>└ 프로모션</span><span>- ₩0</span></div>
             <div class="pd-row"><span>쿠폰</span><span>₩0</span></div>
             <div class="pd-row"><span>마일리지</span><span>₩0</span></div>
             <hr style="border:0; border-top:1px solid #111; margin: 16px 0;">
             <div class="pd-row total"><span>총 결제 금액</span><span>₩<fmt:formatNumber value="${amount}" pattern="#,###"/></span></div>
          </div>
        </div>

        <div class="info-group">
          <div class="info-label" style="margin-bottom: 16px;">결제 수단</div>
          <div class="pay-method-wrap">
            <label class="pay-method-label"><input type="radio" name="payMethod" value="card" checked> 일반 신용카드</label>
            <label class="pay-method-label"><input type="radio" name="payMethod" value="tosspay"> <span style="color:#0050FF; font-weight:900;">toss</span> 머니/계좌 결제</label>
            <label class="pay-method-label"><input type="radio" name="payMethod" value="kakaopay"> <span style="color:#FEE500; background:#111; padding:2px 6px; border-radius:4px; font-size:12px;">pay</span> 카카오페이</label>
          </div>
        </div>

        <div class="terms-wrap">
          <div class="terms-header">
            <label style="display:flex; align-items:center; gap:8px; cursor:pointer;">
              <input type="checkbox" id="chkAllTerms"> 사용자 약관 전체 동의
            </label>
          </div>
          
          <div class="terms-item" onclick="toggleTerm('termInfo')">
            <label style="display:flex; align-items:center; gap:8px; cursor:pointer;" onclick="event.stopPropagation();">
              <input type="checkbox" class="chk-term"> (필수) 개인정보 제 3자 제공 동의
            </label>
            <span class="term-arrow" id="arr-termInfo">∨</span>
          </div>
          <div id="termInfo" class="term-content">
            (주)스테이폴리오는 예약 시스템 제공 과정에서 예약자 동의 하에 서비스 이용을 위한 예약자 개인정보를 수집하며, 수집된 개인정보는 제휴 판매자(숙소)에게 제공됩니다.<br>
            정보 주체는 개인정보의 수집 및 이용 동의를 거부할 권리가 있으나, 이 경우 상품 및 서비스 예약이 제한됩니다.<br><br>
            <strong>- 제공 받는 자 : ${room.placeName}</strong><br>
            - 제공 목적: 제휴 판매자(숙소)와 이용자(회원)의 예약에 대한 서비스 제공, 계약의 이행(예약확인, 이용자 확인), 민원 처리 등 소비자 분쟁 해결을 위한 기록 보존<br>
            - 제공 정보: 예약번호, 아이디, 성명, 휴대전화 번호, 이메일, 인원 정보, 생년월일(필요한 경우), 동행 투숙객 정보(필요한 경우)<br>
            - 보유 및 이용 기간 : 5년
          </div>

          <div class="terms-item" onclick="toggleTerm('termAge')">
            <label style="display:flex; align-items:center; gap:8px; cursor:pointer;" onclick="event.stopPropagation();">
              <input type="checkbox" class="chk-term"> (필수) 미성년자(청소년) 투숙 기준 동의
            </label>
            <span class="term-arrow" id="arr-termAge">∨</span>
          </div>
          <div id="termAge" class="term-content">
            <strong>스테이 소재지 : 대한민국</strong><br>
            1. 만 19세 미만 미성년자(청소년)의 경우 예약 및 투숙이 불가합니다.<br>
            2. 만 19세 미만 미성년자(청소년)가 투숙을 원하는 경우 보호자(법정대리인)가 필수 동행해야 합니다.<br>
            3. 이용일 당일 미성년자(청소년) 투숙 기준 위반이 확인되는 경우 환불없이 퇴실 조치됩니다.<br><br>
            <strong>스테이 소재지 : 대한민국 외</strong><br>
            1. 스테이가 위치한 국가/지역에 따라 미성년자(청소년)로 간주되는 경우 예약 및 투숙이 불가합니다.<br>
            2. 미성년자(청소년)가 투숙을 원하는 경우 보호자(법정대리인)가 필수 동행해야 합니다.<br>
            3. 이용일 당일 미성년자(청소년) 투숙 기준 위반이 확인되는 경우 환불없이 퇴실 조치됩니다.
          </div>

          <div class="terms-item" onclick="toggleTerm('termRefund')">
            <label style="display:flex; align-items:center; gap:8px; cursor:pointer;" onclick="event.stopPropagation();">
              <input type="checkbox" class="chk-term"> (필수) 스테이 환불 규정
            </label>
            <span class="term-arrow" id="arr-termRefund">∨</span>
          </div>
          <table class="refund-table term-content" id="termRefund">
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
          <div class="s-room-title">${room.placeName} - ${room.roomName}</div>
          <img src="${room.roomImageUrl}" class="s-room-img" onerror="this.src='https://images.unsplash.com/photo-1598928506311-c55ded91a20c?w=600'">
          
          <div class="s-room-info">
            기준 ${room.roomBaseCount}명 (최대 ${room.maxCapacity}명)<br>
            ${nights}박 일정
          </div>

          <div class="s-price-row">
            <span>객실 요금</span>
            <span><fmt:formatNumber value="${amount}" pattern="#,###"/>원</span>
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
  // 🌟 약관 아코디언 토글 (하나 열면 나머지는 닫힘)
  function toggleTerm(id) {
    const targetEl = document.getElementById(id);
    const isCurrentlyOpen = targetEl.style.display === 'block' || targetEl.style.display === 'table';

    // 1. 모든 컨텐츠 닫기
    document.querySelectorAll('.term-content').forEach(el => {
      el.style.display = 'none';
    });
    // 2. 모든 화살표 아래로 초기화
    document.querySelectorAll('.term-arrow').forEach(arrow => {
      arrow.innerText = '∨';
    });

    // 3. 클릭한게 닫혀있었다면 열기
    if (!isCurrentlyOpen) {
      targetEl.style.display = (id === 'termRefund') ? 'table' : 'block';
      document.getElementById('arr-' + id).innerText = '∧';
    }
  }

  // 🌟 약관 체크박스 동기화 로직
  const chkAll = document.getElementById('chkAllTerms');
  const chkItems = document.querySelectorAll('.chk-term');

  // '전체 동의' 클릭 시 개별 항목 동기화
  chkAll.addEventListener('change', function() {
    chkItems.forEach(chk => chk.checked = chkAll.checked);
  });

  // 개별 항목 클릭 시 '전체 동의' 상태 업데이트
  chkItems.forEach(chk => {
    chk.addEventListener('change', function() {
      const allChecked = Array.from(chkItems).every(c => c.checked);
      chkAll.checked = allChecked;
    });
  });

  // 페이지 이탈 시 락 릴리즈
  window.addEventListener("beforeunload", function (e) {
      const payload = JSON.stringify({ roomId: '${roomId}', checkin: '${checkin}' });
      const url = '${pageContext.request.contextPath}/accommodation/release-lock'; 
      navigator.sendBeacon(url, new Blob([payload], {type: 'application/json'}));
  });

  function requestPayment() {
    // 🌟 결제 전 체크박스 검증 (chkAllTerms가 체크되어 있는지 확인)
    if(!document.getElementById('chkAllTerms').checked) {
      alert("필수 약관에 모두 동의해주세요.");
      return;
    }
    
    const payMethod = document.querySelector('input[name="payMethod"]:checked').value;
    let pgType = payMethod === 'kakaopay' ? "kakaopay.TC0ONETIME" : (payMethod === 'tosspay' ? "tosspay" : "html5_inicis");

    var IMP = window.IMP;
    IMP.init("imp27678455"); 

    IMP.request_pay({
        pg: pgType,
        pay_method: "card",
        merchant_uid: "ORDER_" + new Date().getTime(), 
        name: "${room.placeName} - ${room.roomName}",                           
        amount: ${amount},             
        buyer_name: "${sessionScope.loginUser.username}", 
        buyer_tel: "${sessionScope.loginUser.phoneNumber}", 
        buyer_email: "${sessionScope.loginUser.email}" 
    }, function (rsp) { 
        if (rsp.success) {
            const requestData = {
                impUid: rsp.imp_uid,
                merchantUid: rsp.merchant_uid,
                roomId: '${roomId}',
                checkin: '${checkin}',
                checkout: '${checkout}',
                adult: ${adult},
                child: ${child},
                amount: ${amount},
                payMethod: payMethod,
                request: document.getElementById('guestRequest').value // textarea 값 넘기기
            };

            fetch('${pageContext.request.contextPath}/accommodation/complete', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(requestData)
            })
            .then(res => res.json())
            .then(data => {
                if(data.success) {
                    alert("예약 및 결제가 완벽하게 처리되었습니다!");
                    location.href = '${pageContext.request.contextPath}/mypage/schedule'; 
                } else {
                    alert("DB 저장 중 문제가 발생했습니다.\n에러: " + data.message);
                }
            })
            .catch(err => {
                alert("서버와 통신 중 에러가 발생했습니다.");
            });
        } else {
            alert("결제에 실패하였습니다.\n에러 내용: " + rsp.error_msg);
        }
    });
  }
</script>

<jsp:include page="../layout/footer.jsp" />