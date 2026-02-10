import { RefreshToken } from '../models/RefreshToken';

export const RefreshTokenRepository = {
  create: (data: Record<string, unknown>) => RefreshToken.create(data),
  findByHash: (tokenHash: string) => RefreshToken.findOne({ tokenHash }),
  revoke: (id: string, data: Record<string, unknown>) =>
    RefreshToken.findByIdAndUpdate(id, data, { new: true }),
  revokeAllForUser: (userId: string) =>
    RefreshToken.updateMany({ userId, revokedAt: null }, { revokedAt: new Date() })
};
