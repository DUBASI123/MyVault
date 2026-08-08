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
exports.AcademicController = exports.CreateContentDto = void 0;
const common_1 = require("@nestjs/common");
const swagger_1 = require("@nestjs/swagger");
const class_validator_1 = require("class-validator");
const academic_service_1 = require("./academic.service");
class CreateContentDto {
}
exports.CreateContentDto = CreateContentDto;
__decorate([
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], CreateContentDto.prototype, "subjectId", void 0);
__decorate([
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], CreateContentDto.prototype, "title", void 0);
__decorate([
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], CreateContentDto.prototype, "contentType", void 0);
__decorate([
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsInt)(),
    __metadata("design:type", Number)
], CreateContentDto.prototype, "unitNumber", void 0);
__decorate([
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], CreateContentDto.prototype, "fileUrl", void 0);
__decorate([
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], CreateContentDto.prototype, "storagePath", void 0);
__decorate([
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], CreateContentDto.prototype, "description", void 0);
let AcademicController = class AcademicController {
    constructor(academicService) {
        this.academicService = academicService;
    }
    async getSubjects(branch, semester, subjectType = 'academic') {
        return this.academicService.getSubjects(branch, parseInt(semester), subjectType);
    }
    async getSubjectContents(subjectId, contentType) {
        return this.academicService.getSubjectContents(subjectId, contentType);
    }
    async createContent(dto) {
        return this.academicService.createContent(dto);
    }
};
exports.AcademicController = AcademicController;
__decorate([
    (0, common_1.Get)('subjects'),
    (0, swagger_1.ApiOperation)({ summary: 'Get subjects by branch and semester' }),
    (0, swagger_1.ApiQuery)({ name: 'branch', required: true, example: 'ECE' }),
    (0, swagger_1.ApiQuery)({ name: 'semester', required: true, example: 1 }),
    (0, swagger_1.ApiQuery)({ name: 'type', required: false, example: 'academic' }),
    __param(0, (0, common_1.Query)('branch')),
    __param(1, (0, common_1.Query)('semester')),
    __param(2, (0, common_1.Query)('type')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, String, String]),
    __metadata("design:returntype", Promise)
], AcademicController.prototype, "getSubjects", null);
__decorate([
    (0, common_1.Get)('subjects/:id/contents'),
    (0, swagger_1.ApiOperation)({ summary: 'Get all contents for a subject' }),
    (0, swagger_1.ApiQuery)({ name: 'type', required: false, description: 'Filter by content type' }),
    __param(0, (0, common_1.Param)('id')),
    __param(1, (0, common_1.Query)('type')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, String]),
    __metadata("design:returntype", Promise)
], AcademicController.prototype, "getSubjectContents", null);
__decorate([
    (0, common_1.Post)('contents'),
    (0, swagger_1.ApiOperation)({ summary: 'Create academic content record (called after S3 upload)' }),
    (0, swagger_1.ApiBody)({ type: CreateContentDto }),
    __param(0, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [CreateContentDto]),
    __metadata("design:returntype", Promise)
], AcademicController.prototype, "createContent", null);
exports.AcademicController = AcademicController = __decorate([
    (0, swagger_1.ApiTags)('Academic Hub'),
    (0, common_1.Controller)('api/academic'),
    __metadata("design:paramtypes", [academic_service_1.AcademicService])
], AcademicController);
//# sourceMappingURL=academic.controller.js.map