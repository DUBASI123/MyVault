'use client';

import { useState } from 'react';
import Link from 'next/link';
import { GraduationCap, Menu, X, Download, Upload, BookOpen, Briefcase, UserCheck } from 'lucide-react';

export default function Navbar() {
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);

  return (
    <nav className="fixed top-0 left-0 right-0 z-50 bg-[#07080D]/80 backdrop-blur-xl border-b border-white/10 transition-all">
      <div className="max-w-7xl mx-auto px-6 h-20 flex items-center justify-between">
        {/* Logo */}
        <Link href="/" className="flex items-center gap-3 group">
          <div className="w-10 h-10 rounded-xl bg-gradient-to-br from-[#3E7BFF] to-[#00D9F5] flex items-center justify-center text-white shadow-lg shadow-blue-500/25 group-hover:scale-105 transition-transform">
            <GraduationCap className="w-6 h-6 text-[#04101F]" />
          </div>
          <span className="font-extrabold text-xl tracking-tight text-white group-hover:text-[#00D9F5] transition-colors">
            MyVault
          </span>
        </Link>

        {/* Desktop Links */}
        <div className="hidden md:flex items-center gap-2">
          <Link
            href="/academic"
            className="px-4 py-2 text-sm font-medium text-[#8A97B8] hover:text-white hover:bg-white/5 rounded-lg transition-all flex items-center gap-2"
          >
            <BookOpen className="w-4 h-4 text-[#3E7BFF]" />
            Academic Hub
          </Link>
          <Link
            href="/placements"
            className="px-4 py-2 text-sm font-medium text-[#8A97B8] hover:text-white hover:bg-white/5 rounded-lg transition-all flex items-center gap-2"
          >
            <Briefcase className="w-4 h-4 text-[#7B5BFF]" />
            Placements
          </Link>
          <Link
            href="/upload"
            className="px-4 py-2 text-sm font-medium text-[#8A97B8] hover:text-white hover:bg-white/5 rounded-lg transition-all flex items-center gap-2"
          >
            <Upload className="w-4 h-4 text-[#00E896]" />
            Upload Portal
          </Link>
          <Link
            href="/auth/login"
            className="px-4 py-2 text-sm font-medium text-[#8A97B8] hover:text-white hover:bg-white/5 rounded-lg transition-all flex items-center gap-2"
          >
            <UserCheck className="w-4 h-4 text-[#FFB930]" />
            Login
          </Link>

          <Link
            href="/#download"
            className="ml-4 px-5 py-2.5 rounded-xl font-bold text-sm bg-gradient-to-r from-[#3E7BFF] to-[#00D9F5] text-[#04101F] shadow-lg shadow-blue-500/25 hover:shadow-cyan-500/40 hover:-translate-y-0.5 transition-all flex items-center gap-2"
          >
            <Download className="w-4 h-4" />
            Download APK
          </Link>
        </div>

        {/* Mobile Hamburger */}
        <button
          onClick={() => setMobileMenuOpen(!mobileMenuOpen)}
          className="md:hidden p-2 text-[#8A97B8] hover:text-white focus:outline-none"
          aria-label="Toggle Navigation"
        >
          {mobileMenuOpen ? <X className="w-6 h-6" /> : <Menu className="w-6 h-6" />}
        </button>
      </div>

      {/* Mobile Drawer */}
      {mobileMenuOpen && (
        <div className="md:hidden bg-[#0C1020] border-b border-white/10 px-6 py-6 space-y-4 animate-in fade-in slide-in-from-top-4">
          <Link
            href="/academic"
            onClick={() => setMobileMenuOpen(false)}
            className="flex items-center gap-3 text-base font-semibold text-[#8A97B8] hover:text-white py-2"
          >
            <BookOpen className="w-5 h-5 text-[#3E7BFF]" />
            Academic Hub
          </Link>
          <Link
            href="/placements"
            onClick={() => setMobileMenuOpen(false)}
            className="flex items-center gap-3 text-base font-semibold text-[#8A97B8] hover:text-white py-2"
          >
            <Briefcase className="w-5 h-5 text-[#7B5BFF]" />
            Placements & Jobs
          </Link>
          <Link
            href="/upload"
            onClick={() => setMobileMenuOpen(false)}
            className="flex items-center gap-3 text-base font-semibold text-[#8A97B8] hover:text-white py-2"
          >
            <Upload className="w-5 h-5 text-[#00E896]" />
            Faculty Upload Portal
          </Link>
          <Link
            href="/auth/login"
            onClick={() => setMobileMenuOpen(false)}
            className="flex items-center gap-3 text-base font-semibold text-[#8A97B8] hover:text-white py-2"
          >
            <UserCheck className="w-5 h-5 text-[#FFB930]" />
            Student Login
          </Link>
          <Link
            href="/#download"
            onClick={() => setMobileMenuOpen(false)}
            className="w-full mt-4 py-3 rounded-xl font-bold text-center bg-gradient-to-r from-[#3E7BFF] to-[#00D9F5] text-[#04101F] shadow-lg flex items-center justify-center gap-2"
          >
            <Download className="w-5 h-5" />
            Download APK (20.4MB)
          </Link>
        </div>
      )}
    </nav>
  );
}
