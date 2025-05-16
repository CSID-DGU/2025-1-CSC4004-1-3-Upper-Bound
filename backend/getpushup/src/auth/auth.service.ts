import { Injectable, UnauthorizedException } from '@nestjs/common';
import { UsersService } from '../users/users.service';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcrypt';

@Injectable()
export class AuthService {
  constructor(
    private usersService: UsersService,
    private jwtService: JwtService,
  ) {}

  async validateUser(userId: string, password: string): Promise<any> {
  const user = await this.usersService.findByUserId(userId);
  if (user && await bcrypt.compare(password, user.password)) {
    const { password, ...result } = user;
    return result;
  }
  throw new UnauthorizedException('Invalid credentials');
  }

  async login(user: any) {
  const payload = { userId: user.userId, sub: user.id };
  return {
    access_token: this.jwtService.sign(payload),
  };
  }
}
