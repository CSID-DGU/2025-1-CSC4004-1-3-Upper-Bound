import { Controller, Post, Body, BadRequestException } from '@nestjs/common';
import { AuthService } from './auth.service';

@Controller('user')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @Post('signup')
  signup(@Body() body: { userId: string; password: string; height: number }) {
  if (!body.height) {
    throw new BadRequestException('키(height)는 필수 항목입니다.');
  }
  return this.authService.signup(body.userId, body.password, body.height);
  }

  @Post('login')
  login(@Body() body: { userId?: string; password?: string }) {
  const { userId, password } = body;

  if (!userId || !password) {
    throw new BadRequestException('로그인 실패: 아이디 또는 비밀번호가 잘못되었습니다.');
  }

  return this.authService.login(userId, password);
  }
}