package com.petboarding.server.room;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

public interface RoomRepository extends JpaRepository<Room, Long> {

  List<Room> findByStatus(RoomStatus status);

  long countByStatus(RoomStatus status);

  boolean existsByRoomNo(String roomNo);
}
