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
</head>
<body>

<header><jsp:include page="/WEB-INF/views/layout/header.jsp"/></header>

<div id="signup-page-wrapper">
  <main class="signup-section">
    <div class="signup-card">
      <div style="text-align: center; margin-bottom: 32px;">
        <div class="brand-logo">
          <span class="tri">Trip</span><span class="pan">an</span><span style="color: var(--light-pink);">.</span>
        </div>
        <p style="color: var(--text-dark); font-size: 15px; font-weight: 600;">${mode=="update" ? "회원정보를 안전하게 수정하세요" : "새로운 여행의 시작, Tripan"}</p>
      </div>

      <form name="memberForm" method="post" enctype="multipart/form-data">

        <div style="text-align: center; margin-bottom: 32px;">
          <label for="selectFile" class="profile-preview">
            <svg id="placeholderIcon" class="profile-airplane-icon" viewBox="0 0 24 24">
              <path d="M22,16v-2l-8.5-5V3.5C13.5,2.67 12.83,2 12,2s-1.5,0.67-1.5,1.5V9L2,14v2l8.5-2.5V19L8.5,20.5V22L12,21l3.5,1v-1.5L13.5,19v-5.5L22,16z"/>
            </svg>
            <img class="img-avatar" src="${pageContext.request.contextPath}/dist/images/user.png"
              style="width:100%; height:100%; object-fit:cover; display:none;">
          </label>
          <input type="file" name="selectFile" id="selectFile" accept="image/*" style="display:none;">
          <c:if test="${mode=='update'}">
            <button type="button" class="btn-photo-init" style="margin-top:8px; font-size:12px; color:var(--text-gray);">이미지 초기화</button>
          </c:if>
          <div class="help-block">나를 표현하는 프로필 사진</div>
        </div>

        <div class="form-row">
          <label class="form-label">아이디</label>
          <div class="input-group">
            <input type="text" name="loginId" value="${dto.loginId}" class="form-input" ${mode=="update" ? "readonly":""} placeholder="5~10자 영문/숫자">
            <c:if test="${mode!='update'}"><button type="button" class="btn-side" onclick="checkId()">중복확인</button></c:if>
          </div>
          <c:if test="${mode!='update'}">
            <div class="help-block" id="id-msg">영문자로 시작하는 5~10자 영문/숫자</div>
          </c:if>
        </div>

        <c:if test="${dto.provider != 'KAKAO'}">
            <div class="form-row">
              <label class="form-label">비밀번호</label>
              <input type="password" name="password" class="form-input" placeholder="영문/숫자/특수문자 조합 5~10자">
              <input type="password" name="passwordConfirm" class="form-input" style="margin-top:8px;" placeholder="비밀번호 확인">
              <div class="help-block" id="pwd-msg"></div>
            </div>
        </c:if>

        <div class="form-row">
          <label class="form-label">닉네임</label>
          <div class="input-group">
            <input type="text" name="nickname" value="${dto.nickname}" class="form-input" placeholder="커뮤니티 활동 별명">
            <button type="button" class="btn-side" onclick="checkNickname()">중복확인</button>
          </div>
          <div class="help-block" id="nick-msg">한글/영문/숫자 2~10자 (피드에 표시됩니다)</div>
        </div>

        <div class="form-row">
          <label class="form-label">이름 / 생년월일</label>
          <div class="input-group">
            <input type="text" name="username" value="${dto.username}" class="form-input" placeholder="이름" ${mode=="update" ? "readonly":""}>
            <input type="date" name="birthday" value="${dto.birthday}" class="form-input" required="required" ${mode=="update" ? "readonly":""}>
          </div>
          <div class="help-block" id="info-msg"></div>
        </div>

        <div class="form-row">
          <label class="form-label">관심 여행지</label>
          <select name="preferredRegion" class="form-input" required="required">
            <option value="" disabled selected hidden>선호하는 지역을 선택해주세요</option>
            <option value="서울"  ${dto.preferredRegion == '서울'  ? 'selected':''}>서울</option>
            <option value="제주"  ${dto.preferredRegion == '제주'  ? 'selected':''}>제주도</option>
            <option value="부산"  ${dto.preferredRegion == '부산'  ? 'selected':''}>부산</option>
            <option value="강원"  ${dto.preferredRegion == '강원'  ? 'selected':''}>강릉/속초</option>
            <option value="전라"  ${dto.preferredRegion == '전라'  ? 'selected':''}>여수/전주</option>
            <option value="경상"  ${dto.preferredRegion == '경상'  ? 'selected':''}>경주/거제</option>
          </select>
          <div class="help-block">선택한 지역의 핫플과 축제 정보를 우선 추천해요!</div>
        </div>

        <div class="form-row">
          <label class="form-label">자기소개 (Bio)</label>
          <textarea name="bio" class="form-input" rows="3" style="resize:none;" placeholder="나의 여행 스타일을 공유해보세요!">${dto.bio}</textarea>
        </div>

        <div class="form-row">
          <label class="form-label">연락처 및 이메일</label>
          <input type="text" name="phoneNumber" value="${dto.phoneNumber}" class="form-input" style="margin-bottom:8px;" placeholder="010-0000-0000">
          <input type="email" name="email" value="${dto.email}" class="form-input" 
               ${dto.provider == 'KAKAO' ? 'readonly style="background-color:#f5f5f5;"' : ''} placeholder="tripan@example.com">
          <div class="help-block" id="contact-msg"></div>
        </div>

        <c:if test="${mode!='update'}">
          <div style="margin: 32px 0; padding: 16px; background: #F4F7F6; border-radius: 12px;">
            <label style="display:flex; align-items:center; gap:10px; font-size:14px; font-weight:700; cursor:pointer;">
              <input type="checkbox" id="agree" style="width:18px; height:18px; accent-color:var(--point-blue);" onchange="document.memberForm.sendBtn.disabled = !this.checked">
              <span>Tripan 이용약관 및 개인정보 처리방침 동의</span>
            </label>
          </div>
        </c:if>

        <div style="display: flex; gap: 12px;">
          <button type="button" class="btn-side" style="flex:1; padding:18px;" onclick="history.back()">취소</button>
          <button type="button" id="sendBtn" class="btn-submit-account" style="flex:2;" onclick="memberOk()" ${mode=="update" ? "":"disabled"}>
            ${mode=="update" ? "정보 수정 완료" : "Tripan 시작하기"}
          </button>
        </div>

        <input type="hidden" name="idChecked" value="false">
        <input type="hidden" name="nickChecked" value="false">
        <input type="hidden" name="mode" value="${mode}">
      </form>
    </div>
  </main>
