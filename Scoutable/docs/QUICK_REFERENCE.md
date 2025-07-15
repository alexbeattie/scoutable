# Scoutable Quick Reference Guide

## 🎯 App Overview
**Scoutable** is a sports scouting platform connecting athletes, coaches, and schools through a modern SwiftUI iOS app.

## 👥 User Types
- **Athletes**: High school/college students seeking opportunities
- **Coaches**: College/professional coaches seeking talent  
- **Schools**: Educational institutions showcasing programs

## 🏗️ Technical Stack
- **Framework**: SwiftUI (iOS 18.5+)
- **Language**: Swift 6.0
- **Platform**: iOS (primary), potential macOS
- **State Management**: @StateObject, @ObservedObject, @State
- **Navigation**: TabView with nested NavigationView

## 📱 Core Features

### For Athletes
- Profile creation with stats, videos, achievements
- Video upload and highlight reel creation
- Stats tracking (UTR, GPA, test scores)
- Coach connection requests
- School research and application tracking

### For Coaches
- Advanced athlete search with 20+ filters
- Prospect list management
- Communication hub with athletes
- Recruitment calendar and evaluation tools
- School program showcase

### For Schools
- Program showcase with media galleries
- Virtual campus tours
- Admissions integration
- Coach directory and contact info
- Analytics dashboard

## 🗂️ Data Models

```swift
struct Player: Identifiable {
    let id = UUID()
    let firstName: String
    let lastName: String
    let profileImageName: String
    let sport: String
    let graduationYear: Int
    let highSchool: String
    let location: String
    let utr: Double // Universal Tennis Rating
    let stars: Int // Recruiting stars (1-5)
    let gpa: Double
    let videos: [String]
    let upcomingEvents: [String]
}

struct Coach: Identifiable {
    let id = UUID()
    let name: String
    let title: String
    let school: School
}

struct School: Identifiable {
    let id = UUID()
    let name: String
    let division: String
    let conference: String
    let players: [Player]
    let coaches: [Coach]
}
```

## 🧭 Navigation Structure
```
MainTabView (Root)
├── Home Feed (Social posts)
├── Players (Browse athletes)
├── Coaches (Browse coaches)
├── Schools (Browse institutions)
└── Profile (User profile)
```

## 🎨 Design System
- **Primary Color**: Blue (#007AFF)
- **Typography**: SF Pro fonts
- **Icons**: SF Symbols
- **Spacing**: 8pt grid system
- **Accessibility**: WCAG 2.1 AA compliant

## 🔍 Search & Filtering
- **20+ filter criteria** for athletes
- **Geographic radius search**
- **Saved search functionality**
- **Real-time search suggestions**
- **Natural language processing**

## 💬 Communication
- **Real-time messaging** between all users
- **Video calls** for virtual meetings
- **File sharing** up to 50MB
- **Message templates** and scheduling
- **Read receipts** and typing indicators

## 📹 Content Management
- **Video streaming** with adaptive quality
- **Photo galleries** with organization
- **Document upload** (PDFs, transcripts)
- **Content moderation** with AI filtering
- **Analytics** and view tracking

## 🔐 Security & Privacy
- **End-to-end encryption** for messages
- **Multi-factor authentication**
- **Data encryption** at rest and in transit
- **GDPR, COPPA, FERPA compliance**
- **Privacy by design** principles

## 📊 Success Metrics
- **DAU Target**: 50,000+
- **MAU Target**: 500,000+
- **Session Duration**: 15+ minutes
- **User Retention**: 60%+ at 30 days
- **App Store Rating**: 4.5+ stars

## 🚀 Development Phases

### Phase 1 (Months 1-3) - MVP ✅
- Basic UI structure and navigation
- Data models and sample data
- List views for players, coaches, schools
- Basic filtering functionality
- Profile views with stats display

### Phase 2 (Months 4-6) - Enhanced Features
- User authentication and profiles
- Video upload and playback
- Messaging system
- Advanced filtering and search
- Push notifications

### Phase 3 (Months 7-9) - Advanced Features
- AI-powered recommendations
- Live streaming capabilities
- Social features (comments, likes)
- Calendar integration
- Analytics and insights

## 🎯 Priority Features (P0 - Critical)
1. **Multi-factor authentication**
2. **Comprehensive profile creation**
3. **Video upload and management**
4. **Advanced athlete search**
5. **Communication hub**
6. **Real-time messaging**
7. **Video streaming**
8. **Advanced search**

## 🔧 Technical Requirements
- **Performance**: App launch <3s, search <1s
- **Scalability**: 1M+ concurrent users
- **Security**: SOC 2, GDPR, COPPA compliance
- **Accessibility**: WCAG 2.1 AA compliance
- **Platform**: iOS 18.5+ primary

## 📋 Key Integrations
- **Payment**: Stripe, Apple Pay
- **Video**: AWS S3, CloudFront
- **Analytics**: Firebase, Mixpanel
- **Email**: SendGrid, Mailgun
- **SMS**: Twilio
- **Search**: Algolia, Elasticsearch

## 🎨 UI Components
- **OnboardingView**: User type selection
- **MainTabView**: Primary navigation
- **PlayersListView**: Athlete browsing
- **CoachesListView**: Coach browsing
- **SchoolsListView**: School browsing
- **FilterView**: Search and filtering
- **Profile Views**: Detailed user profiles

## 🔄 State Management
- **FilterState**: Centralized filtering logic
- **CursorManager**: Custom cursor interactions
- **User State**: Authentication and profile data
- **Content State**: Videos, images, documents

## 📱 Platform Features
- **Push Notifications**: Real-time updates
- **iCloud Sync**: User data synchronization
- **Apple Sign In**: Social authentication
- **Siri Shortcuts**: Quick actions
- **Widgets**: Home screen integration

## 🎯 Business Model
- **Freemium**: Basic features free
- **Premium Subscriptions**: Advanced features
- **School Partnerships**: Enterprise pricing
- **Advertising**: Relevant sponsors
- **Event Hosting**: Recruitment events

## 📈 Analytics & Monitoring
- **User Behavior**: Engagement and retention
- **Performance**: App speed and reliability
- **Business Metrics**: Revenue and growth
- **Technical Metrics**: Crashes and errors
- **Content Analytics**: Video and media usage

## 🔒 Compliance Requirements
- **NCAA**: College athletics compliance
- **NAIA**: Smaller institutions
- **FERPA**: Student data protection
- **COPPA**: Under 13 protection
- **GDPR**: European privacy
- **CCPA**: California privacy

## 🚨 Risk Mitigation
- **Technical**: Use proven CDN and WebSocket solutions
- **Business**: Focus on core value proposition
- **Operational**: Plan for team scaling and costs
- **Regulatory**: Build compliance into architecture

## 📚 Documentation Structure
- **README.md**: Main project overview
- **PROJECT_CONTEXT.md**: Comprehensive business context
- **REQUIREMENTS.md**: Detailed feature requirements
- **QUICK_REFERENCE.md**: This file - fast access guide
- **File headers**: Individual file context
- **Code comments**: Inline documentation

## 🎯 AI Cursor Context
This app is a comprehensive sports scouting platform with:
- **Complex user roles** (athletes, coaches, schools)
- **Rich media content** (videos, photos, documents)
- **Advanced search and filtering**
- **Real-time communication**
- **Social networking features**
- **Compliance requirements**
- **Scalability needs**

When helping with this project, consider:
- **User experience** for different user types
- **Performance** for media-heavy content
- **Security** for sensitive user data
- **Accessibility** for inclusive design
- **Scalability** for growth
- **Compliance** for regulatory requirements 