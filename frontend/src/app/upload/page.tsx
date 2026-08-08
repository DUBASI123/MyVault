'use client';

import { useState, useEffect, useRef } from 'react';
import { Upload, CloudUpload, FileCheck, CheckCircle2, AlertCircle, Loader2 } from 'lucide-react';

const API_BASE = 'https://myvault-backend.onrender.com';

interface Subject {
  id: string;
  name: string;
  code?: string;
  branch: string;
  semester: number;
}

export default function UploadPage() {
  const [selectedFile, setSelectedFile] = useState<File | null>(null);
  const [title, setTitle] = useState('');
  const [branch, setBranch] = useState('ECE');
  const [semester, setSemester] = useState(1);
  const [subjects, setSubjects] = useState<Subject[]>([]);
  const [selectedSubjectId, setSelectedSubjectId] = useState('');
  const [unitNumber, setUnitNumber] = useState(1);
  const [contentType, setContentType] = useState('notes');
  const [description, setDescription] = useState('');

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

  const handleUpload = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!title.trim()) {
      setStatusMessage('Please enter a title for the material');
      setStatusType('error');
      return;
    }
    if (!selectedSubjectId) {
      setStatusMessage('Please select a subject');
      setStatusType('error');
      return;
    }
    if (!selectedFile) {
      setStatusMessage('Please select or drag a file to upload');
      setStatusType('error');
      return;
    }

    setUploading(true);
    setProgress(10);
    setStatusMessage('Requesting presigned upload URL from AWS...');

    try {
      // 1. Get Presigned S3 Upload URL from NestJS
      const presignRes = await fetch(
        `${API_BASE}/api/s3/presign-upload?fileName=${encodeURIComponent(
          selectedFile.name
        )}&contentType=${encodeURIComponent(
          selectedFile.type || 'application/octet-stream'
        )}&folder=study-materials`
      );

      if (!presignRes.ok) throw new Error('Failed to obtain S3 upload authorization');
      const { uploadUrl, fileUrl, key } = await presignRes.json();

      setProgress(35);
      setStatusMessage('Streaming file directly to AWS S3 bucket...');

      // 2. PUT file directly to AWS S3 bucket
      const s3UploadRes = await fetch(uploadUrl, {
        method: 'PUT',
        headers: {
          'Content-Type': selectedFile.type || 'application/octet-stream',
        },
        body: selectedFile,
      });

      if (!s3UploadRes.ok) throw new Error(`AWS S3 Upload failed (${s3UploadRes.status})`);

      setProgress(75);
      setStatusMessage('Registering metadata in AWS RDS PostgreSQL...');

      // 3. Save metadata to AWS RDS via NestJS API
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
      setStatusMessage('✅ Successfully uploaded! Live in MyVault app & website!');
      setStatusType('success');

      // Reset form
      setTitle('');
      setSelectedFile(null);
      setDescription('');
    } catch (err: any) {
      console.error(err);
      setStatusMessage(`❌ ${err.message || 'Upload failed. Please try again.'}`);
      setStatusType('error');
    } finally {
      setUploading(false);
    }
  };

  return (
    <div className="pt-32 pb-24 max-w-4xl mx-auto px-6 space-y-8">
      {/* Header */}
      <div className="text-center space-y-3">
        <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-[#00E896]/10 border border-[#00E896]/30 text-[#00E896] text-xs font-bold uppercase tracking-wider">
          <Upload className="w-3.5 h-3.5" />
          AWS S3 Presigned Direct Upload
        </div>
        <h1 className="text-3xl sm:text-4xl font-extrabold">Faculty Study Material Portal</h1>
        <p className="text-[#8A97B8] text-sm max-w-xl mx-auto">
          Upload PDF notes, classroom recordings, lab manuals, and cheat sheets directly to Amazon S3.
        </p>
      </div>

      {/* Main Upload Card */}
      <div className="glass-panel p-8 sm:p-10 rounded-3xl space-y-8 border border-white/10 shadow-2xl">
        <form onSubmit={handleUpload} className="space-y-6">
          {/* File Drag-and-Drop Area */}
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
                <div className="font-bold text-base">Drag & Drop or Click to Browse</div>
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
              placeholder="e.g. Unit 2 — Combinational Circuits & Karnaugh Maps"
              className="w-full bg-white/5 border border-white/10 rounded-xl px-4 py-3 text-sm font-medium text-white focus:outline-none focus:border-[#3E7BFF] transition-all"
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

          {/* Subject Dropdown (Dynamic from AWS RDS) */}
          <div className="space-y-2">
            <label className="block text-xs font-bold text-[#8A97B8] uppercase tracking-wider">
              Subject (AWS RDS) {loadingSubjects && <span className="text-[#3E7BFF]">(Loading...)</span>}
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

          {/* Unit Number & Content Type */}
          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
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
          </div>

          {/* Description */}
          <div className="space-y-2">
            <label className="block text-xs font-bold text-[#8A97B8] uppercase tracking-wider">
              Description (Optional)
            </label>
            <textarea
              rows={2}
              value={description}
              onChange={(e) => setDescription(e.target.value)}
              placeholder="Add key highlights or topics covered in this material..."
              className="w-full bg-white/5 border border-white/10 rounded-xl px-4 py-3 text-sm font-medium text-white focus:outline-none focus:border-[#3E7BFF]"
            />
          </div>

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

          {/* Submit Button */}
          <button
            type="submit"
            disabled={uploading}
            className="w-full py-4 rounded-2xl font-bold text-base gradient-btn flex items-center justify-center gap-2 disabled:opacity-50"
          >
            {uploading ? (
              <>
                <Loader2 className="w-5 h-5 animate-spin" />
                Uploading to AWS S3...
              </>
            ) : (
              <>
                <Upload className="w-5 h-5" />
                Upload Material to AWS S3
              </>
            )}
          </button>
        </form>
      </div>
    </div>
  );
}
