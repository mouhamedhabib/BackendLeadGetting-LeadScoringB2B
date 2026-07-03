import { BadRequestException } from '@nestjs/common';
import { LeadsController } from './leads.controller';
import { LeadsService } from './leads.service';
import { ScrapingJobType } from './scraping-job.entity';

describe('LeadsController', () => {
  const leadsService = {
    createScrapingJobsForLead: jest.fn(),
    generateAiAnalysis: jest.fn(),
    getLeadIntelligence: jest.fn(),
    search: jest.fn(),
  };
  const controller = new LeadsController(
    leadsService as unknown as LeadsService,
  );

  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('delegates a trimmed search query to the service', async () => {
    leadsService.search.mockResolvedValue([]);

    await expect(controller.search('  plumber  ')).resolves.toEqual([]);
    expect(leadsService.search).toHaveBeenCalledWith('plumber');
  });

  it('rejects a missing search query', () => {
    expect(() => controller.search('   ')).toThrow(BadRequestException);
  });

  it('delegates scraping job creation to the service', async () => {
    const result = {
      leadId: 'place-1',
      websiteMissing: false,
      createdJobs: [],
      skippedJobs: [],
      message: 'Created 0 scraping job(s); skipped 0 active job(s).',
    };
    leadsService.createScrapingJobsForLead.mockResolvedValue(result);

    await expect(
      controller.createScrapingJobsForLead('place-1'),
    ).resolves.toBe(result);
    expect(leadsService.createScrapingJobsForLead).toHaveBeenCalledWith(
      'place-1',
      undefined,
    );
  });

  it('passes explicit scraping job types to the service', async () => {
    const result = {
      leadId: 'place-1',
      websiteMissing: false,
      createdJobs: [],
      skippedJobs: [],
      message: 'Created 0 scraping job(s); skipped 0 active job(s).',
    };
    leadsService.createScrapingJobsForLead.mockResolvedValue(result);

    await expect(
      controller.createScrapingJobsForLead('place-1', {
        jobTypes: ['WEBSITE', 'seo'],
      }),
    ).resolves.toBe(result);
    expect(leadsService.createScrapingJobsForLead).toHaveBeenCalledWith(
      'place-1',
      [ScrapingJobType.WEBSITE, ScrapingJobType.SEO],
    );
  });

  it('rejects invalid scraping job types', () => {
    expect(() =>
      controller.createScrapingJobsForLead('place-1', {
        jobTypes: ['WEBSITE', 'UNKNOWN'],
      }),
    ).toThrow(BadRequestException);
    expect(leadsService.createScrapingJobsForLead).not.toHaveBeenCalled();
  });

  it('rejects non-array scraping job types', () => {
    expect(() =>
      controller.createScrapingJobsForLead('place-1', {
        jobTypes: 'WEBSITE',
      }),
    ).toThrow(BadRequestException);
    expect(leadsService.createScrapingJobsForLead).not.toHaveBeenCalled();
  });

  it('delegates lead intelligence lookup to the service', async () => {
    const result = {
      leadId: 'place-1',
      lead: {
        id: 'place-1',
        name: 'Demo Bakery',
        website: 'https://demo.example',
        state: 'ENRICHED',
      },
      latestAnalysis: null,
      latestRawResult: null,
    };
    leadsService.getLeadIntelligence.mockResolvedValue(result);

    await expect(controller.getLeadIntelligence('place-1')).resolves.toBe(
      result,
    );
    expect(leadsService.getLeadIntelligence).toHaveBeenCalledWith('place-1');
  });

  it('delegates live AI analysis generation to the service', async () => {
    const result = {
      status: 'success',
      leadId: 'place-1',
      generatedAt: '2026-07-03T00:00:00.000Z',
      analysis: {
        summary: 'Useful live analysis',
      },
    };
    leadsService.generateAiAnalysis.mockResolvedValue(result);

    await expect(controller.generateAiAnalysis('place-1')).resolves.toBe(
      result,
    );
    expect(leadsService.generateAiAnalysis).toHaveBeenCalledWith('place-1');
  });
});
