"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var RedisService_1;
Object.defineProperty(exports, "__esModule", { value: true });
exports.RedisService = void 0;
const common_1 = require("@nestjs/common");
const ioredis_1 = require("ioredis");
let RedisService = RedisService_1 = class RedisService {
    constructor() {
        this.logger = new common_1.Logger(RedisService_1.name);
    }
    onModuleInit() {
        const redisUrl = process.env.REDIS_URL || 'redis://localhost:6379';
        this.client = new ioredis_1.default(redisUrl, {
            lazyConnect: true,
            maxRetriesPerRequest: 3,
        });
        this.client.on('connect', () => this.logger.log('Redis client connected'));
        this.client.on('error', (err) => this.logger.warn(`Redis connection error: ${err.message}`));
    }
    async onModuleDestroy() {
        if (this.client) {
            await this.client.quit();
        }
    }
    async get(key) {
        try {
            return await this.client.get(key);
        }
        catch (_) {
            return null;
        }
    }
    async set(key, value, ttlSeconds) {
        try {
            if (ttlSeconds) {
                await this.client.set(key, value, 'EX', ttlSeconds);
            }
            else {
                await this.client.set(key, value);
            }
        }
        catch (_) { }
    }
    async del(key) {
        try {
            await this.client.del(key);
        }
        catch (_) { }
    }
};
exports.RedisService = RedisService;
exports.RedisService = RedisService = RedisService_1 = __decorate([
    (0, common_1.Injectable)()
], RedisService);
//# sourceMappingURL=redis.service.js.map