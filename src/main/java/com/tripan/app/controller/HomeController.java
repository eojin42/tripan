package com.tripan.app.controller;

import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import java.util.Comparator;
import java.util.List;
import java.util.Optional;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

import com.tripan.app.admin.service.BannerService;
import com.tripan.app.domain.dto.PlaceDto;
import com.tripan.app.domain.dto.TripDto;
import com.tripan.app.mapper.PlaceRecommendMapper;
import com.tripan.app.mapper.TripMapper;

import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Controller
@RequiredArgsConstructor
@Slf4j
public class HomeController {

    private final TripMapper tripMapper;
    private final BannerService bannerService;
    private final PlaceRecommendMapper placeMapper;
    

    @GetMapping("/start")
    public String startForGuest(HttpSession session) {
        session.setAttribute("redirectAfterLogin", "/");
        return "redirect:/member/login";
    }

    @GetMapping("/")
    public String handleHome(HttpSession session, Model model) {
    	 
    	model.addAttribute("banners", bannerService.getVisible());
    	// TOP 10 장소 (조회수 + 좋아요 합산)
    	model.addAttribute("top10Places", placeMapper.selectTop10Places());
    	
        Object loginUser = session.getAttribute("loginUser");

        // ── 5순위: 비로그인 ──
        if (loginUser == null) {
            model.addAttribute("widgetType", "GUEST");
            return "main/home";
        }

        Long memberId;
        String nickname;
        try {
            memberId = (Long) loginUser.getClass().getMethod("getMemberId").invoke(loginUser);
            nickname = (String) loginUser.getClass().getMethod("getNickname").invoke(loginUser);
        } catch (Exception e) {
            log.warn("loginUser 반사 호출 실패", e);
            model.addAttribute("widgetType", "GUEST");
            return "main/home";
        }

        model.addAttribute("loginNickname", nickname);

        List<TripDto> trips = tripMapper.selectMyTrips(memberId);

        // ── 4순위: 여행 없음 ──
        if (trips == null || trips.isEmpty()) {
            model.addAttribute("widgetType", "EMPTY");
            return "main/home";
        }

        // ── 1순위: ONGOING ──
        Optional<TripDto> ongoingTrip = trips.stream()
            .filter(t -> "ONGOING".equals(t.getStatus()))
            .min(Comparator.comparing(t -> Math.abs(ChronoUnit.DAYS.between(
                LocalDate.now(), LocalDate.parse(t.getStartDate())))));

        if (ongoingTrip.isPresent()) {
            model.addAttribute("widgetType", "ONGOING");
            model.addAttribute("representativeTrip", ongoingTrip.get());
            return "main/home";
        }

        // ── 2순위: PLANNING ──
        Optional<TripDto> planningTrip = trips.stream()
            .filter(t -> "PLANNING".equals(t.getStatus()))
            .min(Comparator.comparing(TripDto::getStartDate));

        if (planningTrip.isPresent()) {
            TripDto trip = planningTrip.get();
            long dday = ChronoUnit.DAYS.between(
                LocalDate.now(), LocalDate.parse(trip.getStartDate()));
            model.addAttribute("widgetType", "PLANNING");
            model.addAttribute("representativeTrip", trip);
            model.addAttribute("dday", dday);
            return "main/home";
        }

        // ── 3순위: 모두 COMPLETED ──
        model.addAttribute("widgetType", "COMPLETED");
        model.addAttribute("representativeTrip", trips.get(0));
        return "main/home";
    }
}
