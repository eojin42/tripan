package com.tripan.app.admin.domain.dto;

import java.util.Date;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class DormantMemberDto {

    private Long   memberId;
    private String email;
    private String nickname;

    /** 마지막 접속일 */
    private Date lastLoginDate;

    /** 휴면 전환일 */
    private Date dormantDate;

    /** 개인정보 파기 예정일 */
    private Date deleteScheduledDate;
}
