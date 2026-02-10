export type UserRole = 'customer' | 'vendor' | 'admin';
export type UserStatus = 'active' | 'suspended';

export interface IUser {
  id: string;
  email: string;
  role: UserRole;
  status: UserStatus;
}
