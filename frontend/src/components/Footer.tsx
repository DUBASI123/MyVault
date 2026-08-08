import Link from 'next/link';
import { GraduationCap, Code2, Code, ExternalLink } from 'lucide-react';

export default function Footer() {
  return (
    <footer className="bg-[#0C1020] border-t border-white/10 pt-16 pb-12 text-sm text-[#8A97B8]">
      <div className="max-w-7xl mx-auto px-6 grid grid-cols-1 md:grid-cols-4 gap-12 mb-12">
        {/* Brand */}
        <div className="space-y-4">
          <div className="flex items-center gap-3">
            <div className="w-9 h-9 rounded-xl bg-gradient-to-br from-[#3E7BFF] to-[#00D9F5] flex items-center justify-center text-[#04101F]">
              <GraduationCap className="w-5 h-5" />
            </div>
            <span className="font-extrabold text-lg text-white">MyVault</span>
          </div>
          <p className="leading-relaxed text-xs text-[#8A97B8] max-w-xs">
            The ultimate all-in-one college companion for B.Tech & Degree students. Study materials, exam results, placement drives & government job notifications in one place.
          </p>
        </div>

        {/* Quick Links */}
        <div className="space-y-3">
          <h4 className="font-bold text-xs uppercase tracking-wider text-white">Features</h4>
          <ul className="space-y-2">
            <li><Link href="/academic" className="hover:text-white transition-colors">Academic Study Hub</Link></li>
            <li><Link href="/placements" className="hover:text-white transition-colors">Campus Placements</Link></li>
            <li><Link href="/upload" className="hover:text-white transition-colors">AWS Upload Portal</Link></li>
            <li><Link href="/#features" className="hover:text-white transition-colors">Resume Builder</Link></li>
          </ul>
        </div>

        {/* Platform Stack */}
        <div className="space-y-3">
          <h4 className="font-bold text-xs uppercase tracking-wider text-white">AWS Production Architecture</h4>
          <ul className="space-y-2">
            <li className="flex items-center gap-2">
              <span className="w-2 h-2 rounded-full bg-[#00E896]" />
              Amazon RDS PostgreSQL
            </li>
            <li className="flex items-center gap-2">
              <span className="w-2 h-2 rounded-full bg-[#00D9F5]" />
              Amazon S3 File Storage
            </li>
            <li className="flex items-center gap-2">
              <span className="w-2 h-2 rounded-full bg-[#3E7BFF]" />
              NestJS Node.js Server
            </li>
            <li className="flex items-center gap-2">
              <span className="w-2 h-2 rounded-full bg-[#7B5BFF]" />
              Next.js + React + Tailwind
            </li>
          </ul>
        </div>

        {/* API & Code */}
        <div className="space-y-3">
          <h4 className="font-bold text-xs uppercase tracking-wider text-white">Developer Links</h4>
          <ul className="space-y-2">
            <li>
              <a href="https://myvault-backend.onrender.com/api/docs" target="_blank" rel="noreferrer" className="hover:text-white transition-colors flex items-center gap-1.5">
                <Code className="w-4 h-4 text-[#00D9F5]" />
                Swagger API Docs
                <ExternalLink className="w-3 h-3 text-[#4A5578]" />
              </a>
            </li>
            <li>
              <a href="https://github.com/DUBASI123/MyVault" target="_blank" rel="noreferrer" className="hover:text-white transition-colors flex items-center gap-1.5">
                <Code2 className="w-4 h-4 text-white" />
                GitHub Repository
                <ExternalLink className="w-3 h-3 text-[#4A5578]" />
              </a>
            </li>
            <li>
              <Link href="/auth/login" className="hover:text-white transition-colors">
                Developer Settings
              </Link>
            </li>
          </ul>
        </div>
      </div>

      <div className="max-w-7xl mx-auto px-6 pt-8 border-t border-white/5 flex flex-col md:flex-row items-center justify-between gap-4 text-xs text-[#4A5578]">
        <p>© 2026 MyVault Engineering. All rights reserved.</p>
        <p className="flex items-center gap-1">
          Built with <span className="text-red-500">❤️</span> for B.Tech & Degree Students
        </p>
      </div>
    </footer>
  );
}
