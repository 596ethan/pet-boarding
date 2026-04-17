import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { EmptyState } from '../components/EmptyState';
import { Owner } from '../model/PetBoardingModels';
import { petBoardingRepository } from '../repository/PetBoardingRepository';

@Entry
@Component
struct OwnerListPage {
  @State keyword: string = '';
  @State owners: Owner[] = petBoardingRepository.listOwners();

  aboutToAppear() {
    this.refresh();
  }

  private refresh() {
    this.owners = petBoardingRepository.listOwners(this.keyword);
  }

  private deleteOwner(ownerId: string) {
    const result = petBoardingRepository.deleteOwner(ownerId);
    promptAction.showToast({ message: result.message });
    this.refresh();
  }

  build() {
    Column({ space: 12 }) {
      Row() {
        Text('主人管理')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor('#101828')
        Blank()
        Button('新增')
          .borderRadius(8)
          .onClick(() => router.pushUrl({ url: 'pages/OwnerFormPage' }))
      }
      .width('100%')

      Search({ placeholder: '搜索姓名或手机号', value: this.keyword })
        .onChange((value: string) => {
          this.keyword = value;
          this.refresh();
        })

      if (this.owners.length === 0) {
        EmptyState({ title: '暂无主人', description: '点击新增建立主人档案' })
      } else {
        List({ space: 10 }) {
          ForEach(this.owners, (owner: Owner) => {
            ListItem() {
              Column({ space: 8 }) {
                Text(owner.name)
                  .fontSize(18)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#101828')
                Text(owner.phone)
                  .fontSize(14)
                  .fontColor('#667085')
                Text(owner.remark)
                  .fontSize(13)
                  .fontColor('#667085')
                Row({ space: 8 }) {
                  Button('编辑')
                    .height(34)
                    .borderRadius(8)
                    .onClick(() => router.pushUrl({ url: 'pages/OwnerFormPage', params: { id: owner.id } }))
                  Button('删除')
                    .height(34)
                    .borderRadius(8)
                    .backgroundColor('#D92D20')
                    .onClick(() => this.deleteOwner(owner.id))
                }
              }
              .width('100%')
              .padding(14)
              .backgroundColor(Color.White)
              .borderRadius(8)
            }
          }, (owner: Owner) => owner.id)
        }
        .layoutWeight(1)
      }
    }
    .width('100%')
    .height('100%')
    .padding(16)
    .backgroundColor('#F5F7FA')
  }
}
