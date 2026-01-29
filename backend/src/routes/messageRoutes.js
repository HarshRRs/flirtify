const express = require('express');
const router = express.Router();
const { sendMessage, getMessages } = require('../controllers/messageController');
const { protect } = require('../middleware/authMiddleware');
const { safetyCheck } = require('../middleware/safetyMiddleware');

router.post('/', protect, safetyCheck, sendMessage);
router.get('/:otherUserId', protect, getMessages);

module.exports = router;
