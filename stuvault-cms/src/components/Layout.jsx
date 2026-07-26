import React from 'react'
import Sidebar from './Sidebar'

export default function Layout({ children }) {
  return (
    <div className="mx-auto flex h-screen max-w-[1400px] gap-4 p-4">
      <Sidebar />
      <main className="min-w-0 flex-1 overflow-y-auto scrollbar-thin pr-1">{children}</main>
    </div>
  )
}
