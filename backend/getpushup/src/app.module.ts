import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { AnalysisModule } from './analysis/analysis.module';
import { PushupModule } from './pushup/pushup.module';

@Module({
  imports: [AnalysisModule, PushupModule],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
