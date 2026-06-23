import twilio from 'twilio';
import dotenv from 'dotenv';

dotenv.config();

const client = twilio(
  process.env.TWILIO_ACCOUNT_SID,
  process.env.TWILIO_AUTH_TOKEN
);

async function test() {
  console.log('Sending Twilio test SMS...');
  console.log('Account SID:', process.env.TWILIO_ACCOUNT_SID);
  console.log('From:', process.env.TWILIO_PHONE_NUMBER);
  try {
    const message = await client.messages.create({
      body: 'Test OTP from My Vault backend',
      from: process.env.TWILIO_PHONE_NUMBER,
      to: '+917569495637'
    });
    console.log('SUCCESS:', message.sid);
  } catch (err) {
    console.error('ERROR:', err);
  }
}

test();
