<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt"%>
<jsp:include page="/WEB-INF/views/layout/vue_cdn.jsp" /> 
<div id="app" class="container mt-5">
    <h3>🏢 파트너 입점 신청</h3>
    <div class="card p-4">
        <div class="mb-3">
            <label class="form-label">업체명</label>
            <input type="text" class="form-control" v-model="form.partner_name">
        </div>
        <div class="mb-3">
            <label class="form-label">사업자 등록번호</label>
            <input type="text" class="form-control" v-model="form.business_number" placeholder="000-00-00000">
        </div>
        <div class="mb-3 row">
            <div class="col">
                <label class="form-label">담당자명</label>
                <input type="text" class="form-control" v-model="form.contact_name">
            </div>
            <div class="col">
                <label class="form-label">연락처</label>
                <input type="text" class="form-control" v-model="form.contact_phone">
            </div>
        </div>
        <div class="mb-3">
            <label class="form-label">정산 계좌 (은행 및 번호)</label>
            <div class="input-group">
                <input type="text" class="form-control" v-model="form.bank_name" placeholder="은행명">
                <input type="text" class="form-control" v-model="form.account_number" placeholder="계좌번호">
            </div>
        </div>
        <button class="btn btn-primary w-100" @click="submitApply">신청하기</button>
    </div>
</div>

<script type="module">
    import { createApp, ref } from 'vue';
    import axios from 'axios';

    createApp({
        setup() {
            const form = ref({
                partner_name: '',
                business_number: '',
                contact_name: '',
                contact_phone: '',
                bank_name: '',
                account_number: ''
            });

            const submitApply = () => {
                if(!form.value.partner_name) { alert('업체명을 입력하세요.'); return; }
                
                // [cite: 2, 4] 강사님 스타일의 axios 통신
                axios.post('/partner/apply', form.value)
                    .then(res => {
                        alert('신청이 완료되었습니다. 관리자 승인을 기다려주세요!');
                        location.href = '/main';
                    })
                    .catch(err => console.error(err));
            };

            return { form, submitApply };
        }
    }).mount('#app');
</script>