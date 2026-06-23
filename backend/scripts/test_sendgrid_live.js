import dotenv from 'dotenv';
dotenv.config();

async function testSendGrid() {
  console.log('Sending SendGrid test email...');
  console.log('From Email:', process.env.SENDGRID_FROM_EMAIL);
  try {
    const response = await fetch('https://api.sendgrid.com/v3/mail/send', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${process.env.SENDGRID_API_KEY}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        personalizations: [
          {
            to: [{ email: 'dubasisruthishiva1335@gmail.com' }],
          },
        ],
        from: { email: process.env.SENDGRID_FROM_EMAIL },
        subject: 'My Vault — SendGrid Test',
        content: [
          {
            type: 'text/plain',
            value: 'Test email from SendGrid.',
          },
        ],
      }),
    });

    console.log('Status Code:', response.status);
    const text = await response.text();
    console.log('Response:', text);
  } catch (err) {
    console.error('Fetch error:', err);
  }
}

testSendGrid();
