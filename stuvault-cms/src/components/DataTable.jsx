import React from 'react'
import { Pencil, Trash2 } from 'lucide-react'

export default function DataTable({ columns, rows, loading, onEdit, onDelete, emptyLabel = 'Nothing here yet' }) {
  if (loading) {
    return (
      <div className="glass-panel p-10 text-center text-sm text-slate-500">Loading…</div>
    )
  }

  if (!rows.length) {
    return (
      <div className="glass-panel p-10 text-center">
        <p className="text-sm text-slate-400">{emptyLabel}</p>
        <p className="mt-1 text-xs text-slate-600">Upload something above to see it appear here — and in the app.</p>
      </div>
    )
  }

  return (
    <div className="glass-panel overflow-x-auto scrollbar-thin">
      <table className="w-full min-w-[640px] text-left text-sm">
        <thead>
          <tr className="border-b border-white/10 text-xs uppercase tracking-wide text-slate-500">
            {columns.map((col) => (
              <th key={col.key} className="px-4 py-3 font-medium">{col.label}</th>
            ))}
            <th className="px-4 py-3 text-right font-medium">Actions</th>
          </tr>
        </thead>
        <tbody>
          {rows.map((row) => (
            <tr key={row.id} className="border-b border-white/5 last:border-0 hover:bg-white/[0.02]">
              {columns.map((col) => (
                <td key={col.key} className="px-4 py-3 align-top text-slate-300">
                  {col.render ? col.render(row) : row[col.key]}
                </td>
              ))}
              <td className="px-4 py-3 text-right">
                <div className="flex justify-end gap-1">
                  <button
                    className="focus-ring rounded-lg p-1.5 text-slate-400 hover:bg-white/5 hover:text-accent-cyan"
                    onClick={() => onEdit?.(row)}
                    aria-label="Edit"
                  >
                    <Pencil className="h-4 w-4" />
                  </button>
                  <button
                    className="focus-ring rounded-lg p-1.5 text-slate-400 hover:bg-rose-500/10 hover:text-rose-400"
                    onClick={() => onDelete?.(row)}
                    aria-label="Delete"
                  >
                    <Trash2 className="h-4 w-4" />
                  </button>
                </div>
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  )
}
