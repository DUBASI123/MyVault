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
const client_s3_1 = require("@aws-sdk/client-s3");
const s3_request_presigner_1 = require("@aws-sdk/s3-request-presigner");
let StorageService = class StorageService {
    constructor() {
        this.bucketName = process.env.AWS_S3_BUCKET || 'myvault-files';
        this.s3Client = new client_s3_1.S3Client({
            region: process.env.AWS_REGION || 'eu-north-1',
            credentials: {
                accessKeyId: process.env.AWS_ACCESS_KEY_ID || '',
                secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY || '',
            },
        });
    }
    async getPresignedDownloadUrl(key, fileName) {
        if (!key)
            throw new common_1.BadRequestException('Key required');
        const command = new client_s3_1.GetObjectCommand({
            Bucket: this.bucketName,
            Key: key,
            ResponseContentDisposition: `attachment; filename="${fileName || key.split('/').pop()}"`,
        });
        return (0, s3_request_presigner_1.getSignedUrl)(this.s3Client, command, { expiresIn: 3600 });
    }
    async getPresignedViewUrl(key) {
        if (!key)
            throw new common_1.BadRequestException('Key required');
        const command = new client_s3_1.GetObjectCommand({
            Bucket: this.bucketName,
            Key: key,
            ResponseContentDisposition: 'inline',
        });
        return (0, s3_request_presigner_1.getSignedUrl)(this.s3Client, command, { expiresIn: 3600 });
    }
    async getPresignedUploadUrl(key, contentType) {
        if (!key)
            throw new common_1.BadRequestException('Key required');
        const command = new client_s3_1.PutObjectCommand({
            Bucket: this.bucketName,
            Key: key,
            ContentType: contentType,
        });
        const uploadUrl = await (0, s3_request_presigner_1.getSignedUrl)(this.s3Client, command, { expiresIn: 3600 });
        const fileUrl = `https://${this.bucketName}.s3.${process.env.AWS_REGION || 'eu-north-1'}.amazonaws.com/${key}`;
        return { uploadUrl, fileUrl };
    }
    async uploadDirectBuffer(buffer, key, contentType) {
        const command = new client_s3_1.PutObjectCommand({
            Bucket: this.bucketName,
            Key: key,
            Body: buffer,
            ContentType: contentType,
        });
        await this.s3Client.send(command);
        return `https://${this.bucketName}.s3.${process.env.AWS_REGION || 'eu-north-1'}.amazonaws.com/${key}`;
    }
};
exports.StorageService = StorageService;
exports.StorageService = StorageService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [])
], StorageService);
//# sourceMappingURL=storage.service.js.map