// ============================================================
// placement_desk_screen.dart
// MyVault — Placement Desk
// Single file: Models + Repository + Providers + Full UI
//
// Add to pubspec.yaml:
//   url_launcher: ^6.3.0
//   flutter_riverpod: ^2.5.1  (already in project)
//   supabase_flutter: ^2.5.0   (already in project)
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

// ─────────────────────────────────────────────────────────────
// COLORS  (MyVault dark theme)
// ─────────────────────────────────────────────────────────────
const _bg   = Color(0xFF0A0A0F);
const _surf = Color(0xFF1A1A2E);
const _s2   = Color(0xFF232340);
const _pri  = Color(0xFF6C63FF);
const _grn  = Color(0xFF4CAF50);
const _red  = Color(0xFFFF5252);

// ─────────────────────────────────────────────────────────────
// MODELS
// ─────────────────────────────────────────────────────────────
enum JobType        { internship, fullTime, partTime, freelance, contract }
enum WorkMode       { onsite, remote, hybrid }
enum ExperienceLevel{ fresher, junior, mid, senior, lead }

class PlacementJob {
  final String id, companyName, companyLogo, role, description;
  final JobType     jobType;
  final WorkMode    workMode;
  final ExperienceLevel level;
  final String      location;
  final String?     salary, experience, qualification, shift, contactInfo, department;
  final List<String> skills, responsibilities, tags;
  final String      applyUrl;
  final DateTime    postedAt;
  final bool        isUrgent, isFeatured;

  const PlacementJob({
    required this.id,          required this.companyName,
    required this.companyLogo, required this.role,
    required this.description, required this.jobType,
    required this.workMode,    required this.level,
    required this.location,
    this.salary, this.experience, this.qualification,
    this.shift,  this.contactInfo, this.department,
    required this.skills,    required this.responsibilities,
    required this.tags,      required this.applyUrl,
    required this.postedAt,  required this.isUrgent,
    required this.isFeatured,
  });

  factory PlacementJob.fromJson(Map<String, dynamic> j) => PlacementJob(
    id:          j['id'],
    companyName: j['company_name'],
    companyLogo: j['company_logo_url'] ?? '',
    role:        j['role'],
    description: j['description'] ?? '',
    jobType:     JobType.values.firstWhere(
                   (e) => e.name == j['job_type'],
                   orElse: () => JobType.fullTime),
    workMode:    WorkMode.values.firstWhere(
                   (e) => e.name == j['work_mode'],
                   orElse: () => WorkMode.onsite),
    level:       ExperienceLevel.values.firstWhere(
                   (e) => e.name == j['experience_level'],
                   orElse: () => ExperienceLevel.fresher),
    location:       j['location'] ?? '',
    salary:         j['salary_range'],
    experience:     j['experience'],
    qualification:  j['qualification'],
    shift:          j['shift'],
    contactInfo:    j['contact_info'],
    department:     j['department'],
    skills:         List<String>.from(j['skills'] ?? []),
    responsibilities: List<String>.from(j['responsibilities'] ?? []),
    tags:           List<String>.from(j['tags'] ?? []),
    applyUrl:       j['apply_url'] ?? '',
    postedAt:       DateTime.parse(j['posted_at']),
    isUrgent:       j['is_urgent'] ?? false,
    isFeatured:     j['is_featured'] ?? false,
  );

  String get jobTypeLabel {
    switch (jobType) {
      case JobType.internship: return 'Internship';
      case JobType.fullTime:   return 'Full-time';
      case JobType.partTime:   return 'Part-time';
      case JobType.freelance:  return 'Freelance';
      case JobType.contract:   return 'Contract';
    }
  }

  String get workModeLabel {
    switch (workMode) {
      case WorkMode.remote:  return 'Remote';
      case WorkMode.hybrid:  return 'Hybrid';
      case WorkMode.onsite:  return 'On-site';
    }
  }

  String get levelLabel {
    switch (level) {
      case ExperienceLevel.fresher: return 'Fresher';
      case ExperienceLevel.junior:  return 'Junior';
      case ExperienceLevel.mid:     return 'Mid-level';
      case ExperienceLevel.senior:  return 'Senior';
      case ExperienceLevel.lead:    return 'Lead / Director';
    }
  }
}

