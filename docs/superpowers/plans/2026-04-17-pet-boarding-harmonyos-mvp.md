# Pet Boarding HarmonyOS MVP Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a HarmonyOS-native phone MVP that demonstrates the full pet boarding workflow from login through completed order history.

**Architecture:** Use typed ArkTS models, minimal seed data, a local repository for CRUD and workflow rules, and small routed HarmonyOS pages. Pages call repository methods and render native UI; repository code owns state transitions such as check-in, care-record restrictions, checkout, and delete blocking.

**Tech Stack:** HarmonyOS ArkTS, DevEco hvigor, native ArkUI components, local in-memory repository, Git.

---

## Scope And Constraints

- Implement only the current HarmonyOS app under `pet_boarding/`.
- Do not scaffold Java backend or management admin UI.
- Keep data local and minimal.
- Keep page files focused on page behavior and layout.
- Avoid generated and machine-local folders: `.hvigor/`, `oh_modules/`, `.idea/`, `local.properties`, `build/`, `.test/`.
- Use explicit interfaces for nested objects and fixture data.
- Commit after each task when the task passes its verification step.

## File Structure Map

Create or modify these files:

- Create: `pet_boarding/entry/src/main/ets/model/PetBoardingModels.ets`
  - Owns enums, interfaces, form input types, and demo login constants.
- Create: `pet_boarding/entry/src/main/ets/data/PetBoardingSeedData.ets`
  - Owns realistic minimal demo records.
- Create: `pet_boarding/entry/src/main/ets/repository/PetBoardingRepository.ets`
  - Owns local state, CRUD methods, query helpers, and workflow validations.
- Create: `pet_boarding/entry/src/main/ets/components/StatusTag.ets`
  - Renders compact status labels.
- Create: `pet_boarding/entry/src/main/ets/components/SummaryCard.ets`
  - Renders home metric cards.
- Create: `pet_boarding/entry/src/main/ets/components/EmptyState.ets`
  - Renders consistent empty states.
- Modify: `pet_boarding/entry/src/main/resources/base/profile/main_pages.json`
  - Registers routed pages.
- Modify: `pet_boarding/entry/src/main/ets/pages/Index.ets`
  - Replaces default template with a redirect/entry screen.
- Create: `pet_boarding/entry/src/main/ets/pages/LoginPage.ets`
- Create: `pet_boarding/entry/src/main/ets/pages/HomePage.ets`
- Create: `pet_boarding/entry/src/main/ets/pages/OwnerListPage.ets`
- Create: `pet_boarding/entry/src/main/ets/pages/OwnerFormPage.ets`
- Create: `pet_boarding/entry/src/main/ets/pages/PetListPage.ets`
- Create: `pet_boarding/entry/src/main/ets/pages/PetFormPage.ets`
- Create: `pet_boarding/entry/src/main/ets/pages/OrderListPage.ets`
- Create: `pet_boarding/entry/src/main/ets/pages/OrderFormPage.ets`
- Create: `pet_boarding/entry/src/main/ets/pages/CheckInPage.ets`
- Create: `pet_boarding/entry/src/main/ets/pages/CareRecordPage.ets`
- Create: `pet_boarding/entry/src/main/ets/pages/CheckoutPage.ets`
- Create: `pet_boarding/entry/src/main/ets/pages/HistoryPage.ets`

## Verification Commands

Run from `D:\HongMengprogram\20260417\pet_boarding`:

```powershell
$env:DEVECO_SDK_HOME='D:\Program Files\Huawei\DevEco Studio\sdk'
& 'D:\Program Files\Huawei\DevEco Studio\tools\node\node.exe' `
  'D:\Program Files\Huawei\DevEco Studio\tools\hvigor\bin\hvigorw.js' `
  --mode module `
  -p module=entry@default `
  -p product=default `
  assembleHap `
  --analyze=normal
```

Expected final result: build succeeds. If it fails, capture the first ArkTS or hvigor error with file path and line.

Manual demo path:

```text
Login -> Home -> Owner -> Pet -> Order -> Check-in -> Care Record -> Checkout -> History
```

Expected final result: the same order moves from `PENDING` to `CHECKED_IN` to `COMPLETED`, and the assigned room returns to available after checkout.

---

### Task 1: Domain Models And Seed Data

**Files:**
- Create: `pet_boarding/entry/src/main/ets/model/PetBoardingModels.ets`
- Create: `pet_boarding/entry/src/main/ets/data/PetBoardingSeedData.ets`

- [ ] **Step 1: Add typed domain models**

Create `pet_boarding/entry/src/main/ets/model/PetBoardingModels.ets` with this content:

```typescript
export enum OrderStatus {
  PENDING = 'PENDING',
  CHECKED_IN = 'CHECKED_IN',
  COMPLETED = 'COMPLETED',
  CANCELLED = 'CANCELLED'
}

export enum RoomStatus {
  AVAILABLE = 'AVAILABLE',
  OCCUPIED = 'OCCUPIED'
}

export enum CareRecordType {
  FEEDING = 'FEEDING',
  WALKING = 'WALKING',
  CLEANING = 'CLEANING',
  MEDICINE = 'MEDICINE',
  NOTE = 'NOTE'
}

export interface User {
  id: string;
  username: string;
  displayName: string;
  password: string;
}

export interface Owner {
  id: string;
  name: string;
  phone: string;
  remark: string;
}

export interface Pet {
  id: string;
  ownerId: string;
  name: string;
  type: string;
  breed: string;
  age: number;
  weight: number;
  temperament: string;
}

export interface Room {
  id: string;
  roomNo: string;
  status: RoomStatus;
}

export interface BoardingOrder {
  id: string;
  ownerId: string;
  petId: string;
  roomId: string;
  status: OrderStatus;
  checkinTime: string;
  checkoutTime: string;
  remark: string;
}

export interface CareRecord {
  id: string;
  orderId: string;
  type: CareRecordType;
  content: string;
  recordTime: string;
}

export interface OwnerInput {
  name: string;
  phone: string;
  remark: string;
}

export interface PetInput {
  ownerId: string;
  name: string;
  type: string;
  breed: string;
  age: number;
  weight: number;
  temperament: string;
}

export interface OrderInput {
  ownerId: string;
  petId: string;
  remark: string;
}

export interface CareRecordInput {
  orderId: string;
  type: CareRecordType;
  content: string;
}

export interface HomeMetrics {
  boardingNow: number;
  todayCheckins: number;
  todayCheckouts: number;
  availableRooms: number;
}

export interface RepositoryResult {
  success: boolean;
  message: string;
}

export const DEMO_USERNAME: string = 'admin';
export const DEMO_PASSWORD: string = '123456';
```

