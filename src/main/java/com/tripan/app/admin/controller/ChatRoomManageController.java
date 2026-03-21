package com.tripan.app.admin.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

import lombok.RequiredArgsConstructor;

@Controller
@RequestMapping("/admin/chat")
@RequiredArgsConstructor
public class ChatRoomManageController {
 
    @GetMapping("/rooms")
    public String chatRoomManagePage() {
        return "admin/cs/chatRoomManage";
    }
}