// ─────────────────────────────────────────────────────────────
// LOCAL SEED DATA  (all real listings from shared document)
// Falls back to Supabase if table exists; always shows seed
// ─────────────────────────────────────────────────────────────
final List<PlacementJob> _seedJobs = [

  // ── 1. Qualcomm ─────────────────────────────────────────────
  PlacementJob(
    id: 'qcom-1', companyName: 'Qualcomm', companyLogo: '',
    role: 'Campus Hire Software Engineer',
    description:
        'Design, develop, test, and maintain software for Qualcomm\'s '
        'advanced mobile chipsets and embedded platforms. Exposure to Android, '
        'Linux kernel, wireless communication, multimedia, device drivers, and IoT. '
        'Work alongside experienced engineers shaping the future of connected devices.',
    jobType: JobType.fullTime, workMode: WorkMode.onsite,
    level: ExperienceLevel.fresher,
    location: 'Bengaluru, Karnataka',
    salary: 'As per industry standards',
    experience: '0 Years (2024 / 2025 / 2026 batch)',
    qualification: 'B.Tech / M.Tech – CS / ECE / EE',
    department: 'Engineering',
    skills: ['Android Development','Linux Kernel','Embedded C/C++','Device Drivers','IoT'],
    responsibilities: [
      'Design and develop software for mobile chipsets',
      'Write unit and integration tests',
      'Collaborate with cross-functional teams on embedded platforms',
    ],
    tags: ['campus','fresher','chip','2026'],
    applyUrl: 'https://careers.qualcomm.com/careers/job/446706882270',
    postedAt: DateTime(2025, 6, 10),
    isUrgent: false, isFeatured: true,
  ),

  // ── 2. Deloitte ─────────────────────────────────────────────
  PlacementJob(
    id: 'del-1', companyName: 'Deloitte', companyLogo: '',
    role: 'Services Support Associate',
    description:
        'Support role within Deloitte\'s integrated Admin COE in Hyderabad. '
        'Coordinate services, manage documentation, and support day-to-day operations. '
        'Freshers welcome — great entry point into a Big 4 consulting firm.',
    jobType: JobType.fullTime, workMode: WorkMode.onsite,
    level: ExperienceLevel.fresher,
    location: 'Hyderabad',
    experience: '0–1 Year',
    qualification: 'Any Graduate',
    department: 'Admin / Operations',
    skills: ['MS Office','Communication','Coordination','Data Entry','MIS'],
    responsibilities: [
      'Manage service coordination and admin tasks',
      'Maintain documentation and records',
      'Support operations team with reporting',
    ],
    tags: ['big4','consulting','admin','fresher','hyderabad'],
    applyUrl:
        'https://usijobs.deloitte.com/en_US/careersUSI/JobDetail/USI-EH27-EOX-Admin-COE-Integrated-Admin-Analyst-Hyderabad/351388',
    postedAt: DateTime(2025, 6, 8),
    isUrgent: false, isFeatured: true,
  ),

  // ── 3. Oracle ────────────────────────────────────────────────
  PlacementJob(
    id: 'ora-1', companyName: 'Oracle', companyLogo: '',
    role: 'Systems Analyst 1 – Support',
    description:
        'Entry-level systems analyst role at Oracle India, Bengaluru. '
        'Support enterprise software, assist clients with technical queries, '
        'and contribute to product improvement. Batches 2024, 2025, 2026 eligible.',
    jobType: JobType.fullTime, workMode: WorkMode.onsite,
    level: ExperienceLevel.fresher,
    location: 'Bengaluru, Karnataka',
    salary: 'Competitive',
    experience: '0 Years',
    qualification: 'Bachelor\'s Degree (2024 / 2025 / 2026)',
    department: 'Technical Support',
    skills: ['SQL','Java','Technical Support','Problem Solving','Communication'],
    responsibilities: [
      'Support enterprise software systems for clients',
      'Diagnose and resolve technical issues',
      'Contribute to product feedback and improvement',
    ],
    tags: ['oracle','fresher','it','bengaluru','campus'],
    applyUrl: 'https://careers.oracle.com/en/sites/jobsearch/job/319150/',
    postedAt: DateTime(2025, 6, 5),
    isUrgent: false, isFeatured: true,
  ),

  // ── 4. Accenture ────────────────────────────────────────────
  PlacementJob(
    id: 'acc-1', companyName: 'Accenture', companyLogo: '',
    role: 'Customer Support Associate – International Voice',
    description:
        'Join Accenture as a Customer Support Associate handling US international '
        'voice calls. 5-day working week with 2 consecutive week-offs and cab '
        'facility provided. Excellent English communication required. '
        'Great learning and career growth in a global organization.',
    jobType: JobType.fullTime, workMode: WorkMode.onsite,
    level: ExperienceLevel.fresher,
    location: 'Bangalore / Mumbai / Pune',
    salary: 'Competitive (BPO grade)',
    experience: '0 Years – Freshers Welcome',
    shift: 'US Night Shift (5 days working, 2 consecutive week-offs)',
    qualification: '10+2 or Any Graduate',
    department: 'Customer Support',
    skills: ['English Communication','Customer Service','Problem Solving','MS Office'],
    responsibilities: [
      'Handle inbound/outbound international voice calls',
      'Resolve customer queries and complaints',
      'Maintain CSAT scores and quality standards',
    ],
    tags: ['bpo','voice','night shift','fresher','accenture'],
    applyUrl: 'https://www.accenture.com/in-en/careers',
    postedAt: DateTime(2025, 6, 15),
    isUrgent: true, isFeatured: true,
  ),

  // ── 5. Teleperformance ───────────────────────────────────────
  PlacementJob(
    id: 'tp-1', companyName: 'Teleperformance', companyLogo: '',
    role: 'Customer Support Executive',
    description:
        'Urgently hiring Customer Support Executives in Mumbai. '
        'Virtual interview mode. 6 working days a week. '
        'English + one regional language required. Attractive performance-based '
        'salary. Freshers and experienced candidates welcome. Immediate joiners preferred.',
    jobType: JobType.fullTime, workMode: WorkMode.onsite,
    level: ExperienceLevel.fresher,
    location: 'Mumbai',
    salary: 'Performance-based (Attractive)',
    experience: '0–2 Years',
    qualification: '10+2 / Intermediate or above',
    contactInfo: '7416011435',
    department: 'Customer Support',
    skills: ['English','Regional Language','Customer Handling','Basic Computer'],
    responsibilities: [
      'Handle customer queries via phone',
      'Maintain customer satisfaction and quality benchmarks',
      'Log interactions in CRM',
    ],
    tags: ['bpo','mumbai','immediate joiner','voice'],
    applyUrl: 'tel:7416011435',
    postedAt: DateTime(2025, 6, 18),
    isUrgent: true, isFeatured: false,
  ),

  // ── 6. Product Support Engineer ──────────────────────────────
  PlacementJob(
    id: 'pse-1', companyName: 'ReqOpen', companyLogo: '',
    role: 'Product Support Engineer',
    description:
        'Work at the intersection of technology and customer success. '
        'Troubleshoot issues, diagnose bugs, and collaborate with engineering teams '
        'to ship fixes fast. US shift role based in Gurgaon (Work from Office). '
        'CTC: ₹6–8 LPA.',
    jobType: JobType.fullTime, workMode: WorkMode.onsite,
    level: ExperienceLevel.junior,
    location: 'Gurgaon',
    salary: '₹6–8 LPA',
    experience: '0–2 Years',
    qualification: 'B.Tech / Any Technical Degree',
    shift: 'US Shift – 6 PM to 4 AM IST',
    contactInfo: '+91-9602498954',
    department: 'Technical Support',
    skills: ['HTML','CSS','JavaScript','SaaS Support','Debugging','Technical Communication'],
    responsibilities: [
      'Troubleshoot SaaS product issues for end users',
      'Reproduce and document bugs for engineering',
      'Own customer communication and resolution SLAs',
    ],
    tags: ['saas','product','support','gurgaon','us shift'],
    applyUrl: 'https://www.reqopen.com/job?id=req-0237f63e',
    postedAt: DateTime(2025, 6, 12),
    isUrgent: false, isFeatured: false,
  ),

  // ── 7. AI Specialist Intern ──────────────────────────────────
  PlacementJob(
    id: 'ai-intern-1', companyName: 'Startup (Social Media)', companyLogo: '',
    role: 'AI Specialist Intern',
    description:
        'Manage end-to-end social media accounts (Instagram, LinkedIn, Facebook). '
        'Create AI-powered content, captions, and creatives. Plan content calendars, '
        'design posts/reels/stories, and analyze performance metrics using AI tools.',
    jobType: JobType.internship, workMode: WorkMode.remote,
    level: ExperienceLevel.fresher,
    location: 'Remote / Work from Home',
    salary: '₹18,000–₹20,000 / month',
    experience: 'No Experience Required',
    qualification: 'Any Graduate / Student',
    contactInfo: '9152395342 (WhatsApp resume)',
    department: 'Marketing & Content',
    skills: ['ChatGPT','Canva AI','Gemini','Social Media Management','Content Creation','Video Editing'],
    responsibilities: [
      'Manage Instagram, LinkedIn, and Facebook pages end-to-end',
      'Create AI-assisted posts, reels, and stories',
      'Plan weekly content calendars and schedule posts',
      'Monitor engagement and generate performance reports',
    ],
    tags: ['ai','social media','intern','remote','canva'],
    applyUrl: 'tel:9152395342',
    postedAt: DateTime(2025, 6, 20),
    isUrgent: true, isFeatured: false,
  ),

  // ── 8. GAO Group – Lead Generation Intern ───────────────────
  PlacementJob(
    id: 'gao-1', companyName: 'The GAO Group (USA & Canada)', companyLogo: '',
    role: 'Lead Generation Intern',
    description:
        'Remote internship with a US-based electronics company. Conduct market '
        'research, collect and verify lead data, assist with outreach emails, '
        'and work with CRM tools like HubSpot, Salesforce, and LinkedIn Sales Navigator. '
        'AI-supported data scraping and automated lead qualification experience provided.',
    jobType: JobType.internship, workMode: WorkMode.remote,
    level: ExperienceLevel.fresher,
    location: 'Remote (Work from Home) – USA/Canada company',
    salary: 'Unpaid (Certificate + International Experience)',
    experience: '0 Years – Students / Recent Graduates',
    qualification: 'Bachelor\'s / Master\'s – Marketing, Business Admin',
    contactInfo: 'HR-PAK-DEPT1@thegaogroup.com',
    department: 'Sales & Marketing',
    skills: ['Market Research','LinkedIn Sales Navigator','HubSpot','Salesforce','MS Excel','CRM'],
    responsibilities: [
      'Identify and evaluate potential leads via online tools',
      'Segment leads by industry, location, and company size',
      'Draft personalized outreach emails and follow-up messages',
      'Update CRM with verified lead data',
    ],
    tags: ['lead gen','crm','marketing','remote','usa company','certificate'],
    applyUrl: 'mailto:HR-PAK-DEPT1@thegaogroup.com',
    postedAt: DateTime(2025, 6, 14),
    isUrgent: false, isFeatured: false,
  ),

  // ── 9. Director – AI Innovation ─────────────────────────────
  PlacementJob(
    id: 'ai-dir-1', companyName: 'Confidential (Tech Firm)', companyLogo: '',
    role: 'Director – AI Innovation',
    description:
        'Lead AI strategy, drive digital transformation, and identify AI solutions '
        'with measurable business impact. Strong hands-on Python background required. '
        'Expertise needed in Generative AI, Agentic AI (LangGraph, CrewAI, AutoGen), '
        'RAG, LLM fine-tuning, MCP, and multi-agent orchestration.',
    jobType: JobType.fullTime, workMode: WorkMode.onsite,
    level: ExperienceLevel.lead,
    location: 'India (Location TBD)',
    salary: 'Senior Executive Compensation',
    experience: '10+ Years (Production AI Engineering preferred)',
    qualification: 'B.Tech / M.Tech / MBA + AI experience',
    department: 'AI & Data',
    skills: ['Python','Generative AI','LangGraph','CrewAI','AutoGen','RAG','LLM Fine-tuning','MCP'],
    responsibilities: [
      'Define and drive the company\'s AI innovation roadmap',
      'Build and mentor AI engineering teams',
      'Evaluate AI vendors, tools, and partnerships',
      'Present AI strategy to C-suite and board',
    ],
    tags: ['ai director','llm','genai','leadership','senior'],
    applyUrl: 'https://www.linkedin.com/feed/',
    postedAt: DateTime(2025, 6, 9),
    isUrgent: true, isFeatured: true,
  ),

  // ── 10. Full Stack .NET Developer ────────────────────────────
  PlacementJob(
    id: 'dotnet-1', companyName: 'MNC (Confidential)', companyLogo: '',
    role: 'Full Stack .NET Developer',
    description:
        'Senior full-stack developer at an MNC. ASP.NET Core, MVC 5, SQL Server, '
        'WCF & REST APIs. UI in React/Angular. Agile (JIRA/Git/Jenkins). '
        'Security scanning with FOP, Sonatype, WebInspect. Payments domain knowledge is a plus.',
    jobType: JobType.fullTime, workMode: WorkMode.onsite,
    level: ExperienceLevel.senior,
    location: 'India (Location TBD)',
    experience: '5+ Years',
    qualification: 'B.Tech / MCA or equivalent',
    department: 'Engineering',
    skills: ['ASP.NET Core','ASP.NET MVC 5','SQL Server','WCF','REST APIs','React','Angular','Jenkins'],
    responsibilities: [
      'Develop and maintain ASP.NET Core backend services',
      'Build React/Angular UI components',
      'Integrate with third-party APIs and payment systems',
      'Conduct code reviews and enforce security standards',
    ],
    tags: ['dotnet','full stack','mnc','react','sql server','payments'],
    applyUrl: 'https://www.linkedin.com/feed/',
    postedAt: DateTime(2025, 6, 7),
    isUrgent: true, isFeatured: false,
  ),

  // ── 11. IT Recruiter – Bangalore ─────────────────────────────
  PlacementJob(
    id: 'rec-1', companyName: 'Staffing Firm, Bangalore', companyLogo: '',
    role: 'IT Recruiter (C2H & Permanent Staffing)',
    description:
        'Handle end-to-end IT recruitment for Contract-to-Hire and Permanent roles '
        'at a staffing firm in Banashankari, Bangalore. Source via Naukri, LinkedIn, '
        'and referrals. Only Bangalore-based candidates considered.',
    jobType: JobType.fullTime, workMode: WorkMode.onsite,
    level: ExperienceLevel.junior,
    location: 'Banashankari, Bangalore',
    experience: '1–4 Years',
    qualification: 'MBA HR / Any Graduate',
    department: 'Human Resources',
    skills: ['IT Recruitment','Naukri','LinkedIn','C2H Staffing','Sourcing','HR Screening'],
    responsibilities: [
      'Source, screen, and shortlist IT candidates',
      'Manage stakeholder communication for open roles',
      'Maintain recruitment tracker and pipeline',
    ],
    tags: ['recruiter','hr','staffing','bangalore'],
    applyUrl: 'https://www.linkedin.com/feed/',
    postedAt: DateTime(2025, 6, 11),
    isUrgent: false, isFeatured: false,
  ),

  // ── 12. Freelance IT Recruiter – WFH ─────────────────────────
  PlacementJob(
    id: 'rec-f-1', companyName: 'Confidential', companyLogo: '',
    role: 'Freelance IT Recruiter',
    description:
        'Work-from-home freelance IT recruiter role on a commission/sharing basis. '
        'Flexible hours as per requirement. Contact via WhatsApp to discuss.',
    jobType: JobType.freelance, workMode: WorkMode.remote,
    level: ExperienceLevel.junior,
    location: 'Work from Home',
    salary: 'Sharing / Commission Based',
    experience: 'Any',
    qualification: 'Any Graduate',
    contactInfo: '8779640704 (WhatsApp)',
    department: 'Human Resources',
    skills: ['IT Recruitment','Sourcing','LinkedIn','Naukri'],
    responsibilities: [
      'Source candidates for client IT requirements',
      'Submit relevant profiles to client within deadlines',
    ],
    tags: ['freelance','recruiter','wfh','commission'],
    applyUrl: 'tel:8779640704',
    postedAt: DateTime(2025, 6, 16),
    isUrgent: false, isFeatured: false,
  ),

  // ── 13. CA – Jewelry Company Mumbai ──────────────────────────
  PlacementJob(
    id: 'ca-jew-1', companyName: 'Jewelry Company', companyLogo: '',
    role: 'Chartered Accountant (CA)',
    description:
        'CA required for a reputed jewelry company in Mumbai. Full JD available '
        'on the job portal. Immediate or early joiners preferred.',
    jobType: JobType.fullTime, workMode: WorkMode.onsite,
    level: ExperienceLevel.mid,
    location: 'Mumbai',
    experience: 'Relevant CA Experience',
    qualification: 'CA Qualified',
    contactInfo: 'cv@ejobocean.com',
    department: 'Finance & Accounts',
    skills: ['Chartered Accountant','Taxation','Audit','Financial Reporting','Tally'],
    responsibilities: [
      'Handle statutory filings and tax compliance',
      'Prepare financial statements and MIS',
      'Liaise with auditors and regulatory bodies',
    ],
    tags: ['ca','accounts','mumbai','jewelry'],
    applyUrl: 'https://ejobocean.com/job-details/6a17d596dd14b19d2f204d73',
    postedAt: DateTime(2025, 6, 13),
    isUrgent: false, isFeatured: false,
  ),

  // ── 14. Accounts & Finance – SAP – Bengaluru ─────────────────
  PlacementJob(
    id: 'sap-1', companyName: 'Leading Manufacturing Company', companyLogo: '',
    role: 'Accounts & Finance Executive',
    description:
        'URGENT: Leading listed manufacturing company in Bengaluru hiring for Accounts '
        '& Finance. Experience in accounting, finance operations, reconciliations, '
        'MIS reporting. SAP knowledge mandatory. 2–4 years, CA qualified, immediate joiners.',
    jobType: JobType.fullTime, workMode: WorkMode.onsite,
    level: ExperienceLevel.junior,
    location: 'Bengaluru',
    experience: '2–4 Years',
    qualification: 'CA Qualified',
    contactInfo: 'cv@ejobocean.com (Subject: SAP)',
    department: 'Finance & Accounts',
    skills: ['SAP','Accounting','MIS Reporting','Reconciliation','Finance Operations'],
    responsibilities: [
      'Manage day-to-day accounting entries in SAP',
      'Prepare MIS reports and reconciliation statements',
      'Coordinate with auditors for statutory compliance',
    ],
    tags: ['ca','sap','manufacturing','bengaluru','immediate joiner'],
    applyUrl: 'mailto:cv@ejobocean.com',
    postedAt: DateTime(2025, 6, 17),
    isUrgent: true, isFeatured: false,
  ),

  // ── 15. Statutory Audit CA – Mumbai ──────────────────────────
  PlacementJob(
    id: 'audit-1', companyName: 'Leading Consulting Firm', companyLogo: '',
    role: 'Statutory Audit – Chartered Accountant',
    description:
        'Leading consulting firm in Mumbai hiring CA professionals for Statutory Audit. '
        '1–5 years of statutory audit experience required.',
    jobType: JobType.fullTime, workMode: WorkMode.onsite,
    level: ExperienceLevel.junior,
    location: 'Mumbai',
    experience: '1–5 Years',
    qualification: 'CA Qualified',
    contactInfo: 'cv@ejobocean.com (Subject: Audit)',
    department: 'Audit & Assurance',
    skills: ['Statutory Audit','CA','Financial Statements','IFRS','Ind AS','Audit Procedures'],
    responsibilities: [
      'Conduct statutory audits for client entities',
      'Review financial statements for accuracy and compliance',
      'Prepare audit reports and management letters',
    ],
    tags: ['ca','audit','statutory','consulting','mumbai'],
    applyUrl: 'mailto:cv@ejobocean.com',
    postedAt: DateTime(2025, 6, 6),
    isUrgent: false, isFeatured: false,
  ),

  // ── 16. Ujjivan SFB – Manager Transformation ─────────────────
  PlacementJob(
    id: 'ujj-1', companyName: 'Ujjivan Small Finance Bank', companyLogo: '',
    role: 'Manager – Transformation',
    description:
        'Drive digital and process transformation initiatives at Ujjivan SFB\'s '
        'Head Office in Koramangala, Bangalore. Work on strategy and execution of '
        'change management programmes across the bank.',
    jobType: JobType.fullTime, workMode: WorkMode.onsite,
    level: ExperienceLevel.mid,
    location: 'Koramangala, Bangalore',
    salary: 'Competitive Banking Package',
    experience: 'Relevant Experience in Transformation / Banking',
    qualification: 'MBA / B.Tech or equivalent',
    contactInfo: 'vyasyaraju.badrinathraju@ujjivan.com',
    department: 'Strategy & Transformation',
    skills: ['Digital Transformation','Process Improvement','Project Management','Banking','Change Management'],
    responsibilities: [
      'Lead transformation projects end-to-end',
      'Coordinate cross-functional teams for process redesign',
      'Track milestones and report to senior leadership',
    ],
    tags: ['banking','transformation','ujjivan','bangalore'],
    applyUrl: 'mailto:vyasyaraju.badrinathraju@ujjivan.com',
    postedAt: DateTime(2025, 6, 4),
    isUrgent: false, isFeatured: false,
  ),

  // ── 17. Ujjivan SFB – Lead Fintech Services ──────────────────
  PlacementJob(
    id: 'ujj-2', companyName: 'Ujjivan Small Finance Bank', companyLogo: '',
    role: 'Lead – Fintech Services',
    description:
        'Lead fintech partnerships and digital product initiatives at Ujjivan SFB\'s '
        'Head Office in Koramangala, Bangalore. Drive API banking, open banking '
        'partnerships, and digital lending products.',
    jobType: JobType.fullTime, workMode: WorkMode.onsite,
    level: ExperienceLevel.senior,
    location: 'Koramangala, Bangalore',
    salary: 'Competitive Banking Package',
    experience: 'Senior Fintech / Banking Experience',
    qualification: 'MBA / B.Tech or equivalent',
    contactInfo: 'vyasyaraju.badrinathraju@ujjivan.com',
    department: 'Fintech & Digital',
    skills: ['Fintech','API Integration','Digital Banking','Product Management','Open Banking'],
    responsibilities: [
      'Identify and on-board fintech partnerships',
      'Drive digital product roadmap for banking services',
      'Coordinate with tech and business teams for implementation',
    ],
    tags: ['fintech','banking','ujjivan','product','bangalore'],
    applyUrl: 'mailto:vyasyaraju.badrinathraju@ujjivan.com',
    postedAt: DateTime(2025, 6, 4),
    isUrgent: false, isFeatured: false,
  ),

  // ── 18. Front Office Admin – Koramangala (Women Only) ─────────
  PlacementJob(
    id: 'fo-1', companyName: 'Company, Koramangala', companyLogo: '',
    role: 'Front Office & Administration Executive',
    description:
        'Women candidates only. Manage front office operations, welcome visitors, '
        'maintain records, handle petty cash, prepare expense reports in Excel, '
        'and coordinate with Accounts and Management. Located in Koramangala, Bengaluru.',
    jobType: JobType.fullTime, workMode: WorkMode.onsite,
    level: ExperienceLevel.junior,
    location: 'Koramangala, Bengaluru',
    experience: '1–3 Years',
    qualification: 'Any Graduate',
    department: 'Administration',
    skills: ['MS Excel','Front Office Management','Record Keeping','Petty Cash','Coordination'],
    responsibilities: [
      'Manage front desk and visitor management',
      'Maintain admin records, petty cash, and expense sheets',
      'Coordinate with accounts and senior management',
    ],
    tags: ['admin','front office','women only','koramangala','bangalore'],
    applyUrl: 'https://www.linkedin.com/feed/',
    postedAt: DateTime(2025, 6, 19),
    isUrgent: false, isFeatured: false,
  ),
];

