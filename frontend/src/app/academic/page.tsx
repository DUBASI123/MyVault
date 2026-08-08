'use client';

import { useState, useEffect } from 'react';
import { BookOpen, FileText, Video, FlaskConical, Download, Search, Sparkles } from 'lucide-react';

const API_BASE = 'https://myvault-f08x.onrender.com';

interface Subject {
  id: string;
  name: string;
  code?: string;
  branch: string;
  semester: number;
}

interface ContentItem {
  id: string;
  title: string;
  contentType: string;
  unitNumber?: number;
  fileUrl?: string;
  description?: string;
  createdAt: string;
}

export default function AcademicHubPage() {
  const [branch, setBranch] = useState('ECE');
  const [semester, setSemester] = useState(1);
  const [subjects, setSubjects] = useState<Subject[]>([]);
  const [selectedSubject, setSelectedSubject] = useState<Subject | null>(null);
  const [contents, setContents] = useState<ContentItem[]>([]);
  const [selectedType, setSelectedType] = useState('all');
  const [searchQuery, setSearchQuery] = useState('');
  const [loading, setLoading] = useState(false);

  // Load subjects
  useEffect(() => {
    async function loadSubjects() {
      setLoading(true);
      try {
        const res = await fetch(`${API_BASE}/api/academic/subjects?branch=${encodeURIComponent(branch)}&semester=${semester}`);
        if (res.ok) {
          const data = await res.json();
          setSubjects(data);
          if (data.length > 0) setSelectedSubject(data[0]);
          else setSelectedSubject(null);
        }
      } catch (err) {
        console.error(err);
      } finally {
        setLoading(false);
      }
    }
    loadSubjects();
  }, [branch, semester]);

  // Load subject contents
  useEffect(() => {
    async function loadContents() {
      if (!selectedSubject) {
        setContents([]);
        return;
      }
      try {
        const res = await fetch(`${API_BASE}/api/academic/subjects/${selectedSubject.id}/contents?type=${selectedType}`);
        if (res.ok) {
          const data = await res.json();
          setContents(data);
        }
      } catch (err) {
        console.error(err);
      }
    }
    loadContents();
  }, [selectedSubject, selectedType]);

  const filteredContents = contents.filter((c) =>
    c.title.toLowerCase().includes(searchQuery.toLowerCase())
  );

  return (
    <div className="pt-32 pb-24 max-w-7xl mx-auto px-6 space-y-10">
      {/* Header */}
      <div className="text-center space-y-3">
        <div className="inline-flex items-center gap-2 px-4 py-1.5 rounded-full bg-[#3E7BFF]/10 border border-[#3E7BFF]/30 text-[#7FB4FF] text-xs font-bold uppercase tracking-wider">
          <BookOpen className="w-4 h-4 text-[#3E7BFF]" />
          AWS RDS Academic Repository
        </div>
        <h1 className="text-3xl sm:text-5xl font-black">Academic Study Hub</h1>
        <p className="text-[#8A97B8] text-base max-w-xl mx-auto">
          Access notes, video lectures, lab manuals, and previous question papers for your semester.
        </p>
      </div>

      {/* Filter Bar */}
      <div className="glass-panel p-6 rounded-3xl border border-white/10 grid grid-cols-1 sm:grid-cols-3 gap-4">
        <div>
          <label className="block text-xs font-bold text-[#8A97B8] uppercase tracking-wider mb-2">Branch</label>
          <select
            value={branch}
            onChange={(e) => setBranch(e.target.value)}
            className="w-full bg-[#0C1020] border border-white/10 rounded-xl px-4 py-2.5 text-sm font-medium text-white focus:outline-none focus:border-[#3E7BFF]"
          >
            <option value="ECE">Electronics (ECE)</option>
            <option value="CSE">CSE</option>
            <option value="CSE (AI & ML)">CSE (AI & ML)</option>
            <option value="EEE">EEE</option>
            <option value="MECH">Mechanical (MECH)</option>
            <option value="CIVIL">Civil (CIVIL)</option>
          </select>
        </div>

        <div>
          <label className="block text-xs font-bold text-[#8A97B8] uppercase tracking-wider mb-2">Semester</label>
          <select
            value={semester}
            onChange={(e) => setSemester(Number(e.target.value))}
            className="w-full bg-[#0C1020] border border-white/10 rounded-xl px-4 py-2.5 text-sm font-medium text-white focus:outline-none focus:border-[#3E7BFF]"
          >
            {[1, 2, 3, 4, 5, 6, 7, 8].map((s) => (
              <option key={s} value={s}>Semester {s}</option>
            ))}
          </select>
        </div>

        <div>
          <label className="block text-xs font-bold text-[#8A97B8] uppercase tracking-wider mb-2">Search Material</label>
          <div className="relative">
            <Search className="w-4 h-4 text-[#8A97B8] absolute left-3 top-1/2 -translate-y-1/2" />
            <input
              type="text"
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              placeholder="Search by title or topic..."
              className="w-full bg-white/5 border border-white/10 rounded-xl pl-9 pr-4 py-2.5 text-sm text-white focus:outline-none focus:border-[#3E7BFF]"
            />
          </div>
        </div>
      </div>

      {/* Main Content Layout */}
      <div className="grid grid-cols-1 lg:grid-cols-4 gap-8">
        {/* Left: Subjects List */}
        <div className="space-y-3">
          <h3 className="text-xs font-bold text-[#8A97B8] uppercase tracking-wider px-2">
            Subjects ({subjects.length})
          </h3>
          <div className="space-y-2">
            {subjects.length > 0 ? (
              subjects.map((sub) => (
                <button
                  key={sub.id}
                  onClick={() => setSelectedSubject(sub)}
                  className={`w-full text-left p-4 rounded-2xl border transition-all ${
                    selectedSubject?.id === sub.id
                      ? 'bg-gradient-to-r from-[#3E7BFF]/20 to-[#00D9F5]/20 border-[#3E7BFF] text-white font-bold'
                      : 'glass-panel border-white/5 text-[#8A97B8] hover:text-white hover:border-white/20'
                  }`}
                >
                  <div className="text-sm">{sub.name}</div>
                  {sub.code && <div className="text-xs text-[#00D9F5] mt-1 font-semibold">{sub.code}</div>}
                </button>
              ))
            ) : (
              <div className="glass-panel p-6 rounded-2xl text-center text-xs text-[#8A97B8]">
                No subjects found.
              </div>
            )}
          </div>
        </div>

        {/* Right: Content Cards */}
        <div className="lg:col-span-3 space-y-6">
          <div className="flex items-center justify-between">
            <h2 className="text-xl font-bold">
              {selectedSubject ? selectedSubject.name : 'Select a Subject'}
            </h2>
            <div className="flex items-center gap-2">
              {['all', 'notes', 'video', 'lab-manual'].map((t) => (
                <button
                  key={t}
                  onClick={() => setSelectedType(t)}
                  className={`px-3 py-1.5 rounded-lg text-xs font-bold capitalize transition-all ${
                    selectedType === t ? 'bg-[#3E7BFF] text-white' : 'bg-white/5 text-[#8A97B8] hover:text-white'
                  }`}
                >
                  {t}
                </button>
              ))}
            </div>
          </div>

          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
            {filteredContents.length > 0 ? (
              filteredContents.map((c) => (
                <div key={c.id} className="glass-panel glass-panel-hover p-6 rounded-2xl space-y-4 border border-white/10 flex flex-col justify-between">
                  <div className="space-y-3">
                    <div className="flex items-center justify-between">
                      <span className="text-[10px] font-bold uppercase tracking-wider px-2.5 py-1 rounded-full bg-[#3E7BFF]/10 text-[#3E7BFF]">
                        Unit {c.unitNumber || 1} · {c.contentType}
                      </span>
                      {c.contentType === 'video' ? (
                        <Video className="w-5 h-5 text-[#7B5BFF]" />
                      ) : c.contentType === 'lab-manual' ? (
                        <FlaskConical className="w-5 h-5 text-[#00E896]" />
                      ) : (
                        <FileText className="w-5 h-5 text-[#00D9F5]" />
                      )}
                    </div>
                    <h4 className="font-bold text-base text-white">{c.title}</h4>
                    {c.description && <p className="text-xs text-[#8A97B8] line-clamp-2">{c.description}</p>}
                  </div>

                  {c.fileUrl ? (
                    <a
                      href={c.fileUrl}
                      target="_blank"
                      rel="noreferrer"
                      className="w-full py-2.5 rounded-xl font-bold text-xs bg-white/10 hover:bg-[#3E7BFF] text-white transition-all flex items-center justify-center gap-2 mt-4"
                    >
                      <Download className="w-4 h-4" /> Download Material
                    </a>
                  ) : (
                    <div className="text-xs text-[#8A97B8] italic mt-4">Preview available in mobile app</div>
                  )}
                </div>
              ))
            ) : (
              <div className="sm:col-span-2 glass-panel p-12 rounded-3xl text-center space-y-3">
                <Sparkles className="w-8 h-8 text-[#3E7BFF] mx-auto" />
                <div className="font-bold text-base">No materials uploaded for this subject yet</div>
                <p className="text-xs text-[#8A97B8]">Faculty can upload materials via the Upload Portal.</p>
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  );
}
