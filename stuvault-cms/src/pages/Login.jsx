import React, { useState } from 'react'
import { useAuth } from '../lib/auth.jsx'
import { isSupabaseConfigured } from '../lib/supabaseClient'
import { ShieldCheck, AlertTriangle } from 'lucide-react'

export default function Login() {
  const { signIn, signUp } = useAuth()
  const [isSignUp, setIsSignUp] = useState(false)
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [error, setError] = useState('')
  const [success, setSuccess] = useState('')
  const [submitting, setSubmitting] = useState(false)

  const handleSubmit = async (e) => {
    e.preventDefault()
    setError('')
    setSuccess('')
    setSubmitting(true)
    try {
      if (isSignUp) {
        await signUp(email, password)
        setSuccess('Account created! Attempting to sign in...')
        await signIn(email, password)
      } else {
        await signIn(email, password)
      }
    } catch (err) {
      if (err.message?.includes('Invalid login credentials')) {
        setError('Invalid login credentials. If you haven\'t created an account yet, switch to "Sign Up" tab below to create one.')
      } else {
        setError(err.message || (isSignUp ? 'Sign-up failed' : 'Sign-in failed'))
      }
    } finally {
      setSubmitting(false)
    }
  }

  return (
    <div className="flex min-h-screen items-center justify-center p-4">
      <div className="glass-panel w-full max-w-sm p-8">
        <div className="mb-6 flex items-center gap-2">
          <ShieldCheck className="h-6 w-6 text-accent-cyan" />
          <div>
            <div className="font-display text-lg font-semibold text-slate-100">StuVault</div>
            <div className="text-xs text-slate-500">Admin {isSignUp ? 'Sign-up' : 'Sign-in'}</div>
          </div>
        </div>

        <div className="mb-6 flex rounded-lg bg-slate-900/60 p-1 border border-slate-800">
          <button
            type="button"
            className={`flex-1 py-1.5 text-xs font-medium rounded-md transition-colors ${!isSignUp ? 'bg-accent-cyan/20 text-accent-cyan border border-accent-cyan/30' : 'text-slate-400 hover:text-slate-200'}`}
            onClick={() => { setIsSignUp(false); setError(''); setSuccess('') }}
          >
            Sign In
          </button>
          <button
            type="button"
            className={`flex-1 py-1.5 text-xs font-medium rounded-md transition-colors ${isSignUp ? 'bg-accent-cyan/20 text-accent-cyan border border-accent-cyan/30' : 'text-slate-400 hover:text-slate-200'}`}
            onClick={() => { setIsSignUp(true); setError(''); setSuccess('') }}
          >
            Sign Up
          </button>
        </div>

        {!isSupabaseConfigured && (
          <div className="mb-4 rounded border border-amber-500/30 bg-amber-500/10 p-3 text-xs text-amber-200">
            <div className="flex items-center gap-1.5 font-medium">
              <AlertTriangle className="h-4 w-4 shrink-0 text-amber-400" />
              <span>Supabase Key Required</span>
            </div>
            <p className="mt-1 text-[11px] leading-relaxed opacity-90">
              Update <code className="rounded bg-black/40 px-1 py-0.5 font-mono">VITE_SUPABASE_ANON_KEY</code> in your <code className="rounded bg-black/40 px-1 py-0.5 font-mono">.env</code> file with your Supabase Anon key.
            </p>
          </div>
        )}

        <form onSubmit={handleSubmit} className="space-y-4">
          <div>
            <label className="mb-1 block text-xs text-slate-400">Email</label>
            <input
              type="email"
              required
              className="input-field"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              autoComplete="username"
              placeholder="admin@stuvault.com"
            />
          </div>
          <div>
            <label className="mb-1 block text-xs text-slate-400">Password</label>
            <input
              type="password"
              required
              className="input-field"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              autoComplete={isSignUp ? 'new-password' : 'current-password'}
              placeholder="••••••••"
            />
          </div>

          {error && <p className="text-xs text-rose-400 leading-relaxed">{error}</p>}
          {success && <p className="text-xs text-emerald-400 leading-relaxed">{success}</p>}

          <button type="submit" disabled={submitting} className="btn-primary w-full justify-center">
            {submitting ? (isSignUp ? 'Creating account…' : 'Signing in…') : (isSignUp ? 'Create Account' : 'Sign in')}
          </button>
        </form>
      </div>
    </div>
  )
}
