package com.petboarding.server.owner;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

public interface OwnerRepository extends JpaRepository<Owner, Long> {

  List<Owner> findByNameContainingIgnoreCaseOrPhoneContaining(String name, String phone);
}
