function previewImage(input) {
    if (input.files && input.files[0]) {
        var reader = new FileReader();
        reader.onload = function(e) {
            document.getElementById('imgPreview').innerHTML = '<img src="' + e.target.result + '" style="width:100%; height:100%; object-fit:cover; border-radius: 12px;">';
        };
        reader.readAsDataURL(input.files[0]);
    }
}

function execDaumPostcode() {
    new daum.Postcode({
        oncomplete: function(data) {
            var roadAddr = data.roadAddress; 
            var zonecode = data.zonecode;    
            
            document.getElementById("baseAddress").value = `[${zonecode}] ${roadAddr}`;
            
            document.getElementById("detailAddress").value = "";
            document.getElementById("detailAddress").focus();
        }
    }).open();
}

function initPartnerInfoEditor() {
    if (document.getElementById('partnerIntroEditor') && !window.partnerQuill) {
        window.partnerQuill = new Quill('#partnerIntroEditor', {
            theme: 'snow',
            placeholder: '우리 스테이만의 감성과 스토리를 자유롭게 작성해 보세요.',
            modules: {
                toolbar: [
                    [{ 'header': [1, 2, 3, false] }],
                    ['bold', 'italic', 'underline', 'strike'],
                    [{ 'color': [] }, { 'background': [] }],
                    [{ 'list': 'ordered'}, { 'list': 'bullet' }],
                    ['link', 'image'] 
                ]
            }
        });

        window.partnerQuill.on('text-change', function() {
            var html = window.partnerQuill.root.innerHTML;
            document.getElementById('partnerIntro').value = (html === '<p><br></p>') ? '' : html;
        });
        
        document.getElementById('partnerIntro').value = window.partnerQuill.root.innerHTML;
    }
}
document.addEventListener("DOMContentLoaded", initPartnerInfoEditor);
initPartnerInfoEditor();

function savePartnerInfo() {
    const baseAddr = document.getElementById("baseAddress").value;
    const detailAddr = document.getElementById("detailAddress").value;
    
    if (detailAddr.trim() !== "") {
        document.getElementById("realAddress").value = baseAddr + ", " + detailAddr;
    } else {
        document.getElementById("realAddress").value = baseAddr;
    }

    if(window.partnerQuill) {
        document.getElementById('partnerIntro').value = window.partnerQuill.root.innerHTML;
    }

    const form = document.getElementById('partnerInfoForm');
    const formData = new FormData(form);

    formData.delete("detailAddress");

    fetch(TripanConfig.contextPath + '/partner/api/info/update', {
        method: 'POST',
        headers: { 'AJAX': 'true' }, 
        body: formData
    })
    .then(res => {
        if (res.status === 401) {
            showToast('세션이 만료되었습니다. 로그인 페이지로 이동합니다.', 'error');
            setTimeout(() => { location.href = TripanConfig.contextPath + '/partner/login'; }, 1500);
            throw new Error('Session Expired');
        }
        return res.json();
    })
    .then(resData => {
        if(resData.message === 'success' || resData.success) {
            showToast('성공적으로 저장되었습니다! 🎉', 'success');
        } else {
            showToast('저장에 실패했습니다.', 'error');
        }
    })
    .catch(error => {
        console.error('Error:', error);
        if(error.message !== 'Session Expired') {
            showToast('서버 통신 중 오류가 발생했습니다.', 'error');
        }
    });
}

document.addEventListener("DOMContentLoaded", () => {
	const baseInput = document.getElementById("baseAddress");
	const detailInput = document.getElementById("detailAddress");
	
	if (baseInput && baseInput.value && baseInput.value.includes(", ")) {
		const parts = baseInput.value.split(", ");
		const detail = parts.pop();
		
		baseInput.value = parts.join(", ");
		if (detailInput) {
			detailInput.value = detail;
		}
	}
});