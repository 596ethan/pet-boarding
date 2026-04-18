import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { EmptyState } from '../components/EmptyState';
import { Pet } from '../model/PetBoardingModels';
import { petBoardingRepository } from '../repository/PetBoardingRepository';

@Entry
@Component
struct PetListPage {
  @State keyword: string = '';
  @State pets: Pet[] = petBoardingRepository.listPets();

  aboutToAppear() {
    this.refresh();
  }

  private refresh() {
    this.pets = petBoardingRepository.listPets(this.keyword);
  }

  private deletePet(petId: string) {
    const result = petBoardingRepository.deletePet(petId);
    promptAction.showToast({ message: result.message });
    this.refresh();
  }

  private confirmDeletePet(pet: Pet) {
    AlertDialog.show({
      title: '确认删除宠物',
      message: `删除后将移除 ${pet.name} 的宠物档案。`,
      primaryButton: {
        value: '取消',
        action: () => {
        }
      },
      secondaryButton: {
        value: '删除',
        fontColor: '#D92D20',
        action: () => {
          this.deletePet(pet.id);
        }
      }
    });
  }

  build() {
    Column({ space: 14 }) {
      Row() {
        Column({ space: 4 }) {
          Text('宠物管理')
            .fontSize(26)
            .fontWeight(FontWeight.Bold)
            .fontColor('#101828')
          Text('维护宠物资料，便于快速创建寄养订单。')
            .fontSize(13)
            .fontColor('#667085')
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
        Button('新增宠物')
          .height(40)
          .borderRadius(8)
          .backgroundColor('#0E7C66')
          .onClick(() => router.pushUrl({ url: 'pages/PetFormPage' }))
      }
      .width('100%')

      Search({ placeholder: '搜索宠物名、类型或品种', value: this.keyword })
        .height(42)
        .onChange((value: string) => {
          this.keyword = value;
          this.refresh();
        })

      if (this.pets.length === 0) {
        EmptyState({ title: '暂无宠物', description: '点击新增宠物，建立第一份宠物档案。' })
      } else {
        List({ space: 10 }) {
          ForEach(this.pets, (pet: Pet) => {
            ListItem() {
              Column({ space: 10 }) {
                Row() {
                  Column({ space: 4 }) {
                    Text(pet.name)
                      .fontSize(18)
                      .fontWeight(FontWeight.Medium)
                      .fontColor('#101828')
                    Text(`主人：${petBoardingRepository.ownerName(pet.ownerId)}`)
                      .fontSize(14)
                      .fontColor('#667085')
                  }
                  .layoutWeight(1)
                  .alignItems(HorizontalAlign.Start)
                  Text(pet.type)
                    .fontSize(12)
                    .fontColor('#2F6FED')
                    .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                    .backgroundColor('#E8F0FE')
                    .borderRadius(8)
                }
                Text(`${pet.breed} / ${pet.age}岁 / ${pet.weight}kg`)
                  .fontSize(14)
                  .fontColor('#667085')
                Text(pet.temperament)
                  .fontSize(13)
                  .fontColor('#667085')
                Row({ space: 8 }) {
                  Button('编辑')
                    .height(34)
                    .borderRadius(8)
                    .onClick(() => router.pushUrl({ url: 'pages/PetFormPage', params: { id: pet.id } }))
                  Button('删除')
                    .height(34)
                    .borderRadius(8)
                    .backgroundColor('#D92D20')
                    .onClick(() => this.confirmDeletePet(pet))
                }
              }
              .width('100%')
              .padding(14)
              .backgroundColor(Color.White)
              .borderRadius(8)
              .border({ width: 1, color: '#E4E7EC' })
            }
          }, (pet: Pet) => pet.id)
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
