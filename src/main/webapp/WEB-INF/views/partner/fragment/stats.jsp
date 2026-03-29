<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<style>
    .stats-header-container { display: flex; justify-content: space-between; align-items: flex-end; margin-bottom: 24px; }
    .stats-title { font-size: 26px; font-weight: 900; color: var(--text-black); letter-spacing: -0.5px; margin: 0; }
    .stats-subtitle { color: var(--text-gray); margin-top: 8px; font-weight: 500; margin-bottom: 0; }
    
    .stats-filter-card { padding: 20px 24px; border-radius: 16px; margin-bottom: 24px; background: #F8FAFC; border: 1px solid #E2E8F0; display: flex; align-items: center; gap: 16px; }
    .filter-input { padding: 10px 16px; border: 1px solid #CBD5E1; border-radius: 8px; font-size: 14px; color: #334155; background: white; font-family: inherit; font-weight: 700; cursor: pointer; }
    .filter-input:focus { outline: none; border-color: #0F172A; box-shadow: 0 0 0 3px rgba(15, 23, 42, 0.05); }
    
    .btn-month-move { padding: 10px 16px; border: 1px solid #CBD5E1; border-radius: 8px; background: white; cursor: pointer; color: #475569; font-weight: 900; transition: background 0.2s; display: flex; align-items: center; justify-content: center; }
    .btn-month-move:hover { background: #E2E8F0; color: #0F172A; }
    .btn-month-current { background: #F1F5F9; color: #0F172A; border-color: #CBD5E1; } 

    .stats-kpi-grid { display: grid; grid-template-columns: repeat(2, 1fr); gap: 16px; margin-bottom: 24px; }
    .stats-kpi-card { padding: 24px; border-radius: 16px; border: 1px solid #E2E8F0; background: #FFFFFF; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05); display: flex; justify-content: space-between; align-items: center; }
    .kpi-title { font-size: 14px; font-weight: 700; color: #64748B; margin-bottom: 8px; }
    .kpi-value { font-size: 32px; font-weight: 900; color: #0F172A; font-family: 'Sora', sans-serif; }
    .kpi-icon { font-size: 40px; opacity: 0.2; }

    .chart-grid { display: grid; grid-template-columns: 2fr 1fr; gap: 24px; }
    .chart-card { padding: 24px; border-radius: 16px; border: 1px solid #E2E8F0; background: #FFFFFF; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05); }
    .chart-title { font-size: 16px; font-weight: 800; color: #1E293B; margin-top: 0; margin-bottom: 20px; }
    .chart-container { position: relative; height: 300px; width: 100%; }
</style>

<div id="tab-stats" class="page-section ${activeTab == 'stats' ? 'active' : ''}">
    
    <div class="stats-header-container">
        <div>
            <h1 class="stats-title">📈 매출 통계</h1>
            <p class="stats-subtitle">기간별, 객실별 매출 데이터를 시각적으로 분석합니다.</p>
        </div>
    </div>

    <div class="stats-filter-card">
        <label style="font-weight: 800; color: #334155; font-size: 15px;">조회 연월</label>
        <div style="display: flex; align-items: center; gap: 8px;">
            <button type="button" class="btn-month-move" onclick="moveMonth(-1)">◀ 이전</button>
            <input type="month" id="statsMonthPicker" class="filter-input" onchange="fetchStatsData()">
            <button type="button" class="btn-month-move" onclick="moveMonth(1)">다음 ▶</button>
            <button type="button" class="btn-month-move btn-month-current" onclick="moveToCurrentMonth()">이번 달</button>
        </div>
        <button type="button" onclick="fetchStatsData()" style="padding: 10px 24px; background: #1E293B; color: white; border: none; border-radius: 8px; font-weight: 800; cursor: pointer; margin-left: 8px;">조회</button>
    </div>

    <div class="stats-kpi-grid">
        <div class="stats-kpi-card">
            <div>
                <div class="kpi-title">해당 월 총 매출</div>
                <div class="kpi-value" id="kpiTotalSales">₩ 0</div>
            </div>
            <div class="kpi-icon">💰</div>
        </div>
        <div class="stats-kpi-card">
            <div>
                <div class="kpi-title">해당 월 총 예약 건수</div>
                <div class="kpi-value" id="kpiTotalCount">0 건</div>
            </div>
            <div class="kpi-icon">🛎️</div>
        </div>
    </div>

    <div class="chart-grid">
        <div class="chart-card">
            <h3 class="chart-title">일별 매출 추이</h3>
            <div class="chart-container">
                <canvas id="dailySalesChart"></canvas>
            </div>
        </div>

        <div class="chart-card">
            <h3 class="chart-title">객실별 매출 비중</h3>
            <div class="chart-container">
                <canvas id="roomSalesChart"></canvas>
            </div>
        </div>
    </div>

</div>

<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

<script>
    const CONTEXT_PATH = '${pageContext.request.contextPath}';
    
    const formatMoney = (num) => new Intl.NumberFormat('ko-KR').format(num);

    let dailySalesChartInstance = null;
    let roomSalesChartInstance = null;

    // 페이지 로드 시 이번 달로 세팅
    document.addEventListener("DOMContentLoaded", function() {
        moveToCurrentMonth();
    });

    // 이번 달로 차트 새로고침하는 함수
    function moveToCurrentMonth() {
        const today = new Date();
        const monthVal = today.getFullYear() + '-' + String(today.getMonth() + 1).padStart(2, '0');
        document.getElementById('statsMonthPicker').value = monthVal;
        
        fetchStatsData();
    }

    // 이전 달, 다음 달 이동 함수
    function moveMonth(offset) {
        const picker = document.getElementById('statsMonthPicker');
        if (!picker.value) return;

        let date = new Date(picker.value + '-01');
        date.setMonth(date.getMonth() + offset);

        const year = date.getFullYear();
        const month = String(date.getMonth() + 1).padStart(2, '0');
        picker.value = year + '-' + month;

        fetchStatsData();
    }

    function fetchStatsData() {
        const selectedMonth = document.getElementById('statsMonthPicker').value;
        if(!selectedMonth) return;

        fetch(CONTEXT_PATH + '/partner/api/stats/data?month=' + selectedMonth)
            .then(response => response.json())
            .then(data => {
                document.getElementById('kpiTotalSales').innerText = '₩ ' + formatMoney(data.totalSales || 0);
                document.getElementById('kpiTotalCount').innerText = (data.totalCount || 0) + ' 건';

                renderDailyChart(data.dailyLabels, data.dailyValues);
                renderRoomChart(data.roomLabels, data.roomValues);
            })
            .catch(error => {
                console.error("통계 데이터를 불러오지 못했습니다:", error);
                renderDailyChart([], []);
                renderRoomChart([], []);
            });
    }

    function renderDailyChart(labels, values) {
        const ctx = document.getElementById('dailySalesChart').getContext('2d');
        
        if (dailySalesChartInstance) {
            dailySalesChartInstance.destroy();
        }

        dailySalesChartInstance = new Chart(ctx, {
            type: 'line',
            data: {
                labels: labels || [],
                datasets: [{
                    label: '일일 매출액 (원)',
                    data: values || [],
                    borderColor: '#6366F1',
                    backgroundColor: 'rgba(99, 102, 241, 0.1)',
                    borderWidth: 3,
                    pointBackgroundColor: '#FFFFFF',
                    pointBorderColor: '#6366F1',
                    pointBorderWidth: 2,
                    pointRadius: 4,
                    fill: true,
                    tension: 0.4
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: { display: false } 
                },
                scales: {
                    y: { beginAtZero: true, ticks: { callback: function(value) { return formatMoney(value); } } }
                }
            }
        });
    }

    function renderRoomChart(labels, values) {
        const ctx = document.getElementById('roomSalesChart').getContext('2d');
        
        if (roomSalesChartInstance) {
            roomSalesChartInstance.destroy();
        }

        const bgColors = ['#3B82F6', '#10B981', '#F59E0B', '#EF4444', '#8B5CF6', '#64748B'];

        roomSalesChartInstance = new Chart(ctx, {
            type: 'doughnut',
            data: {
                labels: labels || [],
                datasets: [{
                    data: values || [],
                    backgroundColor: bgColors,
                    borderWidth: 0,
                    hoverOffset: 4
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                cutout: '70%', 
                plugins: {
                    legend: { position: 'bottom', labels: { boxWidth: 12, font: {size: 11} } }
                }
            }
        });
    }
</script>