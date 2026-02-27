import express from 'express';
import bcryptjs from 'bcryptjs';
import { generateToken } from '../middleware/auth.js';

const router = express.Router();

// Mock database (replace with real DB)
const users = new Map();

// POST /api/auth/register
router.post('/register', async (req, res) => {
  const { email, password, name } = req.body;
  
  if (users.has(email)) {
    return res.status(409).json({ error: 'Email already exists' });
  }

  const hashedPassword = await bcryptjs.hash(password, 10);
  const userId = Date.now().toString();
  
  users.set(email, { userId, name, email, password: hashedPassword });
  
  const token = generateToken(userId, email);
  res.status(201).json({ token, user: { userId, name, email } });
});

// POST /api/auth/login
router.post('/login', async (req, res) => {
  const { email, password } = req.body;
  const user = users.get(email);
  
  if (!user) {
    return res.status(401).json({ error: 'Invalid credentials' });
  }
  
  const isValid = await bcryptjs.compare(password, user.password);
  if (!isValid) {
    return res.status(401).json({ error: 'Invalid credentials' });
  }
  
  const token = generateToken(user.userId, user.email);
  res.json({ token, user: { userId: user.userId, name: user.name, email: user.email } });
});

export default router;
