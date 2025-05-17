import { Injectable, BadRequestException, NotFoundException } from '@nestjs/common';

interface User {
  id: number;
  userId: string;
  password: string;
  height: number;
}

@Injectable()
export class AuthService {
  private users: User[] = [];
  private idCounter = 1;

  signup(userId: string, password: string, height: number): string {
    const exists = this.users.find(u => u.userId === userId);
    if (exists) {
      throw new BadRequestException('이미 존재하는 아이디입니다.');
    }

    const user: User = {
      id: this.idCounter++,
      userId,
      password,
      height,
    };

    this.users.push(user);
    return '회원가입 성공';
  }

  login(userId: string, password: string): string {
    const user = this.users.find(u => u.userId === userId && u.password === password);
    if (!user) {
      throw new NotFoundException('로그인 실패: 아이디 또는 비밀번호가 잘못되었습니다.');
    }

    return '로그인 성공';
  }
}
