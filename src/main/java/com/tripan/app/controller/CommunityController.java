package com.tripan.app.controller;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;

import jakarta.servlet.http.HttpServletRequest;
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

    @GetMapping("/fragment/{tabType}")
    public String handleFragment(@PathVariable("tabType") String tabType, HttpServletRequest request) {
    	String requestedWith = request.getHeader("X-Requested-With");
    	
    	if ("Fetch".equals(requestedWith) || "XMLHttpRequest".equals(requestedWith)) {
            return "community/fragment/" + tabType + "_list"; 
        }
    	else {
            
            if ("freeboard".equals(tabType)) {
                return "redirect:/community/freeboard";
            }
            return "redirect:/community/feed?tab=" + tabType;
        }
    }
    
    @GetMapping("/chat/openlounge")
    public String openlounge(Model model) {
        
        return "community/chat/openlounge"; 
    }
}