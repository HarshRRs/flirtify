const Confession = require('../models/Confession');
const User = require('../models/User');

exports.createConfession = async (req, res) => {
  try {
    const { text, isAnonymous } = req.body;
    const confession = await Confession.create({
      author: req.user.id,
      text,
      isAnonymous
    });
    res.status(201).json(confession);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.getConfessions = async (req, res) => {
  try {
    const confessions = await Confession.find().sort({ createdAt: -1 });
    res.json(confessions);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.heartConfession = async (req, res) => {
  try {
    const { confessionId } = req.params;
    const confession = await Confession.findById(confessionId);
    if (!confession) return res.status(404).json({ message: 'Confession not found' });

    if (!confession.hearts.includes(req.user.id)) {
      confession.hearts.push(req.user.id);
      await confession.save();

      // Instant Match Logic: Check if the heart-er and author both heart each other's confessions
      const authorId = confession.author;
      if (authorId.toString() !== req.user.id) {
        // Check if author has hearted any of req.user's confessions
        const otherConfession = await Confession.findOne({
          author: req.user.id,
          hearts: authorId
        });

        if (otherConfession) {
          // It's an instant match!
          const currentUser = await User.findById(req.user.id);
          const targetUser = await User.findById(authorId);

          if (!currentUser.matches.includes(authorId)) {
            currentUser.matches.push(authorId);
            targetUser.matches.push(req.user.id);
            await currentUser.save();
            await targetUser.save();
            return res.json({ message: 'Instant match from confession!', isMatch: true });
          }
        }
      }
    }
    res.json({ message: 'Confession hearted', isMatch: false });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};
