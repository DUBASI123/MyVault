import { v2 as cloudinary } from 'cloudinary';
import path from 'path';

export async function uploadBuffer(buffer, originalName) {
  if (!process.env.CLOUDINARY_URL) {
    throw new Error('CLOUDINARY_URL is not configured on the server.');
  }
  
  return new Promise((resolve, reject) => {
    const uploadStream = cloudinary.uploader.upload_stream(
      {
        resource_type: 'auto',
        folder: 'myvault_uploads',
      },
      (error, result) => {
        if (error) return reject(error);
        resolve(result.secure_url);
      }
    );
    
    uploadStream.end(buffer);
  });
}
