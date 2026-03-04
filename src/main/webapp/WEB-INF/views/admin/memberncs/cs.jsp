<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<jsp:include page="../layout/header.jsp" />

<main class="admin-section">
    <div class="feed-header reveal active">
        <div>
            <h2 style="font-size: 28px; font-weight: 900; margin-bottom: 8px;">1:1 문의 관리 💬</h2>
            <p style="font-size: 15px; font-weight: 600; color: var(--text-dark);">회원들이 남긴 문의를 확인하고 답변을 작성합니다.</p>
        </div>
    </div>

    <div class="admin-filter reveal active delay-100">
        <select name="inquiryType">
            <option value="ALL">문의 유형 전체</option>
            <option value="PAYMENT">결제/환불</option>
            <option value="ACCOUNT">계정/로그인</option>
            <option value="SERVICE">서비스 이용</option>
            <option value="PARTNER">입점 문의</option>
        </select>
        <select name="replyStatus">
            <option value="ALL">처리 상태 전체</option>
            <option value="WAITING">답변 대기</option>
            <option value="COMPLETED">답변 완료</option>
        </select>
        <input type="text" placeholder="작성자 ID 또는 제목 검색" style="flex: 1;">
        <button class="btn-more" style="background: var(--text-black); color: white;">조회하기</button>
    </div>

    <div class="reveal active delay-200">
        <table class="data-table">
            <thead>
                <tr>
                    <th>NO</th>
                    <th>유형</th>
                    <th>제목</th>
                    <th>작성자</th>
                    <th>작성일</th>
                    <th>상태</th>
                    <th>관리</th>
                </tr>
            </thead>
            <tbody>
                <tr>
                    <td>1042</td>
                    <td>결제/환불</td>
                    <td style="font-weight: 700;">숙소 예약 취소했는데 환불이 안 들어와요</td>
                    <td>user_123</td>
                    <td>2026-03-03</td>
                    <td><span class="status-badge" style="background: var(--point-coral); color: white;">답변 대기</span></td>
                    <td><button class="btn-action">답변하기</button></td>
                </tr>
                <tr>
                    <td>1041</td>
                    <td>입점 문의</td>
                    <td style="font-weight: 700;">제주도 펜션 입점 신청 진행상황 문의드립니다.</td>
                    <td>jeju_stay</td>
                    <td>2026-03-02</td>
                    <td><span class="status-badge status-active">답변 완료</span></td>
                    <td><button class="btn-action">상세보기</button></td>
                </tr>
            </tbody>
        </table>
    </div>
</main>

<jsp:include page="../layout/footer.jsp" />