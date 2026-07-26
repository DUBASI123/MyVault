import React from 'react'
import ContentSection from '../components/ContentSection'
import { BUCKETS } from '../lib/supabaseClient'

export default function Courses() {
  return (
    <ContentSection
      title="Courses"
      description="Self-paced course lessons, videos, and modules — shown in the Courses & Skills section."
      table="courses"
      bucket={BUCKETS.courses}
      fields={[
        { key: 'title', label: 'Course Title', required: true },
        { key: 'description', label: 'Description', type: 'textarea' },
        { key: 'order_index', label: 'Order Index (Sequence Number)', type: 'number' },
      ]}
      columns={[
        { key: 'title', label: 'Title' },
        { key: 'order_index', label: 'Order Index', render: (r) => r.order_index ?? 0 },
        { key: 'description', label: 'Description' },
      ]}
    />
  )
}
