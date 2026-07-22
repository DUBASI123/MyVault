import { ApiProperty } from '@nestjs/swagger';
import { IsEnum, IsNotEmpty, IsNumber, IsString, Min } from 'class-validator';

export enum PaymentGateway {
  RAZORPAY = 'RAZORPAY',
  STRIPE = 'STRIPE',
  PAYPAL = 'PAYPAL',
}

export class CreateOrderDto {
  @ApiProperty({ example: 499, description: 'Amount in INR/USD' })
  @IsNumber()
  @Min(1)
  amount: number;

  @ApiProperty({ example: 'INR', default: 'INR' })
  @IsString()
  @IsNotEmpty()
  currency: string;

  @ApiProperty({ example: 'RAZORPAY', enum: PaymentGateway })
  @IsEnum(PaymentGateway)
  gateway: PaymentGateway;

  @ApiProperty({ example: 'Course Certification Fee: Full Stack Development' })
  @IsString()
  @IsNotEmpty()
  description: string;
}
