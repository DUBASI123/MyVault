import React, { useCallback, useRef, useState } from 'react'
import { UploadCloud, File as FileIcon, X, CheckCircle2, AlertCircle } from 'lucide-react'
import { supabase } from '../lib/supabaseClient'

/**
 * Drag-and-drop uploader. Uploads the file straight to a Supabase Storage
 * bucket and hands the resulting public URL + path back to the caller,
 * which then writes the row (title, description, url, etc.) to its table.
 */
export default function UploadDropzone({ bucket, folder = '', accept, onUploaded }) {
  const inputRef = useRef(null)
  const [dragOver, setDragOver] = useState(false)
  const [queue, setQueue] = useState([]) // { name, progress, status, error }

  const uploadFile = useCallback(
    async (file) => {
      const path = `${folder ? folder.replace(/\/$/, '') + '/' : ''}${Date.now()}-${file.name.replace(/\s+/g, '-')}`
      setQueue((q) => [...q, { name: file.name, status: 'uploading' }])

      const { error } = await supabase.storage.from(bucket).upload(path, file, {
        cacheControl: '3600',
        upsert: false,
      })

      if (error) {
        setQueue((q) => q.map((f) => (f.name === file.name ? { ...f, status: 'error', error: error.message } : f)))
        return
      }

      const { data: publicUrlData } = supabase.storage.from(bucket).getPublicUrl(path)

      setQueue((q) => q.map((f) => (f.name === file.name ? { ...f, status: 'done' } : f)))
      onUploaded?.({ path, url: publicUrlData.publicUrl, name: file.name, size: file.size, type: file.type })
    },
    [bucket, folder, onUploaded]
  )

  const handleFiles = useCallback(
    (fileList) => {
      Array.from(fileList).forEach(uploadFile)
    },
    [uploadFile]
  )

  const onDrop = (e) => {
    e.preventDefault()
    setDragOver(false)
    if (e.dataTransfer.files?.length) handleFiles(e.dataTransfer.files)
  }

  return (
    <div>
      <div
        onDragOver={(e) => {
          e.preventDefault()
          setDragOver(true)
        }}
        onDragLeave={() => setDragOver(false)}
        onDrop={onDrop}
        onClick={() => inputRef.current?.click()}
        className={`focus-ring cursor-pointer rounded-xl border-2 border-dashed px-6 py-10 text-center transition ${
          dragOver ? 'border-accent-cyan bg-accent-cyan/5' : 'border-white/15 hover:border-white/25'
        }`}
        role="button"
        tabIndex={0}
        onKeyDown={(e) => e.key === 'Enter' && inputRef.current?.click()}
      >
        <UploadCloud className="mx-auto mb-3 h-8 w-8 text-accent-cyan" />
        <p className="text-sm text-slate-300">Drag files here, or click to browse</p>
        <p className="mt-1 text-xs text-slate-500">Uploads go straight to the {bucket} bucket</p>
        <input
          ref={inputRef}
          type="file"
          multiple
          accept={accept}
          className="hidden"
          onChange={(e) => e.target.files?.length && handleFiles(e.target.files)}
        />
      </div>

      {queue.length > 0 && (
        <ul className="mt-3 space-y-2">
          {queue.map((f, i) => (
            <li key={`${f.name}-${i}`} className="flex items-center gap-2 rounded-lg bg-base-900/60 px-3 py-2 text-xs">
              <FileIcon className="h-4 w-4 shrink-0 text-slate-400" />
              <span className="truncate text-slate-300">{f.name}</span>
              <span className="ml-auto flex items-center gap-1">
                {f.status === 'uploading' && <span className="text-slate-500">uploading…</span>}
                {f.status === 'done' && <CheckCircle2 className="h-4 w-4 text-emerald-400" />}
                {f.status === 'error' && (
                  <span className="flex items-center gap-1 text-rose-400">
                    <AlertCircle className="h-4 w-4" /> {f.error}
                  </span>
                )}
              </span>
              <button
                className="text-slate-500 hover:text-slate-300"
                onClick={(e) => {
                  e.stopPropagation()
                  setQueue((q) => q.filter((_, idx) => idx !== i))
                }}
              >
                <X className="h-3.5 w-3.5" />
              </button>
            </li>
          ))}
        </ul>
      )}
    </div>
  )
}