- [ ] **Step 2: Add minimal seed data**

Create `pet_boarding/entry/src/main/ets/data/PetBoardingSeedData.ets` with this content:

```typescript
import {
  BoardingOrder,
  CareRecord,
  CareRecordType,
  DEMO_PASSWORD,
  DEMO_USERNAME,
  OrderStatus,
  Owner,
  Pet,
  Room,
  RoomStatus,
  User
} from '../model/PetBoardingModels';

export const seedUsers: User[] = [
  {
    id: 'user-1',
    username: DEMO_USERNAME,
    password: DEMO_PASSWORD,
    displayName: '前台店员'
  }
];

export const seedOwners: Owner[] = [
  {
    id: 'owner-1',
    name: '林雨',
    phone: '13800010001',
    remark: '喜欢上午接送'
  },
  {
    id: 'owner-2',
    name: '陈晓',
    phone: '13800010002',
    remark: '宠物对陌生人慢热'
  }
];

export const seedPets: Pet[] = [
  {
    id: 'pet-1',
    ownerId: 'owner-1',
    name: '团团',
    type: '猫',
    breed: '英短',
    age: 3,
    weight: 4.8,
    temperament: '安静，怕吵'
  },
  {
    id: 'pet-2',
    ownerId: 'owner-2',
    name: '可乐',
    type: '狗',
    breed: '柯基',
    age: 2,
    weight: 11.2,
    temperament: '活泼，爱散步'
  }
];

export const seedRooms: Room[] = [
  {
    id: 'room-1',
    roomNo: 'A101',
    status: RoomStatus.OCCUPIED
  },
  {
    id: 'room-2',
    roomNo: 'A102',
    status: RoomStatus.AVAILABLE
  },
  {
    id: 'room-3',
    roomNo: 'B201',
    status: RoomStatus.AVAILABLE
  }
];

export const seedOrders: BoardingOrder[] = [
  {
    id: 'order-1',
    ownerId: 'owner-1',
    petId: 'pet-1',
    roomId: 'room-1',
    status: OrderStatus.CHECKED_IN,
    checkinTime: '2026-04-17 09:20',
    checkoutTime: '',
    remark: '寄养三天，注意猫砂清洁'
  },
  {
    id: 'order-2',
    ownerId: 'owner-2',
    petId: 'pet-2',
    roomId: '',
    status: OrderStatus.PENDING,
    checkinTime: '',
    checkoutTime: '',
    remark: '今天下午入住'
  }
];

export const seedCareRecords: CareRecord[] = [
  {
    id: 'care-1',
    orderId: 'order-1',
    type: CareRecordType.FEEDING,
    content: '上午已喂食，饮水正常',
    recordTime: '2026-04-17 10:00'
  }
];
```

- [ ] **Step 3: Run build after adding unused typed files**

Run:

```powershell
cd D:\HongMengprogram\20260417\pet_boarding
$env:DEVECO_SDK_HOME='D:\Program Files\Huawei\DevEco Studio\sdk'
& 'D:\Program Files\Huawei\DevEco Studio\tools\node\node.exe' `
  'D:\Program Files\Huawei\DevEco Studio\tools\hvigor\bin\hvigorw.js' `
  --mode module -p module=entry@default -p product=default assembleHap --analyze=normal
```

Expected: build succeeds or fails only because the existing local DevEco/hvigor environment is unavailable. If the compiler reports an ArkTS import/type error in these two new files, fix that error before continuing.

- [ ] **Step 4: Commit**

```powershell
git add -- pet_boarding/entry/src/main/ets/model/PetBoardingModels.ets pet_boarding/entry/src/main/ets/data/PetBoardingSeedData.ets
git commit -m "feat: add pet boarding domain data"
```

---

### Task 2: Local Repository And Workflow Rules

**Files:**
- Create: `pet_boarding/entry/src/main/ets/repository/PetBoardingRepository.ets`

- [ ] **Step 1: Add repository with CRUD and workflow methods**

Create `pet_boarding/entry/src/main/ets/repository/PetBoardingRepository.ets` with this content:

