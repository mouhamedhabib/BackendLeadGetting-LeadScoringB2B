import { Injectable } from '@nestjs/common';

type ExportFormat = 'csv' | 'excel' | 'pdf';
type ReportTemplateType =
  | 'opportunity'
  | 'efficiency'
  | 'alerts'
  | 'comparison'
  | 'projection';

type ReportData = {
  totalReports: number;
  scheduledReports: number;
  activeAlerts: number;
  projectionAccuracy: number;
  alertSummary: {
    critical: number;
    warning: number;
    info: number;
  };
  exportOptions: Array<{
    id: string;
    name: string;
    description: string;
    format: ExportFormat;
    estimatedSize: string;
    dataPoints: number;
  }>;
  recentExports: Array<{
    id: string;
    name: string;
    type: ExportFormat;
    date: string;
    size: string;
  }>;
  reportTemplates: Array<{
    id: string;
    name: string;
    description: string;
    type: ReportTemplateType;
    estimatedTime: string;
    dataPoints: string[];
  }>;
  leads: Array<{ id: string; name: string }>;
  leadDetails: Record<
    string,
    {
      id: string;
      name: string;
      sector: number;
      currentScore: {
        digitalMaturity: number;
        opportunity: number;
        analysisCost: number;
      };
    }
  >;
  projectionData: Array<{
    date: string;
    digitalMaturity: number;
    opportunity: number;
    cost: number;
  }>;
  projectionInsights: Array<{
    type: string;
    title: string;
    description: string;
    impact: string;
  }>;
};

const REPORT_DATA: ReportData = {
  totalReports: 12,
  scheduledReports: 3,
  activeAlerts: 3,
  projectionAccuracy: 87,
  alertSummary: {
    critical: 2,
    warning: 1,
    info: 0,
  },
  exportOptions: [
    {
      id: 'dashboard',
      name: 'Dashboard Data',
      description: 'Current KPI totals and report metrics',
      format: 'excel',
      estimatedSize: '245 KB',
      dataPoints: 156,
    },
    {
      id: 'leads',
      name: 'Lead Details',
      description: 'Lightweight lead details for reporting',
      format: 'csv',
      estimatedSize: '89 KB',
      dataPoints: 48,
    },
    {
      id: 'history',
      name: 'Opportunity History',
      description: 'Recent prospecting history for reports',
      format: 'excel',
      estimatedSize: '1.2 MB',
      dataPoints: 2160,
    },
  ],
  recentExports: [
    {
      id: 'export-001',
      name: 'Monthly Opportunity Report',
      type: 'pdf',
      date: '2026-05-08T10:00:00.000Z',
      size: '418 KB',
    },
    {
      id: 'export-002',
      name: 'Lead Details Export',
      type: 'csv',
      date: '2026-05-07T14:30:00.000Z',
      size: '92 KB',
    },
  ],
  reportTemplates: [
    {
      id: 'opportunity',
      name: 'Opportunity Report',
      description: 'Monthly opportunity per lead',
      type: 'opportunity',
      estimatedTime: '5s',
      dataPoints: ['digitalMaturity', 'opportunity', 'analysisCost'],
    },
    {
      id: 'efficiency',
      name: 'Efficiency Report',
      description: 'Compare leads against report benchmarks',
      type: 'efficiency',
      estimatedTime: '4s',
      dataPoints: ['efficiency'],
    },
    {
      id: 'alerts',
      name: 'Alert Report',
      description: 'Recent alerts and severities',
      type: 'alerts',
      estimatedTime: '3s',
      dataPoints: ['alerts'],
    },
    {
      id: 'comparison',
      name: 'Comparison Report',
      description: 'Side-by-side lead comparisons',
      type: 'comparison',
      estimatedTime: '6s',
      dataPoints: ['lead', 'opportunity'],
    },
    {
      id: 'projection',
      name: 'Projection Report',
      description: 'Opportunity projections and accuracy',
      type: 'projection',
      estimatedTime: '8s',
      dataPoints: ['projection'],
    },
  ],
  leads: [
    { id: '101', name: 'Lead 101' },
    { id: '102', name: 'Lead 102' },
    { id: '201', name: 'Lead 201' },
    { id: '202', name: 'Lead 202' },
  ],
  leadDetails: {
    '101': {
      id: '101',
      name: 'Lead 101',
      sector: 1,
      currentScore: {
        digitalMaturity: 18.4,
        opportunity: 0.42,
        analysisCost: 5.36,
      },
    },
    '102': {
      id: '102',
      name: 'Lead 102',
      sector: 1,
      currentScore: {
        digitalMaturity: 21.2,
        opportunity: 0.49,
        analysisCost: 6.19,
      },
    },
    '201': {
      id: '201',
      name: 'Lead 201',
      sector: 2,
      currentScore: {
        digitalMaturity: 16.9,
        opportunity: 0.38,
        analysisCost: 4.91,
      },
    },
    '202': {
      id: '202',
      name: 'Lead 202',
      sector: 2,
      currentScore: {
        digitalMaturity: 24.1,
        opportunity: 0.55,
        analysisCost: 7.03,
      },
    },
  },
  projectionData: [
    {
      date: '2026-05-02',
      digitalMaturity: 74.2,
      opportunity: 1.51,
      cost: 21.74,
    },
    {
      date: '2026-05-03',
      digitalMaturity: 77.9,
      opportunity: 1.63,
      cost: 22.32,
    },
    {
      date: '2026-05-04',
      digitalMaturity: 81.5,
      opportunity: 1.72,
      cost: 23.41,
    },
    {
      date: '2026-05-05',
      digitalMaturity: 79.1,
      opportunity: 1.68,
      cost: 22.85,
    },
    {
      date: '2026-05-06',
      digitalMaturity: 84.6,
      opportunity: 1.79,
      cost: 24.29,
    },
    {
      date: '2026-05-07',
      digitalMaturity: 86.3,
      opportunity: 1.84,
      cost: 24.83,
    },
    {
      date: '2026-05-08',
      digitalMaturity: 88.7,
      opportunity: 1.91,
      cost: 25.51,
    },
  ],
  projectionInsights: [
    {
      type: 'trend',
      title: 'Opportunity trend is increasing',
      description:
        'Recent report data shows a higher opportunity signal across the selected leads.',
      impact: 'medium',
    },
    {
      type: 'cost',
      title: 'Analysis cost remains stable',
      description:
        'The projected analysis cost is moving within the current reporting range.',
      impact: 'low',
    },
  ],
};

@Injectable()
export class ReportsService {
  getReports(): ReportData {
    return structuredClone(REPORT_DATA);
  }
}
