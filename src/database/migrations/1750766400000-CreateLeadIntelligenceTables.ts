import {
  MigrationInterface,
  QueryRunner,
  Table,
  TableForeignKey,
  TableIndex,
} from 'typeorm';

export class CreateLeadIntelligenceTables1750766400000 implements MigrationInterface {
  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.createTable(
      new Table({
        name: 'lead_contacts',
        columns: [
          {
            name: 'id',
            type: 'int',
            isPrimary: true,
            isGenerated: true,
            generationStrategy: 'increment',
          },
          { name: 'lead_id', type: 'varchar' },
          { name: 'name', type: 'varchar', isNullable: true },
          { name: 'email', type: 'varchar', isNullable: true },
          { name: 'phone', type: 'varchar', isNullable: true },
          { name: 'source', type: 'varchar', isNullable: true },
          { name: 'createdAt', type: 'timestamp', default: 'now()' },
        ],
      }),
    );

    await queryRunner.createTable(
      new Table({
        name: 'lead_analysis',
        columns: [
          {
            name: 'id',
            type: 'int',
            isPrimary: true,
            isGenerated: true,
            generationStrategy: 'increment',
          },
          { name: 'lead_id', type: 'varchar' },
          { name: 'website_url', type: 'varchar', isNullable: true },
          { name: 'has_website', type: 'boolean', isNullable: true },
          { name: 'has_ssl', type: 'boolean', isNullable: true },
          { name: 'has_facebook', type: 'boolean', isNullable: true },
          { name: 'has_instagram', type: 'boolean', isNullable: true },
          { name: 'seo_title', type: 'varchar', isNullable: true },
          { name: 'seo_description', type: 'varchar', isNullable: true },
          { name: 'mobile_friendly', type: 'boolean', isNullable: true },
          { name: 'performance_score', type: 'int', isNullable: true },
          { name: 'analysis_status', type: 'varchar', isNullable: true },
          { name: 'analyzed_at', type: 'timestamp', isNullable: true },
        ],
      }),
    );

    await queryRunner.createTable(
      new Table({
        name: 'lead_scores',
        columns: [
          {
            name: 'id',
            type: 'int',
            isPrimary: true,
            isGenerated: true,
            generationStrategy: 'increment',
          },
          { name: 'lead_id', type: 'varchar' },
          { name: 'analysis_id', type: 'int', isNullable: true },
          { name: 'period_type', type: 'varchar', isNullable: true },
          { name: 'digital_maturity', type: 'decimal', isNullable: true },
          { name: 'opportunity', type: 'decimal', isNullable: true },
          { name: 'analysis_cost', type: 'decimal', isNullable: true },
          { name: 'createdAt', type: 'timestamp', default: 'now()' },
        ],
      }),
    );

    await queryRunner.createForeignKey(
      'lead_contacts',
      new TableForeignKey({
        name: 'FK_lead_contacts_lead_id',
        columnNames: ['lead_id'],
        referencedTableName: 'leads',
        referencedColumnNames: ['google_place_id'],
      }),
    );
    await queryRunner.createForeignKey(
      'lead_analysis',
      new TableForeignKey({
        name: 'FK_lead_analysis_lead_id',
        columnNames: ['lead_id'],
        referencedTableName: 'leads',
        referencedColumnNames: ['google_place_id'],
      }),
    );
    await queryRunner.createForeignKey(
      'lead_scores',
      new TableForeignKey({
        name: 'FK_lead_scores_lead_id',
        columnNames: ['lead_id'],
        referencedTableName: 'leads',
        referencedColumnNames: ['google_place_id'],
      }),
    );
    await queryRunner.createForeignKey(
      'lead_scores',
      new TableForeignKey({
        name: 'FK_lead_scores_analysis_id',
        columnNames: ['analysis_id'],
        referencedTableName: 'lead_analysis',
        referencedColumnNames: ['id'],
      }),
    );

    await queryRunner.createIndex(
      'lead_contacts',
      new TableIndex({
        name: 'IDX_lead_contacts_lead_id',
        columnNames: ['lead_id'],
      }),
    );
    await queryRunner.createIndex(
      'lead_analysis',
      new TableIndex({
        name: 'IDX_lead_analysis_lead_id',
        columnNames: ['lead_id'],
      }),
    );
    await queryRunner.createIndex(
      'lead_scores',
      new TableIndex({
        name: 'IDX_lead_scores_lead_id',
        columnNames: ['lead_id'],
      }),
    );
    await queryRunner.createIndex(
      'lead_scores',
      new TableIndex({
        name: 'IDX_lead_scores_analysis_id',
        columnNames: ['analysis_id'],
      }),
    );
    await queryRunner.createIndex(
      'lead_scores',
      new TableIndex({
        name: 'IDX_lead_scores_period_type',
        columnNames: ['period_type'],
      }),
    );
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.dropTable('lead_scores');
    await queryRunner.dropTable('lead_analysis');
    await queryRunner.dropTable('lead_contacts');
  }
}
