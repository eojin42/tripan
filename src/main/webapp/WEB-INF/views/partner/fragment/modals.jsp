<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<div class="modal-overlay" id="roomModal" style="position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.5); backdrop-filter: blur(2px); z-index: 9999; display: none; align-items: center; justify-content: center;">
    <div class="modal-content" style="width: 600px; max-height: 90vh; overflow-y: auto; background: white; border-radius: 16px; padding: 24px; box-shadow: 0 10px 25px rgba(0,0,0,0.1);">
        <div class="modal-header" style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 24px;">
            <div>
                <h2 style="margin: 0; font-size: 20px; font-weight: 800;">🛏️ 새 객실 등록</h2>
                <p style="font-size: 13px; color: var(--muted); margin: 4px 0 0;">판매하실 객실의 상세 정보를 입력해주세요.</p>
            </div>
            <button onclick="closeRoomModal()" style="background: none; border: none; font-size: 24px; cursor: pointer; color: #8B92A5;">✕</button>
        </div>

        <div class="modal-body">
            <form id="roomForm">
                <div style="margin-bottom: 16px;">
                    <label style="display:block; font-size:12px; font-weight:700; margin-bottom:6px;">객실 이름 (room_name)</label>
                    <input type="text" id="roomName" class="form-control" placeholder="예: 오션뷰 스위트룸" style="width:100%; padding:10px; border:1px solid var(--border); border-radius:8px; outline:none;">
                </div>

                <div style="display:grid; grid-template-columns: 1fr 1fr; gap:16px; margin-bottom: 16px;">
                    <div>
                        <label style="display:block; font-size:12px; font-weight:700; margin-bottom:6px;">기준 인원 (roombasecount)</label>
                        <input type="number" id="roombasecount" class="form-control" value="2" style="width:100%; padding:10px; border:1px solid var(--border); border-radius:8px; outline:none;">
                    </div>
                    <div>
                        <label style="display:block; font-size:12px; font-weight:700; margin-bottom:6px;">최대 인원 (max_capacity)</label>
                        <input type="number" id="maxCapacity" class="form-control" value="4" style="width:100%; padding:10px; border:1px solid var(--border); border-radius:8px; outline:none;">
                    </div>
                </div>

                <div style="display:grid; grid-template-columns: 1fr 1fr; gap:16px; margin-bottom: 24px;">
                    <div>
                        <label style="display:block; font-size:12px; font-weight:700; margin-bottom:6px;">보유 객실 수 (room_count)</label>
                        <input type="number" id="roomCount" class="form-control" value="10" style="width:100%; padding:10px; border:1px solid var(--border); border-radius:8px; outline:none;">
                    </div>
                    <div>
                        <label style="display:block; font-size:12px; font-weight:700; margin-bottom:6px;">기본 요금 (amount)</label>
                        <input type="number" id="amount" class="form-control" placeholder="예: 150000" style="width:100%; padding:10px; border:1px solid var(--border); border-radius:8px; outline:none;">
                    </div>
                </div>

                <div style="margin-bottom: 16px;">
                    <label style="display:block; font-size:12px; font-weight:700; margin-bottom:6px;">객실 소개 (roomintro)</label>
                    <textarea id="roomintro" class="form-control" placeholder="객실에 대한 상세한 설명을 적어주세요." style="width:100%; height:80px; padding:10px; border:1px solid var(--border); border-radius:8px; resize:none; outline:none;"></textarea>
                </div>

                <div style="margin-bottom: 24px; padding: 16px; background: #F8FAFC; border-radius: 8px; border: 1px dashed #CBD5E1;">
                    <label style="display:block; font-size:12px; font-weight:800; margin-bottom:8px; color: var(--primary);">📸 객실 사진 등록 (여러 장 선택 가능)</label>
                    <input type="file" id="roomImages" name="images" multiple accept="image/*" style="width:100%; font-size: 13px;">
                    <p style="font-size: 11px; color: var(--muted); margin-top: 6px;">* Ctrl(또는 Shift) 키를 누른 채 여러 장의 사진을 선택하세요.</p>
                </div>

                <div style="display: flex; gap: 10px; justify-content: flex-end;">
                    <button type="button" class="btn btn-ghost" onclick="closeRoomModal()">취소</button>
                    <button type="button" class="btn btn-primary" onclick="saveRoom()">저장하기</button>
                </div>
            </form>
        </div>
    </div>
