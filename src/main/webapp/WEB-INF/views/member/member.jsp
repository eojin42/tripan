<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Tripan - ${mode=="update"?"정보수정":"회원가입"}</title>
<jsp:include page="/WEB-INF/views/layout/headerResources.jsp"/>

<style>
  /* 디자인 변수 스코프 설정 */
  #signup-page-wrapper {
    --sky-blue: #89CFF0;
    --light-pink: #FFB6C1;
    --grad-main: linear-gradient(135deg, var(--sky-blue), var(--light-pink));
    
    --ice-melt: #A8C8E1;
    --orchid-tint: #C2B8D9;
    --rain-pink: #E0BBC2;
    --grad-sub: linear-gradient(120deg, var(--ice-melt) 0%, var(--orchid-tint) 50%, var(--rain-pink) 100%);
    
    --bg-page: #F4F7F6;
    --card-bg: rgba(255, 255, 255, 0.85);
    --text-black: #2D3748;
    --text-dark: #4A5568;
    --text-gray: #A0AEC0;
    --border-light: #E2E8F0;
    
    --font-sans: 'Pretendard', sans-serif;
    --bounce: cubic-bezier(0.68, -0.55, 0.26, 1.55);
  }

  #signup-page-wrapper .signup-section {
    min-height: 100vh;
    display: flex;
    align-items: center;
    justify-content: center;
    background: linear-gradient(135deg, #F0F8FF 0%, #FFF0F5 100%);
    padding: 120px 20px 80px; 
    font-family: var(--font-sans);
    box-sizing: border-box;
  }

  #signup-page-wrapper .signup-card {
    background: var(--card-bg);
    backdrop-filter: blur(24px); -webkit-backdrop-filter: blur(24px);
    width: 100%;
    max-width: 520px;
    padding: 48px 40px;
    border-radius: 32px; 
    border: 1px solid rgba(255, 255, 255, 0.8);
    box-shadow: 0 24px 48px rgba(137, 207, 240, 0.15);
    transform: translateY(30px);
    opacity: 0;
    animation: signupFadeUp 0.8s var(--bounce) forwards;
    box-sizing: border-box;
  }

  @keyframes signupFadeUp { to { transform: translateY(0); opacity: 1; } }

  #signup-page-wrapper .signup-header { text-align: center; margin-bottom: 32px; }
  
  #signup-page-wrapper .brand-logo { font-size: 36px; font-weight: 900; letter-spacing: -0.5px;
    display: flex; align-items: baseline; justify-content: center; text-decoration: none; line-height: 1; margin-bottom: 8px; }
  #signup-page-wrapper .brand-logo .tri { color: var(--text-black); }
  #signup-page-wrapper .brand-logo .pan { background: var(--grad-main); -webkit-background-clip: text; -webkit-text-fill-color: transparent; }
  #signup-page-wrapper .brand-logo .dot { color: var(--light-pink); font-size: 38px; }

  #signup-page-wrapper .signup-desc { color: var(--text-dark); font-size: 15px; font-weight: 600; margin: 0; }

  /* 프로필 이미지 업로드 UI */
  #signup-page-wrapper .profile-upload-wrapper { display: flex; flex-direction: column; align-items: center; margin-bottom: 32px; }
  #signup-page-wrapper .profile-preview {
    width: 110px; height: 110px; border-radius: 50%;
    background: rgba(244, 247, 246, 0.8); border: 3px solid white;
    box-shadow: 0 8px 16px rgba(137, 207, 240, 0.3);
    display: flex; justify-content: center; align-items: center;
    cursor: pointer; position: relative; overflow: hidden;
    transition: all 0.3s var(--bounce);
  }
  #signup-page-wrapper .profile-preview:hover { transform: scale(1.05); box-shadow: 0 12px 24px rgba(137, 207, 240, 0.5); }
  #signup-page-wrapper .profile-preview img { width: 100%; height: 100%; object-fit: cover; display: none; }
  
  #signup-page-wrapper .profile-airplane-icon { 
    width: 44px; height: 44px; fill: var(--sky-blue); 
    transform: rotate(90deg) translateX(4px); 
    opacity: 0.8; transition: opacity 0.3s;
  }
  #signup-page-wrapper .profile-preview:hover .profile-airplane-icon { opacity: 1; fill: var(--light-pink); }
  
  #signup-page-wrapper .profile-hint { font-size: 12px; color: var(--text-gray); font-weight: 600; margin-top: 12px; text-align: center; }
  #signup-page-wrapper .help-block { font-size: 12px; color: #E53E3E; font-weight: 600; margin-top: 8px; } /* 에러 메시지 */

  /* 폼 요소 공통 */
  #signup-page-wrapper .form-row { margin-bottom: 20px; text-align: left; }
  #signup-page-wrapper .form-label { display: block; font-size: 13px; font-weight: 800; color: var(--text-dark); margin-bottom: 8px; }
  #signup-page-wrapper .input-group { display: flex; gap: 8px; }
  
  #signup-page-wrapper .form-input {
    flex: 1; width: 100%; padding: 14px 16px;
    border: 1px solid var(--border-light); border-radius: 12px;
    font-size: 14px; font-weight: 600; font-family: var(--font-sans); color: var(--text-black);
    transition: all 0.3s ease; background-color: rgba(244, 247, 246, 0.6); box-sizing: border-box; outline: none; margin: 0;
  }
  #signup-page-wrapper .form-input::placeholder { color: var(--text-gray); font-weight: 500; }
  #signup-page-wrapper .form-input:focus { border-color: var(--sky-blue); background-color: #FFFFFF; box-shadow: 0 0 0 4px rgba(137, 207, 240, 0.15); }
  #signup-page-wrapper .form-input:read-only { background-color: #EDF2F7; color: var(--text-gray); cursor: not-allowed; }

  #signup-page-wrapper .btn-side {
    padding: 0 16px; background: var(--bg-page); color: var(--text-dark);
    border: 1px solid var(--border-light); border-radius: 12px;
    font-size: 13px; font-weight: 800; cursor: pointer; white-space: nowrap; transition: all 0.3s ease;
  }
  #signup-page-wrapper .btn-side:hover { background: var(--grad-sub); color: white; border-color: transparent; transform: translateY(-2px); box-shadow: 0 4px 12px rgba(168, 200, 225, 0.4); }

  /* 최종 가입 버튼 */
  #signup-page-wrapper .btn-submit-account {
    width: 100%; padding: 18px; 
    background: var(--text-black); color: #FFFFFF;
    border: none; border-radius: 16px;
    font-size: 16px; font-weight: 800; cursor: pointer;
    transition: all 0.3s var(--bounce); box-sizing: border-box;
  }
  #signup-page-wrapper .btn-submit-account:hover:not(:disabled) {
    background: var(--grad-main); transform: translateY(-3px); box-shadow: 0 12px 24px rgba(137, 207, 240, 0.4);
  }
  #signup-page-wrapper .btn-submit-account:disabled { background: var(--border-light); color: var(--text-gray); cursor: not-allowed; transform: none; box-shadow: none; }
