
# MO - Game Analytics & Admin Management Platform

A high-performance Flutter mobile application designed for tracking game statistics, executing AI-driven screenshot OCR analysis, and providing full administrative dashboards for community moderators and system admins.

## Key Features

* **Global MainLayout Base**: Single-shell architecture utilizing `IndexedStack` to preserve state/cache seamlessly across navigation tabs.
* **AI Image Pipeline**: Modular upload-to-result user workflow for scanning game screenshots with live progress reporting.
* **Full Administrative CRUD**: Complete membership governance (`User Management`) and dynamic catalog processing (`Game Management`) with device native image picking capabilities.
* **Pure UI Graphics Components**: Dynamic mixed trend charts (Bar + Line) and custom traffic density grids (`Activity Heatmap`) built completely from scratch using `CustomPainter` without heavy third-party plugins.

---

## Architecture & Project Structure

The project follows a scalable **Feature-First (Feature-Driven)** architecture pattern, isolating discrete business logic domains within their respective folders.

```text
lib/
├── features/                      # Business domains & feature modules
│   ├── activity_center/           # Admin-Only Governance Suite
│   │   ├── activity_heatmap_screen.dart # 35-Day traffic matrix grid
│   │   ├── activity_trends_screen.dart  # Analytics mixed canvas charts
│   │   ├── analysis_history_screen.dart # Security & system audit trails
│   │   ├── game_management_screen.dart  # Catalog management
│   │   └── user_management_screen.dart  # Permission & account grids
│   ├── auth/                      # Gatekeeping flow
│   │   ├── login.dart
│   │   ├── register.dart
│   │   └── welcome.dart
│   ├── cloud_sync/                # External server backups
│   │   └── cloud_sync_screen.dart
│   ├── game_management/           # Core User Interactive Engine
│   │   ├── upload_analyze_flow/   # Sub-atomic pipeline UI components
│   │   │   ├── pipeline_card.dart
│   │   │   ├── ranking_list.dart
│   │   │   ├── server_selection_modal.dart
│   │   │   └── visual_state_card.dart
│   │   ├── dashboard_screen.dart  # Main user progression dashboard
│   │   ├── game_selection_screen.dart   # Game catalog selection launcher
│   │   └── upload_and_analyze_screen.dart # Central interactive state manager
│   ├── history/                   # User processing logs
│   │   └── history_screen.dart
│   ├── mock_data/                 # Local simulated datasets
│   ├── player_lookup/             # Global system-wide profile search
│   │   └── player_lookup_screen.dart
│   └── profile/                   # Account management hub
│       ├── activity_center_screen.dart # Admin dispatch control tower
│       ├── admin_profile_screen.dart   # Elevated user view
│       ├── my_profile_screen.dart
│       └── profile_screen.dart         # Standard tier account details
├── widgets/                       # Global shared cross-cutting components
│   ├── app_tab.dart               # Global Tab state definitions (Enum)
│   ├── custom_bottom_nav_bar.dart # Synced base bar shell layout
│   └── main_layout.dart           # Shell architecture supervisor
└── main.dart                      # App bootstrap entry point

```

---

## Tech Stack & Configurations

* **Framework**: Flutter (Channel stable)
* **Language**: Dart
* **Primary Plugins**: `image_picker` (Native local file selection)

> **Important Multi-Drive Build Fix Note**
> If you are working on Windows environments where the Pub Cache and target projects reside on separate roots (e.g., `C:\` and `D:\`), Kotlin Daemon compilation increments might crash. The project is pre-configured to suppress this inside `android/gradle.properties`:
> ```properties
> kotlin.incremental=false
> 
> ```
> 
> 

---

## Getting Started

1. **Get Dependencies**
```bash
flutter pub get

```


2. **Clean Project Caches** (Recommended before initial compilation to avoid old build locks)
```bash
flutter clean
flutter pub get

```


3. **Run Application**
```bash
flutter run

```
