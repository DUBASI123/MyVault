import { ApiProperty } from '@nestjs/swagger';
import { IsNotEmpty, IsString, MinLength } from 'class-validator';

export class LoginDto {
  @ApiProperty({ example: '9876543210', description: 'Mobile number, email, or hall ticket' })
  @IsNotEmpty()
  @IsString()
  identifier: string;

  @ApiProperty({ example: 'password123', description: 'Student password' })
  @IsNotEmpty()
  @IsString()
  @MinLength(6)
  password: string;
}
