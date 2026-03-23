package com.tripan.app.admin.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.tripan.app.admin.domain.dto.MainBannerDto;

@Mapper
public interface BannerMapper {
	List<MainBannerDto> selectAll();
    List<MainBannerDto> selectVisible();
    MainBannerDto       selectById(int bannerId);
    int                 insert(MainBannerDto dto);
    int                 update(MainBannerDto dto);
    int                 updateVisibility(@Param("bannerId") int bannerId,
                                         @Param("isVisible") String isVisible);
    int                 delete(int bannerId);
    int                 countAll();
}
