import router from '@ohos.router';
import { SummaryCard } from '../components/SummaryCard';
import { HomeMetrics } from '../model/PetBoardingModels';
import { petBoardingRepository } from '../repository/PetBoardingRepository';

interface HomeAction {
  title: string;
  subtitle: string;
  url: string;
}

@Entry
@Component
struct HomePage {
  @State metrics: HomeMetrics = petBoardingRepository.getHomeMetrics();
  private actions: HomeAction[] = [
    { title: '主人管理', subtitle: '建档、编辑、删除', url: 'pages/OwnerListPage' },
    { title: '宠物管理', subtitle: '关联主人档案', url: 'pages/PetListPage' },
    { title: '订单管理', subtitle: '创建待入住订单', url: 'pages/OrderListPage' },
    { title: '入住登记', subtitle: '分配空闲房间', url: 'pages/CheckInPage' },
    { title: '照护记录', subtitle: '记录喂食清洁等', url: 'pages/CareRecordPage' },
    { title: '退房办理', subtitle: '完成订单并释放房间', url: 'pages/CheckoutPage' },
    { title: '历史订单', subtitle: '查看完整寄养记录', url: 'pages/HistoryPage' }
  ];

  aboutToAppear() {
    this.metrics = petBoardingRepository.getHomeMetrics();
  }

  build() {
    Scroll() {
      Column({ space: 16 }) {
        Text('今日门店')
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .fontColor('#101828')
          .width('100%')
        Grid() {
          GridItem() {
            SummaryCard({ title: '寄养中', value: `${this.metrics.boardingNow}`, subtitle: '当前在店宠物' })
          }
          GridItem() {
            SummaryCard({ title: '今日入住', value: `${this.metrics.todayCheckins}`, subtitle: '已办理入住' })
          }
          GridItem() {
            SummaryCard({ title: '今日退房', value: `${this.metrics.todayCheckouts}`, subtitle: '已完成退房' })
          }
          GridItem() {
            SummaryCard({ title: '空闲房间', value: `${this.metrics.availableRooms}`, subtitle: '可分配笼位' })
          }
        }
        .columnsTemplate('1fr 1fr')
        .columnsGap(12)
        .rowsGap(12)

        Text('业务入口')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor('#101828')
          .width('100%')
          .margin({ top: 8 })

        ForEach(this.actions, (item: HomeAction) => {
          Button(`${item.title}  ${item.subtitle}`)
            .width('100%')
            .height(48)
            .borderRadius(8)
            .onClick(() => {
              router.pushUrl({ url: item.url });
            })
        }, (item: HomeAction) => item.url)
      }
      .padding(16)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA')
  }
}
