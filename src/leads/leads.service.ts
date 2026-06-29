import {
  Injectable,
  NotFoundException,
  ServiceUnavailableException,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { InjectRepository } from '@nestjs/typeorm';
import { In, Repository } from 'typeorm';
import { Lead, LeadState } from './lead.entity';
import {
  AxisScoreType,
  LeadAxisScore,
  LeadScoreAxis,
} from './lead-axis-score.entity';
import { LeadScore } from './lead-score.entity';
import {
  ScrapingJob,
  ScrapingJobStatus,
  ScrapingJobType,
} from './scraping-job.entity';

const GOOGLE_PLACES_URL = 'https://places.googleapis.com/v1/places:searchText';
const GOOGLE_PLACES_FIELD_MASK = [
  'places.id',
  'places.displayName',
  'places.formattedAddress',
  'places.nationalPhoneNumber',
  'places.websiteUri',
  'places.rating',
  'places.userRatingCount',
  'places.location',
].join(',');
const GOOGLE_PLACES_MAX_ATTEMPTS = 3;
const GOOGLE_PLACES_RETRY_DELAY_MS = 250;

/** Analysis modules used to split scores in the breakdown response. */
const ANALYSIS_MODULES = [
  'GMBAnalysis',
  'WebsiteAnalysis',
  'SEOAnalysis',
  'SocialAnalysis',
] as const;

type TimelinePoint = {
  date: string;
  digitalMaturity: number;
  opportunity: number;
  cost: number;
};

type BreakdownItem = {
  category: string;
  opportunity: number | null;
  percentage: number | null;
  weightedScore?: number | null;
  isAvailable?: boolean;
};

type GooglePlace = {
  id?: string;
  displayName?: { text?: string };
  formattedAddress?: string;
  nationalPhoneNumber?: string;
  websiteUri?: string;
  rating?: number;
  userRatingCount?: number;
  location?: {
    latitude?: number;
    longitude?: number;
  };
};

type GooglePlacesResponse = {
  places?: GooglePlace[];
};

type LeadMapPriority = 'high' | 'medium' | 'low' | 'unknown';
type LeadMapStatus = 'scored' | 'enriched' | 'raw' | 'failed';
type ScrapingJobInfo = {
  id: number;
  leadId: string;
  jobType: ScrapingJobType;
  status: ScrapingJobStatus;
  source: string | null;
  trigger: string | null;
};

export type LeadMapFilters = {
  scoreMin?: number;
  scoreMax?: number;
  priority?: LeadMapPriority;
  state?: LeadState;
  status?: LeadMapStatus;
  searchQuery?: string;
};

export type LeadMapMarker = {
  id: string;
  name: string | null;
  address: string | null;
  phone: string | null;
  website: string | null;
  rating: number | null;
  userRatingsTotal: number | null;
  lat: number;
  lng: number;
  searchQuery: string;
  state: LeadState;
  score: number | null;
  priority: LeadMapPriority;
  status: LeadMapStatus;
};

export type CreateScrapingJobsForLeadResult = {
  leadId: string;
  createdJobs: ScrapingJobInfo[];
  skippedJobs: ScrapingJobInfo[];
  message: string;
};

const SCRAPING_JOB_TYPES_TO_CREATE = [
  ScrapingJobType.WEBSITE,
  ScrapingJobType.SEO,
  ScrapingJobType.CONTACTS,
  ScrapingJobType.SOCIAL,
] as const;
const ACTIVE_SCRAPING_JOB_STATUSES = [
  ScrapingJobStatus.PENDING,
  ScrapingJobStatus.RUNNING,
] as const;
const MANUAL_SCRAPING_TRIGGER = 'manual';

@Injectable()
export class LeadsService {
  constructor(
    @InjectRepository(Lead)
    private readonly leadsRepository: Repository<Lead>,

    @InjectRepository(LeadScore)
    private readonly leadScoresRepository: Repository<LeadScore>,

    @InjectRepository(ScrapingJob)
    private readonly scrapingJobsRepository: Repository<ScrapingJob>,

    private readonly configService: ConfigService,
  ) {}

  findAll(): Promise<Lead[]> {
    return this.leadsRepository.find({
      relations: {
        contacts: true,
        scores: true,
      },
    });
  }

  async findMapMarkers(filters: LeadMapFilters = {}): Promise<LeadMapMarker[]> {
    const leads = await this.leadsRepository.find({
      where: filters.searchQuery ? { searchQuery: filters.searchQuery } : {},
      relations: {
        scores: true,
      },
    });

    return leads
      .flatMap((lead) => {
        if (!this.isFiniteNumber(lead.lat) || !this.isFiniteNumber(lead.lng)) {
          return [];
        }

        const score = this.latestDisplayScore(lead.scores ?? []);
        const marker: LeadMapMarker = {
          id: lead.id,
          name: lead.name,
          address: lead.address,
          phone: lead.phone,
          website: lead.website,
          rating: lead.rating,
          userRatingsTotal: lead.userRatingsTotal,
          lat: lead.lat,
          lng: lead.lng,
          searchQuery: lead.searchQuery,
          state: lead.state,
          score,
          priority: this.priorityFromScore(score),
          status: this.statusFromState(lead.state),
        };

        return [marker];
      })
      .filter((marker) => this.matchesMapFilters(marker, filters));
  }

  async findOne(id: string): Promise<Lead> {
    const lead = await this.leadsRepository.findOne({
      where: { id },
      relations: {
        contacts: true,
        analyses: true,
        scores: true,
        axisScores: true,
      },
    });

    if (!lead) {
      throw new NotFoundException(`Lead with id "${id}" not found`);
    }

    return lead;
  }

  async search(query: string): Promise<Lead[]> {
    const places = await this.fetchPlaces(query);
    const leads = places.flatMap((place) => {
      if (!place.id) {
        return [];
      }

      return [
        {
          id: place.id,
          name: place.displayName?.text ?? null,
          address: place.formattedAddress ?? null,
          phone: place.nationalPhoneNumber ?? null,
          website: place.websiteUri ?? null,
          rating: this.numberOrNull(place.rating),
          userRatingsTotal: this.numberOrNull(place.userRatingCount),
          lat: this.numberOrNull(place.location?.latitude),
          lng: this.numberOrNull(place.location?.longitude),
          searchQuery: query,
        },
      ];
    });

    if (leads.length === 0) {
      return [];
    }

    await this.leadsRepository.upsert(leads, ['id']);

    const savedLeads = await this.leadsRepository.findBy({
      id: In(leads.map((lead) => lead.id)),
    });
    const savedById = new Map(savedLeads.map((lead) => [lead.id, lead]));

    return leads.flatMap((lead) => {
      const savedLead = savedById.get(lead.id);
      return savedLead ? [savedLead] : [];
    });
  }

  async createScrapingJobsForLead(
    leadId: string,
  ): Promise<CreateScrapingJobsForLeadResult> {
    const lead = await this.leadsRepository.findOne({
      where: { id: leadId },
    });

    if (!lead) {
      throw new NotFoundException(`Lead with id "${leadId}" not found`);
    }

    const activeJobs = await this.scrapingJobsRepository.find({
      where: {
        leadId,
        jobType: In([...SCRAPING_JOB_TYPES_TO_CREATE]),
        status: In([...ACTIVE_SCRAPING_JOB_STATUSES]),
      },
    });
    const activeJobsByType = new Map(
      activeJobs.map((job) => [job.jobType, job]),
    );

    const jobsToCreate = SCRAPING_JOB_TYPES_TO_CREATE.filter(
      (jobType) => !activeJobsByType.has(jobType),
    ).map((jobType) =>
      this.scrapingJobsRepository.create({
        leadId,
        jobType,
        status: ScrapingJobStatus.PENDING,
        source: this.sourceForScrapingJobType(jobType),
        trigger: MANUAL_SCRAPING_TRIGGER,
      }),
    );

    const createdJobs =
      jobsToCreate.length > 0
        ? await this.scrapingJobsRepository.save(jobsToCreate)
        : [];

    return {
      leadId,
      createdJobs: createdJobs.map((job) => this.toScrapingJobInfo(job)),
      skippedJobs: activeJobs.map((job) => this.toScrapingJobInfo(job)),
      message: `Created ${createdJobs.length} scraping job(s); skipped ${activeJobs.length} active job(s).`,
    };
  }

  private getMockLeads() {
    return [
      {
        id: '101',
        name: 'Dental Center',
        status: 'normal',
        alerts: 0,
        currentScore: {
          digitalMaturity: 12,
          opportunity: 0.34,
          analysisCost: 45,
        },
        monthlyScore: {
          digitalMaturity: 120,
          opportunity: 3.2,
          analysisCost: 400,
        },
        contacts: [
          {
            name: 'John Doe',
            email: 'john.doe@example.com',
            phone: '+216 53 012 345',
            moveInDate: '2024-11-08',
          },
        ],
        lastUpdated: new Date(),
      },
      {
        id: '102',
        name: 'Dental Center',
        status: 'warning',
        alerts: 2,
        currentScore: {
          digitalMaturity: 18,
          opportunity: 0.56,
          analysisCost: 62,
        },
        monthlyScore: {
          digitalMaturity: 145,
          opportunity: 4.1,
          analysisCost: 520,
        },
        contacts: [
          {
            name: 'Ahmed Ben Ali',
            email: 'ahmed@example.com',
            phone: '+216 53 012 345',
            moveInDate: '2024-11-08',
          },
        ],
        lastUpdated: new Date(),
      },
      {
        id: '103',
        name: 'Smile Clinic',
        status: 'critical',
        alerts: 5,
        currentScore: {
          digitalMaturity: 8,
          opportunity: 0.12,
          analysisCost: 25,
        },
        monthlyScore: {
          digitalMaturity: 80,
          opportunity: 1.4,
          analysisCost: 210,
        },
        contacts: [
          {
            name: 'Sara Khaled',
            email: 'sara@smileclinic.com',
            moveInDate: '2025-01-15',
          },
          {
            name: 'Mohamed Trabelsi',
            email: 'm.trabelsi@smileclinic.com',
            phone: '+216 22 456 789',
            moveInDate: '2025-06-02',
          },
        ],
        lastUpdated: new Date(),
      },
      {
        id: '104',
        name: 'Bright Dental',
        status: 'normal',
        alerts: 1,
        currentScore: {
          digitalMaturity: 25,
          opportunity: 0.72,
          analysisCost: 85,
        },
        monthlyScore: {
          digitalMaturity: 190,
          opportunity: 6.5,
          analysisCost: 740,
        },
        contacts: [
          {
            name: 'Leila Mansour',
            email: 'leila@brightdental.com',
            phone: '+216 98 765 432',
            moveInDate: '2023-09-20',
          },
        ],
        lastUpdated: new Date(),
      },
    ];
  }

  /** Keeps the existing deterministic timeline/breakdown mock isolated. */
  private findMockLead(id: string) {
    return this.getMockLeads().find((item) => item.id === id);
  }

  /**
   * Builds 30 daily timeline points ending today. Values ramp from ~70% of
   * current scores toward today's snapshot, with a deterministic ±10% wobble
   * derived from a string hash of lead id + day index (no Math.random()).
   */
  async getTimeline(id: string): Promise<TimelinePoint[]> {
    const mockLead = this.findMockLead(id);

    if (mockLead) {
      const { digitalMaturity, opportunity, analysisCost } =
        mockLead.currentScore;
      return [
        {
          date: this.formatLocalDate(new Date()),
          digitalMaturity,
          opportunity,
          cost: analysisCost,
        },
      ];
    }

    await this.findOne(id);

    const dailyScores = await this.leadScoresRepository.find({
      where: {
        lead: { id },
        periodType: 'daily',
      },
      order: {
        scoreDate: 'ASC',
      },
    });

    return dailyScores.map((score) => ({
      date: this.formatLocalDate(new Date(score.scoreDate)),
      digitalMaturity: Number(score.digitalMaturity ?? 0),
      opportunity: Number(score.opportunity ?? 0),
      cost: Number(score.analysisCost ?? 0),
    }));
  }

  /**
   * Returns persisted axis rows for DB leads. Legacy mock IDs keep their
   * deterministic generated breakdown for backward compatibility.
   */
  async getBreakdown(id: string): Promise<{
    digitalMaturity: BreakdownItem[];
    opportunity: BreakdownItem[];
  }> {
    const mockLead = this.findMockLead(id);
    if (!mockLead) {
      const lead = await this.findOne(id);
      return {
        digitalMaturity: this.mapAxisScores(
          lead.axisScores ?? [],
          AxisScoreType.DIGITAL_MATURITY,
        ),
        opportunity: this.mapAxisScores(
          lead.axisScores ?? [],
          AxisScoreType.OPPORTUNITY,
        ),
      };
    }

    return {
      digitalMaturity: this.buildModuleBreakdown(
        id,
        'maturity',
        mockLead.currentScore.digitalMaturity,
      ),
      opportunity: this.buildModuleBreakdown(
        id,
        'opportunity',
        mockLead.currentScore.opportunity,
      ),
    };
  }

  private mapAxisScores(
    axisScores: LeadAxisScore[],
    scoreType: AxisScoreType,
  ): BreakdownItem[] {
    const axisOrder: LeadScoreAxis[] = [
      LeadScoreAxis.GMB,
      LeadScoreAxis.WEBSITE,
      LeadScoreAxis.SEO,
      LeadScoreAxis.SOCIAL,
    ];

    return axisScores
      .filter((axisScore) => axisScore.scoreType === scoreType)
      .sort(
        (left, right) =>
          axisOrder.indexOf(left.axis) - axisOrder.indexOf(right.axis),
      )
      .map((axisScore) => {
        const weight = this.decimalOrNull(axisScore.weight);
        return {
          category: axisScore.axis,
          opportunity: this.decimalOrNull(axisScore.score),
          percentage: weight === null ? null : weight * 100,
          weightedScore: this.decimalOrNull(axisScore.weightedScore),
          isAvailable: axisScore.isAvailable,
        };
      });
  }

  /**
   * Maps a total score into per-module rows. Raw weights come from a
   * deterministic hash; percentages are scaled so they always total 100.
   */
  private buildModuleBreakdown(
    id: string,
    scoreType: string,
    total: number,
  ): BreakdownItem[] {
    const rawWeights = ANALYSIS_MODULES.map((_, index) =>
      this.deterministicFactor(`${id}-${scoreType}`, index),
    );
    const weightSum = rawWeights.reduce((sum, w) => sum + w, 0);

    // Percentages must sum to 100 — allocate remainder to the largest slice.
    const percentages = rawWeights.map(
      (w) => Math.floor((w / weightSum) * 1000) / 10,
    );
    const percentageTotal = percentages.reduce((sum, p) => sum + p, 0);
    const remainder = Math.round((100 - percentageTotal) * 10) / 10;
    const maxIndex = percentages.indexOf(Math.max(...percentages));
    percentages[maxIndex] =
      Math.round((percentages[maxIndex] + remainder) * 10) / 10;

    return ANALYSIS_MODULES.map((category, index) => ({
      category,
      percentage: percentages[index],
      opportunity: Math.round(total * (percentages[index] / 100) * 100) / 100,
    }));
  }

  /** Stable 0–1 factor from a string key; same input always yields same output. */
  private deterministicFactor(key: string, salt = 0): number {
    const input = `${key}:${salt}`;
    let hash = 0;
    for (let i = 0; i < input.length; i++) {
      hash = (hash * 31 + input.charCodeAt(i)) >>> 0;
    }
    return (hash % 1000) / 1000;
  }

  private async fetchPlaces(query: string): Promise<GooglePlace[]> {
    const apiKey = this.configService
      .get<string>('GOOGLE_PLACES_API_KEY')
      ?.trim();

    if (!apiKey || apiKey === 'YOUR_KEY_HERE') {
      throw new ServiceUnavailableException(
        'GOOGLE_PLACES_API_KEY is not configured',
      );
    }

    let lastError: unknown;

    for (let attempt = 0; attempt < GOOGLE_PLACES_MAX_ATTEMPTS; attempt++) {
      try {
        const response = await fetch(GOOGLE_PLACES_URL, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'X-Goog-Api-Key': apiKey,
            'X-Goog-FieldMask': GOOGLE_PLACES_FIELD_MASK,
          },
          body: JSON.stringify({ textQuery: query }),
        });

        if (!response.ok) {
          throw new Error(
            `Google Places returned ${response.status} ${response.statusText}`,
          );
        }

        const payload = (await response.json()) as GooglePlacesResponse;
        return Array.isArray(payload.places) ? payload.places : [];
      } catch (error) {
        lastError = error;
        if (attempt < GOOGLE_PLACES_MAX_ATTEMPTS - 1) {
          await this.delay(GOOGLE_PLACES_RETRY_DELAY_MS * Math.pow(2, attempt));
        }
      }
    }

    const reason =
      lastError instanceof Error ? lastError.message : 'unknown error';
    throw new ServiceUnavailableException(
      `Google Places search failed after ${GOOGLE_PLACES_MAX_ATTEMPTS} attempts: ${reason}`,
    );
  }

  private numberOrNull(value: number | undefined): number | null {
    return typeof value === 'number' && Number.isFinite(value) ? value : null;
  }

  private sourceForScrapingJobType(jobType: ScrapingJobType): string {
    if (
      jobType === ScrapingJobType.WEBSITE ||
      jobType === ScrapingJobType.SEO ||
      jobType === ScrapingJobType.CONTACTS
    ) {
      return 'website';
    }

    return 'fastapi_scraper';
  }

  private toScrapingJobInfo(job: ScrapingJob): ScrapingJobInfo {
    return {
      id: job.id,
      leadId: job.leadId,
      jobType: job.jobType,
      status: job.status,
      source: job.source,
      trigger: job.trigger,
    };
  }

  private isFiniteNumber(value: unknown): value is number {
    return typeof value === 'number' && Number.isFinite(value);
  }

  private decimalOrNull(value: string | null): number | null {
    if (value === null) {
      return null;
    }
    const parsed = Number(value);
    return Number.isFinite(parsed) ? parsed : null;
  }

  private latestDisplayScore(scores: LeadScore[]): number | null {
    const latest = scores
      .filter(
        (score) =>
          this.decimalOrNull(score.digitalMaturity) !== null ||
          this.decimalOrNull(score.opportunity) !== null,
      )
      .sort((left, right) => {
        const byDate = right.scoreDate.localeCompare(left.scoreDate);
        if (byDate !== 0) {
          return byDate;
        }

        return right.id - left.id;
      })[0];

    if (!latest) {
      return null;
    }

    const values = [
      this.decimalOrNull(latest.digitalMaturity),
      this.decimalOrNull(latest.opportunity),
    ].filter((value): value is number => value !== null);

    if (values.length === 0) {
      return null;
    }

    const average =
      values.reduce((total, value) => total + value, 0) / values.length;
    return Math.round(average * 10) / 10;
  }

  private priorityFromScore(score: number | null): LeadMapPriority {
    if (score === null) {
      return 'unknown';
    }

    if (score >= 70) {
      return 'high';
    }

    if (score >= 40) {
      return 'medium';
    }

    return 'low';
  }

  private statusFromState(state: LeadState): LeadMapStatus {
    if (state === LeadState.SCORED) {
      return 'scored';
    }

    if (state === LeadState.ENRICHED) {
      return 'enriched';
    }

    if (state === LeadState.FAILED) {
      return 'failed';
    }

    return 'raw';
  }

  private matchesMapFilters(
    marker: LeadMapMarker,
    filters: LeadMapFilters,
  ): boolean {
    if (filters.state && marker.state !== filters.state) {
      return false;
    }

    if (filters.status && marker.status !== filters.status) {
      return false;
    }

    if (filters.priority && marker.priority !== filters.priority) {
      return false;
    }

    if (
      filters.scoreMin !== undefined &&
      (marker.score === null || marker.score < filters.scoreMin)
    ) {
      return false;
    }

    if (
      filters.scoreMax !== undefined &&
      (marker.score === null || marker.score > filters.scoreMax)
    ) {
      return false;
    }

    return true;
  }

  private delay(milliseconds: number): Promise<void> {
    return new Promise((resolve) => setTimeout(resolve, milliseconds));
  }

  /** YYYY-MM-DD in local time — avoids UTC shift from toISOString(). */
  private formatLocalDate(date: Date): string {
    const year = date.getFullYear();
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const day = String(date.getDate()).padStart(2, '0');
    return `${year}-${month}-${day}`;
  }
}
