import jwt from 'jsonwebtoken';
import { IUser } from '../types/auth.types';

const jwtSecret = () => process.env.JWT_SECRET || 'changeme';
const jwtExpiresIn = () => process.env.JWT_EXPIRES_IN || '15m';

export const signAccessToken = (user: IUser) => {
  return jwt.sign(
    { userId: user.id, email: user.email, role: user.role },
    jwtSecret(),
    { expiresIn: jwtExpiresIn() }
  );
};

export const verifyAccessToken = (token: string) => {
  return jwt.verify(token, jwtSecret()) as {
    userId: string;
    email: string;
    role: IUser['role'];
  };
};
