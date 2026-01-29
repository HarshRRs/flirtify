const mongoose = require('mongoose');

const confessionSchema = new mongoose.Schema({
  author: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  text: { type: String, required: true },
  hearts: [{ type: mongoose.Schema.Types.ObjectId, ref: 'User' }],
  isAnonymous: { type: Boolean, default: true },
  createdAt: { type: Date, default: Date.now }
});

module.exports = mongoose.model('Confession', confessionSchema);
