package com.tripan.app.controller;

import java.util.HashMap;
import java.util.Map;
import java.util.Objects;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.tripan.app.domain.dto.MemberDto;
import com.tripan.app.domain.dto.SessionInfo;
import com.tripan.app.security.LoginMemberUtil;
import com.tripan.app.service.MemberService;

import jakarta.servlet.http.HttpServletRequest; // 💡 추가!
import jakarta.servlet.http.HttpSession;
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
	
	@GetMapping("complete")
	public String complete(@ModelAttribute("message")String message)throws Exception{
		if(message==null || message.isBlank()) {
			return "redirect:/";
		}
		return "member/complete";
	}
	
	@GetMapping("pwd")
	public String pwdForm(@RequestParam(name = "dropout", required = false) String dropout, 
			Model model) {
		if(dropout == null) {
			model.addAttribute("mode", "update");
		}else {
			model.addAttribute("mode", "dropout");
		}
		return "member/pwd";
	}
							
	@PostMapping("pwd")
	public String pwdSubmit(@RequestParam(name = "password") String password,
			@RequestParam(name = "mode") String mode, 
			final RedirectAttributes reAttr,
			Model model) {

		try {
			SessionInfo info = LoginMemberUtil.getsessionInfo();
			MemberDto dto = Objects.requireNonNull(service.findById(info.getMemberId()));

			boolean bPwd = service.isPasswordCheck(info.getLoginId(), password);
			
			if (! bPwd) {
				model.addAttribute("mode", mode);
				model.addAttribute("message", "패스워드가 일치하지 않습니다.");
				
				return "member/pwd";
			}

			if (mode.equals("dropout")) {
				// 게시판 테이블등 자료 삭제

				// 회원탈퇴 처리
				/*
				  Map<String, Object> map = new HashMap<>();
				  map.put("member_id", info.getMember_id());
				  map.put("filename", info.getAvatar());
				 */

				LoginMemberUtil.logout();
				
				StringBuilder sb = new StringBuilder();
				sb.append(dto.getName() + "님의 회원 탈퇴 처리가 정상적으로 처리되었습니다.<br>");
				sb.append("메인화면으로 이동 하시기 바랍니다.<br>");

				reAttr.addFlashAttribute("title", "회원 탈퇴");
				reAttr.addFlashAttribute("message", sb.toString());

				return "redirect:/member/complete";
			}

			model.addAttribute("dto", dto);
			model.addAttribute("mode", "update");
			
			return "member/member";
			
		} catch (NullPointerException e) {
			LoginMemberUtil.logout();
		} catch (Exception e) {
		}
		
		return "redirect:/";
	}
	@PostMapping("update")
	public String updateSubmit(MemberDto dto, final RedirectAttributes reAttr,
			Model model) throws Exception {
		
		StringBuilder sb = new StringBuilder();
		
		try {
			SessionInfo info = LoginMemberUtil.getsessionInfo();
			dto.setMemberId(info.getMemberId());
			
			service.updateMember(dto, uploadPath);
			
			info.setAvatar(dto.getProfilePhoto());
			
			sb.append(dto.getName() + "님의 회원정보가 정상적으로 변경되었습니다.<br>");
			sb.append("메인화면으로 이동 하시기 바랍니다.<br>");
		} catch (Exception e) {
			sb.append(dto.getName() + "님의 회원정보 변경이 실패했습니다.<br>");
			sb.append("잠시후 다시 변경 하시기 바랍니다.<br>");
		}
		
		reAttr.addFlashAttribute("title", "회원 정보 수정");
		reAttr.addFlashAttribute("message", sb.toString());
		
		return "redirect:/member/complete";
	}
	
	@GetMapping("pwdFind")
	public String pwdFindForm(HttpSession session) throws Exception{
		SessionInfo info = LoginMemberUtil.getsessionInfo();
		
		if(info != null) {
			return "redirect:/";
		}
		
		return "member/pwdFind";
	}
	
	public String pwdFindSubmit(@RequestParam(name="loginId") String loginId, 
			final RedirectAttributes reAttr, Model model) throws Exception{
		try {
			MemberDto dto = service.findById(loginId);
			if(dto == null || dto.getEmail()==null || dto.getStatus()==0) {
				model.addAttribute("message", "등록된 아이디가 아닙니다.");
				return "member/pwdFind";
			}
			service.generatePwd(dto);
			
			StringBuilder sb = new StringBuilder();
			sb.append("회원님의 이메일로 임시패스워드를 전송했습니다.<br>");
			sb.append("로그인 후 패스워드를 변경하시기 바랍니다.<br>");
			
			reAttr.addFlashAttribute("title","패스워드 찾기");
			reAttr.addFlashAttribute("message", sb.toString());
			
			return "redirect:/member/complete";
			
		} catch (Exception e) {
			model.addAttribute("message", "이메일 전송이 실패했습니다.");
		}
		
		return "member/pwdFind";
	}
	
	@GetMapping("noAuthorized")
	public String noAuthorized(Model model) {
		// 권한이 없는 경우
		return "member/noAuthorized";
	}

	@GetMapping("expired")
	public String expired() throws Exception {
		// 세션이 익스파이어드(만료) 된 경우
		return "member/expired";
	}	
}