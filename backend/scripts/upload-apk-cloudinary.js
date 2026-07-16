import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

async function run() {
  const apkPath = path.join(__dirname, '../public/MyVault-release.apk');
  if (!fs.existsSync(apkPath)) {
    console.error('Local APK file not found.');
    return;
  }
  
  const fileSize = fs.statSync(apkPath).size;
  console.log(`APK Size: ${(fileSize / (1024*1024)).toFixed(2)} MB`);
  
  console.log('Uploading APK to Cloudinary (unsigned preset)...');

  // Prepare FormData
  const formData = new FormData();
  formData.append('upload_preset', 'myvault_unsigned');
  
  // Create Blob from file buffer
  const fileBuffer = fs.readFileSync(apkPath);
  const fileBlob = new Blob([fileBuffer], { type: 'application/vnd.android.package-archive' });
  formData.append('file', fileBlob, 'MyVault-release.apk');

  try {
    const res = await fetch('https://api.cloudinary.com/v1_1/dtdb4irno/raw/upload', {
      method: 'POST',
      body: formData
    });
    
    const data = await res.json();
    console.log('Cloudinary response:', data);
    
    if (res.ok && data.secure_url) {
      console.log(`\n🎉 Success! Cloudinary Public APK URL: ${data.secure_url}\n`);
    } else {
      console.error('❌ Cloudinary upload failed:', data.error?.message || data);
    }
  } catch (err) {
    console.error('❌ Error during Cloudinary upload:', err);
  }
}

run();
