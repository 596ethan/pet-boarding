import { EmptyState } from '../components/EmptyState';
import { BoardingOrder, CareRecord, OrderStatus } from '../model/PetBoardingModels';
import { petBoardingRepository } from '../repository/PetBoardingRepository';

@Entry
@Component
struct HistoryPage {
  @State completedOrders: BoardingOrder[] = petBoardingRepository.listOrders(OrderStatus.COMPLETED);

  aboutToAppear() {
    this.completedOrders = petBoardingRepository.listOrders(OrderStatus.COMPLETED);
  }

  private careCount(orderId: string): number {
    const records: CareRecord[] = petBoardingRepository.listCareRecords(orderId);
    return records.length;
  }

  build() {
    Column({ space: 14 }) {
      Column({ space: 4 }) {
        Text('历史订单')
          .fontSize(26)
          .fontWeight(FontWeight.Bold)
          .fontColor('#101828')
        Text('沉淀已完成的寄养记录，便于演示完整闭环。')
          .fontSize(13)
          .fontColor('#667085')
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)

      if (this.completedOrders.length === 0) {
        EmptyState({ title: '暂无历史订单', description: '退房完成后会出现在这里。' })
      } else {
        List({ space: 10 }) {
          ForEach(this.completedOrders, (order: BoardingOrder) => {
            ListItem() {
              Column({ space: 8 }) {
                Row() {
                  Text(`${petBoardingRepository.ownerName(order.ownerId)} / ${petBoardingRepository.petName(order.petId)}`)
                    .fontSize(18)
                    .fontWeight(FontWeight.Medium)
                    .fontColor('#101828')
                  Blank()
                  Text('已完成')
                    .fontSize(12)
                    .fontColor('#027A48')
                    .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                    .backgroundColor('#D1FADF')
                    .borderRadius(8)
                }
                Text(`房间：${petBoardingRepository.roomNo(order.roomId)}`)
                  .fontSize(14)
                  .fontColor('#667085')
                Text(`入住：${order.checkinTime}`)
                  .fontSize(14)
                  .fontColor('#667085')
                Text(`退房：${order.checkoutTime}`)
                  .fontSize(14)
                  .fontColor('#667085')
                Text(`照护记录：${this.careCount(order.id)} 条`)
                  .fontSize(14)
                  .fontColor('#667085')
                Text(order.remark)
                  .fontSize(13)
                  .fontColor('#667085')
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
