import React from 'react'

const STYLES = {
  published: 'bg-emerald-400/10 text-emerald-300 border-emerald-400/20',
  draft: 'bg-amber-400/10 text-amber-300 border-amber-400/20',
  expired: 'bg-rose-400/10 text-rose-300 border-rose-400/20',
  default: 'bg-slate-400/10 text-slate-300 border-slate-400/20',
}

export default function StatusBadge({ status }) {
  const style = STYLES[status] || STYLES.default
  return (
    <span className={`inline-flex items-center rounded-full border px-2.5 py-0.5 text-xs font-medium capitalize ${style}`}>
      {status || 'draft'}
    </span>
  )
}
