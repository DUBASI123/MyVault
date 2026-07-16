import { createClient } from '@supabase/supabase-js';

// IMPORTANT: SUPABASE_SERVICE_ROLE_KEY must NEVER be exposed to the Flutter
// app or committed to source control. It bypasses all RLS and auth checks.
// Set it only in your backend's .env / PM2 env.
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

/**
 * Links a phone number to an existing Supabase Auth user and marks it
 * confirmed immediately (phone_confirm: true), so the number becomes a
 * valid OTP target for signInWithOtp({ phone }) without the user having
 * to go through a separate phone-verification OTP at registration time.
 */
export async function linkAndConfirmPhone(userId, phoneE164) {
  if (!process.env.SUPABASE_SERVICE_ROLE_KEY) {
    console.warn('⚠️ Warning: SUPABASE_SERVICE_ROLE_KEY is missing in backend env. Skipping linkAndConfirmPhone.');
    return { phone: phoneE164 };
  }
  const { data, error } = await supabaseAdmin.auth.admin.updateUserById(userId, {
    phone: phoneE164,
    phone_confirm: true,
  });
  if (error) throw error;
  return data.user;
}

export default supabaseAdmin;
