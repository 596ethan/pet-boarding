@Component
export struct SummaryCard {
  @Prop title: string;
  @Prop value: string;
  @Prop subtitle: string;

  build() {
    Column({ space: 6 }) {
      Text(this.title)
        .fontSize(13)
        .fontColor('#667085')
      Text(this.value)
        .fontSize(26)
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
    .shadow({ radius: 10, color: '#14000000', offsetX: 0, offsetY: 2 })
  }
}