</style>
</head>
<body>

<header>
	<jsp:include page="/WEB-INF/views/layout/header.jsp"/>
</header>

<div id="signup-page-wrapper">
  <main class="signup-section">
    <div class="signup-card">
      
      <div class="signup-header">
        <div class="brand-logo">
          <span class="tri">Tri</span><span class="pan">pan</span><span class="dot">.</span>
        </div>
        <p class="signup-desc">${mode=="update" ? "회원정보를 안전하게 수정하세요" : "Tripan과 함께 새로운 여정을 시작하세요"}</p>
      </div>

      <form name="memberForm" method="post" enctype="multipart/form-data">
        
        <div class="profile-upload-wrapper">
          <label for="selectFile" class="profile-preview">
            <svg class="profile-airplane-icon" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
              <path d="M22,16v-2l-8.5-5V3.5C13.5,2.67 12.83,2 12,2s-1.5,0.67-1.5,1.5V9L2,14v2l8.5-2.5V19L8.5,20.5V22L12,21l3.5,1v-1.5L13.5,19v-5.5L22,16z" />
            </svg>
            <img id="profileImg" src="" alt="Profile">
          </label>
          <input type="file" name="selectFile" id="selectFile" accept="image/png, image/jpg, image/jpeg" style="display: none;">
          
          <div class="profile-hint">
            프로필 사진을 등록해주세요<br>
            <button type="button" class="btn-photo-init" style="background:none; border:none; color:var(--sky-blue); font-size:12px; font-weight:700; margin-top:4px; cursor:pointer; text-decoration: underline;">기본 이미지로 초기화</button>
          </div>
        </div>

        <div class="form-row wrap-loginId">
          <label for="loginId" class="form-label">아이디</label>
          <div class="input-group">
            <input type="text" id="loginId" name="loginId" value="${dto.login_id}" class="form-input" ${mode=="update" ? "readonly ":""} placeholder="5~10자 이내 영문/숫자" autofocus>
            <c:if test="${mode=='account'}">
              <button type="button" class="btn-side" onclick="userIdCheck();">중복검사</button>
            </c:if>
          </div>
          <c:if test="${mode=='account'}">
            <div class="help-block" style="color: var(--text-gray);">아이디는 5~10자 이내이며, 첫글자는 영문자로 시작해야 합니다.</div>
          </c:if>
        </div>

        <div class="form-row">
          <label for="password" class="form-label">비밀번호</label>
          <input type="password" id="password" name="password" class="form-input" autocomplete="off" placeholder="숫자/특수문자 포함 5~10자" style="margin-bottom: 8px;">
          <input type="password" id="password2" name="password2" class="form-input" autocomplete="off" placeholder="비밀번호를 한번 더 입력해주세요">
        </div>

        <div class="form-row">
          <label for="fullName" class="form-label">이름</label>
          <input type="text" id="fullName" name="name" value="${dto.name}" class="form-input" ${mode=="update" ? "readonly ":""} placeholder="이름을 입력해주세요">
        </div>

        <div class="form-row">
          <label for="birth" class="form-label">생년월일</label>
          <input type="date" id="birth" name="birth" value="${dto.birth}" class="form-input" ${mode=="update" ? "readonly ":""}>
        </div>

        <div class="form-row">
          <label for="email" class="form-label">이메일</label>
          <input type="email" id="email" name="email" value="${dto.email}" class="form-input" placeholder="example@tripan.com">
         
        </div>

        <div class="form-row">
          <label for="tel" class="form-label">전화번호</label>
          <input type="text" id="tel" name="tel" value="${dto.tel}" class="form-input" placeholder="010-0000-0000">
        </div>

        <c:if test="${mode=='account'}">
          <div class="form-row" style="margin: 32px 0 20px; padding: 16px; background: rgba(244, 247, 246, 0.8); border-radius: 12px; border: 1px solid var(--border-light);">
            <label style="display: flex; align-items: center; gap: 10px; cursor: pointer; font-size: 14px; font-weight: 700; color: var(--text-black);">
              <input type="checkbox" name="agree" id="agree" onchange="document.memberForm.sendButton.disabled = !this.checked" style="width: 18px; height: 18px; accent-color: var(--sky-blue);">
              <span>
                <a href="#" style="color: var(--sky-blue); text-decoration: underline; text-underline-offset: 4px;">이용약관</a>에 모두 동의합니다.
              </span>
            </label>
          </div>
        </c:if>

        <div style="display: flex; gap: 12px; margin-top: 24px;">
          <button type="button" class="btn-side" style="flex: 1; padding: 18px; text-align: center; justify-content: center; font-size: 15px;" onclick="location.href='${pageContext.request.contextPath}/';">
            ${mode=="update"?"수정 취소":"가입 취소"}
          </button>
          <button type="button" name="sendButton" class="btn-submit-account" style="flex: 2; margin-top: 0;" onclick="memberOk();" ${mode=="account" ? "disabled" : ""}>
            ${mode=="update"?"정보 수정 완료":"Tripan 가입 완료하기"}
          </button>
        </div>
        
        <input type="hidden" name="loginIdValid" id="loginIdValid" value="false">
        <c:if test="${mode == 'update'}">
          <input type="hidden" name="profile_photo" value="${dto.profile_photo}">
        </c:if>

      </form>
    </div>
  </main>
