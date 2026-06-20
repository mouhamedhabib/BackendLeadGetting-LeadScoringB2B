import { Injectable, NotFoundException } from '@nestjs/common';

/** Analysis modules used to split scores in the breakdown response. */
const ANALYSIS_MODULES = [
  'GMBAnalysis',
  'WebsiteAnalysis',
  'SEOAnalysis',
  'SocialAnalysis',
] as const;

type TimelinePoint = {
  date: string;
  digitalMaturity: number;
  opportunity: number;
  cost: number;
};

type BreakdownItem = {
  category: string;
  opportunity: number;
  percentage: number;
};

@Injectable()
export class LeadsService {
  findAll() {
    return [
      {
        id: '101',
        name: 'Dental Center',
        status: 'normal',
        alerts: 0,
        currentScore: {
          digitalMaturity: 12,
          opportunity: 0.34,
          analysisCost: 45,
        },
        monthlyScore: {
          digitalMaturity: 120,
          opportunity: 3.2,
          analysisCost: 400,
        },
        contacts: [
          {
            name: 'John Doe',
            email: 'john.doe@example.com',
            phone: '+216 53 012 345',
            moveInDate: '2024-11-08',
          },
        ],
        lastUpdated: new Date(),
      },
      {
        id: '102',
        name: 'Dental Center',
        status: 'warning',
        alerts: 2,
        currentScore: {
          digitalMaturity: 18,
          opportunity: 0.56,
          analysisCost: 62,
        },
        monthlyScore: {
          digitalMaturity: 145,
          opportunity: 4.1,
          analysisCost: 520,
        },
        contacts: [
          {
            name: 'Ahmed Ben Ali',
            email: 'ahmed@example.com',
            phone: '+216 53 012 345',
            moveInDate: '2024-11-08',
          },
        ],
        lastUpdated: new Date(),
      },
      {
        id: '103',
        name: 'Smile Clinic',
        status: 'critical',
        alerts: 5,
        currentScore: {
          digitalMaturity: 8,
          opportunity: 0.12,
          analysisCost: 25,
        },
        monthlyScore: {
          digitalMaturity: 80,
          opportunity: 1.4,
          analysisCost: 210,
        },
        contacts: [
          {
            name: 'Sara Khaled',
            email: 'sara@smileclinic.com',
            moveInDate: '2025-01-15',
          },
          {
            name: 'Mohamed Trabelsi',
            email: 'm.trabelsi@smileclinic.com',
            phone: '+216 22 456 789',
            moveInDate: '2025-06-02',
          },
        ],
        lastUpdated: new Date(),
      },
      {
        id: '104',
        name: 'Bright Dental',
        status: 'normal',
        alerts: 1,
        currentScore: {
          digitalMaturity: 25,
          opportunity: 0.72,
          analysisCost: 85,
        },
        monthlyScore: {
          digitalMaturity: 190,
          opportunity: 6.5,
          analysisCost: 740,
        },
        contacts: [
          {
            name: 'Leila Mansour',
            email: 'leila@brightdental.com',
            phone: '+216 98 765 432',
            moveInDate: '2023-09-20',
          },
        ],
        lastUpdated: new Date(),
      },
    ];
  }

  /** Returns a single lead or throws when the id is unknown. */
  findOne(id: string) {
    const lead = this.findAll().find((item) => item.id === id);
    if (!lead) {
      throw new NotFoundException(`Lead with id "${id}" not found`);
    }
    return lead;
  }

  /**
   * Builds 30 daily timeline points ending today. Values ramp from ~70% of
   * current scores toward today's snapshot, with a deterministic ±10% wobble
   * derived from a string hash of lead id + day index (no Math.random()).
   */
  getTimeline(id: string): TimelinePoint[] {
    const lead = this.findOne(id);
    const { digitalMaturity, opportunity, analysisCost } = lead.currentScore;
    const points: TimelinePoint[] = [];
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    for (let dayIndex = 0; dayIndex < 30; dayIndex++) {
      const date = new Date(today);
      date.setDate(today.getDate() - (29 - dayIndex));
      const dateStr = this.formatLocalDate(date);

      // Progress 0→1 over the window; last day equals currentScore exactly.
      const progress = dayIndex / 29;
      const wobble = (this.deterministicFactor(id, dayIndex) - 0.5) * 0.2;

      if (dayIndex === 29) {
        points.push({
          date: dateStr,
          digitalMaturity,
          opportunity,
          cost: analysisCost,
        });
        continue;
      }

      const maturityBase = digitalMaturity * (0.7 + 0.3 * progress);
      const opportunityBase = opportunity * (0.7 + 0.3 * progress);
      const costBase = analysisCost * (0.7 + 0.3 * progress);

      points.push({
        date: dateStr,
        digitalMaturity: Math.max(
          0,
          Math.round(maturityBase * (1 + wobble)),
        ),
        opportunity: Math.max(
          0,
          Math.round(opportunityBase * (1 + wobble) * 100) / 100,
        ),
        cost: Math.max(0, Math.round(costBase * (1 + wobble))),
      });
    }

    return points;
  }

  /**
   * Splits current digital-maturity and opportunity scores across the four
   * analysis modules. Percentages are normalized to sum to exactly 100.
   */
  getBreakdown(id: string): {
    digitalMaturity: BreakdownItem[];
    opportunity: BreakdownItem[];
  } {
    const lead = this.findOne(id);

    return {
      digitalMaturity: this.buildModuleBreakdown(
        id,
        'maturity',
        lead.currentScore.digitalMaturity,
      ),
      opportunity: this.buildModuleBreakdown(
        id,
        'opportunity',
        lead.currentScore.opportunity,
      ),
    };
  }

  /**
   * Maps a total score into per-module rows. Raw weights come from a
   * deterministic hash; percentages are scaled so they always total 100.
   */
  private buildModuleBreakdown(
    id: string,
    scoreType: string,
    total: number,
  ): BreakdownItem[] {
    const rawWeights = ANALYSIS_MODULES.map((_, index) =>
      this.deterministicFactor(`${id}-${scoreType}`, index),
    );
    const weightSum = rawWeights.reduce((sum, w) => sum + w, 0);

    // Percentages must sum to 100 — allocate remainder to the largest slice.
    const percentages = rawWeights.map(
      (w) => Math.floor((w / weightSum) * 1000) / 10,
    );
    const percentageTotal = percentages.reduce((sum, p) => sum + p, 0);
    const remainder = Math.round((100 - percentageTotal) * 10) / 10;
    const maxIndex = percentages.indexOf(Math.max(...percentages));
    percentages[maxIndex] = Math.round((percentages[maxIndex] + remainder) * 10) / 10;

    return ANALYSIS_MODULES.map((category, index) => ({
      category,
      percentage: percentages[index],
      opportunity: Math.round(total * (percentages[index] / 100) * 100) / 100,
    }));
  }

  /** Stable 0–1 factor from a string key; same input always yields same output. */
  private deterministicFactor(key: string, salt = 0): number {
    const input = `${key}:${salt}`;
    let hash = 0;
    for (let i = 0; i < input.length; i++) {
      hash = (hash * 31 + input.charCodeAt(i)) >>> 0;
    }
    return (hash % 1000) / 1000;
  }

  /** YYYY-MM-DD in local time — avoids UTC shift from toISOString(). */
  private formatLocalDate(date: Date): string {
    const year = date.getFullYear();
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const day = String(date.getDate()).padStart(2, '0');
    return `${year}-${month}-${day}`;
  }
}