</div>

<footer><jsp:include page="/WEB-INF/views/layout/footer.jsp"/></footer>

<script>
const originalNick = '${dto.nickname}';

  document.addEventListener('DOMContentLoaded', function() {
    let img = '${dto.profilePhoto}';
    const ctx = '${pageContext.request.contextPath}';
    const defaultImg = ctx + '/dist/images/user.png';

    const avatarEl   = document.querySelector('.img-avatar');
    const inputEl    = document.querySelector('form[name=memberForm] input[name=selectFile]');
    const placeholderEl = document.getElementById('placeholderIcon');
    const btnInitEl  = document.querySelector('form[name=memberForm] .btn-photo-init');
    
    const nickInput = document.memberForm.nickname;
    nickInput.addEventListener('input', function() {
        if (this.value !== originalNick) {
            document.memberForm.nickChecked.value = "false";
        }
    });

    // 기존 사진 있으면 표시
    if (img) {
      avatarEl.src = ctx + '/uploads/member/' + img;
      avatarEl.style.display = 'block';
      placeholderEl.style.display = 'none';
    }

    const maxSize = 800 * 1024;

    // 파일 선택 시 미리보기
    inputEl.addEventListener('change', function(e) {
      const file = e.target.files[0];
      if (!file) {
        avatarEl.src = img ? ctx + '/uploads/member/' + img : defaultImg;
        return;
      }
      if (file.size > maxSize || !file.type.match('image.*')) {
        alert('이미지 파일만 800KB 이하로 올려주세요.');
        inputEl.value = '';
        return;
      }
      const reader = new FileReader();
      reader.onload = function(e) {
        avatarEl.src = e.target.result;
        avatarEl.style.display = 'block';
        placeholderEl.style.display = 'none';
      };
      reader.readAsDataURL(file);
    });

    // 이미지 초기화 버튼 (수정 모드에서만 표시)
    if (btnInitEl) {
      btnInitEl.addEventListener('click', function() {
        if (img) {
          if (!confirm('등록된 이미지를 삭제하시겠습니까?')) return;

          fetch(ctx + '/member/deleteProfile', {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded', 'AJAX': 'true' },
            body: 'profile_photo=' + img
          })
          .then(res => res.json())
          .then(data => {
            if (data.state === 'true') {
              img = '';
            }
            inputEl.value = '';
            avatarEl.src = defaultImg;
            avatarEl.style.display = 'block';
            placeholderEl.style.display = 'none';
          })
          .catch(err => console.error('이미지 삭제 오류:', err));

        } else {
          inputEl.value = '';
          avatarEl.src = defaultImg;
        }
      });
    }

    // 비밀번호 실시간 유효성 검사
    const pwdInput = document.memberForm.password;
    const pwdConfirmInput = document.memberForm.passwordConfirm;
    const pwdRegex = /^(?=.*[a-zA-Z])(?=.*[!@#$%^*+=-]|.*[0-9]).{5,10}$/i;

    function validatePwd() {
      const pwd = pwdInput.value;
      const pwdConfirm = pwdConfirmInput.value;
      if (!pwd && !pwdConfirm) { showMsg('pwd-msg', '', false); return; }
      if (!pwdRegex.test(pwd)) {
        showMsg('pwd-msg', '사용 불가: 영문/숫자/특수문자 조합 5~10자로 입력해주세요.', true); return;
      }
      if (!pwdConfirm) {
        showMsg('pwd-msg', '사용 가능: 아래 비밀번호 확인란도 동일하게 입력해주세요.', false); return;
      }
      if (pwd !== pwdConfirm) {
        showMsg('pwd-msg', '사용 불가: 비밀번호가 일치하지 않습니다.', true); return;
      }
      showMsg('pwd-msg', '사용 가능: 안전하고 완벽한 비밀번호입니다!', false);
    }

    pwdInput.addEventListener('input', validatePwd);
    pwdConfirmInput.addEventListener('input', validatePwd);
  });

  function showMsg(id, msg, isError) {
    const el = document.getElementById(id);
    if (!el) return;
    el.innerHTML = msg;
    el.style.color = isError ? 'var(--error-pink)' : 'var(--point-blue)';
  }

  function checkId() {
    const idStr = document.memberForm.loginId.value;
    if (!/^[a-z][a-z0-9_]{4,9}$/i.test(idStr)) {
      showMsg('id-msg', '아이디는 영문자로 시작하는 5~10자 영문/숫자여야 합니다.', true);
      document.memberForm.loginId.focus(); 
      return;
    }
    const ctx = '${pageContext.request.contextPath}';
    
    fetch(ctx + '/member/userIdCheck',{
    	method: 'POST',
    	headers: {'Content-Type': 'application/x-www-form-urlencoded'},
    	body: 'loginId=' + encodeURIComponent(idStr)
    })
    .then(res => res.json())
    .then(data => {
      if (data.passed === 'true' || data.passed === true) {
        showMsg('id-msg', '사용 가능한 아이디입니다!', false);
        document.memberForm.idChecked.value = "true";
      } else {
        showMsg('id-msg', '이미 사용 중인 아이디입니다. 다른 아이디를 입력해주세요.', true);
        document.memberForm.idChecked.value = "false";
        document.memberForm.loginId.focus();
      }
    })
    .catch(err => {
      console.error('중복확인 에러:', err);
      showMsg('id-msg', '서버 통신 중 오류가 발생했습니다.', true);
    });
  }

  function checkNickname() {
    const nick = document.memberForm.nickname.value;
    
    if (!/^[가-힣a-zA-Z0-9]{2,10}$/.test(nick)) {
      showMsg('nick-msg', '닉네임은 특수문자를 제외한 2~10자여야 합니다.', true);
      document.memberForm.nickname.focus(); 
      return;
    }
    const ctx = '${pageContext.request.contextPath}';
    
    fetch(ctx + '/member/nicknameCheck', { 
      method: 'POST',
      headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
      body: 'nickname=' + encodeURIComponent(nick)
    })
    .then(res => res.json())
    .then(data => {
      if (data.passed === 'true' || data.passed === true) {
        showMsg('nick-msg', '사용 가능한 닉네임입니다!', false);
        document.memberForm.nickChecked.value = "true";
      } else {
        showMsg('nick-msg', '이미 누군가 사용 중인 닉네임입니다.', true);
        document.memberForm.nickChecked.value = "false";
        document.memberForm.nickname.focus();
      }
    })
    .catch(err => console.error('닉네임 확인 에러:', err));
  }

  function memberOk() {
    const f = document.memberForm;
    const isUpdate = f.mode.value === 'update';

    if (!isUpdate && f.idChecked.value !== "true") {
      showMsg('id-msg', '아이디 중복확인이 필요합니다.', true);
      f.loginId.focus(); return;
    }

    if(f.password) {
    	const pwd = f.password.value;
        const pwdRegex = /^(?=.*[a-zA-Z])(?=.*[!@#$%^*+=-]|.*[0-9]).{5,10}$/i;
        // 수정 모드에서 비밀번호 안 입력하면 패스, 입력했으면 유효성 검사
        if (!isUpdate || pwd) {
          if (!pwdRegex.test(pwd) || pwd !== f.passwordConfirm.value) {
            showMsg('pwd-msg', '사용 불가: 비밀번호를 다시 확인해주세요.', true);
            f.password.focus(); return;
          }
        }
    }
    
    const currentNick = f.nickname.value;
    if (isUpdate && currentNick !== originalNick && f.nickChecked.value !== "true") {
      showMsg('nick-msg', '닉네임 중복확인이 필요합니다.', true);
      f.nickname.focus(); return;
    }

    if (!/^[가-힣]{2,5}$/.test(f.username.value)) {
      showMsg('info-msg', '올바른 이름을 입력해주세요.', true);
      f.username.focus(); return;
    }

    if (!f.birthday.value) {
      showMsg('info-msg', '생년월일을 선택해주세요.', true);
      f.birthday.focus(); return;
    } else { showMsg('info-msg', '', false); }

    if (!/^(010)-?\d{4}-?\d{4}$/.test(f.phoneNumber.value)) {
      showMsg('contact-msg', '올바른 전화번호를 입력해주세요 (예: 010-0000-0000).', true);
      f.phoneNumber.focus(); return;
    }

    if (!/^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/.test(f.email.value)) {
      showMsg('contact-msg', '올바른 이메일 형식을 입력해주세요.', true);
      f.email.focus(); return;
    } else { showMsg('contact-msg', '', false); }

    f.action = "${pageContext.request.contextPath}/member/${mode}";
    f.submit();
  }
</script>
</body>
</html>
