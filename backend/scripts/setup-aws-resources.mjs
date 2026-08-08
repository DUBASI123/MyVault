import {
  S3Client,
  CreateBucketCommand,
  PutBucketCorsCommand,
  HeadBucketCommand,
} from '@aws-sdk/client-s3';
import dotenv from 'dotenv';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

dotenv.config({ path: path.join(__dirname, '..', '.env') });

const region = process.env.AWS_REGION || 'ap-south-1';
const bucketName = process.env.AWS_BUCKET_NAME || 'myvault-study-materials';
const accessKeyId = process.env.AWS_ACCESS_KEY_ID;
const secretAccessKey = process.env.AWS_SECRET_ACCESS_KEY;

if (!accessKeyId || !secretAccessKey) {
  console.error('❌ AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY must be set in backend/.env');
  process.exit(1);
}

const s3 = new S3Client({
  region,
  credentials: { accessKeyId, secretAccessKey },
});

async function main() {
  console.log(`🚀 Checking AWS S3 Bucket: ${bucketName} in region ${region}...`);

  // 1. Check or Create Bucket
  try {
    await s3.send(new HeadBucketCommand({ Bucket: bucketName }));
    console.log(`✅ Bucket "${bucketName}" exists and is accessible.`);
  } catch (err) {
    if (err.name === 'NotFound' || err.$metadata?.httpStatusCode === 404) {
      console.log(`🔨 Bucket "${bucketName}" does not exist. Creating bucket...`);
      await s3.send(
        new CreateBucketCommand({
          Bucket: bucketName,
          ...(region !== 'us-east-1' && {
            CreateBucketConfiguration: { LocationConstraint: region },
          }),
        })
      );
      console.log(`🎉 Bucket "${bucketName}" created successfully!`);
    } else {
      console.error(`⚠️ Error checking bucket:`, err.message);
    }
  }

  // 2. Apply S3 CORS Configuration for Direct Web & Mobile Uploads
  console.log(`⚙️  Applying S3 CORS policy to "${bucketName}"...`);
  try {
    await s3.send(
      new PutBucketCorsCommand({
        Bucket: bucketName,
        CORSConfiguration: {
          CORSRules: [
            {
              AllowedHeaders: ['*'],
              AllowedMethods: ['GET', 'PUT', 'POST', 'DELETE', 'HEAD'],
              AllowedOrigins: ['*'],
              ExposeHeaders: [
                'ETag',
                'Content-Length',
                'Content-Type',
                'x-amz-request-id',
                'x-amz-id-2',
              ],
              MaxAgeSeconds: 3600,
            },
          ],
        },
      })
    );
    console.log(`✅ S3 CORS policy applied successfully! Web browser direct uploads are now enabled.`);
  } catch (err) {
    console.error(`❌ Failed to set CORS policy:`, err.message);
  }

  console.log(`\n🎉 AWS S3 Setup Complete! Bucket "${bucketName}" is ready for website & app uploads.`);
}

main();
