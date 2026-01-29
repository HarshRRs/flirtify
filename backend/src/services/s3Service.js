const { S3Client, PutObjectCommand } = require('@aws-sdk/client-s3');
const crypto = require('crypto');

const s3Client = new S3Client({
    region: process.env.AWS_REGION,
    credentials: {
        accessKeyId: process.env.AWS_ACCESS_KEY_ID,
        secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY,
    },
});

/**
 * Uploads a file buffer to AWS S3
 * @param {Buffer} fileBuffer The file content
 * @param {String} mimeType The file mime type
 * @returns {Promise<String>} The public URL of the uploaded file
 */
exports.uploadToS3 = async (fileBuffer, mimeType) => {
    if (!process.env.AWS_ACCESS_KEY_ID || !process.env.AWS_S3_BUCKET_NAME) {
        console.warn('AWS Credentials missing. Returning mock URL.');
        return `https://images.unsplash.com/photo-1524504388940-b1c1722653e1?q=80&w=2000`; // Placeholder
    }

    const fileExtension = mimeType.split('/')[1];
    const fileName = `${crypto.randomBytes(16).toString('hex')}.${fileExtension}`;

    const params = {
        Bucket: process.env.AWS_S3_BUCKET_NAME,
        Key: `profiles/${fileName}`,
        Body: fileBuffer,
        ContentType: mimeType,
        // Add ACL: 'public-read' if your bucket policy requires it, 
        // but usually it's handled via Bucket Policy for world-class apps.
    };

    try {
        await s3Client.send(new PutObjectCommand(params));
        return `https://${process.env.AWS_S3_BUCKET_NAME}.s3.${process.env.AWS_REGION}.amazonaws.com/profiles/${fileName}`;
    } catch (error) {
        console.error('S3 Upload Error:', error);
        throw new Error('Failed to upload to cloud storage');
    }
};
