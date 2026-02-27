package com.tripan.app.controller;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@RequestMapping("/trip")
public class TripController {
	
	
	@GetMapping({"/trip_create"})
    public String create(Model model) {
     
        return "trip/trip_create";
    }
	
	@GetMapping({"/trip_workspace"})
    public String workspace(Model model) {
     
        return "trip/trip_workspace";
    }
	
}
