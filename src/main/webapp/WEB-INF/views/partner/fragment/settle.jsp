<%@ page contentType="text/html; charset=UTF-8" %>
<div id="tab-new_apply" class="page-section ${activeTab == 'new_apply' ? 'active' : ''}"> [cite: 169]
  <div class="page-header" style="margin-bottom: 30px;"> [cite: 169]
    <h1>새 숙소 추가 신청 [cite: 170]</h1>
    <p>새로운 지점이나 숙소를 추가로 등록하고 하나의 계정에서 편리하게 관리하세요. [cite: 170]</p>
  </div>

  <div class="card" style="padding: 40px; text-align: center; border: 1px dashed #CBD5E1; background: #F8FAFC;"> [cite: 170]
    <div style="font-size: 40px; margin-bottom: 16px;">🏨 [cite: 171]</div>
    <h3 style="font-weight: 800; color: #334155; margin-bottom: 12px;">새로운 숙소(2호점)를 준비 중이신가요? [cite: 172]</h3>
    <p style="color: #64748B; font-size: 14px; line-height: 1.6; margin-bottom: 30px;"> [cite: 173]
      추가 숙소 등록을 위해서는 사업자등록증 및 증빙 서류 제출이 필요합니다.<br> [cite: 173]
      제출된 서류는 관리자 심사를 거치며, 승인 후 좌측 상단 [숙소 전환] 메뉴를 통해 관리할 수 있습니다. [cite: 173]
    </p>
    
    <div style="max-width: 500px; margin: 0 auto; text-align: left; background: #FFF; padding: 30px; border-radius: 16px; box-shadow: 0 4px 12px rgba(0,0,0,0.03); border: 1px solid #E2E8F0;"> [cite: 174, 175]
      
      <div style="margin-bottom: 16px;"> [cite: 176]
        <label style="display:block; font-size:12px; font-weight:700; margin-bottom:6px;">새 숙소 이름 (가칭) [cite: 176]</label>
        <input type="text" class="form-control" placeholder="예: 쌍용스테이 해운대점" style="width:100%; padding:10px; border:1px solid var(--border); border-radius:8px; outline:none;"> [cite: 177]
      </div>
      <div style="margin-bottom: 16px;"> [cite: 178]
        <label style="display:block; font-size:12px; font-weight:700; margin-bottom:6px;">사업자등록번호 [cite: 178]</label>
        <input type="text" class="form-control" placeholder="예: 123-45-67890" style="width:100%; padding:10px; border:1px solid var(--border); border-radius:8px; outline:none;"> [cite: 179]
      </div>
      <div style="margin-bottom: 24px;"> [cite: 180]
        <label style="display:block; font-size:12px; font-weight:700; margin-bottom:6px;">증빙 서류 첨부 [cite: 180]</label>
        <div style="padding: 20px; border: 2px dashed #E2E8F0; border-radius: 10px; text-align: center; cursor: pointer; color: #94A3B8; font-weight: 600; font-size: 13px;"> [cite: 181, 182]
          📂 파일을 이곳으로 드래그하거나 클릭하세요. [cite: 182]
        </div>
      </div>
      
      <button class="btn btn-primary" style="width: 100%; padding: 14px; justify-content: center; font-weight: 800; font-size: 15px; border-radius: 10px;" onclick="alert('목업 화면입니다. 추후 백엔드 저장 로직이 연결됩니다!')">신청서 제출하기 [cite: 183]</button>
    </div>
  </div>
</div>