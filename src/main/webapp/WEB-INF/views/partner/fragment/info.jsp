<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<div id="tab-info" class="page-section ${activeTab == 'info' ? 'active' : ''}">
  <div class="page-header" style="display:flex; justify-content:space-between; align-items:flex-end;">
    <div>
      <h1>파트너 정보 관리</h1>
      <p>플랫폼에 노출되는 숙소 소개글과 매월 정산받을 계좌 정보를 관리합니다.</p>
    </div>
    <button class="btn btn-primary" onclick="savePartnerInfo()">변경사항 저장</button>
  </div>

  <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 24px;">
    
    <div class="card" style="margin-bottom: 0;">
      <h2 style="font-size: 16px; font-weight: 800; margin-bottom: 20px;">👤 담당자 및 사업자 정보</h2>
      
      <div style="margin-bottom: 16px;">
        <label>사업장명 (수정 불가)</label>
        <input type="text" class="form-control" value="${partnerInfo.partnerName}" disabled style="width:100%; padding:10px; border:1px solid var(--border); border-radius:8px; background: #F8FAFC; color: #8B92A5;">
      </div>
      
      <div style="margin-bottom: 16px;">
        <label>사업자등록번호 (수정 불가)</label>
        <input type="text" class="form-control" value="${partnerInfo.businessNumber != null ? partnerInfo.businessNumber : '심사중'}" disabled style="width:100%; padding:10px; border:1px solid var(--border); border-radius:8px; background: #F8FAFC; color: #8B92A5;">
      </div>

      <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 12px; margin-bottom: 16px;">
        <div>
          <label>담당자 이름</label>
          <input type="text" id="contactName" class="form-control" value="${partnerInfo.contactName}" style="width:100%; padding:10px; border:1px solid var(--border); border-radius:8px;">
        </div>
        <div>
          <label>담당자 연락처</label>
          <input type="text" id="contactPhone" class="form-control" value="${partnerInfo.contactPhone}" style="width:100%; padding:10px; border:1px solid var(--border); border-radius:8px;">
        </div>
      </div>
      <div style="padding-top: 16px; border-top: 1px dashed var(--border);">
        <h3 style="font-size: 14px; font-weight: 800; margin-bottom: 12px; color: var(--primary);">💰 정산 계좌 정보</h3>
        <div style="display: grid; grid-template-columns: 1fr 2fr; gap: 12px;">
          <div>
            <label>은행명</label>
            <select id="bankName" class="form-control" style="width:100%; padding:10px; border:1px solid var(--border); border-radius:8px; outline: none;">
              <option value="" disabled ${empty partnerInfo.bankName ? 'selected' : ''}>은행을 선택해주세요</option>
              <option value="국민" ${partnerInfo.bankName == '국민' ? 'selected' : ''}>KB국민은행</option>
              <option value="신한" ${partnerInfo.bankName == '신한' ? 'selected' : ''}>신한은행</option>
              <option value="우리" ${partnerInfo.bankName == '우리' ? 'selected' : ''}>우리은행</option>
              <option value="하나" ${partnerInfo.bankName == '하나' ? 'selected' : ''}>하나은행</option>
              <option value="농협" ${partnerInfo.bankName == '농협' ? 'selected' : ''}>NH협은행</option>
              <option value="기업" ${partnerInfo.bankName == '기업' ? 'selected' : ''}>IBK기업은행</option>
              <option value="SC제일" ${partnerInfo.bankName == 'SC제일' ? 'selected' : ''}>SC제일은행</option>
              <option value="씨티" ${partnerInfo.bankName == '씨티' ? 'selected' : ''}>한국씨티은행</option>
              <option value="수협" ${partnerInfo.bankName == '수협' ? 'selected' : ''}>Sh수협은행</option>
              <option value="카카오뱅크" ${partnerInfo.bankName == '카카오뱅크' ? 'selected' : ''}>카카오뱅크</option>
              <option value="토스뱅크" ${partnerInfo.bankName == '토스뱅크' ? 'selected' : ''}>토스뱅크</option>
              <option value="케이뱅크" ${partnerInfo.bankName == '케이뱅크' ? 'selected' : ''}>케이뱅크</option>
              <option value="대구" ${partnerInfo.bankName == '대구' ? 'selected' : ''}>DGB대구은행</option>
              <option value="부산" ${partnerInfo.bankName == '부산' ? 'selected' : ''}>BNK부산은행</option>
              <option value="경남" ${partnerInfo.bankName == '경남' ? 'selected' : ''}>BNK경남은행</option>
              <option value="광주" ${partnerInfo.bankName == '광주' ? 'selected' : ''}>광주은행</option>
              <option value="전북" ${partnerInfo.bankName == '전북' ? 'selected' : ''}>전북은행</option>
              <option value="제주" ${partnerInfo.bankName == '제주' ? 'selected' : ''}>제주은행</option>
              <option value="새마을" ${partnerInfo.bankName == '새마을' ? 'selected' : ''}>새마을금고</option>
              <option value="우체국" ${partnerInfo.bankName == '우체국' ? 'selected' : ''}>우체국예금</option>
              <option value="신협" ${partnerInfo.bankName == '신협' ? 'selected' : ''}>신협</option>
              <option value="저축은행" ${partnerInfo.bankName == '저축은행' ? 'selected' : ''}>저축은행</option>
            </select>
          </div>
          <div>
            <label>계좌번호 ( - 제외)</label>
            <input type="text" id="accountNumber" class="form-control" value="${partnerInfo.accountNumber}" style="width:100%; padding:10px; border:1px solid var(--border); border-radius:8px;">
          </div>
        </div>
      </div>
    </div>

    <div class="card" style="margin-bottom: 0;">
      <h2 style="font-size: 16px; font-weight: 800; margin-bottom: 20px;">📢 숙소 소개글 (플랫폼 노출)</h2>
      <div>
        <label>공간 소개 및 컨셉</label>
        <textarea id="partnerIntro" class="form-control" style="width:100%; height:300px; padding:12px; border:1px solid var(--border); border-radius:8px; resize:none;">${partnerInfo.partnerIntro}</textarea>
      </div>
    </div>
  </div>
</div>