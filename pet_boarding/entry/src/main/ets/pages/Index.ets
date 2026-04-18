import router from '@ohos.router';

@Entry
@Component
struct Index {
  aboutToAppear() {
    router.replaceUrl({ url: 'pages/LoginPage' });
  }

  build() {
    Column({ space: 8 }) {
      Text('宠物寄养管理')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor('#101828')
      Text('正在进入前台工作台')
        .fontSize(14)
        .fontColor('#667085')
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .backgroundColor('#F6F8FB')
  }
}
