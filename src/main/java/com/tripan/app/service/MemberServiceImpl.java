package com.tripan.app.service;

import java.security.SecureRandom;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.Objects;

import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.tripan.app.admin.domain.entity.Member1;
import com.tripan.app.admin.domain.entity.Member2;
import com.tripan.app.domain.entity.MemberStatus;
import com.tripan.app.common.StorageService;
import com.tripan.app.domain.dto.MemberDto;
import com.tripan.app.mail.Mail;
import com.tripan.app.mail.MailSender;
import com.tripan.app.mapper.MemberMapper;
import com.tripan.app.repository.Member2Repository;
import com.tripan.app.repository.MemberRepository;
import com.tripan.app.repository.MemberStatusRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Service
@RequiredArgsConstructor
@Slf4j
public class MemberServiceImpl implements MemberService {

    private final MemberMapper mapper;
    private final MemberRepository memberRepository;
    private final Member2Repository member2Repository;
    private final MemberStatusRepository memberStatusRepository;
    private final StorageService storageService;
    private final PasswordEncoder bcryptEncoder;
    private final MailSender mailSender;

    // SNS 로그인 조회
    @Override
    public MemberDto loginSnsMember(Map<String, Object> map) {
        MemberDto dto = null;
        try {
            dto = mapper.loginSnsMember(map);
        } catch (Exception e) {
            log.info("loginSnsMember : ", e);
        }
        return dto;
    }

    // 일반 회원가입
    @Transactional(rollbackFor = {Exception.class})
    @Override
    public void insertMember(MemberDto dto, String uploadPath) throws Exception {
        try {
            if (dto.getSelectFile() != null && !dto.getSelectFile().isEmpty()) {
                String saveFilename = storageService.uploadFileToServer(dto.getSelectFile(), uploadPath);
                dto.setProfilePhoto(saveFilename);
            }

            String encPassword = bcryptEncoder.encode(dto.getPassword());

            Member1 member1 = new Member1();
            member1.setLoginId(dto.getLoginId());
            member1.setEmail(dto.getEmail());
            member1.setPassword(encPassword);
            member1.setUsername(dto.getUsername());
            member1.setStatus(1);
            member1.setRole("ROLE_USER");
            member1.setGender(dto.getGender());
            member1.setBirthday(dto.getBirthday());
            member1.setFailureCnt(0);
            memberRepository.save(member1);

            Member2 member2 = new Member2();
            member2.setMember1(member1);
            member2.setNickname(dto.getNickname());
            member2.setProfileImage(dto.getProfilePhoto());
            member2.setPhoneNumber(dto.getPhoneNumber());
            member2Repository.save(member2);

        } catch (Exception e) {
            log.info("insertMember : ", e);
            throw e;
        }
    }

    // SNS 회원가입
    @Transactional(rollbackFor = {Exception.class})
    @Override
    public void insertSnsMember(MemberDto dto) throws Exception {
        try {
            Member1 member1 = new Member1();
            member1.setLoginId(dto.getLoginId() != null ? dto.getLoginId() : dto.getEmail());
            member1.setEmail(dto.getEmail());
            member1.setPassword("");
            member1.setUsername(dto.getName());
            member1.setStatus(1);
            member1.setRole("ROLE_USER");
            member1.setProvider(dto.getSnsProvider());
            member1.setProviderId(dto.getSnsId());
            member1.setFailureCnt(0);
            memberRepository.save(member1);

            Member2 member2 = new Member2();
            member2.setMember1(member1);
            member2.setNickname(dto.getNickname());
            member2.setProfileImage(dto.getProfilePhoto());
            member2.setPhoneNumber(dto.getPhoneNumber());
            member2Repository.save(member2);

            dto.setMemberId(member1.getId());

        } catch (Exception e) {
            log.info("insertSnsMember : ", e);
            throw e;
        }
    }

    // 회원 상태 로그 저장
    @Override
    public void insertMemberStatus(MemberDto dto) throws Exception {
        try {
            MemberStatus memberStatus = new MemberStatus();
            memberStatus.setNum(dto.getMemberId());
            memberStatus.setStatus(dto.getStatus());
            memberStatusRepository.save(memberStatus);
        } catch (Exception e) {
            log.info("insertMemberStatus : ", e);
            throw e;
        }
    }

