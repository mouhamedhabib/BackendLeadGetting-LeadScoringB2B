import { BadRequestException } from '@nestjs/common';
import { LeadsController } from './leads.controller';
import { LeadsService } from './leads.service';

describe('LeadsController', () => {
  const leadsService = {
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
});
