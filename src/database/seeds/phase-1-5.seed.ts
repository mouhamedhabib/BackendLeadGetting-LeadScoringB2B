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

const historicalScoreDates = [
  '2026-06-01',
  '2026-06-02',
  '2026-06-03',
  '2026-06-04',
  '2026-06-05',
  '2026-06-06',
  '2026-06-07',
  '2026-06-08',
  '2026-06-09',
  '2026-06-10',
  '2026-06-11',
  '2026-06-12',
  '2026-06-13',
  '2026-06-14',
  '2026-06-15',
  '2026-06-16',
  '2026-06-17',
  '2026-06-18',
  '2026-06-19',
  '2026-06-20',
  '2026-06-21',
  '2026-06-22',
  '2026-06-23',
  '2026-06-24',
  '2026-06-25',
  '2026-06-26',
  '2026-06-27',
  '2026-06-28',
  '2026-06-29',
  '2026-06-30',
] as const;

type DailyScoreProfile = {
  digitalMaturity: readonly [start: number, end: number];
  opportunity: readonly [start: number, end: number];
  analysisCost: readonly [start: number, end: number];
};

// Static demo profiles only. They do not invoke or reproduce scoring rules.
const dailyScoreProfiles: DailyScoreProfile[] = [
  {
    digitalMaturity: [42, 57],
    opportunity: [38, 64],
    analysisCost: [5, 7.9],
  },
  {
    digitalMaturity: [35, 49],
    opportunity: [45, 70],
    analysisCost: [4, 6.9],
  },
  {
    digitalMaturity: [60, 75],
    opportunity: [30, 48],
    analysisCost: [6, 8.9],
  },
];

function interpolateDailyValue(
  [start, end]: readonly [number, number],
  dayIndex: number,
): string {
  const progress = dayIndex / (historicalScoreDates.length - 1);
  return (start + (end - start) * progress).toFixed(2);
}

type AxisScoreSample = {
  axis: 'GMB' | 'WEBSITE' | 'SEO' | 'SOCIAL';
  scoreType: 'digital_maturity' | 'opportunity';
  score: string | null;
  weight: string;
  weightedScore: string | null;
  isAvailable: boolean;
};

// Static demo data only. These values are not produced by scoring rules.
const axisScoreSamples: AxisScoreSample[][] = [
  [
    {
      axis: 'GMB',
      scoreType: 'digital_maturity',
      score: '70',
      weight: '0.2',
      weightedScore: '14',
      isAvailable: true,
    },
    {
      axis: 'WEBSITE',
      scoreType: 'digital_maturity',
      score: '55',
      weight: '0.35',
      weightedScore: '19.25',
      isAvailable: true,
    },
    {
      axis: 'SEO',
      scoreType: 'digital_maturity',
      score: '40',
      weight: '0.25',
      weightedScore: '10',
      isAvailable: true,
    },
    {
      axis: 'SOCIAL',
      scoreType: 'digital_maturity',
      score: null,
      weight: '0.2',
      weightedScore: null,
      isAvailable: false,
    },
    {
      axis: 'GMB',
      scoreType: 'opportunity',
      score: '30',
      weight: '0.2',
      weightedScore: '6',
      isAvailable: true,
    },
    {
      axis: 'WEBSITE',
      scoreType: 'opportunity',
      score: '65',
      weight: '0.35',
      weightedScore: '22.75',
      isAvailable: true,
    },
    {
      axis: 'SEO',
      scoreType: 'opportunity',
      score: '60',
      weight: '0.25',
      weightedScore: '15',
      isAvailable: true,
    },
    {
      axis: 'SOCIAL',
      scoreType: 'opportunity',
      score: null,
      weight: '0.2',
      weightedScore: null,
      isAvailable: false,
    },
  ],
  [
    {
      axis: 'GMB',
      scoreType: 'digital_maturity',
      score: '62',
      weight: '0.2',
      weightedScore: '12.4',
      isAvailable: true,
    },
    {
      axis: 'WEBSITE',
      scoreType: 'digital_maturity',
      score: '68',
      weight: '0.35',
      weightedScore: '23.8',
      isAvailable: true,
    },
    {
      axis: 'SEO',
      scoreType: 'digital_maturity',
      score: '52',
      weight: '0.25',
      weightedScore: '13',
      isAvailable: true,
    },
    {
      axis: 'SOCIAL',
      scoreType: 'digital_maturity',
      score: '45',
      weight: '0.2',
      weightedScore: '9',
      isAvailable: true,
    },
    {
      axis: 'GMB',
      scoreType: 'opportunity',
      score: '38',
      weight: '0.2',
      weightedScore: '7.6',
      isAvailable: true,
    },
    {
      axis: 'WEBSITE',
      scoreType: 'opportunity',
      score: '32',
      weight: '0.35',
      weightedScore: '11.2',
      isAvailable: true,
    },
    {
      axis: 'SEO',
      scoreType: 'opportunity',
      score: '48',
      weight: '0.25',
      weightedScore: '12',
      isAvailable: true,
    },
    {
      axis: 'SOCIAL',
      scoreType: 'opportunity',
      score: '55',
      weight: '0.2',
      weightedScore: '11',
      isAvailable: true,
    },
  ],
  [
    {
      axis: 'GMB',
      scoreType: 'digital_maturity',
      score: '82',
      weight: '0.2',
      weightedScore: '16.4',
      isAvailable: true,
    },
    {
      axis: 'WEBSITE',
      scoreType: 'digital_maturity',
      score: '76',
      weight: '0.35',
      weightedScore: '26.6',
      isAvailable: true,
    },
    {
      axis: 'SEO',
      scoreType: 'digital_maturity',
      score: '71',
      weight: '0.25',
      weightedScore: '17.75',
      isAvailable: true,
    },
    {
      axis: 'SOCIAL',
      scoreType: 'digital_maturity',
      score: null,
      weight: '0.2',
      weightedScore: null,
      isAvailable: false,
    },
    {
      axis: 'GMB',
      scoreType: 'opportunity',
      score: '18',
      weight: '0.2',
      weightedScore: '3.6',
      isAvailable: true,
    },
    {
      axis: 'WEBSITE',
      scoreType: 'opportunity',
      score: '24',
      weight: '0.35',
      weightedScore: '8.4',
      isAvailable: true,
    },
    {
      axis: 'SEO',
      scoreType: 'opportunity',
      score: '29',
      weight: '0.25',
      weightedScore: '7.25',
      isAvailable: true,
    },
    {
      axis: 'SOCIAL',
      scoreType: 'opportunity',
      score: null,
      weight: '0.2',
      weightedScore: null,
      isAvailable: false,
    },
  ],
];

