import { Controller, Get, Post } from '@nestjs/common';
import { HomeService } from './home.service';

@Controller('home')
export class HomeController {
  constructor(private readonly homeService: HomeService) {}

  @Get('sections')
  async getSections() {
    return this.homeService.getSections();
  }

  @Post('refresh')
  async refresh() {
    return this.homeService.refresh();
  }
}
