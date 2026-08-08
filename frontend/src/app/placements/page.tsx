'use client';

import { useState } from 'react';
import { Briefcase, Building2, ExternalLink, Calendar, DollarSign, Filter, Search } from 'lucide-react';

export default function PlacementsPage() {
  const [filter, setFilter] = useState('all');
  const [search, setSearch] = useState('');

  const jobs = [
    {
      id: '1',
      company: 'Infosys',
      role: 'Specialist Programmer / Software Engineer',
      type: 'IT',
      domain: 'Java / Python / Cloud',
      stipend: '₹ 15,000 / mo',
      duration: '6 Months Internship',
      deadline: 'Dec 31, 2026',
      status: 'Open',
      link: 'https://infosys.com',
    },
    {
      id: '2',
      company: 'TCS Digital',
      role: 'System Engineer & Cloud Intern',
      type: 'IT',
      domain: 'React / Node.js / AWS',
      stipend: '₹ 18,000 / mo',
      duration: '6 Months',
      deadline: 'Jan 15, 2027',
      status: 'Open',
      link: 'https://tcs.com',
    },
    {
      id: '3',
      company: 'TSPSC Group I / Engineering Services',
      role: 'Assistant Executive Engineer (AEE)',
      type: 'Govt',
      domain: 'Civil / ECE / Mechanical',
      stipend: '₹ 54,220 - ₹ 1,33,630',
      duration: 'Permanent Govt Role',
      deadline: 'Jan 28, 2027',
      status: 'Notification Out',
      link: 'https://tspsc.gov.in',
    },
    {
      id: '4',
      company: 'Qualcomm',
      role: 'Hardware & VLSI Intern',
      type: 'Core',
      domain: 'Digital System Design / Verilog',
      stipend: '₹ 35,000 / mo',
      duration: '6 Months',
      deadline: 'Dec 25, 2026',
      status: 'Open',
      link: 'https://qualcomm.com',
    },
  ];

  const filteredJobs = jobs.filter((j) => {
    const matchesType = filter === 'all' || j.type.toLowerCase() === filter.toLowerCase();
    const matchesSearch = j.company.toLowerCase().includes(search.toLowerCase()) || j.role.toLowerCase().includes(search.toLowerCase());
    return matchesType && matchesSearch;
  });

  return (
    <div className="pt-32 pb-24 max-w-7xl mx-auto px-6 space-y-10">
      {/* Header */}
      <div className="text-center space-y-3">
        <div className="inline-flex items-center gap-2 px-4 py-1.5 rounded-full bg-[#7B5BFF]/10 border border-[#7B5BFF]/30 text-[#A78BFF] text-xs font-bold uppercase tracking-wider">
          <Briefcase className="w-4 h-4 text-[#7B5BFF]" />
          Career Opportunities Portal
        </div>
        <h1 className="text-3xl sm:text-5xl font-black">Placements & Govt Jobs</h1>
        <p className="text-[#8A97B8] text-base max-w-xl mx-auto">
          Explore campus drives, IT internships, core engineering roles, and public sector notifications.
        </p>
      </div>

      {/* Filter & Search */}
      <div className="glass-panel p-6 rounded-3xl border border-white/10 flex flex-col md:flex-row items-center justify-between gap-4">
        <div className="flex items-center gap-2 w-full md:w-auto">
          {['all', 'IT', 'Core', 'Govt'].map((t) => (
            <button
              key={t}
              onClick={() => setFilter(t)}
              className={`px-4 py-2 rounded-xl text-xs font-bold transition-all ${
                filter === t ? 'bg-gradient-to-r from-[#3E7BFF] to-[#00D9F5] text-[#04101F]' : 'bg-white/5 text-[#8A97B8] hover:text-white'
              }`}
            >
              {t === 'all' ? 'All Roles' : t}
            </button>
          ))}
        </div>

        <div className="relative w-full md:w-80">
          <Search className="w-4 h-4 text-[#8A97B8] absolute left-3 top-1/2 -translate-y-1/2" />
          <input
            type="text"
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            placeholder="Search company or role..."
            className="w-full bg-white/5 border border-white/10 rounded-xl pl-9 pr-4 py-2 text-sm text-white focus:outline-none focus:border-[#3E7BFF]"
          />
        </div>
      </div>

      {/* Job Cards Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        {filteredJobs.map((job) => (
          <div key={job.id} className="glass-panel glass-panel-hover p-8 rounded-3xl space-y-6 border border-white/10 flex flex-col justify-between">
            <div className="space-y-4">
              <div className="flex items-start justify-between">
                <div>
                  <span className="text-[10px] font-bold uppercase tracking-wider px-2.5 py-1 rounded-full bg-[#7B5BFF]/10 text-[#7B5BFF]">
                    {job.type} Opportunity
                  </span>
                  <h3 className="text-xl font-bold text-white mt-2">{job.company}</h3>
                  <div className="text-sm font-semibold text-[#00D9F5]">{job.role}</div>
                </div>
                <div className="w-10 h-10 rounded-xl bg-white/5 border border-white/10 flex items-center justify-center text-lg">
                  💼
                </div>
              </div>

              <div className="grid grid-cols-2 gap-3 pt-2 text-xs text-[#8A97B8]">
                <div className="flex items-center gap-2">
                  <DollarSign className="w-4 h-4 text-[#00E896]" />
                  <span>{job.stipend}</span>
                </div>
                <div className="flex items-center gap-2">
                  <Calendar className="w-4 h-4 text-[#FFB930]" />
                  <span>Deadline: {job.deadline}</span>
                </div>
              </div>
            </div>

            <a
              href={job.link}
              target="_blank"
              rel="noreferrer"
              className="w-full py-3 rounded-xl font-bold text-xs gradient-btn flex items-center justify-center gap-2 mt-4"
            >
              Apply Now <ExternalLink className="w-4 h-4" />
            </a>
          </div>
        ))}
      </div>
    </div>
  );
}
