import { OrderStatus, RoomStatus } from '../model/PetBoardingModels';

@Component
export struct StatusTag {
  @Prop text: string;
  @Prop tone: string;

  build() {
    Text(this.text)
      .fontSize(12)
      .fontColor(this.tone === 'danger' ? '#B42318' : this.tone === 'success' ? '#027A48' : '#344054')
      .padding({ left: 8, right: 8, top: 4, bottom: 4 })
      .backgroundColor(this.tone === 'danger' ? '#FEE4E2' : this.tone === 'success' ? '#D1FADF' : '#EAECF0')
      .borderRadius(8)
  }
}

export function orderStatusText(status: OrderStatus): string {
  if (status === OrderStatus.PENDING) {
    return '待入住';
  }
  if (status === OrderStatus.CHECKED_IN) {
    return '寄养中';
  }
  if (status === OrderStatus.COMPLETED) {
    return '已完成';
  }
  return '已取消';
}

export function orderStatusTone(status: OrderStatus): string {
  if (status === OrderStatus.CHECKED_IN || status === OrderStatus.COMPLETED) {
    return 'success';
  }
  if (status === OrderStatus.CANCELLED) {
    return 'danger';
  }
  return 'neutral';
}

export function roomStatusText(status: RoomStatus): string {
  return status === RoomStatus.AVAILABLE ? '空闲' : '占用';
}