```typescript
import {
  BoardingOrder,
  CareRecord,
  CareRecordInput,
  HomeMetrics,
  OrderInput,
  OrderStatus,
  Owner,
  OwnerInput,
  Pet,
  PetInput,
  RepositoryResult,
  Room,
  RoomStatus,
  User
} from '../model/PetBoardingModels';
import {
  seedCareRecords,
  seedOrders,
  seedOwners,
  seedPets,
  seedRooms,
  seedUsers
} from '../data/PetBoardingSeedData';

export class PetBoardingRepository {
  private users: User[] = seedUsers.slice();
  private owners: Owner[] = seedOwners.slice();
  private pets: Pet[] = seedPets.slice();
  private rooms: Room[] = seedRooms.slice();
  private orders: BoardingOrder[] = seedOrders.slice();
  private careRecords: CareRecord[] = seedCareRecords.slice();
  private sequence: number = 1000;

  login(username: string, password: string): RepositoryResult {
    const matched: User | undefined = this.users.find((user: User) => user.username === username && user.password === password);
    if (matched) {
      return { success: true, message: `欢迎，${matched.displayName}` };
    }
    return { success: false, message: '账号或密码错误' };
  }

  getHomeMetrics(): HomeMetrics {
    return {
      boardingNow: this.orders.filter((order: BoardingOrder) => order.status === OrderStatus.CHECKED_IN).length,
      todayCheckins: this.orders.filter((order: BoardingOrder) => order.checkinTime.startsWith(this.today())).length,
      todayCheckouts: this.orders.filter((order: BoardingOrder) => order.checkoutTime.startsWith(this.today())).length,
      availableRooms: this.rooms.filter((room: Room) => room.status === RoomStatus.AVAILABLE).length
    };
  }

  listOwners(keyword: string = ''): Owner[] {
    const text: string = keyword.trim();
    if (text.length === 0) {
      return this.owners.slice();
    }
    return this.owners.filter((owner: Owner) => owner.name.includes(text) || owner.phone.includes(text));
  }

  getOwner(id: string): Owner | undefined {
    return this.owners.find((owner: Owner) => owner.id === id);
  }

  saveOwner(input: OwnerInput, id: string = ''): Owner {
    if (id.length > 0) {
      const index: number = this.owners.findIndex((owner: Owner) => owner.id === id);
      if (index >= 0) {
        const updated: Owner = { id, name: input.name, phone: input.phone, remark: input.remark };
        this.owners.splice(index, 1, updated);
        return updated;
      }
    }
    const created: Owner = { id: this.nextId('owner'), name: input.name, phone: input.phone, remark: input.remark };
    this.owners.push(created);
    return created;
  }

  deleteOwner(id: string): RepositoryResult {
    const hasOpenOrder: boolean = this.orders.some((order: BoardingOrder) => order.ownerId === id && order.status !== OrderStatus.COMPLETED && order.status !== OrderStatus.CANCELLED);
    if (hasOpenOrder) {
      return { success: false, message: '主人存在未完成订单，不能删除' };
    }
    this.owners = this.owners.filter((owner: Owner) => owner.id !== id);
    return { success: true, message: '主人已删除' };
  }

  listPets(keyword: string = ''): Pet[] {
    const text: string = keyword.trim();
    if (text.length === 0) {
      return this.pets.slice();
    }
    return this.pets.filter((pet: Pet) => pet.name.includes(text) || pet.type.includes(text) || pet.breed.includes(text));
  }

  getPet(id: string): Pet | undefined {
    return this.pets.find((pet: Pet) => pet.id === id);
  }

  savePet(input: PetInput, id: string = ''): Pet {
    if (id.length > 0) {
      const index: number = this.pets.findIndex((pet: Pet) => pet.id === id);
      if (index >= 0) {
        const updated: Pet = { id, ownerId: input.ownerId, name: input.name, type: input.type, breed: input.breed, age: input.age, weight: input.weight, temperament: input.temperament };
        this.pets.splice(index, 1, updated);
        return updated;
      }
    }
    const created: Pet = { id: this.nextId('pet'), ownerId: input.ownerId, name: input.name, type: input.type, breed: input.breed, age: input.age, weight: input.weight, temperament: input.temperament };
    this.pets.push(created);
    return created;
  }

  deletePet(id: string): RepositoryResult {
    const hasOpenOrder: boolean = this.orders.some((order: BoardingOrder) => order.petId === id && order.status !== OrderStatus.COMPLETED && order.status !== OrderStatus.CANCELLED);
    if (hasOpenOrder) {
      return { success: false, message: '宠物存在未完成订单，不能删除' };
    }
    this.pets = this.pets.filter((pet: Pet) => pet.id !== id);
    return { success: true, message: '宠物已删除' };
  }

  listRooms(): Room[] {
    return this.rooms.slice();
  }

  listAvailableRooms(): Room[] {
    return this.rooms.filter((room: Room) => room.status === RoomStatus.AVAILABLE);
  }

  getRoom(id: string): Room | undefined {
    return this.rooms.find((room: Room) => room.id === id);
  }

  listOrders(status: OrderStatus | '' = ''): BoardingOrder[] {
    if (status === '') {
      return this.orders.slice();
    }
    return this.orders.filter((order: BoardingOrder) => order.status === status);
  }

  getOrder(id: string): BoardingOrder | undefined {
    return this.orders.find((order: BoardingOrder) => order.id === id);
  }

  saveOrder(input: OrderInput, id: string = ''): BoardingOrder {
    if (id.length > 0) {
      const index: number = this.orders.findIndex((order: BoardingOrder) => order.id === id);
      if (index >= 0) {
        const current: BoardingOrder = this.orders[index];
        const updated: BoardingOrder = {
          id,
          ownerId: input.ownerId,
          petId: input.petId,
          roomId: current.roomId,
          status: current.status,
          checkinTime: current.checkinTime,
          checkoutTime: current.checkoutTime,
          remark: input.remark
        };
        this.orders.splice(index, 1, updated);
        return updated;
      }
    }
    const created: BoardingOrder = {
      id: this.nextId('order'),
      ownerId: input.ownerId,
      petId: input.petId,
      roomId: '',
      status: OrderStatus.PENDING,
      checkinTime: '',
      checkoutTime: '',
      remark: input.remark
    };
    this.orders.push(created);
    return created;
  }

  deleteOrder(id: string): RepositoryResult {
    const order: BoardingOrder | undefined = this.getOrder(id);
    if (!order) {
      return { success: false, message: '订单不存在' };
    }
    if (order.status === OrderStatus.CHECKED_IN) {
      return { success: false, message: '寄养中订单不能删除，请先退房' };
    }
    this.orders = this.orders.filter((item: BoardingOrder) => item.id !== id);
    this.careRecords = this.careRecords.filter((record: CareRecord) => record.orderId !== id);
    return { success: true, message: '订单已删除' };
  }

  checkIn(orderId: string, roomId: string): RepositoryResult {
    const order: BoardingOrder | undefined = this.getOrder(orderId);
    const room: Room | undefined = this.getRoom(roomId);
    if (!order) {
      return { success: false, message: '订单不存在' };
    }
    if (!room) {
      return { success: false, message: '房间不存在' };
    }
    if (order.status !== OrderStatus.PENDING) {
      return { success: false, message: '只有待入住订单可以办理入住' };
    }
    if (room.status !== RoomStatus.AVAILABLE) {
      return { success: false, message: '房间已被占用' };
    }
    order.status = OrderStatus.CHECKED_IN;
    order.roomId = roomId;
    order.checkinTime = this.nowText();
    room.status = RoomStatus.OCCUPIED;
    return { success: true, message: '入住成功' };
  }

  checkOut(orderId: string): RepositoryResult {
    const order: BoardingOrder | undefined = this.getOrder(orderId);
    if (!order) {
      return { success: false, message: '订单不存在' };
    }
    if (order.status !== OrderStatus.CHECKED_IN) {
      return { success: false, message: '只有寄养中订单可以退房' };
    }
    const room: Room | undefined = this.getRoom(order.roomId);
    order.status = OrderStatus.COMPLETED;
    order.checkoutTime = this.nowText();
    if (room) {
      room.status = RoomStatus.AVAILABLE;
    }
    return { success: true, message: '退房完成' };
  }

  listCareRecords(orderId: string = ''): CareRecord[] {
    if (orderId.length === 0) {
      return this.careRecords.slice();
    }
    return this.careRecords.filter((record: CareRecord) => record.orderId === orderId);
  }

  saveCareRecord(input: CareRecordInput, id: string = ''): RepositoryResult {
    const order: BoardingOrder | undefined = this.getOrder(input.orderId);
    if (!order) {
      return { success: false, message: '订单不存在' };
    }
    if (order.status !== OrderStatus.CHECKED_IN) {
      return { success: false, message: '只有寄养中订单可以新增或修改照护记录' };
    }
    if (id.length > 0) {
      const index: number = this.careRecords.findIndex((record: CareRecord) => record.id === id);
      if (index >= 0) {
        const updated: CareRecord = {
          id,
          orderId: input.orderId,
          type: input.type,
          content: input.content,
          recordTime: this.nowText()
        };
        this.careRecords.splice(index, 1, updated);
        return { success: true, message: '照护记录已更新' };
      }
    }
    const created: CareRecord = {
      id: this.nextId('care'),
      orderId: input.orderId,
      type: input.type,
      content: input.content,
      recordTime: this.nowText()
    };
    this.careRecords.push(created);
    return { success: true, message: '照护记录已新增' };
  }

  deleteCareRecord(id: string): RepositoryResult {
    this.careRecords = this.careRecords.filter((record: CareRecord) => record.id !== id);
    return { success: true, message: '照护记录已删除' };
  }

  ownerName(ownerId: string): string {
    const owner: Owner | undefined = this.getOwner(ownerId);
    return owner ? owner.name : '未知主人';
  }

  petName(petId: string): string {
    const pet: Pet | undefined = this.getPet(petId);
    return pet ? pet.name : '未知宠物';
  }

  roomNo(roomId: string): string {
    const room: Room | undefined = this.getRoom(roomId);
    return room ? room.roomNo : '未分配';
  }

  private nextId(prefix: string): string {
    this.sequence += 1;
    return `${prefix}-${this.sequence}`;
  }

  private today(): string {
    return '2026-04-17';
  }

  private nowText(): string {
    const date: Date = new Date();
    const month: string = `${date.getMonth() + 1}`.padStart(2, '0');
    const day: string = `${date.getDate()}`.padStart(2, '0');
    const hour: string = `${date.getHours()}`.padStart(2, '0');
    const minute: string = `${date.getMinutes()}`.padStart(2, '0');
    return `${date.getFullYear()}-${month}-${day} ${hour}:${minute}`;
  }
}

export const petBoardingRepository: PetBoardingRepository = new PetBoardingRepository();
```

