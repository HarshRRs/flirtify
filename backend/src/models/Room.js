const mongoose = require('mongoose');

const roomSchema = new mongoose.Schema({
  name: { type: String, required: true },
  mood: { type: String, required: true },
  host: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  participants: [{ type: mongoose.Schema.Types.ObjectId, ref: 'User' }],
  isBoosted: { type: Boolean, default: false },
  expiresAt: { 
    type: Date, 
    default: () => new Date(+new Date() + 24*60*60*1000), // 24 hours from now
    index: { expires: '0s' } // Auto-delete from DB when expired
  },
  createdAt: { type: Date, default: Date.now }
});

module.exports = mongoose.model('Room', roomSchema);