// ─────────────────────────────────────────────────────────────
// PROVIDERS
// ─────────────────────────────────────────────────────────────

// Filter state
class _Filters {
  final String  search;
  final String? type, mode, level;
  const _Filters({this.search='', this.type, this.mode, this.level});
  _Filters copyWith({String? search, Object? type='__', Object? mode='__', Object? level='__'}) =>
    _Filters(
      search: search ?? this.search,
      type:  identical(type,'__')  ? this.type  : type as String?,
      mode:  identical(mode,'__')  ? this.mode  : mode as String?,
      level: identical(level,'__') ? this.level : level as String?,
    );
}

final _filtersProvider = StateProvider<_Filters>((ref) => const _Filters());

final _savedIdsProvider = StateProvider<Set<String>>((ref) => {});

final _jobsProvider = FutureProvider.family<List<PlacementJob>, _Filters>((ref, f) async {
  // Try Supabase first, fall back to seed data
  try {
    var q = Supabase.instance.client
        .from('placement_jobs')
        .select()
        .eq('is_approved', true);
    if (f.type  != null) q = q.eq('job_type',          f.type!);
    if (f.mode  != null) q = q.eq('work_mode',         f.mode!);
    if (f.level != null) q = q.eq('experience_level',  f.level!);
    if (f.search.isNotEmpty) q = q.ilike('role', '%${f.search}%');
    final data = await q
        .order('is_featured', ascending: false)
        .order('is_urgent',   ascending: false)
        .order('posted_at',   ascending: false)
        .timeout(const Duration(seconds: 4));
    if ((data as List).isNotEmpty) {
      return data.map((j) => PlacementJob.fromJson(j)).toList();
    }
  } catch (_) {}
  // Seed fallback with client-side filtering
  var jobs = _seedJobs.toList();
  if (f.type  != null) jobs = jobs.where((j) => j.jobType.name  == f.type).toList();
  if (f.mode  != null) jobs = jobs.where((j) => j.workMode.name == f.mode).toList();
  if (f.level != null) jobs = jobs.where((j) => j.level.name    == f.level).toList();
  if (f.search.isNotEmpty) {
    final q = f.search.toLowerCase();
    jobs = jobs.where((j) =>
      j.role.toLowerCase().contains(q) ||
      j.companyName.toLowerCase().contains(q) ||
      j.skills.any((s) => s.toLowerCase().contains(q)) ||
      j.tags.any((t) => t.toLowerCase().contains(q))
    ).toList();
  }
  jobs.sort((a, b) {
    if (a.isFeatured != b.isFeatured) return a.isFeatured ? -1 : 1;
    if (a.isUrgent   != b.isUrgent)   return a.isUrgent   ? -1 : 1;
    return b.postedAt.compareTo(a.postedAt);
  });
  return jobs;
});

