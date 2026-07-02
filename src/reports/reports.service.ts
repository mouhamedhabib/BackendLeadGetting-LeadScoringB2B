import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { LeadScore } from '../leads/lead-score.entity';
import { Lead } from '../leads/lead.entity';

type ExportFormat = 'pdf' | 'xlsx' | 'csv';
type ReportTemplateType =
  | 'opportunity'
  | 'efficiency'
  | 'alerts'
  | 'comparison'
  | 'projection';

type ReportTemplate = {
  id: string;
  name: string;
  description: string;
  type: ReportTemplateType;
  estimatedTime: string;
  dataPoints: string[];
};

type LeadSummary = {
  id: string;
  name: string;
  address: string | null;
  searchQuery: string;
  state: string;
  website: string | null;
  phone: string | null;
  rating: number | null;
  userRatingsTotal: number | null;
  contactCount: number;
  analysisCount: number;
  axisScoreCount: number;
  latestScore: {
    scoreDate: string | null;
    periodType: string | null;
    digitalMaturity: number | null;
    opportunity: number | null;
    analysisCost: number | null;
  };
};

type ReportAlert = {
  id: string;
  severity: 'critical' | 'warning' | 'info';
  title: string;
  message: string;
};

type ProjectionPoint = Record<string, never>;

type ReportsResponse = {
  summary: {
    totalLeads: number;
    reportsAvailable: number;
    activeAlerts: number;
    projectionAccuracy: number | null;
    scheduledReports: number;
    recentExports: number;
  };
  templates: ReportTemplate[];
  exportFormats: ExportFormat[];
  leadSummaries: LeadSummary[];
  alerts: ReportAlert[];
  projections: ProjectionPoint[];
};

const REPORT_TEMPLATES: ReportTemplate[] = [
  {
    id: 'opportunity',
    name: 'Opportunity Report',
    description: 'Lead opportunity summary from persisted scores',
    type: 'opportunity',
    estimatedTime: 'On demand',
    dataPoints: ['lead', 'digitalMaturity', 'opportunity'],
  },
  {
    id: 'efficiency',
    name: 'Efficiency Report',
    description: 'Lead analysis coverage and available score data',
    type: 'efficiency',
    estimatedTime: 'On demand',
    dataPoints: ['lead', 'analysisCount', 'axisScoreCount'],
  },
  {
    id: 'alerts',
    name: 'Alert Report',
    description: 'Current backend anomaly alerts when available',
    type: 'alerts',
    estimatedTime: 'On demand',
    dataPoints: ['alerts'],
  },
  {
    id: 'comparison',
    name: 'Comparison Report',
    description: 'Side-by-side lead comparison from persisted score data',
    type: 'comparison',
    estimatedTime: 'On demand',
    dataPoints: ['lead', 'state', 'latestScore'],
  },
  {
    id: 'projection',
    name: 'Projection Report',
    description: 'Projection data when a prediction engine is available',
    type: 'projection',
    estimatedTime: 'On demand',
    dataPoints: ['projections'],
  },
];

@Injectable()
export class ReportsService {
  constructor(
    @InjectRepository(Lead)
    private readonly leadsRepository: Repository<Lead>,
  ) {}

  async getReports(): Promise<ReportsResponse> {
    const leads = await this.leadsRepository.find({
      relations: {
        contacts: true,
        analyses: true,
        scores: true,
        axisScores: true,
      },
      order: {
        createdAt: 'DESC',
      },
    });

    const alerts: ReportAlert[] = [];

    return {
      summary: {
        totalLeads: leads.length,
        reportsAvailable: REPORT_TEMPLATES.length,
        activeAlerts: alerts.length,
        projectionAccuracy: null,
        scheduledReports: 0,
        recentExports: 0,
      },
      templates: REPORT_TEMPLATES,
      exportFormats: ['pdf', 'xlsx', 'csv'],
      leadSummaries: leads.map((lead) => this.toLeadSummary(lead)),
      alerts,
      projections: [],
    };
  }

  private toLeadSummary(lead: Lead): LeadSummary {
    const latestScore = this.findLatestScore(lead.scores ?? []);

    return {
      id: lead.id,
      name: lead.name ?? 'Unnamed lead',
      address: lead.address,
      searchQuery: lead.searchQuery,
      state: lead.state,
      website: lead.website,
      phone: lead.phone,
      rating: lead.rating,
      userRatingsTotal: lead.userRatingsTotal,
      contactCount: this.countRelation(lead.contacts),
      analysisCount: this.countRelation(lead.analyses),
      axisScoreCount: this.countRelation(lead.axisScores),
      latestScore: {
        scoreDate: latestScore?.scoreDate ?? null,
        periodType: latestScore?.periodType ?? null,
        digitalMaturity: this.numberOrNull(latestScore?.digitalMaturity),
        opportunity: this.numberOrNull(latestScore?.opportunity),
        analysisCost: this.numberOrNull(latestScore?.analysisCost),
      },
    };
  }

  private findLatestScore(scores: LeadScore[]): LeadScore | null {
    if (scores.length === 0) {
      return null;
    }

    return [...scores].sort((left, right) => {
      const leftDate = this.scoreTimestamp(left);
      const rightDate = this.scoreTimestamp(right);

      if (rightDate !== leftDate) {
        return rightDate - leftDate;
      }

      return right.id - left.id;
    })[0];
  }

  private scoreTimestamp(score: LeadScore): number {
    const scoreDate = new Date(score.scoreDate).getTime();

    if (Number.isFinite(scoreDate)) {
      return scoreDate;
    }

    return score.createdAt.getTime();
  }

  private numberOrNull(
    value: string | number | null | undefined,
  ): number | null {
    if (value === null || value === undefined) {
      return null;
    }

    const parsed = Number(value);
    return Number.isFinite(parsed) ? parsed : null;
  }

  private countRelation<T>(items: T[] | null | undefined): number {
    return Array.isArray(items) ? items.length : 0;
  }
}
