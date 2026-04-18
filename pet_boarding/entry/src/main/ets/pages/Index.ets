import router from '@ohos.router';

@Entry
@Component
struct Index {
  aboutToAppear() {
    router.replaceUrl({ url: 'pages/LoginPage' });
  }

  build() {
    Column() {
      Text('宠物寄养管理')
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
        .fontColor('#101828')
      Text('正在进入...')
        .fontSize(14)
        .fontColor('#667085')
        .margin({ top: 8 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .backgroundColor('#F5F7FA')
  }
}
