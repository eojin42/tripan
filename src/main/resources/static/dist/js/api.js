/**
 * 공통 API 통신 모듈
 * fetch API를 감싸서 사용하기 편하게 만든 유틸리티 함수입니다.
 */
const TripanAPI = {
    get: async function(endpoint) {
        try {
            const url = TripanConfig.apiBaseUrl + endpoint;
            
            const response = await fetch(url, {
                method: 'GET',
                headers: {
                    'Content-Type': 'application/json',
                    'X-Requested-With': 'Fetch'
                }
            });

            if (!response.ok) {
                throw new Error('API 호출 에러: ' + response.status);
            }

            return await response.json();
            
        } catch (error) {
            console.error('TripanAPI GET Error:', error);
            throw error; 
        }
    },
    getFestivals: async function(year, month) {
        return await this.get(`/festivals?year=${year}&month=${month}`);
    }
};