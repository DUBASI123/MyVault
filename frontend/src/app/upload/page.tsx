'use client';

import { useState, useEffect, useRef } from 'react';
import {
  Upload,
  CloudUpload,
  FileCheck,
  CheckCircle2,
  AlertCircle,
  Loader2,
  BookOpen,
  Briefcase,
  Building2,
  Bell,
  Sparkles,
} from 'lucide-react';

const API_BASE = 'https://myvault-f08x.onrender.com';

interface Subject {
  id: string;
  name: string;
  code?: string;
  branch: string;
  semester: number;
}

export default function UploadPage() {
  const [activeTab, setActiveTab] = useState<'academic' | 'placements' | 'govt' | 'notices'>('academic');

  // Academic Upload Form State
  const [selectedFile, setSelectedFile] = useState<File | null>(null);
  const [title, setTitle] = useState('');
  const [branch, setBranch] = useState('ECE');
  const [semester, setSemester] = useState(1);
  const [subjects, setSubjects] = useState<Subject[]>([]);
  const [selectedSubjectId, setSelectedSubjectId] = useState('');
  const [unitNumber, setUnitNumber] = useState(1);
  const [contentType, setContentType] = useState('notes');
  const [description, setDescription] = useState('');

  // Placement / Job Upload Form State
  const [jobTitle, setJobTitle] = useState('');
  const [companyName, setCompanyName] = useState('');
  const [jobType, setJobType] = useState('IT'); // IT | Core | Govt
  const [jobLink, setJobLink] = useState('');

  // Notice Form State
  const [noticeTitle, setNoticeTitle] = useState('');
  const [noticeMessage, setNoticeMessage] = useState('');
  const [noticeCategory, setNoticeCategory] = useState('exam');

  const [loadingSubjects, setLoadingSubjects] = useState(false);
  const [uploading, setUploading] = useState(false);
  const [progress, setProgress] = useState(0);
  const [statusMessage, setStatusMessage] = useState<string | null>(null);
  const [statusType, setStatusType] = useState<'success' | 'error' | null>(null);

  const fileInputRef = useRef<HTMLInputElement>(null);

  // Load subjects from NestJS API (backed by AWS RDS)
  useEffect(() => {
    async function fetchSubjects() {
      setLoadingSubjects(true);
      try {
        const res = await fetch(
          `${API_BASE}/api/academic/subjects?branch=${encodeURIComponent(branch)}&semester=${semester}`
        );
        if (res.ok) {
          const data = await res.json();
          setSubjects(data);
          if (data.length > 0) setSelectedSubjectId(data[0].id);
          else setSelectedSubjectId('');
        }
      } catch (err) {
        console.error('Failed to load subjects:', err);
      } finally {
        setLoadingSubjects(false);
      }
    }
    fetchSubjects();
  }, [branch, semester]);

  const handleFileDrop = (e: React.DragEvent) => {
    e.preventDefault();
    if (e.dataTransfer.files && e.dataTransfer.files[0]) {
      setSelectedFile(e.dataTransfer.files[0]);
    }
  };

  const handleFileSelect = (e: React.ChangeEvent<HTMLInputElement>) => {
    if (e.target.files && e.target.files[0]) {
      setSelectedFile(e.target.files[0]);
    }
  };

  // Helper to upload file to AWS S3 via presigned URL
  const uploadFileToS3 = async (file: File, folder: string) => {
    const presignRes = await fetch(
      `${API_BASE}/api/s3/presign-upload?fileName=${encodeURIComponent(
        file.name
      )}&contentType=${encodeURIComponent(
        file.type || 'application/octet-stream'
      )}&folder=${folder}`
    );

    if (!presignRes.ok) throw new Error('Failed to obtain AWS S3 upload authorization');
    const { uploadUrl, fileUrl, key } = await presignRes.json();

    const s3UploadRes = await fetch(uploadUrl, {
      method: 'PUT',
      headers: {
        'Content-Type': file.type || 'application/octet-stream',
      },
      body: file,
    });

    if (!s3UploadRes.ok) throw new Error(`AWS S3 upload failed (${s3UploadRes.status})`);
    return { fileUrl, key };
  };

  // Handle Academic Material Upload
  const handleAcademicUpload = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!title.trim()) return setStatus('Please enter a title', 'error');
    if (!selectedSubjectId) return setStatus('Please select a subject', 'error');
    if (!selectedFile) return setStatus('Please attach a file to upload', 'error');

    setUploading(true);
    setProgress(20);
    setStatusMessage('Uploading study file to AWS S3 bucket...');

    try {
      const { fileUrl, key } = await uploadFileToS3(selectedFile, 'study-materials');

      setProgress(70);
      setStatusMessage('Registering in AWS RDS PostgreSQL...');

      const dbRes = await fetch(`${API_BASE}/api/academic/contents`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          subjectId: selectedSubjectId,
          title,
          contentType,
          unitNumber,
          fileUrl,
          storagePath: key,
          description: description.trim() || undefined,
        }),
      });

      if (!dbRes.ok) throw new Error('Failed to record metadata in database');

      setProgress(100);
      setStatus('✅ Successfully uploaded! Live in MyVault app & website!', 'success');
      setTitle('');
      setSelectedFile(null);
      setDescription('');
    } catch (err: any) {
      setStatus(`❌ ${err.message || 'Upload failed'}`, 'error');
    } finally {
      setUploading(false);
    }
  };

  // Handle Placement Drive & Job Upload
  const handlePlacementUpload = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!jobTitle.trim()) return setStatus('Please enter job title', 'error');
    if (!companyName.trim()) return setStatus('Please enter company name', 'error');

    setUploading(true);
    setProgress(30);
    setStatusMessage('Saving Placement Drive in database...');

    try {
      let documentUrl = jobLink;
      if (selectedFile) {
        setStatusMessage('Uploading job notification doc to AWS S3...');
        const { fileUrl } = await uploadFileToS3(selectedFile, 'placements');
        if (!jobLink) documentUrl = fileUrl;
      }

      const dbRes = await fetch(`${API_BASE}/api/content/internships`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          title: jobTitle,
          company: companyName,
          type: jobType,
          link: documentUrl || undefined,
        }),
      });

      if (!dbRes.ok) throw new Error('Failed to save job opportunity');

      setProgress(100);
      setStatus('✅ Job Opportunity Published! Instantly visible in app & website!', 'success');
      setJobTitle('');
      setCompanyName('');
      setJobLink('');
      setSelectedFile(null);
    } catch (err: any) {
      setStatus(`❌ ${err.message || 'Upload failed'}`, 'error');
    } finally {
      setUploading(false);
    }
  };

  // Handle Notice / Alert Upload
  const handleNoticeUpload = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!noticeTitle.trim()) return setStatus('Please enter notice title', 'error');
    if (!noticeMessage.trim()) return setStatus('Please enter notice message', 'error');

    setUploading(true);
    setProgress(40);
    setStatusMessage('Publishing announcement alert...');

    try {
      const dbRes = await fetch(`${API_BASE}/api/content/notifications`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          title: noticeTitle,
          message: noticeMessage,
          category: noticeCategory,
        }),
      });

      if (!dbRes.ok) throw new Error('Failed to publish notice');

      setProgress(100);
      setStatus('✅ Announcement Published! Live ticker updated across mobile app & website!', 'success');
      setNoticeTitle('');
      setNoticeMessage('');
    } catch (err: any) {
      setStatus(`❌ ${err.message || 'Upload failed'}`, 'error');
    } finally {
      setUploading(false);
    }
  };

  const setStatus = (msg: string, type: 'success' | 'error') => {
    setStatusMessage(msg);
    setStatusType(type);
  };

  return (
    <div className="pt-32 pb-24 max-w-4xl mx-auto px-6 space-y-8">
      {/* Header */}
      <div className="text-center space-y-3">
        <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-[#00E896]/10 border border-[#00E896]/30 text-[#00E896] text-xs font-bold uppercase tracking-wider">
          <Sparkles className="w-3.5 h-3.5" />
          AWS Cloud Master Content Creator Portal
        </div>
        <h1 className="text-3xl sm:text-4xl font-extrabold">Upload & Publish Content</h1>
        <p className="text-[#8A97B8] text-sm max-w-xl mx-auto">
          Upload academic notes, placement drives, government job alerts, and college circulars directly to AWS S3 & RDS. All uploads instantly sync with the MyVault Mobile App & Website.
        </p>
      </div>

      {/* Category Tab Switcher */}
      <div className="flex flex-wrap items-center justify-center gap-2 p-1.5 bg-[#0C1020] border border-white/10 rounded-2xl">
        <button
          onClick={() => { setActiveTab('academic'); setStatusMessage(null); }}
          className={`flex items-center gap-2 px-4 py-2.5 rounded-xl text-xs font-bold transition-all ${
            activeTab === 'academic'
              ? 'bg-gradient-to-r from-[#3E7BFF] to-[#00D9F5] text-white shadow-lg'
              : 'text-[#8A97B8] hover:text-white'
          }`}
        >
          <BookOpen className="w-4 h-4" />
          Academic Hub Files
        </button>
        <button
          onClick={() => { setActiveTab('placements'); setStatusMessage(null); }}
          className={`flex items-center gap-2 px-4 py-2.5 rounded-xl text-xs font-bold transition-all ${
            activeTab === 'placements'
              ? 'bg-gradient-to-r from-[#3E7BFF] to-[#00D9F5] text-white shadow-lg'
              : 'text-[#8A97B8] hover:text-white'
          }`}
        >
          <Briefcase className="w-4 h-4" />
          Placements & Internships
        </button>
        <button
          onClick={() => { setActiveTab('govt'); setStatusMessage(null); }}
          className={`flex items-center gap-2 px-4 py-2.5 rounded-xl text-xs font-bold transition-all ${
            activeTab === 'govt'
              ? 'bg-gradient-to-r from-[#3E7BFF] to-[#00D9F5] text-white shadow-lg'
              : 'text-[#8A97B8] hover:text-white'
          }`}
        >
          <Building2 className="w-4 h-4" />
          Govt Jobs & Exams
        </button>
        <button
          onClick={() => { setActiveTab('notices'); setStatusMessage(null); }}
          className={`flex items-center gap-2 px-4 py-2.5 rounded-xl text-xs font-bold transition-all ${
            activeTab === 'notices'
              ? 'bg-gradient-to-r from-[#3E7BFF] to-[#00D9F5] text-white shadow-lg'
              : 'text-[#8A97B8] hover:text-white'
          }`}
        >
          <Bell className="w-4 h-4" />
          Notices & Ticker Alerts
        </button>
      </div>

      {/* Main Upload Card Container */}
      <div className="glass-panel p-8 sm:p-10 rounded-3xl space-y-8 border border-white/10 shadow-2xl">
        {/* TAB 1: ACADEMIC HUB UPLOAD */}
        {activeTab === 'academic' && (
          <form onSubmit={handleAcademicUpload} className="space-y-6">
            <div className="border-b border-white/10 pb-4">
              <h2 className="text-lg font-bold text-white flex items-center gap-2">
                <BookOpen className="w-5 h-5 text-[#3E7BFF]" />
                Upload Academic Notes, Manuals & Videos
              </h2>
              <p className="text-xs text-[#8A97B8]">Files uploaded here will appear under the student's branch & semester in the app & web.</p>
            </div>

            {/* Drag & Drop */}
            <div
              onDragOver={(e) => e.preventDefault()}
              onDrop={handleFileDrop}
              onClick={() => fileInputRef.current?.click()}
              className="border-2 border-dashed border-[#3E7BFF]/30 hover:border-[#3E7BFF] bg-[#3E7BFF]/5 hover:bg-[#3E7BFF]/10 rounded-2xl p-8 text-center cursor-pointer transition-all space-y-3 relative overflow-hidden"
            >
              <input
                ref={fileInputRef}
                type="file"
                onChange={handleFileSelect}
                accept=".pdf,.mp4,.mov,.docx,.doc,.pptx,.png,.jpg,.jpeg,.zip"
                className="hidden"
              />
              {selectedFile ? (
                <div className="space-y-2">
                  <FileCheck className="w-12 h-12 text-[#00E896] mx-auto animate-bounce" />
                  <div className="font-bold text-base text-white">{selectedFile.name}</div>
                  <div className="text-xs text-[#8A97B8]">
                    {(selectedFile.size / 1024 / 1024).toFixed(2)} MB · Ready for AWS S3
                  </div>
                </div>
              ) : (
                <div className="space-y-2">
                  <CloudUpload className="w-12 h-12 text-[#3E7BFF] mx-auto" />
                  <div className="font-bold text-base">Drag & Drop or Click to Select File</div>
                  <div className="text-xs text-[#8A97B8]">
                    PDF, MP4, DOCX, PPTX up to 100MB · Bucket: myvault-study-materials
                  </div>
                </div>
              )}
            </div>

            {/* Title */}
            <div className="space-y-2">
              <label className="block text-xs font-bold text-[#8A97B8] uppercase tracking-wider">
                Material Title *
              </label>
              <input
                type="text"
                required
                value={title}
                onChange={(e) => setTitle(e.target.value)}
                placeholder="e.g. Unit 2 — Digital Signal Processing Complete Notes"
                className="w-full bg-white/5 border border-white/10 rounded-xl px-4 py-3 text-sm font-medium text-white focus:outline-none focus:border-[#3E7BFF]"
              />
            </div>

            {/* Branch & Semester */}
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
              <div className="space-y-2">
                <label className="block text-xs font-bold text-[#8A97B8] uppercase tracking-wider">
                  Engineering Branch
                </label>
                <select
                  value={branch}
                  onChange={(e) => setBranch(e.target.value)}
                  className="w-full bg-[#0C1020] border border-white/10 rounded-xl px-4 py-3 text-sm font-medium text-white focus:outline-none focus:border-[#3E7BFF]"
                >
                  <option value="ECE">Electronics (ECE)</option>
                  <option value="CSE">CSE</option>
                  <option value="CSE (AI & ML)">CSE (AI & ML)</option>
                  <option value="EEE">EEE</option>
                  <option value="MECH">Mechanical (MECH)</option>
                  <option value="CIVIL">Civil (CIVIL)</option>
                  <option value="General">General Engineering</option>
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
                    <option key={s} value={s}>
                      Semester {s}
                    </option>
                  ))}
                </select>
              </div>
            </div>

            {/* Subject Picker */}
            <div className="space-y-2">
              <label className="block text-xs font-bold text-[#8A97B8] uppercase tracking-wider">
                Select Subject (AWS RDS) {loadingSubjects && <span className="text-[#3E7BFF]">(Loading...)</span>}
              </label>
              <select
                value={selectedSubjectId}
                onChange={(e) => setSelectedSubjectId(e.target.value)}
                className="w-full bg-[#0C1020] border border-white/10 rounded-xl px-4 py-3 text-sm font-medium text-white focus:outline-none focus:border-[#3E7BFF]"
              >
                {subjects.length > 0 ? (
                  subjects.map((sub) => (
                    <option key={sub.id} value={sub.id}>
                      {sub.name} {sub.code ? `(${sub.code})` : ''}
                    </option>
                  ))
                ) : (
                  <option value="">— No subjects found in RDS for this branch/semester —</option>
                )}
              </select>
            </div>

            {/* Content Type & Unit */}
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
              <div className="space-y-2">
                <label className="block text-xs font-bold text-[#8A97B8] uppercase tracking-wider">
                  Content Type
                </label>
                <select
                  value={contentType}
                  onChange={(e) => setContentType(e.target.value)}
                  className="w-full bg-[#0C1020] border border-white/10 rounded-xl px-4 py-3 text-sm font-medium text-white focus:outline-none focus:border-[#3E7BFF]"
                >
                  <option value="notes">📄 Notes (PDF)</option>
                  <option value="video">🎬 Video Recording</option>
                  <option value="lab-manual">🧪 Lab Manual</option>
                  <option value="cheat-sheet">⚡ Cheat Sheet</option>
                  <option value="assignment">📋 Assignment</option>
                  <option value="previous-paper">📊 Previous Paper</option>
                </select>
              </div>

              <div className="space-y-2">
                <label className="block text-xs font-bold text-[#8A97B8] uppercase tracking-wider">
                  Unit Number
                </label>
                <select
                  value={unitNumber}
                  onChange={(e) => setUnitNumber(Number(e.target.value))}
                  className="w-full bg-[#0C1020] border border-white/10 rounded-xl px-4 py-3 text-sm font-medium text-white focus:outline-none focus:border-[#3E7BFF]"
                >
                  {[1, 2, 3, 4, 5].map((u) => (
                    <option key={u} value={u}>
                      Unit {u}
                    </option>
                  ))}
                </select>
              </div>
            </div>

            <button
              type="submit"
              disabled={uploading}
              className="w-full py-4 rounded-2xl font-bold text-base gradient-btn flex items-center justify-center gap-2 disabled:opacity-50"
            >
              {uploading ? <Loader2 className="w-5 h-5 animate-spin" /> : <Upload className="w-5 h-5" />}
              {uploading ? 'Publishing to AWS S3 & RDS...' : 'Upload Academic File'}
            </button>
          </form>
        )}

        {/* TAB 2: PLACEMENTS & INTERNSHIPS UPLOAD */}
        {activeTab === 'placements' && (
          <form onSubmit={handlePlacementUpload} className="space-y-6">
            <div className="border-b border-white/10 pb-4">
              <h2 className="text-lg font-bold text-white flex items-center gap-2">
                <Briefcase className="w-5 h-5 text-[#3E7BFF]" />
                Post Placement Drive or Internship Opportunity
              </h2>
              <p className="text-xs text-[#8A97B8]">Job postings appear instantly in the student Placements portal in app & web.</p>
            </div>

            <div className="space-y-2">
              <label className="block text-xs font-bold text-[#8A97B8] uppercase tracking-wider">Job Role / Position Title *</label>
              <input
                type="text"
                required
                value={jobTitle}
                onChange={(e) => setJobTitle(e.target.value)}
                placeholder="e.g. Software Development Engineer — 2026 Batch"
                className="w-full bg-white/5 border border-white/10 rounded-xl px-4 py-3 text-sm text-white focus:outline-none focus:border-[#3E7BFF]"
              />
            </div>

            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
              <div className="space-y-2">
                <label className="block text-xs font-bold text-[#8A97B8] uppercase tracking-wider">Company / Organization *</label>
                <input
                  type="text"
                  required
                  value={companyName}
                  onChange={(e) => setCompanyName(e.target.value)}
                  placeholder="e.g. Qualcomm / Infosys / TCS"
                  className="w-full bg-white/5 border border-white/10 rounded-xl px-4 py-3 text-sm text-white focus:outline-none focus:border-[#3E7BFF]"
                />
              </div>

              <div className="space-y-2">
                <label className="block text-xs font-bold text-[#8A97B8] uppercase tracking-wider">Job Category</label>
                <select
                  value={jobType}
                  onChange={(e) => setJobType(e.target.value)}
                  className="w-full bg-[#0C1020] border border-white/10 rounded-xl px-4 py-3 text-sm text-white focus:outline-none focus:border-[#3E7BFF]"
                >
                  <option value="IT">IT & Software</option>
                  <option value="Core">Core Engineering (ECE/EEE/MECH)</option>
                  <option value="Govt">Government Job Alert</option>
                </select>
              </div>
            </div>

            <div className="space-y-2">
              <label className="block text-xs font-bold text-[#8A97B8] uppercase tracking-wider">Application Link / Portal URL</label>
              <input
                type="url"
                value={jobLink}
                onChange={(e) => setJobLink(e.target.value)}
                placeholder="https://careers.company.com/jobs/12345"
                className="w-full bg-white/5 border border-white/10 rounded-xl px-4 py-3 text-sm text-white focus:outline-none focus:border-[#3E7BFF]"
              />
            </div>

            <div className="space-y-2">
              <label className="block text-xs font-bold text-[#8A97B8] uppercase tracking-wider">Attach Official JD / Notification File (Optional PDF)</label>
              <input
                type="file"
                accept=".pdf,.docx,.doc"
                onChange={handleFileSelect}
                className="w-full text-xs text-[#8A97B8] file:mr-4 file:py-2 file:px-4 file:rounded-xl file:border-0 file:text-xs file:font-bold file:bg-[#3E7BFF]/20 file:text-[#3E7BFF] hover:file:bg-[#3E7BFF]/30"
              />
            </div>

            <button
              type="submit"
              disabled={uploading}
              className="w-full py-4 rounded-2xl font-bold text-base gradient-btn flex items-center justify-center gap-2 disabled:opacity-50"
            >
              {uploading ? <Loader2 className="w-5 h-5 animate-spin" /> : <Briefcase className="w-5 h-5" />}
              {uploading ? 'Publishing Job Opportunity...' : 'Post Placement Opportunity'}
            </button>
          </form>
        )}

        {/* TAB 3: GOVT JOBS & EXAM ALERTS */}
        {activeTab === 'govt' && (
          <form onSubmit={handlePlacementUpload} className="space-y-6">
            <div className="border-b border-white/10 pb-4">
              <h2 className="text-lg font-bold text-white flex items-center gap-2">
                <Building2 className="w-5 h-5 text-[#00E896]" />
                Publish Govt Job & Competitive Exam Alert
              </h2>
              <p className="text-xs text-[#8A97B8]">Publish TSPSC, ISRO, GATE, DRDO & UPSC notification alerts to students.</p>
            </div>

            <div className="space-y-2">
              <label className="block text-xs font-bold text-[#8A97B8] uppercase tracking-wider">Notification Title *</label>
              <input
                type="text"
                required
                value={jobTitle}
                onChange={(e) => setJobTitle(e.target.value)}
                placeholder="e.g. TSPSC Assistant Executive Engineer (AEE) Recruitment 2026"
                className="w-full bg-white/5 border border-white/10 rounded-xl px-4 py-3 text-sm text-white focus:outline-none focus:border-[#3E7BFF]"
              />
            </div>

            <div className="space-y-2">
              <label className="block text-xs font-bold text-[#8A97B8] uppercase tracking-wider">Government Department / Agency *</label>
              <input
                type="text"
                required
                value={companyName}
                onChange={(e) => setCompanyName(e.target.value)}
                placeholder="e.g. TSPSC / ISRO / BEL / ECIL"
                className="w-full bg-white/5 border border-white/10 rounded-xl px-4 py-3 text-sm text-white focus:outline-none focus:border-[#3E7BFF]"
              />
            </div>

            <div className="space-y-2">
              <label className="block text-xs font-bold text-[#8A97B8] uppercase tracking-wider">Official Portal / Apply Link</label>
              <input
                type="url"
                value={jobLink}
                onChange={(e) => setJobLink(e.target.value)}
                placeholder="https://tspsc.gov.in"
                className="w-full bg-white/5 border border-white/10 rounded-xl px-4 py-3 text-sm text-white focus:outline-none focus:border-[#3E7BFF]"
              />
            </div>

            <button
              type="submit"
              disabled={uploading}
              className="w-full py-4 rounded-2xl font-bold text-base gradient-btn flex items-center justify-center gap-2 disabled:opacity-50"
            >
              {uploading ? <Loader2 className="w-5 h-5 animate-spin" /> : <Building2 className="w-5 h-5" />}
              {uploading ? 'Publishing Govt Alert...' : 'Publish Government Job Alert'}
            </button>
          </form>
        )}

        {/* TAB 4: NOTICES & ANNOUNCEMENTS */}
        {activeTab === 'notices' && (
          <form onSubmit={handleNoticeUpload} className="space-y-6">
            <div className="border-b border-white/10 pb-4">
              <h2 className="text-lg font-bold text-white flex items-center gap-2">
                <Bell className="w-5 h-5 text-[#00D9F5]" />
                Publish College Notice or Circular Alert
              </h2>
              <p className="text-xs text-[#8A97B8]">Announcements update the live ticker at the top of the mobile app home screen.</p>
            </div>

            <div className="space-y-2">
              <label className="block text-xs font-bold text-[#8A97B8] uppercase tracking-wider">Notice Title *</label>
              <input
                type="text"
                required
                value={noticeTitle}
                onChange={(e) => setNoticeTitle(e.target.value)}
                placeholder="e.g. End Semester Exam Timetable Released for 3rd Year ECE & CSE"
                className="w-full bg-white/5 border border-white/10 rounded-xl px-4 py-3 text-sm text-white focus:outline-none focus:border-[#3E7BFF]"
              />
            </div>

            <div className="space-y-2">
              <label className="block text-xs font-bold text-[#8A97B8] uppercase tracking-wider">Announcement Details *</label>
              <textarea
                rows={3}
                required
                value={noticeMessage}
                onChange={(e) => setNoticeMessage(e.target.value)}
                placeholder="Enter complete circular text or exam instructions..."
                className="w-full bg-white/5 border border-white/10 rounded-xl px-4 py-3 text-sm text-white focus:outline-none focus:border-[#3E7BFF]"
              />
            </div>

            <button
              type="submit"
              disabled={uploading}
              className="w-full py-4 rounded-2xl font-bold text-base gradient-btn flex items-center justify-center gap-2 disabled:opacity-50"
            >
              {uploading ? <Loader2 className="w-5 h-5 animate-spin" /> : <Bell className="w-5 h-5" />}
              {uploading ? 'Publishing Announcement...' : 'Publish Notice to Mobile Ticker'}
            </button>
          </form>
        )}

        {/* Progress Bar */}
        {uploading && (
          <div className="space-y-2">
            <div className="w-full h-2 bg-white/10 rounded-full overflow-hidden">
              <div
                className="h-full bg-gradient-to-r from-[#3E7BFF] to-[#00D9F5] transition-all duration-500"
                style={{ width: `${progress}%` }}
              />
            </div>
            <div className="text-xs font-semibold text-center text-[#00D9F5]">{progress}% Complete</div>
          </div>
        )}

        {/* Status Message */}
        {statusMessage && (
          <div
            className={`p-4 rounded-xl text-xs font-bold flex items-center gap-3 ${
              statusType === 'success'
                ? 'bg-[#00E896]/10 border border-[#00E896]/30 text-[#00E896]'
                : 'bg-red-500/10 border border-red-500/30 text-red-400'
            }`}
          >
            {statusType === 'success' ? <CheckCircle2 className="w-5 h-5 flex-shrink-0" /> : <AlertCircle className="w-5 h-5 flex-shrink-0" />}
            <span>{statusMessage}</span>
          </div>
        )}
      </div>
    </div>
  );
}
