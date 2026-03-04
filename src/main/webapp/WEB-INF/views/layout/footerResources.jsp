<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt"%>

<script>
    const TripanConfig = {
        contextPath: '${pageContext.request.contextPath}',
        kakaoMapKey: 'YOUR_KAKAO_MAP_JS_KEY',
        apiBaseUrl: '${pageContext.request.contextPath}/api'
    };
</script>

<script src="${pageContext.request.contextPath}/resources/js/api.js"></script>