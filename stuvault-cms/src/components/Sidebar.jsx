import React from 'react'
import { NavLink } from 'react-router-dom'
import { LayoutDashboard, BookOpen, GraduationCap, Briefcase, Landmark, Megaphone, Folder } from 'lucide-react'
import { useAuth } from '../lib/auth.jsx'

const NAV = [
  { to: '/', label: 'Dashboard', icon: LayoutDashboard, end: true },
  { to: '/study-materials', label: 'Study Materials', icon: BookOpen },
  { to: '/courses', label: 'Courses', icon: GraduationCap },
  { to: '/placements', label: 'Placements', icon: Briefcase },
  { to: '/govt-jobs', label: 'Govt Jobs', icon: Landmark },
  { to: '/notices', label: 'Notices', icon: Megaphone },
  { to: '/my-files', label: 'My Files', icon: Folder },
]

export default function Sidebar() {
  const { adminProfile, signOut } = useAuth()

  return (
    <aside className="glass-panel flex h-full w-64 shrink-0 flex-col p-4">
      <div className="mb-6 px-2">
        <div className="font-display text-lg font-semibold text-slate-100">StuVault</div>
        <div className="text-xs text-slate-500">Content console for MyVault</div>
      </div>

      <nav className="flex-1 space-y-1">
        {NAV.map(({ to, label, icon: Icon, end }) => (
          <NavLink
            key={to}
            to={to}
            end={end}
            className={({ isActive }) =>
              `focus-ring flex items-center gap-3 rounded-xl px-3 py-2.5 text-sm transition ${
                isActive
                  ? 'bg-gradient-to-r from-accent-cyan/15 to-accent-blue/10 text-slate-100 border border-white/10'
                  : 'text-slate-400 hover:bg-white/5 hover:text-slate-200'
              }`
            }
          >
            <Icon className="h-4 w-4" />
            {label}
          </NavLink>
        ))}
      </nav>

      <div className="mt-4 border-t border-white/10 pt-4 px-2">
        <div className="text-xs text-slate-500">
          Console Mode<br />
          <span className="text-slate-300 font-medium">Direct Access (No Auth)</span>
        </div>
      </div>
    </aside>
  )
}
