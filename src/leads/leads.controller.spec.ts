import { BadRequestException } from '@nestjs/common';
import { LeadsController } from './leads.controller';
import { LeadsService } from './leads.service';

describe('LeadsController', () => {
  const leadsService = {
    createScrapingJobsForLead: jest.fn(),
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
    );
  });
});
