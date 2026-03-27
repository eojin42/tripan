package com.tripan.app.security;

import java.util.Collections;
import java.util.Map;
import java.util.UUID;

import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.oauth2.client.userinfo.DefaultOAuth2UserService;
import org.springframework.security.oauth2.client.userinfo.OAuth2UserRequest;
import org.springframework.security.oauth2.core.OAuth2AuthenticationException;
import org.springframework.security.oauth2.core.user.OAuth2User;
import org.springframework.stereotype.Service;

import com.tripan.app.domain.dto.MemberDto;
import com.tripan.app.domain.dto.SessionInfo;
import com.tripan.app.service.MemberService;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@Service
@RequiredArgsConstructor
public class CustomOAuth2UserService extends DefaultOAuth2UserService{
	private final MemberService memberService;
	private final PasswordEncoder passwordEncoder;
	
	@Override
    public OAuth2User loadUser(OAuth2UserRequest userRequest) throws OAuth2AuthenticationException {
        OAuth2User oAuth2User = super.loadUser(userRequest);
        Map<String, Object> attributes = oAuth2User.getAttributes();
        
        Map<String, Object> kakaoAccount = (Map<String, Object>) attributes.get("kakao_account");
        Map<String, Object> profile = (Map<String, Object>) kakaoAccount.get("profile");

        String providerId = String.valueOf(attributes.get("id")); // 카카오 고유 ID
        String email = (String) kakaoAccount.get("email");
        String realName = (String) kakaoAccount.get("name");
        String nickname = (String) profile.get("nickname");
        String profileImage = (String) profile.get("profile_image_url");
        String kakaoBirthyear = (String) kakaoAccount.get("birthyear"); 
        String kakaoBirthday = (String) kakaoAccount.get("birthday");
        
        MemberDto savedMember = memberService.findByProviderId("KAKAO", providerId);

        SessionInfo sessionInfo = new SessionInfo();

        if (savedMember == null) {
            MemberDto newDto = new MemberDto();
            newDto.setEmail(email);
            newDto.setLoginId("K_" + providerId);
            
            String dummyPassword = UUID.randomUUID().toString();
            newDto.setPassword(passwordEncoder.encode(dummyPassword));
            
            newDto.setName(realName);
            newDto.setNickname(nickname);
            newDto.setProfilePhoto(profileImage);
            newDto.setProvider("KAKAO");
            newDto.setProviderId(providerId);
            
            if (kakaoBirthyear != null && kakaoBirthday != null && kakaoBirthday.length() == 4) {
                String formattedDate = kakaoBirthyear + "-" 
                                     + kakaoBirthday.substring(0, 2) + "-" 
                                     + kakaoBirthday.substring(2, 4);
                newDto.setBirthday(formattedDate);
            } else {
                newDto.setBirthday("9999-01-01");
            }
            
            try {
                memberService.insertSnsMember(newDto); 
                
                sessionInfo.setMemberId(newDto.getMemberId());
                sessionInfo.setLoginId(email);
                sessionInfo.setRole("ROLE_USER");
                
            } catch (Exception e) {
                log.error("SNS 회원가입 실패", e);
                throw new OAuth2AuthenticationException("회원가입 처리 중 오류 발생");
            }
        } else {
            sessionInfo.setMemberId(savedMember.getMemberId());
            sessionInfo.setLoginId(savedMember.getLoginId());
            sessionInfo.setRole(savedMember.getRole());
            sessionInfo.setProvider(savedMember.getProvider());
        }

        return CustomUserDetails.builder()
                .sessionInfo(sessionInfo)
                .roles(Collections.singletonList(sessionInfo.getRole()))
                .attributes(attributes) 
                .disabled(false)
                .build();
    }
}

