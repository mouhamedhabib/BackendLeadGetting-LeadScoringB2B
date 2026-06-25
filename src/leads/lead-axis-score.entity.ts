import {
  Check,
  Column,
  CreateDateColumn,
  Entity,
  Index,
  JoinColumn,
  ManyToOne,
  PrimaryGeneratedColumn,
} from 'typeorm';
import { LeadAnalysis } from './lead-analysis.entity';
import { Lead } from './lead.entity';

export enum LeadScoreAxis {
  GMB = 'GMB',
  WEBSITE = 'WEBSITE',
  SEO = 'SEO',
  SOCIAL = 'SOCIAL',
}

export enum AxisScoreType {
  DIGITAL_MATURITY = 'digital_maturity',
  OPPORTUNITY = 'opportunity',
}

@Entity({ name: 'lead_axis_scores' })
@Index('IDX_lead_axis_scores_lead_id', ['leadId'])
@Index('IDX_lead_axis_scores_analysis_id', ['analysisId'])
@Index('IDX_lead_axis_scores_axis', ['axis'])
@Index('IDX_lead_axis_scores_score_type', ['scoreType'])
@Check(
  'CHK_lead_axis_scores_axis',
  `"axis" IN ('GMB', 'WEBSITE', 'SEO', 'SOCIAL')`,
)
@Check(
  'CHK_lead_axis_scores_score_type',
  `"score_type" IN ('digital_maturity', 'opportunity')`,
)
export class LeadAxisScore {
  @PrimaryGeneratedColumn({ type: 'int' })
  id: number;

  @Column({ name: 'lead_id', type: 'varchar' })
  leadId: string;

  @ManyToOne(() => Lead, (lead) => lead.axisScores, { nullable: false })
  @JoinColumn({
    name: 'lead_id',
    referencedColumnName: 'id',
    foreignKeyConstraintName: 'FK_lead_axis_scores_lead_id',
  })
  lead: Lead;

  @Column({ name: 'analysis_id', type: 'int', nullable: true })
  analysisId: number | null;

  @ManyToOne(() => LeadAnalysis, (analysis) => analysis.axisScores, {
    nullable: true,
  })
  @JoinColumn({
    name: 'analysis_id',
    foreignKeyConstraintName: 'FK_lead_axis_scores_analysis_id',
  })
  analysis: LeadAnalysis | null;

  @Column({ type: 'varchar' })
  axis: LeadScoreAxis;

  @Column({ type: 'decimal', nullable: true })
  score: string | null;

  @Column({ type: 'decimal', nullable: true })
  weight: string | null;

  @Column({ name: 'weighted_score', type: 'decimal', nullable: true })
  weightedScore: string | null;

  @Column({ name: 'is_available', type: 'boolean', default: true })
  isAvailable: boolean;

  @Column({ name: 'score_type', type: 'varchar' })
  scoreType: AxisScoreType;

  @CreateDateColumn()
  createdAt: Date;
}
