package com.tripan.app.admin.domain.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import java.time.LocalDateTime;

@Entity
@Table(name = "login_log")
@Getter @Setter
public class LoginLog {

    @Id
    @SequenceGenerator(name="LOGIN_LOG_SEQ_GEN", sequenceName="LOGIN_LOG_SEQ", allocationSize=1)
    @GeneratedValue(strategy=GenerationType.SEQUENCE, generator="LOGIN_LOG_SEQ_GEN")
    @Column(name = "log_id")
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "member_id", nullable = false)
    private Member1 member;

    @Column(name = "log_date")
    private LocalDateTime logDate;

    @Column(name = "ip_info", length = 30)
    private String ipInfo;
}