- [ ] **Step 2: Run build**

Run:

```powershell
cd D:\HongMengprogram\20260417\pet_boarding
$env:DEVECO_SDK_HOME='D:\Program Files\Huawei\DevEco Studio\sdk'
& 'D:\Program Files\Huawei\DevEco Studio\tools\node\node.exe' `
  'D:\Program Files\Huawei\DevEco Studio\tools\hvigor\bin\hvigorw.js' `
  --mode module -p module=entry@default -p product=default assembleHap --analyze=normal
```

Expected: build succeeds. If ArkTS rejects array mutation on typed interface objects, update `checkIn` and `checkOut` to replace the full array item with a new object and re-run the command.

- [ ] **Step 3: Commit**

```powershell
git add -- pet_boarding/entry/src/main/ets/repository/PetBoardingRepository.ets
git commit -m "feat: add local pet boarding repository"
```

---

### Task 3: Shared UI Components

**Files:**
- Create: `pet_boarding/entry/src/main/ets/components/StatusTag.ets`
- Create: `pet_boarding/entry/src/main/ets/components/SummaryCard.ets`
- Create: `pet_boarding/entry/src/main/ets/components/EmptyState.ets`

- [ ] **Step 1: Add status tag component**

Create `pet_boarding/entry/src/main/ets/components/StatusTag.ets`:

```typescript
import { OrderStatus, RoomStatus } from '../model/PetBoardingModels';

@Component
export struct StatusTag {
  @Prop text: string;
  @Prop tone: string;

  build() {
    Text(this.text)
      .fontSize(12)
      .fontColor(this.tone === 'danger' ? '#B42318' : this.tone === 'success' ? '#027A48' : '#344054')
      .padding({ left: 8, right: 8, top: 4, bottom: 4 })
      .backgroundColor(this.tone === 'danger' ? '#FEE4E2' : this.tone === 'success' ? '#D1FADF' : '#EAECF0')
      .borderRadius(8)
  }
}

export function orderStatusText(status: OrderStatus): string {
  if (status === OrderStatus.PENDING) {
    return '待入住';
  }
  if (status === OrderStatus.CHECKED_IN) {
    return '寄养中';
  }
  if (status === OrderStatus.COMPLETED) {
    return '已完成';
  }
  return '已取消';
}

export function orderStatusTone(status: OrderStatus): string {
  if (status === OrderStatus.CHECKED_IN || status === OrderStatus.COMPLETED) {
    return 'success';
  }
  if (status === OrderStatus.CANCELLED) {
    return 'danger';
  }
  return 'neutral';
}

export function roomStatusText(status: RoomStatus): string {
  return status === RoomStatus.AVAILABLE ? '空闲' : '占用';
}
```

