import 'express-async-errors';
import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import { Server } from 'socket.io';
import http from 'http';
import redis from 'redis';
import dotenv from 'dotenv';

import authRoutes from './routes/auth.js';
import userRoutes from './routes/users.js';
import matchingRoutes from './routes/matching.js';
import messagesRoutes from './routes/messages.js';
import roomsRoutes from './routes/rooms.js';
import { errorHandler } from './middleware/errorHandler.js';
import { authenticate } from './middleware/auth.js';

dotenv.config();

const app = express();
const server = http.createServer(app);
const io = new Server(server, {
  cors: { origin: process.env.FRONTEND_URL || '*', credentials: true },
});

// Redis connection for real-time presence
const redisClient = redis.createClient({
  url: process.env.REDIS_URL || 'redis://localhost:6379',
});

redisClient.on('error', (err) => console.error('Redis Client Error', err));
await redisClient.connect();

// Middleware
app.use(helmet());
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Routes
app.use('/api/auth', authRoutes);
app.use('/api/users', authenticate, userRoutes);
app.use('/api/matching', authenticate, matchingRoutes);
app.use('/api/messages', authenticate, messagesRoutes);
app.use('/api/rooms', authenticate, roomsRoutes);

// Real-time socket events
io.use((socket, next) => {
  const userId = socket.handshake.auth.userId;
  if (!userId) return next(new Error('Invalid user'));
  socket.userId = userId;
  next();
});

io.on('connection', (socket) => {
  console.log(`User ${socket.userId} connected`);
  redisClient.set(`user:${socket.userId}:socket`, socket.id, { EX: 86400 });

  socket.on('typing', ({ conversationId, isTyping }) => {
    io.to(conversationId).emit('user-typing', { userId: socket.userId, isTyping });
  });

  socket.on('disconnect', () => {
    redisClient.del(`user:${socket.userId}:socket`);
  });
});

// Error handling
app.use(errorHandler);

const PORT = process.env.PORT || 5000;
server.listen(PORT, () => {
  console.log(`🚀 Server running on port ${PORT}`);
});

export { io, redisClient };
