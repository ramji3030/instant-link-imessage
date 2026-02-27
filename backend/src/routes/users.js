import express from 'express';

const router = express.Router();
const users = new Map();

// GET /api/users/me - Get current user profile
router.get('/me', (req, res) => {
  const user = users.get(req.user.userId);
  if (!user) {
    return res.status(404).json({ error: 'User not found' });
  }
  res.json(user);
});

// GET /api/users/:id - Get user by ID
router.get('/:id', (req, res) => {
  const user = users.get(req.params.id);
  if (!user) {
    return res.status(404).json({ error: 'User not found' });
  }
  const { password, ...safeUser } = user;
  res.json(safeUser);
});

// PUT /api/users/:id - Update user profile
router.put('/:id', (req, res) => {
  if (req.params.id !== req.user.userId) {
    return res.status(403).json({ error: 'Unauthorized' });
  }
  
  let user = users.get(req.params.id) || {};
  user = { ...user, ...req.body, userId: req.params.id };
  users.set(req.params.id, user);
  const { password, ...safeUser } = user;
  res.json(safeUser);
});

// GET /api/users/search - Search users
router.get('/search', (req, res) => {
  const q = req.query.q?.toLowerCase() || '';
  const results = Array.from(users.values())
    .filter(u => u.name?.toLowerCase().includes(q))
    .map(({ password, ...u }) => u)
    .slice(0, 10);
  res.json(results);
});

export default router;
