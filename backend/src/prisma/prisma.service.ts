import { Injectable, OnModuleInit, OnModuleDestroy } from '@nestjs/common';

@Injectable()
export class PrismaService implements OnModuleInit, OnModuleDestroy {
  async onModuleInit() {}
  async onModuleDestroy() {}

  university = {
    findMany: async (args?: any) => {
      return [
        { id: '1', name: 'JNTUH Affiliated', code: 'JNTUH', state: 'Telangana', createdAt: new Date() },
        { id: '2', name: 'Osmania University Affiliated', code: 'OU', state: 'Telangana', createdAt: new Date() },
      ];
    }
  };

  college = {
    findMany: async (args?: any) => {
      const all = [
        { id: 'c_nitw', universityId: '6', name: 'NIT Warangal', code: 'NITW', district: 'Hanamkonda', type: 'Government' },
        { id: 'c_kitsw', universityId: '3', name: 'KITS Warangal', code: 'KITSW', district: 'Hasanparthy, Hanamkonda', type: 'Private' },
        { id: 'c_vcew', universityId: '3', name: 'Vaagdevi College of Engineering', code: 'VCEW', district: 'Bollikunta, Warangal', type: 'Private' },
      ];
      if (args && args.where && args.where.universityId) {
        return all.filter(c => c.universityId === args.where.universityId);
      }
      return all;
    }
  };

  student = {
    findFirst: async (args?: any) => {
      return {
        id: 'demo-1',
        firstName: 'Shivashankar',
        lastName: 'Dubasi',
        fullNameAadhar: 'Dubasi Shivashankar',
        mobile: '9876543210',
        email: 'shiva@example.com',
        passwordHash: '$2a$10$Efy7N2GepYtQ64Lkh3/Vke13hZ86xO3698v5.5Hh6z/0WzK.t117G', // password hash for 'password'
        hallTicket: 'JNTUH20CS001',
        universityId: '1',
        collegeId: 'c_1',
        course: 'B.Tech',
        branch: 'CSE',
        semester: 3,
        role: 'admin',
        university: { id: '1', name: 'JNTUH Affiliated', code: 'JNTUH' },
        college: { id: 'c_1', name: 'JNTU College of Engineering Hyderabad', code: 'JNTUH' }
      };
    },
    findUnique: async (args?: any) => {
      return {
        id: args?.where?.id || 'demo-1',
        firstName: 'Shivashankar',
        lastName: 'Dubasi',
        fullNameAadhar: 'Dubasi Shivashankar',
        mobile: '9876543210',
        email: 'shiva@example.com',
        passwordHash: '$2a$10$Efy7N2GepYtQ64Lkh3/Vke13hZ86xO3698v5.5Hh6z/0WzK.t117G',
        hallTicket: 'JNTUH20CS001',
        universityId: '1',
        collegeId: 'c_1',
        course: 'B.Tech',
        branch: 'CSE',
        semester: 3,
        role: 'admin',
        university: { id: '1', name: 'JNTUH Affiliated', code: 'JNTUH' },
        college: { id: 'c_1', name: 'JNTU College of Engineering Hyderabad', code: 'JNTUH' }
      };
    },
    create: async (args?: any) => {
      return {
        id: 'demo-2',
        ...args?.data,
        role: 'student',
        university: { id: '1', name: 'JNTUH Affiliated', code: 'JNTUH' },
        college: { id: 'c_1', name: 'JNTU College of Engineering Hyderabad', code: 'JNTUH' }
      };
    },
    update: async (args?: any) => {
      return {
        id: args?.where?.id || 'demo-1',
        ...args?.data,
      };
    }
  };

  subject = {
    findMany: async (args?: any) => {
      return [
        { id: 'sub-math', name: 'Mathematics', code: 'MA201', branch: 'CSE', semester: 3, subjectType: 'academic' },
        { id: 'sub-phy', name: 'Physics', code: 'PH201', branch: 'CSE', semester: 3, subjectType: 'academic' },
        { id: 'sub-ds', name: 'Data Structures', code: 'CS201', branch: 'CSE', semester: 3, subjectType: 'academic' },
        { id: 'sub-dbms', name: 'DBMS', code: 'CS301', branch: 'CSE', semester: 3, subjectType: 'academic' },
      ];
    }
  };

  academicContent = {
    findMany: async (args?: any) => {
      return [
        {
          id: 'c_1',
          subjectId: args?.where?.subjectId || 'sub-ds',
          title: 'DS Unit 1 Notes',
          contentType: 'notes',
          description: 'Introduction to Arrays & Linked Lists',
          unitNumber: 1,
          fileUrl: 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
          createdAt: new Date(),
        },
        {
          id: 'c_3',
          subjectId: args?.where?.subjectId || 'sub-ds',
          title: 'Stacks & Queues Lecture',
          contentType: 'video',
          description: 'Recorded classroom session',
          unitNumber: null,
          fileUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
          createdAt: new Date(),
        },
      ];
    },
    findUnique: async (args?: any) => {
      return {
        id: args?.where?.id || 'c_1',
        title: 'Mock Content',
        fileUrl: 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
        createdAt: new Date()
      };
    },
    create: async (args?: any) => {
      return {
        id: 'new-c-id',
        ...args?.data,
        createdAt: new Date()
      };
    },
    delete: async (args?: any) => {
      return { id: args?.where?.id };
    }
  };

  notification = {
    findMany: async (args?: any) => {
      return [
        { id: '1', title: 'TSPSC Group I Notification', message: 'TSPSC Group I notification released.', type: 'govt_job', createdAt: new Date() },
        { id: '2', title: 'JNTUH Mid-2 Exams', message: 'Mid-2 examinations start from December 15, 2024', type: 'exam_timetable', createdAt: new Date() }
      ];
    }
  };

  examResult = {
    findMany: async (args?: any) => {
      return [
        { id: '1', subject: 'Mathematics - I', code: 'M101', internal: 28, external: 62, total: 90, max: 100, grade: 'A+', status: 'Pass', branch: 'CSE', semester: 3, createdAt: new Date() },
        { id: '2', subject: 'Data Structures', code: 'CS201', internal: 20, external: 35, total: 55, max: 100, grade: 'C', status: 'Pass', branch: 'CSE', semester: 3, createdAt: new Date() }
      ];
    }
  };

  internship = {
    findMany: async (args?: any) => {
      return [
        { id: 'i1', company: 'Infosys', role: 'Software Engineer Intern', type: 'IT', domain: 'Java / Python', stipend: '15000', duration: '6 months', deadline: '2024-12-31', applyLink: 'https://infosys.com', status: 'Open', createdAt: new Date() }
      ];
    }
  };
}
