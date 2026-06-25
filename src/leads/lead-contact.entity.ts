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

@Entity({ name: 'lead_contacts' })
@Index('IDX_lead_contacts_lead_id', ['leadId'])
export class LeadContact {
  @PrimaryGeneratedColumn({ type: 'int' })
  id: number;

  @Column({ name: 'lead_id', type: 'varchar' })
  leadId: string;

  @ManyToOne(() => Lead, (lead) => lead.contacts, { nullable: false })
  @JoinColumn({
    name: 'lead_id',
    referencedColumnName: 'id',
    foreignKeyConstraintName: 'FK_lead_contacts_lead_id',
  })
  lead: Lead;

  @Column({ type: 'varchar', nullable: true })
  name: string | null;

  @Column({ type: 'varchar', nullable: true })
  email: string | null;

  @Column({ type: 'varchar', nullable: true })
  phone: string | null;

  @Column({ type: 'varchar', nullable: true })
  source: string | null;

  @CreateDateColumn()
  createdAt: Date;
}
