import { Controller, Post, Body } from '@nestjs/common';
import { ApiTags, ApiOperation } from '@nestjs/swagger';
import { PaymentsService } from './payments.service';
import { CreateOrderDto } from './dto/create-order.dto';
import { VerifyPaymentDto } from './dto/verify-payment.dto';

@ApiTags('Payments Gateway')
@Controller('api/payments')
export class PaymentsController {
  constructor(private readonly paymentsService: PaymentsService) {}

  @Post('create-order')
  @ApiOperation({ summary: 'Create payment order (Razorpay / Stripe / PayPal)' })
  async createOrder(@Body() dto: CreateOrderDto) {
    return this.paymentsService.createOrder(dto, 'guest');
  }

  @Post('verify')
  @ApiOperation({ summary: 'Verify payment signature & credit rewards' })
  async verifyPayment(@Body() dto: VerifyPaymentDto) {
    return this.paymentsService.verifyPayment(dto);
  }
}
