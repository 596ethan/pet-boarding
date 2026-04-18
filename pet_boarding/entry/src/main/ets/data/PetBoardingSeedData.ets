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

function formatDate(date: Date): string {
  const month: string = `${date.getMonth() + 1}`.padStart(2, '0');
  const day: string = `${date.getDate()}`.padStart(2, '0');
  return `${date.getFullYear()}-${month}-${day}`;
}

const todayDate: Date = new Date();
const yesterdayDate: Date = new Date(todayDate.getTime() - 24 * 60 * 60 * 1000);
const DEMO_TODAY: string = formatDate(todayDate);
const DEMO_YESTERDAY: string = formatDate(yesterdayDate);

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
    remark: '喜欢上午接送，需要电话确认。'
  },
  {
    id: 'owner-2',
    name: '陈晓',
    phone: '13800010002',
    remark: '宠物对陌生人慢热，先轻声安抚。'
  },
  {
    id: 'owner-3',
    name: '周宁',
    phone: '13800010003',
    remark: '退房前同步照护记录。'
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
    temperament: '安静，怕吵。'
  },
  {
    id: 'pet-2',
    ownerId: 'owner-2',
    name: '可乐',
    type: '狗',
    breed: '柯基',
    age: 2,
    weight: 11.2,
    temperament: '活泼，爱散步。'
  },
  {
    id: 'pet-3',
    ownerId: 'owner-3',
    name: '糯米',
    type: '猫',
    breed: '布偶',
    age: 4,
    weight: 5.6,
    temperament: '亲人，需每日梳毛。'
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
  },
  {
    id: 'room-4',
    roomNo: 'B202',
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
    checkinTime: `${DEMO_TODAY} 09:20`,
    checkoutTime: '',
    remark: '寄养三天，注意猫砂清洁。'
  },
  {
    id: 'order-2',
    ownerId: 'owner-2',
    petId: 'pet-2',
    roomId: '',
    status: OrderStatus.PENDING,
    checkinTime: '',
    checkoutTime: '',
    remark: '今天下午入住，优先安排安静房间。'
  },
  {
    id: 'order-3',
    ownerId: 'owner-3',
    petId: 'pet-3',
    roomId: 'B201',
    status: OrderStatus.COMPLETED,
    checkinTime: `${DEMO_YESTERDAY} 10:10`,
    checkoutTime: `${DEMO_TODAY} 08:40`,
    remark: '已完成退房，主人反馈良好。'
  }
];

export const seedCareRecords: CareRecord[] = [
  {
    id: 'care-1',
    orderId: 'order-1',
    type: CareRecordType.FEEDING,
    content: '上午已喂食，饮水正常。',
    recordTime: `${DEMO_TODAY} 10:00`
  },
  {
    id: 'care-2',
    orderId: 'order-3',
    type: CareRecordType.CLEANING,
    content: '退房前完成房间清洁和毛发整理。',
    recordTime: `${DEMO_TODAY} 08:20`
  }
];
