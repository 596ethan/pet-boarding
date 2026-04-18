import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { Owner, OwnerInput } from '../model/PetBoardingModels';
import { petBoardingRepository } from '../repository/PetBoardingRepository';

@Entry
@Component
struct OwnerFormPage {
  @State ownerId: string = '';
  @State name: string = '';
  @State phone: string = '';
  @State remark: string = '';

  aboutToAppear() {
    const params = router.getParams() as Record<string, string>;
    this.ownerId = params && params['id'] ? params['id'] : '';
    if (this.ownerId.length > 0) {
      const owner: Owner | undefined = petBoardingRepository.getOwner(this.ownerId);
      if (owner) {
        this.name = owner.name;
        this.phone = owner.phone;
        this.remark = owner.remark;
      }
    }
  }

  private save() {
    if (this.name.trim().length === 0 || this.phone.trim().length === 0) {
      promptAction.showToast({ message: '请填写姓名和手机号' });
      return;
    }
    const input: OwnerInput = { name: this.name, phone: this.phone, remark: this.remark };
    petBoardingRepository.saveOwner(input, this.ownerId);
    promptAction.showToast({ message: '主人已保存' });
    router.back();
  }

  build() {
    Column({ space: 16 }) {
      Column({ space: 4 }) {
        Text(this.ownerId.length > 0 ? '编辑主人' : '新增主人')
          .fontSize(26)
          .fontWeight(FontWeight.Bold)
          .fontColor('#101828')
        Text('补齐联系人信息，便于后续建立宠物和订单。')
          .fontSize(13)
          .fontColor('#667085')
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)

      Column({ space: 12 }) {
        Text('基本信息')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#101828')
          .width('100%')
        TextInput({ placeholder: '姓名', text: this.name })
          .height(48)
          .backgroundColor('#F9FAFB')
          .borderRadius(8)
          .onChange((value: string) => this.name = value)
        TextInput({ placeholder: '手机号', text: this.phone })
          .height(48)
          .backgroundColor('#F9FAFB')
          .borderRadius(8)
          .onChange((value: string) => this.phone = value)
        TextInput({ placeholder: '备注', text: this.remark })
          .height(48)
          .backgroundColor('#F9FAFB')
          .borderRadius(8)
          .onChange((value: string) => this.remark = value)
      }
      .width('100%')
      .padding(14)
      .backgroundColor(Color.White)
      .borderRadius(8)
      .border({ width: 1, color: '#E4E7EC' })

      Button('保存')
        .width('100%')
        .height(48)
        .borderRadius(8)
        .backgroundColor('#0E7C66')
        .onClick(() => this.save())
      Button('返回')
        .width('100%')
        .height(44)
        .borderRadius(8)
        .backgroundColor('#667085')
        .onClick(() => router.back())
    }
    .width('100%')
    .height('100%')
    .padding(16)
    .backgroundColor('#F6F8FB')
  }
}
