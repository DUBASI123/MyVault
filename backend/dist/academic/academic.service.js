"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.AcademicService = void 0;
const common_1 = require("@nestjs/common");
const prisma_service_1 = require("../prisma/prisma.service");
const redis_service_1 = require("../redis/redis.service");
let AcademicService = class AcademicService {
    constructor(prisma, redis) {
        this.prisma = prisma;
        this.redis = redis;
    }
    async getSubjects(branch, semester, subjectType = 'academic') {
        const cacheKey = `subjects:${branch}:${semester}:${subjectType}`;
        const cached = await this.redis.get(cacheKey);
        if (cached) {
            return JSON.parse(cached);
        }
        const data = await this.prisma.subject.findMany({
            where: {
                branch: String(branch),
                semester: Number(semester),
                subjectType: String(subjectType),
            },
            orderBy: { name: 'asc' },
        });
        await this.redis.set(cacheKey, JSON.stringify(data), 600);
        return data;
    }
    async getSubjectContents(subjectId, contentType) {
        return this.prisma.academicContent.findMany({
            where: {
                subjectId,
                ...(contentType && contentType !== 'all' ? { contentType: String(contentType) } : {}),
            },
            orderBy: { createdAt: 'desc' },
        });
    }
};
exports.AcademicService = AcademicService;
exports.AcademicService = AcademicService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService,
        redis_service_1.RedisService])
], AcademicService);
//# sourceMappingURL=academic.service.js.map