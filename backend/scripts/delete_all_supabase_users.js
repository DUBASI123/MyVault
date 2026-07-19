import { createClient } from '@supabase/supabase-js';
import dotenv from 'dotenv';
dotenv.config();

const supabaseAdmin = createClient(
  process.env.SUPABASE_URL || 'https://oawomrlsitttrbulxgyk.supabase.co',
  process.env.SUPABASE_SERVICE_ROLE_KEY || '',
  {
    auth: {
      autoRefreshToken: false,
      persistSession: false,
    },
  },
);

async function main() {
  console.log('--- DELETING ALL SUPABASE AUTH USERS ---');
  if (!process.env.SUPABASE_SERVICE_ROLE_KEY) {
    console.error('Error: SUPABASE_SERVICE_ROLE_KEY is missing.');
    return;
  }

  const { data: { users }, error: listError } = await supabaseAdmin.auth.admin.listUsers();
  if (listError) {
    throw listError;
  }

  console.log(`Found ${users.length} users to delete.`);

  for (const user of users) {
    console.log(`Deleting user: ${user.email || user.phone} (${user.id})...`);
    const { error: deleteError } = await supabaseAdmin.auth.admin.deleteUser(user.id);
    if (deleteError) {
      console.error(`Failed to delete user ${user.id}:`, deleteError);
    } else {
      console.log(`Deleted user ${user.id} successfully.`);
    }
  }
}

main().catch(err => console.error(err));
