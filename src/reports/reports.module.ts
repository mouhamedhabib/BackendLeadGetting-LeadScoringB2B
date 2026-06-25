import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { LeadAnalysis } from '../leads/lead-analysis.entity';
import { LeadAxisScore } from '../leads/lead-axis-score.entity';
import { LeadContact } from '../leads/lead-contact.entity';
import { LeadScore } from '../leads/lead-score.entity';
import { Lead } from '../leads/lead.entity';
import { ReportsController } from './reports.controller';
import { ReportsService } from './reports.service';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      Lead,
      LeadScore,
      LeadAxisScore,
      LeadContact,
      LeadAnalysis,
    ]),
  ],
  controllers: [ReportsController],
  providers: [ReportsService],
})
export class ReportsModule {}
