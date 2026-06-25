import {
  Column,
  CreateDateColumn,
  Entity,
  Index,
  JoinColumn,
  ManyToOne,
  PrimaryGeneratedColumn,
} from 'typeorm';
import { Lead } from './lead.entity';
import { ScrapingJob } from './scraping-job.entity';

export enum ScrapingRawResultStatus {
  RAW = 'RAW',
  NORMALIZED = 'NORMALIZED',
  REJECTED = 'REJECTED',
  DUPLICATE = 'DUPLICATE',
  ERROR = 'ERROR',
}

@Entity({ name: 'scraping_raw_results' })
@Index('IDX_scraping_raw_results_job_id', ['jobId'])
@Index('IDX_scraping_raw_results_lead_id', ['leadId'])
@Index('IDX_scraping_raw_results_source', ['source'])
@Index('IDX_scraping_raw_results_normalized_status', ['normalizedStatus'])
@Index('IDX_scraping_raw_results_dedupe_key', ['dedupeKey'])
@Index('IDX_scraping_raw_results_created_at', ['createdAt'])
@Index('IDX_scraping_raw_results_lead_id_source', ['leadId', 'source'])
@Index('IDX_scraping_raw_results_job_id_source', ['jobId', 'source'])
export class ScrapingRawResult {
  @PrimaryGeneratedColumn({ type: 'int' })
  id: number;

  @Column({ name: 'job_id', type: 'int' })
  jobId: number;

  @ManyToOne(() => ScrapingJob, (job) => job.rawResults, { nullable: false })
  @JoinColumn({
    name: 'job_id',
    foreignKeyConstraintName: 'FK_scraping_raw_results_job_id',
  })
  job: ScrapingJob;

  @Column({ name: 'lead_id', type: 'varchar' })
  leadId: string;

  @ManyToOne(() => Lead, (lead) => lead.scrapingRawResults, {
    nullable: false,
  })
  @JoinColumn({
    name: 'lead_id',
    referencedColumnName: 'id',
    foreignKeyConstraintName: 'FK_scraping_raw_results_lead_id',
  })
  lead: Lead;

  @Column({ type: 'varchar', length: 50 })
  source: string;

  @Column({ name: 'raw_json', type: 'jsonb' })
  rawJson: Record<string, unknown>;

  @Column({
    name: 'normalized_status',
    type: 'varchar',
    length: 30,
    nullable: true,
  })
  normalizedStatus: ScrapingRawResultStatus | null;

  @Column({ name: 'dedupe_key', type: 'varchar', length: 255, nullable: true })
  dedupeKey: string | null;

  @CreateDateColumn({ name: 'created_at', type: 'timestamp' })
  createdAt: Date;
}
