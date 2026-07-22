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
exports.AcademicController = void 0;
const common_1 = require("@nestjs/common");
const swagger_1 = require("@nestjs/swagger");
const academic_service_1 = require("./academic.service");
let AcademicController = class AcademicController {
    constructor(academicService) {
        this.academicService = academicService;
    }
    async getSubjects(branch, semester, subjectType) {
        return this.academicService.getSubjects(branch, semester, subjectType);
    }
    async getContents(subjectId, contentType) {
        return this.academicService.getSubjectContents(subjectId, contentType);
    }
};
exports.AcademicController = AcademicController;
__decorate([
    (0, common_1.Get)('subjects'),
    (0, swagger_1.ApiOperation)({ summary: 'Get curriculum subjects for branch and semester' }),
    (0, swagger_1.ApiQuery)({ name: 'branch', example: 'ECE' }),
    (0, swagger_1.ApiQuery)({ name: 'semester', example: 1 }),
    (0, swagger_1.ApiQuery)({ name: 'subjectType', required: false, example: 'academic' }),
    __param(0, (0, common_1.Query)('branch')),
    __param(1, (0, common_1.Query)('semester')),
    __param(2, (0, common_1.Query)('subjectType')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, Number, String]),
    __metadata("design:returntype", Promise)
], AcademicController.prototype, "getSubjects", null);
__decorate([
    (0, common_1.Get)('contents/:subjectId'),
    (0, swagger_1.ApiOperation)({ summary: 'Get study contents for a specific subject' }),
    __param(0, (0, common_1.Param)('subjectId')),
    __param(1, (0, common_1.Query)('contentType')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, String]),
    __metadata("design:returntype", Promise)
], AcademicController.prototype, "getContents", null);
exports.AcademicController = AcademicController = __decorate([
    (0, swagger_1.ApiTags)('Academic'),
    (0, common_1.Controller)('api/academic'),
    __metadata("design:paramtypes", [academic_service_1.AcademicService])
], AcademicController);
//# sourceMappingURL=academic.controller.js.map