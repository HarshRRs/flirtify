const User = require('../models/User');

exports.getDiscoveryUsers = async (req, res) => {
  try {
    const user = await User.findById(req.user.id);
    if (!user) return res.status(404).json({ message: 'User not found' });

    // Use current settings but allow overrides from query params (Phase 4)
    const minAge = parseInt(req.query.minAge) || user.preferences.ageRange.min;
    const maxAge = parseInt(req.query.maxAge) || user.preferences.ageRange.max;
    const distanceLimit = parseInt(req.query.maxDistance) || user.preferences.maxDistance;
    const targetGender = user.preferences.gender;

    let query = {
      _id: { $ne: user._id, $nin: [...user.likedUsers, ...user.dislikedUsers] },
      age: { $gte: minAge, $lte: maxAge },
      isActive: true
    };

    if (targetGender !== 'all') {
      query.gender = targetGender;
    }

    // Advanced Geo Query
    if (user.location && user.location.coordinates) {
      query.location = {
        $near: {
          $geometry: {
            type: 'Point',
            coordinates: user.location.coordinates
          },
          $maxDistance: distanceLimit * 1000 // meters
        }
      };
    }

    // Fetch batch of users
    // We limit to 40 and randomize to keep the experience fresh
    let discoveryList = await User.find(query).limit(40);

    // Sort by lastSeen to prioritize active users
    discoveryList.sort((a, b) => b.lastSeen - a.lastSeen);

    // Convert to public JSON format
    const sanitizedUsers = discoveryList.map(u => u.toPublicJSON());

    res.json(sanitizedUsers);
  } catch (error) {
    console.error('Discovery Error:', error);
    res.status(500).json({ message: 'Error fetching discovery results' });
  }
};

exports.likeUser = async (req, res) => {
  try {
    const { targetUserId } = req.body;
    const currentUser = await User.findById(req.user.id);
    const targetUser = await User.findById(targetUserId);

    if (!targetUser) return res.status(404).json({ message: 'User not found' });

    // Prevent duplicate likes
    if (currentUser.likedUsers.includes(targetUserId)) {
      return res.status(400).json({ message: 'User already liked' });
    }

    currentUser.likedUsers.push(targetUserId);

    let isMatch = false;
    // Check for match
    if (targetUser.likedUsers.includes(currentUser._id)) {
      isMatch = true;
      if (!currentUser.matches.includes(targetUserId)) {
        currentUser.matches.push(targetUserId);
      }
      if (!targetUser.matches.includes(currentUser._id)) {
        targetUser.matches.push(currentUser._id);
        await targetUser.save();
      }
    }

    await currentUser.save();
    res.json({ message: isMatch ? "It's a Match!" : "User liked", isMatch });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.dislikeUser = async (req, res) => {
  try {
    const { targetUserId } = req.body;
    const user = await User.findById(req.user.id);

    if (!user.dislikedUsers.includes(targetUserId)) {
      user.dislikedUsers.push(targetUserId);
      await user.save();
    }

    res.json({ message: 'User disliked' });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.getHeatMap = async (req, res) => {
  try {
    // Group users by approximate location (0.01 precision ~ 1.1km)
    const clusters = await User.aggregate([
      { $match: { 'location.coordinates': { $exists: true } } },
      {
        $group: {
          _id: {
            lng: { $round: [{ $arrayElemAt: ['$location.coordinates', 0] }, 2] },
            lat: { $round: [{ $arrayElemAt: ['$location.coordinates', 1] }, 2] }
          },
          count: { $sum: 1 }
        }
      },
      { $match: { count: { $gt: 1 } } }, // Only show clusters
      { $sort: { count: -1 } }
    ]);
    res.json(clusters);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.getWingmanIcebreaker = (req, res) => {
  const { mood } = req.query;
  const prompts = {
    Playful: [
      "Your 'Teasing' mood is dangerous... what's the last thing that made you smirk like that? 😏",
      "Quick: chocolate chip or blueberry pancakes for our imaginary late-night snack? 🥞",
      "You look like trouble... am I right or do I need proof? 😉"
    ],
    Horny: [
      "Saw you're into dirty talk — guilty pleasure question: what's a word that instantly turns you on? 🔥",
      "If we were in the same room right now, where would your hands go first?",
      "What's the filthiest thought you've had today? Don't hold back..."
    ],
    Teasing: [
      "I bet I can guess your red flags in three tries. Ready to lose? 😈",
      "Are we here for flirty banter, voice notes, or straight to the good stuff?",
      "If this chat turns into a movie scene, are we slow-burn sensual or quick & rough? 😂"
    ]
  };

  const selectedPrompts = prompts[mood] || prompts.Playful;
  const randomPrompt = selectedPrompts[Math.floor(Math.random() * selectedPrompts.length)];
  res.json({ icebreaker: randomPrompt });
};
