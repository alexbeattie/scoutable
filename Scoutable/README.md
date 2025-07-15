# Scoutable

A SwiftUI-based sports scouting application for connecting athletes, coaches, and schools.

## AI Cursor Context & Specifications

### App Overview
Scoutable is a comprehensive sports scouting platform that facilitates connections between:
- **Athletes** - High school and college athletes looking to showcase their skills
- **Coaches** - College and professional coaches seeking talent
- **Schools** - Educational institutions with athletic programs

### Core Features

#### User Types & Authentication
- **Athletes**: Can create profiles, upload videos, track stats, and connect with coaches
- **Coaches**: Can browse athletes, filter by criteria, and manage recruitment
- **Schools**: Can showcase their programs and connect with potential athletes

#### Key Functionality
1. **Profile Management**
   - Athlete profiles with stats, videos, and achievements
   - Coach profiles with school affiliations
   - School profiles with program details

2. **Discovery & Filtering**
   - Advanced filtering by sport, location, stats, graduation year
   - Search functionality across all user types
   - Recommendation algorithms

3. **Communication**
   - Direct messaging between users
   - Event announcements and updates
   - Notification system

4. **Content Management**
   - Video upload and playback
   - Photo galleries
   - Document sharing (transcripts, references)

### Technical Architecture

#### Frontend (SwiftUI)
- **Platform**: iOS (primary), with potential macOS support
- **Framework**: SwiftUI with UIKit integration
- **State Management**: @StateObject, @ObservedObject, @State
- **Navigation**: TabView with nested navigation

#### Data Models
```swift
// Core entities
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
    let stars: Int // Recruiting stars
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

#### UI Components
- **OnboardingView**: User type selection and initial setup
- **MainTabView**: Primary navigation with tabs for different sections
- **PlayersListView**: Browse and filter athletes
- **CoachesListView**: Browse coaches and schools
- **SchoolsListView**: Browse educational institutions
- **FilterView**: Advanced filtering and search
- **Profile Views**: Detailed user profiles with stats and content

### Cursor Management System

The app includes a custom cursor management system for enhanced user interaction:

#### Features
- **Touch Feedback**: Visual feedback for interactive elements
- **Hover Effects**: Cursor changes on hover (iPad with trackpad)
- **Contextual Indicators**: Different cursor styles for different actions
- **Accessibility**: Proper accessibility labels and hints

#### Usage Examples
```swift
// Clickable elements with visual feedback
Button("Connect") { }
    .clickableWithFeedback()

// Text input areas
TextField("Search", text: $searchText)
    .textInput()

// Interactive elements
Rectangle()
    .interactive(.selection)

// Hover effects
Button("Profile") { }
    .clickable()
```

### Design System

#### Color Palette
- **Primary**: Blue (#007AFF)
- **Secondary**: Gray (#8E8E93)
- **Success**: Green (#34C759)
- **Warning**: Orange (#FF9500)
- **Error**: Red (#FF3B30)

#### Typography
- **Headings**: SF Pro Display
- **Body**: SF Pro Text
- **Monospace**: SF Mono

#### Spacing
- **Small**: 8pt
- **Medium**: 16pt
- **Large**: 24pt
- **Extra Large**: 32pt

### User Experience Guidelines

#### Navigation
- **Tab-based**: Primary navigation through tabs
- **Hierarchical**: Nested navigation for detailed views
- **Modal**: Overlay presentations for focused tasks

#### Interaction Patterns
- **Tap to Select**: Standard selection behavior
- **Long Press**: Context menus and additional options
- **Swipe**: Dismissal and quick actions
- **Pull to Refresh**: Data updates

#### Accessibility
- **VoiceOver**: Complete screen reader support
- **Dynamic Type**: Scalable text sizes
- **High Contrast**: Support for accessibility settings
- **Reduced Motion**: Respect user preferences

### Performance Considerations

#### Image Loading
- **Lazy Loading**: Images load as needed
- **Caching**: Local image cache for performance
- **Compression**: Optimized image sizes

#### Data Management
- **Pagination**: Large lists load incrementally
- **Caching**: Local data cache with refresh
- **Background Updates**: Data sync in background

### Security & Privacy

#### Data Protection
- **Encryption**: All data encrypted in transit and at rest
- **Authentication**: Secure user authentication
- **Authorization**: Role-based access control

#### Privacy Compliance
- **GDPR**: European privacy compliance
- **COPPA**: Children's privacy protection
- **Data Minimization**: Only collect necessary data

### Testing Strategy

#### Unit Tests
- **Model Logic**: Data validation and business rules
- **View Models**: State management and data flow
- **Utilities**: Helper functions and extensions

#### Integration Tests
- **API Integration**: Network requests and responses
- **Database Operations**: Data persistence and retrieval
- **User Flows**: End-to-end user journeys

#### UI Tests
- **Accessibility**: Screen reader and accessibility features
- **Responsive Design**: Different screen sizes and orientations
- **Performance**: Load times and memory usage

### Deployment & Distribution

#### App Store
- **iOS App Store**: Primary distribution channel
- **TestFlight**: Beta testing and feedback
- **App Review**: Apple's review process compliance

#### Analytics & Monitoring
- **Crash Reporting**: Error tracking and resolution
- **User Analytics**: Usage patterns and engagement
- **Performance Monitoring**: App performance metrics

### Future Enhancements

#### Planned Features
- **Video Streaming**: Live streaming capabilities
- **AI Recommendations**: Machine learning for matches
- **Social Features**: Comments, likes, and sharing
- **Calendar Integration**: Event scheduling and reminders

#### Technical Improvements
- **Offline Support**: Core functionality without internet
- **Push Notifications**: Real-time updates and alerts
- **Deep Linking**: Direct navigation to specific content
- **Widgets**: Home screen widgets for quick access

---

## Development Setup

### Prerequisites
- Xcode 16.4 or later
- iOS 18.5+ deployment target
- Swift 6.0

### Installation
1. Clone the repository
2. Open `Scoutable.xcodeproj` in Xcode
3. Select your development team
4. Build and run on simulator or device

### Project Structure
```
Scoutable/
├── ScoutableApp.swift          # App entry point
├── ContentView.swift           # Main router
├── Models/
│   └── Models.swift            # Data models
├── Views/
│   ├── OnboardingView.swift    # User onboarding
│   ├── MainTabView.swift       # Primary navigation
│   ├── PlayersListView.swift   # Athlete browsing
│   ├── CoachesListView.swift   # Coach browsing
│   ├── SchoolsListView.swift   # School browsing
│   └── FilterView.swift        # Search and filtering
├── Helper/
│   ├── CursorManager.swift     # Cursor management
│   └── OnboardingButton.swift  # Custom button component
└── Assets.xcassets/            # Images and resources
```

### Contributing
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

### License
[Add your license information here] 