package com.tripan.app.controller;

import com.tripan.app.security.CustomUserDetails;
import com.tripan.app.service.MyTripsService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ModelAttribute;

@ControllerAdvice
@RequiredArgsConstructor
public class GlobalModelAdvice {

    private final MyTripsService myTripsService;

    @ModelAttribute("myTripCount")
    public int getMyTripCount(@AuthenticationPrincipal CustomUserDetails userDetails) {
        if (userDetails != null) {
            return myTripsService.getMyTrips(userDetails.getMember().getMemberId()).size();
        }
        return 0;
    }
}