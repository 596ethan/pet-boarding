package com.petboarding.server.auth;

import com.petboarding.server.auth.dto.LoginRequest;
import com.petboarding.server.auth.dto.LoginResponse;
import com.petboarding.server.common.BusinessException;
import com.petboarding.server.user.AppUser;
import com.petboarding.server.user.AppUserRepository;
import org.springframework.stereotype.Service;

@Service
public class AuthService {

  private final AppUserRepository appUserRepository;

  public AuthService(AppUserRepository appUserRepository) {
    this.appUserRepository = appUserRepository;
  }

  public LoginResponse login(LoginRequest request) {
    AppUser user = appUserRepository.findByUsernameAndPassword(request.username(), request.password())
        .orElseThrow(() -> new BusinessException("Invalid username or password"));
    return new LoginResponse(user.getId(), user.getUsername(), user.getDisplayName(), user.getToken());
  }
}
