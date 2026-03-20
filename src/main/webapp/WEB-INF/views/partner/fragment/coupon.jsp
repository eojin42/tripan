<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<div id="tab-coupon" class="page-section ${activeTab == 'coupon' ? 'active' : ''}">
    <div class="page-header" style="display:flex; justify-content:space-between; align-items:flex-end;">
        <div>
            <h1>쿠폰 마케팅</h1>
            <p>우리 숙소 전용 할인 쿠폰을 직접 발행하고 관리하여 예약률을 높여보세요.</p>
        </div>
        <button class="btn btn-primary" onclick="openCouponModal()">+ 새 쿠폰 발행</button>
    </div>

    <div class="kpi-grid" style="grid-template-columns: repeat(3, 1fr);">
        <div class="card" style="padding: 20px; margin-bottom: 0;">
            <div class="kpi-label">발급 진행 중인 쿠폰</div>
            <div class="kpi-value" style="color: var(--primary);">2건</div>
        </div>
        <div class="card" style="padding: 20px; margin-bottom: 0;">
            <div class="kpi-label">이번 달 누적 다운로드</div>
            <div class="kpi-value">145건</div>
        </div>
        <div class="card" style="padding: 20px; margin-bottom: 0;">
            <div class="kpi-label">이번 달 실제 사용(결제)</div>
            <div class="kpi-value" style="color: #10B981;">32건</div>
        </div>
    </div>

    <div class="card" style="padding: 0; overflow: hidden; margin-top: 24px;">
        <table>
            <thead style="background: #F8FAFC;">
                <tr>
                    <th style="padding-left: 24px;">쿠폰명</th>
                    <th>할인 혜택</th>
                    <th>사용 조건</th>
                    <th>유효 기간</th>
                    <th>상태</th>
                    <th style="text-align: center; padding-right: 24px;">관리</th>
                </tr>
            </thead>
            <tbody>
                <tr>
                    <td style="padding-left: 24px; font-weight: 800;">🍂 가을 맞이 깜짝 할인</td>
                    <td><span style="color: var(--danger); font-weight: 900; font-family:'Sora', sans-serif;">₩ 5,000</span></td>
                    <td style="color: var(--muted); font-size: 12px;">50,000원 이상 결제 시</td>
                    <td style="font-size: 12px; font-weight: 700;">26.09.01 ~ 26.10.31</td>
                    <td><span class="badge badge-done">발급중</span></td>
                    <td style="text-align: center; padding-right: 24px;">
                        <button class="btn btn-ghost" style="padding: 4px 10px; font-size: 11px;">발급 중지</button>
                    </td>
                </tr>
                <tr>
                    <td style="padding-left: 24px; font-weight: 800;">🌊 오션뷰 객실 프로모션</td>
                    <td>
                        <span style="color: var(--danger); font-weight: 900; font-family:'Sora', sans-serif;">10%</span>
                        <span style="font-size:11px; color:var(--muted);">(최대 2만원)</span>
                    </td>
                    <td style="color: var(--muted); font-size: 12px;">조건 없음</td>
                    <td style="font-size: 12px; font-weight: 700;">26.10.01 ~ 26.12.31</td>
                    <td><span class="badge badge-done">발급중</span></td>
                    <td style="text-align: center; padding-right: 24px;">
                        <button class="btn btn-ghost" style="padding: 4px 10px; font-size: 11px;">발급 중지</button>
                    </td>
                </tr>
                <tr>
                    <td style="padding-left: 24px; font-weight: 700; color: var(--muted);">🏖️ 여름 성수기 얼리버드</td>
                    <td style="color: var(--muted); font-family:'Sora', sans-serif;">₩ 10,000</td>
                    <td style="color: var(--muted); font-size: 12px;">100,000원 이상 결제 시</td>
                    <td style="color: var(--muted); font-size: 12px;">26.06.01 ~ 26.08.31</td>
                    <td><span class="badge" style="background:#F1F5F9; color:#64748B;">기간만료</span></td>
                    <td style="text-align: center; padding-right: 24px;">
                        <button class="btn btn-ghost" style="padding: 4px 10px; font-size: 11px; text-decoration: line-through;" disabled>종료됨</button>
                    </td>
                </tr>
            </tbody>
        </table>
    </div>
</div>