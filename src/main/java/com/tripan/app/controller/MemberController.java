package com.tripan.app.controller;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;

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
}