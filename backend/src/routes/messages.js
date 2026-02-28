import express from 'express';
import { v4 as uuidv4 } from 'uuid';

const router = express.Router();

// Mock database (replace with real DB)
const conversations = new Map();
const messages = new Map();

const initMockData = () => {
  const conv1 = { id: 'conv_1', participants: ['user_1', 'user_2'], lastMessage: 'Hey!', updatedAt: new Date() };
  conversations.set('conv_1', conv1);
  messages.set('msg_1', { id: 'msg_1', conversationId: 'conv_1', senderId: 'user_2', content: 'Hey!', timestamp: new Date().toISOString(), status: 'delivered' });
};
initMockData();

router.get('/conversations', (req, res) => {
  const userId = req.user.userId;
  const userConversations = Array.from(conversations.values())
    .filter(conv => conv.participants.includes(userId))
    .sort((a, b) => new Date(b.updatedAt) - new Date(a.updatedAt));
  res.json({ conversations: userConversations });
});

router.get('/:conversationId', (req, res) => {
  const { conversationId } = req.params;
  const conversation = conversations.get(conversationId);
  if (!conversation) return res.status(404).json({ error: 'Conversation not found' });
  if (!conversation.participants.includes(req.user.userId)) return res.status(403).json({ error: 'Access denied' });
  const conversationMessages = Array.from(messages.values())
    .filter(msg => msg.conversationId === conversationId)
    .sort((a, b) => new Date(a.timestamp) - new Date(b.timestamp));
  res.json({ conversation, messages: conversationMessages });
});

router.post('/', async (req, res) => {
  const { conversationId, content } = req.body;
  const senderId = req.user.userId;
  if (!content || !content.trim()) return res.status(400).json({ error: 'Message content is required' });
  let conversation = conversations.get(conversationId);
  if (!conversation) {
    conversation = { id: conversationId, participants: [senderId], lastMessage: content, updatedAt: new Date() };
    conversations.set(conversationId, conversation);
  }
  if (!conversation.participants.includes(senderId)) return res.status(403).json({ error: 'Access denied' });
  const messageId = uuidv4();
  const message = { id: messageId, conversationId, senderId, content: content.trim(), timestamp: new Date().toISOString(), status: 'sent' };
  messages.set(messageId, message);
  conversation.lastMessage = content;
  conversation.updatedAt = new Date();
  conversations.set(conversationId, conversation);
  const { io } = await import('../index.js');
  io.to(conversationId).emit('message-sent', message);
  res.status(201).json({ message });
});

router.delete('/:id', async (req, res) => {
  const { id } = req.params;
  const message = messages.get(id);
  if (!message) return res.status(404).json({ error: 'Message not found' });
  if (message.senderId !== req.user.userId) return res.status(403).json({ error: 'Cannot delete another user message' });
  messages.delete(id);
  const { io } = await import('../index.js');
  io.to(message.conversationId).emit('message-deleted', { messageId: id });
  res.json({ success: true });
});

router.patch('/:id/read', (req, res) => {
  const { id } = req.params;
  const message = messages.get(id);
  if (!message) return res.status(404).json({ error: 'Message not found' });
  message.status = 'read';
  messages.set(id, message);
  res.json({ message });
});

export default router;
