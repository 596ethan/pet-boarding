import { OrderStatus, RoomStatus } from '../model/PetBoardingModels';

@Component
export struct StatusTag {
  @Prop text: string;
  @Prop tone: string;

  private textColor(): string {
    if (this.tone === 'danger') {
      return '#B42318';
    }
    if (this.tone === 'success') {
      return '#027A48';
    }
    if (this.tone === 'warning') {
      return '#B54708';
    }
    return '#344054';
  }

  private bgColor(): string {
    if (this.tone === 'danger') {
      return '#FEE4E2';
    }
    if (this.tone === 'success') {
      return '#D1FADF';
    }
    if (this.tone === 'warning') {
      return '#FEF0C7';
    }
    return '#EAECF0';
  }

  build() {
    Text(this.text)
      .fontSize(12)
      .fontWeight(FontWeight.Medium)
      .fontColor(this.textColor())
      .padding({ left: 8, right: 8, top: 4, bottom: 4 })
      .backgroundColor(this.bgColor())
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
  return 'warning';
}

export function roomStatusText(status: RoomStatus): string {
  return status === RoomStatus.AVAILABLE ? '空闲' : '占用';
}

export function roomStatusTone(status: RoomStatus): string {
  return status === RoomStatus.AVAILABLE ? 'success' : 'warning';
}
