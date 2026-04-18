@Component
export struct SummaryCard {
  @Prop title: string;
  @Prop value: string;
  @Prop subtitle: string;
  @Prop accentColor: string;
  @Prop accentBg: string;

  build() {
    Column({ space: 10 }) {
      Row() {
        Text(this.title)
          .fontSize(13)
          .fontColor('#667085')
        Blank()
        Text('')
          .width(18)
          .height(18)
          .borderRadius(8)
          .backgroundColor(this.accentBg)
          .border({ width: 4, color: this.accentColor })
      }
      .width('100%')

      Text(this.value)
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
        .fontColor('#101828')

      Text(this.subtitle)
        .fontSize(12)
        .fontColor('#667085')
    }
    .alignItems(HorizontalAlign.Start)
    .padding(14)
    .backgroundColor(Color.White)
    .borderRadius(8)
    .border({ width: 1, color: '#E4E7EC' })
    .shadow({ radius: 10, color: '#12000000', offsetX: 0, offsetY: 2 })
  }
}
