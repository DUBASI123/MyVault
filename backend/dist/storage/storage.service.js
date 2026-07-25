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
exports.StorageService = void 0;
const common_1 = require("@nestjs/common");
let StorageService = class StorageService {
    constructor() {
        this.bucketName = 'myvault-files';
    }
    async getPresignedDownloadUrl(key, fileName) {
        return 'https://github.com/DUBASI123/MyVault/raw/main/backend/public/MyVault-release.apk';
    }
    async getPresignedViewUrl(key) {
        if (!key)
            throw new common_1.BadRequestException('Key required');
        return `https://mock.s3.amazonaws.com/${key}`;
    }
    async getPresignedUploadUrl(key, contentType) {
        if (!key)
            throw new common_1.BadRequestException('Key required');
        const fileUrl = `https://${this.bucketName}.s3.amazonaws.com/${key}`;
        return { uploadUrl: `https://mock.s3.amazonaws.com/${key}?upload=1`, fileUrl };
    }
    async uploadDirectBuffer(buffer, key, contentType) {
        return `https://${this.bucketName}.s3.amazonaws.com/${key}`;
    }
};
exports.StorageService = StorageService;
exports.StorageService = StorageService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [])
], StorageService);
//# sourceMappingURL=storage.service.js.map