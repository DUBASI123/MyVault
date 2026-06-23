import { serve } from "https://deno.land/std@0.224.0/http/server.ts";

const ACCOUNT_SID  = Deno.env.get("TWILIO_ACCOUNT_SID")!;
const AUTH_TOKEN   = Deno.env.get("TWILIO_AUTH_TOKEN")!;
const SERVICE_SID  = Deno.env.get("TWILIO_VERIFY_SERVICE_SID")!;

serve(async (req) => {
  try {
    const { to, channel } = await req.json();
    // channel: "sms" for mobile, "email" for email
    // to: "+91XXXXXXXXXX" for SMS, "user@email.com" for email

    const url = `https://verify.twilio.com/v2/Services/${SERVICE_SID}/Verifications`;
    const creds = btoa(`${ACCOUNT_SID}:${AUTH_TOKEN}`);

    const res = await fetch(url, {
      method: "POST",
      headers: {
        "Authorization": `Basic ${creds}`,
        "Content-Type": "application/x-www-form-urlencoded",
      },
      body: new URLSearchParams({ To: to, Channel: channel }),
    });

    const data = await res.json();

    if (!res.ok) {
      return new Response(
        JSON.stringify({ success: false, error: data.message }),
        { status: 400, headers: { "Content-Type": "application/json" } }
      );
    }

    return new Response(
      JSON.stringify({ success: true, status: data.status }),
      { headers: { "Content-Type": "application/json" } }
    );
  } catch (e) {
    return new Response(
      JSON.stringify({ success: false, error: String(e) }),
      { status: 500, headers: { "Content-Type": "application/json" } }
    );
  }
});