// ─────────────────────────────────────────────────────────────
// PLACEMENT DESK SCREEN  (entry point)
// ─────────────────────────────────────────────────────────────
class PlacementDeskScreen extends ConsumerStatefulWidget {
  const PlacementDeskScreen({super.key});
  @override
  ConsumerState<PlacementDeskScreen> createState() => _PlacementDeskState();
}

class _PlacementDeskState extends ConsumerState<PlacementDeskScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;
  final _searchCtrl = TextEditingController();

  @override
  void initState() { super.initState(); _tab = TabController(length: 3, vsync: this); }
  @override
  void dispose()   { _tab.dispose(); _searchCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final f = ref.watch(_filtersProvider);
    return Scaffold(
      backgroundColor: _bg,
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [
          SliverAppBar(
            backgroundColor: _bg,
            expandedHeight: 140,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: _header(),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(44),
              child: _tabBar(),
            ),
          ),
        ],
        body: Column(children: [
          _searchBar(f),
          _filterRow(f),
          Expanded(
            child: TabBarView(controller: _tab, children: [
              _JobListView(filters: f, savedOnly: false),
              _JobListView(filters: f.copyWith(type: 'internship'), savedOnly: false),
              _JobListView(filters: f, savedOnly: true),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _header() => Container(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        colors: [Color(0xFF1A1A40), _bg],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
    ),
    padding: const EdgeInsets.fromLTRB(20, 56, 20, 0),
    child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
      Container(
        width: 44, height: 44,
        decoration: BoxDecoration(
          color: _pri.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _pri.withOpacity(0.3)),
        ),
        child: const Icon(Icons.work_outline, color: _pri, size: 22),
      ),
      const SizedBox(width: 14),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Placement Desk',
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        Text('${_seedJobs.length} live openings',
            style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13)),
      ]),
      const Spacer(),
      // Stats pill
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: _grn.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _grn.withOpacity(0.3)),
        ),
        child: Row(children: [
          Container(width: 7, height: 7,
              decoration: BoxDecoration(color: _grn, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          const Text('Hiring Now',
              style: TextStyle(color: _grn, fontSize: 11, fontWeight: FontWeight.bold)),
        ]),
      ),
    ]),
  );

  PreferredSizeWidget _tabBar() => TabBar(
    controller: _tab,
    indicatorColor: _pri,
    indicatorWeight: 2,
    labelColor: _pri,
    unselectedLabelColor: Colors.white54,
    labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
    tabs: const [Tab(text: 'All Jobs'), Tab(text: 'Internships'), Tab(text: 'Saved')],
  );

  Widget _searchBar(_Filters f) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
    child: TextField(
      controller: _searchCtrl,
      style: const TextStyle(color: Colors.white),
      onChanged: (v) => ref.read(_filtersProvider.notifier).update((s) => s.copyWith(search: v)),
      decoration: InputDecoration(
        hintText: 'Search roles, skills, companies...',
        hintStyle: const TextStyle(color: Colors.white30, fontSize: 13),
        prefixIcon: const Icon(Icons.search, color: Colors.white38, size: 20),
        suffixIcon: f.search.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.close, color: Colors.white38, size: 18),
                onPressed: () {
                  _searchCtrl.clear();
                  ref.read(_filtersProvider.notifier).update((s) => s.copyWith(search: ''));
                })
            : null,
        filled: true, fillColor: _surf,
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _pri)),
      ),
    ),
  );

  Widget _filterRow(_Filters f) {
    final hasFilter = f.mode != null || f.level != null;
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      scrollDirection: Axis.horizontal,
      child: Row(children: [
        _popupFilter(
          label: 'Mode', current: f.mode,
          options: const {'Remote':'remote','Onsite':'onsite','Hybrid':'hybrid'},
          onPick: (v) => ref.read(_filtersProvider.notifier).update(
              (s) => s.copyWith(mode: v == f.mode ? null : v)),
        ),
        const SizedBox(width: 8),
        _popupFilter(
          label: 'Level', current: f.level,
          options: const {
            'Fresher':'fresher','Junior':'junior',
            'Mid':'mid','Senior':'senior','Lead':'lead'
          },
          onPick: (v) => ref.read(_filtersProvider.notifier).update(
              (s) => s.copyWith(level: v == f.level ? null : v)),
        ),
        if (hasFilter) ...[
          const SizedBox(width: 8),
          ActionChip(
            label: const Text('Clear all', style: TextStyle(color: _red, fontSize: 11)),
            backgroundColor: _red.withOpacity(0.08),
            side: const BorderSide(color: _red, width: 0.8),
            padding: EdgeInsets.zero,
            onPressed: () => ref.read(_filtersProvider.notifier).update(
                (s) => s.copyWith(mode: null, level: null)),
          ),
        ],
      ]),
    );
  }

  Widget _popupFilter({
    required String label, required String? current,
    required Map<String, String> options, required void Function(String) onPick,
  }) {
    final activeLabel = current != null
        ? options.entries.firstWhere((e) => e.value == current, orElse: () => MapEntry(label,'')).key
        : label;
    return PopupMenuButton<String>(
      color: _s2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: onPick,
      itemBuilder: (_) => options.entries.map((e) => PopupMenuItem(
        value: e.value,
        height: 42,
        child: Row(children: [
          Icon(e.value == current ? Icons.radio_button_checked : Icons.radio_button_off,
              color: e.value == current ? _pri : Colors.white38, size: 16),
          const SizedBox(width: 8),
          Text(e.key, style: TextStyle(
              color: e.value == current ? Colors.white : Colors.white70, fontSize: 13)),
        ]),
      )).toList(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: current != null ? _pri.withOpacity(0.12) : _surf,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: current != null ? _pri : Colors.white12),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.tune, size: 13, color: current != null ? _pri : Colors.white38),
          const SizedBox(width: 5),
          Text(activeLabel, style: TextStyle(
              color: current != null ? _pri : Colors.white60,
              fontSize: 12, fontWeight: FontWeight.w600)),
          const SizedBox(width: 3),
          Icon(Icons.arrow_drop_down, size: 16, color: current != null ? _pri : Colors.white38),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// JOB LIST VIEW
// ─────────────────────────────────────────────────────────────
class _JobListView extends ConsumerWidget {
  final _Filters filters;
  final bool savedOnly;
  const _JobListView({required this.filters, required this.savedOnly});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobsAsync = ref.watch(_jobsProvider(filters));
    final savedIds  = ref.watch(_savedIdsProvider);

    return jobsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator(color: _pri)),
      error:   (e, _) => _empty('Couldn\'t load jobs.\nCheck your connection.', Icons.wifi_off_outlined),
      data: (all) {
        final jobs = savedOnly ? all.where((j) => savedIds.contains(j.id)).toList() : all;
        if (jobs.isEmpty) {
          return savedOnly
              ? _empty('No saved jobs yet.\nTap the bookmark to save a job.', Icons.bookmark_outline)
              : _empty('No openings match your filters.', Icons.search_off_rounded);
        }
        return RefreshIndicator(
          color: _pri,
          onRefresh: () async => ref.refresh(_jobsProvider(filters)),
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            itemCount: jobs.length,
            itemBuilder: (_, i) => _JobCard(
              job: jobs[i],
              isSaved: savedIds.contains(jobs[i].id),
              onSave: () => ref.read(_savedIdsProvider.notifier).update((s) {
                final next = {...s};
                if (next.contains(jobs[i].id)) next.remove(jobs[i].id);
                else next.add(jobs[i].id);
                return next;
              }),
            ),
          ),
        );
      },
    );
  }

  Widget _empty(String msg, IconData icon) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: Colors.white24, size: 48),
        const SizedBox(height: 14),
        Text(msg, textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white38, fontSize: 14, height: 1.6)),
      ]),
    ),
  );
}

