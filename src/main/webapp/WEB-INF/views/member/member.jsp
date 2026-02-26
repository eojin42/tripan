<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt"%>

<jsp:include page="../layout/header.jsp" />

<style>
  /* member.jsp 전용 스타일 조정 */
  .member-container {
    max-width: 800px;
    margin: 160px auto 100px;
    padding: 50px;
    background: rgba(255, 255, 255, 0.85);
    backdrop-filter: blur(24px);
    -webkit-backdrop-filter: blur(24px);
    border-radius: var(--radius-lg);
    border: 1px solid rgba(255, 255, 255, 0.6);
    box-shadow: 0 24px 48px rgba(45, 55, 72, 0.08);
  }

  .page-title {
    text-align: center;
    margin-bottom: 40px;
  }
  
  .page-title h1 {
    font-size: 32px;
    font-weight: 900;
    color: var(--text-black);
    letter-spacing: -0.5px;
  }

  .form-label {
    font-weight: 800;
    font-size: 14px;
    color: var(--text-dark);
    margin-bottom: 8px;
    display: block;
  }

  /* 입력창 스타일을 메인 검색바 스타일로 변경 */
  .form-control {
    width: 100%;
    padding: 14px 20px;
    border-radius: var(--radius-sm);
    border: 1px solid #E2E8F0;
    background: var(--bg-white);
    font-family: var(--font-sans);
    font-size: 15px;
    font-weight: 600;
    color: var(--text-black);
    transition: all 0.3s var(--bounce);
  }

  .form-control::placeholder {
    color: #A0AEC0;
    font-weight: 500;
  }

  .form-control:focus {
    outline: none;
    border-color: var(--point-blue);
    box-shadow: 0 0 0 4px rgba(137, 207, 240, 0.2);
  }

  .form-control:read-only {
    background: var(--bg-light);
    color: var(--text-gray);
  }

  /* 사진 업로드 영역 스타일 */
  .profile-upload-section {
    background: var(--bg-beige);
    padding: 30px;
    border-radius: var(--radius-lg);
    margin-bottom: 40px;
    display: flex;
    align-items: center;
    gap: 24px;
    border: 1px dashed rgba(137, 207, 240, 0.5);
  }

  .img-avatar {
    width: 100px;
    height: 100px;
    border-radius: 30px;
    object-fit: cover;
    border: 4px solid white;
    box-shadow: 0 8px 16px rgba(45, 55, 72, 0.05);
  }

  /* 버튼 스타일 */
  .btn-action {
    padding: 14px 32px;
    border-radius: var(--radius-pill);
    font-weight: 800;
    font-size: 15px;
    transition: all 0.3s var(--bounce);
    cursor: pointer;
    border: none;
    display: inline-flex;
    align-items: center;
    justify-content: center;
    gap: 8px;
  }

  .btn-submit {
    background: var(--text-black);
    color: white;
    min-width: 160px;
    box-shadow: 0 4px 12px rgba(45, 55, 72, 0.15);
  }

  .btn-submit:hover {
    background: var(--point-blue);
    transform: translateY(-2px);
    box-shadow: 0 8px 24px rgba(137, 207, 240, 0.3);
  }
  
  .btn-cancel {
    background: var(--bg-light);
    color: var(--text-dark);
    min-width: 160px;
  }
  
  .btn-cancel:hover {
    background: #E2E8F0;
  }

  .btn-check-id {
    background: var(--bg-white);
    color: var(--point-blue);
    font-size: 14px;
    padding: 10px 24px;
    border: 1px solid var(--point-blue);
  }
  
  .btn-check-id:hover {
    background: var(--point-blue);
    color: white;
  }

  .help-block {
    font-size: 13px;
    color: var(--text-gray);
    margin-top: 8px;
    font-weight: 600;
  }

  /* 그리드 레이아웃 */
  .form-grid {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 24px;
  }
  
  .full-width {
    grid-column: span 2;
  }

  @media (max-width: 768px) {
    .form-grid {
      grid-template-columns: 1fr;
    }
    .full-width {
      grid-column: span 1;
    }
    .member-container {
      padding: 30px 20px;
      margin-top: 100px;
    }
  }
