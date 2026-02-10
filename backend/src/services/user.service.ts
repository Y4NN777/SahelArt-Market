import { User } from '../models/User';
import { ApiError } from '../utils/ApiError';

export const UserService = {
  async getById(id: string) {
    const user = await User.findById(id);
    if (!user) {
      throw new ApiError(404, 'NOT_FOUND', 'User not found');
    }
    return user;
  },

  async updateProfile(id: string, profile: Record<string, unknown>) {
    const user = await User.findByIdAndUpdate(id, { profile }, { new: true });
    if (!user) {
      throw new ApiError(404, 'NOT_FOUND', 'User not found');
    }
    return user;
  }
};
