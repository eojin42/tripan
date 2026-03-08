package com.tripan.app.controller;

import java.util.List;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.tripan.app.domain.dto.AccommodationDetailDto;
import com.tripan.app.domain.dto.AccommodationDto;
import com.tripan.app.domain.dto.AdSearchConditionDto;
import com.tripan.app.domain.dto.RoomDto;
import com.tripan.app.service.AccommodationService;

import lombok.RequiredArgsConstructor;

@Controller
@RequestMapping("/accommodation/*")
@RequiredArgsConstructor
public class AccommodationController {
	private final AccommodationService accommodationService;
	
	@GetMapping("home")
	public String main() {
		
		return "accommodation/home";
	}
	
	// 숙소 리스트 페이지 (지역 선택 시 이동)
    @GetMapping("/list")
    public String list(@RequestParam(value = "region", defaultValue = "서울 전체") String region,
    		Model model) {
        
        model.addAttribute("region", region);
        
        return "accommodation/list";
    }
    
    @PostMapping("/search")
    @ResponseBody 
    public List<AccommodationDto> searchAccommodations(@RequestBody AdSearchConditionDto condition) {

        return accommodationService.searchAccommodations(condition);
    }
    
    @GetMapping("/detail/{id}")
    public String detail(@PathVariable("id") Long id, Model model) {
        
        AccommodationDetailDto detail = accommodationService.getAccommodationDetail(id);
        
        model.addAttribute("detail", detail);
        
        return "accommodation/detail";
    }
}
