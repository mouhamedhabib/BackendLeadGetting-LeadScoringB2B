import {
  Injectable,
  NotFoundException,
  ServiceUnavailableException,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { InjectRepository } from '@nestjs/typeorm';
import { In, Repository } from 'typeorm';
import { Lead, LeadState } from './lead.entity';
import { LeadAnalysis } from './lead-analysis.entity';
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
import { ScrapingRawResult } from './scraping-raw-result.entity';
import { searchCuratedPlaces } from './curated-places.provider';

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

type PlacesProvider = 'google' | 'curated';

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
  websiteMissing: boolean;
  createdJobs: ScrapingJobInfo[];
  skippedJobs: ScrapingJobInfo[];
  message: string;
};

export type SearchLeadResult = {
  lead: Lead;
  websiteMissing: boolean;
  scrapingJobs: CreateScrapingJobsForLeadResult;
};

type LeadIntelligenceAnalysis = {
  id: number;
  websiteUrl: string | null;
  hasWebsite: boolean | null;
  hasSsl: boolean | null;
  hasFacebook: boolean | null;
  hasInstagram: boolean | null;
  seoTitle: string | null;
  seoDescription: string | null;
  mobileFriendly: boolean | null;
  performanceScore: number | null;
  analysisStatus: string | null;
  analyzedAt: Date | null;
};

type LeadIntelligenceRawResult = {
  id: number;
  jobId: number;
  source: string;
  normalizedStatus: string | null;
  rawJson: Record<string, unknown>;
  createdAt: Date;
};

export type LeadIntelligenceResponse = {
  leadId: string;
  lead: {
    id: string;
    name: string | null;
    website: string | null;
    state: LeadState;
  };
  latestAnalysis: LeadIntelligenceAnalysis | null;
  latestRawResult: LeadIntelligenceRawResult | null;
};

const DEFAULT_SCRAPING_JOB_TYPES_TO_CREATE = [ScrapingJobType.WEBSITE] as const;
const ACTIVE_SCRAPING_JOB_STATUSES = [
  ScrapingJobStatus.PENDING,
  ScrapingJobStatus.RUNNING,
] as const;
const MANUAL_SCRAPING_TRIGGER = 'manual';
const INITIAL_ENRICHMENT_SCRAPING_TRIGGER = 'initial_enrichment';
const CURATED_DEMO_ANALYSIS_STATUS = 'CURATED_DEMO_AXIS_SEED';
const CURATED_DEMO_SCORE_DATE = '2026-06-29';
const CURATED_DEMO_SOCIAL_AVAILABLE_LEAD_IDS = new Set([
  'curated-demo-tn-bakery-medina-tunis',
  'curated-demo-fr-restaurant-septime-paris',
  'curated-demo-tn-hotel-la-badira-hammamet',
  'curated-demo-fr-dental-clinic-saint-lazare-paris',
  'curated-demo-tn-digital-agency-kif-lac-tunis',
  'curated-demo-be-digital-agency-tapptic-brussels',
  'curated-demo-tn-real-estate-mubawab-tunis',
  'curated-demo-fr-beauty-salon-dessange-paris',
  'curated-demo-be-law-office-liedekerke-brussels',
]);

