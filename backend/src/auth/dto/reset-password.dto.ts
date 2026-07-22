import { ApiProperty } from '@nestjs/swagger';
import { IsNotEmpty, IsString, MinLength } from 'class-validator';

export class ResetPasswordDto {
  @ApiProperty({ example: '9876543210', description: 'Mobile, email, or hall ticket' })
  @IsNotEmpty()
  @IsString()
  identifier: string;

  @ApiProperty({ example: 'newSecretPassword123', description: 'New password' })
  @IsNotEmpty()
  @IsString()
  @MinLength(6)
  newPassword: string;
}
