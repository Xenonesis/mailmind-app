# MailMind App - Backend API Endpoints

This document details all the API endpoints that the MailMind Flutter app is designed to use from the backend.

## Base URL
```
http://localhost:3000/api (for local development)
```
Or your deployed backend URL for production.

Update the base URL in `lib/api/endpoints.dart`:
```dart
static const String baseUrl = 'http://localhost:3000/api';
```

## Authentication Endpoints

### Register
- **POST** `/auth/register`
- **Description**: Register a new user account
- **Authentication**: Not required
- **Request Body**:
  ```json
  {
    "email": "user@example.com",
    "password": "password",
    "name": "User Name"
  }
  ```
- **Response**: 
  ```json
  {
    "access_token": "jwt_token",
    "user": {
      "id": "user_id",
      "email": "user@example.com",
      "name": "User Name"
    }
  }
  ```
- **Success Response**: `201 Created`

### Login
- **POST** `/auth/login`
- **Description**: Authenticate user and return access token
- **Authentication**: Not required
- **Request Body**:
  ```json
  {
    "email": "user@example.com",
    "password": "password"
  }
  ```
- **Response**: 
  ```json
  {
    "access_token": "jwt_token",
    "user": {
      "id": "user_id",
      "email": "user@example.com",
      "name": "User Name"
    }
  }
  ```
- **Success Response**: `200 OK`

### Google OAuth
- **GET** `/auth/google`
- **Description**: Initiate Google OAuth authentication flow
- **Authentication**: Not required
- **Response**: Redirect to Google authentication page
- **Success Response**: `302 Found` (redirect)

### Google OAuth Callback
- **GET** `/auth/google/callback`
- **Description**: Handle Google OAuth callback and complete authentication
- **Authentication**: Not required (Google handles authentication)
- **Response**: Authentication token and user information
- **Success Response**: `200 OK`

### Google OAuth Token Verification
- **POST** `/auth/google/token`
- **Description**: Verify Google ID token and authenticate user
- **Authentication**: Not required
- **Request Body**:
  ```json
  {
    "idToken": "google_id_token",
    "accessToken": "google_access_token"
  }
  ```
- **Response**: 
  ```json
  {
    "access_token": "jwt_token",
    "user": {
      "id": "user_id",
      "email": "user@example.com",
      "name": "User Name"
    }
  }
  ```
- **Success Response**: `200 OK`

## User Management Endpoints
*All endpoints require Authorization: Bearer token*

### Get Profile
- **GET** `/user/profile`
- **Description**: Retrieve current user's profile information
- **Headers**: 
  ```json
  {
    "Authorization": "Bearer {token}"
  }
  ```
- **Response**: 
  ```json
  {
    "id": "user_id",
    "email": "user@example.com",
    "name": "User Name"
  }
  ```
- **Success Response**: `200 OK`

### Get Settings
- **GET** `/user/settings`
- **Description**: Retrieve current user's settings
- **Headers**: 
  ```json
  {
    "Authorization": "Bearer {token}"
  }
  ```
- **Response**: 
  ```json
  {
    "theme": "light",
    "notifications": true,
    "autoSync": true,
    "syncFrequency": 15
  }
  ```
- **Success Response**: `200 OK`

### Update Settings
- **PUT** `/user/settings`
- **Description**: Update current user's settings
- **Headers**: 
  ```json
  {
    "Authorization": "Bearer {token}"
  }
  ```
- **Request Body**: 
  ```json
  {
    "theme": "dark",
    "notifications": false,
    "autoSync": true,
    "syncFrequency": 30
  }
  ```
- **Response**: Updated settings confirmation
- **Success Response**: `200 OK`

## Email Management Endpoints
*All endpoints require Authorization: Bearer token*

### Sync Emails
- **GET** `/emails/sync`
- **Description**: Synchronize emails from external provider
- **Headers**: 
  ```json
  {
    "Authorization": "Bearer {token}",
    "x-access-token": "email_provider_token"
  }
  ```
- **Response**: Synchronization status and count of processed emails
- **Success Response**: `200 OK`

### Get All Emails
- **GET** `/emails`
- **Description**: Retrieve user's emails with optional category filtering
- **Headers**: 
  ```json
  {
    "Authorization": "Bearer {token}"
  }
  ```
- **Query Parameters**:
  - `category` (optional): Filter emails by category (e.g., work, personal, promotions)
- **Example**: `GET /emails?category=work`
- **Response**: List of emails with metadata
- **Success Response**: `200 OK`

### Get Email Categories
- **GET** `/emails/categories`
- **Description**: Retrieve available email categories for the user
- **Headers**: 
  ```json
  {
    "Authorization": "Bearer {token}"
  }
  ```
- **Response**: List of available email categories
- **Success Response**: `200 OK`

### Get Specific Email
- **GET** `/emails/{id}`
- **Description**: Retrieve a specific email by ID
- **Headers**: 
  ```json
  {
    "Authorization": "Bearer {token}"
  }
  ```
- **Path Parameters**:
  - `id`: Email ID
- **Response**: Email details including subject, body, sender, recipients, and metadata
- **Success Response**: `200 OK`

## Frontend Implementation Example

### Flutter/Dart Implementation
The MailMind app uses Dio HTTP client. Here's how the endpoints are integrated:

```dart
// Update base URL in lib/api/endpoints.dart
class ApiEndpoints {
  static const String baseUrl = 'http://localhost:3000/api';
  
  // Authentication endpoints
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String googleAuth = '/auth/google';
  
  // User management endpoints
  static const String userProfile = '/user/profile';
  static const String userSettings = '/user/settings';
  
  // Email management endpoints
  static const String emailSync = '/emails/sync';
  static const String emails = '/emails';
  static const String emailCategories = '/emails/categories';
}
```

