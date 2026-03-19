package com.tripan.app.admin.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@RequestMapping("/admin/partner")
public class PartnerManageController {

    @GetMapping("/main")
    public String main() {
        return "admin/partner/main";
    }

    @GetMapping("/apply")
    public String apply() {
        return "admin/partner/apply";
    }

    @GetMapping("/detail")
    public String detail() {
        return "admin/partner/detail";
    }
}
