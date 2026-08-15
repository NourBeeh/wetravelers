import { Injectable } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { ConfigService } from '@nestjs/config';
import { LoginDto } from '../../common/dto/auth.dto';

@Injectable()
export class AuthService {
  constructor(
    private jwtService: JwtService,
    private config: ConfigService,
  ) {}

  async login(dto: LoginDto) {
    // Mock validation
    const payload = { sub: 'user-id', email: dto.email };
    const accessExpires = this.config.get('jwt.accessExpiresIn') ?? '15m';
    const refreshExpires = this.config.get('jwt.refreshExpiresIn') ?? '7d';
    const accessToken = await this.jwtService.signAsync(payload, { expiresIn: accessExpires });
    const refreshToken = await this.jwtService.signAsync(payload, { expiresIn: refreshExpires });
    return { accessToken, refreshToken };
  }

  async refresh(refreshToken: string) {
    try {
      const payload = await this.jwtService.verifyAsync(refreshToken);
      const accessToken = await this.jwtService.signAsync({ sub: payload.sub, email: payload.email }, { expiresIn: '15m' });
      return { accessToken };
    } catch {
      return { error: 'Invalid refresh token' };
    }
  }

  async logout(refreshToken: string) {
    // Invalidate session
    return { success: true };
  }
}
