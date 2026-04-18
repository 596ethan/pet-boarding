package com.petboarding.server.care;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

public interface CareRecordRepository extends JpaRepository<CareRecord, Long> {

  List<CareRecord> findByOrderId(Long orderId);

  void deleteByOrderId(Long orderId);
}
