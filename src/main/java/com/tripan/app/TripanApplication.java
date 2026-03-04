package com.tripan.app;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableScheduling;

@SpringBootApplication
@EnableScheduling
public class TripanApplication {

	public static void main(String[] args) {
		SpringApplication.run(TripanApplication.class, args);
	}

}
