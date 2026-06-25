import { MigrationInterface, QueryRunner } from 'typeorm';

export class AddLeadScoreDate1782307200000 implements MigrationInterface {
  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      'ALTER TABLE lead_scores ADD COLUMN score_date DATE',
    );
    await queryRunner.query(
      'UPDATE lead_scores SET score_date = "createdAt"::date',
    );
    await queryRunner.query(
      'ALTER TABLE lead_scores ALTER COLUMN score_date SET NOT NULL',
    );
    await queryRunner.query(
      'CREATE INDEX idx_lead_scores_date ON lead_scores (lead_id, score_date)',
    );
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query('DROP INDEX idx_lead_scores_date');
    await queryRunner.query('ALTER TABLE lead_scores DROP COLUMN score_date');
  }
}
