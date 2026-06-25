import {
  Column,
  CreateDateColumn,
  Entity,
  PrimaryColumn,
  UpdateDateColumn,
  OneToMany,
} from 'typeorm';
import { LeadAnalysis } from './lead-analysis.entity';
import { LeadContact } from './lead-contact.entity';
import { LeadScore } from './lead-score.entity';
import { LeadAxisScore } from './lead-axis-score.entity';

export enum LeadState {
  RAW = 'RAW',
  NORMALIZED = 'NORMALIZED',
  ENRICHED = 'ENRICHED',
  SCORED = 'SCORED',
  FAILED = 'FAILED',
}

@Entity({ name: 'leads' })
export class Lead {
  @PrimaryColumn({ name: 'google_place_id', type: 'varchar' })
  id: string;

  @Column({ type: 'varchar', nullable: true })
  name: string | null;

  @Column({ type: 'varchar', nullable: true })
  address: string | null;

  @Column({ type: 'varchar', nullable: true })
  phone: string | null;

  @Column({ type: 'varchar', nullable: true })
  website: string | null;

  @Column({ type: 'float', nullable: true })
  rating: number | null;

  @Column({ type: 'int', nullable: true })
  userRatingsTotal: number | null;

  @Column({ type: 'float', nullable: true })
  lat: number | null;

  @Column({ type: 'float', nullable: true })
  lng: number | null;

  @Column({ type: 'varchar' })
  searchQuery: string;

  @Column({ type: 'enum', enum: LeadState, default: LeadState.RAW })
  state: LeadState;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  lastUpdated: Date;

  @OneToMany(() => LeadContact, (contact) => contact.lead)
  contacts: LeadContact[];

  @OneToMany(() => LeadAnalysis, (analysis) => analysis.lead)
  analyses: LeadAnalysis[];

  @OneToMany(() => LeadScore, (score) => score.lead)
  scores: LeadScore[];

  @OneToMany(() => LeadAxisScore, (axisScore) => axisScore.lead)
  axisScores: LeadAxisScore[];
}
