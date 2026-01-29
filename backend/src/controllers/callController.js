const crypto = require('crypto');

/**
 * Generates a unique, secure room name for Jitsi Meet.
 * This ensures "Free Forever" calling for Flirtify users.
 */
exports.generateCallRoom = async (req, res) => {
  try {
    const { receiverId } = req.query;
    const senderId = req.user._id;

    if (!receiverId) {
      return res.status(400).json({ message: 'Receiver ID is required' });
    }

    // Generate a secure, unique room name derived from both user IDs
    // We sort IDs to ensure both users get the same room name
    const ids = [senderId.toString(), receiverId.toString()].sort();
    const combined = ids.join('_');
    const roomName = `flirtify_${crypto.createHash('md5').update(combined).digest('hex')}`;

    res.json({
      roomName,
      serverUrl: 'https://meet.jit.si', // Using public secure bridge
      subject: 'Flirtify Private Call'
    });
  } catch (error) {
    console.error('Jitsi Room Error:', error);
    res.status(500).json({ message: 'Error establishing call room' });
  }
};
