# 🌐 Flirtify Cloud Configuration Guide

This guide explains exactly which 9 variables you need in your **Railway Dashboard** and how to get them from each service provider.

---

## 🛠️ 1. Database: MongoDB Atlas
**Variable:** `MONGODB_URI`

1. Go to [MongoDB Atlas](https://www.mongodb.com/cloud/atlas).
2. Click **Connect** on your Cluster.
3. Choose **"Connect your application"** (Drivers).
4. Copy the connection string.
5. Replace `<password>` with your database user password.
   - *Example:* `mongodb+srv://admin:pass123@cluster.mongodb.net/flirtify?retryWrites=true&w=majority`

---

## ☁️ 2. Media Storage: AWS S3
**Variables:** `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_REGION`, `AWS_S3_BUCKET_NAME`

1. **Bucket**: Go to [AWS S3 Console](https://s3.console.aws.amazon.com/) and click **Create bucket**. Give it a unique name (e.g., `flirtify-media-2026`).
2. **Region**: Note the code (e.g. `us-east-1` or `ap-south-1`).
3. **IAM Keys**:
   - Go to [IAM Console](https://console.aws.amazon.com/iam/).
   - Go to **Users** -> **Create User**.
   - Attach Policy: **AmazonS3FullAccess**.
   - Go to the new user -> **Security credentials** -> **Create access key**.
   - Choose **"Application running outside AWS"**.
   - Copy the **Access Key** and the **Secret Key** immediately!

---

## 📞 3. Video/Voice Calls: Jitsi Meet (FREE)
**Status:** **Life-Time Free Forever**

1. **How it works**: Flirtify now uses Jitsi Meet's public secure servers. 
2. **Cost**: **$0.00** No matter how many minutes you use.
3. **Setup**: None required! The app automatically generates unique, encrypted bridge rooms for every match.

---

## 🔐 4. General Security
**Variables:** `JWT_SECRET`, `ALLOWED_ORIGINS`

1. **JWT_SECRET**: Put any long, random text here. It secures user logins.
   - *Example:* `9h#s2K!pX8vL@6mZq3nR5tY7wJ`
2. **ALLOWED_ORIGINS**: Controls who can talk to your API.
   - *Value for development/mobile:* `*`

---

## 🏁 Summary Table for Railway

| Railway Name | Source |
| :--- | :--- |
| `MONGODB_URI` | MongoDB Connection String |
| `JWT_SECRET` | Any random strong string |
| `ALLOWED_ORIGINS` | `*` |
| `AWS_ACCESS_KEY_ID` | IAM User Access Key |
| `AWS_SECRET_ACCESS_KEY` | IAM User Secret Key |
| `AWS_REGION` | e.g. `us-east-1` |
| `AWS_S3_BUCKET_NAME` | Your S3 Bucket Name |
| `AGORA_APP_ID` | Agora Project AppID |
| `AGORA_APP_CERTIFICATE` | Agora Project Certificate |

---

## 📱 Connecting the Mobile App
Once your Railway build turns **Green**, remember to update your Flutter file:
📂 `lib/core/api_service.dart`

**Update:**
```dart
static const String baseUrl = 'https://flirtify-production.up.railway.app/api';
```

---
**Flirtify is now fully powered by the cloud! 🚀💘**
