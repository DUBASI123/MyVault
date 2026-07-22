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
exports.ContentService = void 0;
const common_1 = require("@nestjs/common");
const prisma_service_1 = require("../prisma/prisma.service");
const redis_service_1 = require("../redis/redis.service");
let ContentService = class ContentService {
    constructor(prisma, redis) {
        this.prisma = prisma;
        this.redis = redis;
    }
    async getTicker() {
        const cached = await this.redis.get('content:ticker');
        if (cached)
            return JSON.parse(cached);
        const items = await this.prisma.notification.findMany({
            orderBy: { createdAt: 'desc' },
            take: 5,
        });
        const ticker = items.length
            ? items.map((n) => `🔔 ${n.title}`).join(' | ')
            : 'Welcome to MyVault — your student platform';
        const result = { ticker };
        await this.redis.set('content:ticker', JSON.stringify(result), 300);
        return result;
    }
    async getNotifications() {
        return this.prisma.notification.findMany({
            orderBy: { createdAt: 'desc' },
        });
    }
    async getResults(branch, semester) {
        return this.prisma.examResult.findMany({
            where: {
                ...(branch ? { branch } : {}),
                ...(semester ? { semester: Number(semester) } : {}),
            },
            orderBy: { subject: 'asc' },
        });
    }
    async getInternships(type) {
        return this.prisma.internship.findMany({
            where: type ? { type } : undefined,
            orderBy: { createdAt: 'desc' },
        });
    }
};
exports.ContentService = ContentService;
exports.ContentService = ContentService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService,
        redis_service_1.RedisService])
], ContentService);
//# sourceMappingURL=content.service.js.map