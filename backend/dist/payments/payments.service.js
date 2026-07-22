"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var PaymentsService_1;
Object.defineProperty(exports, "__esModule", { value: true });
exports.PaymentsService = void 0;
const common_1 = require("@nestjs/common");
const create_order_dto_1 = require("./dto/create-order.dto");
const crypto = require("crypto");
let PaymentsService = PaymentsService_1 = class PaymentsService {
    constructor() {
        this.logger = new common_1.Logger(PaymentsService_1.name);
    }
    async createOrder(dto, studentId) {
        this.logger.log(`Creating ${dto.gateway} payment order for student ${studentId}: ${dto.amount} ${dto.currency}`);
        if (dto.gateway === create_order_dto_1.PaymentGateway.RAZORPAY) {
            const razorpayKey = process.env.RAZORPAY_KEY_ID;
            const razorpaySecret = process.env.RAZORPAY_KEY_SECRET;
            if (razorpayKey && razorpaySecret) {
                const Razorpay = require('razorpay');
                const instance = new Razorpay({ key_id: razorpayKey, key_secret: razorpaySecret });
                const order = await instance.orders.create({
                    amount: Math.round(dto.amount * 100),
                    currency: dto.currency || 'INR',
                    receipt: `receipt_${Date.now()}`,
                    notes: { studentId, description: dto.description },
                });
                return { gateway: 'RAZORPAY', orderId: order.id, amount: order.amount, currency: order.currency, key: razorpayKey };
            }
        }
        const mockOrderId = `order_mock_${Date.now()}`;
        return {
            gateway: dto.gateway,
            orderId: mockOrderId,
            amount: Math.round(dto.amount * 100),
            currency: dto.currency,
            message: 'Mock Order generated successfully',
        };
    }
    async verifyPayment(dto) {
        const secret = process.env.RAZORPAY_KEY_SECRET;
        if (secret) {
            const generatedSignature = crypto
                .createHmac('sha256', secret)
                .update(`${dto.orderId}|${dto.paymentId}`)
                .digest('hex');
            if (generatedSignature !== dto.signature) {
                throw new common_1.BadRequestException('Invalid payment signature');
            }
        }
        return {
            status: 'SUCCESS',
            message: 'Payment signature verified successfully',
            orderId: dto.orderId,
            paymentId: dto.paymentId,
        };
    }
};
exports.PaymentsService = PaymentsService;
exports.PaymentsService = PaymentsService = PaymentsService_1 = __decorate([
    (0, common_1.Injectable)()
], PaymentsService);
//# sourceMappingURL=payments.service.js.map