package com.tripan.app.controller;

import com.tripan.app.domain.dto.TripDto;
import com.tripan.app.service.MyTripsService;
import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.List;

@Controller
@RequestMapping("/trip")
@RequiredArgsConstructor
public class MyTripsController {

    private final MyTripsService myTripsService;

    /**
     * GET /trip/my-trips
     * 나의 여행 목록 페이지
     */
    @GetMapping("/my_trips")
    public String myTrips(HttpSession session, Model model) {
        Long loginMemberId = getLoginMemberId(session);
       

        List<TripDto> trips = myTripsService.getMyTrips(loginMemberId);

        model.addAttribute("trips",         trips);
        model.addAttribute("loginMemberId", loginMemberId);

        // 상태별 분류
        long ongoingCount  = trips.stream().filter(t -> "ONGOING".equals(t.getStatus())).count();
        long planningCount = trips.stream().filter(t -> "PLANNING".equals(t.getStatus())).count();
        long completedCount= trips.stream().filter(t -> "COMPLETED".equals(t.getStatus())).count();

        model.addAttribute("ongoingCount",  ongoingCount);
        model.addAttribute("planningCount", planningCount);
        model.addAttribute("completedCount",completedCount);

        return "trip/my_trips";
    }

    // ───────────────────────────────
    private Long getLoginMemberId(HttpSession session) {
        Object user = session.getAttribute("loginUser");
        if (user == null) return null;
        try {
            return (Long) user.getClass().getMethod("getMemberId").invoke(user);
        } catch (Exception e) {
            return null;
        }
    }
}
