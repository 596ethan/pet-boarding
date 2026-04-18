package com.petboarding.server.owner.dto;

import jakarta.validation.constraints.NotBlank;

public record OwnerRequest(
    @NotBlank String name,
    @NotBlank String phone,
    String remark
) {
}
