import {
  Column,
  CreateDateColumn,
  Entity,
  Index,
  JoinColumn,
  ManyToOne,
  OneToMany,
  PrimaryGeneratedColumn,
  UpdateDateColumn,
} from 'typeorm';
import { Lead } from './lead.entity';
import { ScrapingRawResult } from './scraping-raw-result.entity';

export enum ScrapingJobType {
  FULL = 'FULL',
  WEBSITE = 'WEBSITE',
  SEO = 'SEO',
  SOCIAL = 'SOCIAL',
  CONTACTS = 'CONTACTS',
}

export enum ScrapingJobStatus {
  PENDING = 'PENDING',
  RUNNING = 'RUNNING',
  SUCCESS = 'SUCCESS',
  FAILED = 'FAILED',
  PARTIAL = 'PARTIAL',
}

@Entity({ name: 'scraping_jobs' })
@Index('IDX_scraping_jobs_lead_id', ['leadId'])
@Index('IDX_scraping_jobs_status', ['status'])
@Index('IDX_scraping_jobs_job_type', ['jobType'])
@Index('IDX_scraping_jobs_created_at', ['createdAt'])
@Index('IDX_scraping_jobs_lead_id_created_at', ['leadId', 'createdAt'])
export class ScrapingJob {
  @PrimaryGeneratedColumn({ type: 'int' })
  id: number;

  @Column({ name: 'lead_id', type: 'varchar' })
  leadId: string;

  @ManyToOne(() => Lead, (lead) => lead.scrapingJobs, { nullable: false })
  @JoinColumn({
    name: 'lead_id',
    referencedColumnName: 'id',
    foreignKeyConstraintName: 'FK_scraping_jobs_lead_id',
  })
  lead: Lead;

  @Column({ name: 'job_type', type: 'varchar', length: 30 })
  jobType: ScrapingJobType;

  @Column({ type: 'varchar', length: 30 })
  status: ScrapingJobStatus;

  @Column({ type: 'varchar', length: 50, nullable: true })
  source: string | null;

  @Column({ type: 'varchar', length: 50, nullable: true })
  trigger: string | null;

  @Column({ name: 'started_at', type: 'timestamp', nullable: true })
  startedAt: Date | null;

  @Column({ name: 'finished_at', type: 'timestamp', nullable: true })
  finishedAt: Date | null;

  @Column({ name: 'duration_ms', type: 'int', nullable: true })
  durationMs: number | null;

  @Column({ name: 'error_message', type: 'text', nullable: true })
  errorMessage: string | null;

  @CreateDateColumn({ name: 'created_at', type: 'timestamp' })
  createdAt: Date;

  @UpdateDateColumn({ name: 'updated_at', type: 'timestamp' })
  updatedAt: Date;

  @OneToMany(() => ScrapingRawResult, (rawResult) => rawResult.job)
  rawResults: ScrapingRawResult[];
}
