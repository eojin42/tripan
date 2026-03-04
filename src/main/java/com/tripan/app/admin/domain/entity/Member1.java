package com.tripan.app.admin.domain.entity;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

@Entity
@Table(name = "member1")
@Getter @Setter
public class Member1 {

	@Id
    @SequenceGenerator(name="MEMBER1_SEQ_GEN", sequenceName="MEMBER1_SEQ", allocationSize=1)
    @GeneratedValue(strategy=GenerationType.SEQUENCE, generator="MEMBER1_SEQ_GEN")
    @Column(name = "member_id", nullable = false)
    private Long id;

    @Column(name = "login_id", length = 20, nullable = false)
    private String loginId;

    @Column(length = 100, nullable = false, unique = true)
    private String email;

    @Column(length = 255, nullable = false)
    private String password;

    @Column(length = 50, nullable = false)
    private String username;

    // 1: ACTIVE, 0: INACTIVE
    @Column(nullable = false)
    private Integer status;

    // ADMIN, USER, PARTNER 등
    @Column(length = 20, nullable = false)
    private String role;

    @Column(length = 10)
    private String gender;

    @Column(name = "failure_cnt")
    private Integer failureCnt;

    @Column(length = 20)
    private String provider;

    @Column(name = "provider_id", length = 255)
    private String providerId;

    @Column(length = 10)
    private String birthday;
}