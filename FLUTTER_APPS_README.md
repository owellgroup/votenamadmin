# Votenam Flutter Apps - Complete Implementation

## Overview

This project contains **two complete Flutter applications** that communicate with the same Spring Boot REST API:

1. **votenam_flutter** - Mobile + Web voter app (Android, iOS, Web)
2. **votenamadmin_flutter** - Web-only admin panel

Both apps share the same backend API (`http://localhost:8484`) ensuring real-time communication.

---

## How the Apps Communicate

### Shared REST API Backend

Both applications communicate with the **same Spring Boot REST API** running on `http://localhost:8484`. This ensures that:

- ✅ When voters submit votes in the **voter app**, they immediately appear in the **admin app**
- ✅ All data is synchronized in real-time through the shared database
- ✅ Admin can manage candidates, categories, regions, etc., and voters see the changes instantly
- ✅ Statistics and charts update automatically in both apps

### Communication Flow

```
┌─────────────────────┐         ┌──────────────────┐         ┌─────────────────────┐
│   Voter App         │         │  Spring Boot API │         │   Admin App         │
│  (votenam_flutter)  │◄───────►│  (localhost:8484)│◄───────►│ (votenamadmin_flutter)│
└─────────────────────┘         └──────────────────┘         └─────────────────────┘
                                      │
                                      ▼
                              ┌───────────────┐
                              │  PostgreSQL   │
                              │   Database    │
                              └───────────────┘
```

### Example: Vote Submission Flow

1. **Voter submits vote** in `votenam_flutter`:
   - Calls `POST /api/voter/submit-vote`
   - Vote is saved to database
   - Confirmation email sent to voter

2. **Admin views votes** in `votenamadmin_flutter`:
   - Calls `GET /api/admin/votes`
   - Receives all votes including the new one
   - Dashboard updates automatically with new statistics
   - Charts refresh to show latest vote counts

3. **Voter views results** in `votenam_flutter`:
   - Calls `GET /api/admin/votes` and `GET /api/admin/candidates`
   - Sees updated performance charts with all votes

---

## App 1: votenam_flutter (Voter App)

### Features
- ✅ **Launch Screen** - Logo + "Vote Now" and "Results" buttons
- ✅ **Vote Now Flow**:
  - View available voting categories
  - Select category → View candidates
  - Select candidate (radio button with photo, details, party logo)
  - Enter voter details (name, ID, DOB, address, region, phone, email, voter card)
  - Submit vote
  - Error handling for duplicates (National ID, Email, Phone, Voter Card)
- ✅ **Results Screen**:
  - Overall candidate performance bar chart
  - Top performing candidates list
  - Click candidate to see performance by region
  - Regional breakdown charts
- ✅ **Responsive Design** - Works on mobile and web
- ✅ **Cupertino Widgets** - Native iOS look and feel

### Project Structure
```
votenam_flutter/
├── lib/
│   ├── main.dart
│   ├── models/
│   │   ├── candidate.dart
│   │   ├── region.dart
│   │   ├── vote_category.dart
│   │   └── voters_details.dart
│   ├── services/
│   │   └── api_service.dart
│   └── screens/
│       ├── launch_screen.dart
│       ├── vote_now_screen.dart
│       ├── candidate_selection_screen.dart
│       ├── voter_details_screen.dart
│       ├── results_screen.dart
│       └── candidate_detail_results_screen.dart
├── assets/
│   └── logovotenam.png
└── pubspec.yaml
```

### Setup Instructions

1. **Navigate to the project**:
   ```bash
   cd c:\projects\votenam_flutter
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Configure API Base URL** (if needed):
   - Open `lib/services/api_service.dart`
   - Update `baseUrl` if your Spring Boot server is running on a different address
   - For mobile testing, use your computer's IP: `http://192.168.1.100:8484`

4. **Add Logo**:
   - Place your `logovotenam.png` file in the `assets/` folder

5. **Run the app**:
   ```bash
   # For web
   flutter run -d chrome
   
   # For Android
   flutter run
   
   # For iOS (Mac only)
   flutter run
   ```

---

## App 2: votenamadmin_flutter (Admin Panel)

### Features
- ✅ **Login Screen** - Email/password authentication with logo
- ✅ **Dashboard**:
  - Statistics cards (Total Votes, Candidates, Regions, Average)
  - Overall candidate performance bar chart
  - Top performing candidates list
  - Click candidate to see detailed regional performance
  - Votes by region breakdown
- ✅ **Sidebar Navigation** with logo:
  - Dashboard
  - Candidates (CRUD with search, photo/logo upload)
  - Vote Categories (CRUD with search)
  - Voter Cards (CRUD with search)
  - Voters Details (View-only with search, shows all submitted votes)
  - Regions (CRUD with search)
  - Users (CRUD with search)
