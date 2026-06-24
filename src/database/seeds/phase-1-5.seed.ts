import dataSource from '../data-source';

type LeadRow = { google_place_id: string };
type AnalysisRow = { id: number; lead_id: string };

const seedLeadIds = [
  'phase-1-5-demo-bakery',
  'phase-1-5-demo-plumber',
  'phase-1-5-demo-agency',
];

const scoreSamples = [
  {
    current: ['32.00', '68.00', '1.20'],
    monthly: ['38.00', '62.00', '4.80'],
  },
  {
    current: ['51.00', '49.00', '1.50'],
    monthly: ['55.00', '45.00', '5.25'],
  },
  {
    current: ['74.00', '26.00', '1.10'],
    monthly: ['70.00', '30.00', '4.40'],
  },
];

async function seed(): Promise<void> {
  await dataSource.initialize();
  const queryRunner = dataSource.createQueryRunner();
  await queryRunner.connect();
  await queryRunner.startTransaction();

  try {
    const [{ count }] = (await queryRunner.query(
      'SELECT COUNT(*)::int AS count FROM leads',
    )) as Array<{ count: number }>;

    if (count === 0) {
      await queryRunner.query(
        `INSERT INTO leads
          (google_place_id, name, address, phone, website, rating,
           "userRatingsTotal", lat, lng, "searchQuery", state,
           "createdAt", "lastUpdated")
         VALUES
          ($1, 'Demo Bakery', '1 Seed Street', NULL, NULL, 4.2, 18,
           36.8065, 10.1815, 'phase-1.5-demo', 'RAW', now(), now()),
          ($2, 'Demo Plumber', '2 Seed Street', '+216 00 000 002',
           'https://example.test/plumber', 4.6, 31, 36.8120, 10.1760,
           'phase-1.5-demo', 'RAW', now(), now()),
          ($3, 'Demo Agency', '3 Seed Street', NULL,
           'https://example.test/agency', NULL, NULL, 36.8000, 10.1900,
           'phase-1.5-demo', 'RAW', now(), now())`,
        seedLeadIds,
      );
    }

    const leads = (await queryRunner.query(
      `SELECT google_place_id
       FROM leads
       ORDER BY "createdAt", google_place_id
       LIMIT 3`,
    )) as LeadRow[];

    for (const [index, lead] of leads.entries()) {
      await queryRunner.query(
        `INSERT INTO lead_contacts
          (lead_id, name, email, phone, source, "createdAt")
         SELECT $1::varchar, $2::varchar, $3::varchar, $4::varchar,
                'phase-1.5-seed', now()
         WHERE NOT EXISTS (
           SELECT 1 FROM lead_contacts
           WHERE lead_id = $1 AND source = 'phase-1.5-seed'
         )`,
        [
          lead.google_place_id,
          `Demo Contact ${index + 1}`,
          index === 0 ? 'demo@example.test' : null,
          index === 1 ? '+216 00 000 102' : null,
        ],
      );

      await queryRunner.query(
        `INSERT INTO lead_analysis
          (lead_id, website_url, has_website, has_ssl, has_facebook,
           has_instagram, seo_title, seo_description, mobile_friendly,
           performance_score, analysis_status, analyzed_at)
         SELECT $1::varchar, $2::varchar, $3::boolean, $4::boolean,
                $5::boolean, $6::boolean, $7::varchar, NULL::varchar,
                $8::boolean, $9::int, 'SEEDED', now()
         WHERE NOT EXISTS (
           SELECT 1 FROM lead_analysis
           WHERE lead_id = $1 AND analysis_status = 'SEEDED'
         )`,
        [
          lead.google_place_id,
          index === 0 ? null : `https://example.test/demo-${index + 1}`,
          index !== 0,
          index !== 0,
          index === 1,
          false,
          index === 0 ? null : `Demo title ${index + 1}`,
          index === 2,
          index === 0 ? null : 70 + index,
        ],
      );
    }

    const analyses = (await queryRunner.query(
      `SELECT id, lead_id
       FROM lead_analysis
       WHERE analysis_status = 'SEEDED'
       ORDER BY id`,
    )) as AnalysisRow[];

    for (const [index, analysis] of analyses.entries()) {
      for (const periodType of ['current', 'monthly']) {
        const [digitalMaturity, opportunity, analysisCost] =
          scoreSamples[index % scoreSamples.length][
            periodType as 'current' | 'monthly'
          ];

        await queryRunner.query(
          `WITH updated AS (
             UPDATE lead_scores
             SET digital_maturity = $4::decimal,
                 opportunity = $5::decimal,
                 analysis_cost = $6::decimal
             WHERE lead_id = $1::varchar
               AND analysis_id = $2::int
               AND period_type = $3::varchar
             RETURNING id
           )
           INSERT INTO lead_scores
            (lead_id, analysis_id, period_type, digital_maturity,
             opportunity, analysis_cost, "createdAt")
           SELECT $1::varchar, $2::int, $3::varchar, $4::decimal,
                  $5::decimal, $6::decimal, now()
           WHERE NOT EXISTS (SELECT 1 FROM updated)`,
          [
            analysis.lead_id,
            analysis.id,
            periodType,
            digitalMaturity,
            opportunity,
            analysisCost,
          ],
        );
      }
    }

    await queryRunner.commitTransaction();
  } catch (error) {
    await queryRunner.rollbackTransaction();
    throw error;
  } finally {
    await queryRunner.release();
    await dataSource.destroy();
  }
}

void seed().catch((error: unknown) => {
  console.error('Phase 1.5 seed failed', error);
  process.exitCode = 1;
});
