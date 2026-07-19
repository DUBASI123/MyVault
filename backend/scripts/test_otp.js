import { createClient } from '@supabase/supabase-js';

const supabase = createClient(
  "https://oawomrlsitttrbulxgyk.supabase.co",
  "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9hd29tcmxzaXR0dHJidWx4Z3lrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODE4NDk3NzQsImV4cCI6MjA5NzQyNTc3NH0.j3rs7JlIZiRXxsw67GVLbQsKGpOUP_758PuIbGnYzig"
);

async function test() {
  console.log('Sending OTP to +917569495637...');
  const { data, error } = await supabase.auth.signInWithOtp({
    phone: '+917569495637',
    shouldCreateUser: false
  });

  if (error) {
    console.error('❌ OTP failed with error:', error.message);
  } else {
    console.log('✅ OTP sent successfully! Data:', data);
  }
}

test();
