const express = require('express');
const router = express.Router();
const { generateCallRoom } = require('../controllers/callController');
const { protect } = require('../middleware/authMiddleware');

router.get('/room', protect, generateCallRoom);

module.exports = router;
