document.addEventListener('DOMContentLoaded', function() {
    const calendarEl = document.getElementById('calendar');
    if (!calendarEl) return;

    const calendar = new FullCalendar.Calendar(calendarEl, {
        initialView: 'dayGridMonth',
        locale: 'ko',
        height: 700,
        headerToolbar: {
            left: 'prev,next today',
            center: 'title',
            right: 'dayGridMonth,dayGridWeek'
        },

        events: function(info, successCallback, failureCallback) {

			            fetch(`/partner/api/calendar/events?start=${info.startStr}&end=${info.endStr}`)
                .then(response => response.json())
                .then(data => {
                    successCallback(data); 
                })
                .catch(error => {
                    console.error('달력 데이터를 불러오는데 실패했습니다.', error);
                    failureCallback(error);
                });
        },

        dateClick: function(info) {
            console.log('선택한 날짜: ' + info.dateStr);
        },
		eventClick: function(info) {
		            const props = info.event.extendedProps;

		            document.getElementById('modalTitle').innerText = info.event.title; 
		            
		            let endStr = info.event.endStr;
		            if(!endStr) endStr = info.event.startStr; 
		            document.getElementById('modalDate').innerText = info.event.startStr + " ~ " + endStr;
		            
		            document.getElementById('modalGuest').innerText = props.guestCount;
		            document.getElementById('modalAmount').innerText = Number(props.amount).toLocaleString(); 
		            
		            document.getElementById('modalRequest').innerText = props.request;
		            document.getElementById('modalStatus').innerText = (props.status === 'SUCCESS') ? "✅ 예약 완료" : "❌ 취소됨";
		            if(props.status === 'CANCELED') document.getElementById('modalStatus').style.color = "red";
		            else document.getElementById('modalStatus').style.color = "green";

		            document.getElementById('reservationDetailModal').style.display = 'flex';
		        }
    });

    calendar.render();
});