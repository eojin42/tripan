package com.tripan.app.domain.entity;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import java.time.LocalDateTime;

import com.tripan.app.admin.domain.entity.Member1;

@Entity
@Table(name = "MEMBERSTATUS")
@Getter @Setter
public class MemberStatus {

    @Id
    @SequenceGenerator(name="MEMBERSTATUS_SEQ_GEN", sequenceName="MEMBERSTATUS_SEQ", allocationSize=1)
    @GeneratedValue(strategy=GenerationType.SEQUENCE, generator="MEMBERSTATUS_SEQ_GEN")
    private Long num;

    // 상태가 변경된 대상 회원
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "member_id", nullable = false)
    private Member1 targetMember;

    // 1: 정상, 2: 활동 정지(Ban), 3: 휴면, 4: 탈퇴
    @Column(name = "status_code", nullable = false)
    private Integer status;

    @Lob
    private String memo;

    @Column(name = "reg_date")
    private LocalDateTime regDate;

    // 이 상태 이력을 등록한 사람 (member_id와 연결되는 제약조건)
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "register_id")
    private Member1 registerMember; 
}