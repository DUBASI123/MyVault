// Using built-in fetch

const SUPABASE_URL = 'https://oawomrlsitttrbulxgyk.supabase.co';
const SUPABASE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9hd29tcmxzaXR0dHJidWx4Z3lrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODE4NDk3NzQsImV4cCI6MjA5NzQyNTc3NH0.j3rs7JlIZiRXxsw67GVLbQsKGpOUP_758PuIbGnYzig';

async function list() {
  const res = await fetch(`${SUPABASE_URL}/storage/v1/bucket`, {
    headers: {
      'Authorization': `Bearer ${SUPABASE_KEY}`,
      'apikey': SUPABASE_KEY
    }
  });
  const data = await res.json();
  console.log('Buckets:', data);
}

list();
