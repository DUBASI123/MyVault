-- ============================================================
-- SQL Seed: 10 Additional Premium Prep Courses (Total reaches 20)
-- ============================================================

-- 1. Node.js & Express Backend Development
insert into internship_courses
  (id, title, subtitle, description, thumbnail_url, category, difficulty,
   duration_minutes, total_videos, total_assignments, instructor_name,
   instructor_avatar, rating, enrolled_count, skills_you_learn, is_approved)
values (
  '55555555-5555-5555-5555-000000000001',
  'Node.js & Express Backend Masterclass',
  'Build scalable RESTful APIs and real-time backend services',
  'Learn event loop, npm, Express middleware, routing, authentication with JWT, MongoDB integration, and deployment pipelines.',
  'https://images.unsplash.com/photo-1555066931-4365d14bab8c?w=800',
  'Web Development', 'intermediate', 240, 4, 1,
  'Dave Gray', 'https://res.cloudinary.com/demo/image/upload/v1/avatars/mosh.jpg',
  4.9, 1200,
  array['Node.js','Express','REST APIs','JWT','MongoDB'],
  true
) on conflict (id) do nothing;

-- 2. Next.js React Framework
insert into internship_courses
  (id, title, subtitle, description, thumbnail_url, category, difficulty,
   duration_minutes, total_videos, total_assignments, instructor_name,
   instructor_avatar, rating, enrolled_count, skills_you_learn, is_approved)
values (
  '55555555-5555-5555-5555-000000000002',
  'Next.js 14 Production Guide',
  'Master App Router, Server Components, and Server Actions',
  'Learn modern React frameworks, Server Components, routing, SSR/SSG/ISR rendering modes, API routes, and Tailwind integration.',
  'https://images.unsplash.com/photo-1531403009284-440f080d1e12?w=800',
  'Web Development', 'advanced', 180, 3, 1,
  'Lee Robinson', 'https://res.cloudinary.com/demo/image/upload/v1/avatars/jonas.jpg',
  4.8, 950,
  array['Next.js','React Server Components','Tailwind CSS','Vercel'],
  true
) on conflict (id) do nothing;

-- 3. Intro to Python & Data Analysis
insert into internship_courses
  (id, title, subtitle, description, thumbnail_url, category, difficulty,
   duration_minutes, total_videos, total_assignments, instructor_name,
   instructor_avatar, rating, enrolled_count, skills_you_learn, is_approved)
values (
  '55555555-5555-5555-5555-000000000003',
  'Python for Data Science Beginners',
  'Start parsing, cleaning, and visualizing data in Python',
  'Learn core Python syntax, control structures, list comprehensions, and data analysis packages like NumPy and Pandas.',
  'https://images.unsplash.com/photo-1526374965328-7f61d4dc18c5?w=800',
  'Data Science', 'beginner', 150, 3, 1,
  'Corey Schafer', 'https://res.cloudinary.com/demo/image/upload/v1/avatars/kunal.jpg',
  4.7, 1800,
  array['Python','Data Analytics','Pandas','NumPy'],
  true
) on conflict (id) do nothing;

-- 4. Deep Learning with TensorFlow
insert into internship_courses
  (id, title, subtitle, description, thumbnail_url, category, difficulty,
   duration_minutes, total_videos, total_assignments, instructor_name,
   instructor_avatar, rating, enrolled_count, skills_you_learn, is_approved)
values (
  '55555555-5555-5555-5555-000000000004',
  'Deep Learning & Neural Networks',
  'Build and train CNNs, RNNs, and models using TensorFlow',
  'Understand neural network math, construct deep networks, handle gradient descent, train convolutional layers, and solve computer vision problems.',
  'https://images.unsplash.com/photo-1620712943543-bcc4688e7485?w=800',
  'Data Science', 'advanced', 320, 4, 1,
  'Andrew Ng', 'https://res.cloudinary.com/demo/image/upload/v1/avatars/andrew.jpg',
  4.9, 870,
  array['TensorFlow','Deep Learning','CNNs','Computer Vision'],
  true
) on conflict (id) do nothing;

-- 5. Figma Advanced Prototyping
insert into internship_courses
  (id, title, subtitle, description, thumbnail_url, category, difficulty,
   duration_minutes, total_videos, total_assignments, instructor_name,
   instructor_avatar, rating, enrolled_count, skills_you_learn, is_approved)
values (
  '55555555-5555-5555-5555-000000000005',
  'Figma Design Systems & Prototyping',
  'Create scalable component libraries and micro-interactions',
  'Master auto-layout, variables, design system structure, nested components, interactive states, and high-fidelity mobile flow prototyping.',
  'https://images.unsplash.com/photo-1611162617213-7d7a39e9b1d7?w=800',
  'UI/UX Design', 'intermediate', 160, 3, 1,
  'Sneha Iyer', 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150',
  4.8, 620,
  array['Figma','Design Systems','Auto Layout','Interactive Prototyping'],
  true
) on conflict (id) do nothing;

