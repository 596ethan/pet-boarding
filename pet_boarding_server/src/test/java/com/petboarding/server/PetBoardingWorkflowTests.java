package com.petboarding.server;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import java.math.BigDecimal;

import com.petboarding.server.auth.AuthService;
import com.petboarding.server.auth.dto.LoginRequest;
import com.petboarding.server.auth.dto.LoginResponse;
import com.petboarding.server.care.CareRecord;
import com.petboarding.server.care.CareRecordService;
import com.petboarding.server.care.CareRecordType;
import com.petboarding.server.care.dto.CareRecordRequest;
import com.petboarding.server.common.BusinessException;
import com.petboarding.server.dashboard.DashboardService;
import com.petboarding.server.dashboard.dto.DashboardMetrics;
import com.petboarding.server.order.BoardingOrder;
import com.petboarding.server.order.BoardingOrderService;
import com.petboarding.server.order.OrderStatus;
import com.petboarding.server.order.dto.CheckInRequest;
import com.petboarding.server.order.dto.OrderRequest;
import com.petboarding.server.owner.Owner;
import com.petboarding.server.owner.OwnerService;
import com.petboarding.server.owner.dto.OwnerRequest;
import com.petboarding.server.pet.Pet;
import com.petboarding.server.pet.PetService;
import com.petboarding.server.pet.dto.PetRequest;
import com.petboarding.server.room.Room;
import com.petboarding.server.room.RoomService;
import com.petboarding.server.room.RoomStatus;
import com.petboarding.server.room.dto.RoomRequest;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.transaction.annotation.Transactional;

@SpringBootTest
@ActiveProfiles("test")
@Transactional
class PetBoardingWorkflowTests {

  @Autowired
  private AuthService authService;

  @Autowired
  private OwnerService ownerService;

  @Autowired
  private PetService petService;

  @Autowired
  private RoomService roomService;

  @Autowired
  private BoardingOrderService boardingOrderService;

  @Autowired
  private CareRecordService careRecordService;

  @Autowired
  private DashboardService dashboardService;

  @Test
  @DisplayName("Login should return demo token and reject invalid credentials")
  void loginShouldReturnDemoTokenAndRejectInvalidCredentials() {
    LoginResponse response = authService.login(new LoginRequest("admin", "123456"));

    assertThat(response.username()).isEqualTo("admin");
    assertThat(response.token()).isEqualTo("demo-token-admin");
    assertThatThrownBy(() -> authService.login(new LoginRequest("admin", "bad-password")))
        .isInstanceOf(BusinessException.class)
        .hasMessageContaining("Invalid username or password");
  }

  @Test
  @DisplayName("Owner, pet, and room CRUD should support basic demo maintenance")
  void ownerPetRoomCrudShouldSupportBasicDemoMaintenance() {
    Owner owner = ownerService.create(new OwnerRequest("Wang Lei", "13800010099", "Demo owner"));
    Owner updatedOwner = ownerService.update(owner.getId(), new OwnerRequest("Wang Lei Updated", "13800010098", ""));

    Pet pet = petService.create(new PetRequest(
        updatedOwner.getId(),
        "Doudou",
        "Dog",
        "Poodle",
        5,
        new BigDecimal("6.50"),
        "Gentle"
    ));
    Pet updatedPet = petService.update(pet.getId(), new PetRequest(
        updatedOwner.getId(),
        "Doudou Updated",
        "Dog",
        "Poodle",
        5,
        new BigDecimal("6.80"),
        "Gentle"
    ));

    Room room = roomService.create(new RoomRequest("C301", RoomStatus.AVAILABLE));
    Room updatedRoom = roomService.update(room.getId(), new RoomRequest("C302", RoomStatus.AVAILABLE));

    assertThat(updatedOwner.getName()).isEqualTo("Wang Lei Updated");
    assertThat(updatedPet.getName()).isEqualTo("Doudou Updated");
    assertThat(updatedRoom.getRoomNo()).isEqualTo("C302");

    roomService.delete(updatedRoom.getId());
    petService.delete(updatedPet.getId());
    ownerService.delete(updatedOwner.getId());

    assertThat(roomService.list(null)).extracting(Room::getRoomNo).doesNotContain("C302");
    assertThat(petService.list(null)).extracting(Pet::getId).doesNotContain(updatedPet.getId());
    assertThat(ownerService.list(null)).extracting(Owner::getId).doesNotContain(updatedOwner.getId());
  }

