package com.petboarding.server.order.dto;

import jakarta.validation.constraints.NotNull;

public record OrderRequest(
    @NotNull Long ownerId,
    @NotNull Long petId,
    String remark
) {
}
