package com.tripan.app.controller;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@RequestMapping("/feed")
public class FeedController {
	
	
	@GetMapping({"/feed_list"})
    public String feed_list(Model model) {
     
        return "feed/feed_list";
    }
	
	@GetMapping({"/feed_detail"})
    public String feed_detail(Model model) {
     
        return "feed/feed_detail";
    }
	
	

}
