package com.tripan.app.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/regions")
public class RegionApiController {

    @Autowired
    private JdbcTemplate jdbcTemplate;

    @GetMapping("/sido")
    public List<Map<String, Object>> getSidoList() {
        String sql = "SELECT region_id AS \"regionId\", sido_name AS \"name\" " +
                     "FROM region " +
                     "WHERE api_sigungu_code IS NULL AND api_area_code IS NOT NULL " +
                     "ORDER BY api_area_code ASC";
        
        return jdbcTemplate.queryForList(sql);
    }
}