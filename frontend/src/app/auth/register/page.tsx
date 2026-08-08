'use client';

import { useState } from 'react';
import Link from 'next/link';
import { User, Lock, Mail, Phone, GraduationCap, Building, ArrowRight, CheckCircle2, AlertCircle } from 'lucide-react';

const API_BASE = 'https://myvault-f08x.onrender.com';

export default function RegisterPage() {
  const [courseType, setCourseType] = useState<'btech' | 'degree'>('btech');
  const [lastName, setLastName] = useState('');
  const [firstName, setFirstName] = useState('');
  const [hallTicket, setHallTicket] = useState('');
  const [mobile, setMobile] = useState('');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [useDefaultPassword, setUseDefaultPassword] = useState(true);
  const [branch, setBranch] = useState('CSE');
  const [semester, setSemester] = useState(1);
  const [collegeName, setCollegeName] = useState('');

  const [loading, setLoading] = useState(false);
  const [message, setMessage] = useState<string | null>(null);
  const [messageType, setMessageType] = useState<'success' | 'error' | null>(null);

  const formattedFullName = `${lastName.trim()} ${firstName.trim()}`.trim();

  const handleRegister = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!firstName.trim() || !lastName.trim() || !hallTicket.trim() || !mobile.trim()) {
      setMessage('Please fill in all required fields marked with *');
      setMessageType('error');
      return;
    }

    const finalPassword = useDefaultPassword ? hallTicket.trim() : password;
    if (!finalPassword) {
      setMessage('Please specify a password or enable default password');
      setMessageType('error');
      return;
    }

    setLoading(true);
    setMessage(null);

    try {
      const res = await fetch(`${API_BASE}/api/auth/register`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          firstName: firstName.trim(),
          lastName: lastName.trim(),
          fullNameAadhar: formattedFullName,
          hallTicket: hallTicket.trim(),
          mobile: mobile.trim(),
          email: email.trim() || undefined,
          password: finalPassword,
          course: courseType === 'btech' ? 'B.Tech' : 'Degree',
          branch,
          semester,
          university: collegeName.trim() || undefined,
        }),
      });

      const data = await res.json();
      if (res.ok) {
        setMessage('✅ Account created successfully! Redirecting to login...');
        setMessageType('success');
        setTimeout(() => {
          window.location.href = '/auth/login';
        }, 1500);
      } else {
        throw new Error(data.message || 'Registration failed');
      }
    } catch (err: any) {
      setMessage(err.message || 'Registration failed. Try again.');
      setMessageType('error');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="pt-32 pb-24 max-w-xl mx-auto px-6 space-y-8">
      {/* Header */}
      <div className="text-center space-y-3">
        <h1 className="text-3xl font-extrabold">Create Student Account</h1>
        <p className="text-xs text-[#8A97B8]">
          Format: <span className="font-bold text-white">Lastname Firstname</span> (e.g. Dubasi Shivashankar)
        </p>
      </div>

      {/* Course Type Toggle */}
      <div className="glass-panel p-2 rounded-2xl flex items-center gap-2 border border-white/10">
        <button
          type="button"
          onClick={() => setCourseType('btech')}
          className={`flex-1 py-3 rounded-xl text-xs font-extrabold transition-all ${
            courseType === 'btech'
              ? 'bg-gradient-to-r from-[#3E7BFF] to-[#00D9F5] text-[#04101F] shadow-lg'
              : 'text-[#8A97B8] hover:text-white'
          }`}
        >
          🎓 B.Tech Engineering
        </button>
        <button
          type="button"
          onClick={() => setCourseType('degree')}
          className={`flex-1 py-3 rounded-xl text-xs font-extrabold transition-all ${
            courseType === 'degree'
              ? 'bg-gradient-to-r from-[#3E7BFF] to-[#00D9F5] text-[#04101F] shadow-lg'
              : 'text-[#8A97B8] hover:text-white'
          }`}
        >
          📜 Degree (B.Sc / B.Com / B.A)
        </button>
      </div>

      {/* Form Card */}
      <div className="glass-panel p-8 rounded-3xl space-y-6 border border-white/10 shadow-2xl">
        <form onSubmit={handleRegister} className="space-y-4">
          {/* Name Row */}
          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <div className="space-y-2">
              <label className="block text-xs font-bold text-[#8A97B8] uppercase tracking-wider">
                Last Name (Surname) *
              </label>
              <input
                type="text"
                required
                value={lastName}
                onChange={(e) => setLastName(e.target.value)}
                placeholder="e.g. Dubasi"
                className="w-full bg-white/5 border border-white/10 rounded-xl px-4 py-3 text-sm text-white focus:outline-none focus:border-[#3E7BFF]"
              />
            </div>

            <div className="space-y-2">
              <label className="block text-xs font-bold text-[#8A97B8] uppercase tracking-wider">
                First Name *
              </label>
              <input
                type="text"
                required
                value={firstName}
                onChange={(e) => setFirstName(e.target.value)}
                placeholder="e.g. Shivashankar"
                className="w-full bg-white/5 border border-white/10 rounded-xl px-4 py-3 text-sm text-white focus:outline-none focus:border-[#3E7BFF]"
              />
            </div>
          </div>

          {formattedFullName && (
            <div className="text-xs text-[#00D9F5] font-semibold bg-[#00D9F5]/10 p-3 rounded-xl">
              Formatted Full Name: {formattedFullName}
            </div>
          )}

          {/* Hall Ticket & Mobile */}
          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <div className="space-y-2">
              <label className="block text-xs font-bold text-[#8A97B8] uppercase tracking-wider">
                Hall Ticket Number *
              </label>
              <input
                type="text"
                required
                value={hallTicket}
                onChange={(e) => setHallTicket(e.target.value)}
                placeholder="e.g. 20CS001"
                className="w-full bg-white/5 border border-white/10 rounded-xl px-4 py-3 text-sm text-white focus:outline-none focus:border-[#3E7BFF]"
              />
            </div>

            <div className="space-y-2">
              <label className="block text-xs font-bold text-[#8A97B8] uppercase tracking-wider">
                Mobile Number *
              </label>
              <input
                type="tel"
                required
                value={mobile}
                onChange={(e) => setMobile(e.target.value)}
                placeholder="10-digit mobile"
                className="w-full bg-white/5 border border-white/10 rounded-xl px-4 py-3 text-sm text-white focus:outline-none focus:border-[#3E7BFF]"
              />
            </div>
          </div>

          {/* Email */}
          <div className="space-y-2">
            <label className="block text-xs font-bold text-[#8A97B8] uppercase tracking-wider">
              Email Address (Optional)
            </label>
            <input
              type="email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              placeholder="student@example.com"
              className="w-full bg-white/5 border border-white/10 rounded-xl px-4 py-3 text-sm text-white focus:outline-none focus:border-[#3E7BFF]"
            />
          </div>

          {/* Password Options */}
          <div className="space-y-3 pt-2">
            <label className="flex items-center gap-2 text-xs font-semibold text-[#8A97B8] cursor-pointer">
              <input
                type="checkbox"
                checked={useDefaultPassword}
                onChange={(e) => setUseDefaultPassword(e.target.checked)}
                className="rounded bg-white/5 border-white/10 text-[#3E7BFF]"
              />
              <span>Use Hall Ticket Number as Password (Recommended)</span>
            </label>

            {!useDefaultPassword && (
              <input
                type="password"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                placeholder="Set custom password"
                className="w-full bg-white/5 border border-white/10 rounded-xl px-4 py-3 text-sm text-white focus:outline-none focus:border-[#3E7BFF]"
              />
            )}
          </div>

          {/* Branch & Semester */}
          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <div className="space-y-2">
              <label className="block text-xs font-bold text-[#8A97B8] uppercase tracking-wider">
                Branch / Specialization
              </label>
              <select
                value={branch}
                onChange={(e) => setBranch(e.target.value)}
                className="w-full bg-[#0C1020] border border-white/10 rounded-xl px-4 py-3 text-sm font-medium text-white focus:outline-none focus:border-[#3E7BFF]"
              >
                <option value="CSE">CSE</option>
                <option value="ECE">ECE</option>
                <option value="CSE (AI & ML)">CSE (AI & ML)</option>
                <option value="EEE">EEE</option>
                <option value="MECH">MECH</option>
                <option value="CIVIL">CIVIL</option>
              </select>
            </div>

            <div className="space-y-2">
              <label className="block text-xs font-bold text-[#8A97B8] uppercase tracking-wider">
                Semester
              </label>
              <select
                value={semester}
                onChange={(e) => setSemester(Number(e.target.value))}
                className="w-full bg-[#0C1020] border border-white/10 rounded-xl px-4 py-3 text-sm font-medium text-white focus:outline-none focus:border-[#3E7BFF]"
              >
                {[1, 2, 3, 4, 5, 6, 7, 8].map((s) => (
                  <option key={s} value={s}>Semester {s}</option>
                ))}
              </select>
            </div>
          </div>

          {/* Status Message */}
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
            className="w-full py-4 rounded-2xl font-bold text-sm gradient-btn flex items-center justify-center gap-2"
          >
            Create Account <ArrowRight className="w-4 h-4" />
          </button>
        </form>

        <div className="pt-4 border-t border-white/10 text-center text-xs text-[#8A97B8]">
          Already registered?{' '}
          <Link href="/auth/login" className="font-bold text-[#00D9F5] hover:underline">
            Sign In Here
          </Link>
        </div>
      </div>
    </div>
  );
}
