import React from 'react'
import ContentSection from '../components/ContentSection'
import { BUCKETS, supabase } from '../lib/supabaseClient'

export default function MyFiles() {
  const handleBeforeSave = async (payload) => {
    const { data: { session } } = await supabase.auth.getSession()
    if (session?.user?.id) {
      payload.user_id = session.user.id
    } else {
      delete payload.user_id
    }
    return payload
  }

  return (
    <ContentSection
      title="My Files"
      description="Uploaded user files stored in website-uploads bucket — shared across the website and Flutter app."
      table="files"
      bucket={BUCKETS.websiteUploads}
      onBeforeSave={handleBeforeSave}
      fields={[
        { key: 'file_name', label: 'File Name', required: true },
      ]}
      columns={[
        { key: 'file_name', label: 'File Name' },
        {
          key: 'file_url',
          label: 'File Link',
          render: (r) => (
            r.file_url ? (
              <a
                href={r.file_url}
                target="_blank"
                rel="noreferrer"
                className="text-accent-cyan hover:underline font-mono text-xs"
              >
                Open File ↗
              </a>
            ) : '—'
          ),
        },
        { key: 'created_at', label: 'Uploaded At', render: (r) => (r.created_at ? new Date(r.created_at).toLocaleDateString() : '—') },
      ]}
    />
  )
}