    // 패스워드 변경
    @Override
    public void updatePassword(MemberDto dto) throws Exception {
        if (isPasswordCheck(dto.getLoginId(), dto.getPassword())) {
            throw new RuntimeException("패스워드가 기존 패스워드와 일치합니다.");
        }
        try {
            String encPassword = bcryptEncoder.encode(dto.getPassword());
            memberRepository.updatePassword(dto.getLoginId(), encPassword);
        } catch (Exception e) {
            log.info("updatePassword : ", e);
            throw e;
        }
    }

    // 계정 활성/비활성 변경
    @Override
    public void updateMemberEnabled(Map<String, Object> map) throws Exception {
        try {
            Long memberId = (Long) map.get("memberId");
            Integer status = (Integer) map.get("enabled");
            memberRepository.updateStatus(memberId, status);
        } catch (Exception e) {
            log.info("updateMemberEnabled : ", e);
            throw e;
        }
    }

    // 회원정보 수정
    @Transactional(rollbackFor = {Exception.class})
    @Override
    public void updateMember(MemberDto dto, String uploadPath) throws Exception {
        try {
            if (dto.getSelectFile() != null && !dto.getSelectFile().isEmpty()) {
                if (dto.getProfilePhoto() != null && !dto.getProfilePhoto().isBlank()) {
                    storageService.deleteFile(uploadPath, dto.getProfilePhoto());
                }
                String saveFilename = storageService.uploadFileToServer(dto.getSelectFile(), uploadPath);
                dto.setProfilePhoto(saveFilename);
                member2Repository.updateProfileImage(dto.getMemberId(), dto.getProfilePhoto());
            }

            boolean bPwdUpdate = !isPasswordCheck(dto.getLoginId(), dto.getPassword());
            if (bPwdUpdate) {
                String encPassword = bcryptEncoder.encode(dto.getPassword());
                memberRepository.updatePassword(dto.getLoginId(), encPassword);
            }

            member2Repository.updateProfile(
                dto.getMemberId(),
                dto.getNickname(),
                dto.getBio(),
                dto.getPhoneNumber(),
                dto.getPreferredRegion()
            );

        } catch (Exception e) {
            log.info("updateMember : ", e);
            throw e;
        }
    }

    // 마지막 로그인 시간 갱신
    @Override
    public void updateLastLogin(Long memberId) throws Exception {
        try {
            member2Repository.updateLastLoginAt(memberId, LocalDateTime.now());
        } catch (Exception e) {
            log.info("updateLastLogin : ", e);
            throw e;
        }
    }

    @Override
    public void updateLastLogin(String loginId) throws Exception {
        try {
            Long memberId = mapper.getMemberId(loginId);
            if (memberId != null) {
                member2Repository.updateLastLoginAt(memberId, LocalDateTime.now());
            }
        } catch (Exception e) {
            log.info("updateLastLogin : ", e);
            throw e;
        }
    }

    // 로그인 실패 횟수 증가
    @Override
    public void updateFailureCount(String loginId) throws Exception {
        try {
            memberRepository.incrementFailureCount(loginId);
        } catch (Exception e) {
            log.info("updateFailureCount : ", e);
            throw e;
        }
    }

    // 로그인 실패 횟수 초기화
    @Override
    public void updateFailureCountReset(String loginId) throws Exception {
        try {
            memberRepository.resetFailureCount(loginId);
        } catch (Exception e) {
            log.info("updateFailureCountReset : ", e);
            throw e;
        }
    }

    // 회원 탈퇴
    @Transactional(rollbackFor = {Exception.class})
    @Override
    public void deleteMember(Map<String, Object> map, String uploadPath) throws Exception {
        try {
            mapper.deleteAuthority(map);

            Long memberId = (Long) map.get("memberId");
            memberRepository.updateStatus(memberId, 0);

            String filename = (String) map.get("filename");
            if (filename != null && !filename.isBlank()) {
                storageService.deleteFile(uploadPath, filename);
            }

            member2Repository.deleteById(memberId);

        } catch (Exception e) {
            log.info("deleteMember : ", e);
            throw e;
        }
    }

    // 프로필 이미지 삭제
    @Override
    public void deleteProfilePhoto(Map<String, Object> map, String uploadPath) throws Exception {
        try {
            String filename = (String) map.get("filename");
            if (filename != null && !filename.isBlank()) {
                storageService.deleteFile(uploadPath, filename);
            }
            Long memberId = (Long) map.get("memberId");
            member2Repository.updateProfileImage(memberId, null);
        } catch (Exception e) {
            log.info("deleteProfilePhoto : ", e);
            throw e;
        }
    }