-- 6. iOS App Development with SwiftUI
insert into internship_courses
  (id, title, subtitle, description, thumbnail_url, category, difficulty,
   duration_minutes, total_videos, total_assignments, instructor_name,
   instructor_avatar, rating, enrolled_count, skills_you_learn, is_approved)
values (
  '55555555-5555-5555-5555-000000000006',
  'SwiftUI iOS App Development',
  'Build native iOS apps using modern declarative Swift UI',
  'Learn Swift language fundamentals, lists, state variables, navigation patterns, network integrations, and App Store guidelines.',
  'https://images.unsplash.com/photo-1512941937669-90a1b58e7e9c?w=800',
  'Mobile Development', 'intermediate', 280, 3, 1,
  'Angela Yu', 'https://res.cloudinary.com/demo/image/upload/v1/avatars/colt.jpg',
  4.9, 1100,
  array['Swift','SwiftUI','iOS Development','XCode'],
  true
) on conflict (id) do nothing;

-- 7. React Native Development
insert into internship_courses
  (id, title, subtitle, description, thumbnail_url, category, difficulty,
   duration_minutes, total_videos, total_assignments, instructor_name,
   instructor_avatar, rating, enrolled_count, skills_you_learn, is_approved)
values (
  '55555555-5555-5555-5555-000000000007',
  'React Native Cross-Platform Apps',
  'Build native Android and iOS apps from a single JavaScript codebase',
  'Learn React Native basics, Expo workflow, styling, navigation with React Navigation, device features, and app packaging.',
  'https://images.unsplash.com/photo-1551650975-87deedd944c3?w=800',
  'Mobile Development', 'intermediate', 210, 3, 1,
  'Maximilian Schwarzmüller', 'https://res.cloudinary.com/demo/image/upload/v1/avatars/jonas.jpg',
  4.7, 1340,
  array['React Native','Expo','JavaScript','Mobile Components'],
  true
) on conflict (id) do nothing;

-- 8. Cybersecurity Basics
insert into internship_courses
  (id, title, subtitle, description, thumbnail_url, category, difficulty,
   duration_minutes, total_videos, total_assignments, instructor_name,
   instructor_avatar, rating, enrolled_count, skills_you_learn, is_approved)
values (
  '55555555-5555-5555-5555-000000000008',
  'Cybersecurity Foundations',
  'Understand network security, cryptography, and server hardening',
  'Learn fundamental security protocols, secure networks, firewalls, public/private keys, threat models, and safe development practices.',
  'https://images.unsplash.com/photo-1550751827-4bd374c3f58b?w=800',
  'Web Development', 'beginner', 140, 3, 1,
  'Colt Steele', 'https://res.cloudinary.com/demo/image/upload/v1/avatars/colt.jpg',
  4.8, 790,
  array['Cybersecurity','Cryptography','Network Security','Pentesting Basics'],
  true
) on conflict (id) do nothing;

-- 9. DevOps & Docker
insert into internship_courses
  (id, title, subtitle, description, thumbnail_url, category, difficulty,
   duration_minutes, total_videos, total_assignments, instructor_name,
   instructor_avatar, rating, enrolled_count, skills_you_learn, is_approved)
values (
  '55555555-5555-5555-5555-000000000009',
  'Docker & Containerization Guide',
  'Package, run, and scale applications in isolated containers',
  'Learn containerization principles, write Dockerfiles, manage images, use docker-compose, and deploy microservices.',
  'https://images.unsplash.com/photo-1600132806370-bf17e65e942f?w=800',
  'Web Development', 'intermediate', 160, 3, 1,
  'Dave Gray', 'https://res.cloudinary.com/demo/image/upload/v1/avatars/mosh.jpg',
  4.8, 930,
  array['Docker','Containerization','DevOps','Docker Compose'],
  true
) on conflict (id) do nothing;

-- 10. Data Visualization with Tableau & Power BI
insert into internship_courses
  (id, title, subtitle, description, thumbnail_url, category, difficulty,
   duration_minutes, total_videos, total_assignments, instructor_name,
   instructor_avatar, rating, enrolled_count, skills_you_learn, is_approved)
values (
  '55555555-5555-5555-5555-000000000010',
  'Data Visualization Masterclass',
  'Build stunning dashboards with Tableau and Power BI',
  'Learn how to import, clean, model, and visualize business data using charts, maps, and interactive metrics reporting dashboards.',
  'https://images.unsplash.com/photo-1551288049-bebda4e38f71?w=800',
  'Data Science', 'beginner', 180, 3, 1,
  'Kunal Kushwaha', 'https://res.cloudinary.com/demo/image/upload/v1/avatars/kunal.jpg',
  4.7, 1020,
  array['Tableau','Power BI','Data Visualization','Dashboards'],
  true
) on conflict (id) do nothing;