</style>

<main class="reveal active">
  <div class="member-container">
    <div class="page-title">
      <h1>${mode=="update"?"정보 수정":"회원가입"}</h1>
    </div>

    <form name="memberForm" method="post" enctype="multipart/form-data">
      
      <div class="profile-upload-section">
        <img src="${pageContext.request.contextPath}/dist/images/user.png" class="img-avatar">
        <div>
          <label for="selectFile" class="btn-action btn-check-id" style="margin-bottom: 12px;">
            사진 업로드
            <input type="file" name="selectFile" id="selectFile" hidden accept="image/png, image/jpg, image/jpeg">
          </label>
          <button type="button" class="btn-photo-init" style="background:none; border:none; color:var(--text-gray); font-size:14px; font-weight:700; margin-left:12px; cursor:pointer; text-decoration: underline;">초기화</button>
          <p class="help-block" style="margin-top: 0;">Allowed JPG, GIF or PNG. Max size of 800K</p>
        </div>
      </div>

      <div class="form-grid">
        
        <div class="full-width wrap-loginId">
          <label for="login_id" class="form-label">아이디</label>
          <div style="display: flex; gap: 12px;">
            <input class="form-control" type="text" id="loginId" name="loginId" value="${dto.login_id}" ${mode=="update" ? "readonly ":""} autofocus placeholder="5~10자 이내 영문/숫자">
            <c:if test="${mode=='account'}">
              <button type="button" class="btn-action btn-check-id" onclick="userIdCheck();" style="flex-shrink:0;">중복검사</button>
            </c:if>
          </div>
          <c:if test="${mode=='account'}">
            <p class="help-block">아이디는 5~10자 이내이며, 첫글자는 영문자로 시작해야 합니다.</p>
          </c:if>
        </div>

        <div>
          <label for="password" class="form-label">패스워드</label>
          <input class="form-control" type="password" id="password" name="password" autocomplete="off" placeholder="숫자/특수문자 포함 5~10자">
        </div>
        <div>
          <label for="password2" class="form-label">패스워드 확인</label>
          <input class="form-control" type="password" id="password2" name="password2" autocomplete="off" placeholder="패스워드를 한번 더 입력해주세요">
        </div>

        <div>
          <label for="fullName" class="form-label">이름</label>
          <input class="form-control" type="text" id="fullName" name="name" value="${dto.name}" ${mode=="update" ? "readonly ":""}>
        </div>
        <div>
          <label for="birth" class="form-label">생년월일</label>
          <input class="form-control" type="date" id="birth" name="birth" value="${dto.birth}" ${mode=="update" ? "readonly ":""}>
        </div>

        <div>
          <label for="email" class="form-label">이메일</label>
          <input class="form-control" type="text" id="email" name="email" value="${dto.email}">
        </div>
        <div style="display: flex; flex-direction: column; justify-content: center;">
          <label class="form-label">메일 수신</label>
          <label style="display: flex; align-items: center; gap: 8px; cursor: pointer; font-weight: 600; color: var(--text-dark); margin-top: 8px;">
            <input type="checkbox" name="receive_email" id="receive_email" value="1" ${dto.receive_email == 1 ? "checked":""} style="width: 18px; height: 18px; accent-color: var(--point-blue);">
            동의합니다
          </label>
        </div>

        <div>
          <label for="tel" class="form-label">전화번호</label>
          <input class="form-control" type="text" id="tel" name="tel" value="${dto.tel}" placeholder="010-0000-0000">
        </div>
        <div></div>

      </div>

      <c:if test="${mode=='account'}">
        <div class="full-width" style="margin: 32px 0; padding: 20px; background: var(--bg-light); border-radius: var(--radius-sm); border: 1px solid var(--bg-beige);">
          <label style="display: flex; align-items: center; gap: 12px; cursor: pointer; font-weight: 700; color: var(--text-black);">
            <input type="checkbox" name="agree" id="agree" onchange="form.sendButton.disabled = !checked" style="width: 20px; height: 20px; accent-color: var(--point-blue);">
            <span>
              <a href="#" style="color: var(--point-blue); text-decoration: underline; text-underline-offset: 4px;">이용약관</a>에 동의합니다.
            </span>
          </label>
        </div>
      </c:if>

      <div style="display: flex; justify-content: center; gap: 16px; margin-top: 48px;">
        <button type="button" name="sendButton" class="btn-action btn-submit" onclick="memberOk();" disabled>
          ${mode=="update"?"정보수정":"회원가입"} 
        </button>
        <button type="button" class="btn-action btn-cancel" onclick="location.href='${pageContext.request.contextPath}/';">
          ${mode=="update"?"수정취소":"가입취소"} 
        </button>
      </div>
      
      <input type="hidden" name="loginIdValid" id="loginIdValid" value="false">
      <c:if test="${mode == 'update'}">
        <input type="hidden" name="profile_photo" value="${dto.profile_photo}">
      </c:if>
      
    </form>
  </div>
