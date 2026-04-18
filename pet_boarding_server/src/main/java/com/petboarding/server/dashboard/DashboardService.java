package com.petboarding.server.dashboard;

import java.time.LocalDate;
import java.time.LocalDateTime;

import com.petboarding.server.dashboard.dto.DashboardMetrics;
import com.petboarding.server.order.BoardingOrderRepository;
import com.petboarding.server.order.OrderStatus;
import com.petboarding.server.room.RoomRepository;
import com.petboarding.server.room.RoomStatus;
import org.springframework.stereotype.Service;

@Service
public class DashboardService {

  private final BoardingOrderRepository boardingOrderRepository;
  private final RoomRepository roomRepository;

  public DashboardService(BoardingOrderRepository boardingOrderRepository, RoomRepository roomRepository) {
    this.boardingOrderRepository = boardingOrderRepository;
    this.roomRepository = roomRepository;
  }

  public DashboardMetrics metrics() {
    LocalDate today = LocalDate.now();
    LocalDateTime start = today.atStartOfDay();
    LocalDateTime end = today.plusDays(1).atStartOfDay();
    return new DashboardMetrics(
        boardingOrderRepository.countByStatus(OrderStatus.CHECKED_IN),
        boardingOrderRepository.countByCheckinTimeBetween(start, end),
        boardingOrderRepository.countByCheckoutTimeBetween(start, end),
        roomRepository.countByStatus(RoomStatus.AVAILABLE)
    );
  }
}
