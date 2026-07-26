import React from 'react'
import ContentSection from '../components/ContentSection'
import StatusBadge from '../components/StatusBadge'
import { BUCKETS } from '../lib/supabaseClient'

export default function GovtJobs() {
  return (
    <ContentSection
      title="Govt Jobs"
      description="Government Job Listings — IBPS, Railways, Defence, SSC, State PSC — shown in the MyVault app."
      table="govt_jobs"
      bucket={BUCKETS.jobs}
      fields={[
        { key: 'title', label: 'Post Title (e.g. Probationary Officer / Management Trainee)', required: true },
        { key: 'department', label: 'Department / Organization (e.g. ISRO, RRB, SSC)', required: true },
        {
          key: 'sector',
          label: 'Sector',
          type: 'select',
          options: [
            { value: 'banking', label: 'Banking' },
            { value: 'railways', label: 'Railways' },
            { value: 'defence', label: 'Defence' },
            { value: 'police', label: 'Police' },
            { value: 'teaching', label: 'Teaching' },
            { value: 'upsc', label: 'UPSC' },
            { value: 'state_psc', label: 'State PSC' },
            { value: 'psu_technical', label: 'PSU Technical' },
          ],
          required: true,
        },
        { key: 'apply_url', label: 'Official Apply Link (URL)', required: true },
        { key: 'deadline', label: 'Application Deadline', type: 'date', required: true },
        { key: 'related_exam', label: 'Related Exam (Optional, e.g. GATE, GRE, TSPSC)' },
      ]}
      columns={[
        { key: 'title', label: 'Post Title' },
        { key: 'department', label: 'Department' },
        { key: 'sector', label: 'Sector' },
        { key: 'deadline', label: 'Deadline' },
        { key: 'related_exam', label: 'Related Exam', render: (r) => r.related_exam || '—' },
      ]}
    />
  )
}
