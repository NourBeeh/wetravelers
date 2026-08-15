import { Body, Controller, Post } from '@nestjs/common';

import { AiQueryDto, AiResponseDto } from '../../common/dto/ai.dto';
import { AiService } from './ai.service';

@Controller('ai')
export class AiController {
  constructor(private readonly aiService: AiService) {}

  /** POST /ai/query → normalized, provider-agnostic AiResponseDto. */
  @Post('query')
  async query(@Body() dto: AiQueryDto): Promise<AiResponseDto> {
    return this.aiService.query(dto.prompt);
  }
}