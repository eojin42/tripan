<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Spring</title>
<jsp:include page="/WEB-INF/views/layout/headerResources.jsp"/>
<link rel="stylesheet" href="${pageContext.request.contextPath}/dist/css/board.css" type="text/css">
</head>
<body>

<header>
	<jsp:include page="/WEB-INF/views/layout/header.jsp"/>
</header>

<main>
	<!-- Page Title -->
	<div class="page-title">
		<div class="container align-items-center" data-aos="fade-up">
			<h1>메일 보내기</h1>
			<div class="page-title-underline-accent"></div>
		</div>
	</div>
    
	<!-- Page Content -->    
	<div class="section">
		<div class="container" data-aos="fade-up" data-aos-delay="100">
			<div class="row justify-content-center">
				<div class="col-md-10 board-section my-4 p-5">

					<div class="pb-2">
						<span class="small-title">메일 전송</span>
					</div>
				
					<form name="mailForm" action="" method="post" enctype="multipart/form-data">
						<table class="table write-form">
							<tr>
								<td class="col-md-3 bg-light">보내는 사람 이름</td>
								<td>
									<div class="row">
										<div class="col-md-6">
											<input type="text" name="senderName" class="form-control" value="${sessionScope.member.name}" readonly>
										</div>
									</div>
								</td>
							</tr>

							<tr>
								<td class="col-md-3 bg-light">받는 사람 E-Mail</td>
								<td>
									<input type="text" name="receiverEmail" class="form-control" placeholder="받는 사람 E-Mail">
									<small class="form-control-plaintext help-block">여러명에게 이메일을 전송하는 경우 이메일을 세미콜론(<span class="fs-6">;</span>)으로 구분합니다.</small>
								</td>
							</tr>
													
							<tr>
								<td class="col-md-3 bg-light">제 목</td>
								<td>
									<input type="text" name="subject" class="form-control" maxlength="100" placeholder="Subject">
								</td>
							</tr>
						
							<tr>
								<td class="col-md-3 bg-light">내 용</td>
								<td>
									<textarea name="content" class="form-control" placeholder="Content"></textarea>
								</td>
							</tr>
							
							<tr>
								<td class="col-md-2 bg-light">첨 부</td>
								<td>
									<input type="file" class="form-control" name="selectFile" multiple>
								</td>
							</tr>
						</table>
						
						<div class="text-center">
							<button type="button" class="btn-accent btn-md" onclick="sendOk();">메일전송</button>
							<button type="reset" class="btn-default btn-md">다시입력</button>
							<button type="button" class="btn-default btn-md" onclick="location.href='${pageContext.request.contextPath}/';">취 소</button>
						</div>						
					</form>

				</div>
			</div>
		</div>
	</div>
</main>

<script type="text/javascript">
function sendOk() {
	const f = document.mailForm;
	let str;
	
	if(!f.receiverEmail.value.trim()) {
		alert("정상적인 E-Mail을 입력하세요. ");
		f.receiverEmail.focus();
		return;
	}
	
	str = f.subject.value.trim();
	if( ! str ) {
		alert('제목을 입력하세요. ');
		f.subject.focus();
		return;
	}

	str = f.content.value.trim();
	if( ! str ) {
		alert('내용을 입력하세요. ');
		f.content.focus();
		return;
	}
	
	f.action = '${pageContext.request.contextPath}/mail/send';
	f.submit();
}
</script>

<footer>
	<jsp:include page="/WEB-INF/views/layout/footer.jsp"/>
</footer>

<jsp:include page="/WEB-INF/views/layout/footerResources.jsp"/>

</body>
</html>