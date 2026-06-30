import '../models/internship_models.dart';

final aiBasicsCourse = InternshipCourse(
  id: 'course_ai_basics_001',
  title: 'AI & ML Fundamentals',
  subtitle: 'Complete basics of Artificial Intelligence in one shot',
  description:
      'An introductory course covering the core ideas behind AI and '
      'machine learning — what they are, how they differ, and the '
      'foundational concepts you need before going deeper into ML '
      'engineering or data science tracks.',
  thumbnailUrl: 'https://img.youtube.com/vi/D1eL1EnxXXQ/hqdefault.jpg',
  category: 'Data Science',
  difficulty: DifficultyLevel.beginner,
  durationMinutes: 240, // adjust to the tutorial's actual runtime
  totalVideos: 1,
  totalAssignments: 1,
  instructorName: 'Apna College',
  instructorAvatar: '',
  rating: 0.0, // populate once you have real student ratings
  enrolledCount: 0,
  isApproved: true,
  createdAt: DateTime(2026, 6, 29),
  skillsYouLearn: const [
    'AI fundamentals',
    'Machine learning basics',
    'Key terminology (model, training, inference)',
    'Where AI/ML fits in a tech career',
  ],
  sections: [
    CourseSection(
      id: 'section_ai_basics_intro',
      courseId: 'course_ai_basics_001',
      title: 'Getting Started with AI',
      orderIndex: 0,
      videos: [
        CourseVideo(
          id: 'video_ai_basics_oneshot',
          sectionId: 'section_ai_basics_intro',
          title: 'AI & ML Fundamentals — Complete One Shot',
          description:
              'A single end-to-end walkthrough of AI/ML basics for '
              'complete beginners — no prior background assumed.',
          videoUrl: 'https://www.youtube.com/watch?v=D1eL1EnxXXQ',
          thumbnailUrl: 'https://img.youtube.com/vi/D1eL1EnxXXQ/hqdefault.jpg',
          durationSeconds: 14400, // placeholder — set to actual length
          orderIndex: 0,
          isPreview: true, // free preview since it's a public YouTube video
          resources: const [],
        ),
      ],
      assignments: [
        CourseAssignment(
          id: 'assignment_ai_basics_recap',
          sectionId: 'section_ai_basics_intro',
          courseId: 'course_ai_basics_001',
          title: 'AI Basics Recap',
          description:
              'Short written recap to confirm understanding of the video.',
          instructions:
              'In 150-300 words, explain in your own words: (1) the '
              'difference between AI and ML, (2) what "training a model" '
              'means, and (3) one real-world application you found '
              'interesting from the video.',
          maxScore: 20,
          orderIndex: 0,
          attachmentUrls: const [],
        ),
      ],
    ),
  ],
);

/// A short quiz to gate the certificate, matching CourseTestQuestion.
final aiBasicsTestQuestions = [
  CourseTestQuestion(
    id: 'q1_ai_basics',
    courseId: 'course_ai_basics_001',
    question: 'Which best describes the relationship between AI and ML?',
    options: const [
      'They are unrelated fields',
      'ML is a subset of AI focused on learning from data',
      'AI is a subset of ML',
      'They are interchangeable terms with no distinction',
    ],
    correctOptionIndex: 1,
    explanation:
        'Machine learning is one approach within the broader field of AI, '
        'specifically focused on systems that improve from data.',
    marks: 5,
  ),
  CourseTestQuestion(
    id: 'q2_ai_basics',
    courseId: 'course_ai_basics_001',
    question: 'What does "training" a model typically involve?',
    options: const [
      'Manually programming every possible output',
      'Feeding the model data so it can learn patterns',
      'Deleting the model after one use',
      'Running the model without any input',
    ],
    correctOptionIndex: 1,
    marks: 5,
  ),
];

/// Example of how an internship opportunity can require this course.
final mlInternshipExample = InternshipOpportunity(
  id: 'opportunity_ml_intern_001',
  companyName: 'Example Analytics Co.',
  companyLogoUrl: '',
  role: 'ML Intern (Entry Level)',
  description:
      'Support the data team with model evaluation and dataset prep. '
      'No prior professional experience required — this course covers '
      'the prerequisite fundamentals.',
  type: OpportunityType.internship,
  location: 'Remote',
  isRemote: true,
  duration: '3 months',
  stipend: '₹10,000/month',
  requiredSkills: const ['AI fundamentals', 'Python basics'],
  postedAt: DateTime(2026, 6, 1),
  deadline: DateTime(2026, 8, 31),
  applyUrl: 'https://example.com/careers/ml-intern',
  isApproved: true,
);
