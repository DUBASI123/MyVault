import React from 'react'
import { Routes, Route, Navigate } from 'react-router-dom'
import { useAuth } from './lib/auth.jsx'
import Layout from './components/Layout'
import Login from './pages/Login'
import Dashboard from './pages/Dashboard'
import StudyMaterials from './pages/StudyMaterials'
import Courses from './pages/Courses'
import Placements from './pages/Placements'
import GovtJobs from './pages/GovtJobs'
import Notices from './pages/Notices'

function LoadingScreen() {
  return (
    <div className="flex h-screen items-center justify-center text-sm text-slate-500">Loading…</div>
  )
}

function NotAuthorized() {
  const { signOut, user } = useAuth()
  return (
    <div className="flex h-screen items-center justify-center p-4">
      <div className="glass-panel max-w-sm p-8 text-center">
        <h1 className="font-display text-lg font-semibold text-slate-100">Account not authorized</h1>
        <p className="mt-2 text-sm text-slate-400">
          {user?.email} is signed in but isn't listed as a StuVault admin yet. Add this user to the{' '}
          <code className="text-accent-cyan">cms_admins</code> table to grant access.
        </p>
        <button className="btn-ghost mt-4 w-full justify-center" onClick={signOut}>Sign out</button>
      </div>
    </div>
  )
}

import MyFiles from './pages/MyFiles'

export default function App() {
  return (
    <Layout>
      <Routes>
        <Route path="/" element={<Dashboard />} />
        <Route path="/study-materials" element={<StudyMaterials />} />
        <Route path="/courses" element={<Courses />} />
        <Route path="/placements" element={<Placements />} />
        <Route path="/govt-jobs" element={<GovtJobs />} />
        <Route path="/notices" element={<Notices />} />
        <Route path="/my-files" element={<MyFiles />} />
        <Route path="*" element={<Navigate to="/" replace />} />
      </Routes>
    </Layout>
  )
}
