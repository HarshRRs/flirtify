const RED_FLAGS = [
  'kill', 'hate', 'stupid', 'ugly', 'scam', 'money', 'bank', 'password', 'wire', 'transfer'
];

const safetyCheck = (req, res, next) => {
  const { text } = req.body;
  
  if (text) {
    const foundFlag = RED_FLAGS.find(flag => text.toLowerCase().includes(flag));
    if (foundFlag) {
      // Logic for flagging the user or warning the system
      console.log(`[SAFETY WARNING]: Potential red-flag detected in message: "${text}"`);
      // We still let it pass for now but log it, or we could block it:
      // return res.status(400).json({ message: 'Message blocked: Potential safety violation.' });
    }
  }
  next();
};

module.exports = { safetyCheck };
