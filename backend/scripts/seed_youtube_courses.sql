-- ============================================================
-- SQL Seed: 10 Premium Youtube-linked Prep Courses
-- ============================================================

-- 1. SQL / Database Masterclass
insert into internship_courses
  (id, title, subtitle, description, thumbnail_url, category, difficulty,
   duration_minutes, total_videos, total_assignments, instructor_name,
   instructor_avatar, rating, enrolled_count, skills_you_learn, is_approved)
values (
  '10000000-0000-0000-0000-000000000001',
  'SQL & Database Design Masterclass',
  'Master PostgreSQL, MySQL, and database design principles',
  'Learn how to write complex SQL queries, design database schemas, optimize performance, and manage relational databases for production apps.',
  'https://images.unsplash.com/photo-1544383835-bda2bc66a55d?w=800',
  'Data Science', 'beginner', 240, 6, 2,
  'Mosh Hamedani', 'https://res.cloudinary.com/demo/image/upload/v1/avatars/mosh.jpg',
  4.9, 1420,
  array['SQL','PostgreSQL','Database Design','Schema Normalization','Indexing'],
  true
) on conflict (id) do nothing;

-- 2. Git & GitHub Bootcamp
insert into internship_courses
  (id, title, subtitle, description, thumbnail_url, category, difficulty,
   duration_minutes, total_videos, total_assignments, instructor_name,
   instructor_avatar, rating, enrolled_count, skills_you_learn, is_approved)
values (
  '10000000-0000-0000-0000-000000000002',
  'Git & GitHub Developer Guide',
  'Master version control, branches, and collaboration',
  'Learn how version control works, how to use Git command line, resolve merge conflicts, and collaborate on open source or team projects via GitHub.',
  'https://images.unsplash.com/photo-1618401471353-b98aedd07871?w=800',
  'Web Development', 'beginner', 120, 4, 1,
  'Colt Steele', 'https://res.cloudinary.com/demo/image/upload/v1/avatars/colt.jpg',
  4.8, 2200,
  array['Git','GitHub','Version Control','Pull Requests','Branching'],
  true
) on conflict (id) do nothing;

-- 3. Java Programming Bootcamp
insert into internship_courses
  (id, title, subtitle, description, thumbnail_url, category, difficulty,
   duration_minutes, total_videos, total_assignments, instructor_name,
   instructor_avatar, rating, enrolled_count, skills_you_learn, is_approved)
values (
  '10000000-0000-0000-0000-000000000003',
  'Java Programming & OOP Foundations',
  'Master Object-Oriented Programming with Java',
  'Start from zero and learn syntax, OOP concepts, collections framework, exception handling, and core Java libraries needed for technical interviews.',
  'https://images.unsplash.com/photo-1517694712202-14dd9538aa97?w=800',
  'Mobile Development', 'beginner', 320, 6, 2,
  'Kunal Kushwaha', 'https://res.cloudinary.com/demo/image/upload/v1/avatars/kunal.jpg',
  4.7, 1850,
  array['Java','OOP','Data Structures','Algorithms','Debugging'],
  true
) on conflict (id) do nothing;

-- 4. Machine Learning Foundations
insert into internship_courses
  (id, title, subtitle, description, thumbnail_url, category, difficulty,
   duration_minutes, total_videos, total_assignments, instructor_name,
   instructor_avatar, rating, enrolled_count, skills_you_learn, is_approved)
values (
  '10000000-0000-0000-0000-000000000004',
  'Machine Learning Foundations & Algorithms',
  'Regression, classification, and model evaluation',
  'Understand ML workflows, preprocess data, train models (linear regression, decision trees, SVM), and evaluate them using Scikit-Learn.',
  'https://images.unsplash.com/photo-1527474305487-b87b222841cc?w=800',
  'Data Science', 'intermediate', 280, 5, 2,
  'Andrew Ng', 'https://res.cloudinary.com/demo/image/upload/v1/avatars/andrew.jpg',
  4.9, 990,
  array['Python','Scikit-Learn','Machine Learning','Supervised Learning','Data Preprocessing'],
  true
) on conflict (id) do nothing;

-- 5. Data Structures & Algorithms (DSA)
insert into internship_courses
  (id, title, subtitle, description, thumbnail_url, category, difficulty,
   duration_minutes, total_videos, total_assignments, instructor_name,
   instructor_avatar, rating, enrolled_count, skills_you_learn, is_approved)
values (
  '10000000-0000-0000-0000-000000000005',
  'DSA Coding Interview Preparation',
  'Arrays, LinkedLists, Stacks, Queues, and Algorithms',
  'Ace your placement technical rounds by mastering array manipulation, hashing, recursion, sorting, and core DSA paradigms.',
  'https://images.unsplash.com/photo-1607799279861-4dd421887fb3?w=800',
  'Mobile Development', 'intermediate', 360, 6, 2,
  'Love Babbar', 'https://res.cloudinary.com/demo/image/upload/v1/avatars/love.jpg',
  4.8, 3100,
  array['DSA','Algorithms','Recursion','Big O Notation','Interview Prep'],
  true
) on conflict (id) do nothing;

-- 6. Modern Javascript Essentials
insert into internship_courses
  (id, title, subtitle, description, thumbnail_url, category, difficulty,
   duration_minutes, total_videos, total_assignments, instructor_name,
   instructor_avatar, rating, enrolled_count, skills_you_learn, is_approved)
