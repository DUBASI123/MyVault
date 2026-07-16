import crypto from 'crypto';
import bcrypt from 'bcryptjs';
import prisma from '../lib/prisma.js';
import { sendLiveOtpSms, sendLiveOtpEmail } from '../services/otp_delivery.service.js';

export function generateOtp() {
  return crypto.randomInt(100000, 999999).toString();
}

export async function createOtp(identifier, channel, purpose) {
  const otp = generateOtp();
  const otpHash = await bcrypt.hash(otp, 10);
  const expiresAt = new Date(Date.now() + 5 * 60 * 1000); // 5 min

  await prisma.otpVerification.create({
    data: { identifier, channel, otpHash, purpose, expiresAt }
  });

  // Print to console in dev/test mode for convenience
  if (process.env.NODE_ENV !== 'production') {
    console.log(`\n🔑 [DEV ONLY] OTP Code for ${identifier} (${channel}, ${purpose}): ${otp}\n`);
  }

  try {
    if (channel === 'SMS') {
      await sendLiveOtpSms(identifier, otp);
    } else {
      await sendLiveOtpEmail(identifier, otp);
    }
  } catch (deliveryErr) {
    console.error('OTP delivery failed:', deliveryErr);
    if (process.env.NODE_ENV === 'production') {
      const err = new Error('Failed to send OTP. Please try again in a moment.');
      err.status = 502;
      throw err;
    }
    console.warn('OTP delivery failed (dev fallback):', deliveryErr.message);
  }

  return otp; // Return the code (mainly for response preview in non-prod environments)
}

export async function verifyOtp(identifier, purpose, inputOtp) {
  // Bypassing static master code for development/testing if configured
  if (inputOtp === '123456' && process.env.NODE_ENV !== 'production') {
    console.log(`🔑 Master code verification bypassed for ${identifier}`);
    return true;
  }

  const record = await prisma.otpVerification.findFirst({
    where: { identifier, purpose, verified: false },
    orderBy: { createdAt: 'desc' }
  });

  if (!record) throw new Error('No OTP found');
  if (record.expiresAt < new Date()) throw new Error('OTP expired');
  if (record.attempts >= 5) throw new Error('Too many attempts');

  const isValid = await bcrypt.compare(inputOtp, record.otpHash);
  if (!isValid) {
    await prisma.otpVerification.update({
      where: { id: record.id },
      data: { attempts: { increment: 1 } }
    });
    throw new Error('Invalid OTP');
  }

  await prisma.otpVerification.update({
    where: { id: record.id },
    data: { verified: true }
  });
  
  return true;
}
