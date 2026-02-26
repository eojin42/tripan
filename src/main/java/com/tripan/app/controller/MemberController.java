package com.tripan.app.controller;

import java.util.HashMap;
import java.util.Map;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.tripan.app.domain.dto.MemberDto;
import com.tripan.app.service.MemberService;

import jakarta.servlet.http.HttpServletRequest; // 💡 추가!
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Controller
@RequiredArgsConstructor
@Slf4j
@RequestMapping(value = "/member/*")
public class MemberController {
	private final MemberService service;
	
	@Value("${file.upload-root}/member")
	private String uploadPath;
	
	@RequestMapping(value = "login", method = {RequestMethod.GET, RequestMethod.POST})
	public String loginForm(HttpServletRequest req, 
            @RequestParam(name = "error", required = false) String error, 
			Model model) {
		
        String referer = req.getHeader("Referer");
        if (referer != null && !referer.contains("/member/login")) {
            req.getSession().setAttribute("prevPage", referer);
        }

		if(error != null) {
			model.addAttribute("message", "아이디 또는 패스워드가 일치하지 않습니다.");
		}
		
		return "member/login";
	}
	
	@GetMapping("account")
	public String memberForm(Model model) {
		
		model.addAttribute("mode", "account");
		
		return "member/member";
	}
	
	@PostMapping("account")
	public String memberSubmit(MemberDto dto,
			Model model,
			final RedirectAttributes rAttr) {
		
		try {
			
			service.insertMember(dto, uploadPath);
			
			StringBuilder sb = new StringBuilder();
			sb.append(dto.getName() + "님의 회원 가입이 정상적으로 처리되었습니다.<br>");
			sb.append("메인화면으로 이동하여 로그인 하시기 바랍니다.<br>");

			// 리다이렉트된 페이지에 값 넘기기
			rAttr.addFlashAttribute("message", sb.toString());
			rAttr.addFlashAttribute("title", "회원 가입");

			return "redirect:/member/complete";
			
		} catch (Exception e) {
			model.addAttribute("mode", "account");
			model.addAttribute("message", "회원가입이 실패했습니다.");
		}
		
		
		return "member/member";
	}
	
	@ResponseBody
	@PostMapping("userIdCheck")
	public Map<String, ?> handleUserIdCheck(@RequestParam(name = "loginId") String loginId) throws Exception {
		// ID 중복 검사
		Map<String, Object> model = new HashMap<>();
		
		String p = "false";
		try {
			MemberDto dto = service.findById(loginId);
			if (dto == null) {
				p = "true";
			}
		} catch (Exception e) {
		}
		
		model.put("passed", p);
		
		return model;
	}
}