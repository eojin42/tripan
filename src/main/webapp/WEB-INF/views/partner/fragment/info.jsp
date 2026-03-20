<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<link href="https://cdn.quilljs.com/1.3.6/quill.snow.css" rel="stylesheet">

<div id="tab-info" class="page-section ${activeTab == 'info' ? 'active' : ''}">
    <div class="page-header" style="display:flex; justify-content:space-between; align-items:flex-end;">
        <div>
            <h1>파트너 정보 관리</h1>
            <p>플랫폼에 노출되는 숙소 소개글과 매월 정산받을 계좌 정보를 관리합니다.</p>
        </div>
        <button class="btn btn-primary" onclick="savePartnerInfo()">변경사항 저장</button>
    </div>

    <div style="display: flex; flex-direction: column; gap: 30px;">
        
        <div class="card" style="margin-bottom: 0;">
            <h2 style="font-size: 16px; font-weight: 800; margin-bottom: 20px;">👤 담당자 및 사업자 정보</h2>

            <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 16px; margin-bottom: 16px;">
                <div>
                    <label>사업장명 (수정 불가)</label>
                    <input type="text" class="form-control" value="${partnerInfo.partnerName}" disabled style="width:100%; padding:10px; border:1px solid var(--border); border-radius:8px; background: #F8FAFC; color: #8B92A5;">
                </div>
                <div>
                    <label>사업자등록번호 (수정 불가)</label>
                    <input type="text" class="form-control" value="${partnerInfo.businessNumber != null ? partnerInfo.businessNumber : '심사중'}" disabled style="width:100%; padding:10px; border:1px solid var(--border); border-radius:8px; background: #F8FAFC; color: #8B92A5;">
                </div>
            </div>

            <div style="display: grid; grid-template-columns: 1fr 1fr 1fr; gap: 16px; margin-bottom: 16px;">
                <div>
                    <label>담당자 이름</label>
                    <input type="text" id="contactName" name="contactName" class="form-control" value="${partnerInfo.contactName}" style="width:100%; padding:10px; border:1px solid var(--border); border-radius:8px;">
                </div>
                <div>
                    <label>담당자 연락처</label>
                    <input type="text" id="contactPhone" name="contactPhone" class="form-control" value="${partnerInfo.contactPhone}" style="width:100%; padding:10px; border:1px solid var(--border); border-radius:8px;">
                </div>
                <div>
                    <label>업종 (숙소 유형)</label>
                    <select id="accommodationType" name="accommodationType" class="form-control" style="width:100%; padding:10px; border:1px solid var(--border); border-radius:8px; outline: none;">
                        <option value="" disabled ${empty partnerInfo.accommodationType ? 'selected' : ''}>숙소 유형 선택</option>
                        <option value="HOTEL" ${partnerInfo.accommodationType == 'HOTEL' ? 'selected' : ''}>호텔/리조트</option>
                        <option value="MOTEL" ${partnerInfo.accommodationType == 'MOTEL' ? 'selected' : ''}>모텔</option>
                        <option value="PENSION" ${partnerInfo.accommodationType == 'PENSION' ? 'selected' : ''}>펜션/풀빌라</option>
                        <option value="GUESTHOUSE" ${partnerInfo.accommodationType == 'GUESTHOUSE' ? 'selected' : ''}>게스트하우스/한옥</option>
                        <option value="CAMPING" ${partnerInfo.accommodationType == 'CAMPING' ? 'selected' : ''}>캠핑/글램핑</option>
                    </select>
                </div>
            </div>
            
            <div style="padding-top: 20px; margin-top: 10px; border-top: 1px dashed var(--border);">
                <h3 style="font-size: 14px; font-weight: 800; margin-bottom: 12px; color: var(--primary);">💰 정산 계좌 정보</h3>
                <div style="display: grid; grid-template-columns: 1fr 2fr; gap: 16px;">
                    <div>
                        <label>은행명</label>
                        <select id="bankName" class="form-control" style="width:100%; padding:10px; border:1px solid var(--border); border-radius:8px; outline: none;">
                            <option value="" disabled ${empty partnerInfo.bankName ? 'selected' : ''}>은행을 선택해주세요</option>
                            <option value="국민" ${partnerInfo.bankName == '국민' ? 'selected' : ''}>KB국민은행</option>
                            <option value="신한" ${partnerInfo.bankName == '신한' ? 'selected' : ''}>신한은행</option>
                            <option value="우리" ${partnerInfo.bankName == '우리' ? 'selected' : ''}>우리은행</option>
                            <option value="하나" ${partnerInfo.bankName == '하나' ? 'selected' : ''}>하나은행</option>
                            <option value="농협" ${partnerInfo.bankName == '농협' ? 'selected' : ''}>NH농협은행</option>
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
                <label style="margin-bottom: 8px; display: inline-block; color: #333; font-weight: 700;">공간 소개 및 컨셉</label>
                
                <div id="partnerIntroEditor" style="height:400px; background:#fff; border-bottom-left-radius:8px; border-bottom-right-radius:8px;">${partnerInfo.partnerIntro}</div>
                
                <input type="hidden" id="partnerIntro" name="partnerIntro" value="<c:out value='${partnerInfo.partnerIntro}' escapeXml='true'/>">
            </div>
        </div>
        
    </div>
</div>

<script src="https://cdn.quilljs.com/1.3.6/quill.min.js"></script>

<script>
    function initPartnerInfoEditor() {
        if (document.getElementById('partnerIntroEditor') && !window.partnerQuill) {
            window.partnerQuill = new Quill('#partnerIntroEditor', {
                theme: 'snow',
                placeholder: '우리 스테이만의 감성과 스토리를 자유롭게 작성해 보세요.',
                modules: {
                    toolbar: [
                        [{ 'header': [1, 2, 3, false] }],
                        ['bold', 'italic', 'underline', 'strike'],
                        [{ 'color': [] }, { 'background': [] }],
                        [{ 'list': 'ordered'}, { 'list': 'bullet' }],
                        ['link', 'image'] 
                    ]
                }
            });

            window.partnerQuill.on('text-change', function() {
                var html = window.partnerQuill.root.innerHTML;
                document.getElementById('partnerIntro').value = (html === '<p><br></p>') ? '' : html;
            });
            
            document.getElementById('partnerIntro').value = window.partnerQuill.root.innerHTML;
        }
    }

    document.addEventListener("DOMContentLoaded", initPartnerInfoEditor);
    initPartnerInfoEditor();
</script>