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
    Column({ space: 18 }) {
      Text('宠物寄养管理系统')
        .fontSize(26)
        .fontWeight(FontWeight.Bold)
        .fontColor('#101828')
      Text('门店前台演示端')
        .fontSize(15)
        .fontColor('#667085')
      TextInput({ placeholder: '账号', text: this.username })
        .height(48)
        .backgroundColor(Color.White)
        .borderRadius(8)
        .onChange((value: string) => {
          this.username = value;
        })
      TextInput({ placeholder: '密码', text: this.password })
        .height(48)
        .type(InputType.Password)
        .backgroundColor(Color.White)
        .borderRadius(8)
        .onChange((value: string) => {
          this.password = value;
        })
      Button('登录')
        .width('100%')
        .height(48)
        .borderRadius(8)
        .onClick(() => {
          this.submitLogin();
        })
      Text(`演示账号：${DEMO_USERNAME} / ${DEMO_PASSWORD}`)
        .fontSize(13)
        .fontColor('#667085')
    }
    .width('100%')
    .height('100%')
    .padding(24)
    .justifyContent(FlexAlign.Center)
    .backgroundColor('#F5F7FA')
  }
}
