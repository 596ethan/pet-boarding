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
