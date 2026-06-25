import {
  Column,
  Entity,
  Index,
  JoinColumn,
  ManyToOne,
  OneToMany,
  PrimaryGeneratedColumn,
} from 'typeorm';
import { Lead } from './lead.entity';
import { LeadScore } from './lead-score.entity';
import { LeadAxisScore } from './lead-axis-score.entity';

@Entity({ name: 'lead_analysis' })
@Index('IDX_lead_analysis_lead_id', ['leadId'])
export class LeadAnalysis {
  @PrimaryGeneratedColumn({ type: 'int' })
  id: number;

  @Column({ name: 'lead_id', type: 'varchar' })
  leadId: string;

  @ManyToOne(() => Lead, (lead) => lead.analyses, { nullable: false })
  @JoinColumn({
    name: 'lead_id',
    referencedColumnName: 'id',
    foreignKeyConstraintName: 'FK_lead_analysis_lead_id',
  })
  lead: Lead;

  @Column({ name: 'website_url', type: 'varchar', nullable: true })
  websiteUrl: string | null;

  @Column({ name: 'has_website', type: 'boolean', nullable: true })
  hasWebsite: boolean | null;

  @Column({ name: 'has_ssl', type: 'boolean', nullable: true })
  hasSsl: boolean | null;

  @Column({ name: 'has_facebook', type: 'boolean', nullable: true })
  hasFacebook: boolean | null;

  @Column({ name: 'has_instagram', type: 'boolean', nullable: true })
  hasInstagram: boolean | null;

  @Column({ name: 'seo_title', type: 'varchar', nullable: true })
  seoTitle: string | null;

  @Column({ name: 'seo_description', type: 'varchar', nullable: true })
  seoDescription: string | null;

  @Column({ name: 'mobile_friendly', type: 'boolean', nullable: true })
  mobileFriendly: boolean | null;

  @Column({ name: 'performance_score', type: 'int', nullable: true })
  performanceScore: number | null;

  @Column({ name: 'analysis_status', type: 'varchar', nullable: true })
  analysisStatus: string | null;

  @Column({ name: 'analyzed_at', type: 'timestamp', nullable: true })
  analyzedAt: Date | null;

  @OneToMany(() => LeadScore, (score) => score.analysis)
  scores: LeadScore[];

  @OneToMany(() => LeadAxisScore, (axisScore) => axisScore.analysis)
  axisScores: LeadAxisScore[];
}
