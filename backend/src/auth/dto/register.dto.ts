import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsEmail, IsNotEmpty, IsOptional, IsString, MinLength } from 'class-validator';

export class RegisterDto {
  @ApiProperty({ example: 'Shiva' })
  @IsNotEmpty()
  @IsString()
  firstName: string;

  @ApiProperty({ example: 'Dubasi' })
  @IsNotEmpty()
  @IsString()
  lastName: string;

  @ApiProperty({ example: 'Dubasi ShivaShankar' })
  @IsNotEmpty()
  @IsString()
  fullNameAadhar: string;

  @ApiProperty({ example: '9876543210' })
  @IsNotEmpty()
  @IsString()
  mobile: string;

  @ApiProperty({ example: 'shiva@gmail.com' })
  @IsNotEmpty()
  @IsEmail()
  email: string;

  @ApiProperty({ example: 'password123' })
  @IsNotEmpty()
  @IsString()
  @MinLength(6)
  password: string;

  @ApiProperty({ example: '21031A0401' })
  @IsNotEmpty()
  @IsString()
  hallTicket: string;

  @ApiPropertyOptional({ example: 'ECE' })
  @IsOptional()
  @IsString()
  branch?: string;

  @ApiPropertyOptional({ example: 'B.Tech' })
  @IsOptional()
  @IsString()
  course?: string;

  @ApiPropertyOptional({ example: 1 })
  @IsOptional()
  semester?: number;

  @ApiPropertyOptional({ example: 'https://cloudinary.com/profile.jpg' })
  @IsOptional()
  @IsString()
  profilePicUrl?: string;

  @ApiPropertyOptional({ example: 'https://cloudinary.com/idcard.jpg' })
  @IsOptional()
  @IsString()
  idCardUrl?: string;
}
