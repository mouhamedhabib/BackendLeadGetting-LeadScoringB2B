import { Test, TestingModule } from '@nestjs/testing';
import { ReportsService } from './reports.service';

describe('ReportsService', () => {
  let service: ReportsService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [ReportsService],
    }).compile();

    service = module.get<ReportsService>(ReportsService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  it('should return the complete reports contract', () => {
    const reports = service.getReports();

    expect(typeof reports.totalReports).toBe('number');
    expect(typeof reports.scheduledReports).toBe('number');
    expect(typeof reports.activeAlerts).toBe('number');
    expect(typeof reports.projectionAccuracy).toBe('number');
    expect(reports.alertSummary).toEqual(
      expect.objectContaining({
        critical: expect.any(Number),
        warning: expect.any(Number),
        info: expect.any(Number),
      }),
    );
    expect(Array.isArray(reports.leads)).toBe(true);
    expect(reports.leadDetails).toBeDefined();
    expect(Array.isArray(reports.exportOptions)).toBe(true);
    expect(Array.isArray(reports.recentExports)).toBe(true);
    expect(Array.isArray(reports.projectionData)).toBe(true);
    expect(Array.isArray(reports.projectionInsights)).toBe(true);
  });
});
