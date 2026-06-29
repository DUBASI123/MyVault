// insert_colleges.mjs — inserts colleges using real university IDs from live Supabase
import https from 'node:https';

const SUPABASE_URL      = 'oawomrlsitttrbulxgyk.supabase.co';
const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9hd29tcmxzaXR0dHJidWx4Z3lrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODE4NDk3NzQsImV4cCI6MjA5NzQyNTc3NH0.j3rs7JlIZiRXxsw67GVLbQsKGpOUP_758PuIbGnYzig';

function request(method, path, body) {
  return new Promise((resolve, reject) => {
    const data = body ? JSON.stringify(body) : null;
    const options = {
      hostname: SUPABASE_URL,
      path: `/rest/v1/${path}`,
      method,
      headers: {
        'apikey': SUPABASE_ANON_KEY,
        'Authorization': `Bearer ${SUPABASE_ANON_KEY}`,
        'Content-Type': 'application/json',
        ...(method === 'POST' ? { 'Prefer': 'resolution=merge-duplicates,return=representation' } : {}),
        ...(data ? { 'Content-Length': Buffer.byteLength(data) } : {}),
      },
    };
    const req = https.request(options, (res) => {
      let raw = '';
      res.on('data', chunk => raw += chunk);
      res.on('end', () => resolve({ status: res.statusCode, body: raw }));
    });
    req.on('error', reject);
    if (data) req.write(data);
    req.end();
  });
}

// Step 1: fetch real university IDs
const uniRes = await request('GET', 'universities?select=id,code');
const unis = JSON.parse(uniRes.body);
const uniMap = {};
unis.forEach(u => uniMap[u.code] = u.id);

console.log('\n📚 University IDs fetched:', uniMap);

// Step 2: build colleges with correct university_id values
const colleges = [
  { university_id: uniMap['National'], name: 'NIT Warangal',                                 code: 'NITW',  district: 'Hanamkonda', type: 'National Institute', state: 'Telangana' },
  { university_id: uniMap['KU'],       name: 'KITS Warangal',                                code: 'KW',    district: 'Hanamkonda', type: 'Private',            state: 'Telangana' },
  { university_id: uniMap['KU'],       name: 'Vaagdevi College of Engineering',              code: 'VCE',   district: 'Warangal',   type: 'Private',            state: 'Telangana' },
  { university_id: uniMap['National'], name: 'SR University',                                code: 'SRU',   district: 'Hanamkonda', type: 'Deemed University',  state: 'Telangana' },
  { university_id: uniMap['JNTUH'],    name: 'SVS Group of Institutions',                    code: 'SVS',   district: 'Hanamkonda', type: 'Private',            state: 'Telangana' },
  { university_id: uniMap['JNTUH'],    name: 'Talla Padmavathi College of Engineering',     code: 'TPCE',  district: 'Kazipet',    type: 'Private',            state: 'Telangana' },
  { university_id: uniMap['JNTUH'],    name: 'Chaitanya Institute of Technology and Science',code: 'CITS',  district: 'Hanamkonda', type: 'Private',            state: 'Telangana' },
  { university_id: uniMap['JNTUH'],    name: 'Ramappa Engineering College',                  code: 'REC',   district: 'Hanamkonda', type: 'Private',            state: 'Telangana' },
  { university_id: uniMap['JNTUH'],    name: 'Balaji Institute of Technology and Science',   code: 'BITS',  district: 'Narsampet',  type: 'Private',            state: 'Telangana' },
  { university_id: uniMap['KU'],       name: 'Warangal Institute of Technology and Science', code: 'WITS',  district: 'Warangal',   type: 'Private',            state: 'Telangana' },
];

console.log(`\n⬆️  Inserting ${colleges.length} colleges…\n`);

// Step 3: insert
const res = await request('POST', 'colleges', colleges);

if (res.status === 200 || res.status === 201) {
  const data = JSON.parse(res.body);
  console.log(`✅ Success! ${data.length} colleges inserted:\n`);
  data.forEach(c => console.log(`   • ${c.name} (${c.code}) — ${c.district}`));
} else {
  console.error(`❌ HTTP ${res.status}:`, res.body);
  console.log('\n⚠️  RLS is blocking insert. Run this SQL in Supabase Dashboard → SQL Editor:\n');
  console.log(`INSERT INTO colleges (university_id, name, code, district, type, state) VALUES`);
  colleges.forEach((c, i) => {
    const comma = i < colleges.length - 1 ? ',' : ';';
    console.log(`  ('${c.university_id}', '${c.name}', '${c.code}', '${c.district}', '${c.type}', '${c.state}')${comma}`);
  });
}
