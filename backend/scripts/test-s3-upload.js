import { S3Client, ListObjectsV2Command } from '@aws-sdk/client-s3';
import dotenv from 'dotenv';

dotenv.config();

const s3 = new S3Client({
  region: process.env.AWS_REGION || 'eu-north-1',
  credentials: {
    accessKeyId: process.env.AWS_ACCESS_KEY_ID,
    secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY,
  },
});

async function run() {
  try {
    const data = await s3.send(new ListObjectsV2Command({
      Bucket: process.env.AWS_BUCKET_NAME || 'myvault-files',
      MaxKeys: 5
    }));
    console.log('S3 Connection Successful! Objects:', data.Contents);
  } catch (err) {
    console.error('S3 Connection Failed:', err);
  }
}

run();