-- ─── Course Sections ──────────────────────────────────────────
insert into course_sections (id, course_id, title, order_index) values
  ('60000000-0000-0000-0000-000000000011', '55555555-5555-5555-5555-000000000001', 'Module 1: Node.js Basics & Express Intro', 1),
  ('60000000-0000-0000-0000-000000000021', '55555555-5555-5555-5555-000000000002', 'Module 1: Next.js Setup & Routing', 1),
  ('60000000-0000-0000-0000-000000000031', '55555555-5555-5555-5555-000000000003', 'Module 1: Python Basics', 1),
  ('60000000-0000-0000-0000-000000000041', '55555555-5555-5555-5555-000000000004', 'Module 1: Deep Learning Foundations', 1),
  ('60000000-0000-0000-0000-000000000051', '55555555-5555-5555-5555-000000000005', 'Module 1: Figma Layouts & Systems', 1),
  ('60000000-0000-0000-0000-000000000061', '55555555-5555-5555-5555-000000000006', 'Module 1: Swift & SwiftUI Basics', 1),
  ('60000000-0000-0000-0000-000000000071', '55555555-5555-5555-5555-000000000007', 'Module 1: React Native Core Components', 1),
  ('60000000-0000-0000-0000-000000000081', '55555555-5555-5555-5555-000000000008', 'Module 1: Crypto & Network Basics', 1),
  ('60000000-0000-0000-0000-000000000091', '55555555-5555-5555-5555-000000000009', 'Module 1: Containerization Concepts', 1),
  ('60000000-0000-0000-0000-000000000101', '55555555-5555-5555-5555-000000000010', 'Module 1: Tableau Quickstart', 1)
on conflict (id) do nothing;

-- ─── Course Videos ────────────────────────────────────────────
insert into course_videos (id, section_id, course_id, title, description, video_url, duration_seconds, order_index, is_preview) values
  ('70000000-0000-0000-0000-000000000011', '60000000-0000-0000-0000-000000000011', '55555555-5555-5555-5555-000000000001',
   'Node.js Express API Tutorial', 'Setting up express app and server middleware.', 'https://www.youtube.com/watch?v=SccSCuHhOw0', 1800, 1, true),
  ('70000000-0000-0000-0000-000000000021', '60000000-0000-0000-0000-000000000021', '55555555-5555-5555-5555-000000000002',
   'Next.js 14 Course Introduction', 'App router layout structure overview.', 'https://www.youtube.com/watch?v=wm5gMKuwSYk', 1200, 1, true),
  ('70000000-0000-0000-0000-000000000031', '60000000-0000-0000-0000-000000000031', '55555555-5555-5555-5555-000000000003',
   'Python Data Science Tutorial', 'Basic parsing and variables.', 'https://www.youtube.com/watch?v=rfscVS0vtbw', 1500, 1, true),
  ('70000000-0000-0000-0000-000000000041', '60000000-0000-0000-0000-000000000041', '55555555-5555-5555-5555-000000000004',
   'TensorFlow Introduction', 'What are weights, biases and activations.', 'https://www.youtube.com/watch?v=tPYj3fFJGjk', 1600, 1, true),
  ('70000000-0000-0000-0000-000000000051', '60000000-0000-0000-0000-000000000051', '55555555-5555-5555-5555-000000000005',
   'Figma Layout Grid Tutorial', 'Using grids and component rules.', 'https://www.youtube.com/watch?v=vV5h2UuT4Hw', 900, 1, true),
  ('70000000-0000-0000-0000-000000000061', '60000000-0000-0000-0000-000000000061', '55555555-5555-5555-5555-000000000006',
   'SwiftUI Basics Guide', 'Using stacks and states.', 'https://www.youtube.com/watch?v=F2ojHyqfnIY', 1100, 1, true),
  ('70000000-0000-0000-0000-000000000071', '60000000-0000-0000-0000-000000000071', '55555555-5555-5555-5555-000000000007',
   'React Native Expo Tutorial', 'Expo quick start setup.', 'https://www.youtube.com/watch?v=gvkqT_Uoahw', 1200, 1, true),
  ('70000000-0000-0000-0000-000000000081', '60000000-0000-0000-0000-000000000081', '55555555-5555-5555-5555-000000000008',
   'Cryptography Fundamentals', 'Public and private key explanation.', 'https://www.youtube.com/watch?v=NuyzuNBFWxQ', 1300, 1, true),
  ('70000000-0000-0000-0000-000000000091', '60000000-0000-0000-0000-000000000091', '55555555-5555-5555-5555-000000000009',
   'Docker Quickstart Course', 'Writing your first Dockerfile.', 'https://www.youtube.com/watch?v=3c-iBn73dDE', 1400, 1, true),
  ('70000000-0000-0000-0000-000000000101', '60000000-0000-0000-0000-000000000101', '55555555-5555-5555-5555-000000000010',
   'Tableau Tutorial for Beginners', 'Visualizing sheets and maps.', 'https://www.youtube.com/watch?v=aHaOIvR00So', 1100, 1, true)
on conflict (id) do nothing;
