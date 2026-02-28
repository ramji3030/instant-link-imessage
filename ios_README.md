# iOS App Setup - Instant Link iMessage

## Prerequisites
- macOS with Xcode 14.0+
- iOS 15.0+ deployment target
- Apple Developer account ($99/year)

## Project Structure
```
ios/
├── InstantLink.xcodeproj
├── InstantLink/              # Main iOS app
│   ├── App/
│   │   ├── InstantLinkApp.swift
│   │   └── AppDelegate.swift
│   ├── Views/
│   │   ├── ContentView.swift
│   │   ├── LoginView.swift
│   │   ├── SignUpView.swift
│   │   ├── HomeView.swift
│   │   ├── ProfileView.swift
│   │   ├── ConversationsView.swift
│   │   └── ChatView.swift
│   ├── Models/
│   │   ├── User.swift
│   │   ├── Message.swift
│   │   └── Conversation.swift
│   ├── Services/
│   │   ├── APIService.swift
│   │   ├── AuthService.swift
│   │   └── WebSocketService.swift
│   └── ViewModels/
│       └── AuthViewModel.swift
├── InstantLinkMessages/      # iMessage Extension
│   ├── MessagesViewController.swift
│   └── MainInterface.storyboard
└── InstantLinkTests/
    └── InstantLinkTests.swift
```

## Setup Instructions

### 1. Open Project
```bash
cd ios
open InstantLink.xcodeproj
```

### 2. Configure Signing
- Select project in Xcode
- Go to "Signing & Capabilities"
- Select your Team (Apple Developer account)
- Set Bundle Identifier: `com.instantlink.app`

### 3. Configure Backend URL
Edit `Services/APIService.swift`:
```swift
static let baseURL = "https://your-backend-url.com/api"
```

### 4. Install Dependencies (if using SPM)
- File → Add Packages
- Add dependencies as needed

### 5. Run on Simulator
- Select iPhone simulator
- Press Cmd+R to run

## Building for App Store

### 1. Archive App
- Product → Archive
- Wait for archive to complete

### 2. Upload to App Store Connect
- Click "Distribute App"
- Select "App Store Connect"
- Follow the upload wizard

### 3. Configure App Store Connect
- Create new app in App Store Connect
- Fill in metadata (name, description, screenshots)
- Submit for review

## iMessage Extension

The iMessage extension allows users to share their Instant Link profile directly in iMessage conversations.

### Features
- Share profile link
- Quick invite sending
- Deep link back to app

### Testing iMessage Extension
- Run "InstantLinkMessages" scheme
- Select iMessage simulator
- Test profile sharing

## Known Issues
- [ ] WebSocket reconnection logic needed
- [ ] Push notifications not yet implemented
- [ ] Profile image upload not implemented

## Next Steps
1. Implement login/signup views
2. Connect to backend API
3. Add WebSocket for real-time messaging
4. Implement conversation list
5. Build chat interface
6. Add push notifications

## Contact
For questions about iOS development, contact the development team.
