const { RtcTokenBuilder, RtcRole } = require('agora-token');

exports.generateToken = async (req, res) => {
  const { channelName, role } = req.query;
  const appId = process.env.AGORA_APP_ID;
  const appCertificate = process.env.AGORA_APP_CERTIFICATE;

  if (!channelName) {
    return res.status(400).json({ message: 'Channel name is required' });
  }

  // Set default role to subscriber
  let agoraRole = RtcRole.SUBSCRIBER;
  if (role === 'publisher') {
    agoraRole = RtcRole.PUBLISHER;
  }

  // Token expires in 1 hour
  const expirationTimeInSeconds = 3600;
  const currentTimestamp = Math.floor(Date.now() / 1000);
  const privilegeExpiredTs = currentTimestamp + expirationTimeInSeconds;

  // Build the token
  try {
    const token = RtcTokenBuilder.buildTokenWithUid(
      appId,
      appCertificate,
      channelName,
      0, // uid 0 means the server generates one
      agoraRole,
      privilegeExpiredTs
    );
    res.json({ token, appId });
  } catch (error) {
    res.status(500).json({ message: 'Error generating token' });
  }
};
