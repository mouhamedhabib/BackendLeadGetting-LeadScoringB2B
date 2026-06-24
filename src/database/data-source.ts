import 'reflect-metadata';
import 'dotenv/config';
import { DataSource } from 'typeorm';
import { LeadAnalysis } from '../leads/lead-analysis.entity';
import { LeadContact } from '../leads/lead-contact.entity';
import { Lead } from '../leads/lead.entity';
import { LeadScore } from '../leads/lead-score.entity';

const databaseUrl = process.env.DATABASE_URL;

if (!databaseUrl) {
  throw new Error('DATABASE_URL is required to run TypeORM commands');
}

export default new DataSource({
  type: 'postgres',
  url: databaseUrl,
  entities: [Lead, LeadContact, LeadAnalysis, LeadScore],
  migrations: [`${__dirname}/migrations/*{.ts,.js}`],
  synchronize: false,
});
