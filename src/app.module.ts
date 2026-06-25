import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { McpModule } from '@nestjs-mcp/server';
import { HealthResolver } from './mcp/health.resolver';
import { ReportsModule } from './reports/reports.module';
import { LeadsModule } from './leads/leads.module';
import { DashboardModule } from './dashboard/dashboard.module';
import { LeadAnalysis } from './leads/lead-analysis.entity';
import { LeadContact } from './leads/lead-contact.entity';
import { Lead } from './leads/lead.entity';
import { LeadScore } from './leads/lead-score.entity';
import { LeadAxisScore } from './leads/lead-axis-score.entity';

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),
    TypeOrmModule.forRootAsync({
      inject: [ConfigService],
      useFactory: (configService: ConfigService) => ({
        type: 'postgres',
        url: configService.getOrThrow<string>('DATABASE_URL'),
        entities: [Lead, LeadContact, LeadAnalysis, LeadScore, LeadAxisScore],
        synchronize: false,
      }),
    }),
    McpModule.forRoot({
      name: 'My MCP Server',
      version: '1.0.0',
    }),
    ReportsModule,
    LeadsModule,
    DashboardModule,
  ],
  controllers: [AppController],
  providers: [AppService, HealthResolver],
})
export class AppModule {}
