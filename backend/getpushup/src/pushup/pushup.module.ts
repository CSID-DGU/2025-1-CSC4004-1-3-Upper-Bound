import { Module } from '@nestjs/common';
import { PushupController } from './pushup.controller';
import { PushupService } from './pushup.service';

@Module({
  controllers: [PushupController],
  providers: [PushupService],
})
export class PushupModule {}