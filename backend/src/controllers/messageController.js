const Message = require('../models/Message');

exports.sendMessage = async (req, res) => {
  try {
    const { receiverId, text, imageUrl, videoUrl, type } = req.body;
    const message = await Message.create({
      sender: req.user.id,
      receiver: receiverId,
      text,
      imageUrl,
      videoUrl,
      type: type || 'text'
    });
    res.status(201).json(message);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.getMessages = async (req, res) => {
  try {
    const { otherUserId } = req.params;
    const messages = await Message.find({
      $or: [
        { sender: req.user.id, receiver: otherUserId },
        { sender: otherUserId, receiver: req.user.id }
      ]
    }).sort({ timestamp: 1 });
    res.json(messages);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};
