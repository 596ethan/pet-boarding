import router from '@ohos.router';
import { SummaryCard } from '../components/SummaryCard';
import { HomeMetrics } from '../model/PetBoardingModels';
import { petBoardingRepository } from '../repository/PetBoardingRepository';

interface HomeAction {
  step: string;
  title: string;
  subtitle: string;
  url: string;
}

@Entry
@Component
struct HomePage {
  @State metrics: HomeMetrics = petBoardingRepository.getHomeMetrics();
  private actions: HomeAction[] = [
    { step: '01', title: '主人管理', subtitle: '建档、编辑、删除联系人信息', url: 'pages/OwnerListPage' },
    { step: '02', title: '宠物管理', subtitle: '维护宠物档案并关联主人', url: 'pages/PetListPage' },
    { step: '03', title: '订单管理', subtitle: '创建待入住寄养订单', url: 'pages/OrderListPage' },
    { step: '04', title: '入住登记', subtitle: '为待入住订单分配空闲房间', url: 'pages/CheckInPage' },
    { step: '05', title: '照护记录', subtitle: '记录喂食、清洁、用药和异常', url: 'pages/CareRecordPage' },
    { step: '06', title: '退房办理', subtitle: '完成订单并释放房间', url: 'pages/CheckoutPage' },
    { step: '07', title: '历史订单', subtitle: '查看已完成寄养记录', url: 'pages/HistoryPage' }
  ];

  aboutToAppear() {
    this.metrics = petBoardingRepository.getHomeMetrics();
  }

  build() {
    Scroll() {
      Column({ space: 18 }) {
        Column({ space: 6 }) {
          Text('今日门店')
            .fontSize(30)
            .fontWeight(FontWeight.Bold)
            .fontColor('#101828')
          Text('按主人、宠物、订单、入住、照护、退房的顺序完成演示。')
            .fontSize(14)
            .fontColor('#667085')
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)

        Grid() {
          GridItem() {
            SummaryCard({ title: '寄养中', value: `${this.metrics.boardingNow}`, subtitle: '当前在店宠物', accentColor: '#0E7C66', accentBg: '#E7F6F1' })
          }
          GridItem() {
            SummaryCard({ title: '今日入住', value: `${this.metrics.todayCheckins}`, subtitle: '已办理入住', accentColor: '#2F6FED', accentBg: '#E8F0FE' })
          }
          GridItem() {
            SummaryCard({ title: '今日退房', value: `${this.metrics.todayCheckouts}`, subtitle: '已完成退房', accentColor: '#B54708', accentBg: '#FEF0C7' })
          }
          GridItem() {
            SummaryCard({ title: '空闲房间', value: `${this.metrics.availableRooms}`, subtitle: '可分配笼位', accentColor: '#12B76A', accentBg: '#ECFDF3' })
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

        ForEach(this.actions, (item: HomeAction) => {
          Row({ space: 12 }) {
            Text(item.step)
              .fontSize(13)
              .fontWeight(FontWeight.Bold)
              .fontColor('#0E7C66')
              .width(42)
              .height(42)
              .textAlign(TextAlign.Center)
              .backgroundColor('#E7F6F1')
              .borderRadius(8)
            Column({ space: 4 }) {
              Text(item.title)
                .fontSize(17)
                .fontWeight(FontWeight.Medium)
                .fontColor('#101828')
              Text(item.subtitle)
                .fontSize(13)
                .fontColor('#667085')
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Start)
            Text('进入')
              .fontSize(13)
              .fontColor('#0E7C66')
          }
          .width('100%')
          .padding(14)
          .backgroundColor(Color.White)
          .borderRadius(8)
          .border({ width: 1, color: '#E4E7EC' })
          .onClick(() => {
            router.pushUrl({ url: item.url });
          })
        }, (item: HomeAction) => item.url)
      }
      .padding(16)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F6F8FB')
  }
}
