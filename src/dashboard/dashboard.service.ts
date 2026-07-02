import { BadRequestException, Injectable } from '@nestjs/common';

type StatusTone = 'healthy' | 'warning' | 'critical' | 'stable';

type DashboardKpi = {
  title: string;
  value: string;
  description: string;
  target: string;
  status: string;
  statusTone: StatusTone;
  decisionHint: string;
  operationalUse: string;
  icon: string;
  color: 'primary' | 'chart-1' | 'chart-2' | 'chart-3' | 'accent';
};

type RealtimePoint = {
  time: string;
  digitalMaturity: number;
  opportunity: number;
  analysisCost: number;
};

type DashboardAlert = {
  id: string;
  type: 'warning' | 'error' | 'info';
  message: string;
  timestamp: string;
};

/** Domain-specific alert templates; timestamps are placed within the requested range. */
const ALERT_TEMPLATES: Array<Omit<DashboardAlert, 'timestamp'>> = [
  {
    id: 'alert-quota',
    type: 'warning',
    message:
      'Google Places API quota at 82% — enrichment runs may throttle within 6 hours.',
  },
  {
    id: 'alert-validation',
    type: 'error',
    message:
      'Scoring validation failed for 3 leads in batch #1847 — opportunity band mismatch.',
  },
  {
    id: 'alert-worker',
    type: 'warning',
    message:
      'BullMQ worker queue depth elevated — average job wait time exceeds 90 seconds.',
  },
  {
    id: 'alert-critical-band',
    type: 'info',
    message:
      'Lead #103 moved into the critical opportunity band (0–25) after re-scoring.',
  },
  {
    id: 'alert-enrichment',
    type: 'info',
    message:
      'WebsiteAnalysis module completed enrichment for 12 leads in the current window.',
  },
  {
    id: 'alert-pipeline',
    type: 'error',
    message:
      '2 leads stuck in FAILED state — normalization step rejected malformed contact data.',
  },
];

@Injectable()
export class DashboardService {
  /**
   * Returns KPI cards, time-series chart data, and pipeline alerts for the
   * executive dashboard. All values are deterministic in-memory mocks until
   * real metrics collection is wired up.
   */
  getDashboardData(startDate: string, endDate: string) {
    this.validateDateRange(startDate, endDate);

    return {
      kpis: this.getStaticKpis(),
      realtimeData: this.buildRealtimeData(startDate, endDate),
      alerts: this.buildAlerts(startDate, endDate),
    };
  }

  /** Rejects missing or inverted date ranges before any mock data is built. */
  private validateDateRange(startDate: string, endDate: string): void {
    if (!startDate || !endDate) {
      throw new BadRequestException(
        'Both start_date and end_date query parameters are required.',
      );
    }

    const start = this.parseDate(startDate);
    const end = this.parseDate(endDate);

    if (start > end) {
      throw new BadRequestException('start_date must not be after end_date.');
    }
  }

  /**
   * Static KPI placeholders — values mirror the former frontend hardcoding and
   * will be replaced once real session, scoring, and quota metrics exist.
   */
  private getStaticKpis(): DashboardKpi[] {
    return [
      {
        title: 'Average Session Processing Time',
        value: '4.2 min',
        description: 'Mean time from search launch to scored lead set.',
        target: '< 5 min',
        status: 'Healthy',
        statusTone: 'healthy',
        decisionHint:
          'Scale BullMQ workers or optimize API calls when latency rises.',
        operationalUse:
          'Monitor processing speed across active prospecting sessions.',
        icon: 'Timer',
        color: 'primary',
      },
      {
        title: 'Scoring Integrity Rate',
        value: '72%',
        description:
          'Share of scoring checks passing deterministic validation.',
        target: '>= 70%',
        status: 'Stable',
        statusTone: 'stable',
        decisionHint: 'Recalibrate scoring weights when consistency drops.',
        operationalUse: 'Track score consistency and test coverage readiness.',
        icon: 'ShieldCheck',
        color: 'chart-2',
      },
      {
        title: 'Critical Lead Ratio',
        value: '18%',
        description: 'Leads currently grouped in the 0-25 opportunity band.',
        target: '0-25 score band',
        status: 'Warning',
        statusTone: 'warning',
        decisionHint:
          'Adjust target sectors or geographic areas if the pool weakens.',
        operationalUse:
          'Measure concentration of high-priority outreach targets.',
        icon: 'AlertTriangle',
        color: 'chart-1',
      },
      {
        title: 'API Quota Utilization Rate',
        value: '64%',
        description:
          'Current consumption pressure for external data collection.',
        target: '< 80%',
        status: 'Healthy',
        statusTone: 'healthy',
        decisionHint:
          'Adjust consumption strategy before Google API limits constrain runs.',
        operationalUse: 'Monitor quota usage during lead discovery windows.',
        icon: 'Gauge',
        color: 'chart-3',
      },
      {
        title: 'Status Update Frequency',
        value: '18 / hr',
        description: 'Pipeline stage updates emitted for active lead records.',
        target: '>= 12 / hr',
        status: 'Stable',
        statusTone: 'stable',
        decisionHint: 'Improve follow-up workflow when progression slows.',
        operationalUse:
          'Monitor movement through RAW, NORMALIZED, ENRICHED, SCORED, and FAILED states.',
        icon: 'RefreshCw',
        color: 'accent',
      },
    ];
  }

