import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const supabase = createClient(
  Deno.env.get("SUPABASE_URL")!,
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
);

serve(async (req) => {
  try {
    const { contact, new_password } = await req.json();
    const isEmail = contact.includes("@");
    const column  = isEmail ? "email" : "mobile";
    const value   = isEmail ? contact : contact.replace("+91", "");

    const { data: student } = await supabase
      .from("students")
      .select("id")
      .eq(column, value)
      .maybeSingle();

    if (!student) {
      return new Response(
        JSON.stringify({ success: false, error: "Student not found" }),
        { status: 404, headers: { "Content-Type": "application/json" } }
      );
    }

    const { error } = await supabase.auth.admin.updateUserById(
      student.id,
      { password: new_password }
    );

    if (error) {
      return new Response(
        JSON.stringify({ success: false, error: error.message }),
        { status: 400, headers: { "Content-Type": "application/json" } }
      );
    }

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
