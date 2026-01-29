require('dotenv').config();
const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const http = require('http');
const { Server } = require('socket.io');
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');
const mongoSanitize = require('express-mongo-sanitize');

const app = express();
const server = http.createServer(app);

// In production, replace "*" with your actual frontend domain
const allowedOrigins = process.env.ALLOWED_ORIGINS ? process.env.ALLOWED_ORIGINS.split(',') : ["*"];

const io = new Server(server, {
  cors: {
    origin: (origin, callback) => {
      if (!origin || (allowedOrigins.length > 0 && (allowedOrigins.includes(origin) || allowedOrigins.includes("*")))) {
        callback(null, true);
      } else {
        callback(new Error('Not allowed by CORS'));
      }
    },
    methods: ["GET", "POST"]
  }
});

// Security Middleware
app.use(helmet()); // Sets various security-focused HTTP headers
app.use(mongoSanitize()); // Prevents NoSQL injection attacks

// Rate Limiting
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // Limit each IP to 100 requests per windowMs
  standardHeaders: true, // Return rate limit info in the `RateLimit-*` headers
  legacyHeaders: false, // Disable the `X-RateLimit-*` headers
  message: 'Too many requests from this IP, please try again after 15 minutes'
});

app.use('/api/', limiter); // Apply rate limiting to all requests under /api/

app.use(cors({
  origin: (origin, callback) => {
    if (!origin || (allowedOrigins.length > 0 && (allowedOrigins.includes(origin) || allowedOrigins.includes("*")))) {
      callback(null, true);
    } else {
      callback(new Error('Not allowed by CORS'));
    }
  }
}));

// Basic Security Headers (Would ideally use helmet.js, adding manual headers for now)
app.use((req, res, next) => {
  res.setHeader('X-Content-Type-Options', 'nosniff');
  res.setHeader('X-Frame-Options', 'DENY');
  res.setHeader('X-XSS-Protection', '1; mode=block');
  next();
});

app.use(express.json({ limit: '10mb' })); // Reduced from 50mb for better security
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// Database Connection
mongoose.connect(process.env.MONGODB_URI)
  .then(() => console.log('MongoDB connected...'))
  .catch(err => console.log('MongoDB connection error:', err));

// Socket.io Logic
io.on('connection', (socket) => {
  console.log('A user connected:', socket.id);

  socket.on('join_chat', (userId) => {
    socket.join(userId);
    console.log(`User ${userId} joined their private channel`);
  });

  socket.on('send_message', (data) => {
    // data: { receiverId, senderId, message, timestamp }
    io.to(data.receiverId).emit('receive_message', data);
  });

  // Group Room events
  socket.on('join_vibe_room', (roomId) => {
    socket.join(roomId);
    console.log(`User joined Vibe Room: ${roomId}`);
  });

  socket.on('send_room_message', (data) => {
    // data: { roomId, senderId, message, timestamp }
    io.to(data.roomId).emit('receive_room_message', data);
  });

  // Call Signaling
  socket.on('call_user', (data) => {
    // data: { userToCall, signalData, from, name, type: 'video' | 'voice' }
    io.to(data.userToCall).emit('incoming_call', {
      from: data.from,
      name: data.name,
      type: data.type,
      channelName: data.channelName
    });
  });

  socket.on('answer_call', (data) => {
    // data: { to, accepted: true | false }
    io.to(data.to).emit('call_answered', data);
  });

  socket.on('end_call', (data) => {
    io.to(data.to).emit('call_ended');
  });

  socket.on('disconnect', () => {
    console.log('User disconnected');
  });
});

// Basic Route
app.use('/api/auth', require('./src/routes/authRoutes'));
app.use('/api/users', require('./src/routes/userRoutes'));
app.use('/api/messages', require('./src/routes/messageRoutes'));
app.use('/api/rooms', require('./src/routes/roomRoutes'));
app.use('/api/confessions', require('./src/routes/confessionRoutes'));
app.use('/api/calls', require('./src/routes/callRoutes'));

app.get('/', (req, res) => {
  res.send('Flirtify API is running...');
});

app.get('/api/health', (req, res) => {
  res.status(200).json({ status: 'ok', timestamp: new Date().toISOString() });
});

// Start Server
const PORT = process.env.PORT || 5000;
server.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
