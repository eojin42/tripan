<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt"%>

<link rel="icon" href="data:;base64,iVBORw0KGgo=">
<!-- Favicons -->

<link rel="stylesheet" href="${pageContext.request.contextPath}/dist/css/partner/admin.css">
<link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css" rel="stylesheet">

<script>
    const TripanConfig = {
        contextPath: '${pageContext.request.contextPath}',
        apiBaseUrl: '${pageContext.request.contextPath}/api'
    };
</script>

<script src="${pageContext.request.contextPath}/dist/js/partner/partner_main.js" defer></script>
<script src="${pageContext.request.contextPath}/dist/js/partner/partner_room.js" defer></script>
<script src="${pageContext.request.contextPath}/dist/js/partner/partner_booking.js" defer></script>
<script src="${pageContext.request.contextPath}/dist/js/partner/partner_info.js" defer></script>
<script src="${pageContext.request.contextPath}/dist/js/partner/partner_facility.js" defer></script>