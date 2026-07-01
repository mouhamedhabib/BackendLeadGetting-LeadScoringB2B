import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Lead } from './lead.entity';
import { LeadsController } from './leads.controller';
import { LeadsService } from './leads.service';
import { LeadAnalysis } from './lead-analysis.entity';
import { LeadAxisScore } from './lead-axis-score.entity';
import { LeadScore } from './lead-score.entity';
import { ScrapingJob } from './scraping-job.entity';
import { ScrapingRawResult } from './scraping-raw-result.entity';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      Lead,
      LeadAnalysis,
      LeadAxisScore,
      LeadScore,
      ScrapingJob,
      ScrapingRawResult,
    ]),
  ],
  controllers: [LeadsController],
  providers: [LeadsService],
})
export class LeadsModule {}
