<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<link href="https://cdn.quilljs.com/1.3.6/quill.snow.css" rel="stylesheet">

<style>
    /* info 탭 전용 폼 스타일 (깨짐 방지용) */
    .info-form-label { display: block; font-size: 12px; font-weight: 800; color: var(--muted); margin-bottom: 8px; }
    .info-form-control { width: 100%; padding: 12px 16px; border: 1px solid var(--border); border-radius: 10px; background: #FFF; font-size: 13px; font-weight: 600; color: var(--text); outline: none; transition: border-color 0.2s, box-shadow 0.2s; }
    .info-form-control:focus { border-color: var(--primary); box-shadow: 0 0 0 3px var(--primary-10); }
    .info-form-control:disabled { background: #F8FAFC; color: #8B92A5; cursor: not-allowed; }
    .info-select { cursor: pointer; appearance: none; -webkit-appearance: none; background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='10' height='6'%3E%3Cpath d='M0 0l5 6 5-6z' fill='%238B92A5'/%3E%3C/svg%3E"); background-repeat: no-repeat; background-position: right 16px center; padding-right: 40px; }
</style>

<div id="tab-info" class="page-section ${activeTab == 'info' ? 'active' : ''}">
    <div class="page-header" style="display:flex; justify-content:space-between; align-items:flex-end;">
        <div>
            <h1>파트너 정보 관리</h1>
            <p>플랫폼에 노출되는 숙소 소개글, 주소, 대표 이미지 등을 관리합니다.</p>
        </div>
        <button class="btn btn-primary" onclick="savePartnerInfo()">변경사항 저장</button>
    </div>

    <form id="partnerInfoForm" enctype="multipart/form-data">
        <div style="display: flex; flex-direction: column; gap: 24px;">
            
            <div class="card" style="margin-bottom: 0;">
                <h2 style="font-size: 16px; font-weight: 800; margin-bottom: 24px;">🏡 숙소 대표 정보</h2>
                
                <div style="display: grid; grid-template-columns: 200px 1fr; gap: 32px; align-items: start;">
                    <div>
                        <label class="info-form-label">대표 썸네일 이미지</label>
                        <div id="imgPreview" style="width: 100%; height: 150px; background: #F8FAFC; border: 1px dashed #CBD5E1; border-radius: 12px; display: flex; align-items: center; justify-content: center; overflow: hidden; cursor: pointer; transition: all 0.2s;" onmouseover="this.style.borderColor='var(--primary)'" onmouseout="this.style.borderColor='#CBD5E1'" onclick="document.getElementById('uploadImage').click()">
                            <c:choose>
                                <c:when test="${not empty partnerInfo.imageUrl}">
                                    <img src="${pageContext.request.contextPath}${partnerInfo.imageUrl}" style="width:100%; height:100%; object-fit:cover;">
                                </c:when>
                                <c:otherwise>
                                    <span style="color:#94A3B8; font-size:13px; font-weight:700;">+ 이미지 등록</span>
                                </c:otherwise>
                            </c:choose>
                        </div>
                        <input type="file" id="uploadImage" name="uploadImage" accept="image/*" style="display:none;" onchange="previewImage(this)">
                    </div>

                    <div>
                        <label class="info-form-label">숙소 주소 (고객 노출용)</label>
                        
                        <input type="hidden" id="realAddress" name="address" value="<c:out value='${partnerInfo.address}'/>">

                        <div style="display: flex; gap: 10px; margin-bottom: 8px;">
                            <input type="text" id="baseAddress" class="info-form-control" value="${partnerInfo.address}" placeholder="버튼을 눌러 주소를 검색하세요" readonly style="flex: 1; cursor: pointer; background: #F8FAFC;" onclick="execDaumPostcode()">
                            <button type="button" class="btn btn-ghost" style="border: 1px solid var(--border); border-radius: 10px; font-size: 13px; font-weight: 700; white-space: nowrap;" onclick="execDaumPostcode()">주소 검색</button>
                        </div>
                        
                        <div style="margin-bottom: 12px;">
                            <input type="text" id="detailAddress" class="info-form-control" placeholder="상세 주소 (건물명, 동, 호수 등)를 입력해 주세요.">
                        </div>

                        <p style="font-size:12px; color:var(--muted); margin:0; font-weight: 600; line-height: 1.4;">
                        </p>
                    </div>
                    
            </div>

            <div class="card" style="margin-bottom: 0;">
                <h2 style="font-size: 16px; font-weight: 800; margin-bottom: 24px;">👤 담당자 및 사업자 정보</h2>
                
                <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 20px; margin-bottom: 20px;">
					<div>
					    <label class="info-form-label">사업장명 (수정 불가)</label>
					    <input type="text" class="info-form-control" value="${partnerInfo.partnerName}" disabled>
					</div>

					<div>
					    <label class="info-form-label">사업장명 (수정 불가)</label>
					    <input type="hidden" name="partnerName" value="${partnerInfo.partnerName}">
					    <input type="text" class="info-form-control" value="${partnerInfo.partnerName}" disabled>
					</div>
					
                    <div>
                        <label class="info-form-label">사업자등록번호 (수정 불가)</label>
                        <input type="text" class="info-form-control" value="${not empty partnerInfo.businessNumber ? partnerInfo.businessNumber : '심사중'}" disabled>
                    </div>
                </div>
                
                <div style="display: grid; grid-template-columns: 1fr 1fr 1fr; gap: 20px; margin-bottom: 20px;">
                    <div>
                        <label class="info-form-label">담당자 이름</label>
                        <input type="text" id="contactName" name="contactName" class="info-form-control" value="${partnerInfo.contactName}">
                    </div>
                    <div>
                        <label class="info-form-label">담당자 연락처</label>
                        <input type="text" id="contactPhone" name="contactPhone" class="info-form-control" value="${partnerInfo.contactPhone}">
                    </div>
                    <div>
                        <label class="info-form-label">업종 (숙소 유형)</label>
                        <select id="accommodationType" name="accommodationType" class="info-form-control info-select">
                            <option value="" disabled ${empty partnerInfo.accommodationType ? 'selected' : ''}>숙소 유형 선택</option>
                            <option value="HOTEL" ${partnerInfo.accommodationType == 'HOTEL' ? 'selected' : ''}>호텔/리조트</option>
                            <option value="MOTEL" ${partnerInfo.accommodationType == 'MOTEL' ? 'selected' : ''}>모텔</option>
                            <option value="PENSION" ${partnerInfo.accommodationType == 'PENSION' ? 'selected' : ''}>펜션/풀빌라</option>
                            <option value="GUESTHOUSE" ${partnerInfo.accommodationType == 'GUESTHOUSE' ? 'selected' : ''}>게스트하우스/한옥</option>
                            <option value="CAMPING" ${partnerInfo.accommodationType == 'CAMPING' ? 'selected' : ''}>캠핑/글램핑</option>
                        </select>
                    </div>
                </div>
                
                <div style="padding-top: 24px; margin-top: 8px; border-top: 1px dashed var(--border);">
                    <h3 style="font-size: 14px; font-weight: 800; margin-bottom: 16px; color: var(--primary);">💰 정산 계좌 정보</h3>
                    <div style="display: grid; grid-template-columns: 1fr 2fr; gap: 20px;">
                        <div>
                            <label class="info-form-label">은행명</label>
                            <select id="bankName" name="bankName" class="info-form-control info-select">
                                <option value="" disabled ${empty partnerInfo.bankName ? 'selected' : ''}>은행 선택</option>
                                <option value="국민" ${partnerInfo.bankName == '국민' ? 'selected' : ''}>KB국민은행</option>
                                <option value="신한" ${partnerInfo.bankName == '신한' ? 'selected' : ''}>신한은행</option>
                                <option value="우리" ${partnerInfo.bankName == '우리' ? 'selected' : ''}>우리은행</option>
                                <option value="하나" ${partnerInfo.bankName == '하나' ? 'selected' : ''}>하나은행</option>
                                <option value="농협" ${partnerInfo.bankName == '농협' ? 'selected' : ''}>NH농협</option>
                                <option value="기업" ${partnerInfo.bankName == '기업' ? 'selected' : ''}>IBK기업은행</option>
                                <option value="카카오뱅크" ${partnerInfo.bankName == '카카오뱅크' ? 'selected' : ''}>카카오뱅크</option>
                                <option value="토스뱅크" ${partnerInfo.bankName == '토스뱅크' ? 'selected' : ''}>토스뱅크</option>
                            </select>
                        </div>
                        <div>
                            <label class="info-form-label">계좌번호 (- 제외)</label>
                            <input type="text" id="accountNumber" name="accountNumber" class="info-form-control" value="${partnerInfo.accountNumber}">
                        </div>
                    </div>
                </div>
            </div>

            <div class="card" style="margin-bottom: 0;">
                <h2 style="font-size: 16px; font-weight: 800; margin-bottom: 20px;">📢 숙소 소개글 (플랫폼 노출)</h2>
                <div>
                    <label class="info-form-label">공간 소개 및 컨셉</label>
                    <div id="partnerIntroEditor" style="height:400px; background:#fff; border-bottom-left-radius:8px; border-bottom-right-radius:8px;">${partnerInfo.partnerIntro}</div>
                    <input type="hidden" id="partnerIntro" name="partnerIntro" value="<c:out value='${partnerInfo.partnerIntro}' escapeXml='true'/>">
                </div>
            </div>
        </div>
    </form>
</div>

<script src="//t1.daumcdn.net/mapjsapi/bundle/postcode/prod/postcode.v2.js"></script>
<script src="https://cdn.quilljs.com/1.3.6/quill.min.js"></script>