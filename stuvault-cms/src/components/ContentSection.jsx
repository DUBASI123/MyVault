import React, { useState } from 'react'
import { Plus } from 'lucide-react'
import { useSupabaseTable } from '../hooks/useSupabaseTable'
import UploadDropzone from './UploadDropzone'
import DataTable from './DataTable'
import Modal from './Modal'
import StatusBadge from './StatusBadge'

/**
 * Config-driven content section:
 *  - table: Supabase table name
 *  - bucket: Storage bucket for file uploads (null = no file upload, e.g. text-only notices)
 *  - fields: form fields shown in the add/edit modal
 *  - columns: DataTable columns
 *  - extraDefaults: static values merged into every insert (e.g. { job_type: 'placement' })
 */
export default function ContentSection({ title, description, table, bucket, fields, columns, extraDefaults = {}, onBeforeSave }) {
  const { rows, loading, insertRow, updateRow, deleteRow } = useSupabaseTable(table)
  const [modalOpen, setModalOpen] = useState(false)
  const [editing, setEditing] = useState(null)
  const [form, setForm] = useState({})
  const [saving, setSaving] = useState(false)
  const [formError, setFormError] = useState('')

  const openCreate = () => {
    setEditing(null)
    setForm({})
    setFormError('')
    setModalOpen(true)
  }

  const openEdit = (row) => {
    setEditing(row)
    setForm(row)
    setFormError('')
    setModalOpen(true)
  }

  const handleDelete = async (row) => {
    if (!window.confirm(`Delete "${row.title || row.name || 'this item'}"? This can't be undone.`)) return
    try {
      await deleteRow(row.id)
    } catch (err) {
      alert(err.message)
    }
  }

  const handleSave = async (e) => {
    e.preventDefault()
    setSaving(true)
    setFormError('')
    try {
      let payload = { ...form, ...extraDefaults }
      delete payload.created_at
      if (onBeforeSave) {
        payload = await onBeforeSave(payload)
      }
      if (editing) {
        delete payload.id
        await updateRow(editing.id, payload)
      } else {
        if (!payload.id) {
          payload.id = crypto.randomUUID()
        }
        await insertRow(payload)
      }
      setModalOpen(false)
    } catch (err) {
      setFormError(err.message)
    } finally {
      setSaving(false)
    }
  }

  const setField = (key, value) => setForm((f) => ({ ...f, [key]: value }))

  return (
    <div>
      <header className="mb-6 flex items-start justify-between gap-4">
        <div>
          <h1 className="font-display text-2xl font-semibold text-slate-100">{title}</h1>
          {description && <p className="mt-1 text-sm text-slate-500">{description}</p>}
        </div>
        <button className="btn-primary shrink-0" onClick={openCreate}>
          <Plus className="h-4 w-4" /> Add new
        </button>
      </header>

      <DataTable columns={columns} rows={rows} loading={loading} onEdit={openEdit} onDelete={handleDelete} />

      <Modal open={modalOpen} onClose={() => setModalOpen(false)} title={editing ? 'Edit item' : 'Add new item'} wide>
        <form onSubmit={handleSave} className="space-y-4">
          {bucket && (
            <div>
              <label className="mb-1 block text-xs text-slate-400">File</label>
              <UploadDropzone
                bucket={bucket}
                onUploaded={({ url, name }) => {
                  setField('file_url', url)
                  if (!form.title) setField('title', name)
                }}
              />
              {form.file_url && (
                <p className="mt-2 truncate text-xs text-emerald-400">Attached: {form.file_url}</p>
              )}
            </div>
          )}

          {fields.map((field) => (
            <div key={field.key}>
              <label className="mb-1 block text-xs text-slate-400">{field.label}</label>
              {field.type === 'textarea' ? (
                <textarea
                  className="input-field min-h-[90px]"
                  value={form[field.key] ?? ''}
                  onChange={(e) => setField(field.key, e.target.value)}
                  required={field.required}
                />
              ) : field.type === 'select' ? (
                <select
                  className="input-field"
                  value={form[field.key] ?? ''}
                  onChange={(e) => setField(field.key, e.target.value)}
                  required={field.required}
                >
                  <option value="" disabled>Select…</option>
                  {field.options.map((opt) => {
                    const value = typeof opt === 'object' ? opt.value : opt
                    const label = typeof opt === 'object' ? opt.label : opt
                    return <option key={value} value={value}>{label}</option>
                  })}
                </select>
              ) : (
                <input
                  type={field.type || 'text'}
                  className="input-field"
                  value={form[field.key] ?? ''}
                  onChange={(e) => setField(field.key, e.target.value)}
                  placeholder={field.placeholder}
                  required={field.required}
                />
              )}
            </div>
          ))}

          {formError && <p className="text-xs text-rose-400">{formError}</p>}

          <div className="flex justify-end gap-2 pt-2">
            <button type="button" className="btn-ghost" onClick={() => setModalOpen(false)}>Cancel</button>
            <button type="submit" disabled={saving} className="btn-primary">
              {saving ? 'Saving…' : editing ? 'Save changes' : 'Publish'}
            </button>
          </div>
        </form>
      </Modal>
    </div>
  )
}

export { StatusBadge }
