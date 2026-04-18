package com.petboarding.server.care.dto;

import com.petboarding.server.care.CareRecordType;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

public record CareRecordRequest(
    @NotNull Long orderId,
    @NotNull CareRecordType type,
    @NotBlank String content
) {
}