- [ ] **Step 2: Add summary card component**

Create `pet_boarding/entry/src/main/ets/components/SummaryCard.ets`:

```typescript
@Component
export struct SummaryCard {
  @Prop title: string;
  @Prop value: string;
  @Prop subtitle: string;

  build() {
    Column({ space: 6 }) {
      Text(this.title)
        .fontSize(13)
        .fontColor('#667085')
      Text(this.value)
        .fontSize(26)
        .fontWeight(FontWeight.Bold)
        .fontColor('#101828')
      Text(this.subtitle)
        .fontSize(12)
        .fontColor('#667085')
    }
    .alignItems(HorizontalAlign.Start)
    .padding(14)
    .backgroundColor(Color.White)
    .borderRadius(8)
    .shadow({ radius: 10, color: '#14000000', offsetX: 0, offsetY: 2 })
  }
}
```

- [ ] **Step 3: Add empty state component**

Create `pet_boarding/entry/src/main/ets/components/EmptyState.ets`:

```typescript
@Component
export struct EmptyState {
  @Prop title: string;
  @Prop description: string;

  build() {
    Column({ space: 8 }) {
      Text(this.title)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor('#344054')
      Text(this.description)
        .fontSize(13)
        .fontColor('#667085')
    }
    .width('100%')
    .padding(24)
    .alignItems(HorizontalAlign.Center)
  }
}
```

- [ ] **Step 4: Run build**

Run the standard `assembleHap` command from `pet_boarding/`.

Expected: build succeeds or reports a component syntax issue in the new files. Fix the cited file and rerun.

- [ ] **Step 5: Commit**

```powershell
git add -- pet_boarding/entry/src/main/ets/components/StatusTag.ets pet_boarding/entry/src/main/ets/components/SummaryCard.ets pet_boarding/entry/src/main/ets/components/EmptyState.ets
git commit -m "feat: add shared HarmonyOS UI components"
```

---

### Task 4: Routing, Login, And Home Shell

**Files:**
- Modify: `pet_boarding/entry/src/main/resources/base/profile/main_pages.json`
- Modify: `pet_boarding/entry/src/main/ets/pages/Index.ets`
- Create: `pet_boarding/entry/src/main/ets/pages/LoginPage.ets`
- Create: `pet_boarding/entry/src/main/ets/pages/HomePage.ets`

- [ ] **Step 1: Register all MVP pages**

Replace `pet_boarding/entry/src/main/resources/base/profile/main_pages.json` with:

```json
{
  "src": [
    "pages/Index",
    "pages/LoginPage",
    "pages/HomePage",
    "pages/OwnerListPage",
    "pages/OwnerFormPage",
    "pages/PetListPage",
    "pages/PetFormPage",
    "pages/OrderListPage",
    "pages/OrderFormPage",
    "pages/CheckInPage",
    "pages/CareRecordPage",
    "pages/CheckoutPage",
    "pages/HistoryPage"
  ]
}
```

- [ ] **Step 2: Replace default Index page**

Replace `pet_boarding/entry/src/main/ets/pages/Index.ets` with:

```typescript
import router from '@ohos.router';

@Entry
@Component
struct Index {
  aboutToAppear() {
    router.replaceUrl({ url: 'pages/LoginPage' });
  }

  build() {
    Column() {
      Text('宠物寄养管理')
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
        .fontColor('#101828')
      Text('正在进入...')
        .fontSize(14)
        .fontColor('#667085')
        .margin({ top: 8 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .backgroundColor('#F5F7FA')
  }
}
```

- [ ] **Step 3: Add login page**

Create `pet_boarding/entry/src/main/ets/pages/LoginPage.ets`:

```typescript
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
```

- [ ] **Step 4: Add home page**

Create `pet_boarding/entry/src/main/ets/pages/HomePage.ets`:

```typescript
import router from '@ohos.router';
import { SummaryCard } from '../components/SummaryCard';
import { HomeMetrics } from '../model/PetBoardingModels';
import { petBoardingRepository } from '../repository/PetBoardingRepository';

interface HomeAction {
  title: string;
  subtitle: string;
  url: string;
}

@Entry
@Component
struct HomePage {
  @State metrics: HomeMetrics = petBoardingRepository.getHomeMetrics();
  private actions: HomeAction[] = [
    { title: '主人管理', subtitle: '建档、编辑、删除', url: 'pages/OwnerListPage' },
    { title: '宠物管理', subtitle: '关联主人档案', url: 'pages/PetListPage' },
    { title: '订单管理', subtitle: '创建待入住订单', url: 'pages/OrderListPage' },
    { title: '入住登记', subtitle: '分配空闲房间', url: 'pages/CheckInPage' },
    { title: '照护记录', subtitle: '记录喂食清洁等', url: 'pages/CareRecordPage' },
    { title: '退房办理', subtitle: '完成订单并释放房间', url: 'pages/CheckoutPage' },
    { title: '历史订单', subtitle: '查看完整寄养记录', url: 'pages/HistoryPage' }
  ];

  aboutToAppear() {
    this.metrics = petBoardingRepository.getHomeMetrics();
  }

  build() {
    Scroll() {
      Column({ space: 16 }) {
        Text('今日门店')
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .fontColor('#101828')
          .width('100%')
        Grid() {
          GridItem() {
            SummaryCard({ title: '寄养中', value: `${this.metrics.boardingNow}`, subtitle: '当前在店宠物' })
          }
          GridItem() {
            SummaryCard({ title: '今日入住', value: `${this.metrics.todayCheckins}`, subtitle: '已办理入住' })
          }
          GridItem() {
            SummaryCard({ title: '今日退房', value: `${this.metrics.todayCheckouts}`, subtitle: '已完成退房' })
          }
          GridItem() {
            SummaryCard({ title: '空闲房间', value: `${this.metrics.availableRooms}`, subtitle: '可分配笼位' })
          }
        }
        .columnsTemplate('1fr 1fr')
        .columnsGap(12)
        .rowsGap(12)

        Text('业务入口')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor('#101828')
          .width('100%')
          .margin({ top: 8 })

        ForEach(this.actions, (item: HomeAction) => {
          Button(`${item.title}  ${item.subtitle}`)
            .width('100%')
            .height(48)
            .borderRadius(8)
            .onClick(() => {
              router.pushUrl({ url: item.url });
            })
        }, (item: HomeAction) => item.url)
      }
      .padding(16)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA')
  }
}
```

