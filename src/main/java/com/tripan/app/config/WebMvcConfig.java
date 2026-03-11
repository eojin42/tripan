package com.tripan.app.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Configuration
public class WebMvcConfig implements WebMvcConfigurer {

    @Value("${tripan.upload.dir:${user.home}/tripan-uploads/thumbnails}")
    private String uploadDir;

    @Override
    public void addResourceHandlers(ResourceHandlerRegistry registry) {
        // 업로드된 썸네일 이미지 서빙
        // /dist/images/thumbnails/abc123.jpg → 서버 디스크 파일
        registry.addResourceHandler("/dist/images/thumbnails/**")
                .addResourceLocations("file:" + uploadDir + "/");

        // 기본 정적 리소스 (classpath)
        registry.addResourceHandler("/dist/**")
                .addResourceLocations("classpath:/static/dist/");
    }
}
