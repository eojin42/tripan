<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<div id="tab-new_apply" class="page-section ${activeTab == 'new_apply' ? 'active' : ''}">
    <div class="page-header" style="margin-bottom: 30px;">
        <h1>새 숙소 추가 신청</h1>
        <p>추가 숙소 등록을 위해서는 사업자등록증 및 증빙 서류 제출이 필요합니다.<br>
        제출된 서류는 관리자 심사를 거치며, 승인 후 좌측 상단 [숙소 전환] 메뉴를 통해 관리할 수 있습니다.</p>
    </div>

    <div class="card" style="padding: 40px; width: 100%;">
        <form action="${pageContext.request.contextPath}/partner/apply" method="POST" enctype="multipart/form-data" id="newApplyForm">
            <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 50px;">
                <div>
                    <h4 style="font-size: 15px; font-weight: 900; color: var(--primary); margin-bottom: 20px; border-bottom: 2px solid #eee; padding-bottom: 10px;">담당자 및 사업자 정보</h4>
                    <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 16px; margin-bottom: 20px;">
                        <div>
                            <label style="display:block; font-size:13px; font-weight:700; margin-bottom:8px;">담당자 성함 <span style="color:var(--danger);">*</span></label>
                            <input type="text" name="contactName" class="form-control" value="${loginUser.nickname}" required style="width:100%; padding:12px; border:1px solid var(--border); border-radius:10px; outline:none;">
                        </div>
                        <div>
                            <label style="display:block; font-size:13px; font-weight:700; margin-bottom:8px;">연락처 <span style="color:var(--danger);">*</span></label>
                            <input type="tel" name="contactPhone" class="form-control" placeholder="'-' 제외" required style="width:100%; padding:12px; border:1px solid var(--border); border-radius:10px; outline:none;">
                        </div>
                    </div>
                    <div style="margin-bottom: 20px;">
                        <label style="display:block; font-size:13px; font-weight:700; margin-bottom:8px;">이메일 주소 <span style="color:var(--danger);">*</span></label>
                        <input type="email" name="contactEmail" class="form-control" placeholder="예: admin@stay.com" required style="width:100%; padding:12px; border:1px solid var(--border); border-radius:10px; outline:none;">
                    </div>
                    <div style="margin-bottom: 40px;">
                        <label style="display:block; font-size:13px; font-weight:700; margin-bottom:8px;">사업자등록번호 <span style="color:var(--danger);">*</span></label>
                        <input type="text" name="businessNumber" class="form-control" placeholder="예: 123-45-67890" required style="width:100%; padding:12px; border:1px solid var(--border); border-radius:10px; outline:none;">
                    </div>

                    <h4 style="font-size: 15px; font-weight: 900; color: var(--primary); margin-bottom: 20px; border-bottom: 2px solid #eee; padding-bottom: 10px;">증빙 서류 제출</h4>
                    <div>
                        <label style="display:block; font-size:13px; font-weight:700; margin-bottom:8px;">서류 첨부 (PDF, 이미지) <span style="color:var(--danger);">*</span></label>
                        <input type="file" name="bizLicenseFiles" id="newApplyFiles" multiple required style="width:100%; font-size: 14px; padding: 16px; background: #F8FAFC; border: 1px dashed var(--border); border-radius: 10px;">
                    </div>
                </div>

                <div>
                    <h4 style="font-size: 15px; font-weight: 900; color: var(--primary); margin-bottom: 20px; border-bottom: 2px solid #eee; padding-bottom: 10px;">스테이 정보</h4>
                    <div style="margin-bottom: 20px;">
                        <label style="display:block; font-size:13px; font-weight:700; margin-bottom:8px;">새 숙소 이름 (가칭) <span style="color:var(--danger);">*</span></label>
                        <input type="text" name="partnerName" class="form-control" placeholder="예: 쌍용스테이 해운대점" required style="width:100%; padding:12px; border:1px solid var(--border); border-radius:10px; outline:none;">
                    </div>
                    <div style="margin-bottom: 20px;">
                        <label style="display:block; font-size:13px; font-weight:700; margin-bottom:8px;">숙박업 운영 경험 유무 <span style="color:var(--danger);">*</span></label>
                        <div style="display: flex; gap: 30px; padding: 10px 0;">
                            <label style="cursor: pointer; font-size: 14px; font-weight: 600; display:flex; align-items:center; gap:8px;">
                                <input type="radio" name="expStatus" value="Y" required style="accent-color: var(--primary); width:18px; height:18px;"> 있음
                            </label>
                            <label style="cursor: pointer; font-size: 14px; font-weight: 600; display:flex; align-items:center; gap:8px;">
                                <input type="radio" name="expStatus" value="N" required style="accent-color: var(--primary); width:18px; height:18px;"> 없음
                            </label>
                        </div>
                    </div>
                    <div style="margin-bottom: 0;">
                        <label style="display:block; font-size:13px; font-weight:700; margin-bottom:8px;">새 공간 소개 <span style="color:var(--danger);">*</span></label>
                        <textarea name="partnerIntro" class="form-control" style="width:100%; height:230px; padding:16px; font-size:14px; line-height:1.6; border:1px solid var(--border); border-radius:10px; outline:none; resize:none;" placeholder="공간의 컨셉과 스토리를 들려주세요. &#13;&#10;스테이를 소개할 SNS나 홈페이지 정보를 입력해 주어도 좋아요. (최소 50자) " required></textarea>
                    </div>
                </div>
            </div>

            <div style="margin-top: 40px; border-top: 1px dashed #E2E8F0; padding-top: 30px;">
                <button type="submit" class="btn btn-primary" style="width: 100%; padding: 18px; justify-content: center; font-weight: 900; font-size: 17px; border-radius: 12px; box-shadow: 0 4px 12px rgba(59,110,248,0.2); transition: 0.2s;">
                    신청서 제출하기 ✨
                </button>
            </div>
        </form>
    </div>
</div>