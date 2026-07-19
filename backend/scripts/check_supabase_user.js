import { createClient } from '@supabase/supabase-js';

const supabaseAdmin = createClient(
  "https://oawomrlsitttrbulxgyk.supabase.co",
  "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9hd29tcmxzaXR0dHJidWx4Z3lrIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc4MTg0OTc3NCwiZXhwIjoyMDk3NDI1Nzc0fQ.ywlapYJ9sx4n0M80uYW4yFUCkBzPWfjRAMDS7JaU7TU",
  {
    auth: {
      autoRefreshToken: false,
      persistSession: false,
    },
  },
);

async function check() {
  const { data: { users }, error } = await supabaseAdmin.auth.admin.listUsers();
  if (error) {
    console.error('Error listing users:', error);
    return;
  }

  console.log(`Found ${users.length} users in Supabase Auth:`);
  for (const user of users) {
    console.log(`- ID: ${user.id}, Email: ${user.email}, Phone: ${user.phone}, Phone Confirmed: ${user.phone_confirmed}`);
  }
}

check();
