import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const SUPABASE_URL = 'https://oawomrlsitttrbulxgyk.supabase.co';
const SUPABASE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9hd29tcmxzaXR0dHJidWx4Z3lrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODE4NDk3NzQsImV4cCI6MjA5NzQyNTc3NH0.j3rs7JlIZiRXxsw67GVLbQsKGpOUP_758PuIbGnYzig';

async function run() {
  const bucketId = 'downloads';
  
  // 1. Try to create the bucket
  console.log(`Creating bucket "${bucketId}"...`);
  const createRes = await fetch(`${SUPABASE_URL}/storage/v1/bucket`, {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${SUPABASE_KEY}`,
      'apikey': SUPABASE_KEY,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({
      id: bucketId,
      name: bucketId,
      public: true,
      file_size_limit: 104857600, // 100MB
    })
  });
  const createData = await createRes.json();
  console.log('Create Bucket result:', createData);

  // 2. Upload the APK
  const apkPath = path.join(__dirname, '../public/MyVault-release.apk');
  if (!fs.existsSync(apkPath)) {
    console.error('Local APK file not found.');
    return;
  }
  
  const fileBuffer = fs.readFileSync(apkPath);
  console.log(`Uploading APK (${(fileBuffer.length / (1024*1024)).toFixed(2)} MB) to Supabase Storage...`);
  
  const uploadRes = await fetch(`${SUPABASE_URL}/storage/v1/object/${bucketId}/MyVault-release.apk`, {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${SUPABASE_KEY}`,
      'apikey': SUPABASE_KEY,
      'Content-Type': 'application/vnd.android.package-archive',
      'x-upsert': 'true'
    },
    body: fileBuffer
  });
  
  const uploadData = await uploadRes.json();
  console.log('Upload result:', uploadData);

  if (uploadRes.ok) {
    const publicUrl = `${SUPABASE_URL}/storage/v1/object/public/${bucketId}/MyVault-release.apk`;
    console.log(`\n🎉 Success! Public APK URL: ${publicUrl}\n`);
  }
}

run();