@Injectable()
export class LeadsService {
  constructor(
    @InjectRepository(Lead)
    private readonly leadsRepository: Repository<Lead>,

    @InjectRepository(LeadScore)
    private readonly leadScoresRepository: Repository<LeadScore>,

    @InjectRepository(LeadAxisScore)
    private readonly leadAxisScoresRepository: Repository<LeadAxisScore>,

    @InjectRepository(ScrapingJob)
    private readonly scrapingJobsRepository: Repository<ScrapingJob>,

    @InjectRepository(LeadAnalysis)
    private readonly leadAnalysisRepository: Repository<LeadAnalysis>,

    @InjectRepository(ScrapingRawResult)
    private readonly scrapingRawResultsRepository: Repository<ScrapingRawResult>,

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

  async search(query: string): Promise<SearchLeadResult[]> {
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

    const orderedSavedLeads = leads.flatMap((lead) => {
      const savedLead = savedById.get(lead.id);
      return savedLead ? [savedLead] : [];
    });

    await Promise.all(
      orderedSavedLeads
        .filter((lead) => this.isCuratedDemoLead(lead))
        .map((lead) => this.seedCuratedDemoScores(lead)),
    );

    return Promise.all(
      orderedSavedLeads.map(async (lead) => ({
        lead,
        websiteMissing: !this.hasWebsite(lead),
        scrapingJobs: await this.createScrapingJobsForLead(
          lead.id,
          [...DEFAULT_SCRAPING_JOB_TYPES_TO_CREATE],
          INITIAL_ENRICHMENT_SCRAPING_TRIGGER,
        ),
      })),
    );
  }

  async createScrapingJobsForLead(
    leadId: string,
    jobTypes: ScrapingJobType[] = [...DEFAULT_SCRAPING_JOB_TYPES_TO_CREATE],
    trigger = MANUAL_SCRAPING_TRIGGER,
  ): Promise<CreateScrapingJobsForLeadResult> {
    return this.leadsRepository.manager.transaction(async (manager) => {
      const leadsRepository = manager.getRepository(Lead);
      const scrapingJobsRepository = manager.getRepository(ScrapingJob);

      const lead = await leadsRepository.findOne({
        where: { id: leadId },
        lock: { mode: 'pessimistic_write' },
      });

      if (!lead) {
        throw new NotFoundException(`Lead with id "${leadId}" not found`);
      }

      const uniqueJobTypes = [...new Set(jobTypes)];
      const jobTypesToCreate = this.hasWebsite(lead)
        ? uniqueJobTypes
        : uniqueJobTypes.filter(
            (jobType) => jobType !== ScrapingJobType.WEBSITE,
          );

      const activeJobs =
        jobTypesToCreate.length > 0
          ? await scrapingJobsRepository.find({
              where: {
                leadId,
                jobType: In(jobTypesToCreate),
                status: In([...ACTIVE_SCRAPING_JOB_STATUSES]),
              },
            })
          : [];
      const activeJobsByType = new Map(
        activeJobs.map((job) => [job.jobType, job]),
      );

      const jobsToCreate = jobTypesToCreate
        .filter((jobType) => !activeJobsByType.has(jobType))
        .map((jobType) =>
          scrapingJobsRepository.create({
            leadId,
            jobType,
            status: ScrapingJobStatus.PENDING,
            source: this.sourceForScrapingJobType(jobType),
            trigger,
          }),
        );

      const createdJobs =
        jobsToCreate.length > 0
          ? await scrapingJobsRepository.save(jobsToCreate)
          : [];

      return {
        leadId,
        websiteMissing: !this.hasWebsite(lead),
        createdJobs: createdJobs.map((job) => this.toScrapingJobInfo(job)),
        skippedJobs: activeJobs.map((job) => this.toScrapingJobInfo(job)),
        message: this.buildScrapingJobsMessage(
          createdJobs.length,
          activeJobs.length,
          !this.hasWebsite(lead),
        ),
      };
    });
  }

  async getLeadIntelligence(leadId: string): Promise<LeadIntelligenceResponse> {
    const lead = await this.leadsRepository.findOne({
      where: { id: leadId },
    });

    if (!lead) {
      throw new NotFoundException(`Lead with id "${leadId}" not found`);
    }

    const [latestAnalysis, latestRawResult] = await Promise.all([
      this.leadAnalysisRepository.findOne({
        where: {
          leadId,
          analysisStatus: 'WEBSITE_NORMALIZED',
        },
        order: {
          analyzedAt: 'DESC',
          id: 'DESC',
        },
      }),
      this.scrapingRawResultsRepository.findOne({
        where: {
          leadId,
          source: 'website',
        },
        order: {
          createdAt: 'DESC',
          id: 'DESC',
        },
      }),
    ]);

    return {
      leadId,
      lead: {
        id: lead.id,
        name: lead.name,
        website: lead.website,
        state: lead.state,
      },
      latestAnalysis: latestAnalysis
        ? this.toLeadIntelligenceAnalysis(latestAnalysis)
        : null,
      latestRawResult: latestRawResult
        ? this.toLeadIntelligenceRawResult(latestRawResult)
        : null,
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
    const provider = this.getPlacesProvider();

    if (provider === 'curated') {
      return searchCuratedPlaces(query);
    }

    return this.fetchGooglePlaces(query);
  }

  private async seedCuratedDemoScores(lead: Lead): Promise<void> {
    await this.leadsRepository.manager.transaction(async (manager) => {
      const leadsRepository = manager.getRepository(Lead);
      const leadAnalysisRepository = manager.getRepository(LeadAnalysis);
      const leadScoresRepository = manager.getRepository(LeadScore);
      const leadAxisScoresRepository = manager.getRepository(LeadAxisScore);

      const lockedLead = await leadsRepository.findOne({
        where: { id: lead.id },
        lock: { mode: 'pessimistic_write' },
      });

      if (!lockedLead) {
        return;
      }

      const analysis = await this.findOrCreateCuratedDemoAnalysis(
        lockedLead,
        leadAnalysisRepository,
      );
      const axisRows = this.buildCuratedDemoAxisRows(lockedLead, analysis.id);
      const snapshot = this.buildCuratedDemoScoreSnapshot(lockedLead.id);

      const existingCurrentScore = await leadScoresRepository.findOne({
        where: {
          leadId: lockedLead.id,
          periodType: 'current',
        },
        order: {
          id: 'ASC',
        },
      });

      await leadScoresRepository.save(
        leadScoresRepository.create({
          ...(existingCurrentScore ? { id: existingCurrentScore.id } : {}),
          leadId: lockedLead.id,
          analysisId: analysis.id,
          periodType: 'current',
          digitalMaturity: snapshot.digitalMaturity,
          opportunity: snapshot.opportunity,
          analysisCost: null,
          scoreDate: CURATED_DEMO_SCORE_DATE,
        }),
      );

      for (const axisRow of axisRows) {
        const existingAxisScore = await leadAxisScoresRepository.findOne({
          where: {
            leadId: lockedLead.id,
            axis: axisRow.axis,
            scoreType: axisRow.scoreType,
          },
          order: {
            id: 'ASC',
          },
        });

        await leadAxisScoresRepository.save(
          leadAxisScoresRepository.create({
            ...(existingAxisScore ? { id: existingAxisScore.id } : {}),
            ...axisRow,
          }),
        );
      }
    });
  }

  private async findOrCreateCuratedDemoAnalysis(
    lead: Lead,
    leadAnalysisRepository: Repository<LeadAnalysis>,
  ): Promise<LeadAnalysis> {
    const existingAnalysis = await leadAnalysisRepository.findOne({
      where: {
        leadId: lead.id,
        analysisStatus: CURATED_DEMO_ANALYSIS_STATUS,
      },
      order: {
        id: 'ASC',
      },
    });

    if (existingAnalysis) {
      return existingAnalysis;
    }

    return leadAnalysisRepository.save(
      leadAnalysisRepository.create({
        leadId: lead.id,
        websiteUrl: lead.website,
        hasWebsite: this.hasWebsite(lead),
        hasSsl: this.hasWebsite(lead)
          ? (lead.website?.startsWith('https://') ?? null)
          : null,
        hasFacebook: false,
        hasInstagram: this.hasCuratedDemoSocialSignal(lead.id),
        seoTitle: null,
        seoDescription: null,
        mobileFriendly: null,
        performanceScore: null,
        analysisStatus: CURATED_DEMO_ANALYSIS_STATUS,
        analyzedAt: new Date(`${CURATED_DEMO_SCORE_DATE}T00:00:00.000Z`),
      }),
    );
  }

  private buildCuratedDemoAxisRows(
    lead: Lead,
    analysisId: number,
  ): Partial<LeadAxisScore>[] {
    const hasWebsite = this.hasWebsite(lead);
    const hasSocial = this.hasCuratedDemoSocialSignal(lead.id);
    const maturityRows = this.buildCuratedDemoRowsForScoreType(
      lead.id,
      AxisScoreType.DIGITAL_MATURITY,
      {
        gmb: this.demoScore(lead.id, 'maturity-gmb', 60, 85),
        website: hasWebsite
          ? this.demoScore(lead.id, 'maturity-website', 35, 80)
          : null,
        seo: hasWebsite
          ? this.demoScore(lead.id, 'maturity-seo', 25, 75)
          : null,
        social: hasSocial
          ? this.demoScore(lead.id, 'maturity-social', 30, 70)
          : null,
      },
      analysisId,
    );
    const opportunityRows = this.buildCuratedDemoRowsForScoreType(
      lead.id,
      AxisScoreType.OPPORTUNITY,
      {
        gmb: this.demoScore(lead.id, 'opportunity-gmb', 15, 50),
        website: hasWebsite
          ? this.demoScore(lead.id, 'opportunity-website', 30, 80)
          : null,
        seo: hasWebsite
          ? this.demoScore(lead.id, 'opportunity-seo', 35, 85)
          : null,
        social: hasSocial
          ? this.demoScore(lead.id, 'opportunity-social', 35, 75)
          : null,
      },
      analysisId,
    );

    return [...maturityRows, ...opportunityRows];
  }

  private buildCuratedDemoRowsForScoreType(
    leadId: string,
    scoreType: AxisScoreType,
    scores: {
      gmb: number;
      website: number | null;
      seo: number | null;
      social: number | null;
    },
    analysisId: number,
  ): Partial<LeadAxisScore>[] {
    return [
      this.toCuratedDemoAxisRow(
        leadId,
        analysisId,
        LeadScoreAxis.GMB,
        scoreType,
        scores.gmb,
        '0.2',
      ),
      this.toCuratedDemoAxisRow(
        leadId,
        analysisId,
        LeadScoreAxis.WEBSITE,
        scoreType,
        scores.website,
        '0.35',
      ),
      this.toCuratedDemoAxisRow(
        leadId,
        analysisId,
        LeadScoreAxis.SEO,
        scoreType,
        scores.seo,
        '0.25',
      ),
      this.toCuratedDemoAxisRow(
        leadId,
        analysisId,
        LeadScoreAxis.SOCIAL,
        scoreType,
        scores.social,
        '0.2',
      ),
    ];
  }

  private toCuratedDemoAxisRow(
    leadId: string,
    analysisId: number,
    axis: LeadScoreAxis,
    scoreType: AxisScoreType,
    score: number | null,
    weight: string,
  ): Partial<LeadAxisScore> {
    return {
      leadId,
      analysisId,
      axis,
      scoreType,
      score: score === null ? null : String(score),
      weight,
      weightedScore:
        score === null
          ? null
          : this.formatDecimal(score * Number.parseFloat(weight)),
      isAvailable: score !== null,
    };
  }

  private buildCuratedDemoScoreSnapshot(leadId: string): {
    digitalMaturity: string;
    opportunity: string;
  } {
    return {
      digitalMaturity: String(
        this.demoScore(leadId, 'snapshot-maturity', 45, 78),
      ),
      opportunity: String(
        this.demoScore(leadId, 'snapshot-opportunity', 32, 72),
      ),
    };
  }

  private demoScore(
    leadId: string,
    salt: string,
    minimum: number,
    maximum: number,
  ): number {
    const span = maximum - minimum + 1;
    return minimum + (this.stableHash(`${leadId}:${salt}`) % span);
  }

  private hasCuratedDemoSocialSignal(leadId: string): boolean {
    return CURATED_DEMO_SOCIAL_AVAILABLE_LEAD_IDS.has(leadId);
  }

  private isCuratedDemoLead(lead: Pick<Lead, 'id'>): boolean {
    return lead.id.startsWith('curated-demo-');
  }

  private stableHash(value: string): number {
    let hash = 0;
    for (let i = 0; i < value.length; i++) {
      hash = (hash * 31 + value.charCodeAt(i)) >>> 0;
    }
    return hash;
  }

  private formatDecimal(value: number): string {
    return (Math.round(value * 100) / 100).toString();
  }

  private getPlacesProvider(): PlacesProvider {
    const provider = this.configService
      .get<string>('PLACES_PROVIDER')
      ?.trim()
      .toLowerCase();

    if (!provider || provider === 'google') {
      return 'google';
    }

    if (provider === 'curated') {
      return 'curated';
    }

    throw new ServiceUnavailableException(
      `Unsupported PLACES_PROVIDER "${provider}". Use "google" or "curated".`,
    );
  }

  private async fetchGooglePlaces(query: string): Promise<GooglePlace[]> {
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

  private hasWebsite(lead: Pick<Lead, 'website'>): boolean {
    return typeof lead.website === 'string' && lead.website.trim().length > 0;
  }

  private buildScrapingJobsMessage(
    createdCount: number,
    skippedCount: number,
    websiteMissing: boolean,
  ): string {
    const message = `Created ${createdCount} scraping job(s); skipped ${skippedCount} active job(s).`;
    return websiteMissing
      ? `${message} Website scraping skipped because the lead has no website.`
      : message;
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

  private toLeadIntelligenceAnalysis(
    analysis: LeadAnalysis,
  ): LeadIntelligenceAnalysis {
    return {
      id: analysis.id,
      websiteUrl: analysis.websiteUrl,
      hasWebsite: analysis.hasWebsite,
      hasSsl: analysis.hasSsl,
      hasFacebook: analysis.hasFacebook,
      hasInstagram: analysis.hasInstagram,
      seoTitle: analysis.seoTitle,
      seoDescription: analysis.seoDescription,
      mobileFriendly: analysis.mobileFriendly,
      performanceScore: analysis.performanceScore,
      analysisStatus: analysis.analysisStatus,
      analyzedAt: analysis.analyzedAt,
    };
  }

  private toLeadIntelligenceRawResult(
    rawResult: ScrapingRawResult,
  ): LeadIntelligenceRawResult {
    return {
      id: rawResult.id,
      jobId: rawResult.jobId,
      source: rawResult.source,
      normalizedStatus: rawResult.normalizedStatus,
      rawJson: rawResult.rawJson,
      createdAt: rawResult.createdAt,
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
