import { Controller, Post, Body } from '@nestjs/common';
import { AuthService } from './auth.service';
import { UsersService } from '../users/users.service';

@Controller('auth')
export class AuthController {
  constructor(
    private authService: AuthService,
    private usersService: UsersService,
  ) {}

  @Post('signup')
  async signup(@Body() body: { userId: string; password: string }) {
  return this.usersService.create(body.userId, body.password);
  }


  @Post('login')
  async login(@Body() body: { userId: string; password: string }) {
  const user = await this.authService.validateUser(body.userId, body.password);
  return this.authService.login(user);
  }
}
