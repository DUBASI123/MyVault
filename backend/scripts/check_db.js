async function testPostgrest() {
  const url = "https://oawomrlsitttrbulxgyk.supabase.co/rest/v1/students?select=*";
  const anonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9hd29tcmxzaXR0dHJidWx4Z3lrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODE4NDk3NzQsImV4cCI6MjA5NzQyNTc3NH0.j3rs7JlIZiRXxsw67GVLbQsKGpOUP_758PuIbGnYzig";
  
  try {
    const res = await fetch(url, {
      headers: {
        "apikey": anonKey,
        "Authorization": `Bearer ${anonKey}`
      }
    });
    console.log("Status:", res.status);
    const data = await res.json();
    console.log("Data:", data);
  } catch (err) {
    console.error("Error:", err);
  }
}
testPostgrest();