// ─────────────────────────────────────────────────────────────
// JOB CARD
// ─────────────────────────────────────────────────────────────
class _JobCard extends StatelessWidget {
  final PlacementJob job;
  final bool isSaved;
  final VoidCallback onSave;
  const _JobCard({required this.job, required this.isSaved, required this.onSave});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => _JobDetailScreen(job: job))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: _surf,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: job.isFeatured ? _pri.withOpacity(0.35) : Colors.white.withOpacity(0.05),
          ),
          boxShadow: job.isFeatured
              ? [BoxShadow(color: _pri.withOpacity(0.12), blurRadius: 16, offset: const Offset(0, 4))]
              : [],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          // ── Top section ──────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 12, 12),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [

              // Company avatar
              _Avatar(name: job.companyName, url: job.companyLogo),
              const SizedBox(width: 12),

              // Title
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                if (job.isUrgent)
                  Container(
                    margin: const EdgeInsets.only(bottom: 5),
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                        color: _red.withOpacity(0.12), borderRadius: BorderRadius.circular(6)),
                    child: const Text('● URGENT',
                        style: TextStyle(color: _red, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.8)),
                  ),
                Text(job.role,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                    maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 3),
                Text(job.companyName,
                    style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
              ])),

              // Bookmark
              GestureDetector(
                onTap: onSave,
                child: Padding(
                  padding: const EdgeInsets.only(left: 8, top: 2),
                  child: Icon(
                    isSaved ? Icons.bookmark : Icons.bookmark_outline,
                    color: isSaved ? _pri : Colors.white30,
                    size: 22,
                  ),
                ),
              ),
            ]),
          ),

          // ── Meta chips ────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(spacing: 6, runSpacing: 6, children: [
              _chip(job.location, Icons.location_on_outlined),
              _chip(job.workModeLabel, _modeIcon(job.workMode),
                  color: job.workMode == WorkMode.remote ? _grn : null),
              _chip(job.jobTypeLabel, Icons.work_outline),
              if (job.salary != null)
                _chip(job.salary!, Icons.payments_outlined, color: _grn),
              if (job.experience != null)
                _chip(job.experience!, Icons.timelapse_outlined),
            ]),
          ),

          // ── Description snippet ───────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
            child: Text(job.description,
                maxLines: 2, overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.white.withOpacity(0.45), fontSize: 12.5, height: 1.5)),
          ),

          // ── Skill pills ───────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            child: Wrap(spacing: 6, runSpacing: 6,
              children: job.skills.take(4).map((s) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                    color: _pri.withOpacity(0.09),
                    borderRadius: BorderRadius.circular(6)),
                child: Text(s, style: const TextStyle(color: _pri, fontSize: 10, fontWeight: FontWeight.w600)),
              )).toList()),
          ),

          const Divider(color: Colors.white10, height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(children: [
              Text(
                'Posted ${job.postedAt.day}/${job.postedAt.month}/${job.postedAt.year}',
                style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 11),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () async {
                  final url = Uri.parse(job.applyUrl);
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.inAppWebView);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _pri,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Apply Now', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String name, url;
  final double size;
  const _Avatar({required this.name, required this.url, this.size = 40});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: _s2,
      backgroundImage: url.isNotEmpty ? NetworkImage(url) : null,
      child: url.isEmpty
          ? Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: const TextStyle(color: _pri, fontWeight: FontWeight.bold, fontSize: 16),
            )
          : null,
    );
  }
}

