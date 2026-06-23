import { Server } from 'socket.io';
import jwt from 'jsonwebtoken';

let ioInstance = null;
const userSockets = new Map(); // userId -> Set of socketIds

export function initSocket(server) {
  const io = new Server(server, {
    cors: {
      origin: '*',
      methods: ['GET', 'POST'],
    },
  });

  ioInstance = io;

  io.use((socket, next) => {
    const token = socket.handshake.auth?.token || socket.handshake.query?.token;
    if (!token) {
      return next();
    }
    try {
      const decoded = jwt.verify(token, process.env.JWT_SECRET || 'change-me-in-production');
      socket.userId = decoded.sub;
      next();
    } catch (err) {
      console.warn('Socket auth failed:', err.message);
      next();
    }
  });

  io.on('connection', (socket) => {
    console.log(`🔌 Socket connected: ${socket.id} (User: ${socket.userId || 'Guest'})`);

    if (socket.userId) {
      if (!userSockets.has(socket.userId)) {
        userSockets.set(socket.userId, new Set());
      }
      userSockets.get(socket.userId).add(socket.id);
    }

    socket.on('disconnect', () => {
      console.log(`🔌 Socket disconnected: ${socket.id}`);
      if (socket.userId && userSockets.has(socket.userId)) {
        const sockets = userSockets.get(socket.userId);
        sockets.delete(socket.id);
        if (sockets.size === 0) {
          userSockets.delete(socket.userId);
        }
      }
    });
  });

  console.log('⚡ Socket.io service initialized');
  return io;
}

export function broadcastToUser(userId, event, data) {
  if (!ioInstance) return;
  const socketIds = userSockets.get(userId);
  if (socketIds) {
    socketIds.forEach((socketId) => {
      ioInstance.to(socketId).emit(event, data);
    });
  }
}

export function broadcastGlobal(event, data) {
  if (!ioInstance) return;
  ioInstance.emit(event, data);
}