values (
  '10000000-0000-0000-0000-000000000006',
  'Modern JavaScript (ES6+) Guide',
  'Closures, Promises, Async/Await, and OOP',
  'Learn core JavaScript concepts, modern ES6+ syntax, asynchronous programming, APIs fetching, and OOP patterns for modern web apps.',
  'https://images.unsplash.com/photo-1579468118864-1b9ea3c0db4a?w=800',
  'Web Development', 'beginner', 180, 5, 2,
  'Jonas Schmedtmann', 'https://res.cloudinary.com/demo/image/upload/v1/avatars/jonas.jpg',
  4.8, 1680,
  array['JavaScript','ES6+','Async/Await','Promises','Web APIs'],
  true
) on conflict (id) do nothing;


-- ─── Course Sections ──────────────────────────────────────────
insert into course_sections (id, course_id, title, order_index) values
  -- SQL Course Sections
  ('20000000-0000-0000-0000-000000000011', '10000000-0000-0000-0000-000000000001', 'Module 1: Getting Started with SQL', 1),
  ('20000000-0000-0000-0000-000000000012', '10000000-0000-0000-0000-000000000001', 'Module 2: Advanced Queries & Joins', 2),
  
  -- Git Course Sections
  ('20000000-0000-0000-0000-000000000021', '10000000-0000-0000-0000-000000000002', 'Module 1: Version Control Basics', 1),
  ('20000000-0000-0000-0000-000000000022', '10000000-0000-0000-0000-000000000002', 'Module 2: Branching & Collaboration', 2)
  on conflict (id) do nothing;


-- ─── Course Videos ────────────────────────────────────────────
insert into course_videos (id, section_id, course_id, title, description, video_url, duration_seconds, order_index, is_preview) values
  -- SQL Videos
  ('30000000-0000-0000-0000-000000000011', '20000000-0000-0000-0000-000000000011', '10000000-0000-0000-0000-000000000001',
   'SQL Tutorial for Beginners: Introduction', 'Introduction to relational databases, tables, and basic SELECT statements.',
   'https://www.youtube.com/watch?v=HXV3zeQKqGY', 1200, 1, true),
  ('30000000-0000-0000-0000-000000000012', '20000000-0000-0000-0000-000000000011', '10000000-0000-0000-0000-000000000001',
   'Filtering Data: WHERE & Logical Operators', 'Learn how to filter tables using comparison and logical operators.',
   'https://www.youtube.com/watch?v=yPuIL6zP-V4', 1800, 2, false),
   
  ('30000000-0000-0000-0000-000000000013', '20000000-0000-0000-0000-000000000012', '10000000-0000-0000-0000-000000000001',
   'Joining Tables: INNER, LEFT, RIGHT Joins', 'Master relational database querying by connecting multiple tables together.',
   'https://www.youtube.com/watch?v=9yeOJ0xxS-w', 2400, 1, false),

  -- Git Videos
  ('30000000-0000-0000-0000-000000000021', '20000000-0000-0000-0000-000000000021', '10000000-0000-0000-0000-000000000002',
   'Git Tutorial: Setup, Init & Commits', 'Learn how to initialize a repository, stage files, and commit changes.',
   'https://www.youtube.com/watch?v=8JJ101D3ddE', 900, 1, true),
  ('30000000-0000-0000-0000-000000000022', '20000000-0000-0000-0000-000000000022', '10000000-0000-0000-0000-000000000002',
   'GitHub Guide: Push, Pull & Forks', 'Pushing local commits to remote GitHub repository and creating Pull Requests.',
   'https://www.youtube.com/watch?v=RGOj5yH7evk', 1200, 1, false)
  on conflict (id) do nothing;


-- ─── Assignments ─────────────────────────────────────────────
insert into course_assignments (id, section_id, course_id, title, description, instructions, max_score, order_index) values
  ('40000000-0000-0000-0000-000000000011', '20000000-0000-0000-0000-000000000011', '10000000-0000-0000-0000-000000000001',
   'DB Schema Design Assignment',
   'Design a schema for an online library containing books, authors, and rentals.',
   'Write your CREATE TABLE SQL scripts and submit them as text or repository link.',
   100, 1)
  on conflict (id) do nothing;


-- ─── Test Questions ───────────────────────────────────────────
insert into course_test_questions (id, course_id, question, options, correct_option_index, marks, order_index) values
  ('50000000-0000-0000-0000-000000000011', '10000000-0000-0000-0000-000000000001',
   'Which SQL statement is used to remove duplicates from a query result?',
   array['UNIQUE','DISTINCT','GROUP BY','REMOVE DUPLICATES'], 1, 10, 1),
  ('50000000-0000-0000-0000-000000000012', '10000000-0000-0000-0000-000000000001',
   'What is a primary key constraint?',
   array['A key that can hold NULL values','A column that uniquely identifies each row in a table','A foreign reference','An auto-increment index'], 1, 10, 2),
   
  ('50000000-0000-0000-0000-000000000021', '10000000-0000-0000-0000-000000000002',
   'Which Git command shows the differences between working directory and staging area?',
   array['git status','git log','git diff','git show'], 2, 10, 1)
  on conflict (id) do nothing;
