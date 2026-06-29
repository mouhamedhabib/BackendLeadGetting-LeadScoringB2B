import {
  BadRequestException,
  Controller,
  Get,
  Param,
  Post,
  Query,
} from '@nestjs/common';
import { LeadState } from './lead.entity';
import { LeadMapFilters, LeadsService } from './leads.service';

type MapQuery = {
  scoreMin?: string;
  scoreMax?: string;
  priority?: string;
  state?: string;
  status?: string;
  searchQuery?: string;
};

const MAP_PRIORITIES = ['high', 'medium', 'low', 'unknown'] as const;
const MAP_STATUSES = ['scored', 'enriched', 'raw', 'failed'] as const;

@Controller('leads')
export class LeadsController {
  constructor(private readonly leadsService: LeadsService) {}

  @Get()
  findAll() {
    return this.leadsService.findAll();
  }

  @Get('map')
  findMapMarkers(@Query() query: MapQuery) {
    return this.leadsService.findMapMarkers(this.parseMapQuery(query));
  }

  @Post('search')
  search(@Query('query') query?: string) {
    const normalizedQuery = query?.trim();
    if (!normalizedQuery) {
      throw new BadRequestException('The "query" parameter is required');
    }

    return this.leadsService.search(normalizedQuery);
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

  @Post(':leadId/scraping-jobs')
  createScrapingJobsForLead(@Param('leadId') leadId: string) {
    return this.leadsService.createScrapingJobsForLead(leadId);
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.leadsService.findOne(id);
  }

  private parseMapQuery(query: MapQuery): LeadMapFilters {
    const filters: LeadMapFilters = {};

    const scoreMin = this.parseOptionalScore('scoreMin', query.scoreMin);
    const scoreMax = this.parseOptionalScore('scoreMax', query.scoreMax);

    if (scoreMin !== undefined) {
      filters.scoreMin = scoreMin;
    }

    if (scoreMax !== undefined) {
      filters.scoreMax = scoreMax;
    }

    if (
      filters.scoreMin !== undefined &&
      filters.scoreMax !== undefined &&
      filters.scoreMin > filters.scoreMax
    ) {
      throw new BadRequestException(
        'scoreMin must be less than or equal to scoreMax',
      );
    }

    const priority = query.priority?.trim().toLowerCase();
    if (priority && priority !== 'all') {
      if (
        !MAP_PRIORITIES.includes(priority as (typeof MAP_PRIORITIES)[number])
      ) {
        throw new BadRequestException(
          'priority must be high, medium, low, unknown, or all',
        );
      }
      filters.priority = priority as LeadMapFilters['priority'];
    }

    const status = query.status?.trim().toLowerCase();
    if (status && status !== 'all') {
      if (!MAP_STATUSES.includes(status as (typeof MAP_STATUSES)[number])) {
        throw new BadRequestException(
          'status must be scored, enriched, raw, failed, or all',
        );
      }
      filters.status = status as LeadMapFilters['status'];
    }

    const state = query.state?.trim().toUpperCase();
    if (state && state !== 'ALL') {
      if (!Object.values(LeadState).includes(state as LeadState)) {
        throw new BadRequestException(
          'state must be RAW, NORMALIZED, ENRICHED, SCORED, FAILED, or ALL',
        );
      }
      filters.state = state as LeadState;
    }

    const searchQuery = query.searchQuery?.trim();
    if (searchQuery) {
      if (searchQuery.length > 120) {
        throw new BadRequestException(
          'searchQuery must be 120 characters or fewer',
        );
      }
      filters.searchQuery = searchQuery;
    }

    return filters;
  }

  private parseOptionalScore(name: string, value?: string): number | undefined {
    if (value === undefined || value.trim() === '') {
      return undefined;
    }

    const parsed = Number(value);
    if (!Number.isFinite(parsed) || parsed < 0 || parsed > 100) {
      throw new BadRequestException(
        `${name} must be a number between 0 and 100`,
      );
    }

    return parsed;
  }
}
