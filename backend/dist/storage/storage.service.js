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
var StorageService_1;
Object.defineProperty(exports, "__esModule", { value: true });
exports.StorageService = void 0;
const common_1 = require("@nestjs/common");
const config_1 = require("@nestjs/config");
const client_s3_1 = require("@aws-sdk/client-s3");
const s3_request_presigner_1 = require("@aws-sdk/s3-request-presigner");
const lib_storage_1 = require("@aws-sdk/lib-storage");
let StorageService = StorageService_1 = class StorageService {
    constructor(config) {
        this.config = config;
        this.logger = new common_1.Logger(StorageService_1.name);
        this.region = this.config.get('AWS_REGION') || 'ap-south-1';
        this.bucket = this.config.get('AWS_BUCKET_NAME') || 'myvault-study-materials';
        this.s3 = new client_s3_1.S3Client({
            region: this.region,
            credentials: {
                accessKeyId: this.config.get('AWS_ACCESS_KEY_ID') || '',
                secretAccessKey: this.config.get('AWS_SECRET_ACCESS_KEY') || '',
            },
        });
        this.logger.log(`✅ S3 client initialised — bucket: ${this.bucket} | region: ${this.region}`);
    }
    publicUrl(key) {
        return `https://${this.bucket}.s3.${this.region}.amazonaws.com/${key}`;
    }
    async getPresignedDownloadUrl(key, fileName) {
        if (!key)
            throw new common_1.BadRequestException('S3 key is required');
        const command = new client_s3_1.GetObjectCommand({
            Bucket: this.bucket,
            Key: key,
            ...(fileName && {
                ResponseContentDisposition: `attachment; filename="${encodeURIComponent(fileName)}"`,
            }),
        });
        return (0, s3_request_presigner_1.getSignedUrl)(this.s3, command, { expiresIn: 900 });
    }
    async getPresignedViewUrl(key) {
        if (!key)
            throw new common_1.BadRequestException('S3 key is required');
        const command = new client_s3_1.GetObjectCommand({
            Bucket: this.bucket,
            Key: key,
            ResponseContentDisposition: 'inline',
        });
        return (0, s3_request_presigner_1.getSignedUrl)(this.s3, command, { expiresIn: 3600 });
    }
    async getPresignedUploadUrl(key, contentType) {
        if (!key)
            throw new common_1.BadRequestException('S3 key is required');
        const command = new client_s3_1.PutObjectCommand({
            Bucket: this.bucket,
            Key: key,
            ContentType: contentType,
        });
        const uploadUrl = await (0, s3_request_presigner_1.getSignedUrl)(this.s3, command, { expiresIn: 300 });
        const fileUrl = this.publicUrl(key);
        this.logger.log(`🔗 Presigned upload URL generated for key: ${key}`);
        return { uploadUrl, fileUrl };
    }
    async uploadDirectBuffer(buffer, key, contentType) {
        const command = new client_s3_1.PutObjectCommand({
            Bucket: this.bucket,
            Key: key,
            Body: buffer,
            ContentType: contentType,
        });
        await this.s3.send(command);
        this.logger.log(`📤 Direct upload complete: ${key}`);
        return this.publicUrl(key);
    }
    async uploadStream(stream, key, contentType) {
        const upload = new lib_storage_1.Upload({
            client: this.s3,
            params: {
                Bucket: this.bucket,
                Key: key,
                Body: stream,
                ContentType: contentType,
            },
            queueSize: 4,
            partSize: 5 * 1024 * 1024,
        });
        upload.on('httpUploadProgress', (progress) => {
            this.logger.log(`⬆️  ${key}: ${progress.loaded}/${progress.total} bytes`);
        });
        await upload.done();
        this.logger.log(`✅ Multipart upload complete: ${key}`);
        return this.publicUrl(key);
    }
    async deleteObject(key) {
        await this.s3.send(new client_s3_1.DeleteObjectCommand({ Bucket: this.bucket, Key: key }));
        this.logger.log(`🗑️  Deleted: ${key}`);
    }
};
exports.StorageService = StorageService;
exports.StorageService = StorageService = StorageService_1 = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [config_1.ConfigService])
], StorageService);
//# sourceMappingURL=storage.service.js.map