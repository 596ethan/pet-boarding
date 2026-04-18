package com.petboarding.server.order.dto;

import jakarta.validation.constraints.NotNull;

public record CheckInRequest(@NotNull Long roomId) {
}
