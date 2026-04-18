package com.petboarding.server.room;

import java.util.List;

import com.petboarding.server.common.ApiResponse;
import com.petboarding.server.room.dto.RoomRequest;
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
@RequestMapping("/api/rooms")
public class RoomController {

  private final RoomService roomService;

  public RoomController(RoomService roomService) {
    this.roomService = roomService;
  }

  @GetMapping
  public ApiResponse<List<Room>> list(@RequestParam(required = false) RoomStatus status) {
    return ApiResponse.ok("Rooms loaded", roomService.list(status));
  }

  @GetMapping("/{id}")
  public ApiResponse<Room> get(@PathVariable Long id) {
    return ApiResponse.ok("Room loaded", roomService.get(id));
  }

  @PostMapping
  public ApiResponse<Room> create(@Valid @RequestBody RoomRequest request) {
    return ApiResponse.ok("Room created", roomService.create(request));
  }

  @PutMapping("/{id}")
  public ApiResponse<Room> update(@PathVariable Long id, @Valid @RequestBody RoomRequest request) {
    return ApiResponse.ok("Room updated", roomService.update(id, request));
  }

  @DeleteMapping("/{id}")
  public ApiResponse<Void> delete(@PathVariable Long id) {
    roomService.delete(id);
    return ApiResponse.ok("Room deleted");
  }
}
