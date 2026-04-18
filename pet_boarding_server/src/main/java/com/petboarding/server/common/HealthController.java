package com.petboarding.server.common;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class HealthController {

  @GetMapping("/api/health")
  public ApiResponse<String> health() {
    return ApiResponse.ok("Pet Boarding server is running", "UP");
  }
}
