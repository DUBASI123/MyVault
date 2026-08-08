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
    async getDownloadUrl(key, fileName) {
        if (!key)
            throw new common_1.BadRequestException('S3 key required');
        const url = await this.storageService.getPresignedDownloadUrl(key, fileName);
        return { url };
    }
    async getViewUrl(key) {
        if (!key)
            throw new common_1.BadRequestException('S3 key required');
        const url = await this.storageService.getPresignedViewUrl(key);
        return { url };
    }
    async redirect(key, res) {
        const url = await this.storageService.getPresignedViewUrl(key);
        return res.redirect(302, url);
    }
    async getPresignedUploadUrl(fileName, contentType, folder = 'study-materials') {
        if (!fileName)
            throw new common_1.BadRequestException('fileName is required');
        const safeName = fileName.replace(/\s+/g, '-');
        const key = `${folder}/${Date.now()}_${safeName}`;
        return this.storageService.getPresignedUploadUrl(key, contentType || 'application/octet-stream');
    }
    async uploadFile(file, folder = 'study-materials') {
        if (!file)
            throw new common_1.BadRequestException('file is required');
        const key = `${folder}/${Date.now()}_${file.originalname.replace(/\s+/g, '-')}`;
        const fileUrl = await this.storageService.uploadDirectBuffer(file.buffer, key, file.mimetype);
        return { fileUrl, key };
    }
    async deleteObject(key) {
        if (!key)
            throw new common_1.BadRequestException('S3 key required');
        await this.storageService.deleteObject(key);
        return { deleted: true, key };
    }
};
exports.StorageController = StorageController;
__decorate([
    (0, common_1.Get)('download/*'),
    (0, swagger_1.ApiOperation)({ summary: 'Get presigned S3 download URL (15 min expiry)' }),
    (0, swagger_1.ApiQuery)({ name: 'fileName', required: false }),
    __param(0, (0, common_1.Param)('0')),
    __param(1, (0, common_1.Query)('fileName')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, String]),
    __metadata("design:returntype", Promise)
], StorageController.prototype, "getDownloadUrl", null);
__decorate([
    (0, common_1.Get)('view/*'),
    (0, swagger_1.ApiOperation)({ summary: 'Get presigned S3 inline view URL (1 hr expiry)' }),
    __param(0, (0, common_1.Param)('0')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", Promise)
], StorageController.prototype, "getViewUrl", null);
__decorate([
    (0, common_1.Get)('redirect/*'),
    (0, swagger_1.ApiOperation)({ summary: 'Redirect browser directly to presigned S3 view URL' }),
    __param(0, (0, common_1.Param)('0')),
    __param(1, (0, common_1.Res)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, Object]),
    __metadata("design:returntype", Promise)
], StorageController.prototype, "redirect", null);
__decorate([
    (0, common_1.Get)('presign-upload'),
    (0, swagger_1.ApiOperation)({ summary: 'Get presigned S3 PUT URL — browser uploads directly to S3' }),
    (0, swagger_1.ApiQuery)({ name: 'fileName', required: true, example: 'DLD_notes.pdf' }),
    (0, swagger_1.ApiQuery)({ name: 'contentType', required: false, example: 'application/pdf' }),
    (0, swagger_1.ApiQuery)({ name: 'folder', required: false, example: 'study-materials', description: 'S3 folder prefix' }),
    __param(0, (0, common_1.Query)('fileName')),
    __param(1, (0, common_1.Query)('contentType')),
    __param(2, (0, common_1.Query)('folder')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, String, String]),
    __metadata("design:returntype", Promise)
], StorageController.prototype, "getPresignedUploadUrl", null);
__decorate([
    (0, common_1.Post)('upload'),
    (0, swagger_1.ApiOperation)({ summary: 'Upload file via backend → S3 (use presign-upload for large files)' }),
    (0, swagger_1.ApiConsumes)('multipart/form-data'),
    (0, swagger_1.ApiBody)({ description: 'File upload', schema: { type: 'object', properties: { file: { type: 'string', format: 'binary' }, folder: { type: 'string' } } } }),
    (0, common_1.UseInterceptors)((0, platform_express_1.FileInterceptor)('file')),
    __param(0, (0, common_1.UploadedFile)()),
    __param(1, (0, common_1.Query)('folder')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, String]),
    __metadata("design:returntype", Promise)
], StorageController.prototype, "uploadFile", null);
__decorate([
    (0, common_1.Delete)('object/*'),
    (0, swagger_1.ApiOperation)({ summary: 'Delete an object from S3 by key' }),
    __param(0, (0, common_1.Param)('0')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", Promise)
], StorageController.prototype, "deleteObject", null);
exports.StorageController = StorageController = __decorate([
    (0, swagger_1.ApiTags)('S3 Storage'),
    (0, common_1.Controller)('api/s3'),
    __metadata("design:paramtypes", [storage_service_1.StorageService])
], StorageController);
//# sourceMappingURL=storage.controller.js.map