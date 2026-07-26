import { useCallback, useEffect, useState } from 'react'
import { supabase } from '../lib/supabaseClient'

/**
 * Generic CRUD + realtime hook for a single table.
 * Keeps every content section (study materials, courses, jobs, notices)
 * wired to the same live Supabase data without repeating fetch logic.
 */
export function useSupabaseTable(table, { orderBy = 'created_at', ascending = false } = {}) {
  const [rows, setRows] = useState([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState(null)

  const fetchRows = useCallback(async () => {
    setLoading(true)
    const { data, error: err } = await supabase
      .from(table)
      .select('*')
      .order(orderBy, { ascending })
    if (err) {
      setError(err.message)
    } else {
      setError(null)
      setRows(data ?? [])
    }
    setLoading(false)
  }, [table, orderBy, ascending])

  useEffect(() => {
    fetchRows()

    const channel = supabase
      .channel(`realtime:${table}`)
      .on('postgres_changes', { event: '*', schema: 'public', table }, () => {
        fetchRows()
      })
      .subscribe()

    return () => {
      supabase.removeChannel(channel)
    }
  }, [table, fetchRows])

  const insertRow = async (payload) => {
    const { data, error: err } = await supabase.from(table).insert(payload).select().single()
    if (err) throw err
    return data
  }

  const updateRow = async (id, payload) => {
    const { data, error: err } = await supabase.from(table).update(payload).eq('id', id).select().single()
    if (err) throw err
    return data
  }

  const deleteRow = async (id) => {
    const { error: err } = await supabase.from(table).delete().eq('id', id)
    if (err) throw err
  }

  return { rows, loading, error, refetch: fetchRows, insertRow, updateRow, deleteRow }
}
