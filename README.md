# 🍽️ Restaurant POS System

A full-stack, role-based **Point of Sale** application built with **Flutter** (frontend) and **Serverpod** (backend). Designed for restaurants that need a unified platform for waiters, kitchen staff, bar staff, administrators, and self-service kiosk customers — all communicating in real time.

---

## 📋 Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Architecture](#architecture)
- [Roles](#roles)
- [Tech Stack](#tech-stack)
- [Project Structure](#project-structure)
- [Getting Started](#getting-started)
- [Backend Setup](#backend-setup)
- [Frontend Setup](#frontend-setup)
- [CI/CD & Releases](#cicd--releases)
- [API Endpoints](#api-endpoints)

---

## Overview

This POS system is a **monorepo** containing:

| Component | Description |
|-----------|-------------|
| `pos_app` | Flutter frontend (Android, Windows, Web) |
| `pos_server` | Serverpod backend (Dart server + PostgreSQL) |

All screens share a single, persistent WebSocket connection to the Serverpod backend. When any user places an order, updates a table, or checks out — every connected screen updates instantly via real-time events.

---

## Features

### 🧑‍🍳 Operations
- **Live order management** — place, update, split, and merge orders
- **Table management** — view floor plan, assign orders to tables, track occupancy and guest count
- **Order status pipeline** — `Pending → In Progress → Ready → Served → Paid → Completed`
- **Scheduled orders** — support for future/timed orders
- **Bill splitting** — split a single table order into multiple bills with individual calculations

### 💳 Payments & Checkout
- **Waiter checkout** — apply tax, service charge, and tip; process full or split payment
- **Multiple payment methods** — Cash, Card, or Split Payment
- **Receipt printing** — ESC/POS thermal printer and PDF bill generation
- **Order history** — view past orders and completed checkouts

### 🖥️ Kitchen & Bar Display
- **Station-filtered views** — Kitchen sees food items only; Bar sees drinks only
- **One-tap status update** — mark items as In Progress or Ready directly from the display
- **Auto-updating** — new orders appear instantly via WebSocket events

### 🏪 Self-Service Kiosk
- **Touchscreen-first UI** — animated splash screen, large product cards
- **Category browsing** — filter by Takeaway/Both categories in real time
- **Cart & checkout** — add, adjust quantity, and place takeaway orders autonomously

### ⚙️ Admin
- **Menu management** — add/edit/delete categories, subcategories, products, and product extras
- **User management** — create and manage staff accounts with role (Admin / Waiter) and PIN
- **Settings** — configure tax rate, service charge, currency symbol, and order delay threshold
- **Reports** — sales analytics with charts (daily revenue, top products, order type breakdown)
- **Printer management** — configure ESC/POS thermal printers
- **Checkout history** — browse all closed/completed orders
- **Data tools** — purge old data, clear transactional data, backup/restore database

### 🔄 Real-Time Sync
- **Global WebSocket stream** — all clients share one persistent Serverpod event stream
- **Event types**: `order_created`, `order_updated`, `table_updated`, `product_updated`, `checkout_completed`
- **Auto-reconnect** — the app retries the event subscription on error with a 5-second cooldown

---

## Architecture

```
┌─────────────────────────────────────────────────────┐
│                   pos_app (Flutter)                  │
│                                                      │
│  LoginScreen ──► Admin ──────────────────────────┐  │
│               ├─► Waiter (Tables/Orders/Checkout) │  │
│               ├─► Kitchen Display                 │  │
│               ├─► Bar Display                     │  │
│               └─► Kiosk (Self-service Takeaway)   │  │
│                                                   │  │
│  Global WebSocket (posEventStreamController) ◄────┘  │
└──────────────────────┬──────────────────────────────┘
                       │ HTTP + WebSocket (port 8080)
┌──────────────────────▼──────────────────────────────┐
│               pos_server (Serverpod)                 │
│                                                      │
│  Endpoints: orders, tables, checkout, products,      │
│             categories, users, settings, reports,    │
│             reservations, events                     │
│                                                      │
│  EventService ──► broadcasts PosEvent to all clients │
└──────────────────────┬──────────────────────────────┘
                       │
              ┌────────▼────────┐
              │   PostgreSQL DB  │
              └─────────────────┘
```

---

## Roles

| Role | Access | Authentication |
|------|--------|---------------|
| **Admin** | Full system: menu, users, reports, settings, checkout history | Username + PIN |
| **Waiter** | Tables, new orders, checkout, bills, reservations, order history | Username + PIN |
| **Kitchen** | Kitchen display (food items only), order status updates | No auth |
| **Bar** | Bar display (drinks only), order status updates | No auth |
| **Kiosk** | Self-service takeaway ordering | No auth |

Default credentials:
- Admin: `admin` / `1111`
- Waiter: `waiter` / `2222`

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Frontend | Flutter 3.x (Dart) |
| Backend | Serverpod 3.4 (Dart) |
| Database | PostgreSQL |
| State / Events | Serverpod Streaming WebSocket |
| Charts | fl_chart |
| Printing | flutter_pos_printer_platform_image_3, printing + pdf |
| CI/CD | GitHub Actions |
| Releases | Android APK + Windows ZIP via `softprops/action-gh-release` |

---

## Project Structure

```
pos3/
├── pos_app/                        # Flutter frontend
│   ├── lib/
│   │   ├── main.dart               # App entry, Serverpod client init, event stream
│   │   ├── login_screen.dart       # Role selector + PIN login
│   │   ├── admin/                  # Admin dashboard and sub-views
│   │   │   ├── admin_dashboard_screen.dart
│   │   │   ├── menu_management_view.dart
│   │   │   ├── user_management_view.dart
│   │   │   ├── reports_view.dart
│   │   │   ├── settings_view.dart
│   │   │   ├── printer_management_view.dart
│   │   │   └── checkout_history_view.dart
│   │   ├── waiter/                 # Waiter workflow
│   │   │   ├── waiter_shell.dart   # Bottom nav shell
│   │   │   ├── tables_view.dart    # Table floor plan
│   │   │   ├── new_order_view.dart # Order creation
│   │   │   ├── checkout_view.dart  # Payment & checkout
│   │   │   ├── bills_view.dart     # Bill breakdown
│   │   │   ├── reservations_view.dart
│   │   │   ├── order_history_view.dart
│   │   │   └── printer_view.dart
│   │   ├── kitchen/
│   │   │   └── kitchen_bar_screen.dart  # Kitchen & Bar KDS
│   │   ├── kiosk/
│   │   │   └── kiosk_screen.dart        # Self-service kiosk
│   │   ├── shared/
│   │   │   └── responsive_layout.dart   # Breakpoint helpers
│   │   └── utils/
│   ├── assets/
│   │   └── icon.png
│   └── pubspec.yaml
│
├── pos_server/                     # Serverpod backend
│   ├── pos_server_server/
│   │   └── lib/src/
│   │       ├── endpoints/
│   │       │   ├── orders_endpoint.dart       # CRUD + merge/split/status
│   │       │   ├── tables_endpoint.dart       # Table CRUD + status
│   │       │   ├── checkout_endpoint.dart     # Payment processing
│   │       │   ├── products_endpoint.dart
│   │       │   ├── categories_endpoint.dart
│   │       │   ├── subcategories_endpoint.dart
│   │       │   ├── users_endpoint.dart
│   │       │   ├── settings_endpoint.dart
│   │       │   ├── reports_endpoint.dart
│   │       │   ├── reservations_endpoint.dart
│   │       │   └── events_endpoint.dart       # WebSocket event stream
│   │       └── event_service.dart             # Broadcast helper
│   └── pos_server_client/          # Auto-generated Dart client
│
└── .github/
    └── workflows/
        └── release.yml             # CI: build APK + Windows EXE on tag push
```

---

## Getting Started

### Prerequisites

| Requirement | Version |
|------------|---------|
| Flutter SDK | ≥ 3.10 |
| Dart SDK | ≥ 3.10 |
| Docker + Docker Compose | Latest |
| PostgreSQL | 15+ (via Docker) |

---

## Backend Setup

```bash
# 1. Navigate to the server directory
cd pos_server/pos_server_server

# 2. Start PostgreSQL via Docker (Serverpod default)
docker-compose up -d

# 3. Install dependencies
dart pub get

# 4. Run database migrations
dart run bin/main.dart --apply-migrations

# 5. Start the server
dart run bin/main.dart
```

The server will listen on **port 8080** (HTTP/WebSocket) and **port 8081** (Serverpod Insights dashboard).

> **Note:** The server IP is configurable from the app's login screen at runtime — no rebuild required.

---

## Frontend Setup

```bash
# 1. Install the generated client package dependencies
cd pos_server/pos_server_client
dart pub get

# 2. Navigate to the app
cd ../../pos_app
flutter pub get

# 3. Run on your target platform
flutter run -d windows    # Windows desktop
flutter run -d android    # Android device/emulator
flutter run -d chrome     # Web browser
```

### Connecting to the Server

On the login screen, tap the **"Server Setup"** button (bottom-right) or the IP chip (top-right) to enter the backend IP address. The app saves this with `shared_preferences` and connects immediately without restarting.

- **Local**: `localhost` or `127.0.0.1`  
- **Local network**: `192.168.x.x` (your server machine's LAN IP)

---

## CI/CD & Releases

Releases are fully automated via **GitHub Actions** (`.github/workflows/release.yml`).

### Trigger

Push a version tag to the repository:

```bash
git tag v2.3.0
git push origin v2.3.0
```

### Pipeline

```
Push tag v*
    │
    ├──► Job: build-apk (ubuntu-latest)
    │        └─ flutter build apk --release
    │
    └──► Job: build-windows (windows-latest)
             └─ flutter build windows --release
                  └─ Compress-Archive → pos_app-windows.zip
    │
    └──► Job: release (after both above succeed)
             └─ softprops/action-gh-release
                  ├─ app-release.apk
                  └─ pos_app-windows.zip
```

The release is created automatically with auto-generated release notes from commit history.

---

## API Endpoints

All endpoints are served by Serverpod and consumed by the auto-generated `pos_server_client` package.

| Endpoint | Key Methods |
|----------|------------|
| `orders` | `getAll`, `getById`, `create`, `updateStatus`, `update`, `merge`, `split` |
| `tables` | `getAll`, `create`, `update`, `delete`, `updateStatus` |
| `checkout` | `processPayment`, `getCheckouts`, `getById` |
| `products` | `getAll`, `create`, `update`, `delete` |
| `categories` | `getAll`, `create`, `update`, `delete` |
| `subcategories` | `getAll`, `create`, `update`, `delete` |
| `users` | `login`, `getAll`, `create`, `update`, `delete` |
| `settings` | `getSettings`, `updateSettings`, `purgeOldData`, `clearAllTransactionalData` |
| `reports` | `getDailySales`, `getTopProducts`, `getOrderTypeBreakdown` |
| `reservations` | `getAll`, `create`, `update`, `delete` |
| `events` | `subscribe` (WebSocket stream of `PosEvent`) |

### Order Status Flow

```
Scheduled ──► Pending ──► In Progress ──► Ready ──► Served
                                                       │
                                              ◄── Paid ◄─── Checkout
                                                       │
                                                   Completed
```

- If a customer pays **before** the kitchen marks the order ready, the next kitchen status update automatically completes the order.
- Tables are automatically freed when all orders for that table reach `Completed` or `Cancelled`.

---

## License

Private repository — all rights reserved.
