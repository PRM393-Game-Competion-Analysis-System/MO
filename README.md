# 🎮 PRM393 - Game Competition Analysis System (Mobile App)

Chào mừng bạn đến với kho lưu trữ mã nguồn ứng dụng di động thuộc hệ thống **Game Competition Analysis System (GCAS)**. Dự án được phát triển bằng **Flutter**, kế thừa và chuẩn hóa từ kiến trúc hệ thống Web của nhóm sang mô hình di động chuyên nghiệp.

---

## 🚀 Công nghệ sử dụng
- **Framework:** Flutter (Dart)
- **HTTP Client:** [Dio](https://pub.dev/packages/dio) (Hỗ trợ JWT Interceptors, xử lý gọi API tương tự Axios trên Web)
- **Kiến trúc:** Feature-First (Phát triển theo tính năng)

---

## 📂 Cấu trúc thư mục (`lib/`)

Mã nguồn được tổ chức theo cấu trúc **Feature-First** nhằm tối ưu hóa việc làm việc nhóm, tránh xung đột code (conflict) khi merge.

```text
lib/
├── core/                             # Tầng dùng chung (Shared layer - tương đương lib/ và hooks/ trên Web)
│   ├── network/
│   │   └── api_client.dart           # Cấu hình Dio, Interceptor đính kèm JWT (Thay cho api.ts)
│   ├── services/
│   │   ├── ai_service.dart           # Xử lý/chuẩn hóa dữ liệu từ AI (Thay cho ai.ts)
│   │   └── game_service.dart         # Fetch & filter danh sách game (Thay cho games.ts)
│   ├── constants/
│   │   └── analysis_meta.dart        # Lưu trữ các hằng số, metadata cấu hình (Thay cho analysisMeta.ts)
│   └── widgets/                      # Các UI components dùng chung toàn app (Thay cho components/)
│       ├── custom_navbar.dart        # Thanh điều hướng dưới màn hình (Bottom Navigation)
│       └── common_button.dart        # Nút bấm dùng chung
│
├── features/                         # Tầng tính năng (Feature layer - thay thế hoàn toàn cho pages/ trên Web)
│   ├── auth/                         # Tính năng Đăng nhập / Đăng ký (pages/Authen)
│   │   ├── presentation/             # Giao diện (Màn hình Login, Register)
│   │   └── logic/                    # Xử lý logic (Thay cho React hooks của Auth)
│   │
│   ├── history/                      # Quản lý lịch sử phân tích & CRUD (pages/History)
│   │   ├── presentation/
│   │   └── logic/
│   │
│   ├── admin/                        # Dashboard Admin & Quản lý User (pages/admin)
│   │   ├── presentation/
│   │   └── logic/
│   │
│   ├── analyze/                      # Upload ảnh chụp màn hình & Phân tích (pages/Analyze.tsx)
│   │   ├── presentation/
│   │   └── logic/
│   │
│   ├── game_management/              # Quản lý danh sách Game, Server và Players
│   │   ├── presentation/
│   │   │   ├── game_selection_screen.dart
│   │   │   ├── server_selection_screen.dart
│   │   │   └── players_screen.dart
│   │   └── logic/
│   │
│   ├── heatmap/                      # Biểu đồ mật độ hoạt động (pages/ActivityHeatmap.tsx)
│   │   ├── presentation/
│   │   └── logic/
│   │
│   └── profile/                      # Thông tin cá nhân người dùng (pages/Profile.tsx)
│       ├── presentation/
│       └── logic/
│
└── main.dart                         # Điểm khởi chạy ứng dụng (Cấu hình Router, Theme ban đầu)