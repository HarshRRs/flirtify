# Flirtify API Documentation 🚀🔧

This document provides a technical overview of the Flirtify backend API.

## Base URL
`http://localhost:5000/api` (Development)

## Authentication
Most endpoints require a JWT token in the `Authorization` header:
`Authorization: Bearer <your_token>`

---

## 👤 User Endpoints

### 💘 Discovery
Fetches potential matches based on user preferences and filters.

- **URL**: `/users/discovery`
- **Method**: `GET`
- **Auth Required**: YES
- **Query Params (Optional)**:
  - `minAge` (Number)
  - `maxAge` (Number)
  - `maxDistance` (Number, in km)
- **Success Response**: `200 OK` with an array of sanitized User objects.

### 💖 Like User
Expresses interest in another user.

- **URL**: `/users/like`
- **Method**: `POST`
- **Auth Required**: YES
- **Body**: `{ "targetUserId": "ID_STRING" }`
- **Success Response**: `200 OK` with `{ "isMatch": true/false, "message": "..." }`

### 👎 Dislike User
Skips another user.

- **URL**: `/users/dislike`
- **Method**: `POST`
- **Auth Required**: YES
- **Body**: `{ "targetUserId": "ID_STRING" }`

---

## 🔐 Auth Endpoints

### 📝 Register
Creates a new user account.

- **URL**: `/auth/register`
- **Method**: `POST`
- **Body**: 
  ```json
  {
    "name": "...",
    "email": "...",
    "password": "...",
    "age": 25,
    "gender": "male/female/other",
    "photos": ["BASE64_STREINGS"]
  }
  ```

### 🔑 Login
Authenticates a user and returns a token.

- **URL**: `/auth/login`
- **Method**: `POST`
- **Body**: `{ "email": "...", "password": "..." }`

---

## ✨ System Features

### 📍 HeatMap
Returns clusters of active users nearby.

- **URL**: `/users/heatmap`
- **Method**: `GET`
- **Auth Required**: YES

### 🤖 Wingman Icebreakers
Generates flirty conversation starters based on mood.

- **URL**: `/users/wingman`
- **Method**: `GET`
- **Query Params**: `mood` (e.g., Playful, Teasing)

---

## 🛠️ Global Safety Meaures
- **Rate Limiting**: 100 requests per 15 minutes per IP.
- **Payload Limit**: JSON bodies are limited to 10MB.
- **Data Sanitization**: All NoSQL inputs are automatically sanitized.
