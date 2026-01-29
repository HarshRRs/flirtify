const express = require('express');
const router = express.Router();
const { generateToken } = require('../controllers/callController');
const { protect } = require('../middleware/authMiddleware');

router.get('/token', protect, generateToken);

module.exports = router;
