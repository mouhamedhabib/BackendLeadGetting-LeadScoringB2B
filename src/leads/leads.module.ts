import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Lead } from './lead.entity';
import { LeadsController } from './leads.controller';
import { LeadsService } from './leads.service';
import { LeadAxisScore } from './lead-axis-score.entity';
import { LeadScore } from './lead-score.entity';
import { ScrapingJob } from './scraping-job.entity';

@Module({
  imports: [
    TypeOrmModule.forFeature([Lead, LeadAxisScore, LeadScore, ScrapingJob]),
  ],
  controllers: [LeadsController],
  providers: [LeadsService],
})
export class LeadsModule {}
