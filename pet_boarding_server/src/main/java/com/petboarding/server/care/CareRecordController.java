package com.petboarding.server.care;

import java.util.List;

import com.petboarding.server.care.dto.CareRecordRequest;
import com.petboarding.server.common.ApiResponse;
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
@RequestMapping("/api/care-records")
public class CareRecordController {

  private final CareRecordService careRecordService;

  public CareRecordController(CareRecordService careRecordService) {
    this.careRecordService = careRecordService;
  }

  @GetMapping
  public ApiResponse<List<CareRecord>> list(@RequestParam(required = false) Long orderId) {
    return ApiResponse.ok("Care records loaded", careRecordService.list(orderId));
  }

  @GetMapping("/{id}")
  public ApiResponse<CareRecord> get(@PathVariable Long id) {
    return ApiResponse.ok("Care record loaded", careRecordService.get(id));
  }

  @PostMapping
  public ApiResponse<CareRecord> create(@Valid @RequestBody CareRecordRequest request) {
    return ApiResponse.ok("Care record created", careRecordService.create(request));
  }

  @PutMapping("/{id}")
  public ApiResponse<CareRecord> update(@PathVariable Long id, @Valid @RequestBody CareRecordRequest request) {
    return ApiResponse.ok("Care record updated", careRecordService.update(id, request));
  }

  @DeleteMapping("/{id}")
  public ApiResponse<Void> delete(@PathVariable Long id) {
    careRecordService.delete(id);
    return ApiResponse.ok("Care record deleted");
  }
}
