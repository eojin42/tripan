package com.tripan.app.admin.domain.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import java.time.LocalDateTime;

@Entity
@Table(name = "booking")
@Getter
@Setter
public class Booking {

	@Id
    @SequenceGenerator(
        name = "BOOKING_SEQ_GEN",sequenceName = "BOOKING_SEQ",
        initialValue = 1, allocationSize = 1
    )
	
    @GeneratedValue(
        strategy = GenerationType.SEQUENCE, 
        generator = "BOOKING_SEQ_GEN"
    )
    private Long id;

    @Column(unique = true, nullable = false)
    private String resId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "member_id")
    private Member1 member;

    private String roomName;
    private String checkIn;
    private String checkOut;
    private Long totalPrice;
    
    private Integer status;

    private LocalDateTime regDate;
}