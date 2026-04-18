package com.petboarding.server.common;

public class BusinessException extends RuntimeException {

  public BusinessException(String message) {
    super(message);
  }
}
