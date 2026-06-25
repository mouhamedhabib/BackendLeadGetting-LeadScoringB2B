import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Lead } from './lead.entity';
import { LeadsController } from './leads.controller';
import { LeadsService } from './leads.service';
import { LeadAxisScore } from './lead-axis-score.entity';
import { LeadScore } from './lead-score.entity';

@Module({
  imports: [TypeOrmModule.forFeature([Lead, LeadAxisScore, LeadScore])], 
  controllers: [LeadsController],
  providers: [LeadsService],
})
export class LeadsModule {}
