import React from 'react'
import ContentSection from '../components/ContentSection'
import { BUCKETS } from '../lib/supabaseClient'

export default function Notices() {
  return (
    <ContentSection
      title="Notices"
      description="Announcements shown on the app's home feed and notification history."
      table="notices"
      bucket={BUCKETS.notices}
      fields={[
        { key: 'title', label: 'Notice Title', required: true },
        { key: 'body', label: 'Body Text', type: 'textarea', required: true },
        {
          key: 'target_branch',
          label: 'Target Branch',
          type: 'select',
          options: ['All', 'CSE', 'ECE', 'EEE', 'MECH', 'CIVIL', 'General'],
          required: true,
        },
        {
          key: 'target_semester',
          label: 'Target Semester',
          type: 'select',
          options: ['All', '1', '2', '3', '4', '5', '6', '7', '8'],
          required: true,
        },
        { key: 'expires_at', label: 'Expiry Date (Optional)', type: 'date' },
      ]}
      columns={[
        { key: 'title', label: 'Title' },
        { key: 'target_branch', label: 'Target Branch' },
        { key: 'target_semester', label: 'Target Sem' },
        { key: 'expires_at', label: 'Expires', render: (r) => (r.expires_at ? new Date(r.expires_at).toLocaleDateString() : 'Never') },
      ]}
    />
  )
}
