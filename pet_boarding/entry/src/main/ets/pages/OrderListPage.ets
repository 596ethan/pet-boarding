import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { EmptyState } from '../components/EmptyState';
import { orderStatusText, orderStatusTone, StatusTag } from '../components/StatusTag';
import { BoardingOrder } from '../model/PetBoardingModels';
import { petBoardingRepository } from '../repository/PetBoardingRepository';

@Entry
@Component
struct OrderListPage {
  @State keyword: string = '';
  @State orders: BoardingOrder[] = petBoardingRepository.listOrders();

  aboutToAppear() {
    this.refresh();
  }

  private refresh() {
    this.orders = petBoardingRepository.listOrders();
  }

  private visibleOrders(): BoardingOrder[] {
    const text: string = this.keyword.trim();
    if (text.length === 0) {
      return this.orders;
    }
    return this.orders.filter((order: BoardingOrder) => {
      return order.id.includes(text) ||
        petBoardingRepository.ownerName(order.ownerId).includes(text) ||
        petBoardingRepository.petName(order.petId).includes(text);
    });
  }

  private deleteOrder(orderId: string) {
    const result = petBoardingRepository.deleteOrder(orderId);
    promptAction.showToast({ message: result.message });
    this.refresh();
  }

  private confirmDeleteOrder(order: BoardingOrder) {
    AlertDialog.show({
      title: '确认删除订单',
      message: `删除订单 ${order.id} 后，该订单的照护记录也会移除。`,
      primaryButton: {
        value: '取消',
        action: () => {
        }
      },
      secondaryButton: {
        value: '删除',
        fontColor: '#D92D20',
        action: () => {
          this.deleteOrder(order.id);
        }
      }
    });
  }

  build() {
    Column({ space: 14 }) {
      Row() {
        Column({ space: 4 }) {
          Text('订单管理')
            .fontSize(26)
            .fontWeight(FontWeight.Bold)
            .fontColor('#101828')
          Text('创建待入住订单，并查看状态流转。')
            .fontSize(13)
            .fontColor('#667085')
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
        Button('新增订单')
          .height(40)
          .borderRadius(8)
          .backgroundColor('#0E7C66')
          .onClick(() => router.pushUrl({ url: 'pages/OrderFormPage' }))
      }
      .width('100%')

      Search({ placeholder: '搜索订单、主人或宠物', value: this.keyword })
        .height(42)
        .onChange((value: string) => {
          this.keyword = value;
        })

      if (this.visibleOrders().length === 0) {
        EmptyState({ title: '暂无订单', description: '点击新增订单，创建待入住寄养订单。' })
      } else {
        List({ space: 10 }) {
          ForEach(this.visibleOrders(), (order: BoardingOrder) => {
            ListItem() {
              Column({ space: 10 }) {
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
                if (order.checkoutTime.length > 0) {
                  Text(`退房：${order.checkoutTime}`)
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
                    .onClick(() => this.confirmDeleteOrder(order))
                }
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
