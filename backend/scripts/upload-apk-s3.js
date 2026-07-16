import { S3Client } from '@aws-sdk/client-s3';
import { Upload } from '@aws-sdk/lib-storage';
import fs from 'fs';
import path from 'path';
import dotenv from 'dotenv';
import { fileURLToPath } from 'url';

dotenv.config();

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const s3 = new S3Client({
  region: process.env.AWS_REGION || 'eu-north-1',
  credentials: {
    accessKeyId: process.env.AWS_ACCESS_KEY_ID,
    secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY,
  },
});

async function upload() {
  const apkPath = path.join(__dirname, '../public/MyVault-release.apk');
  console.log(`Reading APK from: ${apkPath}`);
  
  if (!fs.existsSync(apkPath)) {
    console.error('Error: APK file does not exist locally. Build it first.');
    process.exit(1);
  }

  const fileStream = fs.createReadStream(apkPath);
  const fileSize = fs.statSync(apkPath).size;
  console.log(`APK Size: ${(fileSize / (1024 * 1024)).toFixed(2)} MB`);

  try {
    console.log('Initiating multipart upload to AWS S3...');
    const uploader = new Upload({
      client: s3,
      params: {
        Bucket: process.env.AWS_BUCKET_NAME || 'myvault-files',
        Key: 'downloads/MyVault-release.apk',
        Body: fileStream,
        ContentType: 'application/vnd.android.package-archive',
      },
    });

    uploader.on('httpUploadProgress', (progress) => {
      console.log(`Uploaded ${progress.loaded} of ${progress.total} bytes (${Math.round((progress.loaded / progress.total) * 100)}%)`);
    });

    const result = await uploader.done();
    console.log('✅ APK uploaded successfully via multipart upload!');
    console.log(result);
  } catch (err) {
    console.error('❌ Error uploading APK:', err);
    process.exit(1);
  }
}

upload();
