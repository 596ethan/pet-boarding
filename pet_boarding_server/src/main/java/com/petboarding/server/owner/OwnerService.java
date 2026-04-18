package com.petboarding.server.owner;

import java.util.List;

import com.petboarding.server.common.BusinessException;
import com.petboarding.server.common.NotFoundException;
import com.petboarding.server.order.BoardingOrderRepository;
import com.petboarding.server.order.OrderStatus;
import com.petboarding.server.owner.dto.OwnerRequest;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class OwnerService {

  private static final List<OrderStatus> OPEN_STATUSES = List.of(OrderStatus.PENDING, OrderStatus.CHECKED_IN);

  private final OwnerRepository ownerRepository;
  private final BoardingOrderRepository boardingOrderRepository;

  public OwnerService(OwnerRepository ownerRepository, BoardingOrderRepository boardingOrderRepository) {
    this.ownerRepository = ownerRepository;
    this.boardingOrderRepository = boardingOrderRepository;
  }

  public List<Owner> list(String keyword) {
    if (keyword == null || keyword.isBlank()) {
      return ownerRepository.findAll();
    }
    return ownerRepository.findByNameContainingIgnoreCaseOrPhoneContaining(keyword.trim(), keyword.trim());
  }

  public Owner get(Long id) {
    return ownerRepository.findById(id).orElseThrow(() -> new NotFoundException("Owner not found"));
  }

  @Transactional
  public Owner create(OwnerRequest request) {
    Owner owner = new Owner();
    apply(owner, request);
    return ownerRepository.save(owner);
  }

  @Transactional
  public Owner update(Long id, OwnerRequest request) {
    Owner owner = get(id);
    apply(owner, request);
    return ownerRepository.save(owner);
  }

  @Transactional
  public void delete(Long id) {
    Owner owner = get(id);
    if (boardingOrderRepository.existsByOwnerIdAndStatusIn(owner.getId(), OPEN_STATUSES)) {
      throw new BusinessException("Owner has unfinished orders and cannot be deleted");
    }
    ownerRepository.delete(owner);
  }

  private void apply(Owner owner, OwnerRequest request) {
    owner.setName(request.name().trim());
    owner.setPhone(request.phone().trim());
    owner.setRemark(request.remark() == null ? "" : request.remark().trim());
  }
}