- [ ] **Step 5: Run build**

Run the standard `assembleHap` command from `pet_boarding/`.

Expected: if later pages are not created yet, the build can fail because `main_pages.json` references missing files. In that case, continue directly to Task 5 and rerun after owner pages exist. If the failure is in `LoginPage`, `HomePage`, or `Index`, fix it before continuing.

- [ ] **Step 6: Commit**

```powershell
git add -- pet_boarding/entry/src/main/resources/base/profile/main_pages.json pet_boarding/entry/src/main/ets/pages/Index.ets pet_boarding/entry/src/main/ets/pages/LoginPage.ets pet_boarding/entry/src/main/ets/pages/HomePage.ets
git commit -m "feat: add login and home shell"
```

---

### Task 5: Owner CRUD Pages

**Files:**
- Create: `pet_boarding/entry/src/main/ets/pages/OwnerListPage.ets`
- Create: `pet_boarding/entry/src/main/ets/pages/OwnerFormPage.ets`

- [ ] **Step 1: Add owner list page**

Create `pet_boarding/entry/src/main/ets/pages/OwnerListPage.ets`:

```typescript
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
                    .onClick(() => router.pushUrl({ url: `pages/OwnerFormPage?id=${owner.id}` }))
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
```

- [ ] **Step 2: Add owner form page**

Create `pet_boarding/entry/src/main/ets/pages/OwnerFormPage.ets`:

```typescript
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
    Column({ space: 14 }) {
      Text(this.ownerId.length > 0 ? '编辑主人' : '新增主人')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor('#101828')
        .width('100%')
      TextInput({ placeholder: '姓名', text: this.name })
        .height(48)
        .backgroundColor(Color.White)
        .borderRadius(8)
        .onChange((value: string) => this.name = value)
      TextInput({ placeholder: '手机号', text: this.phone })
        .height(48)
        .backgroundColor(Color.White)
        .borderRadius(8)
        .onChange((value: string) => this.phone = value)
      TextInput({ placeholder: '备注', text: this.remark })
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
    .width('100%')
    .height('100%')
    .padding(16)
    .backgroundColor('#F5F7FA')
  }
}
```

- [ ] **Step 3: Run build**

Run the standard `assembleHap` command.

Expected: build may still fail because other registered pages are not created. Errors in owner files must be fixed before continuing.

- [ ] **Step 4: Manual owner check**

Launch preview/device when available and verify:

```text
Login -> Home -> 主人管理 -> 新增 -> 保存 -> list shows new owner -> 编辑 -> 保存 -> 删除
```

Expected: list refreshes after save/delete; deleting an owner with an open order shows the repository blocking message.

- [ ] **Step 5: Commit**

```powershell
git add -- pet_boarding/entry/src/main/ets/pages/OwnerListPage.ets pet_boarding/entry/src/main/ets/pages/OwnerFormPage.ets
git commit -m "feat: add owner CRUD pages"
```

---

### Task 6: Pet CRUD Pages

**Files:**
- Create: `pet_boarding/entry/src/main/ets/pages/PetListPage.ets`
- Create: `pet_boarding/entry/src/main/ets/pages/PetFormPage.ets`

- [ ] **Step 1: Add pet list page**

Create `pet_boarding/entry/src/main/ets/pages/PetListPage.ets` with this concrete behavior:

```typescript
// State:
// keyword: string
// pets: Pet[] = petBoardingRepository.listPets()
// Refresh on aboutToAppear and Search.onChange.
// Render pet.name, pet.type, pet.breed, pet.age, pet.weight, pet.temperament.
// Render owner name with petBoardingRepository.ownerName(pet.ownerId).
// Actions:
// 新增 -> pages/PetFormPage
// 编辑 -> pages/PetFormPage?id=<pet.id>
// 删除 -> petBoardingRepository.deletePet(pet.id), toast result.message, refresh
```

Use these imports:

```typescript
import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { EmptyState } from '../components/EmptyState';
import { Pet } from '../model/PetBoardingModels';
import { petBoardingRepository } from '../repository/PetBoardingRepository';
```

- [ ] **Step 2: Add pet form page**

Create `pet_boarding/entry/src/main/ets/pages/PetFormPage.ets`. Required behavior:

```typescript
// State:
// petId, ownerId, name, type, breed, temperament as strings
// age and weight as strings in the form, converted to numbers on save
// owners = petBoardingRepository.listOwners()
// aboutToAppear loads edit pet if id param exists
// Save validates ownerId, name, and type
// Save builds PetInput and calls petBoardingRepository.savePet(input, petId)
```

Use `Select` or a compact list of owner buttons for owner selection. If the HarmonyOS API level rejects `Select`, replace it with `ForEach(owners)` buttons and keep the selected owner id in state. The visible owner field must make it clear which owner is selected.

- [ ] **Step 3: Run build**

Run the standard `assembleHap` command.

Expected: pet page type errors are fixed before continuing. Remaining failures can only be missing later registered pages.

- [ ] **Step 4: Manual pet check**

```text
Login -> Home -> 宠物管理 -> 新增 -> choose owner -> save -> edit -> delete
```

Expected: pet list shows owner name; deleting a pet with an open order is blocked.

- [ ] **Step 5: Commit**

```powershell
git add -- pet_boarding/entry/src/main/ets/pages/PetListPage.ets pet_boarding/entry/src/main/ets/pages/PetFormPage.ets
git commit -m "feat: add pet CRUD pages"
```

