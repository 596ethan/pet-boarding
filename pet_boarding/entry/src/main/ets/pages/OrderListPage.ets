import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { EmptyState } from '../components/EmptyState';
import { orderStatusText, orderStatusTone, StatusTag } from '../components/StatusTag';
import { BoardingOrder } from '../model/PetBoardingModels';
import { petBoardingRepository } from '../repository/PetBoardingRepository';

@Entry
@Component
struct OrderListPage {
  @State orders: BoardingOrder[] = petBoardingRepository.listOrders();

  aboutToAppear() {
    this.refresh();
  }

  private refresh() {
    this.orders = petBoardingRepository.listOrders();
  }

  private deleteOrder(orderId: string) {
    const result = petBoardingRepository.deleteOrder(orderId);
    promptAction.showToast({ message: result.message });
    this.refresh();
  }

  build() {
    Column({ space: 12 }) {
      Row() {
        Text('订单管理')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor('#101828')
        Blank()
        Button('新增')
          .borderRadius(8)
          .onClick(() => router.pushUrl({ url: 'pages/OrderFormPage' }))
      }
      .width('100%')

      if (this.orders.length === 0) {
        EmptyState({ title: '暂无订单', description: '点击新增创建待入住订单' })
      } else {
        List({ space: 10 }) {
          ForEach(this.orders, (order: BoardingOrder) => {
            ListItem() {
              Column({ space: 8 }) {
                Row() {
                  Text(`订单 ${order.id}`)
                    .fontSize(17)
                    .fontWeight(FontWeight.Medium)
                    .fontColor('#101828')
                  Blank()
                  StatusTag({ text: orderStatusText(order.status), tone: orderStatusTone(order.status) })
                }
                Text(`主人：${petBoardingRepository.ownerName(order.ownerId)}`)
                  .fontSize(14)
                  .fontColor('#667085')
                Text(`宠物：${petBoardingRepository.petName(order.petId)}`)
                  .fontSize(14)
                  .fontColor('#667085')
                Text(`房间：${petBoardingRepository.roomNo(order.roomId)}`)
                  .fontSize(14)
                  .fontColor('#667085')
                if (order.checkinTime.length > 0) {
                  Text(`入住：${order.checkinTime}`)
                    .fontSize(13)
                    .fontColor('#667085')
                }
                Text(order.remark)
                  .fontSize(13)
                  .fontColor('#667085')
                Row({ space: 8 }) {
                  Button('编辑')
                    .height(34)
                    .borderRadius(8)
                    .onClick(() => router.pushUrl({ url: 'pages/OrderFormPage', params: { id: order.id } }))
                  Button('删除')
                    .height(34)
                    .borderRadius(8)
                    .backgroundColor('#D92D20')
                    .onClick(() => this.deleteOrder(order.id))
                }
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
