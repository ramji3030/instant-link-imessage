import express from 'express';

const router = express.Router();
const connections = new Map(); // userId -> [connectedUserIds]

// GET /api/matching/suggestions - AI-powered recommendations
router.get('/suggestions', (req, res) => {
  // Simple mock algorithm - in production, use ML clustering
  const userId = req.user.userId;
  const mockSuggestions = [
    { userId: 'user_1', name: 'Alice', matchScore: 0.92, mutualConnections: 3 },
    { userId: 'user_2', name: 'Bob', matchScore: 0.88, mutualConnections: 1 },
    { userId: 'user_3', name: 'Charlie', matchScore: 0.75, mutualConnections: 0 },
  ];
  res.json({ suggestions: mockSuggestions });
});

// POST /api/matching/add-connection
router.post('/add-connection', (req, res) => {
  const userId = req.user.userId;
  const { targetUserId } = req.body;
  
  const userConnections = connections.get(userId) || [];
  if (!userConnections.includes(targetUserId)) {
    userConnections.push(targetUserId);
    connections.set(userId, userConnections);
  }
  
  res.json({ message: 'Connection added', connections: userConnections });
});

// GET /api/matching/mutual-connections
router.get('/mutual-connections', (req, res) => {
  const userId = req.user.userId;
  const { targetUserId } = req.query;
  
  const userConnections = connections.get(userId) || [];
  const targetConnections = connections.get(targetUserId) || [];
  const mutuals = userConnections.filter(id => targetConnections.includes(id));
  
  res.json({ mutualConnections: mutuals, count: mutuals.length });
});

export default router;
