class ResumeModel {
  final String fullName;
  final String email;
  final String phone;
  final String location;
  final String github;
  final String linkedin;
  final String summary;
  final String college;
  final String degree;
  final String branch;
  final String yearOfGraduation;
  final String cgpa;
  final List<String> skills;
  final List<ResumeProject> projects;
  final List<ResumeExperience> experiences;

  ResumeModel({
    required this.fullName,
    required this.email,
    required this.phone,
    required this.location,
    required this.github,
    required this.linkedin,
    required this.summary,
    required this.college,
    required this.degree,
    required this.branch,
    required this.yearOfGraduation,
    required this.cgpa,
    required this.skills,
    required this.projects,
    required this.experiences,
  });

  factory ResumeModel.sample() => ResumeModel(
        fullName: 'ShivaShankar Dubasi',
        email: 'shiva@gmail.com',
        phone: '+91 9876543210',
        location: 'Hyderabad, India',
        github: 'github.com/DUBASI123',
        linkedin: 'linkedin.com/in/shivadubasi',
        summary:
            'Motivated Electronics and Communication Engineering student with experience in Flutter mobile development, Node.js REST APIs, PostgreSQL database architecture, and AWS S3 integration.',
        college: 'CMR College of Engineering & Technology',
        degree: 'B.Tech',
        branch: 'ECE',
        yearOfGraduation: '2025',
        cgpa: '8.5 / 10.0',
        skills: [
          'Flutter',
          'Dart',
          'Node.js',
          'TypeScript',
          'PostgreSQL',
          'Prisma ORM',
          'AWS S3',
          'Git',
          'REST APIs'
        ],
        projects: [
          ResumeProject(
            title: 'MyVault - Student Academic Platform',
            description:
                'Built a comprehensive academic hub with Riverpod state management, Supabase, Cloudinary media CDN, and AWS S3 release distribution.',
            technologies: 'Flutter, Node.js, Prisma, S3',
          ),
        ],
        experiences: [
          ResumeExperience(
            role: 'Mobile Developer Intern',
            company: 'Tech Solutions Inc.',
            duration: 'Jun 2024 - Aug 2024',
            highlights: 'Developed cross-platform mobile UI components and integrated REST APIs.',
          ),
        ],
      );
}

class ResumeProject {
  final String title;
  final String description;
  final String technologies;

  ResumeProject({
    required this.title,
    required this.description,
    required this.technologies,
  });
}

class ResumeExperience {
  final String role;
  final String company;
  final String duration;
  final String highlights;

  ResumeExperience({
    required this.role,
    required this.company,
    required this.duration,
    required this.highlights,
  });
}
