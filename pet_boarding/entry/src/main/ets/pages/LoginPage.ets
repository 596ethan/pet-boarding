import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { DEMO_PASSWORD, DEMO_USERNAME } from '../model/PetBoardingModels';
import { petBoardingRepository } from '../repository/PetBoardingRepository';

@Entry
@Component
struct LoginPage {
  @State username: string = DEMO_USERNAME;
  @State password: string = DEMO_PASSWORD;

  private submitLogin() {
    const result = petBoardingRepository.login(this.username, this.password);
    promptAction.showToast({ message: result.message });
    if (result.success) {
      router.replaceUrl({ url: 'pages/HomePage' });
    }
  }

  build() {
    Column({ space: 22 }) {
      Column({ space: 8 }) {
        Text('宠物寄养管理系统')
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .fontColor('#101828')
        Text('门店前台工作台')
          .fontSize(15)
          .fontColor('#667085')
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)

      Column({ space: 14 }) {
        TextInput({ placeholder: '账号', text: this.username })
          .height(48)
          .backgroundColor('#F9FAFB')
          .borderRadius(8)
          .onChange((value: string) => {
            this.username = value;
          })
        TextInput({ placeholder: '密码', text: this.password })
          .height(48)
          .type(InputType.Password)
          .backgroundColor('#F9FAFB')
          .borderRadius(8)
          .onChange((value: string) => {
            this.password = value;
          })
        Button('登录')
          .width('100%')
          .height(48)
          .borderRadius(8)
          .backgroundColor('#0E7C66')
          .onClick(() => {
            this.submitLogin();
          })
        Text(`演示账号：${DEMO_USERNAME} / ${DEMO_PASSWORD}`)
          .fontSize(13)
          .fontColor('#667085')
          .width('100%')
      }
      .width('100%')
      .padding(18)
      .backgroundColor(Color.White)
      .borderRadius(8)
      .border({ width: 1, color: '#E4E7EC' })
      .shadow({ radius: 12, color: '#14000000', offsetX: 0, offsetY: 3 })
    }
    .width('100%')
    .height('100%')
    .padding(24)
    .justifyContent(FlexAlign.Center)
    .backgroundColor('#F6F8FB')
  }
}
