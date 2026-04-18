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

  private confirmDeleteOwner(owner: Owner) {
    AlertDialog.show({
      title: '确认删除主人',
      message: `删除后将移除 ${owner.name} 的主人档案。`,
      primaryButton: {
        value: '取消',
        action: () => {
        }
      },
      secondaryButton: {
        value: '删除',
        fontColor: '#D92D20',
        action: () => {
          this.deleteOwner(owner.id);
        }
      }
    });
  }

  build() {
    Column({ space: 14 }) {
      Row() {
        Column({ space: 4 }) {
          Text('主人管理')
            .fontSize(26)
            .fontWeight(FontWeight.Bold)
            .fontColor('#101828')
          Text('维护联系人，作为宠物和订单的入口。')
            .fontSize(13)
            .fontColor('#667085')
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
        Button('新增主人')
          .height(40)
          .borderRadius(8)
          .backgroundColor('#0E7C66')
          .onClick(() => router.pushUrl({ url: 'pages/OwnerFormPage' }))
      }
      .width('100%')

      Search({ placeholder: '搜索姓名或手机号', value: this.keyword })
        .height(42)
        .onChange((value: string) => {
          this.keyword = value;
          this.refresh();
        })

      if (this.owners.length === 0) {
        EmptyState({ title: '暂无主人', description: '点击新增主人，建立第一份主人档案。' })
      } else {
        List({ space: 10 }) {
          ForEach(this.owners, (owner: Owner) => {
            ListItem() {
              Column({ space: 10 }) {
                Row() {
                  Column({ space: 4 }) {
                    Text(owner.name)
                      .fontSize(18)
                      .fontWeight(FontWeight.Medium)
                      .fontColor('#101828')
                    Text(owner.phone)
                      .fontSize(14)
                      .fontColor('#667085')
                  }
                  .layoutWeight(1)
                  .alignItems(HorizontalAlign.Start)
                  Text('主人')
                    .fontSize(12)
                    .fontColor('#0E7C66')
                    .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                    .backgroundColor('#E7F6F1')
                    .borderRadius(8)
                }
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
                    .onClick(() => this.confirmDeleteOwner(owner))
                }
              }
              .width('100%')
              .padding(14)
              .backgroundColor(Color.White)
              .borderRadius(8)
              .border({ width: 1, color: '#E4E7EC' })
            }
          }, (owner: Owner) => owner.id)
        }
        .layoutWeight(1)
      }
    }
    .width('100%')
    .height('100%')
    .padding(16)
    .backgroundColor('#F6F8FB')
  }
}
