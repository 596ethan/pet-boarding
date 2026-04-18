package com.petboarding.server.config;

import com.petboarding.server.user.AppUserRepository;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Component;
import org.springframework.web.servlet.HandlerInterceptor;

@Component
public class AuthInterceptor implements HandlerInterceptor {

  private static final String BEARER_PREFIX = "Bearer ";

  private final AppUserRepository appUserRepository;

  public AuthInterceptor(AppUserRepository appUserRepository) {
    this.appUserRepository = appUserRepository;
  }

  @Override
  public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) {
    String header = request.getHeader(HttpHeaders.AUTHORIZATION);
    if (header == null || !header.startsWith(BEARER_PREFIX)) {
      response.setStatus(HttpStatus.UNAUTHORIZED.value());
      return false;
    }
    String token = header.substring(BEARER_PREFIX.length());
    if (appUserRepository.existsByToken(token)) {
      return true;
    }
    response.setStatus(HttpStatus.UNAUTHORIZED.value());
    return false;
  }
}
