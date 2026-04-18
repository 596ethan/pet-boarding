package com.petboarding.server.order;

import java.util.List;

import com.petboarding.server.common.ApiResponse;
import com.petboarding.server.order.dto.CheckInRequest;
import com.petboarding.server.order.dto.OrderRequest;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/orders")
public class BoardingOrderController {

  private final BoardingOrderService boardingOrderService;

  public BoardingOrderController(BoardingOrderService boardingOrderService) {
    this.boardingOrderService = boardingOrderService;
  }

  @GetMapping
  public ApiResponse<List<BoardingOrder>> list(@RequestParam(required = false) OrderStatus status) {
    return ApiResponse.ok("Orders loaded", boardingOrderService.list(status));
  }

  @GetMapping("/{id}")
  public ApiResponse<BoardingOrder> get(@PathVariable Long id) {
    return ApiResponse.ok("Order loaded", boardingOrderService.get(id));
  }

  @PostMapping
  public ApiResponse<BoardingOrder> create(@Valid @RequestBody OrderRequest request) {
    return ApiResponse.ok("Order created", boardingOrderService.create(request));
  }

  @PutMapping("/{id}")
  public ApiResponse<BoardingOrder> update(@PathVariable Long id, @Valid @RequestBody OrderRequest request) {
    return ApiResponse.ok("Order updated", boardingOrderService.update(id, request));
  }

  @DeleteMapping("/{id}")
  public ApiResponse<Void> delete(@PathVariable Long id) {
    boardingOrderService.delete(id);
    return ApiResponse.ok("Order deleted");
  }

  @PostMapping("/{id}/check-in")
  public ApiResponse<BoardingOrder> checkIn(@PathVariable Long id, @Valid @RequestBody CheckInRequest request) {
    return ApiResponse.ok("Check-in completed", boardingOrderService.checkIn(id, request));
  }

  @PostMapping("/{id}/checkout")
  public ApiResponse<BoardingOrder> checkOut(@PathVariable Long id) {
    return ApiResponse.ok("Checkout completed", boardingOrderService.checkOut(id));
  }
}
