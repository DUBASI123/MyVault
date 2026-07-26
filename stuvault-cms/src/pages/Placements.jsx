import React from 'react'
import ContentSection from '../components/ContentSection'
import StatusBadge from '../components/StatusBadge'
import { BUCKETS } from '../lib/supabaseClient'

export default function Placements() {
  return (
    <ContentSection
      title="Placements"
      description="Job & Internship listings shown on the MyVault Placement Desk — synced live with the mobile app."
      table="placement_jobs"
      bucket={BUCKETS.jobs}
      fields={[
        { key: 'company_name', label: 'Company Name', required: true },
        { key: 'role', label: 'Role Title (e.g. Full Stack Developer)', required: true },
        { key: 'location', label: 'Location (e.g. Hyderabad / Remote)' },
        {
          key: 'job_type',
          label: 'Job Type',
          type: 'select',
          options: [
            { value: 'fullTime', label: 'Full Time' },
            { value: 'internship', label: 'Internship' },
            { value: 'contract', label: 'Contract' },
          ],
          required: true,
        },
        {
          key: 'work_mode',
          label: 'Work Mode',
          type: 'select',
          options: [
            { value: 'remote', label: 'Remote' },
            { value: 'hybrid', label: 'Hybrid' },
            { value: 'onsite', label: 'Onsite' },
          ],
        },
        { key: 'salary_range', label: 'Salary / CTC (e.g. 6-10 LPA)' },
        { key: 'apply_url', label: 'Apply URL (Official Link)', required: true },
        { key: 'description', label: 'Job Description', type: 'textarea' },
      ]}
      columns={[
        { key: 'company_name', label: 'Company' },
        { key: 'role', label: 'Role' },
        { key: 'job_type', label: 'Type' },
        { key: 'location', label: 'Location' },
        { key: 'salary_range', label: 'Salary' },
      ]}
    />
  )
}
