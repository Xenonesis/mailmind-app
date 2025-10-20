# API Endpoints Documentation

This document provides comprehensive documentation for all API endpoints in the email management application.

## Authentication Endpoints

All authentication endpoints are available under the `/auth` base path.

### Registration

**POST** `/auth/register`

- **Description**: Register a new user account
- **Authentication**: Not required
- **Request Body**:
  ```json
  {
    "email": "string",
    "password": "string",
    "firstName": "string",
    "lastName": "string"
  }
  ```
- **Response**: User registration confirmation and authentication token
- **Success Response**: `201 Created`
- **Error Responses**: 
  - `400 Bad Request` - Invalid input data
  - `409 Conflict` - User already exists

### Login

**POST** `/auth/login`

- **Description**: Authenticate user and return access token
- **Authentication**: Not required
- **Request Body**:
  ```json
  {
    "email": "string",
    "password": "string"
  }
  ```
- **Response**: Authentication token and user information
- **Success Response**: `200 OK`
- **Error Responses**: 
  - `400 Bad Request` - Invalid input data
  - `401 Unauthorized` - Invalid credentials

### Google OAuth

**GET** `/auth/google`

- **Description**: Initiate Google OAuth authentication flow
- **Authentication**: Not required
- **Response**: Redirect to Google authentication page
- **Success Response**: `302 Found` (redirect)
- **Error Responses**: `500 Internal Server Error`

**GET** `/auth/google/callback`

- **Description**: Handle Google OAuth callback and complete authentication
- **Authentication**: Not required (Google handles authentication)
- **Response**: Authentication token and user information
- **Success Response**: `200 OK`
- **Error Responses**: `401 Unauthorized` or `500 Internal Server Error`

## User Management Endpoints

All user management endpoints require authentication and are available under the `/user` base path.

### Profile Management

**GET** `/user/profile`

- **Description**: Retrieve current user's profile information
- **Authentication**: Required (JWT token)
- **Headers**: 
  - `Authorization: Bearer <token>`
- **Response**: User profile data including email, name, and account details
- **Success Response**: `200 OK`
- **Error Responses**: 
  - `401 Unauthorized` - Invalid or expired token
  - `404 Not Found` - User not found

### User Settings

**GET** `/user/settings`

- **Description**: Retrieve current user's settings
- **Authentication**: Required (JWT token)
- **Headers**: 
  - `Authorization: Bearer <token>`
- **Response**: User settings configuration
- **Success Response**: `200 OK`
- **Error Responses**: 
  - `401 Unauthorized` - Invalid or expired token
  - `404 Not Found` - Settings not found for user

**PUT** `/user/settings`

- **Description**: Update current user's settings
- **Authentication**: Required (JWT token)
- **Headers**: 
  - `Authorization: Bearer <token>`
- **Request Body**: Settings update object
- **Response**: Updated settings confirmation
- **Success Response**: `200 OK`
- **Error Responses**: 
  - `401 Unauthorized` - Invalid or expired token
  - `400 Bad Request` - Invalid settings data

## Email Management Endpoints

All email management endpoints require authentication and are available under the `/emails` base path.

### Email Synchronization

**GET** `/emails/sync`

- **Description**: Synchronize emails from external provider
- **Authentication**: Required (JWT token)
- **Headers**: 
  - `Authorization: Bearer <token>`
  - `x-access-token: <external provider token>`
- **Response**: Synchronization status and count of processed emails
- **Success Response**: `200 OK`
- **Error Responses**: 
  - `401 Unauthorized` - Invalid or expired token
  - `400 Bad Request` - Missing external access token

### Email Retrieval

**GET** `/emails`

- **Description**: Retrieve user's emails with optional category filtering
- **Authentication**: Required (JWT token)
- **Headers**: 
  - `Authorization: Bearer <token>`
- **Query Parameters**:
 - `category` (optional): Filter emails by category (e.g., inbox, sent, drafts, spam)
- **Response**: List of emails with metadata
- **Success Response**: `200 OK`
- **Error Responses**: 
  - `401 Unauthorized` - Invalid or expired token

**GET** `/emails/:id`

- **Description**: Retrieve a specific email by ID
- **Authentication**: Required (JWT token)
- **Headers**: 
  - `Authorization: Bearer <token>`
- **Path Parameters**:
  - `id`: Email ID
- **Response**: Email details including subject, body, sender, recipients, and metadata
- **Success Response**: `200 OK`
- **Error Responses**: 
  - `401 Unauthorized` - Invalid or expired token
  - `404 Not Found` - Email not found
  - `403 Forbidden` - User doesn't have access to this email

### Email Categories

**GET** `/emails/categories`

- **Description**: Retrieve available email categories for the user
- **Authentication**: Required (JWT token)
- **Headers**: 
  - `Authorization: Bearer <token>`
- **Response**: List of available email categories
- **Success Response**: `200 OK`
- **Error Responses**: 
  - `401 Unauthorized` - Invalid or expired token

## Authentication Requirements Summary

| Endpoint | Authentication Required | Notes |
|----------|------------------------|-------|
| `POST /auth/register` | No | User registration |
| `POST /auth/login` | No | User authentication |
| `GET /auth/google` | No | OAuth initiation |
| `GET /auth/google/callback` | No | OAuth completion |
| `GET /user/profile` | Yes | JWT token required |
| `GET /user/settings` | Yes | JWT token required |
| `PUT /user/settings` | Yes | JWT token required |
| `GET /emails/sync` | Yes | JWT token required |
| `GET /emails` | Yes | JWT token required |
| `GET /emails/:id` | Yes | JWT token required |
| `GET /emails/categories` | Yes | JWT token required |

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