async function seed(): Promise<void> {
  await dataSource.initialize();
  const queryRunner = dataSource.createQueryRunner();
  await queryRunner.connect();
  await queryRunner.startTransaction();

  try {
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
           'phase-1.5-demo', 'RAW', now(), now())
         ON CONFLICT (google_place_id) DO NOTHING`,
      seedLeadIds,
    );

    const leads = (await queryRunner.query(
      `SELECT google_place_id
       FROM leads
       WHERE google_place_id = ANY($1::varchar[])
       ORDER BY array_position($1::varchar[], google_place_id)`,
      [seedLeadIds],
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
       FROM (
         SELECT DISTINCT ON (lead_id) id, lead_id
         FROM lead_analysis
         WHERE analysis_status = 'SEEDED'
           AND lead_id = ANY($1::varchar[])
         ORDER BY lead_id, id DESC
       ) latest_analysis
       ORDER BY array_position($1::varchar[], lead_id)`,
      [seedLeadIds],
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
             opportunity, analysis_cost, score_date, "createdAt")
           SELECT $1::varchar, $2::int, $3::varchar, $4::decimal,
                  $5::decimal, $6::decimal, CURRENT_DATE, now()
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

      for (const [dayIndex, scoreDate] of historicalScoreDates.entries()) {
        const profile = dailyScoreProfiles[index];
        const digitalMaturity = interpolateDailyValue(
          profile.digitalMaturity,
          dayIndex,
        );
        const opportunity = interpolateDailyValue(
          profile.opportunity,
          dayIndex,
        );
        const analysisCost = interpolateDailyValue(
          profile.analysisCost,
          dayIndex,
        );

        await queryRunner.query(
          `WITH updated AS (
             UPDATE lead_scores
             SET analysis_id = $2::int,
                 digital_maturity = $4::decimal,
                 opportunity = $5::decimal,
                 analysis_cost = $6::decimal
             WHERE lead_id = $1::varchar
               AND period_type = 'daily'
               AND score_date = $3::date
             RETURNING id
           )
           INSERT INTO lead_scores
            (lead_id, analysis_id, period_type, score_date,
             digital_maturity, opportunity, analysis_cost, "createdAt")
           SELECT $1::varchar, $2::int, 'daily', $3::date,
                  $4::decimal, $5::decimal, $6::decimal, now()
           WHERE NOT EXISTS (SELECT 1 FROM updated)`,
          [
            analysis.lead_id,
            analysis.id,
            scoreDate,
            digitalMaturity,
            opportunity,
            analysisCost,
          ],
        );
      }

      for (const axisScore of axisScoreSamples[index]) {
        await queryRunner.query(
          `WITH updated AS (
             UPDATE lead_axis_scores
             SET score = $5::decimal,
                 weight = $6::decimal,
                 weighted_score = $7::decimal,
                 is_available = $8::boolean
             WHERE lead_id = $1::varchar
               AND analysis_id = $2::int
               AND axis = $3::varchar
               AND score_type = $4::varchar
             RETURNING id
           )
           INSERT INTO lead_axis_scores
            (lead_id, analysis_id, axis, score_type, score, weight,
             weighted_score, is_available, "createdAt")
           SELECT $1::varchar, $2::int, $3::varchar, $4::varchar,
                  $5::decimal, $6::decimal, $7::decimal, $8::boolean, now()
           WHERE NOT EXISTS (SELECT 1 FROM updated)`,
          [
            analysis.lead_id,
            analysis.id,
            axisScore.axis,
            axisScore.scoreType,
            axisScore.score,
            axisScore.weight,
            axisScore.weightedScore,
            axisScore.isAvailable,
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