---

### Task 7: Boarding Order CRUD Pages

**Files:**
- Create: `pet_boarding/entry/src/main/ets/pages/OrderListPage.ets`
- Create: `pet_boarding/entry/src/main/ets/pages/OrderFormPage.ets`

- [ ] **Step 1: Add order list page**

Create `pet_boarding/entry/src/main/ets/pages/OrderListPage.ets`. Required imports:

```typescript
import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { EmptyState } from '../components/EmptyState';
import { orderStatusText, orderStatusTone, StatusTag } from '../components/StatusTag';
import { BoardingOrder } from '../model/PetBoardingModels';
import { petBoardingRepository } from '../repository/PetBoardingRepository';
```

Required behavior:

```typescript
// State:
// orders: BoardingOrder[] = petBoardingRepository.listOrders()
// Refresh on aboutToAppear.
// Render order id, ownerName, petName, roomNo, remark, checkinTime if present.
// Render StatusTag({ text: orderStatusText(order.status), tone: orderStatusTone(order.status) }).
// Actions:
// 新增 -> pages/OrderFormPage
// 编辑 -> pages/OrderFormPage?id=<order.id>
// 删除 -> petBoardingRepository.deleteOrder(order.id), toast result.message, refresh
```

- [ ] **Step 2: Add order form page**

Create `pet_boarding/entry/src/main/ets/pages/OrderFormPage.ets`. Required behavior:

```typescript
// State:
// orderId, ownerId, petId, remark
// owners = petBoardingRepository.listOwners()
// pets = petBoardingRepository.listPets()
// aboutToAppear loads edit order if id param exists.
// Pet choices are filtered by selected ownerId.
// Save validates ownerId and petId.
// Save builds OrderInput and calls petBoardingRepository.saveOrder(input, orderId).
```

Use owner and pet selection buttons if `Select` is not accepted by the local ArkUI compiler. The selected owner and pet must be visible before save.

- [ ] **Step 3: Run build**

Run the standard `assembleHap` command.

Expected: order page type errors are fixed before continuing. Remaining failures can only be missing workflow pages.

- [ ] **Step 4: Manual order check**

```text
Login -> Home -> 订单管理 -> 新增 -> choose owner -> choose pet -> save -> list shows 待入住
```

Expected: a new order starts as `PENDING`; deleting a checked-in order is blocked.

- [ ] **Step 5: Commit**

```powershell
git add -- pet_boarding/entry/src/main/ets/pages/OrderListPage.ets pet_boarding/entry/src/main/ets/pages/OrderFormPage.ets
git commit -m "feat: add boarding order CRUD pages"
```

---

### Task 8: Check-In Workflow

**Files:**
- Create: `pet_boarding/entry/src/main/ets/pages/CheckInPage.ets`

- [ ] **Step 1: Add check-in page**

Create `pet_boarding/entry/src/main/ets/pages/CheckInPage.ets`. Required imports:

```typescript
import promptAction from '@ohos.promptAction';
import { EmptyState } from '../components/EmptyState';
import { BoardingOrder, OrderStatus, Room } from '../model/PetBoardingModels';
import { petBoardingRepository } from '../repository/PetBoardingRepository';
```

Required behavior:

```typescript
// State:
// pendingOrders: BoardingOrder[] = petBoardingRepository.listOrders(OrderStatus.PENDING)
// availableRooms: Room[] = petBoardingRepository.listAvailableRooms()
// selectedOrderId: string
// selectedRoomId: string
// aboutToAppear refreshes both lists.
// Render pending order cards with ownerName, petName, remark.
// Render available room buttons.
// Confirm button calls petBoardingRepository.checkIn(selectedOrderId, selectedRoomId), shows toast, refreshes lists.
```

The confirm button must validate both selections before calling repository:

```typescript
if (this.selectedOrderId.length === 0 || this.selectedRoomId.length === 0) {
  promptAction.showToast({ message: '请选择订单和房间' });
  return;
}
```

- [ ] **Step 2: Run build**

Run the standard `assembleHap` command.

Expected: check-in page compiles or the cited ArkTS error is fixed.

- [ ] **Step 3: Manual check-in verification**

```text
Login -> Home -> 入住登记 -> select pending order -> select available room -> confirm
```

Expected:

```text
Toast: 入住成功
Order disappears from pending list
Room disappears from available list
Home 寄养中 increments by 1
Home 空闲房间 decrements by 1
```

- [ ] **Step 4: Commit**

```powershell
git add -- pet_boarding/entry/src/main/ets/pages/CheckInPage.ets
git commit -m "feat: add check-in workflow"
```

---

### Task 9: Care Record CRUD Page

**Files:**
- Create: `pet_boarding/entry/src/main/ets/pages/CareRecordPage.ets`

- [ ] **Step 1: Add care record page**

Create `pet_boarding/entry/src/main/ets/pages/CareRecordPage.ets`. Required imports:

```typescript
import promptAction from '@ohos.promptAction';
import { EmptyState } from '../components/EmptyState';
import { BoardingOrder, CareRecord, CareRecordInput, CareRecordType, OrderStatus } from '../model/PetBoardingModels';
import { petBoardingRepository } from '../repository/PetBoardingRepository';
```

Required behavior:

```typescript
// State:
// checkedInOrders: BoardingOrder[] = petBoardingRepository.listOrders(OrderStatus.CHECKED_IN)
// selectedOrderId: string
// recordType: CareRecordType = CareRecordType.FEEDING
// content: string
// records: CareRecord[] = []
// aboutToAppear selects first checked-in order when available and loads records.
// Changing selected order reloads records.
// Save validates selectedOrderId and content.
// Save builds CareRecordInput and calls petBoardingRepository.saveCareRecord(input).
// Delete calls petBoardingRepository.deleteCareRecord(record.id), then reloads records.
```

Use these type labels on the page:

