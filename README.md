# instant-link-imessage
# instant-link-imessage 🚀

**Advanced iMessage Social Network** - Instant connections, AI matching engine, real-time messaging, and ephemeral rooms. iOS app + backend + iMessage extension inspired by Series.so.

## ✨ Key Features

### 🎯 Core Functionality
- **Instant Connections**: One-tap profile sharing via iMessage
- **AI Matching Engine**: Smart recommendations using k-means clustering + graph algorithms
- **Real-Time Messaging**: WebSocket-powered chat with typing indicators
- **Ephemeral Rooms**: Short-lived group spaces for voice/video (future)
- **Presence System**: Real-time online status via Redis

### 📱 User Experience
- Native SwiftUI iOS app with iMessage extension
- Frictionless onboarding (.edu emails for verification)
- Profile discovery with mutual connections
- Trust & safety system (block lists, reporting)

### 🔧 Advanced Features
- Multi-tenant GraphQL API (future)
- Machine learning-based matching
- Event-driven architecture with Redis queues
- Docker deployment ready
- CI/CD pipelines with GitHub Actions

## 🏗️ Project Structure

```
instant-link-imessage/
├── backend/                      # Node.js/Express server
│   ├── src/
│   │   ├── index.js             # Main server entry
│   │   ├── routes/              # API endpoints
│   │   │   ├── auth.js          # JWT authentication
│   │   │   ├── users.js         # User profiles
│   │   │   ├── matching.js      # ML matching engine
│   │   │   ├── messages.js      # Direct messaging
│   │   │   └── rooms.js         # Ephemeral rooms
│   │   ├── middleware/          # Auth, error handling
│   │   ├── models/              # Database schemas
│   │   ├── services/            # Business logic
│   │   └── utils/               # Helpers
│   ├── migrations/              # Database migrations
│   ├── package.json
│   └── Dockerfile
├── ios/                         # SwiftUI iOS app
│   ├── InstantLink/             # Main app target
│   ├── InstantLinkMessages/     # iMessage extension
│   └── InstantLink.xcodeproj
├── .github/workflows/           # CI/CD pipelines
├── docker-compose.yml           # Local development
├── Dockerfile                   # Production image
└── README.md
```

## 🚀 Quick Start

### Prerequisites
- Node.js 18+
- PostgreSQL 14+
- Redis 6+
- Xcode 14+ (for iOS)

### Backend Setup

```bash
# Clone repository
git clone https://github.com/ramji3030/instant-link-imessage.git
cd instant-link-imessage

# Install dependencies
cd backend
npm install

# Configure environment
cp .env.example .env
# Edit .env with your config

# Run database migrations
npm run migrate

# Start development server
npm run dev
```

### Docker Compose (Recommended)

```bash
docker-compose up -d
```

This starts:
- PostgreSQL database (port 5432)
- Redis cache (port 6379)
- Node.js backend (port 5000)

### iOS App Setup

```bash
cd ios
open InstantLink.xcodeproj
# Select simulator & press Run
```

## 📚 API Documentation

### Authentication
```
POST /api/auth/register
POST /api/auth/login
POST /api/auth/refresh-token
POST /api/auth/logout
```

### Users
```
GET /api/users/me
GET /api/users/:id
PUT /api/users/:id
GET /api/users/search?q=query
```

### Matching
```
GET /api/matching/suggestions    # AI-powered recommendations
POST /api/matching/add-connection
GET /api/matching/mutual-connections
```

### Messages
```
GET /api/messages/:conversationId
POST /api/messages
DELETE /api/messages/:id
```

### Rooms
```
POST /api/rooms                   # Create ephemeral room
GET /api/rooms/:id
POST /api/rooms/:id/invite
```

## 🔌 WebSocket Events

- `user-typing`: Real-time typing indicators
- `message-sent`: New message arrival
- `user-online`: Presence updates
- `room-created`: Ephemeral room creation

## 🗄️ Database Schema

Key tables:
- `users` - User profiles & metadata
- `connections` - Graph edges for matching
- `conversations` - Direct message threads
- `messages` - Chat history
- `rooms` - Ephemeral group spaces
- `tokens` - JWT refresh tokens

## 🚢 Deployment

### AWS ECS (Recommended)

```bash
# Build & push Docker image
aws ecr get-login-password --region us-east-1 | docker login ...
docker build -t instant-link:latest .
docker tag instant-link:latest [ECR_URI]:latest
docker push [ECR_URI]:latest

# Deploy with Terraform or CloudFormation
```

### Environment Variables

```
DATABASE_URL=postgresql://user:pass@localhost:5432/instant_link
REDIS_URL=redis://localhost:6379
JWT_SECRET=your_secret_key
NODE_ENV=production
PORT=5000
FRONTEND_URL=https://app.instantlink.com
AI_MODEL_ENDPOINT=https://api.example.com/ml
```

## 🧪 Testing

```bash
# Run tests
npm test

# Coverage report
npm run test:coverage

# E2E tests (future)
npm run test:e2e
```

## 🤖 AI Matching Algorithm

The matching engine uses:
1. **K-means clustering** - Group users by interests/location
2. **Graph algorithms** - Find mutual connections & second-degree paths
3. **Collaborative filtering** - Recommend based on similar users
4. **Diversity enforcement** - Prevent filter bubbles

Run matching job:
```bash
node src/jobs/matchingEngine.js
```

## 📱 iMessage Extension

### Swift Code Structure

```swift
// InstantLinkMessages/MessagesViewController.swift
class MessagesViewController: MSMessagesAppViewController {
    func sendProfileInvite(_ profile: UserProfile) {
        let url = URL(string: "instantlink://invite?userId=\(profile.id)")
        let message = MSMessage()
        message.url = url
        activeConversation?.insert(message)
    }
}
```

## 🔐 Security

- ✅ End-to-end encryption (future)
- ✅ JWT token rotation
- ✅ Rate limiting on all endpoints
- ✅ SQL injection prevention (parameterized queries)
- ✅ XSS/CSRF protection via Helmet
- ✅ Privacy: No scrapin of phone contacts without permission

## 📊 Monitoring & Analytics

- Sentry for error tracking
- DataDog for infrastructure monitoring
- Custom dashboards for user metrics

## 🤝 Contributing

1. Fork repo
2. Create feature branch (`git checkout -b feature/amazing`)
3. Commit changes (`git commit -am 'Add amazing feature'`)
4. Push branch (`git push origin feature/amazing`)
5. Open Pull Request

## 📄 License

MIT License - see LICENSE file

## 🙏 Acknowledgments

- Inspired by Series.so's AI-driven networking
- Built with Express, React Native, PostgreSQL
- Powered by Socket.io for real-time features

## 📧 Contact

- GitHub: [@ramji3030](https://github.com/ramji3030)
- Email: contact@instantlink.app

---

**Made with ❤️ for instant connections**
