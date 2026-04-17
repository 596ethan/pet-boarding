import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { Owner, Pet, PetInput } from '../model/PetBoardingModels';
import { petBoardingRepository } from '../repository/PetBoardingRepository';

@Entry
@Component
struct PetFormPage {
  @State petId: string = '';
  @State ownerId: string = '';
  @State name: string = '';
  @State type: string = '';
  @State breed: string = '';
  @State ageText: string = '';
  @State weightText: string = '';
  @State temperament: string = '';
  @State owners: Owner[] = petBoardingRepository.listOwners();

  aboutToAppear() {
    this.owners = petBoardingRepository.listOwners();
    const params = router.getParams() as Record<string, string>;
    this.petId = params && params['id'] ? params['id'] : '';
    if (this.petId.length > 0) {
      const pet: Pet | undefined = petBoardingRepository.getPet(this.petId);
      if (pet) {
        this.ownerId = pet.ownerId;
        this.name = pet.name;
        this.type = pet.type;
        this.breed = pet.breed;
        this.ageText = `${pet.age}`;
        this.weightText = `${pet.weight}`;
        this.temperament = pet.temperament;
      }
    } else if (this.owners.length > 0) {
      this.ownerId = this.owners[0].id;
    }
  }

  private isInvalidNumber(value: number): boolean {
    return value !== value || value < 0;
  }

  private save() {
    const age: number = Number(this.ageText);
    const weight: number = Number(this.weightText);
    if (this.ownerId.length === 0 || this.name.trim().length === 0 || this.type.trim().length === 0) {
      promptAction.showToast({ message: '请选择主人，并填写宠物名和类型' });
      return;
    }
    if (this.isInvalidNumber(age) || this.isInvalidNumber(weight)) {
      promptAction.showToast({ message: '年龄和体重必须是有效数字' });
      return;
    }
    const input: PetInput = {
      ownerId: this.ownerId,
      name: this.name,
      type: this.type,
      breed: this.breed,
      age,
      weight,
      temperament: this.temperament
    };
    petBoardingRepository.savePet(input, this.petId);
    promptAction.showToast({ message: '宠物已保存' });
    router.back();
  }

  build() {
    Scroll() {
      Column({ space: 14 }) {
        Text(this.petId.length > 0 ? '编辑宠物' : '新增宠物')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor('#101828')
          .width('100%')

        Text('选择主人')
          .fontSize(14)
          .fontColor('#667085')
          .width('100%')
        Row({ space: 8 }) {
          ForEach(this.owners, (owner: Owner) => {
            Button(owner.name)
              .height(36)
              .borderRadius(8)
              .backgroundColor(this.ownerId === owner.id ? '#2563EB' : '#EAECF0')
              .fontColor(this.ownerId === owner.id ? Color.White : '#344054')
              .onClick(() => this.ownerId = owner.id)
          }, (owner: Owner) => owner.id)
        }
        .width('100%')

        TextInput({ placeholder: '宠物名', text: this.name })
          .height(48)
          .backgroundColor(Color.White)
          .borderRadius(8)
          .onChange((value: string) => this.name = value)
        TextInput({ placeholder: '类型，例如 猫 / 狗', text: this.type })
          .height(48)
          .backgroundColor(Color.White)
          .borderRadius(8)
          .onChange((value: string) => this.type = value)
        TextInput({ placeholder: '品种', text: this.breed })
          .height(48)
          .backgroundColor(Color.White)
          .borderRadius(8)
          .onChange((value: string) => this.breed = value)
        TextInput({ placeholder: '年龄', text: this.ageText })
          .height(48)
          .backgroundColor(Color.White)
          .borderRadius(8)
          .onChange((value: string) => this.ageText = value)
        TextInput({ placeholder: '体重 kg', text: this.weightText })
          .height(48)
          .backgroundColor(Color.White)
          .borderRadius(8)
          .onChange((value: string) => this.weightText = value)
        TextInput({ placeholder: '性格特点', text: this.temperament })
          .height(48)
          .backgroundColor(Color.White)
          .borderRadius(8)
          .onChange((value: string) => this.temperament = value)
        Button('保存')
          .width('100%')
          .height(48)
          .borderRadius(8)
          .onClick(() => this.save())
        Button('返回')
          .width('100%')
          .height(44)
          .borderRadius(8)
          .backgroundColor('#667085')
          .onClick(() => router.back())
      }
      .padding(16)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA')
  }
}
