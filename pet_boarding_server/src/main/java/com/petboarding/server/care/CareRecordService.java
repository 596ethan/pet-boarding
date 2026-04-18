package com.petboarding.server.care;

import java.time.LocalDateTime;
import java.util.List;

import com.petboarding.server.care.dto.CareRecordRequest;
import com.petboarding.server.common.BusinessException;
import com.petboarding.server.common.NotFoundException;
import com.petboarding.server.order.BoardingOrder;
import com.petboarding.server.order.BoardingOrderRepository;
import com.petboarding.server.order.OrderStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class CareRecordService {

  private final CareRecordRepository careRecordRepository;
  private final BoardingOrderRepository boardingOrderRepository;

  public CareRecordService(
      CareRecordRepository careRecordRepository,
      BoardingOrderRepository boardingOrderRepository
  ) {
    this.careRecordRepository = careRecordRepository;
    this.boardingOrderRepository = boardingOrderRepository;
  }

  public List<CareRecord> list(Long orderId) {
    if (orderId == null) {
      return careRecordRepository.findAll();
    }
    return careRecordRepository.findByOrderId(orderId);
  }

  public CareRecord get(Long id) {
    return careRecordRepository.findById(id).orElseThrow(() -> new NotFoundException("Care record not found"));
  }

  @Transactional
  public CareRecord create(CareRecordRequest request) {
    ensureCheckedInOrder(request.orderId());
    CareRecord record = new CareRecord();
    apply(record, request);
    record.setRecordTime(LocalDateTime.now());
    return careRecordRepository.save(record);
  }

  @Transactional
  public CareRecord update(Long id, CareRecordRequest request) {
    ensureCheckedInOrder(request.orderId());
    CareRecord record = get(id);
    apply(record, request);
    record.setRecordTime(LocalDateTime.now());
    return careRecordRepository.save(record);
  }

  @Transactional
  public void delete(Long id) {
    careRecordRepository.delete(get(id));
  }

  private void apply(CareRecord record, CareRecordRequest request) {
    record.setOrderId(request.orderId());
    record.setType(request.type());
    record.setContent(request.content().trim());
  }

  private void ensureCheckedInOrder(Long orderId) {
    BoardingOrder order = boardingOrderRepository.findById(orderId)
        .orElseThrow(() -> new NotFoundException("Order not found"));
    if (order.getStatus() != OrderStatus.CHECKED_IN) {
      throw new BusinessException("Care records can only be added or edited for checked-in orders");
    }
  }
}
