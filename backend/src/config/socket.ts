import { Server as HttpServer } from 'http';
import { Server, Socket } from 'socket.io';
import { verifyAccessToken } from './jwt';

let io: Server | null = null;

export const initializeSocketIO = (httpServer: HttpServer) => {
  const allowedOrigins = process.env.ALLOWED_ORIGINS
    ? process.env.ALLOWED_ORIGINS.split(',').map((o) => o.trim())
    : [];

  io = new Server(httpServer, {
    cors: {
      origin: (origin, callback) => {
        if (!origin || allowedOrigins.includes(origin)) {
          callback(null, true);
        } else {
          callback(new Error('Not allowed by CORS'));
        }
      },
      credentials: true
    },
    transports: ['websocket', 'polling']
  });

  io.use((socket: Socket, next) => {
    const token = socket.handshake.auth.token as string;
    if (!token) {
      return next(new Error('Authentication error'));
    }

    try {
      const decoded = verifyAccessToken(token);
      socket.data.user = decoded;
      next();
    } catch (error) {
      next(new Error('Authentication error'));
    }
  });

  io.on('connection', (socket: Socket) => {
    const user = socket.data.user;
    if (!user) return;

    socket.join(`user:${user.id}`);

    if (user.role === 'vendor') {
      socket.join(`vendor:${user.id}`);
    }

    if (user.role === 'admin') {
      socket.join('admin');
    }
  });

  return io;
};

export const getIO = (): Server => {
  if (!io) {
    throw new Error('Socket.IO not initialized');
  }
  return io;
};

export const isSocketIOInitialized = (): boolean => {
  return io !== null;
};
