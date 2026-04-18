package com.petboarding.server.pet;

import java.util.List;

import com.petboarding.server.common.BusinessException;
import com.petboarding.server.common.NotFoundException;
import com.petboarding.server.order.BoardingOrderRepository;
import com.petboarding.server.order.OrderStatus;
import com.petboarding.server.owner.OwnerRepository;
import com.petboarding.server.pet.dto.PetRequest;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class PetService {

  private static final List<OrderStatus> OPEN_STATUSES = List.of(OrderStatus.PENDING, OrderStatus.CHECKED_IN);

  private final PetRepository petRepository;
  private final OwnerRepository ownerRepository;
  private final BoardingOrderRepository boardingOrderRepository;

  public PetService(
      PetRepository petRepository,
      OwnerRepository ownerRepository,
      BoardingOrderRepository boardingOrderRepository
  ) {
    this.petRepository = petRepository;
    this.ownerRepository = ownerRepository;
    this.boardingOrderRepository = boardingOrderRepository;
  }

  public List<Pet> list(String keyword) {
    if (keyword == null || keyword.isBlank()) {
      return petRepository.findAll();
    }
    String text = keyword.trim();
    return petRepository.findByNameContainingIgnoreCaseOrTypeContainingIgnoreCaseOrBreedContainingIgnoreCase(text, text, text);
  }

  public Pet get(Long id) {
    return petRepository.findById(id).orElseThrow(() -> new NotFoundException("Pet not found"));
  }

  @Transactional
  public Pet create(PetRequest request) {
    ensureOwnerExists(request.ownerId());
    Pet pet = new Pet();
    apply(pet, request);
    return petRepository.save(pet);
  }

  @Transactional
  public Pet update(Long id, PetRequest request) {
    ensureOwnerExists(request.ownerId());
    Pet pet = get(id);
    apply(pet, request);
    return petRepository.save(pet);
  }

  @Transactional
  public void delete(Long id) {
    Pet pet = get(id);
    if (boardingOrderRepository.existsByPetIdAndStatusIn(pet.getId(), OPEN_STATUSES)) {
      throw new BusinessException("Pet has unfinished orders and cannot be deleted");
    }
    petRepository.delete(pet);
  }

  private void apply(Pet pet, PetRequest request) {
    pet.setOwnerId(request.ownerId());
    pet.setName(request.name().trim());
    pet.setType(request.type().trim());
    pet.setBreed(request.breed().trim());
    pet.setAge(request.age());
    pet.setWeight(request.weight());
    pet.setTemperament(request.temperament() == null ? "" : request.temperament().trim());
  }

  private void ensureOwnerExists(Long ownerId) {
    if (!ownerRepository.existsById(ownerId)) {
      throw new NotFoundException("Owner not found");
    }
  }
}
