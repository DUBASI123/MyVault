import Link from 'next/link';
import {
  BookOpen,
  BarChart3,
  Briefcase,
  Building2,
  Trophy,
  FileSpreadsheet,
  Calendar,
  Layers,
  Bell,
  Download,
  Upload,
  CheckCircle2,
  FileText,
  Video,
  FlaskConical,
  Zap,
  ArrowRight,
  ShieldCheck,
  Smartphone,
  Cpu,
} from 'lucide-react';

export default function Home() {
  return (
    <div className="space-y-24 pb-20">
      {/* HERO SECTION */}
      <section className="relative pt-32 lg:pt-40 pb-20 overflow-hidden">
        {/* Glow Blobs */}
        <div className="absolute top-0 left-1/2 -translate-x-1/2 w-[800px] h-[400px] bg-gradient-to-tr from-[#3E7BFF]/20 to-[#00D9F5]/20 blur-[120px] rounded-full pointer-events-none -z-10" />

        <div className="max-w-7xl mx-auto px-6 grid grid-cols-1 lg:grid-cols-2 gap-12 items-center">
          {/* Hero Left Content */}
          <div className="space-y-8 text-center lg:text-left">
            <div className="inline-flex items-center gap-2.5 px-4 py-2 rounded-full border border-[#3E7BFF]/30 bg-[#3E7BFF]/10 text-[#7FB4FF] text-xs font-semibold">
              <span className="w-2 h-2 rounded-full bg-[#00D9F5] animate-ping" />
              MyVault v1.2.0 — Powered by AWS RDS & S3
            </div>

            <h1 className="text-4xl sm:text-6xl font-black tracking-tight leading-[1.1]">
              Your College, <br />
              <span className="gradient-text">In Your Pocket.</span>
            </h1>

            <p className="text-lg text-[#8A97B8] max-w-xl mx-auto lg:mx-0 leading-relaxed">
              The all-in-one platform for B.Tech & Degree students. Access study materials, semester results, campus placements, government job alerts, and lab manuals instantly.
            </p>

            <div className="flex flex-wrap items-center justify-center lg:justify-start gap-4">
              <Link
                href="#download"
                className="px-8 py-4 rounded-2xl font-bold text-base gradient-btn flex items-center gap-3"
              >
                <Download className="w-5 h-5" />
                Download Android APK
              </Link>
              <Link
                href="/upload"
                className="px-8 py-4 rounded-2xl font-semibold text-base bg-white/5 hover:bg-white/10 border border-white/10 hover:border-white/20 transition-all flex items-center gap-3"
              >
                <Upload className="w-5 h-5 text-[#00E896]" />
                AWS Upload Portal
              </Link>
            </div>

            {/* Quick Stats */}
            <div className="pt-8 border-t border-white/10 grid grid-cols-3 gap-6 max-w-md mx-auto lg:mx-0">
              <div>
                <div className="text-2xl font-extrabold gradient-text">10+</div>
                <div className="text-xs text-[#8A97B8] mt-1 font-medium">App Modules</div>
              </div>
              <div>
                <div className="text-2xl font-extrabold gradient-text">AWS S3</div>
                <div className="text-xs text-[#8A97B8] mt-1 font-medium">Cloud Storage</div>
              </div>
              <div>
                <div className="text-2xl font-extrabold gradient-text">100%</div>
                <div className="text-xs text-[#8A97B8] mt-1 font-medium">Free for Students</div>
              </div>
            </div>
          </div>

          {/* Hero Right Visual Phone Mockup */}
          <div className="relative flex justify-center">
            <div className="w-[300px] h-[600px] bg-gradient-to-b from-[#0F1628] to-[#080C18] rounded-[44px] border-2 border-white/10 p-4 shadow-2xl shadow-blue-500/20 relative animate-float">
              {/* Notch */}
              <div className="absolute top-3 left-1/2 -translate-x-1/2 w-28 h-5 bg-black rounded-b-xl z-20" />

              {/* Screen Content */}
              <div className="h-full rounded-[32px] bg-[#07080D] p-4 flex flex-col justify-between overflow-hidden relative">
                <div className="pt-6 space-y-4">
                  <div className="flex items-center justify-between">
                    <div className="flex items-center gap-2">
                      <div className="w-7 h-7 rounded-lg bg-gradient-to-tr from-[#3E7BFF] to-[#00D9F5] flex items-center justify-center text-[#04101F] font-black text-xs">
                        🎓
                      </div>
                      <span className="font-extrabold text-xs">MyVault</span>
                    </div>
                    <Bell className="w-4 h-4 text-[#8A97B8]" />
                  </div>

                  <div className="bg-white/5 border border-white/10 rounded-2xl p-3 space-y-2">
                    <div className="text-[10px] text-[#8A97B8] uppercase font-bold tracking-wider">
                      Academic Overview
                    </div>
                    <div className="flex items-center justify-between">
                      <span className="font-bold text-xs">Semester 1 Results</span>
                      <span className="text-[10px] px-2 py-0.5 rounded-full bg-[#00E896]/20 text-[#00E896] font-bold">
                        CGPA 8.4
                      </span>
                    </div>
                  </div>

                  <div className="grid grid-cols-2 gap-2">
                    <div className="bg-white/5 border border-white/10 rounded-xl p-3 text-center space-y-1">
                      <BookOpen className="w-5 h-5 mx-auto text-[#3E7BFF]" />
                      <div className="text-[10px] font-semibold text-[#8A97B8]">Study Hub</div>
                    </div>
                    <div className="bg-white/5 border border-white/10 rounded-xl p-3 text-center space-y-1">
                      <Briefcase className="w-5 h-5 mx-auto text-[#7B5BFF]" />
                      <div className="text-[10px] font-semibold text-[#8A97B8]">Placements</div>
                    </div>
                    <div className="bg-white/5 border border-white/10 rounded-xl p-3 text-center space-y-1">
                      <Building2 className="w-5 h-5 mx-auto text-[#00E896]" />
                      <div className="text-[10px] font-semibold text-[#8A97B8]">Govt Jobs</div>
                    </div>
                    <div className="bg-white/5 border border-white/10 rounded-xl p-3 text-center space-y-1">
                      <Trophy className="w-5 h-5 mx-auto text-[#FFB930]" />
                      <div className="text-[10px] font-semibold text-[#8A97B8]">Exams</div>
                    </div>
                  </div>
                </div>

                <div className="bg-gradient-to-r from-[#3E7BFF]/20 to-[#00D9F5]/20 border border-[#3E7BFF]/30 rounded-xl p-3 text-center">
                  <div className="text-xs font-bold text-white">AWS S3 Integration</div>
                  <div className="text-[9px] text-[#8A97B8]">Presigned URL Streaming</div>
                </div>
              </div>
            </div>

            {/* Floating Badges */}
            <div className="absolute -left-6 top-1/4 glass-panel border border-[#3E7BFF]/30 p-3 rounded-xl shadow-xl hidden sm:flex items-center gap-3">
              <div className="w-8 h-8 rounded-lg bg-[#3E7BFF]/20 flex items-center justify-center text-[#3E7BFF]">
                <FileText className="w-4 h-4" />
              </div>
              <div>
                <div className="text-xs font-bold">DLD_Unit2_Notes.pdf</div>
                <div className="text-[10px] text-[#8A97B8]">Stored on AWS S3</div>
              </div>
            </div>

            <div className="absolute -right-6 bottom-1/4 glass-panel border border-[#00E896]/30 p-3 rounded-xl shadow-xl hidden sm:flex items-center gap-3">
              <div className="w-8 h-8 rounded-lg bg-[#00E896]/20 flex items-center justify-center text-[#00E896]">
                <CheckCircle2 className="w-4 h-4" />
              </div>
              <div>
                <div className="text-xs font-bold">Verified Database</div>
                <div className="text-[10px] text-[#8A97B8]">Amazon RDS PostgreSQL</div>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* FEATURE SHOWCASE GRID */}
      <section id="features" className="max-w-7xl mx-auto px-6">
        <div className="text-center space-y-4 mb-16">
          <div className="inline-block text-xs font-bold uppercase tracking-widest text-[#3E7BFF] px-4 py-1.5 rounded-full bg-[#3E7BFF]/10 border border-[#3E7BFF]/30">
            Comprehensive Suite
          </div>
          <h2 className="text-3xl sm:text-4xl font-extrabold">
            Built Specifically for <span className="gradient-text">Engineering Students</span>
          </h2>
          <p className="text-[#8A97B8] max-w-2xl mx-auto text-base">
            Everything you need for your B.Tech or Degree course — organized by Year, Semester, Branch, and Subject.
          </p>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {[
            {
              icon: BookOpen,
              color: 'text-[#3E7BFF]',
              bg: 'bg-[#3E7BFF]/10',
              title: 'Academic Study Hub',
              desc: 'Browse lecture notes, lab manuals, PDFs, and classroom video recordings categorized by Unit 1-5.',
            },
            {
              icon: BarChart3,
              color: 'text-[#00D9F5]',
              bg: 'bg-[#00D9F5]/10',
              title: 'Semester Results & CGPA',
              desc: 'Check subject-wise marks, grades, and CGPA reports instantly with full history.',
            },
            {
              icon: Briefcase,
              color: 'text-[#7B5BFF]',
              bg: 'bg-[#7B5BFF]/10',
              title: 'Campus Placements',
              desc: 'Real-time updates on placement drives, eligibility criteria, interview rounds, and application links.',
            },
            {
              icon: Building2,
              color: 'text-[#00E896]',
              bg: 'bg-[#00E896]/10',
              title: 'Government Job Alerts',
              desc: 'Curated notifications for UPSC, SSC, TSPSC, RRB, and Public Sector Unit (PSU) engineering roles.',
            },
            {
              icon: Trophy,
              color: 'text-[#FFB930]',
              bg: 'bg-[#FFB930]/10',
              title: 'Competitive Exams',
              desc: 'GATE, GRE, CAT, and TOEFL study series, syllabus blueprints, and aptitude model papers.',
            },
            {
              icon: FileSpreadsheet,
              color: 'text-[#FF5B6B]',
              bg: 'bg-[#FF5B6B]/10',
              title: 'Resume Builder',
              desc: 'Generate a industry-ready technical resume pre-populated with your academic achievements.',
            },
            {
              icon: Calendar,
              color: 'text-[#3E7BFF]',
              bg: 'bg-[#3E7BFF]/10',
              title: 'Study Planner',
              desc: 'Track mid-exam timetables, subject revisions, and assignment deadlines on your schedule.',
            },
            {
              icon: Layers,
              color: 'text-[#00D9F5]',
              bg: 'bg-[#00D9F5]/10',
              title: 'Projects Hub',
              desc: 'Explore final-year mini & major project ideas, code repositories, and documentation templates.',
            },
            {
              icon: Bell,
              color: 'text-[#7B5BFF]',
              bg: 'bg-[#7B5BFF]/10',
              title: 'Instant College Notices',
              desc: 'Official college announcements, fee payment reminders, and timetable changes delivered live.',
            },
          ].map((item, idx) => (
            <div key={idx} className="glass-panel glass-panel-hover p-8 rounded-3xl space-y-4">
              <div className={`w-12 h-12 rounded-2xl ${item.bg} flex items-center justify-center`}>
                <item.icon className={`w-6 h-6 ${item.color}`} />
              </div>
              <h3 className="font-bold text-lg">{item.title}</h3>
              <p className="text-sm text-[#8A97B8] leading-relaxed">{item.desc}</p>
            </div>
          ))}
        </div>
      </section>

      {/* CONTENT TYPES */}
      <section className="max-w-7xl mx-auto px-6">
        <div className="glass-panel p-10 rounded-3xl space-y-12 border border-[#3E7BFF]/20">
          <div className="flex flex-col md:flex-row md:items-end justify-between gap-6">
            <div className="space-y-3">
              <span className="text-xs font-bold uppercase tracking-widest text-[#00D9F5]">Organized Learning</span>
              <h2 className="text-3xl font-extrabold">All Types of Academic Content</h2>
            </div>
            <Link href="/academic" className="text-sm font-bold text-[#3E7BFF] hover:underline flex items-center gap-2">
              Explore Academic Hub <ArrowRight className="w-4 h-4" />
            </Link>
          </div>

          <div className="grid grid-cols-2 sm:grid-cols-4 gap-4">
            {[
              { label: 'Notes (PDF)', icon: FileText, desc: 'Unit-wise lecture notes' },
              { label: 'Videos', icon: Video, desc: 'Classroom recordings' },
              { label: 'Lab Manuals', icon: FlaskConical, desc: 'Procedures & codes' },
              { label: 'Cheat Sheets', icon: Zap, desc: 'Revision formulas' },
            ].map((type, i) => (
              <div key={i} className="bg-white/5 border border-white/10 rounded-2xl p-5 space-y-3 text-center hover:bg-white/10 transition-all">
                <type.icon className="w-8 h-8 mx-auto text-[#00D9F5]" />
                <div className="font-bold text-sm">{type.label}</div>
                <div className="text-xs text-[#8A97B8]">{type.desc}</div>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* HOW IT WORKS */}
      <section id="how" className="max-w-7xl mx-auto px-6">
        <div className="text-center space-y-4 mb-16">
          <div className="inline-block text-xs font-bold uppercase tracking-widest text-[#00E896] px-4 py-1.5 rounded-full bg-[#00E896]/10 border border-[#00E896]/30">
            Simple Onboarding
          </div>
          <h2 className="text-3xl sm:text-4xl font-extrabold">
            Get Started in <span className="gradient-text">4 Simple Steps</span>
          </h2>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-4 gap-8 relative">
          {[
            { step: '01', title: 'Download APK', desc: 'Install MyVault directly on your Android phone.' },
            { step: '02', title: 'Register Account', desc: 'Enter your Hall Ticket Number & select your Branch.' },
            { step: '03', title: 'Log In', desc: 'Default password is your Hall Ticket Number.' },
            { step: '04', title: 'Access Materials', desc: 'Browse notes, results, placements & AWS uploads.' },
          ].map((s, idx) => (
            <div key={idx} className="glass-panel p-6 rounded-2xl text-center space-y-3 relative">
              <div className="w-12 h-12 rounded-2xl bg-gradient-to-tr from-[#3E7BFF] to-[#00D9F5] text-[#04101F] font-black text-lg flex items-center justify-center mx-auto shadow-lg">
                {s.step}
              </div>
              <h3 className="font-bold text-base">{s.title}</h3>
              <p className="text-xs text-[#8A97B8] leading-relaxed">{s.desc}</p>
            </div>
          ))}
        </div>
      </section>

      {/* DOWNLOAD BANNER */}
      <section id="download" className="max-w-7xl mx-auto px-6">
        <div className="bg-gradient-to-br from-[#0F1628] via-[#0C1020] to-[#080C18] border border-[#3E7BFF]/30 p-12 md:p-16 rounded-[36px] text-center space-y-8 relative overflow-hidden">
          <div className="inline-flex items-center gap-2 px-4 py-1.5 rounded-full bg-[#00E896]/10 border border-[#00E896]/30 text-[#00E896] text-xs font-semibold">
            <ShieldCheck className="w-4 h-4" />
            MyVault v1.2.0 Release APK · Verified Build
          </div>

          <h2 className="text-3xl sm:text-5xl font-black max-w-2xl mx-auto leading-tight">
            Ready to Accelerate Your <br />
            <span className="gradient-text">College Journey?</span>
          </h2>

          <p className="text-[#8A97B8] max-w-xl mx-auto text-base">
            Free for all B.Tech & Degree students. Download the official APK release file to get instant access.
          </p>

          <div className="flex flex-wrap items-center justify-center gap-4">
            <a
              href="/download-apk"
              className="px-8 py-4 rounded-2xl font-bold text-base gradient-btn flex items-center gap-3"
            >
              <Download className="w-5 h-5" />
              Download Release APK (20.4 MB)
            </a>
            <a
              href="https://github.com/DUBASI123/MyVault"
              target="_blank"
              rel="noreferrer"
              className="px-8 py-4 rounded-2xl font-semibold text-base bg-white/5 hover:bg-white/10 border border-white/10 transition-all flex items-center gap-3"
            >
              <Cpu className="w-5 h-5 text-[#00D9F5]" />
              View Source on GitHub
            </a>
          </div>
        </div>
      </section>
    </div>
  );
}
