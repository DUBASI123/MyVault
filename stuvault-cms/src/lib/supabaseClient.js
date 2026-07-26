import { createClient } from '@supabase/supabase-js'

const url = import.meta.env.VITE_SUPABASE_URL || 'https://placeholder.supabase.co'
const anonKey = import.meta.env.VITE_SUPABASE_ANON_KEY || 'placeholder-anon-key'

export const isSupabaseConfigured = Boolean(
  import.meta.env.VITE_SUPABASE_URL && 
  import.meta.env.VITE_SUPABASE_ANON_KEY && 
  import.meta.env.VITE_SUPABASE_ANON_KEY !== 'your-anon-key-here'
)

if (!isSupabaseConfigured) {
  // eslint-disable-next-line no-console
  console.warn(
    '[StuVault CMS] Missing VITE_SUPABASE_URL / VITE_SUPABASE_ANON_KEY. Copy .env.example to .env and fill in your MyVault Supabase project credentials.'
  )
}

export const supabase = createClient(url, anonKey, {
  auth: {
    persistSession: true,
    autoRefreshToken: true,
  },
})

// Storage bucket names used across upload sections.
// Adjust these to match whatever buckets already exist in your MyVault Supabase project.
export const BUCKETS = {
  studyMaterials: 'study-materials',
  courses: 'course-content',
  notices: 'notices',
  jobs: 'job-attachments',
  websiteUploads: 'website-uploads',
}
