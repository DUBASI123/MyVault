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
var __param = (this && this.__param) || function (paramIndex, decorator) {
    return function (target, key) { decorator(target, key, paramIndex); }
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.ContentController = void 0;
const common_1 = require("@nestjs/common");
const swagger_1 = require("@nestjs/swagger");
const content_service_1 = require("./content.service");
let ContentController = class ContentController {
    constructor(contentService) {
        this.contentService = contentService;
    }
    async getTicker() {
        return this.contentService.getTicker();
    }
    async getNotifications() {
        return this.contentService.getNotifications();
    }
    async getResults(branch, semester) {
        return this.contentService.getResults(branch, semester);
    }
    async getInternships(type) {
        return this.contentService.getInternships(type);
    }
};
exports.ContentController = ContentController;
__decorate([
    (0, common_1.Get)('ticker'),
    (0, swagger_1.ApiOperation)({ summary: 'Get home screen announcement ticker text' }),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", Promise)
], ContentController.prototype, "getTicker", null);
__decorate([
    (0, common_1.Get)('notifications'),
    (0, swagger_1.ApiOperation)({ summary: 'Get notification list' }),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", Promise)
], ContentController.prototype, "getNotifications", null);
__decorate([
    (0, common_1.Get)('results'),
    (0, swagger_1.ApiOperation)({ summary: 'Get exam result grades' }),
    (0, swagger_1.ApiQuery)({ name: 'branch', required: false, example: 'CSE' }),
    (0, swagger_1.ApiQuery)({ name: 'semester', required: false, example: 3 }),
    __param(0, (0, common_1.Query)('branch')),
    __param(1, (0, common_1.Query)('semester')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, Number]),
    __metadata("design:returntype", Promise)
], ContentController.prototype, "getResults", null);
__decorate([
    (0, common_1.Get)('internships'),
    (0, swagger_1.ApiOperation)({ summary: 'Get open internship opportunities' }),
    (0, swagger_1.ApiQuery)({ name: 'type', required: false }),
    __param(0, (0, common_1.Query)('type')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", Promise)
], ContentController.prototype, "getInternships", null);
exports.ContentController = ContentController = __decorate([
    (0, swagger_1.ApiTags)('Content & Feeds'),
    (0, common_1.Controller)('api/content'),
    __metadata("design:paramtypes", [content_service_1.ContentService])
], ContentController);
//# sourceMappingURL=content.controller.js.map