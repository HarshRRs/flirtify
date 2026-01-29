const express = require('express');
const router = express.Router();
const { createConfession, getConfessions, heartConfession } = require('../controllers/confessionController');
const { protect } = require('../middleware/authMiddleware');

router.post('/', protect, createConfession);
router.get('/', protect, getConfessions);
router.post('/:confessionId/heart', protect, heartConfession);

module.exports = router;
