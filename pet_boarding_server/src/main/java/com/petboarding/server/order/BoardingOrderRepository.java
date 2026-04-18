package com.petboarding.server.order;

import java.time.LocalDateTime;
import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

public interface BoardingOrderRepository extends JpaRepository<BoardingOrder, Long> {

  List<BoardingOrder> findByStatus(OrderStatus status);

  boolean existsByOwnerIdAndStatusIn(Long ownerId, List<OrderStatus> statuses);

  boolean existsByPetIdAndStatusIn(Long petId, List<OrderStatus> statuses);

  boolean existsByRoomIdAndStatus(Long roomId, OrderStatus status);

  long countByStatus(OrderStatus status);

  long countByCheckinTimeBetween(LocalDateTime start, LocalDateTime end);

  long countByCheckoutTimeBetween(LocalDateTime start, LocalDateTime end);
}
