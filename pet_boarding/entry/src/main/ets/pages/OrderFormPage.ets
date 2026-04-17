import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { BoardingOrder, OrderInput, Owner, Pet } from '../model/PetBoardingModels';
import { petBoardingRepository } from '../repository/PetBoardingRepository';

@Entry
@Component
struct OrderFormPage {
  @State orderId: string = '';
  @State ownerId: string = '';
  @State petId: string = '';
  @State remark: string = '';
  @State owners: Owner[] = petBoardingRepository.listOwners();
  @State pets: Pet[] = petBoardingRepository.listPets();

  aboutToAppear() {
    this.owners = petBoardingRepository.listOwners();
    this.pets = petBoardingRepository.listPets();
    const params = router.getParams() as Record<string, string>;
    this.orderId = params && params['id'] ? params['id'] : '';
    if (this.orderId.length > 0) {
      const order: BoardingOrder | undefined = petBoardingRepository.getOrder(this.orderId);
      if (order) {
        this.ownerId = order.ownerId;
        this.petId = order.petId;
        this.remark = order.remark;
      }
    } else if (this.owners.length > 0) {
      this.ownerId = this.owners[0].id;
      this.pickFirstPetForOwner();
    }
  }

  private petsForOwner(): Pet[] {
    if (this.ownerId.length === 0) {
      return [];
    }
    return this.pets.filter((pet: Pet) => pet.ownerId === this.ownerId);
  }

  private pickFirstPetForOwner() {
    const ownerPets: Pet[] = this.petsForOwner();
    this.petId = ownerPets.length > 0 ? ownerPets[0].id : '';
  }

  private selectOwner(ownerId: string) {
    this.ownerId = ownerId;
    this.pickFirstPetForOwner();
  }

  private save() {
    if (this.ownerId.length === 0 || this.petId.length === 0) {
      promptAction.showToast({ message: '请选择主人和宠物' });
      return;
    }
    const input: OrderInput = {
      ownerId: this.ownerId,
      petId: this.petId,
      remark: this.remark
    };
    petBoardingRepository.saveOrder(input, this.orderId);
    promptAction.showToast({ message: '订单已保存' });
    router.back();
  }

  build() {
    Scroll() {
      Column({ space: 14 }) {
        Text(this.orderId.length > 0 ? '编辑订单' : '新增订单')
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
              .onClick(() => this.selectOwner(owner.id))
          }, (owner: Owner) => owner.id)
        }
        .width('100%')

        Text('选择宠物')
          .fontSize(14)
          .fontColor('#667085')
          .width('100%')
        if (this.petsForOwner().length === 0) {
          Text('当前主人暂无宠物，请先建立宠物档案')
            .fontSize(13)
            .fontColor('#B42318')
            .width('100%')
        } else {
          Row({ space: 8 }) {
            ForEach(this.petsForOwner(), (pet: Pet) => {
              Button(pet.name)
                .height(36)
                .borderRadius(8)
                .backgroundColor(this.petId === pet.id ? '#2563EB' : '#EAECF0')
                .fontColor(this.petId === pet.id ? Color.White : '#344054')
                .onClick(() => this.petId = pet.id)
            }, (pet: Pet) => pet.id)
          }
          .width('100%')
        }

        TextInput({ placeholder: '订单备注', text: this.remark })
          .height(48)
          .backgroundColor(Color.White)
          .borderRadius(8)
          .onChange((value: string) => this.remark = value)

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
