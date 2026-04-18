import promptAction from '@ohos.promptAction';
import { EmptyState } from '../components/EmptyState';
import { BoardingOrder, OrderStatus, Room } from '../model/PetBoardingModels';
import { petBoardingRepository } from '../repository/PetBoardingRepository';

@Entry
@Component
struct CheckInPage {
  @State pendingOrders: BoardingOrder[] = petBoardingRepository.listOrders(OrderStatus.PENDING);
  @State availableRooms: Room[] = petBoardingRepository.listAvailableRooms();
  @State selectedOrderId: string = '';
  @State selectedRoomId: string = '';

  aboutToAppear() {
    this.refresh();
  }

  private refresh() {
    this.pendingOrders = petBoardingRepository.listOrders(OrderStatus.PENDING);
    this.availableRooms = petBoardingRepository.listAvailableRooms();
    if (!this.pendingOrders.some((order: BoardingOrder) => order.id === this.selectedOrderId)) {
      this.selectedOrderId = '';
    }
    if (!this.availableRooms.some((room: Room) => room.id === this.selectedRoomId)) {
      this.selectedRoomId = '';
    }
  }

  private confirmCheckIn() {
    if (this.selectedOrderId.length === 0 || this.selectedRoomId.length === 0) {
      promptAction.showToast({ message: '请选择订单和房间' });
      return;
    }
    const result = petBoardingRepository.checkIn(this.selectedOrderId, this.selectedRoomId);
    promptAction.showToast({ message: result.message });
    this.refresh();
  }

  build() {
    Scroll() {
      Column({ space: 16 }) {
        Column({ space: 4 }) {
          Text('入住登记')
            .fontSize(26)
            .fontWeight(FontWeight.Bold)
            .fontColor('#101828')
          Text('选择待入住订单，再分配空闲房间。')
            .fontSize(13)
            .fontColor('#667085')
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)

        Column({ space: 12 }) {
          Text('待入住订单')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#101828')
            .width('100%')
          if (this.pendingOrders.length === 0) {
            EmptyState({ title: '暂无待入住订单', description: '请先在订单管理中创建订单。' })
          } else {
            ForEach(this.pendingOrders, (order: BoardingOrder) => {
              Column({ space: 6 }) {
                Text(`${petBoardingRepository.ownerName(order.ownerId)} / ${petBoardingRepository.petName(order.petId)}`)
                  .fontSize(17)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#101828')
                Text(order.remark)
                  .fontSize(13)
                  .fontColor('#667085')
              }
              .width('100%')
              .padding(14)
              .backgroundColor(this.selectedOrderId === order.id ? '#E7F6F1' : Color.White)
              .borderRadius(8)
              .border({ width: 1, color: this.selectedOrderId === order.id ? '#0E7C66' : '#E4E7EC' })
              .onClick(() => this.selectedOrderId = order.id)
            }, (order: BoardingOrder) => order.id)
          }
        }
        .width('100%')

        Column({ space: 12 }) {
          Text('空闲房间')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#101828')
            .width('100%')
          if (this.availableRooms.length === 0) {
            EmptyState({ title: '暂无空闲房间', description: '请先完成退房或整理房间。' })
          } else {
            Row({ space: 8 }) {
              ForEach(this.availableRooms, (room: Room) => {
                Button(room.roomNo)
                  .height(40)
                  .borderRadius(8)
                  .backgroundColor(this.selectedRoomId === room.id ? '#2F6FED' : '#EAECF0')
                  .fontColor(this.selectedRoomId === room.id ? Color.White : '#344054')
                  .onClick(() => this.selectedRoomId = room.id)
              }, (room: Room) => room.id)
            }
            .width('100%')
          }
        }
        .width('100%')
        .padding(14)
        .backgroundColor(Color.White)
        .borderRadius(8)
        .border({ width: 1, color: '#E4E7EC' })

        Button('确认入住')
          .width('100%')
          .height(48)
          .borderRadius(8)
          .backgroundColor('#0E7C66')
          .onClick(() => this.confirmCheckIn())
      }
      .padding(16)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F6F8FB')
  }
}