    // 임시 패스워드 발급 및 메일 발송
    @Override
    public void generatePwd(MemberDto dto) throws Exception {
        String lowercase          = "abcdefghijklmnopqrstuvwxyz";
        String uppercase          = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
        String digits             = "0123456789";
        String specialChars       = "!#@$%^&*()-_=+[]{}?";
        String allChars           = lowercase + digits + uppercase + specialChars;

        try {
            SecureRandom random = new SecureRandom();
            StringBuilder sb = new StringBuilder();

            sb.append(lowercase.charAt(random.nextInt(lowercase.length())));
            sb.append(uppercase.charAt(random.nextInt(uppercase.length())));
            sb.append(digits.charAt(random.nextInt(digits.length())));
            sb.append(specialChars.charAt(random.nextInt(specialChars.length())));

            for (int i = sb.length(); i < 10; i++) {
                sb.append(allChars.charAt(random.nextInt(allChars.length())));
            }

            StringBuilder password = new StringBuilder();
            while (sb.length() > 0) {
                int index = random.nextInt(sb.length());
                password.append(sb.charAt(index));
                sb.deleteCharAt(index);
            }

            Mail mail = new Mail();
            mail.setReceiverEmail(dto.getEmail());
            mail.setSenderEmail("메일설정이메일@도메인");
            mail.setSenderName("관리자");
            mail.setSubject("임시 패스워드 발급");
            mail.setContent(dto.getName() + "님의 새로 발급된 임시 패스워드는 <b> "
                    + password + " </b> 입니다.<br>로그인 후 반드시 패스워드를 변경하시기 바랍니다.");

            String encPassword = bcryptEncoder.encode(password.toString());
            memberRepository.updatePassword(dto.getLoginId(), encPassword);
            memberRepository.resetFailureCount(dto.getLoginId());

            boolean b = mailSender.mailSend(mail);
            if (!b) throw new Exception("이메일 전송중 오류가 발생했습니다.");

        } catch (Exception e) {
            log.info("generatePwd : ", e);
            throw e;
        }
    }

    // 회원 목록 조회
    @Override
    public List<MemberDto> listFindMember(Map<String, Object> map) {
        List<MemberDto> list = null;
        try {
            list = mapper.listFindMember(map);
        } catch (Exception e) {
            log.info("listFindMember : ", e);
        }
        return list;
    }

    // 권한 조회
    @Override
    public String findByAuthority(String loginId) {
        String authority = null;
        try {
            authority = mapper.findByAuthority(loginId);
        } catch (Exception e) {
            log.info("findByAuthority : ", e);
        }
        return authority;
    }

    // 회원 조회 (ID)
    @Override
    public MemberDto findById(Long memberId) {
        MemberDto dto = null;
        try {
            dto = Objects.requireNonNull(mapper.findById(memberId));
        } catch (NullPointerException | ArrayIndexOutOfBoundsException e) {
        } catch (Exception e) {
            log.info("findById : ", e);
        }
        return dto;
    }

    // 회원 조회 (로그인 ID)
    @Override
    public MemberDto findById(String loginId) {
        MemberDto dto = null;
        try {
            dto = Objects.requireNonNull(mapper.findByLoginId(loginId));
        } catch (NullPointerException e) {
        } catch (Exception e) {
            log.info("findById : ", e);
        }
        return dto;
    }

    // memberId 조회
    @Override
    public Long getMemberId(String loginId) {
        try {
            return Objects.requireNonNull(mapper.getMemberId(loginId));
        } catch (Exception e) {
            log.info("getMemberId : ", e);
        }
        return 0L;
    }

    // 실패 횟수 조회
    @Override
    public int checkFailureCount(String loginId) {
        int result = 0;
        try {
            result = mapper.checkFailureCount(loginId);
        } catch (Exception e) {
            log.info("checkFailureCount : ", e);
        }
        return result;
    }

    // 패스워드 일치 여부 확인
    @Override
    public boolean isPasswordCheck(String loginId, String password) {
        try {
            MemberDto dto = Objects.requireNonNull(findById(loginId));
            return bcryptEncoder.matches(password, dto.getPassword());
        } catch (Exception e) {
        }
        return false;
    }
    

	@Override
	public MemberDto findByNickname(String nickname) {
		return mapper.findByNickname(nickname);
	}

	
    
}