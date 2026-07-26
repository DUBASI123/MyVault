import React, { createContext, useContext, useEffect, useState, useCallback } from 'react'
import { supabase } from './supabaseClient'

const AuthContext = createContext(null)

export function AuthProvider({ children }) {
  const [session, setSession] = useState(null)
  const [adminProfile, setAdminProfile] = useState(null)
  const [loading, setLoading] = useState(true)

  const loadAdminProfile = useCallback(async (userId) => {
    if (!userId) {
      setAdminProfile(null)
      return
    }
    const { data, error } = await supabase
      .from('cms_admins')
      .select('id, full_name, role, is_active')
      .eq('user_id', userId)
      .maybeSingle()

    if (error) {
      console.error('Failed to load admin profile:', error.message)
      setAdminProfile(null)
      return
    }
    setAdminProfile(data)
  }, [])

  useEffect(() => {
    let mounted = true

    supabase.auth.getSession().then(({ data }) => {
      if (!mounted) return
      setSession(data?.session ?? null)
      if (data?.session?.user?.id) loadAdminProfile(data.session.user.id)
      setLoading(false)
    }).catch((err) => {
      console.error('Supabase auth error:', err)
      if (mounted) setLoading(false)
    })

    const { data: sub } = supabase.auth.onAuthStateChange((_event, newSession) => {
      if (!mounted) return
      setSession(newSession)
      if (newSession?.user?.id) {
        loadAdminProfile(newSession.user.id)
      } else {
        setAdminProfile(null)
      }
    })

    return () => {
      mounted = false
      sub?.subscription?.unsubscribe()
    }
  }, [loadAdminProfile])

  const signIn = async (email, password) => {
    const { error } = await supabase.auth.signInWithPassword({ email, password })
    if (error) throw error
  }

  const signUp = async (email, password) => {
    const { data, error } = await supabase.auth.signUp({ email, password })
    if (error) throw error
    return data
  }

  const signOut = async () => {
    await supabase.auth.signOut()
  }

  const value = {
    session,
    user: session?.user ?? null,
    adminProfile,
    isAdmin: !!adminProfile?.is_active,
    loading,
    signIn,
    signUp,
    signOut,
  }

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>
}

export function useAuth() {
  const ctx = useContext(AuthContext)
  if (!ctx) throw new Error('useAuth must be used inside AuthProvider')
  return ctx
}
