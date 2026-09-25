# Mutual Fund Basket

A Flutter full-stack application for browsing mutual funds and managing a personal basket of selected funds.

Built using **Flutter, Bloc, Node.js, Express, Firebase Authentication, and Cloud Firestore**.

## Features

* Email/password authentication with Firebase
* User registration and login
* Persistent authentication across app restarts
* Browse mutual funds
* View fund category, 3-year return, expense ratio, and risk level
* Add funds to a personal basket
* Prevent duplicate funds from being added
* Remove funds from the basket
* Per-user basket persistence
* Loading and error states
* Action feedback for add/remove operations
* Empty basket state
* REST API backend

## Tech Stack

### Mobile

* Flutter
* Dart
* `flutter_bloc`
* Firebase Authentication
* `http`

### Backend

* Node.js
* Express
* Firebase Admin SDK
* Cloud Firestore
* CORS

## Architecture

```text
┌──────────────────────────┐
│       Flutter App        │
│                          │
│   UI → Bloc → Repository │
│             ↓            │
│          API Client      │
└────────────┬─────────────┘
             │
             │ REST / HTTP
             ▼
┌──────────────────────────┐
│     Node.js + Express    │
│                          │
│ Routes → Controllers     │
│        → Services        │
└────────────┬─────────────┘
             │
             │ Firebase Admin
             ▼
┌──────────────────────────┐
│       Firestore          │
│                          │
│ Funds + User Baskets     │
└──────────────────────────┘
```

Firebase Authentication handles user identity on the Flutter side. For protected API requests, the Firebase ID token is sent to the Express backend as a Bearer token. The backend verifies the token using Firebase Admin and uses the verified Firebase UID to access the user's basket.

## Project Structure

```text
lunar-finis/
├── backend/
│   ├── src/
│   │   ├── config/
│   │   │   └── firebase.js
│   │   ├── controllers/
│   │   │   ├── basket.controller.js
│   │   │   └── funds.controller.js
│   │   ├── middleware/
│   │   │   └── auth.js
│   │   ├── routes/
│   │   │   ├── basket.routes.js
│   │   │   └── funds.routes.js
│   │   ├── services/
│   │   │   ├── basket.service.js
│   │   │   └── funds.service.js
│   │   └── server.js
│   └── package.json
│
├── mobile/
│   ├── lib/
│   │   ├── core/
│   │   │   ├── network/
│   │   │   └── utils/
│   │   ├── features/
│   │   │   ├── auth/
│   │   │   ├── basket/
│   │   │   └── funds/
│   │   ├── models/
│   │   ├── repositories/
│   │   └── main.dart
│   └── pubspec.yaml
│
├── .gitignore
└── README.md
```

## Authentication Flow

```text
User
 │
 ▼
Flutter Login / Sign Up
 │
 ▼
Firebase Authentication
 │
 ▼
Firebase ID Token
 │
 ▼
Authorization: Bearer <token>
 │
 ▼
Express Authentication Middleware
 │
 ▼
Firebase Admin verifyIdToken()
 │
 ▼
Authenticated Firebase UID
 │
 ▼
User-specific Basket
```

The backend does not accept a user ID from the client for basket ownership. Instead, the UID is obtained from the verified Firebase ID token.

## API

### Health Check

```http
GET /health
```

Returns:

```json
{
  "status": "ok"
}
```

### Get Funds

```http
GET /funds
```

Returns all available funds.

Example response:

```json
{
  "funds": [
    {
      "id": "fund_001",
      "name": "Axis Growth Opportunities",
      "category": "equity",
      "threeYearReturn": 15.4,
      "expenseRatio": 0.64,
      "riskLevel": "high"
    }
  ]
}
```

### Get Basket

```http
GET /basket
Authorization: Bearer <firebase-id-token>
```

Returns the authenticated user's basket.

### Add Fund

```http
POST /basket
Authorization: Bearer <firebase-id-token>
Content-Type: application/json
```

Request:

```json
{
  "fundId": "fund_001"
}
```

Possible responses:

