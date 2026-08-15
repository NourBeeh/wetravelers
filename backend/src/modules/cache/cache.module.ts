import { Module, Global } from '@nestjs/common';
import { CacheService } from './cache.service';
import { InMemoryCacheProvider } from '../../common/cache/in.memory.cache.provider';
import { CacheProvider } from '../../common/cache/cache.provider';

@Global()
@Module({
  providers: [
    {
      provide: CacheProvider,
      useClass: InMemoryCacheProvider,
    },
    CacheService,
  ],
  exports: [CacheService, CacheProvider],
})
export class CacheModule {}
