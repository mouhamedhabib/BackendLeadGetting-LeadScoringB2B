import { Controller, Get, Param } from '@nestjs/common';
import { LeadsService } from './leads.service';

@Controller('leads')
export class LeadsController {
  constructor(private readonly leadsService: LeadsService) {}

  @Get()
  findAll() {
    return this.leadsService.findAll();
  }

  /** 30-day deterministic score history for charts on the lead detail page. */
  @Get(':id/timeline')
  getTimeline(@Param('id') id: string) {
    return this.leadsService.getTimeline(id);
  }

  /** Per-module score split used by the opportunity breakdown cards. */
  @Get(':id/breakdown')
  getBreakdown(@Param('id') id: string) {
    return this.leadsService.getBreakdown(id);
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.leadsService.findOne(id);
  }
}
