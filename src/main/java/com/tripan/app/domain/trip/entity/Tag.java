package com.tripan.app.domain.trip.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

@Entity
@Table(name = "tag")
@Getter @Setter
public class Tag { // 태그

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "tag_id")
    private Long tagId; // 태그 PK

    @Column(name = "tag_name", nullable = false, length = 30, unique = true)
    private String tagName; // 태그 이름
}