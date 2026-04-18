package com.petboarding.server.pet;

import java.util.List;

import com.petboarding.server.common.ApiResponse;
import com.petboarding.server.pet.dto.PetRequest;
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
@RequestMapping("/api/pets")
public class PetController {

  private final PetService petService;

  public PetController(PetService petService) {
    this.petService = petService;
  }

  @GetMapping
  public ApiResponse<List<Pet>> list(@RequestParam(required = false) String keyword) {
    return ApiResponse.ok("Pets loaded", petService.list(keyword));
  }

  @GetMapping("/{id}")
  public ApiResponse<Pet> get(@PathVariable Long id) {
    return ApiResponse.ok("Pet loaded", petService.get(id));
  }

  @PostMapping
  public ApiResponse<Pet> create(@Valid @RequestBody PetRequest request) {
    return ApiResponse.ok("Pet created", petService.create(request));
  }

  @PutMapping("/{id}")
  public ApiResponse<Pet> update(@PathVariable Long id, @Valid @RequestBody PetRequest request) {
    return ApiResponse.ok("Pet updated", petService.update(id, request));
  }

  @DeleteMapping("/{id}")
  public ApiResponse<Void> delete(@PathVariable Long id) {
    petService.delete(id);
    return ApiResponse.ok("Pet deleted");
  }
}
