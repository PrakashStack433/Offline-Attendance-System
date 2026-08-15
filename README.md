# Offline Attendance System

A Flutter mobile app for tracking student attendance offline with dynamic QR codes.

## Features

- **100% Offline** — All data stored locally on device via SQLite
- **Dynamic QR Codes** — Each student gets a unique, session-based QR code for anti-proxy
- **Class Management** — Create, edit, and delete classes with sections
- **Student Management** — Add, edit, and remove students with auto-generated QR codes
- **QR Scanner** — Scan student QR codes to mark attendance in real-time
- **Attendance History** — View attendance records by date
- **Export** — Generate CSV, PDF, or TXT reports and share them

## Tech Stack

| Component | Package |
|---|---|
| Framework | Flutter 3.x + Dart |
| Database | Drift ORM + SQLite |
| QR Scanner | mobile_scanner v7.x |
| QR Generator | qr_flutter |
| State Mgmt | Provider |
| Export | csv, pdf, printing, share_plus |
| Navigation | go_router |

## Setup

### Prerequisites

1. Install Flutter SDK: https://docs.flutter.dev/get-started/install
2. Install Android Studio or VS Code with Flutter extension

### Install

```bash
# Clone the repo
git clone <your-repo-url>
cd Offline-Attendance-System

# Install dependencies
flutter pub get

# Generate Drift code
dart run build_runner build --delete-conflicting-outputs

# Run the app
flutter run
```

### iOS Setup

After first run, configure iOS permissions:
- Open `ios/Runner.xcworkspace` in Xcode
- Add camera permission: `NSCameraUsageDescription`
- Add photo library permission: `NSPhotoLibraryUsageDescription`

## Project Structure

```
lib/
├── main.dart                          # App entry point
├── app.dart                           # MaterialApp, router, theme
├── core/
│   ├── database/
│   │   ├── app_database.dart          # Drift database
│   │   ├── tables/                    # Table definitions
│   │   └── daos/                      # Data access objects
│   └── utils/                         # ID generation, date formatting
├── features/
│   ├── classes/                       # Class CRUD screens
│   ├── students/                      # Student CRUD screens
│   ├── attendance/                    # QR scanning & history
│   └── export/                        # CSV/PDF/TXT export
└── shared/widgets/                    # Reusable UI components
```

## How It Works

1. **Create a Class** — Enter class name and section
2. **Add Students** — Each student gets a unique QR code automatically
3. **Take Attendance** — Open scanner, point at student's QR code
4. **View History** — Check attendance records by date
5. **Export Reports** — Generate and share CSV, PDF, or TXT files
