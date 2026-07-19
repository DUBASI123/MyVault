async function main() {
  console.log("Hiting live endpoint: POST https://myvault-jbd7.onrender.com/api/auth/login/verify-otp");
  
  try {
    const res = await fetch('https://myvault-jbd7.onrender.com/api/auth/login/verify-otp', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        studentId: 'test-id',
        otp: '123456'
      })
    });
    
    console.log("Status:", res.status);
    console.log("Headers:", Object.fromEntries(res.headers.entries()));
    const text = await res.text();
    console.log("Body Snippet:", text.substring(0, 1000));
  } catch (err) {
    console.error("Error:", err);
  }
}

main();
