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
