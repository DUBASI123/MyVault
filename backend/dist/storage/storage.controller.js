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
exports.StorageController = void 0;
const common_1 = require("@nestjs/common");
const swagger_1 = require("@nestjs/swagger");
const platform_express_1 = require("@nestjs/platform-express");
const storage_service_1 = require("./storage.service");
let StorageController = class StorageController {
    constructor(storageService) {
        this.storageService = storageService;
    }
    async getDownloadUrl(path, fileName) {
        const url = await this.storageService.getPresignedDownloadUrl(path, fileName);
        return { url };
    }
    async getViewUrl(path) {
        const url = await this.storageService.getPresignedViewUrl(path);
        return { url };
    }
    async redirectUrl(path, res) {
        const url = await this.storageService.getPresignedViewUrl(path);
        return res.redirect(url);
    }
    async getPresignedUploadUrl(fileName, contentType) {
        const key = `cms-uploads/${Date.now()}_${fileName || 'document.pdf'}`;
        const result = await this.storageService.getPresignedUploadUrl(key, contentType || 'application/pdf');
        return result;
    }
    async uploadFile(file) {
        if (!file)
            throw new Error('File required');
        const key = `cms-uploads/${Date.now()}_${file.originalname}`;
        const fileUrl = await this.storageService.uploadDirectBuffer(file.buffer, key, file.mimetype);
        return { fileUrl };
    }
};
exports.StorageController = StorageController;
__decorate([
    (0, common_1.Get)('download/*'),
    (0, swagger_1.ApiOperation)({ summary: 'Get pre-signed S3 download URL' }),
    __param(0, (0, common_1.Param)('0')),
    __param(1, (0, common_1.Query)('fileName')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, String]),
    __metadata("design:returntype", Promise)
], StorageController.prototype, "getDownloadUrl", null);
__decorate([
    (0, common_1.Get)('view/*'),
    (0, swagger_1.ApiOperation)({ summary: 'Get pre-signed S3 view URL' }),
    __param(0, (0, common_1.Param)('0')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", Promise)
], StorageController.prototype, "getViewUrl", null);
__decorate([
    (0, common_1.Get)('redirect/*'),
    (0, swagger_1.ApiOperation)({ summary: 'Direct redirect to pre-signed S3 URL' }),
    __param(0, (0, common_1.Param)('0')),
    __param(1, (0, common_1.Res)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, Object]),
    __metadata("design:returntype", Promise)
], StorageController.prototype, "redirectUrl", null);
__decorate([
    (0, common_1.Get)('presigned-upload'),
    (0, swagger_1.ApiOperation)({ summary: 'Get pre-signed S3 upload URL for CMS Website uploads' }),
    __param(0, (0, common_1.Query)('fileName')),
    __param(1, (0, common_1.Query)('contentType')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, String]),
    __metadata("design:returntype", Promise)
], StorageController.prototype, "getPresignedUploadUrl", null);
__decorate([
    (0, common_1.Post)('upload'),
    (0, swagger_1.ApiOperation)({ summary: 'Direct file upload to AWS S3 bucket' }),
    (0, common_1.UseInterceptors)((0, platform_express_1.FileInterceptor)('file')),
    __param(0, (0, common_1.UploadedFile)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object]),
    __metadata("design:returntype", Promise)
], StorageController.prototype, "uploadFile", null);
exports.StorageController = StorageController = __decorate([
    (0, swagger_1.ApiTags)('S3 Storage'),
    (0, common_1.Controller)('api/s3'),
    __metadata("design:paramtypes", [storage_service_1.StorageService])
], StorageController);
//# sourceMappingURL=storage.controller.js.map