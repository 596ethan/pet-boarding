package com.petboarding.server.user;

import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

public interface AppUserRepository extends JpaRepository<AppUser, Long> {

  Optional<AppUser> findByUsernameAndPassword(String username, String password);

  boolean existsByToken(String token);
}
