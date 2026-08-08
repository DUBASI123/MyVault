'use client';

import { useState } from 'react';
import Link from 'next/link';
import { User, Lock, ArrowRight, Settings, CheckCircle2, AlertCircle } from 'lucide-react';

const API_BASE = 'https://myvault-backend.onrender.com';

export default function LoginPage() {
  const [hallTicket, setHallTicket] = useState('');
  const [password, setPassword] = useState('');
  const [rememberMe, setRememberMe] = useState(true);
  const [loading, setLoading] = useState(false);
  const [message, setMessage] = useState<string | null>(null);
  const [messageType, setMessageType] = useState<'success' | 'error' | null>(null);
  const [showDevModal, setShowDevModal] = useState(false);
  const [customBackendUrl, setCustomBackendUrl] = useState(API_BASE);

  const handleLogin = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!hallTicket.trim() || !password.trim()) {
      setMessage('Please enter Hall Ticket Number and Password');
      setMessageType('error');
      return;
    }

    setLoading(true);
    setMessage(null);

    try {
      const res = await fetch(`${customBackendUrl}/api/auth/login`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          identifier: hallTicket.trim(),
          password: password.trim(),
        }),
      });

      const data = await res.json();
      if (res.ok && data.accessToken) {
        setMessage(`Welcome back, ${data.student?.firstName || 'Student'}! Session active.`);
        setMessageType('success');
      } else {
        throw new Error(data.message || 'Invalid credentials');
      }
    } catch (err: any) {
      setMessage(err.message || 'Login failed. Ensure backend is running.');
      setMessageType('error');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="pt-32 pb-24 max-w-md mx-auto px-6 space-y-8">
      {/* Header */}
      <div className="text-center space-y-3">
        <div
          onDoubleClick={() => setShowDevModal(true)}
          className="w-16 h-16 rounded-2xl bg-gradient-to-tr from-[#3E7BFF] to-[#00D9F5] flex items-center justify-center text-3xl mx-auto shadow-xl shadow-blue-500/20 cursor-pointer select-none"
          title="Double-click for Developer Settings"
        >
          🎓
        </div>
        <h1 className="text-3xl font-extrabold">Student Login</h1>
        <p className="text-xs text-[#8A97B8]">
          Default password is your Hall Ticket Number. <br />
          <span className="text-[#00D9F5]">Double-click logo above for Dev Settings.</span>
        </p>
      </div>

      {/* Login Card */}
      <div className="glass-panel p-8 rounded-3xl space-y-6 border border-white/10 shadow-2xl">
        <form onSubmit={handleLogin} className="space-y-4">
          <div className="space-y-2">
            <label className="block text-xs font-bold text-[#8A97B8] uppercase tracking-wider">
              Hall Ticket / Mobile *
            </label>
            <div className="relative">
              <User className="w-4 h-4 text-[#8A97B8] absolute left-3.5 top-1/2 -translate-y-1/2" />
              <input
                type="text"
                required
                value={hallTicket}
                onChange={(e) => setHallTicket(e.target.value)}
                placeholder="e.g. JNTUH20CS001"
                className="w-full bg-white/5 border border-white/10 rounded-xl pl-10 pr-4 py-3 text-sm font-medium text-white focus:outline-none focus:border-[#3E7BFF]"
              />
            </div>
          </div>

          <div className="space-y-2">
            <label className="block text-xs font-bold text-[#8A97B8] uppercase tracking-wider">
              Password *
            </label>
            <div className="relative">
              <Lock className="w-4 h-4 text-[#8A97B8] absolute left-3.5 top-1/2 -translate-y-1/2" />
              <input
                type="password"
                required
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                placeholder="Enter password"
                className="w-full bg-white/5 border border-white/10 rounded-xl pl-10 pr-4 py-3 text-sm font-medium text-white focus:outline-none focus:border-[#3E7BFF]"
              />
            </div>
          </div>

          <div className="flex items-center justify-between text-xs text-[#8A97B8]">
            <label className="flex items-center gap-2 cursor-pointer">
              <input
                type="checkbox"
                checked={rememberMe}
                onChange={(e) => setRememberMe(e.target.checked)}
                className="rounded bg-white/5 border-white/10 text-[#3E7BFF]"
              />
              <span>Remember Me</span>
            </label>
            <button
              type="button"
              onClick={() => setShowDevModal(true)}
              className="hover:text-white flex items-center gap-1"
            >
              <Settings className="w-3.5 h-3.5" /> Dev Settings
            </button>
          </div>

          {message && (
            <div
              className={`p-4 rounded-xl text-xs font-bold flex items-center gap-2.5 ${
                messageType === 'success'
                  ? 'bg-[#00E896]/10 border border-[#00E896]/30 text-[#00E896]'
                  : 'bg-red-500/10 border border-red-500/30 text-red-400'
              }`}
            >
              {messageType === 'success' ? <CheckCircle2 className="w-4 h-4" /> : <AlertCircle className="w-4 h-4" />}
              <span>{message}</span>
            </div>
          )}

          <button
            type="submit"
            disabled={loading}
            className="w-full py-3.5 rounded-xl font-bold text-sm gradient-btn flex items-center justify-center gap-2"
          >
            Sign In <ArrowRight className="w-4 h-4" />
          </button>
        </form>

        <div className="pt-4 border-t border-white/10 text-center text-xs text-[#8A97B8]">
          Don't have an account?{' '}
          <Link href="/auth/register" className="font-bold text-[#00D9F5] hover:underline">
            Register Student Account
          </Link>
        </div>
      </div>

      {/* Dev Settings Modal */}
      {showDevModal && (
        <div className="fixed inset-0 z-50 bg-black/80 backdrop-blur-sm flex items-center justify-center p-6">
          <div className="glass-panel p-6 rounded-3xl max-w-sm w-full space-y-4 border border-white/20">
            <h3 className="font-extrabold text-base flex items-center gap-2">
              <Settings className="w-5 h-5 text-[#3E7BFF]" /> Developer Settings
            </h3>
            <p className="text-xs text-[#8A97B8]">Override backend API URL for local testing or custom deployment.</p>

            <div className="space-y-2">
              <label className="text-[10px] font-bold text-[#8A97B8] uppercase">Backend URL</label>
              <input
                type="text"
                value={customBackendUrl}
                onChange={(e) => setCustomBackendUrl(e.target.value)}
                className="w-full bg-white/5 border border-white/10 rounded-xl p-3 text-xs font-mono text-white focus:outline-none focus:border-[#3E7BFF]"
              />
            </div>

            <button
              onClick={() => setShowDevModal(false)}
              className="w-full py-2.5 rounded-xl font-bold text-xs bg-[#3E7BFF] text-white"
            >
              Save & Close
            </button>
          </div>
        </div>
      )}
    </div>
  );
}