</div>

<div class="modal-overlay" id="cancelModal" style="position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.5); backdrop-filter: blur(2px); z-index: 9999; display: none; align-items: center; justify-content: center;">
    <div class="modal-content" style="width: 400px; background: white; border-radius: 16px; padding: 24px;">
        <h2 style="margin: 0 0 10px 0; font-size: 18px; color: var(--danger);">🚨 예약 강제 취소</h2>
        <p style="font-size: 13px; color: var(--muted); margin-bottom: 20px;">부득이한 사유로 예약을 취소합니다. 고객에게 알림이 발송됩니다.</p>
        <textarea id="cancelReason" class="form-control" placeholder="취소 사유를 입력해주세요." style="width: 100%; height: 80px; padding: 10px; border: 1px solid var(--border); border-radius: 8px; resize: none; outline: none; margin-bottom: 20px;"></textarea>
        <div style="display: flex; gap: 10px; justify-content: flex-end;">
            <button class="btn btn-ghost" onclick="closeCancelModal()">닫기</button>
            <button class="btn btn-primary" style="background: var(--danger);" onclick="submitCancel()">취소 확정</button>
        </div>
    </div>
</div>

<div class="modal-overlay" id="couponModal">
    <div class="modal-content" style="width: 500px;">
        <div class="modal-header">
            <h2 style="margin-top: 0;">🎫 새 쿠폰 발행</h2>
            <p style="font-size: 13px; color: var(--muted); margin-bottom: 24px;">우리 숙소 고객들에게 제공할 혜택을 설정하세요.</p>
        </div>
        <div class="modal-body">
            <form id="couponForm">
                <div style="margin-bottom: 16px;">
                    <label style="display:block; font-size:12px; font-weight:700; margin-bottom:6px;">쿠폰 이름 (coupon_name)</label>
                    <input type="text" class="form-control" placeholder="예: 겨울 맞이 5천원 할인" style="width:100%; padding:10px; border:1px solid var(--border); border-radius:8px; outline:none;">
                </div>

                <div style="display:grid; grid-template-columns: 1fr 1fr; gap:16px; margin-bottom: 16px;">
                    <div>
                        <label style="display:block; font-size:12px; font-weight:700; margin-bottom:6px;">할인 유형 (discount_type)</label>
                        <select class="form-control" style="width:100%; padding:10px; border:1px solid var(--border); border-radius:8px; outline:none;">
                            <option value="FIXED">정액 할인 (원)</option>
                            <option value="PERCENT">정률 할인 (%)</option>
                        </select>
                    </div>
                    <div>
                        <label style="display:block; font-size:12px; font-weight:700; margin-bottom:6px;">할인 금액/비율</label>
                        <input type="number" class="form-control" placeholder="예: 5000 또는 10" style="width:100%; padding:10px; border:1px solid var(--border); border-radius:8px; outline:none;">
                    </div>
                </div>

                <div style="margin-bottom: 16px;">
                    <label style="display:block; font-size:12px; font-weight:700; margin-bottom:6px;">최소 결제 금액 (min_order_amount)</label>
                    <input type="number" class="form-control" placeholder="예: 50000 (조건 없을 시 0)" style="width:100%; padding:10px; border:1px solid var(--border); border-radius:8px; outline:none;">
                </div>

                <div style="display:grid; grid-template-columns: 1fr 1fr; gap:16px; margin-bottom: 24px;">
                    <div>
                        <label style="display:block; font-size:12px; font-weight:700; margin-bottom:6px;">발급 시작일 (valid_from)</label>
                        <input type="date" class="form-control" style="width:100%; padding:10px; border:1px solid var(--border); border-radius:8px; outline:none;">
                    </div>
                    <div>
                        <label style="display:block; font-size:12px; font-weight:700; margin-bottom:6px;">발급 종료일 (valid_until)</label>
                        <input type="date" class="form-control" style="width:100%; padding:10px; border:1px solid var(--border); border-radius:8px; outline:none;">
                    </div>
                </div>

                <div style="display: flex; gap: 10px; justify-content: flex-end;">
                    <button type="button" class="btn btn-ghost" onclick="closeCouponModal()">취소</button>
                    <button type="button" class="btn btn-primary" onclick="alert('쿠폰이 성공적으로 발행되었습니다!'); closeCouponModal();">발행하기</button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- 객실용 모달 -->
