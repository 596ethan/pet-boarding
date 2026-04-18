@Component
export struct EmptyState {
  @Prop title: string;
  @Prop description: string;

  build() {
    Column({ space: 8 }) {
      Text(this.title)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor('#344054')
      Text(this.description)
        .fontSize(13)
        .fontColor('#667085')
        .textAlign(TextAlign.Center)
    }
    .width('100%')
    .padding(24)
    .alignItems(HorizontalAlign.Center)
    .backgroundColor(Color.White)
    .borderRadius(8)
    .border({ width: 1, color: '#E4E7EC' })
  }
}