* `201` — fund added
* `400` — missing `fundId`
* `404` — fund does not exist
* `409` — fund is already in the basket
* `401` — authentication required or token invalid

### Remove Fund

```http
DELETE /basket/:fundId
Authorization: Bearer <firebase-id-token>
```

Returns `204 No Content` when the fund is successfully removed.

If the fund is not present in the user's basket, the API returns `404`.

## Firestore Structure

Funds are stored in the `funds` collection:

```text
funds/
├── fund_001
├── fund_002
├── ...
└── fund_012
```

Each fund contains:

```text
id
name
category
threeYearReturn
expenseRatio
riskLevel
```

User baskets are stored separately:

```text
baskets/
└── {firebaseUid}/
    └── items/
        ├── {fundId}
        ├── {fundId}
        └── ...
```

Basket items store the fund ID and the time at which the fund was added:

```json
{
  "fundId": "fund_001",
  "addedAt": "..."
}
```

The complete fund data is retrieved from the `funds` collection rather than duplicated inside every basket item.

## Running the Backend

Navigate to the backend:

```bash
cd backend
```

Install dependencies:

```bash
npm install
```

The backend provides two scripts:

```bash
npm start
```

for the normal server, and:

```bash
npm run dev
```

for development using Nodemon.

### Firebase Admin Configuration

The backend requires Firebase Admin credentials.

For local development, provide the Firebase service-account JSON as:

```text
backend/serviceAccountKey.json
```

Alternatively, the backend supports the `FIREBASE_SERVICE_ACCOUNT_PATH` environment variable:

```text
FIREBASE_SERVICE_ACCOUNT_PATH=/path/to/serviceAccountKey.json
```

## Running the Flutter App

Navigate to the Flutter project:

```bash
cd mobile
```

Install dependencies:

```bash
flutter pub get
```

Then run:

```bash
flutter run
```

The Flutter project is already configured with Firebase using FlutterFire.

The application uses the deployed backend API:

```text
https://lunar-finis.onrender.com
```

The API base URL is defined in:

```text
mobile/lib/core/utils/constants.dart
```

## Application Flow

### 1. Authentication

The user can either log in with an existing Firebase account or create a new account.

### 2. Funds

After authentication, the application loads the available funds from the REST API.

Each fund displays:

* Name
* Category
* Risk level
* 3-year return
* Expense ratio

### 3. Add to Basket

Selecting **Add to Basket** sends a request to the backend.

The backend:

1. Verifies the user's Firebase token.
2. Checks that the fund exists.
3. Checks for an existing basket entry.
4. Creates the basket item for the authenticated user.

Duplicate additions return a conflict response.

### 4. Basket

The basket screen loads the authenticated user's funds from the backend.

Users can remove individual funds from their basket.

### 5. Persistence

Basket data is stored in Firestore against the authenticated user's Firebase UID, allowing the basket to persist across navigation and subsequent login sessions.

## Assumptions

* The mutual fund dataset is static and intended for the scope of this assignment.
* Fund values such as 3-year returns and expense ratios are representative/mock values.
* The application does not execute investments or financial transactions.
* SIPs, payments, KYC, and other investment workflows are outside the scope of this implementation.
* The basket belongs to the authenticated Firebase user.
* Firebase Authentication is used for identity while the Express API controls basket access.
* The application does not provide investment advice.

## What I Would Improve With More Time

If this were extended beyond the assignment scope, I would consider:

* Unit and integration tests for the Flutter application
* API/integration tests for the Express backend
* More structured API error types on the Flutter side
* Dependency injection for easier testing
* Search and filtering for funds
* Pagination for larger datasets
* More comprehensive authentication and session error handling
* Production logging and monitoring
* Automated deployment/CI
* More extensive accessibility and responsive UI testing
* Additional Firestore validation and security hardening

## Scope

This implementation intentionally focuses on the core fund-browsing and basket-management workflow.

It does not attempt to implement investment transactions, payments, SIPs, KYC, or external live fund-data integrations.

---

Built with Flutter, Bloc, Node.js, Express, Firebase Authentication, and Cloud Firestore.
