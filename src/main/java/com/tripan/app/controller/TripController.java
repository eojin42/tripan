package com.tripan.app.controller;

import com.tripan.app.domain.dto.TripCreateDto;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@Controller
@RequestMapping("/trip")
public class TripController {

    @GetMapping("/trip_create")
    public String create(Model model) {
        return "trip/trip_create";
    }

    @GetMapping("/trip_workspace")
    public String workspace(Model model) {
        return "trip/workspace";
    }

    @PostMapping("/create")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> createTrip(@RequestBody TripCreateDto dto) {
        // TODO: TripService.createTrip(dto, loginMemberId) 연결
        System.out.println("[TripController] 여행 생성: " + dto.getTitle()
            + " / " + dto.getStartDate() + "~" + dto.getEndDate()
            + " / 도시: " + dto.getCities());

        return ResponseEntity.ok(Map.of("success", true));
    }
}