</div>

<footer>
	<jsp:include page="/WEB-INF/views/layout/footer.jsp"/>
</footer>

<script type="text/javascript">
document.addEventListener('DOMContentLoaded', ev => {
	let img = '${dto.profile_photo}';

	const avatarEL = document.getElementById('profileImg');
	const iconEL = document.querySelector('.profile-airplane-icon');
	const inputEL = document.querySelector('form[name=memberForm] input[name=selectFile]');
	const btnEL = document.querySelector('form[name=memberForm] .btn-photo-init');
	
	let avatar;
	if( img ) {
		avatar = '${pageContext.request.contextPath}/uploads/member/' + img;
		avatarEL.src = avatar;
		avatarEL.style.display = 'block';
		iconEL.style.display = 'none';
	}
	
	const maxSize = 800 * 1024;
	
	inputEL.addEventListener('change', ev => {
		let file = ev.target.files[0];
		if(! file) {
			if( img ) {
				avatar = '${pageContext.request.contextPath}/uploads/member/' + img;
				avatarEL.src = avatar;
				avatarEL.style.display = 'block';
				iconEL.style.display = 'none';
			} else {
				avatarEL.style.display = 'none';
				iconEL.style.display = 'block';
			}
			return;
		}
		
		if(file.size > maxSize || ! file.type.match('image.*')) {
			alert('이미지 파일 용량이 초과되었거나 올바르지 않은 형식입니다.');
			inputEL.focus();
			return;
		}
		
		var reader = new FileReader();
		reader.onload = function(e) {
			avatarEL.src = e.target.result;
			avatarEL.style.display = 'block';
			iconEL.style.display = 'none';
		}
		reader.readAsDataURL(file);			
	});
	
	btnEL.addEventListener('click', ev => {
		if( img ) {
			if(! confirm('등록된 이미지를 삭제하시겠습니까 ? ')) {
				return false;
			}
			
			avatar = '${pageContext.request.contextPath}/uploads/member/' + img;
			
			// 등록 이미지 삭제 API (경로 주의)
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
						document.querySelector('form input[name=profile_photo').value = '';
					}
					
					inputEL.value = '';
					avatarEL.style.display = 'none';
					iconEL.style.display = 'block';
				})
				.catch(err => console.log("error:", err));
			
		} else {
			inputEL.value = '';
			avatarEL.style.display = 'none';
			iconEL.style.display = 'block';
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
		document.querySelector('.wrap-loginId .help-block').style.color = '#E53E3E';
		f.loginId.focus();
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
	let loginId = document.getElementById('loginId').value;
	if(!/^[a-z][a-z0-9_]{4,9}$/i.test(loginId)) { 
		let str = '아이디는 5~10자 이내이며, 첫글자는 영문자로 시작해야 합니다.';
		document.getElementById('loginId').closest('.wrap-loginId').querySelector('.help-block').textContent = str;
		document.getElementById('loginId').closest('.wrap-loginId').querySelector('.help-block').style.color = '#E53E3E';
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
			let str = '<span style="color:var(--sky-blue); font-weight: 800;">' + loginId + '</span> 아이디는 사용가능 합니다.';
			helpBlock.innerHTML = str;
			helpBlock.style.color = 'var(--text-dark)';
			loginIdValid.value = 'true';
		} else {
			let str = '<span style="color:#E53E3E; font-weight: 800;">' + loginId + '</span> 아이디는 중복되어 사용할 수 없습니다.';
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

</body>
</html>