### JavaScript Implementation Example
```javascript
// Example using fetch API
const API_BASE = 'http://localhost:3000/api';

// Register
const register = async (userData) => {
  const response = await fetch(`${API_BASE}/auth/register`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(userData)
  });
  return response.json();
};

// Login
const login = async (credentials) => {
  const response = await fetch(`${API_BASE}/auth/login`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(credentials)
  });
  return response.json();
};

// Get user profile (with token)
const getProfile = async (token) => {
  const response = await fetch(`${API_BASE}/user/profile`, {
    headers: { 'Authorization': `Bearer ${token}` }
  });
  return response.json();
};

// Get emails with category filter
const getEmails = async (token, category = null) => {
  const url = category 
    ? `${API_BASE}/emails?category=${category}`
    : `${API_BASE}/emails`;
  
  const response = await fetch(url, {
    headers: { 'Authorization': `Bearer ${token}` }
  });
  return response.json();
};
```

## Error Response Format

All error responses follow this standard format:

```json
{
  "statusCode": 401,
  "error": "Unauthorized",
  "message": "Invalid or expired token"
}
```

## Integration Notes

1. **Base URL**: Update the base URL in `lib/api/endpoints.dart` to match your backend server
2. **Authentication**: The app automatically handles JWT token storage and includes it in requests
3. **Error Handling**: The app includes comprehensive error handling for all API responses
4. **Offline Support**: The app caches data locally using Hive for offline functionality

These endpoints are ready to be integrated with your MailMind Flutter application using the existing Dio HTTP client configuration.
- **Endpoint**: `GET /auth/google/callback`
- **Description**: Handle Google OAuth callback and complete authentication
- **Authentication**: Not required (Google handles authentication)
- **Response**: Authentication token and user information
- **Success Response**: `200 OK`

## User Management Endpoints

### Profile Management
- **Endpoint**: `GET /user/profile`
- **Description**: Retrieve current user's profile information
- **Authentication**: Required (JWT token in Authorization header)
- **Headers**: `Authorization: Bearer <token>`
- **Response**: User profile data including email, name, and account details
- **Success Response**: `200 OK`

### User Settings
- **Endpoint**: `GET /user/settings`
- **Description**: Retrieve current user's settings
- **Authentication**: Required (JWT token in Authorization header)
- **Headers**: `Authorization: Bearer <token>`
- **Response**: User settings configuration
- **Success Response**: `200 OK`

- **Endpoint**: `PUT /user/settings`
- **Description**: Update current user's settings
- **Authentication**: Required (JWT token in Authorization header)
- **Headers**: `Authorization: Bearer <token>`
- **Request Body**: Settings update object
- **Response**: Updated settings confirmation
- **Success Response**: `200 OK`

## Email Management Endpoints

### Email Synchronization
- **Endpoint**: `GET /emails/sync`
- **Description**: Synchronize emails from external provider
- **Authentication**: Required (JWT token in Authorization header)
- **Headers**: 
  - `Authorization: Bearer <token>`
  - `x-access-token: <external provider token>`
- **Response**: Synchronization status and count of processed emails
- **Success Response**: `200 OK`

### Email Retrieval
- **Endpoint**: `GET /emails`
- **Description**: Retrieve user's emails with optional category filtering
- **Authentication**: Required (JWT token in Authorization header)
- **Headers**: `Authorization: Bearer <token>`
- **Query Parameters**: `category` (optional): Filter emails by category (e.g., inbox, sent, drafts, spam)
- **Response**: List of emails with metadata
- **Success Response**: `200 OK`

- **Endpoint**: `GET /emails/:id`
- **Description**: Retrieve a specific email by ID
- **Authentication**: Required (JWT token in Authorization header)
- **Headers**: `Authorization: Bearer <token>`
- **Path Parameters**: `id`: Email ID
- **Response**: Email details including subject, body, sender, recipients, and metadata
- **Success Response**: `200 OK`

### Email Categories
- **Endpoint**: `GET /emails/categories`
- **Description**: Retrieve available email categories for the user
- **Authentication**: Required (JWT token in Authorization header)
- **Headers**: `Authorization: Bearer <token>`
- **Response**: List of available email categories
- **Success Response**: `200 OK`

## AI Endpoints (if available)
- **Endpoint**: `POST /ai/summarize`
- **Description**: Get AI-generated summary of an email
- **Authentication**: Required (JWT token in Authorization header)

- **Endpoint**: `POST /ai/categorize`
- **Description**: Get AI-generated category for an email
- **Authentication**: Required (JWT token in Authorization header)

- **Endpoint**: `POST /ai/priority`
- **Description**: Get AI-generated priority for an email
- **Authentication**: Required (JWT token in Authorization header)

## Error Response Format
All error responses follow this standard format:
```json
{
  "statusCode": 401,
  "error": "Unauthorized",
  "message": "Invalid or expired token"
}
```

## Common Headers
- **Content-Type**: `application/json` (for requests with body)
- **Authorization**: `Bearer <jwt_token>` (for authenticated requests)
- **x-access-token**: `<external_provider_token>` (for email sync operations)

## Implementation in App
These endpoints are implemented in the following files:
- `lib/api/endpoints.dart` - Contains the endpoint URL constants
- `lib/api/dio_client.dart` - HTTP client with interceptors for authentication
- `lib/repositories/auth_repository.dart` - Authentication API calls
- `lib/repositories/email_repository.dart` - Email API calls
- `lib/repositories/user_repository.dart` - User management API calls