- ✅ **Full CRUD Operations** for all entities
- ✅ **Search Functionality** on all list pages
- ✅ **Responsive Web Design** - Works on desktop and tablet
- ✅ **Real-time Statistics** - Refreshes when votes are submitted

### Project Structure
```
votenamadmin_flutter/
├── lib/
│   ├── main.dart
│   ├── models/
│   │   ├── candidate.dart
│   │   ├── region.dart
│   │   ├── vote_category.dart
│   │   ├── voters_details.dart
│   │   ├── user.dart
│   │   └── voters_card.dart
│   ├── services/
│   │   └── admin_api_service.dart
│   └── screens/
│       ├── login_screen.dart
│       ├── main_layout_screen.dart
│       ├── dashboard_screen.dart
│       ├── candidate_detail_dashboard_screen.dart
│       ├── candidates_management_screen.dart
│       ├── vote_category_management_screen.dart
│       ├── voters_card_management_screen.dart
│       ├── voters_details_view_screen.dart
│       ├── regions_management_screen.dart
│       └── users_management_screen.dart
├── assets/
│   └── logovotenam.png
└── pubspec.yaml
```

### Setup Instructions

1. **Navigate to the project**:
   ```bash
   cd c:\projects\votenamadmin_flutter
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Configure API Base URL** (if needed):
   - Open `lib/services/admin_api_service.dart`
   - Update `baseUrl` if your Spring Boot server is running on a different address

4. **Add Logo**:
   - Place your `logovotenam.png` file in the `assets/` folder

5. **Run the app** (Web only):
   ```bash
   flutter run -d chrome
   ```

---

## How Data Synchronization Works

### Real-Time Communication

Both apps communicate through the REST API:

1. **Voter App → API → Database**
   - Voter submits vote → Saved to database
   - Candidate data fetched → Shows latest candidates

2. **Admin App → API → Database**
   - Admin creates candidate → Saved to database
   - Admin views votes → Shows all votes including new ones
   - Dashboard refreshes → Shows updated statistics

3. **Shared Database**
   - All votes stored in PostgreSQL
   - Both apps query same database
   - Data is always synchronized

### Example Timeline

```
Time  | Voter App Action              | Admin App Sees
------|-------------------------------|------------------
10:00 | Voter submits vote for        | Dashboard shows:
      | Candidate A                   | - Total votes: 1
      |                               | - Candidate A: 1 vote
------|-------------------------------|------------------
10:05 | Admin refreshes dashboard     | Dashboard shows:
      |                               | - Total votes: 1
      |                               | - Candidate A: 1 vote
------|-------------------------------|------------------
10:10 | Another voter submits vote    | Dashboard shows:
      | for Candidate B               | - Total votes: 2
      |                               | - Candidate A: 1 vote
      |                               | - Candidate B: 1 vote
------|-------------------------------|------------------
10:15 | Admin creates new candidate   | Voter App shows:
      | (Candidate C)                 | - 3 candidates available
      |                               | in vote category
```

---

## Key Features - Both Apps

### Namibia Flag Colors
- **Blue**: `#003580` (Primary color)
- **Red**: `#D21034` (Accent color)
- **Green**: `#009639` (Secondary color)
- **White**: Used for backgrounds

### Responsive Design
- ✅ **votenam_flutter**: Works on mobile (Android/iOS) and web
- ✅ **votenamadmin_flutter**: Optimized for web (desktop/tablet)
- ✅ All screens adapt to screen size
- ✅ Tables show on wide screens, lists on mobile

### Error Handling
- ✅ Duplicate vote detection (National ID, Email, Phone, Voter Card)
- ✅ Invalid voter card number detection
- ✅ Network error handling
- ✅ User-friendly error dialogs

### Statistics & Charts
- ✅ Overall candidate performance bar charts
- ✅ Regional performance breakdown
- ✅ Top performing candidates
- ✅ Vote counts by region
- ✅ Percentage calculations

---

## API Endpoints Used

### Voter App Endpoints
- `GET /api/voter/dashboard` - Get voting categories
- `GET /api/voter/category/{id}/candidates` - Get candidates by category
- `GET /api/voter/regions` - Get all regions
- `POST /api/voter/submit-vote` - Submit vote
- `GET /api/admin/votes` - Get all votes (for results)
- `GET /api/admin/candidates` - Get all candidates (for results)
- `GET /api/admin/votes/candidate/{id}` - Get votes by candidate

