import {
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

@Entity({ name: 'lead_scores' })
@Index('IDX_lead_scores_lead_id', ['leadId'])
@Index('IDX_lead_scores_analysis_id', ['analysisId'])
@Index('IDX_lead_scores_period_type', ['periodType'])
export class LeadScore {
  @PrimaryGeneratedColumn({ type: 'int' })
  id: number;

  @Column({ name: 'lead_id', type: 'varchar' })
  leadId: string;

  @ManyToOne(() => Lead, (lead) => lead.scores, { nullable: false })
  @JoinColumn({
    name: 'lead_id',
    referencedColumnName: 'id',
    foreignKeyConstraintName: 'FK_lead_scores_lead_id',
  })
  lead: Lead;

  @Column({ name: 'analysis_id', type: 'int', nullable: true })
  analysisId: number | null;

  @ManyToOne(() => LeadAnalysis, (analysis) => analysis.scores, {
    nullable: true,
  })
  @JoinColumn({
    name: 'analysis_id',
    foreignKeyConstraintName: 'FK_lead_scores_analysis_id',
  })
  analysis: LeadAnalysis | null;

  @Column({ name: 'period_type', type: 'varchar', nullable: true })
  periodType: string | null;

  @Column({ name: 'digital_maturity', type: 'decimal', nullable: true })
  digitalMaturity: string | null;

  @Column({ type: 'decimal', nullable: true })
  opportunity: string | null;

  @Column({ name: 'analysis_cost', type: 'decimal', nullable: true })
  analysisCost: string | null;

  @CreateDateColumn()
  createdAt: Date;
}
