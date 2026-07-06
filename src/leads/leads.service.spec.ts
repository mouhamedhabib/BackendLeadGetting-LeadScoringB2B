import {
  BadGatewayException,
  ConflictException,
  NotFoundException,
  ServiceUnavailableException,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { Repository } from 'typeorm';
import { Lead, LeadState } from './lead.entity';
import { LeadAnalysis } from './lead-analysis.entity';
import { LeadsService } from './leads.service';
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
import {
  getCuratedPlacesCount,
  searchCuratedPlaces,
} from './curated-places.provider';

type MockRepository<T> = {
  find: jest.Mock<Promise<T[]>, [unknown?]>;
  findOne: jest.Mock<Promise<T | null>, [unknown?]>;
  upsert: jest.Mock<Promise<void>, [Partial<T>[], string[]]>;
  findBy: jest.Mock<Promise<T[]>, [unknown]>;
  manager: {
    transaction: jest.Mock<
      Promise<unknown>,
      [(manager: MockEntityManager) => Promise<unknown>]
    >;
    getRepository: jest.Mock<unknown, [unknown]>;
  };
};

type MockEntityManager = {
  getRepository: jest.Mock<unknown, [unknown]>;
};

type MockSimpleRepository<T> = {
  find: jest.Mock<Promise<T[]>, [unknown?]>;
  findOne: jest.Mock<Promise<T | null>, [unknown?]>;
  create: jest.Mock<Partial<T>, [Partial<T>]>;
  save: jest.Mock<Promise<T>, [Partial<T>]>;
};

type MockScrapingJobsRepository = {
  create: jest.Mock<Partial<ScrapingJob>, [Partial<ScrapingJob>]>;
  find: jest.Mock<Promise<ScrapingJob[]>, [unknown?]>;
  save: jest.Mock<Promise<Partial<ScrapingJob>[]>, [Partial<ScrapingJob>[]]>;
};

type FindByIdCondition = {
  id: {
    _value?: string[];
  };
};

type FindOneWhereId = {
  where: {
    id: string;
  };
};

describe('LeadsService', () => {
  let service: LeadsService;
  let repository: MockRepository<Lead>;
  let leadScoresRepository: MockSimpleRepository<LeadScore>;
  let leadAxisScoresRepository: Omit<
    MockSimpleRepository<LeadAxisScore>,
    'find'
  >;
  let scrapingJobsRepository: MockScrapingJobsRepository;
  let leadAnalysisRepository: Omit<MockSimpleRepository<LeadAnalysis>, 'find'>;
  let scrapingRawResultsRepository: Pick<
    MockSimpleRepository<ScrapingRawResult>,
    'findOne'
  >;
  let configService: { get: jest.Mock<string | undefined, [string]> };

  beforeEach(() => {
    repository = {
      find: jest.fn<Promise<Lead[]>, [unknown?]>(),
      findOne: jest.fn<Promise<Lead | null>, [unknown?]>(),
      upsert: jest.fn<Promise<void>, [Partial<Lead>[], string[]]>(),
      findBy: jest.fn<Promise<Lead[]>, [unknown]>(),
      manager: {
        transaction: jest.fn<
          Promise<unknown>,
          [(manager: MockEntityManager) => Promise<unknown>]
        >((callback) => callback(repository.manager)),
        getRepository: jest.fn<unknown, [unknown]>(),
      },
    };
    leadScoresRepository = {
      find: jest.fn<Promise<LeadScore[]>, [unknown?]>().mockResolvedValue([]),
      findOne: jest
        .fn<Promise<LeadScore | null>, [unknown?]>()
        .mockResolvedValue(null),
      create: jest.fn((score: Partial<LeadScore>) => score),
      save: jest.fn((score: Partial<LeadScore>) =>
        Promise.resolve({
          id: score.id ?? 1,
          ...score,
        }),
      ),
    };
    leadAxisScoresRepository = {
      findOne: jest
        .fn<Promise<LeadAxisScore | null>, [unknown?]>()
        .mockResolvedValue(null),
      create: jest.fn((axisScore: Partial<LeadAxisScore>) => axisScore),
      save: jest.fn((axisScore: Partial<LeadAxisScore>) =>
        Promise.resolve({
          id: axisScore.id ?? 1,
          ...axisScore,
        }),
      ),
    };
    scrapingJobsRepository = {
      create: jest.fn((job: Partial<ScrapingJob>) => job),
      find: jest.fn<Promise<ScrapingJob[]>, [unknown?]>().mockResolvedValue([]),
      save: jest.fn((jobs: Partial<ScrapingJob>[]) =>
        Promise.resolve(
          jobs.map((job, index) => ({
            id: index + 1,
            leadId: job.leadId,
            jobType: job.jobType,
            status: job.status,
            source: job.source,
            trigger: job.trigger,
          })),
        ),
      ),
    };
    leadAnalysisRepository = {
      findOne: jest
        .fn<Promise<LeadAnalysis | null>, [unknown?]>()
        .mockResolvedValue(null),
      create: jest.fn((analysis: Partial<LeadAnalysis>) => analysis),
      save: jest.fn((analysis: Partial<LeadAnalysis>) =>
        Promise.resolve({
          id: analysis.id ?? 10,
          ...analysis,
        }),
      ),
    };
    scrapingRawResultsRepository = {
      findOne: jest
        .fn<Promise<ScrapingRawResult | null>, [unknown?]>()
        .mockResolvedValue(null),
    };
    repository.manager.getRepository.mockImplementation((entity) => {
      if (entity === Lead) {
        return repository;
      }

      if (entity === ScrapingJob) {
        return scrapingJobsRepository;
      }

      if (entity === LeadAnalysis) {
        return leadAnalysisRepository;
      }

      if (entity === LeadScore) {
        return leadScoresRepository;
      }

      if (entity === LeadAxisScore) {
        return leadAxisScoresRepository;
      }

      throw new Error(`Unexpected repository: ${String(entity)}`);
    });
    configService = {
      get: jest.fn((key: string) =>
        key === 'GOOGLE_PLACES_API_KEY' ? 'test-api-key' : undefined,
      ),
    };
    service = new LeadsService(
      repository as unknown as Repository<Lead>,
      leadScoresRepository as unknown as Repository<LeadScore>,
      leadAxisScoresRepository as unknown as Repository<LeadAxisScore>,
      scrapingJobsRepository as unknown as Repository<ScrapingJob>,
      leadAnalysisRepository as unknown as Repository<LeadAnalysis>,
      scrapingRawResultsRepository as unknown as Repository<ScrapingRawResult>,
      configService as unknown as ConfigService,
    );
  });

  afterEach(() => {
    jest.useRealTimers();
    jest.restoreAllMocks();
  });

  it('returns leads from PostgreSQL', async () => {
    const leads = [{ id: 'place-1' }] as Lead[];
    repository.find.mockResolvedValue(leads);

    await expect(service.findAll()).resolves.toBe(leads);
    expect(repository.find).toHaveBeenCalledWith({
      relations: {
        contacts: true,
        scores: true,
      },
    });
  });

  it('throws when a DB-backed lead does not exist', async () => {
    repository.findOne.mockResolvedValue(null);

    await expect(service.findOne('missing')).rejects.toBeInstanceOf(
      NotFoundException,
    );
  });

  it('maps Google Places fields, skips entries without IDs, and upserts by ID', async () => {
    jest.spyOn(global, 'fetch').mockResolvedValue({
      ok: true,
      json: () =>
        Promise.resolve({
          places: [
            {
              id: 'place-1',
              displayName: { text: 'Plumber One' },
              formattedAddress: '1 Main Street',
              rating: 4.7,
              userRatingCount: 18,
              location: { latitude: 36.8, longitude: 10.18 },
            },
            { displayName: { text: 'Missing ID' } },
          ],
        }),
    } as Response);
    repository.upsert.mockResolvedValue(undefined);
    const savedLead = {
      id: 'place-1',
      name: 'Plumber One',
      website: 'https://plumber.example',
      state: LeadState.RAW,
    } as Lead;
    repository.findBy.mockResolvedValue([savedLead]);
    repository.findOne.mockResolvedValue(savedLead);

    await expect(service.search('plumber')).resolves.toEqual([
      {
        lead: savedLead,
        websiteMissing: false,
        scrapingJobs: {
          leadId: 'place-1',
          websiteMissing: false,
          createdJobs: [
            {
              id: 1,
              leadId: 'place-1',
              jobType: ScrapingJobType.WEBSITE,
              status: ScrapingJobStatus.PENDING,
              source: 'website',
              trigger: 'initial_enrichment',
            },
          ],
          skippedJobs: [],
          message: 'Created 1 scraping job(s); skipped 0 active job(s).',
        },
      },
    ]);
    expect(fetch).toHaveBeenCalledWith(
      'https://places.googleapis.com/v1/places:searchText',
      {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-Goog-Api-Key': 'test-api-key',
          'X-Goog-FieldMask':
            'places.id,places.displayName,places.formattedAddress,places.nationalPhoneNumber,places.websiteUri,places.rating,places.userRatingCount,places.location',
        },
        body: JSON.stringify({ textQuery: 'plumber' }),
      },
    );
    expect(repository.upsert).toHaveBeenCalledWith(
      [
        {
          id: 'place-1',
          name: 'Plumber One',
          address: '1 Main Street',
          phone: null,
          website: null,
          rating: 4.7,
          userRatingsTotal: 18,
          lat: 36.8,
          lng: 10.18,
          searchQuery: 'plumber',
        },
      ],
      ['id'],
    );
  });

  it('uses curated provider data deterministically without calling Google', async () => {
    configService.get.mockImplementation((key: string) =>
      key === 'PLACES_PROVIDER' ? 'curated' : 'test-api-key',
    );
    const fetchSpy = jest.spyOn(global, 'fetch');
    repository.upsert.mockResolvedValue(undefined);
    repository.findBy.mockImplementation(({ id }: FindByIdCondition) => {
      const ids = id._value ?? [];
      const upsertedLeads = new Map(
        repository.upsert.mock.calls
          .at(-1)?.[0]
          .map((lead) => [lead.id, lead]) ?? [],
      );
      return Promise.resolve(
        ids.map(
          (leadId) =>
            ({
              id: leadId,
              name: upsertedLeads.get(leadId)?.name ?? null,
              website: upsertedLeads.get(leadId)?.website ?? null,
              state: LeadState.RAW,
            }) as Lead,
        ),
      );
    });
    repository.findOne.mockImplementation(({ where }: FindOneWhereId) =>
      Promise.resolve({
        id: where.id,
        website: where.id.includes('tn-bakery-medina')
          ? 'https://www.paul.fr'
          : null,
      }),
    );

    const firstResult = await service.search('bakery Tunis');
    const secondResult = await service.search('bakery Tunis');

    expect(fetchSpy).not.toHaveBeenCalled();
    expect(repository.upsert).toHaveBeenNthCalledWith(
      1,
      expect.arrayContaining([
        expect.objectContaining({
          id: 'curated-demo-tn-bakery-medina-tunis',
          name: 'مخبزة المدينة - Boulangerie Medina',
          website: 'https://www.paul.fr',
          searchQuery: 'bakery Tunis',
        }),
      ]),
      ['id'],
    );
    expect(repository.upsert.mock.calls[1]).toEqual(
      repository.upsert.mock.calls[0],
    );
    expect(firstResult.map((result) => result.lead.id)).toEqual(
      secondResult.map((result) => result.lead.id),
    );
  });

  it('keeps exactly 20 curated leads and query-specific subsets', () => {
    expect(getCuratedPlacesCount()).toBe(20);
    expect(
      searchCuratedPlaces('bakery Tunis').map((place) => place.id),
    ).toEqual(['curated-demo-tn-bakery-medina-tunis']);
    expect(
      searchCuratedPlaces('agency Belgium').map((place) => place.id),
    ).toEqual([
      'curated-demo-be-digital-agency-tapptic-brussels',
      'curated-demo-be-real-estate-century21-brussels',
    ]);
    expect(
      searchCuratedPlaces('hotel Hammamet').map((place) => place.id),
    ).toEqual(['curated-demo-tn-hotel-la-badira-hammamet']);
    expect(
      searchCuratedPlaces('plumber Brussels').map((place) => place.id),
    ).toEqual(['curated-demo-be-plumber-facq-brussels']);
    expect(
      searchCuratedPlaces('dentist France').map((place) => place.id),
    ).toEqual(['curated-demo-fr-dental-clinic-saint-lazare-paris']);
  });

  it('creates website jobs only for curated leads with websites', async () => {
    configService.get.mockImplementation((key: string) =>
      key === 'PLACES_PROVIDER' ? 'curated' : 'test-api-key',
    );
    repository.upsert.mockResolvedValue(undefined);
    repository.findBy.mockResolvedValue([
      {
        id: 'curated-demo-tn-plumber-hydrotek-tunis',
        website: null,
        state: LeadState.RAW,
      },
      {
        id: 'curated-demo-be-plumber-facq-brussels',
        website: 'https://www.facq.be',
        state: LeadState.RAW,
      },
    ] as Lead[]);
    repository.findOne.mockImplementation(({ where }: FindOneWhereId) =>
      Promise.resolve({
        id: where.id,
        website: where.id.includes('be-plumber-facq')
          ? 'https://www.facq.be'
          : null,
      }),
    );

    await expect(service.search('plumber')).resolves.toMatchObject([
      {
        lead: { id: 'curated-demo-tn-plumber-hydrotek-tunis' },
        websiteMissing: true,
        scrapingJobs: {
          websiteMissing: true,
          createdJobs: [],
        },
      },
      {
        lead: { id: 'curated-demo-be-plumber-facq-brussels' },
        websiteMissing: false,
        scrapingJobs: {
          websiteMissing: false,
          createdJobs: [{ jobType: ScrapingJobType.WEBSITE }],
        },
      },
    ]);
    expect(scrapingJobsRepository.save).toHaveBeenCalledTimes(1);
    expect(scrapingJobsRepository.save).toHaveBeenCalledWith([
      expect.objectContaining({
        leadId: 'curated-demo-be-plumber-facq-brussels',
        jobType: ScrapingJobType.WEBSITE,
        trigger: 'initial_enrichment',
      }),
    ]);
  });

  it('seeds curated demo score and axis rows idempotently', async () => {
    configService.get.mockImplementation((key: string) =>
      key === 'PLACES_PROVIDER' ? 'curated' : 'test-api-key',
    );
    const savedLead = {
      id: 'curated-demo-tn-bakery-medina-tunis',
      name: 'مخبزة المدينة - Boulangerie Medina',
      website: 'https://www.paul.fr',
      state: LeadState.RAW,
    } as Lead;
    repository.upsert.mockResolvedValue(undefined);
    repository.findBy.mockResolvedValue([savedLead]);
    repository.findOne.mockResolvedValue(savedLead);
    leadAnalysisRepository.findOne
      .mockResolvedValueOnce(null)
      .mockResolvedValue({
        id: 20,
        leadId: savedLead.id,
        analysisStatus: 'CURATED_DEMO_AXIS_SEED',
      });
    leadAnalysisRepository.save.mockResolvedValue({
      id: 20,
      leadId: savedLead.id,
      analysisStatus: 'CURATED_DEMO_AXIS_SEED',
    });
    leadScoresRepository.findOne
      .mockResolvedValueOnce(null)
      .mockResolvedValue({ id: 30 });
    leadAxisScoresRepository.findOne.mockImplementation(() => {
      const callIndex = leadAxisScoresRepository.findOne.mock.calls.length;
      return Promise.resolve(
        callIndex <= 8 ? null : ({ id: 100 + callIndex } as LeadAxisScore),
      );
    });

    await service.search('bakery Tunis');
    await service.search('bakery Tunis');

    expect(leadAnalysisRepository.create).toHaveBeenCalledTimes(1);
    expect(leadScoresRepository.save).toHaveBeenNthCalledWith(
      1,
      expect.objectContaining({
        leadId: savedLead.id,
        analysisId: 20,
        periodType: 'current',
        analysisCost: null,
        scoreDate: '2026-06-29',
      }),
    );
    expect(leadScoresRepository.save).toHaveBeenNthCalledWith(
      2,
      expect.objectContaining({
        id: 30,
        leadId: savedLead.id,
        analysisId: 20,
        periodType: 'current',
      }),
    );
    expect(leadAxisScoresRepository.save).toHaveBeenCalledTimes(16);
    expect(leadAxisScoresRepository.save).toHaveBeenCalledWith(
      expect.objectContaining({
        leadId: savedLead.id,
        analysisId: 20,
        axis: LeadScoreAxis.GMB,
        scoreType: AxisScoreType.DIGITAL_MATURITY,
        weight: '0.2',
        isAvailable: true,
      }),
    );
    expect(leadAxisScoresRepository.save).toHaveBeenCalledWith(
      expect.objectContaining({
        leadId: savedLead.id,
        analysisId: 20,
        axis: LeadScoreAxis.WEBSITE,
        scoreType: AxisScoreType.OPPORTUNITY,
        weight: '0.35',
        isAvailable: true,
      }),
    );
    expect(
      leadAxisScoresRepository.save.mock.calls
        .slice(8)
        .every(([axisScore]) => typeof axisScore.id === 'number'),
    ).toBe(true);
  });

  it('creates a pending website scraping job by default', async () => {
    repository.findOne.mockResolvedValue({
      id: 'place-1',
      website: 'https://example.com',
    });

    await expect(service.createScrapingJobsForLead('place-1')).resolves.toEqual(
      {
        leadId: 'place-1',
        websiteMissing: false,
        createdJobs: [
          {
            id: 1,
            leadId: 'place-1',
            jobType: ScrapingJobType.WEBSITE,
            status: ScrapingJobStatus.PENDING,
            source: 'website',
            trigger: 'manual',
          },
        ],
        skippedJobs: [],
        message: 'Created 1 scraping job(s); skipped 0 active job(s).',
      },
    );
    const findOptions = scrapingJobsRepository.find.mock.calls[0]?.[0] as
      | {
          where?: {
            leadId?: string;
            jobType?: unknown;
            status?: unknown;
          };
        }
      | undefined;
    expect(findOptions?.where?.leadId).toBe('place-1');
    expect(findOptions?.where?.jobType).toBeDefined();
    expect(findOptions?.where?.status).toBeDefined();
    expect(scrapingJobsRepository.save).toHaveBeenCalledWith([
      {
        leadId: 'place-1',
        jobType: ScrapingJobType.WEBSITE,
        status: ScrapingJobStatus.PENDING,
        source: 'website',
        trigger: 'manual',
      },
    ]);
  });

  it('creates only explicitly requested scraping job types', async () => {
    repository.findOne.mockResolvedValue({
      id: 'place-1',
      website: 'https://example.com',
    });
    scrapingJobsRepository.save.mockImplementation(
      (jobs: Partial<ScrapingJob>[]) =>
        Promise.resolve(
          jobs.map((job, index) => ({
            id: index + 20,
            leadId: job.leadId,
            jobType: job.jobType,
            status: job.status,
            source: job.source,
            trigger: job.trigger,
          })),
        ),
    );

    await expect(
      service.createScrapingJobsForLead('place-1', [
        ScrapingJobType.WEBSITE,
        ScrapingJobType.SEO,
      ]),
    ).resolves.toMatchObject({
      leadId: 'place-1',
      websiteMissing: false,
      createdJobs: [
        {
          id: 20,
          jobType: ScrapingJobType.WEBSITE,
        },
        {
          id: 21,
          jobType: ScrapingJobType.SEO,
        },
      ],
      skippedJobs: [],
    });
    expect(scrapingJobsRepository.save).toHaveBeenCalledWith([
      {
        leadId: 'place-1',
        jobType: ScrapingJobType.WEBSITE,
        status: ScrapingJobStatus.PENDING,
        source: 'website',
        trigger: 'manual',
      },
      {
        leadId: 'place-1',
        jobType: ScrapingJobType.SEO,
        status: ScrapingJobStatus.PENDING,
        source: 'website',
        trigger: 'manual',
      },
    ]);
  });

  it('skips an existing active website scraping job for the same lead', async () => {
    repository.findOne.mockResolvedValue({
      id: 'place-1',
      website: 'https://example.com',
    });
    scrapingJobsRepository.find.mockResolvedValue([
      {
        id: 10,
        leadId: 'place-1',
        jobType: ScrapingJobType.WEBSITE,
        status: ScrapingJobStatus.RUNNING,
        source: 'website',
        trigger: 'manual',
      },
    ]);

    await expect(service.createScrapingJobsForLead('place-1')).resolves.toEqual(
      {
        leadId: 'place-1',
        websiteMissing: false,
        createdJobs: [],
        skippedJobs: [
          {
            id: 10,
            leadId: 'place-1',
            jobType: ScrapingJobType.WEBSITE,
            status: ScrapingJobStatus.RUNNING,
            source: 'website',
            trigger: 'manual',
          },
        ],
        message: 'Created 0 scraping job(s); skipped 1 active job(s).',
      },
    );
    expect(scrapingJobsRepository.save).not.toHaveBeenCalled();
  });

  it('saves a clear website-missing status and creates no default job', async () => {
    repository.findOne.mockResolvedValue({ id: 'place-1', website: null });

    await expect(service.createScrapingJobsForLead('place-1')).resolves.toEqual(
      {
        leadId: 'place-1',
        websiteMissing: true,
        createdJobs: [],
        skippedJobs: [],
        message:
          'Created 0 scraping job(s); skipped 0 active job(s). Website scraping skipped because the lead has no website.',
      },
    );
    expect(scrapingJobsRepository.find).not.toHaveBeenCalled();
    expect(scrapingJobsRepository.save).not.toHaveBeenCalled();
  });

  it('does not create scraping jobs for a missing lead', async () => {
    repository.findOne.mockResolvedValue(null);

    await expect(
      service.createScrapingJobsForLead('missing'),
    ).rejects.toBeInstanceOf(NotFoundException);
    expect(scrapingJobsRepository.find).not.toHaveBeenCalled();
    expect(scrapingJobsRepository.save).not.toHaveBeenCalled();
  });

  it('returns latest website intelligence without scoring calculations', async () => {
    const analyzedAt = new Date('2026-06-29T08:00:00.000Z');
    const createdAt = new Date('2026-06-29T08:01:00.000Z');
    repository.findOne.mockResolvedValue({
      id: 'place-1',
      name: 'Demo Bakery',
      website: 'https://demo.example',
      state: LeadState.ENRICHED,
    });
    leadAnalysisRepository.findOne.mockResolvedValue({
      id: 7,
      websiteUrl: 'https://demo.example',
      hasWebsite: true,
      hasSsl: true,
      hasFacebook: false,
      hasInstagram: true,
      seoTitle: 'Demo Bakery',
      seoDescription: 'Fresh bread',
      mobileFriendly: null,
      performanceScore: null,
      analysisStatus: 'WEBSITE_NORMALIZED',
      analyzedAt,
    });
    scrapingRawResultsRepository.findOne.mockResolvedValue({
      id: 11,
      jobId: 10,
      source: 'website',
      normalizedStatus: 'NORMALIZED',
      rawJson: {
        url: 'https://demo.example',
        title: 'Demo Bakery',
      },
      createdAt,
    });

    await expect(service.getLeadIntelligence('place-1')).resolves.toEqual({
      leadId: 'place-1',
      lead: {
        id: 'place-1',
        name: 'Demo Bakery',
        website: 'https://demo.example',
        state: LeadState.ENRICHED,
      },
      latestAnalysis: {
        id: 7,
        websiteUrl: 'https://demo.example',
        hasWebsite: true,
        hasSsl: true,
        hasFacebook: false,
        hasInstagram: true,
        seoTitle: 'Demo Bakery',
        seoDescription: 'Fresh bread',
        mobileFriendly: null,
        performanceScore: null,
        analysisStatus: 'WEBSITE_NORMALIZED',
        analyzedAt,
      },
      latestRawResult: {
        id: 11,
        jobId: 10,
        source: 'website',
        normalizedStatus: 'NORMALIZED',
        rawJson: {
          url: 'https://demo.example',
          title: 'Demo Bakery',
        },
        createdAt,
      },
    });
    expect(leadAnalysisRepository.findOne).toHaveBeenCalledWith({
      where: {
        leadId: 'place-1',
        analysisStatus: 'WEBSITE_NORMALIZED',
      },
      order: {
        analyzedAt: 'DESC',
        id: 'DESC',
      },
    });
    expect(scrapingRawResultsRepository.findOne).toHaveBeenCalledWith({
      where: {
        leadId: 'place-1',
        source: 'website',
      },
      order: {
        createdAt: 'DESC',
        id: 'DESC',
      },
    });
  });

  it('returns null intelligence sections for a lead with no scraping data', async () => {
    repository.findOne.mockResolvedValue({
      id: 'place-1',
      name: null,
      website: null,
      state: LeadState.RAW,
    });

    await expect(service.getLeadIntelligence('place-1')).resolves.toEqual({
      leadId: 'place-1',
      lead: {
        id: 'place-1',
        name: null,
        website: null,
        state: LeadState.RAW,
      },
      latestAnalysis: null,
      latestRawResult: null,
    });
  });

  it('generates live AI analysis through FastAPI without database writes', async () => {
    const fetchMock = jest.fn().mockResolvedValue({
      ok: true,
      json: jest.fn().mockResolvedValue({
        success: true,
        observations: ['Website has a clear service page'],
        opportunities: ['Improve conversion copy'],
        recommended_services: ['Landing page optimization'],
        summary: 'Strong foundation with conversion upside.',
        confidence: 0.82,
      }),
    });
    jest.spyOn(globalThis, 'fetch').mockImplementation(fetchMock);
    repository.findOne.mockResolvedValue({
      id: 'place-1',
      name: 'Demo Agency',
    });
    scrapingRawResultsRepository.findOne.mockResolvedValue({
      id: 42,
      leadId: 'place-1',
      source: 'website',
      normalizedStatus: 'NORMALIZED',
      createdAt: new Date('2026-07-03T10:00:00.000Z'),
      rawJson: {},
    });
    configService.get.mockImplementation((key: string) => {
      if (key === 'FASTAPI_BASE_URL') {
        return 'http://fastapi.test';
      }
      if (key === 'FASTAPI_AI_ANALYSIS_PATH') {
        return '/ai/business/:leadId';
      }
      return undefined;
    });

    await expect(service.generateAiAnalysis('place-1')).resolves.toMatchObject({
      status: 'success',
      leadId: 'place-1',
      analysis: {
        observations: ['Website has a clear service page'],
        opportunities: ['Improve conversion copy'],
        recommended_services: ['Landing page optimization'],
        summary: 'Strong foundation with conversion upside.',
        confidence: 0.82,
      },
    });
    expect(fetchMock).toHaveBeenCalledWith(
      'http://fastapi.test/ai/business/place-1',
      expect.objectContaining({ method: 'POST' }),
    );
    expect(scrapingRawResultsRepository.findOne).toHaveBeenCalledWith({
      where: {
        leadId: 'place-1',
        source: 'website',
        normalizedStatus: 'NORMALIZED',
      },
      order: {
        createdAt: 'DESC',
        id: 'DESC',
      },
    });
    expect(repository.upsert).not.toHaveBeenCalled();
    expect(scrapingJobsRepository.save).not.toHaveBeenCalled();
    expect(leadAnalysisRepository.save).not.toHaveBeenCalled();
    expect(leadScoresRepository.save).not.toHaveBeenCalled();
    expect(leadAxisScoresRepository.save).not.toHaveBeenCalled();
  });

  it('uses default FastAPI AI analysis settings when env vars are absent', async () => {
    const fetchMock = jest.fn().mockResolvedValue({
      ok: true,
      json: jest.fn().mockResolvedValue({
        analysis: {
          summary: 'Default FastAPI route works.',
          confidence: 0.75,
        },
      }),
    });
    jest.spyOn(globalThis, 'fetch').mockImplementation(fetchMock);
    repository.findOne.mockResolvedValue({
      id: 'place-1',
      name: 'Demo Agency',
    });
    scrapingRawResultsRepository.findOne.mockResolvedValue({
      id: 42,
      leadId: 'place-1',
      source: 'website',
      normalizedStatus: 'NORMALIZED',
      createdAt: new Date('2026-07-03T10:00:00.000Z'),
      rawJson: {},
    });

    await expect(service.generateAiAnalysis('place-1')).resolves.toMatchObject({
      status: 'success',
      leadId: 'place-1',
      analysis: {
        summary: 'Default FastAPI route works.',
        confidence: 0.75,
      },
    });
    expect(fetchMock).toHaveBeenCalledWith(
      'http://127.0.0.1:8001/ai/analyze-lead/place-1',
      expect.objectContaining({ method: 'POST' }),
    );
  });

  it('does not generate AI analysis for a missing lead', async () => {
    const fetchMock = jest.fn();
    jest.spyOn(globalThis, 'fetch').mockImplementation(fetchMock);
    repository.findOne.mockResolvedValue(null);

    await expect(service.generateAiAnalysis('missing')).rejects.toBeInstanceOf(
      NotFoundException,
    );
    expect(scrapingRawResultsRepository.findOne).not.toHaveBeenCalled();
    expect(fetchMock).not.toHaveBeenCalled();
  });

  it('returns a conflict when no normalized website intelligence exists', async () => {
    const fetchMock = jest.fn();
    jest.spyOn(globalThis, 'fetch').mockImplementation(fetchMock);
    repository.findOne.mockResolvedValue({ id: 'place-1' });
    scrapingRawResultsRepository.findOne.mockResolvedValue(null);

    await expect(service.generateAiAnalysis('place-1')).rejects.toBeInstanceOf(
      ConflictException,
    );
    expect(fetchMock).not.toHaveBeenCalled();
  });

  it('maps FastAPI transport failures to bad gateway', async () => {
    jest
      .spyOn(globalThis, 'fetch')
      .mockRejectedValue(new Error('connect ECONNREFUSED'));
    repository.findOne.mockResolvedValue({ id: 'place-1' });
    scrapingRawResultsRepository.findOne.mockResolvedValue({
      id: 42,
      leadId: 'place-1',
      source: 'website',
      normalizedStatus: 'NORMALIZED',
      createdAt: new Date('2026-07-03T10:00:00.000Z'),
      rawJson: {},
    });

    await expect(service.generateAiAnalysis('place-1')).rejects.toBeInstanceOf(
      BadGatewayException,
    );
  });

  it('maps Gemini failures from FastAPI to service unavailable', async () => {
    jest.spyOn(globalThis, 'fetch').mockResolvedValue({
      ok: true,
      json: jest.fn().mockResolvedValue({
        success: false,
        error_message: 'Gemini quota exhausted',
      }),
    } as unknown as Response);
    repository.findOne.mockResolvedValue({ id: 'place-1' });
    scrapingRawResultsRepository.findOne.mockResolvedValue({
      id: 42,
      leadId: 'place-1',
      source: 'website',
      normalizedStatus: 'NORMALIZED',
      createdAt: new Date('2026-07-03T10:00:00.000Z'),
      rawJson: {},
    });

    await expect(service.generateAiAnalysis('place-1')).rejects.toBeInstanceOf(
      ServiceUnavailableException,
    );
  });

  it('does not expose legacy timeline mocks unless explicitly enabled', async () => {
    repository.findOne.mockResolvedValue(null);

    await expect(service.getTimeline('101')).rejects.toBeInstanceOf(
      NotFoundException,
    );
  });

  it('keeps legacy timeline mocks gated behind a non-production flag', async () => {
    configService.get.mockImplementation((key: string) => {
      if (key === 'ENABLE_LEGACY_MOCK_LEADS') return 'true';
      if (key === 'NODE_ENV') return 'development';
      if (key === 'GOOGLE_PLACES_API_KEY') return 'test-api-key';
      return undefined;
    });

    await expect(service.getTimeline('101')).resolves.toHaveLength(1);
  });

  it('keeps legacy timeline mocks disabled in production', async () => {
    configService.get.mockImplementation((key: string) => {
      if (key === 'ENABLE_LEGACY_MOCK_LEADS') return 'true';
      if (key === 'NODE_ENV') return 'production';
      if (key === 'GOOGLE_PLACES_API_KEY') return 'test-api-key';
      return undefined;
    });
    repository.findOne.mockResolvedValue(null);

    await expect(service.getTimeline('101')).rejects.toBeInstanceOf(
      NotFoundException,
    );
  });

  it('returns safe optional detail data for a DB-backed lead', async () => {
    repository.findOne.mockResolvedValue({ id: 'place-1' });

    await expect(service.getTimeline('place-1')).resolves.toEqual([]);
    await expect(service.getBreakdown('place-1')).resolves.toEqual({
      digitalMaturity: [],
      opportunity: [],
    });
  });

  it('maps persisted axis scores without calculating a final score', async () => {
    repository.findOne.mockResolvedValue({
      id: 'place-1',
      axisScores: [
        {
          axis: LeadScoreAxis.GMB,
          scoreType: AxisScoreType.DIGITAL_MATURITY,
          score: '70',
          weight: '0.2',
          weightedScore: '14',
          isAvailable: true,
        },
        {
          axis: LeadScoreAxis.SOCIAL,
          scoreType: AxisScoreType.DIGITAL_MATURITY,
          score: null,
          weight: '0.2',
          weightedScore: null,
          isAvailable: false,
        },
      ] as LeadAxisScore[],
    });

    await expect(service.getBreakdown('place-1')).resolves.toEqual({
      digitalMaturity: [
        {
          category: 'GMB',
          opportunity: 70,
          percentage: 20,
          weightedScore: 14,
          isAvailable: true,
        },
        {
          category: 'SOCIAL',
          opportunity: null,
          percentage: 20,
          weightedScore: null,
          isAvailable: false,
        },
      ],
      opportunity: [],
    });
  });

  it('keeps a real 404 for optional detail data when the lead does not exist', async () => {
    repository.findOne.mockResolvedValue(null);

    await expect(service.getTimeline('missing')).rejects.toBeInstanceOf(
      NotFoundException,
    );
  });

  it('retries external failures and returns a meaningful service error', async () => {
    jest.useFakeTimers();
    jest.spyOn(global, 'fetch').mockRejectedValue(new Error('network down'));

    const expectation = expect(
      service.search('plumber'),
    ).rejects.toBeInstanceOf(ServiceUnavailableException);
    await jest.runAllTimersAsync();
    await expectation;

    expect(fetch).toHaveBeenCalledTimes(3);
  });
});
