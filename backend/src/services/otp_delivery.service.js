import twilio from 'twilio';
import nodemailer from 'nodemailer';

/**
 * Sends live SMS OTP via Twilio (global) or Fast2SMS (India).
 */
export async function sendLiveOtpSms(phone, otp) {
  const message = `My Vault: Your verification code is ${otp}. Valid for 10 minutes.`;

  if (process.env.TWILIO_ACCOUNT_SID && process.env.TWILIO_AUTH_TOKEN) {
    const client = twilio(
      process.env.TWILIO_ACCOUNT_SID,
      process.env.TWILIO_AUTH_TOKEN,
    );
    await client.messages.create({
      body: message,
      from: process.env.TWILIO_PHONE_NUMBER,
      to: phone.startsWith('+') ? phone : `+91${phone.replace(/\D/g, '').slice(-10)}`,
    });
    return { channel: 'twilio' };
  }

  if (process.env.FAST2SMS_API_KEY) {
    const mobile = phone.replace(/\D/g, '').slice(-10);
    const res = await fetch('https://www.fast2sms.com/dev/bulkV2', {
      method: 'POST',
      headers: {
        authorization: process.env.FAST2SMS_API_KEY,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        route: 'otp',
        variables_values: otp,
        numbers: mobile,
      }),
    });
    const data = await res.json();
    if (!data.return && data.status_code !== 200) {
      throw new Error(data.message || 'Fast2SMS failed');
    }
    return { channel: 'fast2sms' };
  }

  throw new Error(
    'SMS not configured. Set TWILIO_* or FAST2SMS_API_KEY in backend .env',
  );
}

export async function sendLiveOtpEmail(email, otp) {
  if (process.env.SENDGRID_API_KEY) {
    const fromEmail = process.env.SENDGRID_FROM_EMAIL || process.env.SMTP_FROM || 'no-reply@stuvault.com';
    const response = await fetch('https://api.sendgrid.com/v3/mail/send', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${process.env.SENDGRID_API_KEY}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        personalizations: [
          {
            to: [{ email }],
          },
        ],
        from: { email: fromEmail },
        subject: 'My Vault — Verification Code',
        content: [
          {
            type: 'text/plain',
            value: `Your My Vault verification code is ${otp}. Valid for 10 minutes.`,
          },
        ],
      }),
    });

    if (!response.ok) {
      const errText = await response.text();
      throw new Error(`SendGrid API error: ${response.status} - ${errText}`);
    }

    return { channel: 'sendgrid' };
  }

  if (!process.env.SMTP_HOST || !process.env.SMTP_USER) {
    throw new Error('Email OTP not configured. Set SENDGRID_API_KEY or SMTP_* in backend .env');
  }

  const transport = nodemailer.createTransport({
    host: process.env.SMTP_HOST,
    port: Number(process.env.SMTP_PORT || 587),
    secure: process.env.SMTP_SECURE === 'true',
    auth: {
      user: process.env.SMTP_USER,
      pass: process.env.SMTP_PASS,
    },
  });

  await transport.sendMail({
    from: process.env.SMTP_FROM || process.env.SMTP_USER,
    to: email,
    subject: 'My Vault — Verification Code',
    text: `Your My Vault verification code is ${otp}. Valid for 10 minutes.`,
  });

  return { channel: 'smtp' };
}
