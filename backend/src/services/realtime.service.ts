import { getIO, isSocketIOInitialized } from '../config/socket';

export const RealtimeService = {
  emitToUser(userId: string, type: string, payload: unknown) {
    if (!isSocketIOInitialized()) return;
    try {
      const io = getIO();
      io.to(`user:${userId}`).emit(type, payload);
    } catch (error) {
      // Silently fail in test mode
    }
  },

  emitToVendor(vendorId: string, type: string, payload: unknown) {
    if (!isSocketIOInitialized()) return;
    try {
      const io = getIO();
      io.to(`vendor:${vendorId}`).emit(type, payload);
    } catch (error) {
      // Silently fail in test mode
    }
  },

  emitToAdmin(type: string, payload: unknown) {
    if (!isSocketIOInitialized()) return;
    try {
      const io = getIO();
      io.to('admin').emit(type, payload);
    } catch (error) {
      // Silently fail in test mode
    }
  },

  emitPublic(type: string, payload: unknown) {
    if (!isSocketIOInitialized()) return;
    try {
      const io = getIO();
      io.emit(type, payload);
    } catch (error) {
      // Silently fail in test mode
    }
  }
};
