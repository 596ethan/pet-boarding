package com.petboarding.server.order;

import java.time.LocalDateTime;
import java.util.List;

import com.petboarding.server.care.CareRecordRepository;
import com.petboarding.server.common.BusinessException;
import com.petboarding.server.common.NotFoundException;
import com.petboarding.server.order.dto.CheckInRequest;
import com.petboarding.server.order.dto.OrderRequest;
import com.petboarding.server.owner.OwnerRepository;
import com.petboarding.server.pet.Pet;
import com.petboarding.server.pet.PetRepository;
import com.petboarding.server.room.Room;
import com.petboarding.server.room.RoomRepository;
import com.petboarding.server.room.RoomStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class BoardingOrderService {

  private final BoardingOrderRepository boardingOrderRepository;
  private final OwnerRepository ownerRepository;
  private final PetRepository petRepository;
  private final RoomRepository roomRepository;
  private final CareRecordRepository careRecordRepository;

  public BoardingOrderService(
      BoardingOrderRepository boardingOrderRepository,
      OwnerRepository ownerRepository,
      PetRepository petRepository,
      RoomRepository roomRepository,
      CareRecordRepository careRecordRepository
  ) {
    this.boardingOrderRepository = boardingOrderRepository;
    this.ownerRepository = ownerRepository;
    this.petRepository = petRepository;
    this.roomRepository = roomRepository;
    this.careRecordRepository = careRecordRepository;
  }

  public List<BoardingOrder> list(OrderStatus status) {
    if (status == null) {
      return boardingOrderRepository.findAll();
    }
    return boardingOrderRepository.findByStatus(status);
  }

  public BoardingOrder get(Long id) {
    return boardingOrderRepository.findById(id).orElseThrow(() -> new NotFoundException("Order not found"));
  }

  @Transactional
  public BoardingOrder create(OrderRequest request) {
    ensureOwnerAndPet(request.ownerId(), request.petId());
    BoardingOrder order = new BoardingOrder();
    order.setOwnerId(request.ownerId());
    order.setPetId(request.petId());
    order.setStatus(OrderStatus.PENDING);
    order.setRemark(request.remark() == null ? "" : request.remark().trim());
    return boardingOrderRepository.save(order);
  }

  @Transactional
  public BoardingOrder update(Long id, OrderRequest request) {
    ensureOwnerAndPet(request.ownerId(), request.petId());
    BoardingOrder order = get(id);
    if (order.getStatus() != OrderStatus.PENDING) {
      throw new BusinessException("Only pending orders can be edited");
    }
    order.setOwnerId(request.ownerId());
    order.setPetId(request.petId());
    order.setRemark(request.remark() == null ? "" : request.remark().trim());
    return boardingOrderRepository.save(order);
  }

  @Transactional
  public void delete(Long id) {
    BoardingOrder order = get(id);
    if (order.getStatus() == OrderStatus.CHECKED_IN) {
      throw new BusinessException("Checked-in orders cannot be deleted; checkout first");
    }
    careRecordRepository.deleteByOrderId(id);
    boardingOrderRepository.delete(order);
  }

  @Transactional
  public BoardingOrder checkIn(Long id, CheckInRequest request) {
    BoardingOrder order = get(id);
    Room room = roomRepository.findById(request.roomId()).orElseThrow(() -> new NotFoundException("Room not found"));
    if (order.getStatus() != OrderStatus.PENDING) {
      throw new BusinessException("Only pending orders can be checked in");
    }
    if (room.getStatus() != RoomStatus.AVAILABLE) {
      throw new BusinessException("Room is already occupied");
    }
    order.setRoomId(room.getId());
    order.setStatus(OrderStatus.CHECKED_IN);
    order.setCheckinTime(LocalDateTime.now());
    room.setStatus(RoomStatus.OCCUPIED);
    roomRepository.save(room);
    return boardingOrderRepository.save(order);
  }

  @Transactional
  public BoardingOrder checkOut(Long id) {
    BoardingOrder order = get(id);
    if (order.getStatus() != OrderStatus.CHECKED_IN) {
      throw new BusinessException("Only checked-in orders can be checked out");
    }
    order.setStatus(OrderStatus.COMPLETED);
    order.setCheckoutTime(LocalDateTime.now());
    if (order.getRoomId() != null) {
      roomRepository.findById(order.getRoomId()).ifPresent(room -> {
        room.setStatus(RoomStatus.AVAILABLE);
        roomRepository.save(room);
      });
    }
    return boardingOrderRepository.save(order);
  }

  private void ensureOwnerAndPet(Long ownerId, Long petId) {
    if (!ownerRepository.existsById(ownerId)) {
      throw new NotFoundException("Owner not found");
    }
    Pet pet = petRepository.findById(petId).orElseThrow(() -> new NotFoundException("Pet not found"));
    if (!pet.getOwnerId().equals(ownerId)) {
      throw new BusinessException("Pet does not belong to selected owner");
    }
  }
}
