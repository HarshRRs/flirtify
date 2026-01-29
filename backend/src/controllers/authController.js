const User = require('../models/User');
const jwt = require('jsonwebtoken');
const { uploadToS3 } = require('../services/s3Service');

const generateToken = (id) => {
  return jwt.sign({ id }, process.env.JWT_SECRET, { expiresIn: '30d' });
};

/**
 * Converts Base64 string to Buffer
 * @param {String} base64Str 
 * @returns {Buffer}
 */
const base64ToBuffer = (base64Str) => {
  // Remove data:image/jpeg;base64, prefix if present
  const base64Data = base64Str.replace(/^data:.*?;base64,/, "");
  return Buffer.from(base64Data, 'base64');
};

exports.register = async (req, res) => {
  try {
    const { name, email, password, age, gender, coordinates, photos, voiceTeaser } = req.body;

    const userExists = await User.findOne({ email });
    if (userExists) return res.status(400).json({ message: 'User already exists' });

    // Process Photos: Upload to S3 if they are Base64
    const photoUrls = [];
    if (photos && Array.isArray(photos)) {
      for (const photo of photos) {
        if (photo.startsWith('data:') || photo.length > 500) { // Simple check for base64 vs URL
          try {
            const buffer = base64ToBuffer(photo);
            const url = await uploadToS3(buffer, 'image/jpeg');
            photoUrls.push(url);
          } catch (e) {
            console.error('Photo upload failed, skipping one photo.');
          }
        } else {
          photoUrls.push(photo);
        }
      }
    }

    // Process Voice Teaser
    let voiceUrl = voiceTeaser;
    if (voiceTeaser && (voiceTeaser.startsWith('data:') || voiceTeaser.length > 1000)) {
      try {
        const buffer = base64ToBuffer(voiceTeaser);
        voiceUrl = await uploadToS3(buffer, 'audio/mpeg');
      } catch (e) {
        console.error('Voice teaser upload failed.');
      }
    }

    const user = await User.create({
      name,
      email,
      password,
      age,
      gender,
      photos: photoUrls,
      voiceTeaser: voiceUrl,
      location: {
        type: 'Point',
        coordinates: coordinates || [0, 0]
      }
    });

    res.status(201).json({
      _id: user._id,
      name: user.name,
      email: user.email,
      token: generateToken(user._id)
    });
  } catch (error) {
    console.error('Registration Error:', error);
    res.status(500).json({ message: error.message });
  }
};

exports.login = async (req, res) => {
  try {
    const { email, password } = req.body;
    const user = await User.findOne({ email }).select('+password');

    if (user && (await user.comparePassword(password))) {
      res.json({
        _id: user._id,
        name: user.name,
        email: user.email,
        token: generateToken(user._id)
      });
    } else {
      res.status(401).json({ message: 'Invalid email or password' });
    }
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};
