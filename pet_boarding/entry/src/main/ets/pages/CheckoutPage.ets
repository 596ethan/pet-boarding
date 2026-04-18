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

  private confirmCheckout(order: BoardingOrder) {
    AlertDialog.show({
      title: '确认退房',
      message: `${petBoardingRepository.petName(order.petId)} 退房后，订单将进入已完成历史，房间会恢复空闲。`,
      primaryButton: {
        value: '取消',
        action: () => {
        }
      },
      secondaryButton: {
        value: '确认退房',
        action: () => {
          this.checkout(order.id);
        }
      }
    });
  }

  build() {
    Column({ space: 14 }) {
      Column({ space: 4 }) {
        Text('退房办理')
          .fontSize(26)
          .fontWeight(FontWeight.Bold)
          .fontColor('#101828')
        Text('完成寄养订单，并释放对应房间。')
          .fontSize(13)
          .fontColor('#667085')
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)

      if (this.checkedInOrders.length === 0) {
        EmptyState({ title: '暂无寄养中订单', description: '当前没有可退房的订单。' })
      } else {
        List({ space: 10 }) {
          ForEach(this.checkedInOrders, (order: BoardingOrder) => {
            ListItem() {
              Column({ space: 10 }) {
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
                  .backgroundColor('#0E7C66')
                  .onClick(() => this.confirmCheckout(order))
              }
              .width('100%')
              .padding(14)
              .backgroundColor(Color.White)
              .borderRadius(8)
              .border({ width: 1, color: '#E4E7EC' })
            }
          }, (order: BoardingOrder) => order.id)
        }
        .layoutWeight(1)
      }
    }
    .width('100%')
    .height('100%')
    .padding(16)
    .backgroundColor('#F6F8FB')
  }
}
