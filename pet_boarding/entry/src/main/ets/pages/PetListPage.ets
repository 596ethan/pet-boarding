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

  build() {
    Column({ space: 12 }) {
      Row() {
        Text('宠物管理')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor('#101828')
        Blank()
        Button('新增')
          .borderRadius(8)
          .onClick(() => router.pushUrl({ url: 'pages/PetFormPage' }))
      }
      .width('100%')

      Search({ placeholder: '搜索宠物名、类型或品种', value: this.keyword })
        .onChange((value: string) => {
          this.keyword = value;
          this.refresh();
        })

      if (this.pets.length === 0) {
        EmptyState({ title: '暂无宠物', description: '点击新增建立宠物档案' })
      } else {
        List({ space: 10 }) {
          ForEach(this.pets, (pet: Pet) => {
            ListItem() {
              Column({ space: 8 }) {
                Row() {
                  Text(pet.name)
                    .fontSize(18)
                    .fontWeight(FontWeight.Medium)
                    .fontColor('#101828')
                  Blank()
                  Text(pet.type)
                    .fontSize(13)
                    .fontColor('#344054')
                }
                Text(`主人：${petBoardingRepository.ownerName(pet.ownerId)}`)
                  .fontSize(14)
                  .fontColor('#667085')
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
                    .onClick(() => this.deletePet(pet.id))
                }
              }
              .width('100%')
              .padding(14)
              .backgroundColor(Color.White)
              .borderRadius(8)
            }
          }, (pet: Pet) => pet.id)
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