<div id="roomModal" class="modal-overlay" style="display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.5); z-index: 1000; justify-content: center; align-items: center;">
    <div class="modal-content" style="background: #fff; padding: 24px; border-radius: 12px; width: 600px; max-height: 80vh; overflow-y: auto;">
        
        <div style="display: flex; justify-content: space-between; margin-bottom: 16px;">
            <h2 style="font-size: 18px; font-weight: bold;">🛏️ 새 객실 등록</h2>
            <button onclick="closeRoomModal()" style="background: none; border: none; font-size: 20px; cursor: pointer;">&times;</button>
        </div>

        <form id="roomForm">
            <div class="form-group" style="margin-bottom: 12px;">
                <label>객실명</label>
                <input type="text" id="roomName" class="form-control" placeholder="예: 디럭스 오션뷰" required>
            </div>
            
            <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 12px; margin-bottom: 12px;">
                <div class="form-group">
                    <label>기준 인원</label>
                    <input type="number" id="roombasecount" class="form-control" value="2" min="1">
                </div>
                <div class="form-group">
                    <label>최대 인원</label>
                    <input type="number" id="maxCapacity" class="form-control" value="4" min="1">
                </div>
                <div class="form-group">
                    <label>보유 객실 수</label>
                    <input type="number" id="roomCount" class="form-control" value="1" min="1">
                </div>
                <div class="form-group">
                    <label>기본 요금(원)</label>
                    <input type="number" id="amount" class="form-control" placeholder="100000">
                </div>
            </div>

            <div class="form-group" style="margin-bottom: 12px;">
                <label>객실 소개</label>
                <textarea id="roomintro" class="form-control" rows="3" placeholder="객실에 대한 간단한 설명을 적어주세요."></textarea>
            </div>

            <div class="form-group" style="margin-bottom: 16px;">
                <label style="display: block; margin-bottom: 8px;">판매 상태</label>
                <label><input type="radio" name="isActive" value="1" checked> 판매중</label>
                <label style="margin-left: 12px;"><input type="radio" name="isActive" value="0"> 판매중지</label>
            </div>

            <div class="form-group" style="margin-bottom: 16px;">
                <label style="display: block; margin-bottom: 8px;">객실 시설 (다중 선택)</label>
                <div style="display: flex; gap: 12px; flex-wrap: wrap;">
                    <label><input type="checkbox" name="facility" value="roomaircondition"> 에어컨</label>
                    <label><input type="checkbox" name="facility" value="roomtv"> TV</label>
                    <label><input type="checkbox" name="facility" value="roominternet"> 와이파이</label>
                    <label><input type="checkbox" name="facility" value="roombath"> 욕조</label>
                    <label><input type="checkbox" name="facility" value="roomrefrigerator"> 냉장고</label>
                </div>
            </div>

            <div class="form-group" style="margin-bottom: 24px;">
                <label>객실 사진 (최대 5장)</label>
                <input type="file" id="roomImages" class="form-control" multiple accept="image/*">
            </div>

            <div style="text-align: right;">
                <button type="button" class="btn btn-ghost" onclick="closeRoomModal()">취소</button>
                <button type="button" class="btn btn-primary" onclick="saveRoom()">등록 완료</button>
            </div>
        </form>
    </div>
</div>

<!-- 객실용 모달 끝-->