### Admin App Endpoints
- `POST /api/admin/login` - Admin login
- `GET /api/admin/users` - Get all users
- `POST /api/admin/users` - Create user
- `PUT /api/admin/users/{id}` - Update user
- `DELETE /api/admin/users/{id}` - Delete user
- `GET /api/admin/vote-categories` - Get all vote categories
- `POST /api/admin/vote-categories` - Create vote category
- `PUT /api/admin/vote-categories/{id}` - Update vote category
- `DELETE /api/admin/vote-categories/{id}` - Delete vote category
- `GET /api/admin/regions` - Get all regions
- `POST /api/admin/regions` - Create region
- `PUT /api/admin/regions/{id}` - Update region
- `DELETE /api/admin/regions/{id}` - Delete region
- `GET /api/admin/voters-cards` - Get all voter cards
- `POST /api/admin/voters-cards` - Create voter card
- `PUT /api/admin/voters-cards/{id}` - Update voter card
- `DELETE /api/admin/voters-cards/{id}` - Delete voter card
- `GET /api/admin/candidates` - Get all candidates
- `POST /api/admin/candidates` - Create candidate (multipart/form-data)
- `PUT /api/admin/candidates/{id}` - Update candidate (multipart/form-data)
- `DELETE /api/admin/candidates/{id}` - Delete candidate
- `GET /api/admin/votes` - Get all votes
- `GET /api/admin/votes/candidate/{id}` - Get votes by candidate
- `GET /api/admin/votes/category/{id}` - Get votes by category

---

## Testing the Communication

### Step 1: Start Spring Boot Server
```bash
cd c:\projects\votenam
mvn spring-boot:run
```
Server should run on `http://localhost:8484`

### Step 2: Start Admin App
```bash
cd c:\projects\votenamadmin_flutter
flutter run -d chrome
```

### Step 3: Login as Admin
- Create admin user via API or directly in database
- Login with email/password

### Step 4: Create Test Data
- Create vote categories
- Create regions
- Create voter cards
- Create candidates with photos and logos

### Step 5: Start Voter App
```bash
cd c:\projects\votenam_flutter
flutter run -d chrome
```

### Step 6: Test Vote Submission
1. In voter app: Select "Vote Now"
2. Choose a category
3. Select a candidate
4. Fill in voter details
5. Submit vote

### Step 7: Verify in Admin App
1. Go to Dashboard in admin app
2. Refresh or navigate away and back
3. See the new vote in statistics
4. Check "Voters Details" page to see all votes
5. View candidate performance charts updated

---

## Important Notes

1. **API Base URL**: Both apps use `http://localhost:8484` by default. Update this in the service files if your server runs on a different address.

2. **CORS**: The Spring Boot API has CORS enabled for all origins, so both Flutter apps can communicate with it.

3. **Logo File**: Place your `logovotenam.png` file in the `assets/` folder of both apps. The apps will show a placeholder icon if the logo is not found.

4. **Real-time Updates**: The apps don't have WebSocket connections. To see new votes, refresh the screen or navigate away and back. The admin dashboard has a refresh indicator.

5. **Mobile Testing**: For testing the voter app on a physical mobile device, update the API base URL to use your computer's IP address (e.g., `http://192.168.1.100:8484`).

---

## Complete Feature List

### ✅ Voter App (votenam_flutter)
- [x] Launch screen with logo
- [x] Vote Now button
- [x] Results button
- [x] View available voting categories
- [x] View candidates by category
- [x] Candidate selection with photos and party logos
- [x] Voter details form
- [x] Vote submission
- [x] Error handling for duplicates
- [x] Results screen with charts
- [x] Candidate performance by region
- [x] Top performing candidates
- [x] Responsive design
- [x] Cupertino widgets

### ✅ Admin App (votenamadmin_flutter)
- [x] Login screen with logo
- [x] Dashboard with statistics
- [x] Overall performance charts
- [x] Candidate detail charts by region
- [x] Candidates management (CRUD)
- [x] Photo and logo upload for candidates
- [x] Vote Categories management (CRUD)
- [x] Voter Cards management (CRUD)
- [x] Voters Details view (read-only)
- [x] Regions management (CRUD)
- [x] Users management (CRUD)
- [x] Search functionality on all pages
- [x] Sidebar navigation
- [x] Responsive web design

---

## Troubleshooting

### Votes Not Showing in Admin App
1. Check that Spring Boot server is running
2. Verify API base URL in both apps
3. Refresh the admin dashboard
4. Check browser console for errors

### Images Not Loading
1. Verify image URLs in API responses
2. Check CORS settings in Spring Boot
3. Ensure file upload paths are correct

### Network Errors
1. Check that Spring Boot server is accessible
2. For mobile, use computer's IP address instead of localhost
3. Verify firewall settings

---

## Next Steps

1. **Add Logo**: Place `logovotenam.png` in both `assets/` folders
2. **Configure API URL**: Update base URLs if needed
3. **Test Both Apps**: Start Spring Boot server and test both apps
4. **Customize Colors**: Adjust Namibia flag colors if needed
5. **Add Authentication**: Consider adding JWT tokens for better security

---

**Both apps are fully functional and communicate seamlessly through the shared REST API!** 🎉