  /**
   * Builds chart points between startDate and endDate. Ranges spanning one
   * calendar day or less use hourly buckets (~24–48 points); longer ranges
   * use one daily point per day to keep the chart readable.
   */
  private buildRealtimeData(
    startDate: string,
    endDate: string,
  ): RealtimePoint[] {
    const start = this.parseDate(startDate);
    const end = this.parseDate(endDate);
    const daySpan = Math.round((end.getTime() - start.getTime()) / 86_400_000);
    const useHourly = daySpan <= 1;

    const points: RealtimePoint[] = [];

    if (useHourly) {
      const rangeStart = new Date(start);
      rangeStart.setHours(0, 0, 0, 0);
      const rangeEnd = new Date(end);
      rangeEnd.setHours(23, 0, 0, 0);

      const cursor = new Date(rangeStart);
      let index = 0;
      while (cursor <= rangeEnd) {
        points.push(
          this.buildRealtimePoint(startDate, endDate, index, cursor, true),
        );
        cursor.setHours(cursor.getHours() + 1);
        index += 1;
      }
      return points;
    }

    const cursor = new Date(start);
    cursor.setHours(0, 0, 0, 0);
    let index = 0;
    while (cursor <= end) {
      points.push(
        this.buildRealtimePoint(startDate, endDate, index, cursor, false),
      );
      cursor.setDate(cursor.getDate() + 1);
      index += 1;
    }
    return points;
  }

  /** Derives one chart row from a deterministic hash keyed by range + bucket index. */
  private buildRealtimePoint(
    startDate: string,
    endDate: string,
    index: number,
    date: Date,
    hourly: boolean,
  ): RealtimePoint {
    const bucketKey = hourly
      ? `${startDate}:${endDate}:${index}:${date.toISOString()}`
      : `${startDate}:${endDate}:${index}:${this.formatLocalDate(date)}`;

    const maturityBase = 35 + this.deterministicFactor(bucketKey, 0) * 45;
    const opportunityBase = 40 + this.deterministicFactor(bucketKey, 1) * 35;
    const costBase = 45 + this.deterministicFactor(bucketKey, 2) * 120;
    const wobble = (this.deterministicFactor(bucketKey, 3) - 0.5) * 0.12;

    return {
      time: hourly ? date.toISOString() : this.formatLocalDate(date),
      digitalMaturity: Math.round(maturityBase * (1 + wobble)),
      opportunity: Math.round(opportunityBase * (1 + wobble)),
      analysisCost: Math.round(costBase * (1 + wobble)),
    };
  }

  /**
   * Picks 3–6 alerts deterministically and assigns timestamps spread across
   * the requested window so they are not all pinned to "now".
   */
  private buildAlerts(startDate: string, endDate: string): DashboardAlert[] {
    const startMs = this.parseDate(startDate).getTime();
    const endMs = this.parseDate(endDate).getTime() + 86_399_999;
    const count =
      3 +
      Math.floor(this.deterministicFactor(`${startDate}:${endDate}`, 99) * 4);

    return ALERT_TEMPLATES.slice(0, count).map((template, index) => {
      const ratio = this.deterministicFactor(
        `${startDate}:${endDate}:alert`,
        index,
      );
      const timestampMs = Math.round(startMs + ratio * (endMs - startMs));
      return {
        ...template,
        timestamp: new Date(timestampMs).toISOString(),
      };
    });
  }

  /** Parses YYYY-MM-DD into a local-midnight Date; throws on invalid input. */
  private parseDate(value: string): Date {
    if (!/^\d{4}-\d{2}-\d{2}$/.test(value)) {
      throw new BadRequestException(
        `Invalid date format "${value}" — expected YYYY-MM-DD.`,
      );
    }
    const date = new Date(`${value}T00:00:00`);
    if (Number.isNaN(date.getTime())) {
      throw new BadRequestException(`Invalid date "${value}".`);
    }
    return date;
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
