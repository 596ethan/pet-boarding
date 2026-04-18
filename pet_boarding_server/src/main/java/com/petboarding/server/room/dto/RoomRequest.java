package com.petboarding.server.room.dto;

import com.petboarding.server.room.RoomStatus;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

public record RoomRequest(
    @NotBlank String roomNo,
    @NotNull RoomStatus status
) {
}
