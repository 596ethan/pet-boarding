package com.petboarding.server.dashboard.dto;

public record DashboardMetrics(
    long boardingNow,
    long todayCheckins,
    long todayCheckouts,
    long availableRooms
) {
}
