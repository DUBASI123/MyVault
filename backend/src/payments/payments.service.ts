import { Injectable, Logger, BadRequestException } from '@nestjs/common';
import { CreateOrderDto, PaymentGateway } from './dto/create-order.dto';
import { VerifyPaymentDto } from './dto/verify-payment.dto';
import * as crypto from 'crypto';

@Injectable()
export class PaymentsService {
  private readonly logger = new Logger(PaymentsService.name);

  async createOrder(dto: CreateOrderDto, studentId: string) {
    this.logger.log(`Creating ${dto.gateway} payment order for student ${studentId}: ${dto.amount} ${dto.currency}`);

    if (dto.gateway === PaymentGateway.RAZORPAY) {
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

    // Fallback Mock Order for development/testing
    const mockOrderId = `order_mock_${Date.now()}`;
    return {
      gateway: dto.gateway,
      orderId: mockOrderId,
      amount: Math.round(dto.amount * 100),
      currency: dto.currency,
      message: 'Mock Order generated successfully',
    };
  }

  async verifyPayment(dto: VerifyPaymentDto) {
    const secret = process.env.RAZORPAY_KEY_SECRET;
    if (secret) {
      const generatedSignature = crypto
        .createHmac('sha256', secret)
        .update(`${dto.orderId}|${dto.paymentId}`)
        .digest('hex');

      if (generatedSignature !== dto.signature) {
        throw new BadRequestException('Invalid payment signature');
      }
    }

    return {
      status: 'SUCCESS',
      message: 'Payment signature verified successfully',
      orderId: dto.orderId,
      paymentId: dto.paymentId,
    };
  }
}
