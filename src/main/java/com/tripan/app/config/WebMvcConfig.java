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
        // 기존 thumbnails
        registry.addResourceHandler("/dist/images/thumbnails/**")
                .addResourceLocations("file:" + uploadDir + "/");

        // 영수증 이미지 
        registry.addResourceHandler("/receipts/**")
                .addResourceLocations("file:" + System.getProperty("user.home") + "/tripan-uploads/receipts/");

        registry.addResourceHandler("/dist/**")
                .addResourceLocations("classpath:/static/dist/");
    }
}
