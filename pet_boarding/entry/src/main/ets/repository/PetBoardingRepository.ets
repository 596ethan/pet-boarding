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