</main>

<jsp:include page="../layout/footer.jsp" />

<script type="text/javascript">
document.addEventListener('DOMContentLoaded', ev => {
	let img = '${dto.profile_photo}';

	const avatarEL = document.querySelector('.img-avatar');
	const inputEL = document.querySelector('form[name=memberForm] input[name=selectFile]');
	const btnEL = document.querySelector('form[name=memberForm] .btn-photo-init');
	
	let avatar;
	if( img ) {
		avatar = '${pageContext.request.contextPath}/uploads/member/' + img;
		avatarEL.src = avatar;
	}
	
	const maxSize = 800 * 1024;
	inputEL.addEventListener('change', ev => {
		let file = ev.target.files[0];
		if(! file) {
			if( img ) {
				avatar = '${pageContext.request.contextPath}/uploads/member/' + img;
			} else {
				avatar = '${pageContext.request.contextPath}/dist/images/user.png';
			}
			avatarEL.src = avatar;
			
			return;
		}
		
		if(file.size > maxSize || ! file.type.match('image.*')) {
			inputEL.focus();
			return;
		}
		
		var reader = new FileReader();
		reader.onload = function(e) {
			avatarEL.src = e.target.result;
		}
		reader.readAsDataURL(file);			
	});
	
	btnEL.addEventListener('click', ev => {
		if( img ) {
			if(! confirm('등록된 이미지를 삭제하시겠습니까 ? ')) {
				return false;
			}
			
			avatar = '${pageContext.request.contextPath}/uploads/member/' + img;
			
			// 등록 이미지 삭제
			const url = '${pageContext.request.contextPath}/member/deleteProfile';
			const headers = {'Content-Type': 'application/x-www-form-urlencoded', 'AJAX': true};
			const params = 'profile_photo=' + img;
			
			const options = {
				method: 'delete',
				headers: headers,
				body: params,
			};
				
			fetch(url, options)
				.then(res => res.json())
				.then(data => {
					let state = data.state;

					if(state === 'true') {
						img = '';
						avatar = '${pageContext.request.contextPath}/dist/images/user.png';
						
						document.querySelector('form input[name=profile_photo').value = '';
					}
					
					inputEL.value = '';
					avatarEL.src = avatar;
				})
				.catch(err => console.log("error:", err));
			
		} else {
			avatar = '${pageContext.request.contextPath}/dist/images/user.png';
			inputEL.value = '';
			avatarEL.src = avatar;
		}
	});
});

