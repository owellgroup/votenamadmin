# Votenam Admin Panel

A comprehensive Flutter web application for managing the Namibia Voting System. This admin panel provides a complete interface for managing users, candidates, vote categories, regions, voters cards, and viewing voting results.

## 📋 Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Tech Stack](#tech-stack)
- [Prerequisites](#prerequisites)
- [Local Development](#local-development)
- [Docker Deployment](#docker-deployment)
- [API Documentation](#api-documentation)
- [Project Structure](#project-structure)
- [Environment Configuration](#environment-configuration)
- [Troubleshooting](#troubleshooting)

## 🎯 Overview

The Votenam Admin Panel is a Flutter-based web application that serves as the administrative interface for the Namibia Voting System. It connects to a Spring Boot backend API and provides comprehensive management capabilities for all aspects of the voting system.

### System Architecture

```
┌─────────────────────┐
│  Flutter Web App    │
│  (Admin Panel)      │
└──────────┬──────────┘
           │ HTTPS
           │
┌──────────▼──────────┐
│  Spring Boot API    │
│  (Backend)          │
└──────────┬──────────┘
           │
┌──────────▼──────────┐
│  PostgreSQL DB      │
└─────────────────────┘
```

## ✨ Features

### 🔐 Authentication
- Secure login system
- Session management with SharedPreferences
- Automatic logout on session expiry

### 👥 User Management
- View all registered users
- Create new admin users
- Update user information
- Delete users

### 🗳️ Vote Categories Management
- Create vote categories (e.g., Presidential, Local Authority)
- Update category names
- Delete categories
- View all categories

### 📍 Regions Management
- Manage voting regions
- Create, update, and delete regions
- View all regions

### 👤 Candidates Management
- **Comprehensive candidate management:**
  - Add candidates with photos and party logos
  - Update candidate information
  - Upload candidate photos (required)
  - Upload party logos (required)
  - Assign candidates to vote categories
  - Search and filter candidates
  - View candidates in table or list format

### 🆔 Voters Cards Management
- Manage voter ID cards
- Create, update, and delete voter cards
- View all voter cards

### 📊 Dashboard & Analytics
- Real-time voting statistics
- Candidate performance metrics
- Vote counts by category
- Vote counts by region
- Interactive charts and graphs
- Total votes summary

### 📝 Votes Management
- View all submitted votes
- Filter votes by candidate
- Filter votes by category
- View detailed voter information

## 🛠️ Tech Stack

- **Framework:** Flutter 3.0+
- **Language:** Dart 3.0+
- **State Management:** Provider
- **HTTP Client:** http package
- **Image Handling:** cached_network_image, image_picker
- **Charts:** fl_chart
- **Storage:** SharedPreferences
- **Web Server:** Nginx (for production)
- **Containerization:** Docker

### Key Dependencies

```yaml
dependencies:
  flutter: sdk: flutter
  http: ^1.1.0
  provider: ^6.1.1
  cached_network_image: ^3.3.0
  image_picker: ^1.0.5
  file_picker: ^5.5.0
  shared_preferences: ^2.2.2
  fl_chart: ^0.65.0
  intl: ^0.18.1
```

## 📦 Prerequisites

Before you begin, ensure you have the following installed:

- **Flutter SDK** (3.0.0 or higher)
- **Dart SDK** (3.0.0 or higher)
- **Docker** (for containerized deployment)
- **Git**
- **Node.js** (optional, for web development tools)

### Verify Installation

```bash
flutter --version
dart --version
docker --version
```

## 🚀 Local Development

### 1. Clone the Repository

```bash
git clone <repository-url>
cd votenamadmin_flutter
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Configure API Endpoint

The API base URL is configured in `lib/services/admin_api_service.dart`:

```dart
static const String baseUrl = 'https://vote.owellgraphics.com';
```

For local development, you can change it to:

```dart
static const String baseUrl = 'http://localhost:8080';
// Or use your local IP
static const String baseUrl = 'http://192.168.1.100:8080';
```

### 4. Run the Application

#### Web Development

```bash
flutter run -d chrome
```

#### Web Release Build

```bash
flutter build web --release --web-renderer canvaskit
```

The built files will be in the `build/web` directory.

### 5. Serve Locally (Optional)

After building, you can serve the files using any static file server:

```bash
# Using Python
cd build/web
python -m http.server 8000

# Using Node.js (http-server)
npx http-server build/web -p 8000
```

## 🐳 Docker Deployment

### Building the Docker Image

```bash
docker build -t votenamadmin:latest .
```

### Running the Container

```bash
docker run -d -p 5151:5151 --name votenamadmin votenamadmin:latest
```

### Docker Compose (Optional)

Create a `docker-compose.yml`:

```yaml
version: '3.8'

services:
  votenamadmin:
    build: .
    ports:
      - "5151:5151"
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "wget", "--quiet", "--tries=1", "--spider", "http://localhost:5151/health"]
      interval: 30s
      timeout: 3s
      retries: 3
      start_period: 5s
```

Run with:

```bash
docker-compose up -d
```

### Deployment with Dokploy

1. **Push your code to a Git repository** (GitHub, GitLab, etc.)

2. **In Dokploy:**
   - Create a new application
   - Connect your Git repository
   - Set build context to root directory
   - Dockerfile path: `Dockerfile`
   - Port: `5151`
   - Dokploy will automatically:
     - Build the Docker image
     - Handle reverse proxy
     - Configure Let's Encrypt SSL certificates
     - Set up health checks

3. **Deploy:**
   - Click "Deploy" and Dokploy will handle the rest

## 📡 API Documentation

### Base URL

```
Production: https://vote.owellgraphics.com
Development: http://localhost:8080
```

### Authentication

#### Login
```http
POST /api/admin/login
Content-Type: application/json

{
  "email": "admin@example.com",
  "password": "password123"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Login successful",
  "user": {
    "id": 1,
    "email": "admin@example.com",
    "role": "ADMIN"
  }
}
```

### Users Management

#### Get All Users
```http
GET /api/admin/users
```

#### Create User
```http
POST /api/admin/users
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "password123",
  "role": "ADMIN"
}
```

#### Update User
```http
PUT /api/admin/users/{id}
Content-Type: application/json

{
  "email": "updated@example.com",
  "role": "ADMIN"
}
```

#### Delete User
```http
DELETE /api/admin/users/{id}
```

### Vote Categories Management

#### Get All Vote Categories
```http
GET /api/admin/vote-categories
```

**Response:**
```json
{
  "success": true,
  "voteCategories": [
    {
      "id": 1,
      "categoryName": "Presidential"
    },
    {
      "id": 2,
      "categoryName": "Local Authority"
    }
  ]
}
```

#### Create Vote Category
```http
POST /api/admin/vote-categories
Content-Type: application/json

{
  "categoryName": "Presidential"
}
```

#### Update Vote Category
```http
PUT /api/admin/vote-categories/{id}
Content-Type: application/json

{
  "categoryName": "Updated Category Name"
}
```

#### Delete Vote Category
```http
DELETE /api/admin/vote-categories/{id}
```

### Regions Management

#### Get All Regions
```http
GET /api/admin/regions
```

**Response:**
```json
{
  "success": true,
  "regions": [
    {
      "id": 1,
      "regionName": "Khomas"
    },
    {
      "id": 2,
      "regionName": "Erongo"
    }
  ]
}
```

#### Create Region
```http
POST /api/admin/regions
Content-Type: application/json

{
  "regionName": "Khomas"
}
```

#### Update Region
```http
PUT /api/admin/regions/{id}
Content-Type: application/json

{
  "regionName": "Updated Region Name"
}
```

#### Delete Region
```http
DELETE /api/admin/regions/{id}
```

### Candidates Management

#### Get All Candidates
```http
GET /api/admin/candidates
```

**Response:**
```json
{
  "success": true,
  "candidates": [
    {
      "id": 1,
      "fullName": "John Doe",
      "partyName": "Party A",
      "position": "President",
      "photoUrl": "https://vote.owellgraphics.com/api/photos/view/image.jpg",
      "partyLogoUrl": "https://vote.owellgraphics.com/api/logos/view/logo.jpg",
      "voteCategory": {
        "id": 1,
        "categoryName": "Presidential"
      }
    }
  ]
}
```

#### Create Candidate
```http
POST /api/admin/candidates
Content-Type: multipart/form-data

Fields:
- fullName: "John Doe"
- partyName: "Party A"
- position: "President"
- voteCategoryId: 1
- photo: [file]
- partyLogo: [file]
```

**Response:**
```json
{
  "success": true,
  "candidate": {
    "id": 1,
    "fullName": "John Doe",
    "partyName": "Party A",
    "position": "President",
    "photoUrl": "https://vote.owellgraphics.com/api/photos/view/image.jpg",
    "partyLogoUrl": "https://vote.owellgraphics.com/api/logos/view/logo.jpg",
    "voteCategory": {
      "id": 1,
      "categoryName": "Presidential"
    }
  }
}
```

#### Update Candidate
```http
PUT /api/admin/candidates/{id}
Content-Type: multipart/form-data

Fields:
- fullName: "Updated Name" (required)
- partyName: "Updated Party" (required)
- position: "Updated Position" (required)
- voteCategoryId: 1 (required)
- photo: [file] (optional)
- partyLogo: [file] (optional)
```

#### Delete Candidate
```http
DELETE /api/admin/candidates/{id}
```

### Voters Cards Management

#### Get All Voters Cards
```http
GET /api/admin/voters-cards
```

#### Create Voters Card
```http
POST /api/admin/voters-cards
Content-Type: application/json

{
  "votersIdNumber": "123456789",
  "fullName": "Jane Doe",
  "dateOfBirth": "1990-01-15",
  "region": {
    "id": 1
  }
}
```

#### Update Voters Card
```http
PUT /api/admin/voters-cards/{id}
Content-Type: application/json
```

#### Delete Voters Card
```http
DELETE /api/admin/voters-cards/{id}
```

### Votes Management

#### Get All Votes
```http
GET /api/admin/votes
```

#### Get Votes by Candidate
```http
GET /api/admin/votes/candidate/{candidateId}
```

#### Get Votes by Category
```http
GET /api/admin/votes/category/{categoryId}
```

### File Viewing Endpoints

#### View Candidate Photo
```http
GET /api/photos/view/{fileName}
```

#### View Party Logo
```http
GET /api/logos/view/{fileName}
```

#### Download Candidate Photo
```http
GET /api/photos/download/{fileName}
```

#### Download Party Logo
```http
GET /api/logos/download/{fileName}
```

## 📁 Project Structure

```
votenamadmin_flutter/
├── lib/
│   ├── main.dart                 # Application entry point
│   ├── models/                  # Data models
│   │   ├── candidate.dart
│   │   ├── region.dart
│   │   ├── user.dart
│   │   ├── vote_category.dart
│   │   ├── voters_card.dart
│   │   └── voters_details.dart
│   ├── screens/                # UI screens
│   │   ├── login_screen.dart
│   │   ├── main_layout_screen.dart
│   │   ├── dashboard_screen.dart
│   │   ├── candidates_management_screen.dart
│   │   ├── users_management_screen.dart
│   │   ├── vote_category_management_screen.dart
│   │   ├── regions_management_screen.dart
│   │   ├── voters_card_management_screen.dart
│   │   ├── voters_details_view_screen.dart
│   │   └── candidate_detail_dashboard_screen.dart
│   ├── services/                # API services
│   │   └── admin_api_service.dart
│   ├── theme/                   # App theming
│   │   └── app_theme.dart
│   └── widgets/                 # Reusable widgets
│       ├── votenam_logo.dart
│       ├── modern_card.dart
│       └── stat_card.dart
├── assets/                       # Static assets
│   └── logovotenam.png
├── web/                          # Web-specific files
│   ├── index.html
│   ├── manifest.json
│   └── icons/
├── Dockerfile                    # Docker configuration
├── nginx.conf                    # Nginx configuration
├── .dockerignore                 # Docker ignore file
└── pubspec.yaml                  # Dependencies
```

## ⚙️ Environment Configuration

### API Configuration

The API base URL is hardcoded in `lib/services/admin_api_service.dart`. To change it:

1. **For Production:**
   ```dart
   static const String baseUrl = 'https://vote.owellgraphics.com';
   ```

2. **For Development:**
   ```dart
   static const String baseUrl = 'http://localhost:8080';
   ```

### Color Theme

The primary color is configured in `lib/theme/app_theme.dart`:

```dart
static const Color primaryBlue = Color(0xFF41479B);
```

This color is used throughout the application for consistency.

## 🔧 Troubleshooting

### Common Issues

#### 1. Build Errors

**Issue:** `flutter pub get` fails

**Solution:**
```bash
flutter clean
flutter pub get
flutter pub upgrade
```

#### 2. Web Build Fails

**Issue:** `flutter build web` fails

**Solution:**
```bash
flutter clean
flutter pub get
flutter build web --release --web-renderer canvaskit
```

#### 3. Images Not Loading

**Issue:** Candidate photos or party logos not displaying

**Solution:**
- Check API base URL configuration
- Verify image URLs are correct
- Ensure backend file serving endpoints are accessible
- Check CORS settings on backend

#### 4. API Connection Errors

**Issue:** Cannot connect to API

**Solution:**
- Verify API base URL is correct
- Check backend server is running
- Verify network connectivity
- Check CORS configuration on backend

#### 5. Docker Build Fails

**Issue:** Docker build fails with Flutter errors

**Solution:**
```bash
# Ensure Dockerfile uses correct Flutter version
# Check Flutter SDK version compatibility
flutter doctor
```

#### 6. Port Already in Use

**Issue:** Port 5151 already in use

**Solution:**
```bash
# Change port in Dockerfile and nginx.conf
# Or stop the process using port 5151
lsof -i :5151  # macOS/Linux
netstat -ano | findstr :5151  # Windows
```

### Debug Mode

To run in debug mode with verbose logging:

```bash
flutter run -d chrome --verbose
```

### Check Flutter Installation

```bash
flutter doctor
```

This will show any issues with your Flutter installation.

## 📝 Notes

- The application uses **Material Design** components
- Images are cached using `cached_network_image` for better performance
- The app supports both web and mobile platforms (though optimized for web)
- File uploads work differently on web vs mobile (handled automatically)
- All API calls include proper error handling

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is proprietary software for the Namibia Voting System.

## 📞 Support

For support and questions, please contact the development team.

---

**Version:** 1.0.0+1  
**Last Updated:** 2024
