const url = "https://oawomrlsitttrbulxgyk.supabase.co/rest/v1/internship_courses?select=*";
const anonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9hd29tcmxzaXR0dHJidWx4Z3lrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODE4NDk3NzQsImV4cCI6MjA5NzQyNTc3NH0.j3rs7JlIZiRXxsw67GVLbQsKGpOUP_758PuIbGnYzig";

async function main() {
  console.log("Fetching from Supabase REST API...");
  const res = await fetch(url, {
    headers: {
      "apikey": anonKey,
      "Authorization": `Bearer ${anonKey}`
    }
  });
  
  const text = await res.text();
  console.log(`Status code: ${res.status}`);
  try {
    const json = JSON.parse(text);
    if (Array.isArray(json)) {
      console.log(`✅ Success! Received ${json.length} courses from Supabase Rest API!`);
      console.log(`Sample course title: ${json[0]?.title}`);
    } else {
      console.log("❌ Error response:", json);
    }
  } catch {
    console.log("❌ Response text:", text);
  }
}

main().catch(console.error);