```typescript
interface CareTypeOption {
  type: CareRecordType;
  label: string;
}

private careTypes: CareTypeOption[] = [
  { type: CareRecordType.FEEDING, label: '喂食' },
  { type: CareRecordType.WALKING, label: '遛放' },
  { type: CareRecordType.CLEANING, label: '清洁' },
  { type: CareRecordType.MEDICINE, label: '用药' },
  { type: CareRecordType.NOTE, label: '备注' }
];
```

- [ ] **Step 2: Run build**

Run the standard `assembleHap` command.

Expected: care record page compiles or the cited ArkTS error is fixed.

- [ ] **Step 3: Manual care record verification**

```text
Login -> Home -> 照护记录 -> select checked-in order -> choose type -> fill content -> save -> delete record
```

Expected: records list refreshes after save and delete; completed orders do not appear as selectable targets.

- [ ] **Step 4: Commit**

```powershell
git add -- pet_boarding/entry/src/main/ets/pages/CareRecordPage.ets
git commit -m "feat: add care record workflow"
```

---

### Task 10: Checkout And Completed History

**Files:**
- Create: `pet_boarding/entry/src/main/ets/pages/CheckoutPage.ets`
- Create: `pet_boarding/entry/src/main/ets/pages/HistoryPage.ets`

- [ ] **Step 1: Add checkout page**

Create `pet_boarding/entry/src/main/ets/pages/CheckoutPage.ets`. Required behavior:

```typescript
// imports: promptAction, EmptyState, BoardingOrder, OrderStatus, petBoardingRepository
// State:
// checkedInOrders: BoardingOrder[] = petBoardingRepository.listOrders(OrderStatus.CHECKED_IN)
// aboutToAppear refreshes checkedInOrders
// Render ownerName, petName, roomNo, checkinTime, remark
// Button 退房 calls petBoardingRepository.checkOut(order.id), shows toast, refreshes list
```

Expected visible result after checkout:

```text
Checked-out order leaves this page
The same order appears on HistoryPage
The assigned room becomes available for the next check-in
```

- [ ] **Step 2: Add history page**

Create `pet_boarding/entry/src/main/ets/pages/HistoryPage.ets`. Required behavior:

```typescript
// imports: EmptyState, BoardingOrder, CareRecord, OrderStatus, petBoardingRepository
// State:
// completedOrders: BoardingOrder[] = petBoardingRepository.listOrders(OrderStatus.COMPLETED)
// aboutToAppear refreshes completedOrders
// For each completed order:
// - show ownerName
// - show petName
// - show roomNo
// - show checkinTime
// - show checkoutTime
// - show remark
// - show care record count using petBoardingRepository.listCareRecords(order.id).length
```

- [ ] **Step 3: Run build**

Run the standard `assembleHap` command.

Expected: build succeeds because all pages registered in `main_pages.json` now exist.

- [ ] **Step 4: Manual checkout/history verification**

```text
Login -> Home -> 退房办理 -> choose checked-in order -> 退房 -> Home -> 历史订单
```

Expected:

```text
Toast: 退房完成
Home 今日退房 increments
Home 空闲房间 increments
History shows completed order with owner, pet, room, check-in time, checkout time, and care count
```

- [ ] **Step 5: Commit**

```powershell
git add -- pet_boarding/entry/src/main/ets/pages/CheckoutPage.ets pet_boarding/entry/src/main/ets/pages/HistoryPage.ets
git commit -m "feat: add checkout and order history"
```

---

### Task 11: Demo Polish And Final Verification

**Files:**
- Modify: files created in Tasks 3-10 only when fixing layout or compiler issues.

- [ ] **Step 1: Review UI consistency**

Check every page for these concrete rules:

```text
Page background: #F5F7FA
Card background: Color.White
Card radius: 8
Button radius: 8
Primary page title size: 24 or 28
Secondary text color: #667085
Danger action color: #D92D20
No nested decorative card frames around full pages
No oversized settings/admin surfaces
```

Fix any page that violates the list.

- [ ] **Step 2: Run final build**

Run:

```powershell
cd D:\HongMengprogram\20260417\pet_boarding
$env:DEVECO_SDK_HOME='D:\Program Files\Huawei\DevEco Studio\sdk'
& 'D:\Program Files\Huawei\DevEco Studio\tools\node\node.exe' `
  'D:\Program Files\Huawei\DevEco Studio\tools\hvigor\bin\hvigorw.js' `
  --mode module -p module=entry@default -p product=default assembleHap --analyze=normal
```

Expected: build succeeds. Record the final success line or exact first failure.

- [ ] **Step 3: Run full manual demo**

Execute this exact path:

```text
1. Login with admin / 123456.
2. Open 主人管理 and create a new owner.
3. Open 宠物管理 and create a pet linked to that owner.
4. Open 订单管理 and create an order linked to that owner and pet.
5. Open 入住登记 and assign an available room.
6. Open 照护记录 and add a care record to the checked-in order.
7. Open 退房办理 and check out the order.
8. Open 历史订单 and confirm the completed order appears.
9. Return Home and confirm room availability reflects checkout.
```

Expected: the workflow completes without leaving the app and without requiring backend/admin systems.

- [ ] **Step 4: Commit polish fixes**

If Task 11 changed files:

```powershell
git add -- pet_boarding/entry/src/main/ets pet_boarding/entry/src/main/resources/base/profile/main_pages.json
git commit -m "chore: polish MVP demo flow"
```

If Task 11 changed no files:

```powershell
git status --short
```

Expected: no commit is needed and the working tree is clean.

---

## Self-Review Checklist

- Spec coverage:
  - Login is Task 4.
  - Home metrics and quick workflow entry points are Task 4.
  - Owner CRUD is Task 5.
  - Pet CRUD is Task 6.
  - Order CRUD is Task 7.
  - Check-in and room assignment are Task 8.
  - Care record CRUD is Task 9.
  - Checkout and completed history are Task 10.
  - Demo polish and final verification are Task 11.
- The plan keeps backend and management admin UI out of scope.
- The file map matches `pet_boarding/entry/src/main/ets/` organization required by `AGENTS.md`.
- Every task has a build or manual verification step.
- Every task has a commit step.
- The final manual demo path covers the full PRD workflow.
