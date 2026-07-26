import React, { useEffect, useState } from 'react'
import { BookOpen, GraduationCap, Briefcase, Landmark, Megaphone, FolderGit2 } from 'lucide-react'
import { supabase } from '../lib/supabaseClient'
import { Link } from 'react-router-dom'

const CARDS = [
  { table: 'academic_contents', altTable: 'study_materials', label: 'Academic & Study Materials', icon: BookOpen, to: '/study-materials' },
  { table: 'placement_jobs', altTable: 'placement_listings', label: 'Placement Job Listings', icon: Briefcase, to: '/placements' },
  { table: 'govt_jobs', altTable: 'govt_job_listings', label: 'Govt Jobs', icon: Landmark, to: '/govt-jobs' },
  { table: 'courses', label: 'LMS Courses', icon: GraduationCap, to: '/courses' },
  { table: 'notices', altTable: 'announcements', label: 'Notices & Announcements', icon: Megaphone, to: '/notices' },
]

export default function Dashboard() {
  const [counts, setCounts] = useState({})

  useEffect(() => {
    let cancelled = false
    async function loadCounts() {
      const results = await Promise.all(
        CARDS.map(async ({ table, altTable }) => {
          let { count, error } = await supabase.from(table).select('*', { count: 'exact', head: true })
          if ((error || count === 0) && altTable) {
            const resAlt = await supabase.from(altTable).select('*', { count: 'exact', head: true })
            if (!resAlt.error) count = resAlt.count
          }
          return [table, error && !altTable ? 0 : count ?? 0]
        })
      )
      if (!cancelled) setCounts(Object.fromEntries(results))
    }
    loadCounts()
    return () => { cancelled = true }
  }, [])

  return (
    <div>
      <header className="mb-6">
        <h1 className="font-display text-2xl font-semibold text-slate-100">Content console</h1>
        <p className="mt-1 text-sm text-slate-500">
          Everything uploaded here syncs live into the MyVault mobile app database — live across all subjects, placement desk, and govt jobs.
        </p>
      </header>

      <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-3">
        {CARDS.map(({ table, label, icon: Icon, to }) => (
          <Link key={table} to={to} className="glass-panel focus-ring block p-5 transition hover:border-white/20">
            <div className="mb-3 flex items-center justify-between">
              <Icon className="h-5 w-5 text-accent-cyan" />
              <span className="font-mono text-2xl font-semibold text-slate-100">
                {counts[table] ?? '—'}
              </span>
            </div>
            <div className="text-sm font-medium text-slate-200">{label}</div>
          </Link>
        ))}
      </div>
    </div>
  )
}
