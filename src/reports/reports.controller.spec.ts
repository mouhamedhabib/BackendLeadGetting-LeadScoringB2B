import { Test, TestingModule } from '@nestjs/testing';
import { ReportsController } from './reports.controller';
import { ReportsService } from './reports.service';

describe('ReportsController', () => {
  let controller: ReportsController;
  const reportsService = {
    getReports: jest.fn(),
  };

  beforeEach(async () => {
    reportsService.getReports.mockResolvedValue({
      summary: {
        totalLeads: 0,
        reportsAvailable: 5,
        activeAlerts: 0,
        projectionAccuracy: null,
        scheduledReports: 0,
        recentExports: 0,
      },
      templates: [],
      exportFormats: ['pdf', 'xlsx', 'csv'],
      leadSummaries: [],
      alerts: [],
      projections: [],
    });

    const module: TestingModule = await Test.createTestingModule({
      controllers: [ReportsController],
      providers: [
        {
          provide: ReportsService,
          useValue: reportsService,
        },
      ],
    }).compile();

    controller = module.get<ReportsController>(ReportsController);
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });

  it('should delegate report retrieval to the service', async () => {
    await expect(controller.getReports()).resolves.toHaveProperty('summary');
    expect(reportsService.getReports).toHaveBeenCalledTimes(1);
  });
});