  @Test
  @DisplayName("Owner and pet deletion should be blocked when unfinished orders exist")
  void ownerAndPetDeletionShouldBeBlockedWhenUnfinishedOrdersExist() {
    assertThatThrownBy(() -> ownerService.delete(2L))
        .isInstanceOf(BusinessException.class)
        .hasMessageContaining("unfinished orders");

    assertThatThrownBy(() -> petService.delete(2L))
        .isInstanceOf(BusinessException.class)
        .hasMessageContaining("unfinished orders");
  }

  @Test
  @DisplayName("Check-in should reject occupied rooms and occupy an available room")
  void checkInShouldRejectOccupiedRoomsAndOccupyAvailableRoom() {
    BoardingOrder pendingOrder = boardingOrderService.create(new OrderRequest(2L, 2L, "Needs a quiet room"));

    assertThatThrownBy(() -> boardingOrderService.checkIn(pendingOrder.getId(), new CheckInRequest(1L)))
        .isInstanceOf(BusinessException.class)
        .hasMessageContaining("already occupied");

    BoardingOrder checkedIn = boardingOrderService.checkIn(pendingOrder.getId(), new CheckInRequest(2L));
    Room assignedRoom = roomService.get(2L);

    assertThat(checkedIn.getStatus()).isEqualTo(OrderStatus.CHECKED_IN);
    assertThat(checkedIn.getRoomId()).isEqualTo(2L);
    assertThat(assignedRoom.getStatus()).isEqualTo(RoomStatus.OCCUPIED);
  }

  @Test
  @DisplayName("Care records should only be added for checked-in orders")
  void careRecordsShouldOnlyBeAddedForCheckedInOrders() {
    assertThatThrownBy(() -> careRecordService.create(new CareRecordRequest(3L, CareRecordType.NOTE, "Late note")))
        .isInstanceOf(BusinessException.class)
        .hasMessageContaining("checked-in orders");

    CareRecord record = careRecordService.create(new CareRecordRequest(1L, CareRecordType.FEEDING, "Lunch completed"));

    assertThat(record.getOrderId()).isEqualTo(1L);
    assertThat(record.getType()).isEqualTo(CareRecordType.FEEDING);
  }

  @Test
  @DisplayName("Checkout should complete the order and release its room")
  void checkoutShouldCompleteOrderAndReleaseRoom() {
    BoardingOrder completed = boardingOrderService.checkOut(1L);
    Room room = roomService.get(1L);

    assertThat(completed.getStatus()).isEqualTo(OrderStatus.COMPLETED);
    assertThat(completed.getCheckoutTime()).isNotNull();
    assertThat(room.getStatus()).isEqualTo(RoomStatus.AVAILABLE);

    assertThatThrownBy(() -> careRecordService.create(new CareRecordRequest(1L, CareRecordType.NOTE, "After checkout")))
        .isInstanceOf(BusinessException.class)
        .hasMessageContaining("checked-in orders");
  }

  @Test
  @DisplayName("Completed history and dashboard metrics should reflect MVP workflow state")
  void completedHistoryAndDashboardMetricsShouldReflectWorkflowState() {
    assertThat(boardingOrderService.list(OrderStatus.COMPLETED))
        .allMatch(order -> order.getStatus() == OrderStatus.COMPLETED);

    DashboardMetrics metrics = dashboardService.metrics();

    assertThat(metrics.boardingNow()).isEqualTo(1);
    assertThat(metrics.availableRooms()).isEqualTo(3);
    assertThat(metrics.todayCheckins()).isGreaterThanOrEqualTo(1);
    assertThat(metrics.todayCheckouts()).isGreaterThanOrEqualTo(1);
  }
}
