import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const supabase    = createClient(Deno.env.get("SUPABASE_URL")!, Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!);
const RESEND_KEY  = Deno.env.get("RESEND_API_KEY")!;
const RESEND_FROM = Deno.env.get("RESEND_FROM_EMAIL") ?? "MyVault <noreply@resend.dev>";

async function sendEmail(to: string, subject: string, html: string) {
  await fetch("https://api.resend.com/emails", {
    method: "POST",
    headers: { Authorization: `Bearer ${RESEND_KEY}`, "Content-Type": "application/json" },
    body: JSON.stringify({ from: RESEND_FROM, to: [to], subject, html }),
  });
}

serve(async (req) => {
  try {
    const { student_id, first_name, last_name, hall_ticket, email, mobile, college_id } = await req.json();
    const displayName = `${last_name} ${first_name}`;

    const { data: college } = await supabase
      .from("colleges")
      .select("name, admin_email")
      .eq("id", college_id)
      .maybeSingle();

    // Email to college admin (NO password included)
    if (college?.admin_email) {
      await sendEmail(
        college.admin_email,
        `New Student Registered: ${displayName}`,
        `<p>A new student has registered on MyVault under <b>${college.name}</b>.</p>
         <ul>
           <li><b>Name:</b> ${displayName}</li>
           <li><b>Hall Ticket:</b> ${hall_ticket}</li>
           <li><b>Email:</b> ${email}</li>
           <li><b>Mobile:</b> ${mobile}</li>
         </ul>
         <p>No password is included for security reasons.</p>`
      );
    }

    // Email to student with their login credentials
    await sendEmail(
      email,
      "Welcome to MyVault — Your Login Details",
      `<p>Hi ${first_name},</p>
       <p>Your MyVault account has been created successfully!</p>
       <ul>
         <li><b>Login ID (Hall Ticket):</b> ${hall_ticket}</li>
         <li><b>Default Password:</b> ${hall_ticket}</li>
       </ul>
       <p>Please log in and change your password immediately from Profile → Change Password.</p>
       <p>Welcome aboard! 🎓</p>`
    );

    await supabase
      .from("students")
      .update({ college_notified: true, student_notified: true })
      .eq("id", student_id);

    return new Response(
      JSON.stringify({ success: true }),
      { headers: { "Content-Type": "application/json" } }
    );
  } catch (e) {
    return new Response(
      JSON.stringify({ success: false, error: String(e) }),
      { status: 500, headers: { "Content-Type": "application/json" } }
    );
  }
});
