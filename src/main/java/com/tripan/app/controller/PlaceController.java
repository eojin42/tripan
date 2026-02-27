package com.tripan.app.controller;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@RequestMapping("/curation")
public class PlaceController {
	
    @GetMapping({"/magazine_list"})
    public String magazine_list(Model model) {
     
        return "curation/magazine_list";
    }
    

    @GetMapping({"/detail"})
    public String detail(Model model) {
     
        return "curation/detail";
    }
    
    @GetMapping({"/place_list"})
    public String place_list(Model model) {
     
        return "curation/place_list";
    }
}
