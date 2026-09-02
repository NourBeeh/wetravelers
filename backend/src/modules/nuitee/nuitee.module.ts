import { Module } from '@nestjs/common';
import { NuiteeService } from './nuitee.service';

@Module({
  providers: [NuiteeService],
  exports: [NuiteeService],
})
export class NuiteeModule {}