IconData _modeIcon(WorkMode mode) {
  switch (mode) {
    case WorkMode.remote: return Icons.laptop_chromebook;
    case WorkMode.hybrid: return Icons.home_work_outlined;
    case WorkMode.onsite: return Icons.business_outlined;
  }
}

Widget _chip(String text, IconData icon, {Color? color}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.04),
      borderRadius: BorderRadius.circular(6),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: color ?? Colors.white38),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(color: color ?? Colors.white70, fontSize: 11),
        ),
      ],
    ),
  );
}

class _JobDetailScreen extends StatelessWidget {
  final PlacementJob job;
  const _JobDetailScreen({required this.job});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Job Details', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Header Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _surf,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: Row(children: [
              _Avatar(name: job.companyName, url: job.companyLogo, size: 56),
              const SizedBox(width: 16),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(job.role, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text(job.companyName, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14)),
                ]),
              ),
            ]),
          ),
          const SizedBox(height: 20),

          // Overview Details
          const Text('Overview', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          _detailRow(Icons.location_on_outlined, 'Location', job.location),
          _detailRow(Icons.work_outline, 'Job Type', job.jobTypeLabel),
          _detailRow(Icons.laptop, 'Work Mode', job.workModeLabel),
          _detailRow(Icons.school_outlined, 'Experience Level', job.levelLabel),
          if (job.salary != null) _detailRow(Icons.payments_outlined, 'Salary', job.salary!),
          if (job.experience != null) _detailRow(Icons.timelapse_outlined, 'Experience Required', job.experience!),
          if (job.qualification != null) _detailRow(Icons.menu_book_outlined, 'Qualification', job.qualification!),
          if (job.shift != null) _detailRow(Icons.wb_sunny_outlined, 'Shift', job.shift!),
          if (job.department != null) _detailRow(Icons.business_outlined, 'Department', job.department!),
          if (job.contactInfo != null) _detailRow(Icons.contact_phone_outlined, 'Contact Info', job.contactInfo!),
          const SizedBox(height: 20),

          // Description
          const Text('Description', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(job.description, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14, height: 1.5)),
          const SizedBox(height: 20),

          // Skills Required
          if (job.skills.isNotEmpty) ...[
            const Text('Skills Required', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: job.skills.map((s) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _pri.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _pri.withOpacity(0.3)),
                ),
                child: Text(s, style: const TextStyle(color: _pri, fontSize: 12, fontWeight: FontWeight.w600)),
              )).toList(),
            ),
            const SizedBox(height: 20),
          ],

          // Responsibilities
          if (job.responsibilities.isNotEmpty) ...[
            const Text('Key Responsibilities', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ...job.responsibilities.map((r) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('• ', style: TextStyle(color: _pri, fontSize: 16, fontWeight: FontWeight.bold)),
                Expanded(child: Text(r, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13, height: 1.4))),
              ]),
            )),
            const SizedBox(height: 20),
          ],

          // Apply Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () async {
                final url = Uri.parse(job.applyUrl);
                if (await canLaunchUrl(url)) {
                  await launchUrl(url, mode: LaunchMode.inAppWebView);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _pri,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Apply for this Position', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 30),
        ]),
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(children: [
        Icon(icon, color: Colors.white38, size: 20),
        const SizedBox(width: 12),
        Text('$label: ', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13)),
        Expanded(child: Text(value, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500))),
      ]),
    );
  }
}