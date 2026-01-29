# Flirtify 🚀❤️

[![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)](https://flutter.dev)
[![Node.js](https://img.shields.io/badge/node.js-6DA55F?style=for-the-badge&logo=node.js&logoColor=white)](https://nodejs.org/)
[![MongoDB](https://img.shields.io/badge/MongoDB-%234ea94b.svg?style=for-the-badge&logo=mongodb&logoColor=white)](https://www.mongodb.com/)
[![License: ISC](https://img.shields.io/badge/License-ISC-blue.svg?style=for-the-badge)](https://opensource.org/licenses/ISC)

**Flirtify** is a premium, world-class dating application designed to foster meaningful global connections. Built with Flutter for a stunning cross-platform experience and powered by a robust Node.js backend, Flirtify combines high-performance discovery with real-time engagement.

## ✨ Features

- 📱 **Premium UI/UX**: Sleek, modern interface with glassmorphism and smooth animations.
- 💘 **Discovery & Swiping**: Advanced matching algorithm with intuitive card-based discovery.
- 💬 **Real-time Messaging**: Instant communication powered by Socket.io.
- 📹 **Video & Voice Calls**: Seamless, high-quality calling integrated via Agora RTC.
- 📍 **Interactive Heatmap**: Discover activity hotspots nearby in real-time.
- 🎭 **Vibe Rooms & Confessions**: Unique social spaces for anonymous Sharing and group interaction.
- 🎙️ **Voice Teasers**: Express your personality through audio profile snippets.
- 🌓 **Dark Mode Support**: Optimized for all lighting conditions (Coming Soon).

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (^3.10.3)
- Node.js & npm
- MongoDB
- Agora Developer Account (for calls)

### Backend Setup

1. Navigate to the `backend` directory.
2. Install dependencies:
   ```bash
   npm install
   ```
3. Create a `.env` file from the template and add your credentials.
4. Start the server:
   ```bash
   npm run dev
   ```

### Frontend Setup

1. Install Flutter dependencies:
   ```bash
   flutter pub get
   ```
2. Configure your API base URL in `lib/core/api_service.dart`.
3. Run the application:
   ```bash
   flutter run
   ```

## 🛠️ Tech Stack

- **Frontend**: Flutter, GetX (State Management), flutter_animate, glassmorphism_ui.
- **Backend**: Node.js, Express, Socket.io, Mongoose (MongoDB).
- **Video/Voice**: Agora RTC Engine.
- **Maps**: flutter_map.

## 📄 License

This project is licensed under the ISC License.

---

Made with ❤️ by the Flirtify Team.
