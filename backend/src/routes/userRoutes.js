const express = require('express');
const router = express.Router();
const { getDiscoveryUsers, likeUser, dislikeUser, getHeatMap, getWingmanIcebreaker } = require('../controllers/userController');
const { protect } = require('../middleware/authMiddleware');

router.get('/discovery', protect, getDiscoveryUsers);
router.post('/like', protect, likeUser);
router.post('/dislike', protect, dislikeUser);
router.get('/heatmap', protect, getHeatMap);
router.get('/wingman', protect, getWingmanIcebreaker);

module.exports = router;
