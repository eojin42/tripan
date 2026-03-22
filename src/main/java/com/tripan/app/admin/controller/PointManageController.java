package com.tripan.app.admin.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@RequestMapping("/admin/point")
public class PointManageController {

    @GetMapping
    public String pointManagePage() {
        return "admin/coupon/point";
    }
}