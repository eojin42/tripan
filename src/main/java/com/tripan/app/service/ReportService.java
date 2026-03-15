package com.tripan.app.service;

import com.tripan.app.domain.dto.ReportDto;

public interface ReportService {
    void submitReport(ReportDto dto);
}