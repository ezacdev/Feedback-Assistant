# Feedback Assistant

**Feedback Assistant** is a pet project built to demonstrate a production-oriented approach to Apple-platform development. It is an issues/feedback/task management app with a strong focus on **clean architecture**, **modern SwiftUI**, and deep integration with **native system frameworks**.

---

## ✨ Key Features

- Create, edit, delete, and manage **Issues**
- **Tagging** and relationships between entities
- **Filtering** and grouping (e.g., by status, tag, priority, etc.)
- **Local notifications** with custom reminder time per issue
- **Spotlight search** integration (search issues from iOS system search)
- **Widgets** (WidgetKit) displaying up-to-date content
- **In-App Purchases** (StoreKit 2)
- Multi-platform support: **iOS / macOS / watchOS**
- System-friendly UI/UX: state-based UI, context menus, platform adaptations

---

## 🧠 Architecture & Engineering Approach

The app follows a **MVVM-inspired** approach with a centralized **DataController** acting as a data orchestration layer and single source of truth.

### Core principles
- Clear separation of concerns between UI and business logic
- Centralized persistence and domain operations in `DataController`
- SwiftUI views remain lightweight and declarative
- State-driven UI updates via `ObservableObject` and SwiftUI bindings
- Platform-specific code is isolated using conditional compilation

---

## 🗂 Persistence Layer

### Core Data
- Core persistence powered by **Core Data**
- A dedicated `DataController` encapsulates:
  - Core Data stack configuration
  - Save operations and conflict-safe updates
  - Background work patterns where applicable
  - Data lifecycle management (cleanup / optimization)

### Model safety & UI readiness
- Computed wrappers are used for safe access to optional fields
- Entity extensions encapsulate formatting and display-ready values

---

## 🔍 Spotlight Integration

The app integrates with iOS Spotlight to enable system-wide search:

- Uses **Core Spotlight**
- Indexing via `NSCoreDataCoreSpotlightDelegate`
- Converts Spotlight identifiers back to Core Data objects for navigation
- Supports searching issues directly from the iOS home screen search

---

## 🔔 Local Notifications

- Uses `UserNotifications` (`UNUserNotificationCenter`)
- Custom `NotificationDelegate`
- Per-issue reminder settings:
  - enable/disable reminders
  - schedule at a user-selected time
- Handles permissions and edge cases safely

---

## 🧩 In-App Purchases (StoreKit 2)

- Modern **StoreKit 2** implementation using `async/await`
- Product loading with caching to reduce redundant requests
- Transaction stream handling and robust purchase state support:
  - success
  - pending
  - cancelled
  - error handling
- UI load states (loading / loaded / error) for clean user feedback

---

## 📦 Widgets (WidgetKit)

- Widget extension using **WidgetKit**
- `TimelineProvider` implementation:
  - placeholder
  - snapshot
  - timeline
- Displays relevant up-to-date app content
- Uses its own Core Data access pattern suitable for extensions

---

## ⌚ watchOS Support

- Uses conditional compilation to isolate unsupported APIs:
  - `#if os(watchOS)`
  - `#if canImport(...)`
- Minimal UI and functionality adapted to watchOS constraints
- Avoids frameworks not available on watchOS (e.g., Spotlight / certain notification behaviors)

---

## 🖥 macOS Support

- SwiftUI UI adaptation for desktop usage patterns
- `NavigationSplitView` for a multi-column experience
- Platform-specific optimizations and compatibility fixes
- Improved UX for keyboard/mouse and windowed environment

---

## ✅ Testing (Unit + UI)

Testing is a first-class part of this project to reflect real-world development practices.

### Unit Tests (XCTest)
- Unit tests cover core business logic and data-layer behaviors where applicable
- Focus on deterministic logic: filtering, sorting, model transformations, controller logic

### UI Tests (XCUITest)
- UI tests validate critical user flows:
  - creating/editing issues
  - navigation between key screens
  - verifying core UI elements and states
- Ensures stability across refactors and platform adaptations

---

## 🧠 Swift / SwiftUI Concepts Demonstrated

- State management:
  - `@State`, `@StateObject`, `@ObservedObject`
  - `@Environment`, `@EnvironmentObject`
- Concurrency:
  - `async/await`, `Task`
  - `@MainActor` for UI-safe operations
- Language features:
  - property wrappers
  - computed properties
  - conditional compilation (`#if os(...)`, `#if canImport(...)`)
  - `@dynamicMemberLookup`

---

## 🧰 Tech Stack

### Languages & Frameworks
- **Swift**
- **SwiftUI**
- **Core Data**
- **UserNotifications**
- **Core Spotlight**
- **WidgetKit**
- **StoreKit 2**
- **XCTest** (Unit tests)
- **XCUITest** (UI tests)
- **Combine**

### Platforms
- **iOS**
- **macOS**
- **watchOS**

---

## 🎯 Goals of the Project

- Demonstrate production-minded iOS engineering practices
- Show competence with Apple ecosystem APIs (persistence, widgets, Spotlight, purchases, notifications)
- Validate quality through unit and UI testing
- Serve as a portfolio project for technical interviews

