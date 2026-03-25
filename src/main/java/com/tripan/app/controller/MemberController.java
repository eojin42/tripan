package com.tripan.app.controller;

import java.util.HashMap;
import java.util.Map;
import java.util.Objects;

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

import com.tripan.app.admin.domain.entity.Member1;
import com.tripan.app.domain.dto.MemberDto;
import com.tripan.app.domain.dto.SessionInfo;
import com.tripan.app.security.LoginMemberUtil;
import com.tripan.app.service.MemberCouponService;
import com.tripan.app.service.MemberService;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Controller
@RequiredArgsConstructor
@Slf4j
@RequestMapping(value = "/member/*")
public class MemberController {

    private final MemberService service;
    private final MemberCouponService couponService;

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
        if (error != null) {
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
    public String memberSubmit(MemberDto dto, Model model, final RedirectAttributes rAttr, HttpSession session) {
        try {
            service.insertMember(dto, uploadPath);

            Member1 savedMember = new Member1();
            savedMember.setId(dto.getMemberId());
            couponService.issueWelcomeCoupon(savedMember);

            session.invalidate();
            rAttr.addFlashAttribute("title", "회원 가입 완료!");
            rAttr.addFlashAttribute("message", dto.getUsername() + "님, 회원가입이 완료되었습니다! <br>메인화면으로 이동 하여 로그인해주시기 바랍니다.<br>"); 
            return "redirect:/member/complete";

        } catch (Exception e) {
            log.error("회원가입 처리 중 오류", e);
            model.addAttribute("mode", "account");
            model.addAttribute("title", "회원가입 실패!");
            model.addAttribute("isError", true);
        }
        return "member/member";
    }

    /* ── 아래는 기존 코드 그대로 유지 ── */

    @ResponseBody
    @PostMapping("userIdCheck")
    public Map<String, ?> handleUserIdCheck(@RequestParam(name = "loginId") String loginId) throws Exception {
        Map<String, Object> model = new HashMap<>();
        String p = "false";
        try {
            MemberDto dto = service.findById(loginId);
            if (dto == null) p = "true";
        } catch (Exception e) {
            log.error("ID 중복 체크 중 에러 발생", e);
        }
        model.put("passed", p);
        return model;
    }

    @ResponseBody
    @PostMapping("nicknameCheck")
    public Map<String, ?> checkNickname(@RequestParam(name = "nickname") String nickname) throws Exception {
        Map<String, Object> model = new HashMap<>();
        String p = "false";
        try {
            MemberDto dto = service.findByNickname(nickname);
            SessionInfo info = LoginMemberUtil.getsessionInfo();
            if (dto == null || (info != null && dto.getMemberId().equals(info.getMemberId()))) 
            	p = "true";
        } catch (Exception e) {
            log.error("닉네임 중복 체크 중 에러 발생", e);
        }
        model.put("passed", p);
        return model;
    }

    @GetMapping("complete")
    public String complete(Model model) {
        String title = (String) model.asMap().get("title");
        if (title == null || title.isBlank()) return "redirect:/";
        return "member/complete";
    }

    @GetMapping("pwd")
    public String pwdForm(@RequestParam(name = "dropout", required = false) String dropout, Model model) {
        model.addAttribute("mode", dropout == null ? "update" : "dropout");
        return "member/pwd";
    }

    @PostMapping("pwd")
    public String pwdSubmit(@RequestParam(name = "password") String password,
            @RequestParam(name = "mode") String mode,
            final RedirectAttributes reAttr, Model model) {
        try {
            SessionInfo info = LoginMemberUtil.getsessionInfo();
            MemberDto dto = Objects.requireNonNull(service.findById(info.getMemberId()));
            boolean bPwd = service.isPasswordCheck(info.getMemberId(), password);
            if (!bPwd) {
                model.addAttribute("mode", mode);
                model.addAttribute("message", "패스워드가 일치하지 않습니다.");
                return "member/pwd";
            }
            if (mode.equals("dropout")) {
                LoginMemberUtil.logout();
                reAttr.addFlashAttribute("title", "회원 탈퇴");
                reAttr.addFlashAttribute("message",
                        dto.getName() + "님의 회원 탈퇴 처리가 정상적으로 처리되었습니다.<br>메인화면으로 이동 하시기 바랍니다.<br>");
                return "redirect:/member/complete";
            }
            model.addAttribute("dto", dto);
            model.addAttribute("mode", "update");
            return "member/member";
        } catch (NullPointerException e) {
            LoginMemberUtil.logout();
        } catch (Exception e) {
            log.error("비밀번호 확인 중 에러 발생", e);
        }
        return "redirect:/";
    }

    @PostMapping("update")
    public String updateSubmit(MemberDto dto, final RedirectAttributes reAttr, Model model, HttpSession session) throws Exception {
        StringBuilder sb = new StringBuilder();
        try {
            SessionInfo info = LoginMemberUtil.getsessionInfo();
            dto.setMemberId(info.getMemberId());
            service.updateMember(dto, uploadPath);
            info.setAvatar(dto.getProfilePhoto());
            
            MemberDto updatedDto = service.findById(info.getMemberId());
   
            session.setAttribute("loginUser", updatedDto); 
            
            sb.append(dto.getUsername()).append("님의 회원정보가 정상적으로 변경되었습니다.<br>메인화면으로 이동 하시기 바랍니다.<br>");
            reAttr.addFlashAttribute("title", "회원정보수정 완료!"); 
            reAttr.addFlashAttribute("showLogin", false);
        } catch (Exception e) {
            sb.append("회원정보 변경이 실패했습니다.<br>잠시후 다시 변경 하시기 바랍니다.<br>");
            reAttr.addFlashAttribute("title", "회원정보수정 실패"); 
            reAttr.addFlashAttribute("isError", true);
            reAttr.addFlashAttribute("showLogin", false);
            log.error("회원정보 수정 중 에러 발생", e);
        }
        reAttr.addFlashAttribute("message", sb.toString());
        return "redirect:/member/complete";
    }

    @GetMapping("pwdFind")
    public String pwdFindForm(HttpSession session) throws Exception {
        if (LoginMemberUtil.getsessionInfo() != null) return "redirect:/";
        return "member/pwdFind";
    }

    @PostMapping("pwdFind")
    public String pwdFindSubmit(@RequestParam(name = "loginId") String loginId,
            final RedirectAttributes reAttr, Model model) throws Exception {
        try {
            MemberDto dto = service.findById(loginId);
            if (dto == null || dto.getEmail() == null || dto.getStatus() == 0) {
                model.addAttribute("message", "등록된 아이디가 아닙니다.");
                return "member/pwdFind";
            }
            service.generatePwd(dto);
            reAttr.addFlashAttribute("title", "패스워드 찾기");
            reAttr.addFlashAttribute("message",
                    "회원님의 이메일로 임시패스워드를 전송했습니다.<br>로그인 후 패스워드를 변경하시기 바랍니다.<br>");
            return "redirect:/member/complete";
        } catch (Exception e) {
            log.error("비밀번호 찾기 메일 전송 실패", e);
            model.addAttribute("message", "이메일 전송이 실패했습니다.");
        }
        return "member/pwdFind";
    }

    @ResponseBody
    @PostMapping("deleteProfile")
    public Map<String, ?> deleteProfilePhoto(@RequestParam(name = "profile_photo") String profile_photo) {
        Map<String, Object> model = new HashMap<>();
        SessionInfo info = LoginMemberUtil.getsessionInfo();
        String state = "false";
        try {
            if (!profile_photo.isBlank()) {
                Map<String, Object> map = new HashMap<>();
                map.put("member_id", info.getMemberId());
                map.put("filename", info.getAvatar());
                service.deleteProfilePhoto(map, uploadPath);
                info.setAvatar("");
                state = "true";
            }
        } catch (Exception e) {
            log.error("프로필 사진 삭제 오류", e);
        }
        model.put("state", state);
        return model;
    }

    @GetMapping("noAuthorized")
    public String noAuthorized(Model model) {
        return "member/noAuthorized";
    }

    @GetMapping("expired")
    public String expired() throws Exception {
        return "member/expired";
    }
}