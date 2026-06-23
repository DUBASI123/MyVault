/**
 * Verifies all backend tools are live and responding.
 * Run: npm run verify:live
 */
const BASE = process.env.API_BASE_URL || 'http://localhost:5000/api';

async function request(method, path, body) {
  const res = await fetch(`${BASE}${path}`, {
    method,
    headers: body ? { 'Content-Type': 'application/json' } : undefined,
    body: body ? JSON.stringify(body) : undefined,
  });
  const text = await res.text();
  let data;
  try {
    data = JSON.parse(text);
  } catch {
    data = text;
  }
  return { ok: res.ok, status: res.status, data };
}

function pass(label, detail = '') {
  console.log(`  ✓ ${label}${detail ? ` — ${detail}` : ''}`);
  return true;
}

function fail(label, detail = '') {
  console.log(`  ✗ ${label}${detail ? ` — ${detail}` : ''}`);
  return false;
}

async function main() {
  console.log(`\nMy Vault — Live Backend Verification`);
  console.log(`Target: ${BASE}\n`);

  let score = 0;
  let total = 0;

  // 1. Health
  total++;
  const health = await request('GET', '/health');
  if (health.ok && health.data?.status === 'ok') {
    score += pass('Health', health.data.service);
  } else {
    fail('Health', `HTTP ${health.status}`);
    console.log('\nStart server: npm run dev\n');
    process.exit(1);
  }

  // 2. Live status (all tools)
  total++;
  const live = await request('GET', '/health/live');
  if (live.ok && live.data?.status === 'live') {
    const c = live.data.tools?.database?.counts || {};
    score += pass(
      'Live status',
      `DB ${live.data.tools.database.provider} — ${c.universities} unis, ${c.colleges} colleges, ${c.subjects} subjects`,
    );
  } else {
    fail('Live status', live.data?.tools?.database?.error || `HTTP ${live.status}`);
  }

  // 3. Master data
  total++;
  const unis = await request('GET', '/master/universities');
  if (unis.ok && Array.isArray(unis.data) && unis.data.length > 0) {
    score += pass('Master — universities', `${unis.data.length} loaded`);
  } else fail('Master — universities');

  total++;
  const uniId = unis.data?.[0]?.id;
  const cols = await request('GET', `/master/colleges?universityId=${uniId}`);
  if (cols.ok && Array.isArray(cols.data) && cols.data.length > 0) {
    score += pass('Master — colleges', `${cols.data.length} for ${unis.data[0].name}`);
  } else fail('Master — colleges');

  // 4. Content tools
  total++;
  const ticker = await request('GET', '/content/ticker');
  if (ticker.ok && ticker.data?.ticker) {
    score += pass('Content — ticker', ticker.data.ticker.slice(0, 50) + '...');
  } else fail('Content — ticker');

  total++;
  const notifs = await request('GET', '/content/notifications');
  if (notifs.ok && Array.isArray(notifs.data) && notifs.data.length > 0) {
    score += pass('Content — notifications', `${notifs.data.length} items`);
  } else fail('Content — notifications');

  total++;
  const results = await request('GET', '/content/results?branch=CSE');
  if (results.ok && Array.isArray(results.data) && results.data.length > 0) {
    score += pass('Content — results', `${results.data.length} subjects`);
  } else fail('Content — results');

  total++;
  const internships = await request('GET', '/content/internships?type=IT');
  if (internships.ok && Array.isArray(internships.data) && internships.data.length > 0) {
    score += pass('Content — internships', `${internships.data.length} IT listings`);
  } else fail('Content — internships');

  // 5. Academic
  total++;
  const subjects = await request('GET', '/academic/subjects?branch=CSE&semester=3');
  if (subjects.ok && Array.isArray(subjects.data) && subjects.data.length > 0) {
    score += pass('Academic — subjects', subjects.data.map((s) => s.name).join(', '));
  } else fail('Academic — subjects');

  // 6. Auth OTP flow (real API, dev preview OTP)
  total++;
  const testEmail = `verify-${Date.now()}@myvault.test`;
  const sendOtp = await request('POST', '/auth/send-otp', {
    target: testEmail,
    purpose: 'register',
  });
  const otp = sendOtp.data?.otpPreview;
  if (sendOtp.ok && otp) {
    score += pass('Auth — send OTP', `dev preview ${otp}`);
  } else if (sendOtp.ok) {
    score += pass('Auth — send OTP', 'sent (production mode, no preview)');
  } else {
    fail('Auth — send OTP', sendOtp.data?.error || `HTTP ${sendOtp.status}`);
  }

  if (otp) {
    total++;
    const verifyOtp = await request('POST', '/auth/verify-otp', {
      target: testEmail,
      otp,
      purpose: 'register',
    });
    if (verifyOtp.ok && verifyOtp.data?.verified) {
      score += pass('Auth — verify OTP', 'verified');
    } else {
      fail('Auth — verify OTP', verifyOtp.data?.error || `HTTP ${verifyOtp.status}`);
    }
  }

  // 7. OTP delivery tools status
  total++;
  const otpTools = live.data?.tools?.otp;
  if (otpTools?.devPreview) {
    score += pass('OTP tools', 'dev preview active (add FAST2SMS/SMTP for real SMS/email)');
  } else if (otpTools?.sms?.configured || otpTools?.email?.configured) {
    score += pass('OTP tools', `SMS:${otpTools.sms.configured} Email:${otpTools.email.configured}`);
  } else {
    fail('OTP tools', 'no SMS/email provider configured');
  }

  console.log(`\nResult: ${score}/${total} checks passed`);
  if (score === total) {
    console.log('All backend tools are LIVE and verified.\n');
    process.exit(0);
  } else {
    console.log('Some checks failed — review output above.\n');
    process.exit(1);
  }
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
