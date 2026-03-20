package com.tripan.app.mail;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import lombok.RequiredArgsConstructor;

@Controller
@RequiredArgsConstructor
@RequestMapping("/mail/*")
public class MailController {
	private final MailSender mailSender;
	
	@GetMapping("send")
	public String sendForm(Model model) throws Exception {

		return "mail/send";
	}

	@PostMapping("send")
	public String sendSubmit(Mail dto, 
			final RedirectAttributes reAttr) throws Exception {

		dto.setSenderEmail("amandaejk@gmail.com");
		// dto.setSenderEmail("네이버아이디@naver.com");

		dto.setContent(dto.getContent().replaceAll("\n", "<br>"));
		 
		boolean b = mailSender.mailSend(dto);
		
		String msg = "<span style='color:blue;'>" + dto.getReceiverEmail() + "</span> 님에게<br>";
		if( b ) {
			msg += "메일을 성공적으로 전송 했습니다.";
		} else {
			msg += "메일을 전송하는데 실패했습니다.";
		}
		
		reAttr.addFlashAttribute("message", msg);
		
		return "redirect:/mail/complete";
	}
	
	@GetMapping("complete")
	public String complete(@ModelAttribute("message") String message) throws Exception{
		
		// 컴플릿 페이지(complete.jsp)의 출력되는 message와 title는 RedirectAttributes 값이다. 
		// F5를 눌러 새로 고침을 하면 null이 된다.
		
		if(message == null || message.length() == 0) // F5를 누른 경우
			return "redirect:/";
		
		return "mail/complete";
	}
	
	// 테스트용 임시 
	@GetMapping("test-partner")
	@ResponseBody
	public String testPartnerMail(@RequestParam(name = "name", defaultValue = "테스트파트너") String name) {
	    Mail dto = new Mail();
	    dto.setSenderEmail("amandaejk@gmail.com");
	    dto.setSenderName("TRIPAN");
	    dto.setReceiverEmail("amandaejk@gmail.com"); 
	    dto.setSubject(PartnerMailTemplates.approveSubject());
	    dto.setContent(PartnerMailTemplates.approveContent(name, 5.0, new java.util.Date()));
	    dto.setSavePathname(new java.util.ArrayList<>());
	    
	    boolean b = mailSender.mailSend(dto);
	    return b ? "✅ 발송 성공" : "❌ 발송 실패";
	}
}
