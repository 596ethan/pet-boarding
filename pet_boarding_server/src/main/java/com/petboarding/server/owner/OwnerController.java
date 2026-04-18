package com.petboarding.server.owner;

import java.util.List;

import com.petboarding.server.common.ApiResponse;
import com.petboarding.server.owner.dto.OwnerRequest;
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
@RequestMapping("/api/owners")
public class OwnerController {

  private final OwnerService ownerService;

  public OwnerController(OwnerService ownerService) {
    this.ownerService = ownerService;
  }

  @GetMapping
  public ApiResponse<List<Owner>> list(@RequestParam(required = false) String keyword) {
    return ApiResponse.ok("Owners loaded", ownerService.list(keyword));
  }

  @GetMapping("/{id}")
  public ApiResponse<Owner> get(@PathVariable Long id) {
    return ApiResponse.ok("Owner loaded", ownerService.get(id));
  }

  @PostMapping
  public ApiResponse<Owner> create(@Valid @RequestBody OwnerRequest request) {
    return ApiResponse.ok("Owner created", ownerService.create(request));
  }

  @PutMapping("/{id}")
  public ApiResponse<Owner> update(@PathVariable Long id, @Valid @RequestBody OwnerRequest request) {
    return ApiResponse.ok("Owner updated", ownerService.update(id, request));
  }

  @DeleteMapping("/{id}")
  public ApiResponse<Void> delete(@PathVariable Long id) {
    ownerService.delete(id);
    return ApiResponse.ok("Owner deleted");
  }
}
