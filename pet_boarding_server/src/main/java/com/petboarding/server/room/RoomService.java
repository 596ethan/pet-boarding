package com.petboarding.server.room;

import java.util.List;

import com.petboarding.server.common.BusinessException;
import com.petboarding.server.common.NotFoundException;
import com.petboarding.server.order.BoardingOrderRepository;
import com.petboarding.server.order.OrderStatus;
import com.petboarding.server.room.dto.RoomRequest;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class RoomService {

  private final RoomRepository roomRepository;
  private final BoardingOrderRepository boardingOrderRepository;

  public RoomService(RoomRepository roomRepository, BoardingOrderRepository boardingOrderRepository) {
    this.roomRepository = roomRepository;
    this.boardingOrderRepository = boardingOrderRepository;
  }

  public List<Room> list(RoomStatus status) {
    if (status == null) {
      return roomRepository.findAll();
    }
    return roomRepository.findByStatus(status);
  }

  public Room get(Long id) {
    return roomRepository.findById(id).orElseThrow(() -> new NotFoundException("Room not found"));
  }

  @Transactional
  public Room create(RoomRequest request) {
    if (roomRepository.existsByRoomNo(request.roomNo().trim())) {
      throw new BusinessException("Room number already exists");
    }
    Room room = new Room();
    apply(room, request);
    return roomRepository.save(room);
  }

  @Transactional
  public Room update(Long id, RoomRequest request) {
    Room room = get(id);
    apply(room, request);
    return roomRepository.save(room);
  }

  @Transactional
  public void delete(Long id) {
    Room room = get(id);
    if (room.getStatus() == RoomStatus.OCCUPIED ||
        boardingOrderRepository.existsByRoomIdAndStatus(id, OrderStatus.CHECKED_IN)) {
      throw new BusinessException("Occupied room cannot be deleted");
    }
    roomRepository.delete(room);
  }

  private void apply(Room room, RoomRequest request) {
    room.setRoomNo(request.roomNo().trim());
    room.setStatus(request.status());
  }
}
