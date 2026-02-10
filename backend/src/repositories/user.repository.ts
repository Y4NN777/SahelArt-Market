import { User } from '../models/User';

export const UserRepository = {
  findByEmail: (email: string) => User.findOne({ email }),
  findById: (id: string) => User.findById(id),
  create: (data: Record<string, unknown>) => User.create(data),
  updateProfile: (id: string, profile: Record<string, unknown>) =>
    User.findByIdAndUpdate(id, { profile }, { new: true }),
  list: (filter: Record<string, unknown>, skip: number, limit: number) =>
    User.find(filter).skip(skip).limit(limit),
  count: (filter: Record<string, unknown>) => User.countDocuments(filter),
  suspend: (id: string) => User.findByIdAndUpdate(id, { status: 'suspended' }, { new: true })
};
