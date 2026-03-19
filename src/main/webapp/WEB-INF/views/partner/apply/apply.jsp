<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Tripan - 파트너 입점 신청</title>

<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.8/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-sRIl4kxILFvY47J16cr9ZwB07vP4J8+LH7qKQnuqkuIAvNWLzeN8tE5YBujZqJLB" crossorigin="anonymous">
<link rel="stylesheet" href="https://cdn.jsdelivr.net/gh/orioncactus/pretendard@v1.3.8/dist/web/static/pretendard.css">

<style>
:root {
	--tp-ice: #A8C8E1; --tp-orchid: #C2B8D9; --tp-rose: #E0BBC2;
	--tp-grad: linear-gradient(120deg, var(--tp-ice) 0%, var(--tp-orchid) 50%, var(--tp-rose) 100%);
	--tp-bg-white: #FDFDFD;
	--tp-bg-gray: #F8F9FA;
	--tp-placeholder: #B0B8C1;
}

body {
	font-family: 'Pretendard', sans-serif;
	background-color: var(--tp-bg-white);
	color: #111;
	margin: 0;
}

.apply-wrapper {
	padding-top: 140px !important;    
	padding-bottom: 160px !important; 
	min-height: 100vh;
}

.btn-tp-back {
	color: #777; font-weight: 800; text-decoration: none;
	display: inline-flex; align-items: center; gap: 8px; margin-bottom: 25px;
}
.btn-tp-back:hover { color: #111; transform: translateX(-4px); transition: 0.2s; }

.apply-hero { text-align: center; margin-bottom: 50px; }
.apply-hero h1 { font-size: 38px; font-weight: 900; letter-spacing: -1.5px; }
.apply-hero h1 span { background: var(--tp-grad); -webkit-background-clip: text; -webkit-text-fill-color: transparent; }
.apply-hero p { font-size: 17px; color: #777; font-weight: 600; margin-top: 8px; }

.tp-form-card {
	background: #fff; border-radius: 24px; padding: 45px;
	border: 1px solid #eee; box-shadow: 0 5px 20px rgba(0, 0, 0, 0.02);
	margin-bottom: 40px;
}

.section-title { border-bottom: 2px solid #111; padding-bottom: 15px; margin-bottom: 40px; font-weight: 900; }

.form-label { font-weight: 800; color: #333; }

.form-control, .form-select {
	padding: 15px 18px; border-radius: 12px; border: 1px solid #ddd;
	font-size: 15px; font-weight: 600;
}

.form-control::placeholder {
	color: var(--tp-placeholder) !important;
	font-weight: 400 !important;
	letter-spacing: -0.02em;
}
.form-control:focus { border-color: var(--tp-orchid); box-shadow: 0 0 0 4px rgba(194, 184, 217, 0.15); }

.tp-recessed-box {
	background-color: var(--tp-bg-gray);
	border-radius: 20px; padding: 40px;
	border: 1px solid #f1f3f5; text-align: left;
	transition: all 0.3s ease; 
}

.tp-recessed-box.dragover {
	background-color: #fff !important;
	border-color: var(--tp-orchid) !important;
	box-shadow: 0 0 15px rgba(194, 184, 217, 0.3);
}

.file-item {
	display: flex; align-items: center; justify-content: space-between;
	background: #fff; border: 1px solid #eee; padding: 12px 20px;
	border-radius: 12px; margin-top: 10px; font-size: 14px; font-weight: 600;
}
.btn-remove-file {
	background: none; border: none; color: var(--tp-rose); font-weight: 900; font-size: 20px; cursor: pointer; line-height: 1;
}

.btn-tp-submit {
	background: var(--tp-grad); color: white; border: none;
	padding: 22px 100px; border-radius: 100px;
	font-size: 19px; font-weight: 900;
	box-shadow: 0 10px 25px rgba(168, 200, 225, 0.4);
	transition: 0.4s;
}
</style>
</head>
<body>

	<jsp:include page="/WEB-INF/views/layout/header.jsp" />

	<div class="apply-wrapper">
		<div class="container" style="max-width: 850px;">
			<a href="javascript:history.back()" class="btn-tp-back"> 
				<svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round">
					<line x1="19" y1="12" x2="5" y2="12"></line>
					<polyline points="12 19 5 12 12 5"></polyline>
				</svg> 메인으로 돌아가기
			</a>

			<header class="apply-hero">
				<h1>당신의 공간을 <span>Tripan</span>에 담다</h1>
				<p>트리판의 몽환적인 감성 여행 코스에 당신의 스테이를 제안해 보세요.</p>
			</header>

			<form action="${pageContext.request.contextPath}/partner/apply" method="POST" enctype="multipart/form-data" onsubmit="return validateFiles(event)">

					<div class="tp-form-card">
						<h2 class="section-title">담당자 및 사업자 정보</h2>
						
						<div class="row mb-4 align-items-center">
							<label class="col-md-3 form-label">담당자 성함<span class="ms-1" style="color: var(--tp-orchid);">*</span></label>
							<div class="col-md-9">
		                        <input type="text" name="contactName" class="form-control" value="${myApply.contactName}" placeholder="담당자 성함을 입력해 주세요." required>
							</div>
						</div>
						
						<div class="row mb-4 align-items-center">
							<label class="col-md-3 form-label">연락처<span class="ms-1" style="color: var(--tp-orchid);">*</span></label>
							<div class="col-md-9">
		                        <input type="tel" name="contactPhone" class="form-control" value="${myApply.contactPhone}" placeholder="'-'를 제외한 휴대전화번호를 입력해 주세요." required>
							</div>
						</div>
						
						<div class="row mb-4 align-items-center">
							<label class="col-md-3 form-label">이메일 주소<span class="ms-1" style="color: var(--tp-orchid);">*</span></label>
							<div class="col-md-9">
		                        <input type="email" name="contactEmail" class="form-control" value="${myApply.contactEmail}" placeholder="이메일 주소를 입력해 주세요." required>
							</div>
						</div>
	
						<div class="row mb-0 align-items-center">
							<label class="col-md-3 form-label">사업자등록번호<span class="ms-1" style="color: var(--tp-orchid);">*</span></label>
							<div class="col-md-9">
		                        <input type="text" name="businessNumber" class="form-control" value="${myApply.businessNumber}" placeholder="예: 123-45-67890" required>
							</div>
						</div>
					</div>
		
					<div class="tp-form-card">
						<h2 class="section-title">스테이 정보</h2>
						
						<div class="row mb-4 align-items-center">
							<label class="col-md-3 form-label">스테이 이름<span class="ms-1" style="color: var(--tp-orchid);">*</span></label>
							<div class="col-md-9">
		                        <input type="text" name="partnerName" class="form-control" value="${myApply.partnerName}" placeholder="스테이 이름을 입력해 주세요." required>
							</div>
						</div>
							<div class="row mb-4 align-items-center">
								<label class="col-md-3 form-label">숙박업 운영 경험 유무<span class="ms-1" style="color: var(--tp-orchid);">*</span></label>
								<div class="col-md-9">
									<div class="d-flex align-items-center" style="height: 100%; gap: 20px; padding-left: 10px;">
										<div class="form-check mb-0">
											<input class="form-check-input" type="radio" name="expStatus" id="expY" value="Y" ${myApply.expStatus == 'Y' ? 'checked' : ''} required style="accent-color: var(--tp-orchid); cursor: pointer;">
											<label class="form-check-label fw-bold" for="expY" style="cursor: pointer;">있음</label>
										</div>
										<div class="form-check mb-0">
											<input class="form-check-input" type="radio" name="expStatus" id="expN" value="N" ${myApply.expStatus == 'N' ? 'checked' : ''} required style="accent-color: var(--tp-orchid); cursor: pointer;">
											<label class="form-check-label fw-bold" for="expN" style="cursor: pointer;">없음</label>
										</div>
									</div>
								</div>
							</div>
							
							<div class="row mb-0 align-items-start">
								<label class="col-md-3 form-label pt-2">공간 소개<span class="ms-1" style="color: var(--tp-orchid);">*</span></label>
								<div class="col-md-9">
			                        <textarea name="partnerIntro" class="form-control" style="height: 140px; resize: none;" placeholder="공간의 컨셉과 스토리를 들려주세요. &#13;&#10;스테이를 소개할 SNS나 홈페이지 정보를 입력해 주어도 좋아요. (최소 50자) " required>${myApply.partnerIntro}</textarea>
								</div>
							</div>
						</div>
	
					<div class="tp-form-card">
						<h2 class="section-title">증빙 서류 제출</h2>
						<div class="tp-recessed-box text-center" id="fileDropzone"
							style="border: 2px dashed #CCD5E0; cursor: pointer;"
							onclick="document.getElementById('fileIn').click()">
							<input type="file" id="fileIn" name="bizLicenseFiles" style="display: none;" multiple>
							<span style="font-size: 32px; opacity: 0.5;">📂</span>
							<p class="mt-2 mb-0 fw-bold text-secondary" id="fileNameText">
								이곳을 클릭하거나 파일(PDF, 이미지)을 드래그하여 첨부해 주세요.
							</p>
						</div>
						<div id="fileListContainer" class="mt-3"></div>
					</div>
	
					<div class="tp-form-card text-center">
						<h2 class="section-title text-start">개인정보 수집 동의</h2>
						<div class="tp-recessed-box mb-4">
							<div style="font-size: 14px; line-height: 1.8; color: #444;">
								<p class="fw-bold mb-2">개인정보 수집 및 이용 동의</p>
								<p>1. 수집 항목 : 스테이 이름, 주소, 담당자 성함, 연락처, 사업자등록번호 등</p>
								<p>2. 수집 목적 : 입점 신청 정보 확인 및 안내, 정산 및 세무 처리</p>
								<p>3. 보유 기간 : 검토 완료 후 3개월 보관 후 파기 (입점 승인 시 계약 기간 동안 보관)</p>
							</div>
						</div>
						<div class="form-check d-inline-block">
							<input class="form-check-input" type="checkbox" id="agree" required
								style="width: 22px; height: 22px; accent-color: var(--tp-orchid);">
							<label class="form-check-label ms-2 fw-bold" for="agree">내용을 확인했으며, 이에 동의합니다.</label>
						</div>
					</div>
	
					<div class="text-center mt-5">
						<button type="submit" class="btn-tp-submit">입점 제안서 제출하기 ✨</button>
					</div>
				</form>
			</form>
		</div>
	</div>

	<jsp:include page="/WEB-INF/views/layout/footer.jsp" />

	<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.8/dist/js/bootstrap.bundle.min.js" integrity="sha384-FKyoEForCGlyvwx9Hj09JcYn3nv7wiPVlz7YYwJrWVcXK/BmnVDxM+D2scQbITxI" crossorigin="anonymous"></script>

	<script>
		const fileInput = document.getElementById('fileIn');
		const fileListContainer = document.getElementById('fileListContainer');
		const dropzone = document.getElementById('fileDropzone');
		const dataTransfer = new DataTransfer(); 

		function handleFiles(files) {
			files.forEach(file => {
				let alreadyExists = false;
				for(let i = 0; i < dataTransfer.items.length; i++) {
					if(dataTransfer.items[i].getAsFile().name === file.name) alreadyExists = true;
				}
				if(!alreadyExists) {
					dataTransfer.items.add(file);
				}
			});

			fileInput.files = dataTransfer.files;
			
			if (dataTransfer.files.length > 0) {
				dropzone.style.borderColor = "var(--tp-orchid)";
				dropzone.style.backgroundColor = "#fff";
			} else {
				dropzone.style.borderColor = "#CCD5E0";
				dropzone.style.backgroundColor = "var(--tp-bg-gray)";
			}
			renderFileList();
		}

		fileInput.addEventListener('change', function(e) {
			handleFiles(Array.from(e.target.files));
		});

		dropzone.addEventListener('dragover', function(e) {
			e.preventDefault();
			dropzone.classList.add('dragover');
		});

		dropzone.addEventListener('dragleave', function(e) {
			e.preventDefault();
			dropzone.classList.remove('dragover');
		});

		dropzone.addEventListener('drop', function(e) {
			e.preventDefault();
			dropzone.classList.remove('dragover');
			
			if(e.dataTransfer.files && e.dataTransfer.files.length > 0) {
				handleFiles(Array.from(e.dataTransfer.files));
			}
		});

		function renderFileList() {
			fileListContainer.innerHTML = '';
			
			Array.from(dataTransfer.files).forEach((file, index) => {
				const fileItem = document.createElement('div');
				fileItem.className = 'file-item';
				const icon = file.type === 'application/pdf' ? '📕' : '🖼️';
				
				fileItem.innerHTML = '<span>' + icon + ' ' + file.name + '</span>' + 
									 '<button type="button" class="btn-remove-file" onclick="removeFile(' + index + ')">×</button>';
				fileListContainer.appendChild(fileItem);
			});
		}

		window.removeFile = function(index) {
			event.stopPropagation(); 
			
			dataTransfer.items.remove(index);
			fileInput.files = dataTransfer.files;
			renderFileList();
			
			if (dataTransfer.files.length === 0) {
				dropzone.style.borderColor = "#CCD5E0";
				dropzone.style.backgroundColor = "var(--tp-bg-gray)";
			}
		};
		
		function validateFiles(e) {
			if (dataTransfer.files.length === 0) {
				alert('🚨 증빙 서류(PDF, 이미지)를 최소 1개 이상 첨부해 주세요!');
				e.preventDefault(); 
				return false;
			}
			return true;
		}
		
		document.querySelector('form').addEventListener('submit', function(e) {
					if (fileInput.files.length === 0) {
						e.preventDefault(); 
						alert('증빙 서류(PDF, 이미지)를 최소 1개 이상 첨부해 주세요.');
					}
				});
	</script>

</body>
</html>