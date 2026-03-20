<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt"%>

<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<title>Tripan Partner — 파트너 센터</title>

<jsp:include page="/WEB-INF/views/partner/layout/headerResources.jsp" />

<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Sora:wght@600;700;800&family=Noto+Sans+KR:wght@400;500;700;900&display=swap" rel="stylesheet">
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

</head>
<body>

	<div class="admin-layout">

		<jsp:include page="/WEB-INF/views/partner/layout/sidebar.jsp" />

		<div class="main-wrapper">
			<jsp:include page="/WEB-INF/views/partner/layout/header.jsp" />

			<main class="main-content">

				<c:set var="targetTab" value="${empty activeTab ? 'dashboard' : activeTab}" />

				<jsp:include page="/WEB-INF/views/partner/fragment/${targetTab}.jsp" />

			</main>
		</div>
	</div>

	<jsp:include page="/WEB-INF/views/partner/fragment/modals.jsp" />

</body>
</html>