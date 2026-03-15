package com.tripan.app.service;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import com.tripan.app.domain.dto.ReportDto;
import com.tripan.app.mapper.ReportMapper;
import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class ReportServiceImpl implements ReportService {

    private final ReportMapper reportMapper;

    @Override
    @Transactional
    public void submitReport(ReportDto dto) {
        reportMapper.insertReport(dto);
    }
}