package com.tripan.app.domain.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ConquestDto {
	private Long conquestMapId;
	private Long memberId;
	private String sidoName;    // 매퍼에서 region 테이블과 조인용
    private String sigunguName; // 시/군/구 이름
    private String colorCode;
    private String startDate;   // yyyy-MM-dd 형태
    private String endDate;
    private String memo;
    private String photoPath;
}
