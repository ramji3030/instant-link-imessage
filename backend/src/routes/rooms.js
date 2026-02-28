import express from 'express';
import { v4 as uuidv4 } from 'uuid';

const router = express.Router();

// Mock database for ephemeral rooms (TTL-based, replace with Redis in production)
const rooms = new Map();

// Room cleanup interval (every 5 minutes)
setInterval(() => {
  const now = Date.now();
  for (const [roomId, room] of rooms.entries()) {
    if (room.expiresAt && now > room.expiresAt) {
      rooms.delete(roomId);
      console.log(`Room ${roomId} expired and was cleaned up`);
    }
  }
}, 5 * 60 * 1000);

// POST /api/rooms - Create a new ephemeral room
router.post('/', async (req, res) => {
  const { name, maxParticipants, durationMinutes } = req.body;
  const creatorId = req.user.userId;
  
  const roomId = uuidv4();
  const room = {
    id: roomId,
    name: name || `Room ${roomId.slice(0, 8)}`,
    creatorId,
    participants: [creatorId],
    maxParticipants: maxParticipants || 10,
    createdAt: new Date(),
    expiresAt: durationMinutes ? Date.now() + (durationMinutes * 60 * 1000) : Date.now() + (60 * 60 * 1000),
    status: 'active'
  };
  
  rooms.set(roomId, room);
  
  // Emit WebSocket event
  const { io } = await import('../index.js');
  io.emit('room-created', room);
  
  res.status(201).json({ room });
});

// GET /api/rooms/:id - Get room details
router.get('/:id', (req, res) => {
  const { id } = req.params;
  const room = rooms.get(id);
  
  if (!room) return res.status(404).json({ error: 'Room not found' });
  if (room.status !== 'active') return res.status(410).json({ error: 'Room has expired' });
  
  res.json({ room });
});

// POST /api/rooms/:id/join - Join a room
router.post('/:id/join', async (req, res) => {
  const { id } = req.params;
  const userId = req.user.userId;
  const room = rooms.get(id);
  
  if (!room) return res.status(404).json({ error: 'Room not found' });
  if (room.status !== 'active') return res.status(410).json({ error: 'Room has expired' });
  if (room.participants.length >= room.maxParticipants) return res.status(400).json({ error: 'Room is full' });
  
  if (!room.participants.includes(userId)) {
    room.participants.push(userId);
    rooms.set(id, room);
    
    // Emit WebSocket event
    const { io } = await import('../index.js');
    io.to(id).emit('user-joined-room', { roomId: id, userId });
  }
  
  res.json({ room });
});

// POST /api/rooms/:id/leave - Leave a room
router.post('/:id/leave', async (req, res) => {
  const { id } = req.params;
  const userId = req.user.userId;
  const room = rooms.get(id);
  
  if (!room) return res.status(404).json({ error: 'Room not found' });
  
  room.participants = room.participants.filter(p => p !== userId);
  rooms.set(id, room);
  
  // If creator leaves and no one is left, delete the room
  if (room.participants.length === 0) {
    rooms.delete(id);
  }
  
  // Emit WebSocket event
  const { io } = await import('../index.js');
  io.to(id).emit('user-left-room', { roomId: id, userId });
  
  res.json({ success: true });
});

// DELETE /api/rooms/:id - Delete/end a room (creator only)
router.delete('/:id', async (req, res) => {
  const { id } = req.params;
  const room = rooms.get(id);
  
  if (!room) return res.status(404).json({ error: 'Room not found' });
  if (room.creatorId !== req.user.userId) return res.status(403).json({ error: 'Only creator can end the room' });
  
  room.status = 'ended';
  rooms.set(id, room);
  
  // Emit WebSocket event
  const { io } = await import('../index.js');
  io.to(id).emit('room-ended', { roomId: id });
  
  res.json({ success: true });
});

// GET /api/rooms - List active rooms (with pagination)
router.get('/', (req, res) => {
  const { page = 1, limit = 10, status = 'active' } = req.query;
  const allRooms = Array.from(rooms.values())
    .filter(room => room.status === status)
    .sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt));
  
  const startIndex = (page - 1) * limit;
  const endIndex = startIndex + parseInt(limit);
  const paginatedRooms = allRooms.slice(startIndex, endIndex);
  
  res.json({
    rooms: paginatedRooms,
    pagination: {
      currentPage: parseInt(page),
      totalPages: Math.ceil(allRooms.length / limit),
      total: allRooms.length
    }
  });
});

export default router;
