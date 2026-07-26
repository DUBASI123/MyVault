import React, { useState, useEffect } from 'react'
import ContentSection from '../components/ContentSection'
import StatusBadge from '../components/StatusBadge'
import { BUCKETS, supabase } from '../lib/supabaseClient'

export default function StudyMaterials() {
  const [subjects, setSubjects] = useState([])

  const fetchSubjects = () => {
    supabase
      .from('subjects')
      .select('id, name, code, branch, semester')
      .order('semester', { ascending: true })
      .then(({ data }) => {
        if (data) setSubjects(data)
      })
  }

  useEffect(() => {
    fetchSubjects()
  }, [])

  const hasSubjects = subjects.length > 0

  const subjectOptions = subjects.map((s) => ({
    value: s.id,
    label: `${s.code ? s.code + ' - ' : ''}${s.name} (${s.branch || 'General'} Sem ${s.semester || 1})`,
  }))

  const handleBeforeSave = async (payload) => {
    if (!payload.subject_id) return payload
    const isUUID = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i.test(payload.subject_id)
    if (isUUID) return payload

    // User typed a custom text string like "2G"
    const inputVal = payload.subject_id.trim()
    const newSubjectId = crypto.randomUUID()
    const branch = payload.subject_branch || 'General'
    const semester = parseInt(payload.subject_semester) || 1

    // Create subject entry automatically
    const { data: created } = await supabase
      .from('subjects')
      .insert({
        id: newSubjectId,
        name: inputVal,
        code: inputVal,
        branch: branch,
        semester: semester,
        subject_type: 'academic',
      })
      .select()
      .maybeSingle()

    delete payload.subject_branch
    delete payload.subject_semester

    payload.subject_id = created?.id || newSubjectId
    fetchSubjects()
    return payload
  }

  return (
    <ContentSection
      title="Study Materials"
      description="Notes, video recordings, lab manuals, and cheat sheets — linked directly to subjects in the MyVault Mobile App."
      table="academic_contents"
      bucket={BUCKETS.studyMaterials}
      onBeforeSave={handleBeforeSave}
      fields={[
        { key: 'title', label: 'Title (e.g. Unit 1 Circuit Theory Notes)', required: true },
        hasSubjects
          ? {
              key: 'subject_id',
              label: 'Select Mobile App Subject',
              type: 'select',
              options: subjectOptions,
              required: true,
            }
          : {
              key: 'subject_id',
              label: 'Subject Name / Code (e.g. 2G, EC101 Basic Electronics)',
              type: 'text',
              placeholder: 'Type subject name or code...',
              required: true,
            },
        ...(!hasSubjects ? [
          {
            key: 'subject_branch',
            label: 'Subject Branch (e.g. CSE, ECE, General)',
            type: 'select',
            options: [
              { value: 'General', label: 'General / Common' },
              { value: 'CSE', label: 'Computer Science (CSE)' },
              { value: 'ECE', label: 'Electronics (ECE)' },
            ],
            required: true,
          },
          {
            key: 'subject_semester',
            label: 'Subject Semester (1-8)',
            type: 'select',
            options: [
              { value: '1', label: 'Semester 1' },
              { value: '2', label: 'Semester 2' },
              { value: '3', label: 'Semester 3' },
              { value: '4', label: 'Semester 4' },
              { value: '5', label: 'Semester 5' },
              { value: '6', label: 'Semester 6' },
              { value: '7', label: 'Semester 7' },
              { value: '8', label: 'Semester 8' },
            ],
            required: true,
          }
        ] : []),
        {
          key: 'content_type',
          label: 'Content Type',
          type: 'select',
          options: [
            { value: 'notes', label: 'Notes (PDF)' },
            { value: 'video', label: 'Video Lecture' },
            { value: 'lab_manual', label: 'Lab Manual' },
            { value: 'quiz', label: 'Quiz' },
            { value: 'question_paper', label: 'Previous Question Paper' },
            { value: 'syllabus', label: 'Syllabus' },
          ],
          required: true,
        },
        { key: 'unit_number', label: 'Unit Number (e.g. 1, 2, 3, 4, 5)', type: 'number' },
        { key: 'description', label: 'Description', type: 'textarea' },
      ]}
      columns={[
        { key: 'title', label: 'Title' },
        {
          key: 'subject_id',
          label: 'Subject',
          render: (r) => {
            const sub = subjects.find((s) => s.id === r.subject_id)
            return sub ? `${sub.code ? sub.code + ' — ' : ''}${sub.name}` : r.subject_id || '—'
          },
        },
        { key: 'content_type', label: 'Type' },
        { key: 'unit_number', label: 'Unit', render: (r) => (r.unit_number ? `Unit ${r.unit_number}` : '—') },
      ]}
    />
  )
}
