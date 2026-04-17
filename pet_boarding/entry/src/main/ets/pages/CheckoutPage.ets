import promptAction from '@ohos.promptAction';
import { EmptyState } from '../components/EmptyState';
import { BoardingOrder, OrderStatus } from '../model/PetBoardingModels';
import { petBoardingRepository } from '../repository/PetBoardingRepository';

@Entry
@Component
struct CheckoutPage {
  @State checkedInOrders: BoardingOrder[] = petBoardingRepository.listOrders(OrderStatus.CHECKED_IN);

  aboutToAppear() {
    this.refresh();
  }

  private refresh() {
    this.checkedInOrders = petBoardingRepository.listOrders(OrderStatus.CHECKED_IN);
  }

  private checkout(orderId: string) {
    const result = petBoardingRepository.checkOut(orderId);
    promptAction.showToast({ message: result.message });
    this.refresh();
  }

  build() {
    Column({ space: 12 }) {
      Text('退房办理')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor('#101828')
        .width('100%')

      if (this.checkedInOrders.length === 0) {
        EmptyState({ title: '暂无寄养中订单', description: '当前没有可退房的订单' })
      } else {
        List({ space: 10 }) {
          ForEach(this.checkedInOrders, (order: BoardingOrder) => {
            ListItem() {
              Column({ space: 8 }) {
                Text(`${petBoardingRepository.ownerName(order.ownerId)} / ${petBoardingRepository.petName(order.petId)}`)
                  .fontSize(18)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#101828')
                Text(`房间：${petBoardingRepository.roomNo(order.roomId)}`)
                  .fontSize(14)
                  .fontColor('#667085')
                Text(`入住时间：${order.checkinTime}`)
                  .fontSize(14)
                  .fontColor('#667085')
                Text(order.remark)
                  .fontSize(13)
                  .fontColor('#667085')
                Button('退房')
                  .width('100%')
                  .height(42)
                  .borderRadius(8)
                  .onClick(() => this.checkout(order.id))
              }
              .width('100%')
              .padding(14)
              .backgroundColor(Color.White)
              .borderRadius(8)
            }
          }, (order: BoardingOrder) => order.id)
        }
        .layoutWeight(1)
      }
    }
    .width('100%')
    .height('100%')
    .padding(16)
    .backgroundColor('#F5F7FA')
  }
}
