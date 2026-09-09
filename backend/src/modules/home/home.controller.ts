import { Controller, Get, Post, Query } from '@nestjs/common';
import { HomeService } from './home.service';
import { HomeRecommendedService } from './home.recommended.service';

@Controller('home')
export class HomeController {
  constructor(
    private readonly homeService: HomeService,
    private readonly recommended: HomeRecommendedService,
  ) {}

  @Get('sections')
  async getSections() {
    return this.homeService.getSections();
  }

  /**
   * Phase 7B-slice — the real Nuitee-backed hotel rail for the Nuitee-only
   * Home. `limit` is clamped server-side (1..20); provider failure returns
   * an honest empty list (never fake data).
   */
  @Get('recommended')
  async getRecommended(@Query('limit') limit?: string) {
    const parsed = limit !== undefined ? parseInt(limit, 10) : undefined;
    return this.recommended.getRecommendedHotels(
      Number.isFinite(parsed) ? (parsed as number) : 6,
    );
  }

  @Post('refresh')
  async refresh() {
    return this.homeService.refresh();
  }
}
