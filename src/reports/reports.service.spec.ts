import { Test, TestingModule } from '@nestjs/testing';
import { getRepositoryToken } from '@nestjs/typeorm';
import { Lead } from '../leads/lead.entity';
import { ReportsService } from './reports.service';

describe('ReportsService', () => {
  let service: ReportsService;

  const leadsRepository = {
    find: jest.fn(),
  };

  beforeEach(async () => {
    leadsRepository.find.mockResolvedValue([]);

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        ReportsService,
        {
          provide: getRepositoryToken(Lead),
          useValue: leadsRepository,
        },
      ],
    }).compile();

    service = module.get<ReportsService>(ReportsService);
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  it('should return the database-backed reports contract with safe empty defaults', async () => {
    const reports = await service.getReports();

    expect(reports.summary).toEqual({
      totalLeads: 0,
      reportsAvailable: 5,
      activeAlerts: 0,
      projectionAccuracy: null,
      scheduledReports: 0,
      recentExports: 0,
    });
    expect(reports.templates.map((template) => template.name)).toEqual([
      'Opportunity Report',
      'Efficiency Report',
      'Alert Report',
      'Comparison Report',
      'Projection Report',
    ]);
    expect(reports.exportFormats).toEqual(['pdf', 'xlsx', 'csv']);
    expect(reports.leadSummaries).toEqual([]);
    expect(reports.alerts).toEqual([]);
    expect(reports.projections).toEqual([]);
  });

  it('should aggregate persisted lead relations without inventing alerts or projections', async () => {
    leadsRepository.find.mockResolvedValueOnce([
      {
        id: 'place-1',
        name: 'Demo Bakery',
        address: '1 Main St',
        searchQuery: 'bakery tunis',
        state: 'SCORED',
        website: 'https://example.com',
        phone: '+216 00 000 000',
        rating: 4.5,
        userRatingsTotal: 12,
        contacts: [{ id: 1 }],
        analyses: [{ id: 1 }],
        axisScores: [{ id: 1 }, { id: 2 }],
        scores: [
          {
            id: 1,
            scoreDate: '2026-06-23',
            periodType: 'daily',
            digitalMaturity: '42.5',
            opportunity: '57.5',
            analysisCost: '12.25',
            createdAt: new Date('2026-06-23T00:00:00.000Z'),
          },
          {
            id: 2,
            scoreDate: '2026-06-24',
            periodType: 'daily',
            digitalMaturity: '41.5',
            opportunity: '58.5',
            analysisCost: '11.25',
            createdAt: new Date('2026-06-24T00:00:00.000Z'),
          },
        ],
      },
    ]);

    const reports = await service.getReports();

    expect(reports.summary.totalLeads).toBe(1);
    expect(reports.summary.activeAlerts).toBe(0);
    expect(reports.summary.projectionAccuracy).toBeNull();
    expect(reports.leadSummaries).toEqual([
      expect.objectContaining({
        id: 'place-1',
        name: 'Demo Bakery',
        contactCount: 1,
        analysisCount: 1,
        axisScoreCount: 2,
        latestScore: {
          scoreDate: '2026-06-24',
          periodType: 'daily',
          digitalMaturity: 41.5,
          opportunity: 58.5,
          analysisCost: 11.25,
        },
      }),
    ]);
    expect(reports.alerts).toEqual([]);
    expect(reports.projections).toEqual([]);
  });
});
