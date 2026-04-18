package com.petboarding.server.pet.dto;

import java.math.BigDecimal;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

public record PetRequest(
    @NotNull Long ownerId,
    @NotBlank String name,
    @NotBlank String type,
    @NotBlank String breed,
    @NotNull @Min(0) Integer age,
    @NotNull @DecimalMin("0.1") BigDecimal weight,
    String temperament
) {
}
