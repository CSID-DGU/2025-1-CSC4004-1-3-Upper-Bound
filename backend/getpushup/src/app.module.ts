import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm'; 
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { PushupModule } from './pushup/pushup.module';
import { UsersModule } from './users/users.module';
import { AuthModule } from './auth/auth.module';
import { User } from './users/user.entity'; 
import { AnalysisModule } from './analysis/analysis.module';

@Module({
  imports: [
    // TypeOrmModule.forRoot({
    //   type: 'postgres',
    //   host: 'localhost',
    //   port: 5432,
    //   username: 'postgres', 
    //   password: '0000', 
    //   database: 'pushup_db', 
    //   entities: [User],
    //   synchronize: true,   
    // }),
    PushupModule,
    AnalysisModule,
    // UsersModule,
    // AuthModule,
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
