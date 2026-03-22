package com.tripan.app.admin.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

	@Controller
	@RequestMapping("/admin/reservations")
	public class ReservationManageController {

	    @GetMapping
	    public String reservationManagePage() {
	        return "admin/reservation/main";
	    }
}