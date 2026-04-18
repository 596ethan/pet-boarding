package com.petboarding.server.auth.dto;

public record LoginResponse(
    Long userId,
    String username,
    String displayName,
    String token
) {
}
