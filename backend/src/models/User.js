const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

const userSchema = new mongoose.Schema({
  name: { type: String, required: true },
  email: { type: String, required: true, unique: true, lowercase: true, trim: true },
  password: { type: String, required: true, select: false },
  age: { type: Number, required: true },
  gender: { type: String, enum: ['male', 'female', 'other'], required: true },
  mood: { type: String, default: 'Playful' },
  bio: { type: String, default: '', maxlength: 500 },

  // Profile Prompts (from Phase 4)
  prompts: [{
    question: String,
    answer: String
  }],

  voiceTeaser: { type: String }, // Base64 audio string or URL
  photos: [{ type: String }], // Array of Base64 strings or URLs

  location: {
    type: { type: String, default: 'Point' },
    coordinates: { type: [Number], index: '2dsphere' } // [longitude, latitude]
  },

  preferences: {
    gender: { type: String, enum: ['male', 'female', 'other', 'all'], default: 'all' },
    ageRange: {
      min: { type: Number, default: 18 },
      max: { type: Number, default: 50 }
    },
    maxDistance: { type: Number, default: 50 } // km
  },

  likedUsers: [{ type: mongoose.Schema.Types.ObjectId, ref: 'User' }],
  dislikedUsers: [{ type: mongoose.Schema.Types.ObjectId, ref: 'User' }],
  matches: [{ type: mongoose.Schema.Types.ObjectId, ref: 'User' }],

  lastSeen: { type: Date, default: Date.now },
  createdAt: { type: Date, default: Date.now },

  isActive: { type: Boolean, default: true }
}, {
  timestamps: true
});

// Indices for high-performance filtering
userSchema.index({ age: 1, gender: 1 });
userSchema.index({ lastSeen: -1 });

// Hash password before saving
userSchema.pre('save', async function (next) {
  if (!this.isModified('password')) return next();
  this.password = await bcrypt.hash(this.password, 12); // Slightly higher cost factor
  next();
});

// Method to compare password
userSchema.methods.comparePassword = async function (candidatePassword) {
  return await bcrypt.compare(candidatePassword, this.password);
};

// Ensure no sensitive data is leaked
userSchema.methods.toPublicJSON = function () {
  const user = this.toObject();
  delete user.password;
  delete user.email;
  delete user.likedUsers;
  delete user.dislikedUsers;
  delete user.__v;
  return user;
};

module.exports = mongoose.model('User', userSchema);
