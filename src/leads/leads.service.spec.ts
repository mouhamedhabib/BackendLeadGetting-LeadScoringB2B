import { NotFoundException, ServiceUnavailableException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { Repository } from 'typeorm';
import { Lead, LeadState } from './lead.entity';
import { LeadsService } from './leads.service';

describe('LeadsService', () => {
  let service: LeadsService;
  let repository: {
    find: jest.Mock;
    findOneBy: jest.Mock;
    upsert: jest.Mock;
    findBy: jest.Mock;
  };
  let configService: { get: jest.Mock };

  beforeEach(() => {
    repository = {
      find: jest.fn(),
      findOneBy: jest.fn(),
      upsert: jest.fn(),
      findBy: jest.fn(),
    };
    configService = {
      get: jest.fn().mockReturnValue('test-api-key'),
    };
    service = new LeadsService(
      repository as unknown as Repository<Lead>,
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
  });

  it('throws when a DB-backed lead does not exist', async () => {
    repository.findOneBy.mockResolvedValue(null);

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
      state: LeadState.RAW,
    } as Lead;
    repository.findBy.mockResolvedValue([savedLead]);

    await expect(service.search('plumber')).resolves.toEqual([savedLead]);
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

  it('keeps the deterministic timeline mock available', async () => {
    await expect(service.getTimeline('101')).resolves.toHaveLength(30);
  });

  it('returns safe optional detail data for a DB-backed lead', async () => {
    repository.findOneBy.mockResolvedValue({ id: 'place-1' });

    await expect(service.getTimeline('place-1')).resolves.toEqual([]);
    await expect(service.getBreakdown('place-1')).resolves.toEqual({
      digitalMaturity: [],
      opportunity: [],
    });
  });

  it('keeps a real 404 for optional detail data when the lead does not exist', async () => {
    repository.findOneBy.mockResolvedValue(null);

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
