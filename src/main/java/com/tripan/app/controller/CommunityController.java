package com.tripan.app.controller;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Controller
@RequestMapping("/community")
@RequiredArgsConstructor
@Slf4j
public class CommunityController {

    @GetMapping({"", "/", "/feed"})
    public String handleCommunityFeed(Model model) {

    	return "community/feed";
    	
    }

    @GetMapping("/freeboard")
    public String handleCommunityFreeboard(Model model) {

    	model.addAttribute("activeTab", "freeboard");
    	
        return "community/feed"; 
    }

    @GetMapping("/fragment/feed")
    public String fragmentFeed(Model model) {
        
        return "community/fragment/feed_list"; 
    }

    @GetMapping("/fragment/hot")
    public String fragmentHot(Model model) {
        
        return "community/fragment/hot_list"; 
    }

    @GetMapping("/fragment/freeboard")
    public String fragmentFreeboard(Model model) {
        
        return "community/fragment/freeboard_list"; 
    }
    
    @GetMapping("/chat/openlounge")
    public String openlounge(Model model) {
        
        return "community/chat/openlounge"; 
    }
}