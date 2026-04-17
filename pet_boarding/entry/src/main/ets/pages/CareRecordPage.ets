import promptAction from '@ohos.promptAction';
import { EmptyState } from '../components/EmptyState';
import { BoardingOrder, CareRecord, CareRecordInput, CareRecordType, OrderStatus } from '../model/PetBoardingModels';
import { petBoardingRepository } from '../repository/PetBoardingRepository';

interface CareTypeOption {
  type: CareRecordType;
  label: string;
}

@Entry
@Component
struct CareRecordPage {
  @State checkedInOrders: BoardingOrder[] = petBoardingRepository.listOrders(OrderStatus.CHECKED_IN);
  @State selectedOrderId: string = '';
  @State recordType: CareRecordType = CareRecordType.FEEDING;
  @State content: string = '';
  @State records: CareRecord[] = [];
  @State editingRecordId: string = '';

  private careTypes: CareTypeOption[] = [
    { type: CareRecordType.FEEDING, label: '喂食' },
    { type: CareRecordType.WALKING, label: '遛放' },
    { type: CareRecordType.CLEANING, label: '清洁' },
    { type: CareRecordType.MEDICINE, label: '用药' },
    { type: CareRecordType.NOTE, label: '备注' }
  ];

  aboutToAppear() {
    this.checkedInOrders = petBoardingRepository.listOrders(OrderStatus.CHECKED_IN);
    if (this.checkedInOrders.length > 0 && this.selectedOrderId.length === 0) {
      this.selectedOrderId = this.checkedInOrders[0].id;
    }
    this.loadRecords();
  }

  private selectOrder(orderId: string) {
    this.selectedOrderId = orderId;
    this.editingRecordId = '';
    this.content = '';
    this.loadRecords();
  }

  private loadRecords() {
    this.records = this.selectedOrderId.length > 0 ? petBoardingRepository.listCareRecords(this.selectedOrderId) : [];
  }

  private typeLabel(type: CareRecordType): string {
    const matched: CareTypeOption | undefined = this.careTypes.find((item: CareTypeOption) => item.type === type);
    return matched ? matched.label : '记录';
  }

  private editRecord(record: CareRecord) {
    this.editingRecordId = record.id;
    this.recordType = record.type;
    this.content = record.content;
  }

  private saveRecord() {
    if (this.selectedOrderId.length === 0) {
      promptAction.showToast({ message: '请选择寄养中订单' });
      return;
    }
    if (this.content.trim().length === 0) {
      promptAction.showToast({ message: '请填写照护内容' });
      return;
    }
    const input: CareRecordInput = {
      orderId: this.selectedOrderId,
      type: this.recordType,
      content: this.content
    };
    const result = petBoardingRepository.saveCareRecord(input, this.editingRecordId);
    promptAction.showToast({ message: result.message });
    if (result.success) {
      this.editingRecordId = '';
      this.content = '';
      this.recordType = CareRecordType.FEEDING;
      this.loadRecords();
    }
  }

  private deleteRecord(recordId: string) {
    const result = petBoardingRepository.deleteCareRecord(recordId);
    promptAction.showToast({ message: result.message });
    if (this.editingRecordId === recordId) {
      this.editingRecordId = '';
      this.content = '';
    }
    this.loadRecords();
  }

  private confirmDeleteRecord(record: CareRecord) {
    AlertDialog.show({
      title: '确认删除照护记录',
      message: `删除 ${this.typeLabel(record.type)} 记录后不可恢复。`,
      primaryButton: {
        value: '取消',
        action: () => {
        }
      },
      secondaryButton: {
        value: '删除',
        fontColor: '#D92D20',
        action: () => {
          this.deleteRecord(record.id);
        }
      }
    });
  }

  build() {
    Scroll() {
      Column({ space: 16 }) {
        Text('照护记录')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor('#101828')
          .width('100%')

        Text('选择寄养中订单')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#101828')
          .width('100%')
        if (this.checkedInOrders.length === 0) {
          EmptyState({ title: '暂无寄养中订单', description: '入住后才能新增照护记录' })
        } else {
          ForEach(this.checkedInOrders, (order: BoardingOrder) => {
            Column({ space: 4 }) {
              Text(`${petBoardingRepository.ownerName(order.ownerId)} / ${petBoardingRepository.petName(order.petId)}`)
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .fontColor('#101828')
              Text(`房间：${petBoardingRepository.roomNo(order.roomId)}`)
                .fontSize(13)
                .fontColor('#667085')
            }
            .width('100%')
            .padding(12)
            .backgroundColor(this.selectedOrderId === order.id ? '#E0EAFF' : Color.White)
            .borderRadius(8)
            .border({ width: this.selectedOrderId === order.id ? 1 : 0, color: '#2563EB' })
            .onClick(() => this.selectOrder(order.id))
          }, (order: BoardingOrder) => order.id)
        }

        Text(this.editingRecordId.length > 0 ? '编辑记录' : '新增记录')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#101828')
          .width('100%')
        Row({ space: 8 }) {
          ForEach(this.careTypes, (item: CareTypeOption) => {
            Button(item.label)
              .height(36)
              .borderRadius(8)
              .backgroundColor(this.recordType === item.type ? '#2563EB' : '#EAECF0')
              .fontColor(this.recordType === item.type ? Color.White : '#344054')
              .onClick(() => this.recordType = item.type)
          }, (item: CareTypeOption) => item.type)
        }
        .width('100%')

        TextInput({ placeholder: '照护内容', text: this.content })
          .height(48)
          .backgroundColor(Color.White)
          .borderRadius(8)
          .onChange((value: string) => this.content = value)
        Button(this.editingRecordId.length > 0 ? '保存修改' : '新增记录')
          .width('100%')
          .height(48)
          .borderRadius(8)
          .onClick(() => this.saveRecord())

        Text('记录列表')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#101828')
          .width('100%')
        if (this.records.length === 0) {
          EmptyState({ title: '暂无照护记录', description: '填写内容后新增第一条记录' })
        } else {
          ForEach(this.records, (record: CareRecord) => {
            Column({ space: 8 }) {
              Row() {
                Text(this.typeLabel(record.type))
                  .fontSize(16)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#101828')
                Blank()
                Text(record.recordTime)
                  .fontSize(12)
                  .fontColor('#667085')
              }
              Text(record.content)
                .fontSize(14)
                .fontColor('#344054')
                .width('100%')
              Row({ space: 8 }) {
                Button('编辑')
                  .height(34)
                  .borderRadius(8)
                  .onClick(() => this.editRecord(record))
                Button('删除')
                  .height(34)
                  .borderRadius(8)
                  .backgroundColor('#D92D20')
                  .onClick(() => this.confirmDeleteRecord(record))
              }
            }
            .width('100%')
            .padding(14)
            .backgroundColor(Color.White)
            .borderRadius(8)
          }, (record: CareRecord) => record.id)
        }
      }
      .padding(16)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA')
  }
}
