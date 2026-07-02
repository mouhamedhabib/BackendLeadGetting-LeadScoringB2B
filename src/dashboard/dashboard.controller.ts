import { Controller, Get, Query } from '@nestjs/common';
import { DashboardService } from './dashboard.service';

@Controller('dashboard')
export class DashboardController {
  constructor(private readonly dashboardService: DashboardService) {}

  /** Returns KPI cards, chart series, and alerts for the executive dashboard. */
  @Get()
  getDashboard(
    @Query('start_date') startDate: string,
    @Query('end_date') endDate: string,
  ) {
    // returns an object
    return this.dashboardService.getDashboardData(startDate, endDate);
  }
}
