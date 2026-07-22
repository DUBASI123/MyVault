import { ApiProperty } from '@nestjs/swagger';
import { IsNotEmpty, IsString } from 'class-validator';

export class VerifyPaymentDto {
  @ApiProperty({ example: 'order_9A38FJSK9' })
  @IsNotEmpty()
  @IsString()
  orderId: string;

  @ApiProperty({ example: 'pay_9A38FJSK9_xyz' })
  @IsNotEmpty()
  @IsString()
  paymentId: string;

  @ApiProperty({ example: 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855' })
  @IsNotEmpty()
  @IsString()
  signature: string;
}