function isValidDateString(dateString) {
	try {
		const date = new Date(dateString);
		const [year, month, day] = dateString.split("-").map(Number);
		
		return date instanceof Date && !isNaN(date) && date.getDate() === day;
	} catch(e) {
		return false;
	}
}

function memberOk() {
	const f = document.memberForm;
	let str, p;

	p = /^[a-z][a-z0-9_]{4,9}$/i;
	str = f.loginId.value;
	if( ! p.test(str) ) { 
		alert('아이디를 다시 입력 하세요. ');
		f.loginId.focus();
		return;
	}

	let mode = '${mode}';
	if( mode === 'account' && f.loginIdValid.value === 'false' ) {
		str = '아이디 중복 검사가 실행되지 않았습니다.';
		document.querySelector('.wrap-loginId .help-block').textContent = str;
		f.login_id.focus();
		return;
	}

	p =/^(?=.*[a-z])(?=.*[!@#$%^*+=-]|.*[0-9]).{5,10}$/i;
	str = f.password.value;
	if( ! p.test(str) ) { 
		alert('패스워드를 다시 입력 하세요. ');
		f.password.focus();
		return;
	}

	if( str !== f.password2.value ) {
        alert('패스워드가 일치하지 않습니다. ');
        f.password.focus();
        return;
	}
	
	p = /^[가-힣]{2,5}$/;
    str = f.name.value;
    if( ! p.test(str) ) {
        alert('이름을 다시 입력하세요. ');
        f.name.focus();
        return;
    }

    str = f.birth.value;
    if( ! isValidDateString(str) ) {
        alert('생년월일를 입력하세요. ');
        f.birth.focus();
        return;
    }
    
    p = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;    
    str = f.email.value;
	if( ! p.test(str) ) {
        alert('이메일을 입력하세요. ');
        f.email.focus();
        return;
	}
    
    p = /^(010)-?\d{4}-?\d{4}$/;    
    str = f.tel.value;
	if( ! p.test(str) ) {
        alert('전화번호를 입력하세요. ');
        f.tel.focus();
        return;
	}

    f.action = '${pageContext.request.contextPath}/member/${mode}';
    f.submit();
}

function userIdCheck() {
	// 아이디 중복 검사
	let loginId = document.getElementById('loginId').value;
	if(!/^[a-z][a-z0-9_]{4,9}$/i.test(loginId)) { 
		let str = '아이디는 5~10자 이내이며, 첫글자는 영문자로 시작해야 합니다.';
		document.getElementById('loginId').closest('.wrap-loginId').querySelector('.help-block').textContent = str;		
		document.getElementById('loginId').focus();
		return;
	}
	
	const url = '${pageContext.request.contextPath}/member/userIdCheck';
	const params = 'loginId=' + loginId;
	
	const fn = function(data) {
		let passed = data.passed;
		const loginIdInput = document.getElementById('loginId');
		const wrapLoginId = loginIdInput.closest('.wrap-loginId');
		const helpBlock = wrapLoginId.querySelector('.help-block');
		const loginIdValid = document.getElementById('loginIdValid');
		
		if (passed === 'true') {
			let str = '<span style="color:var(--point-blue); font-weight: 800;">' + loginId + '</span> 아이디는 사용가능 합니다.';
			helpBlock.innerHTML = str;
			loginIdValid.value = 'true';
		} else {
			let str = '<span style="color:#E53E3E; font-weight: 800;">' + loginId + '</span> 아이디는 사용할 수 없습니다.';
			helpBlock.innerHTML = str;
			loginIdInput.value = '';
			loginIdValid.value = 'false';
			loginIdInput.focus();
		}
	};
	
	const headers = {'Content-Type': 'application/x-www-form-urlencoded'};
	const options = {
			method: 'post',
			headers: headers,
			body: params,
	};
	
	fetch(url, options)
		.then(res => res.json())
		.then(data => fn(data))
		.catch(err => console.log("error:", err));
}
</script>