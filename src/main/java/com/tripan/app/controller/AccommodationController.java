package com.tripan.app.controller;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

@Controller
@RequestMapping("/accommodation/*")
public class AccommodationController {
	
	@GetMapping("home")
	public String main() {
		
		return "accommodation/home";
	}
	
	// 숙소 리스트 페이지 (지역 선택 시 이동)
    @GetMapping("/list")
    public String list(@RequestParam(value = "region", defaultValue = "서울 전체") String region, 
    		
    		Model model) {
        
        // TODO: 향후 Service를 통해 DB에서 region에 해당하는 숙소 목록을 가져오는 로직 추가
        // List<StayDTO> stayList = stayService.getStayListByRegion(region);
        // model.addAttribute("stayList", stayList);

        // 선택된 지역 이름을 뷰(jsp)로 전달
        model.addAttribute("region", region);
        
        return "accommodation/list";
    }
}
