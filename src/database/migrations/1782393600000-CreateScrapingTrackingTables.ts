import {
  MigrationInterface,
  QueryRunner,
  Table,
  TableForeignKey,
  TableIndex,
} from 'typeorm';

export class CreateScrapingTrackingTables1782393600000 implements MigrationInterface {
  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.createTable(
      new Table({
        name: 'scraping_jobs',
        columns: [
          {
            name: 'id',
            type: 'int',
            isPrimary: true,
            isGenerated: true,
            generationStrategy: 'increment',
          },
          { name: 'lead_id', type: 'varchar' },
          { name: 'job_type', type: 'varchar', length: '30' },
          { name: 'status', type: 'varchar', length: '30' },
          { name: 'source', type: 'varchar', length: '50', isNullable: true },
          { name: 'trigger', type: 'varchar', length: '50', isNullable: true },
          { name: 'started_at', type: 'timestamp', isNullable: true },
          { name: 'finished_at', type: 'timestamp', isNullable: true },
          { name: 'duration_ms', type: 'int', isNullable: true },
          { name: 'error_message', type: 'text', isNullable: true },
          { name: 'created_at', type: 'timestamp', default: 'now()' },
          { name: 'updated_at', type: 'timestamp', default: 'now()' },
        ],
      }),
    );

    await queryRunner.createTable(
      new Table({
        name: 'scraping_raw_results',
        columns: [
          {
            name: 'id',
            type: 'int',
            isPrimary: true,
            isGenerated: true,
            generationStrategy: 'increment',
          },
          { name: 'job_id', type: 'int' },
          { name: 'lead_id', type: 'varchar' },
          { name: 'source', type: 'varchar', length: '50' },
          { name: 'raw_json', type: 'jsonb' },
          {
            name: 'normalized_status',
            type: 'varchar',
            length: '30',
            isNullable: true,
          },
          {
            name: 'dedupe_key',
            type: 'varchar',
            length: '255',
            isNullable: true,
          },
          { name: 'created_at', type: 'timestamp', default: 'now()' },
        ],
      }),
    );

    await queryRunner.createForeignKey(
      'scraping_jobs',
      new TableForeignKey({
        name: 'FK_scraping_jobs_lead_id',
        columnNames: ['lead_id'],
        referencedTableName: 'leads',
        referencedColumnNames: ['google_place_id'],
      }),
    );
    await queryRunner.createForeignKey(
      'scraping_raw_results',
      new TableForeignKey({
        name: 'FK_scraping_raw_results_job_id',
        columnNames: ['job_id'],
        referencedTableName: 'scraping_jobs',
        referencedColumnNames: ['id'],
      }),
    );
    await queryRunner.createForeignKey(
      'scraping_raw_results',
      new TableForeignKey({
        name: 'FK_scraping_raw_results_lead_id',
        columnNames: ['lead_id'],
        referencedTableName: 'leads',
        referencedColumnNames: ['google_place_id'],
      }),
    );

    for (const [tableName, indexName, columnNames] of [
      ['scraping_jobs', 'IDX_scraping_jobs_lead_id', ['lead_id']],
      ['scraping_jobs', 'IDX_scraping_jobs_status', ['status']],
      ['scraping_jobs', 'IDX_scraping_jobs_job_type', ['job_type']],
      ['scraping_jobs', 'IDX_scraping_jobs_created_at', ['created_at']],
      [
        'scraping_jobs',
        'IDX_scraping_jobs_lead_id_created_at',
        ['lead_id', 'created_at'],
      ],
      ['scraping_raw_results', 'IDX_scraping_raw_results_job_id', ['job_id']],
      ['scraping_raw_results', 'IDX_scraping_raw_results_lead_id', ['lead_id']],
      ['scraping_raw_results', 'IDX_scraping_raw_results_source', ['source']],
      [
        'scraping_raw_results',
        'IDX_scraping_raw_results_normalized_status',
        ['normalized_status'],
      ],
      [
        'scraping_raw_results',
        'IDX_scraping_raw_results_dedupe_key',
        ['dedupe_key'],
      ],
      [
        'scraping_raw_results',
        'IDX_scraping_raw_results_created_at',
        ['created_at'],
      ],
      [
        'scraping_raw_results',
        'IDX_scraping_raw_results_lead_id_source',
        ['lead_id', 'source'],
      ],
      [
        'scraping_raw_results',
        'IDX_scraping_raw_results_job_id_source',
        ['job_id', 'source'],
      ],
    ] as const) {
      await queryRunner.createIndex(
        tableName,
        new TableIndex({ name: indexName, columnNames: [...columnNames] }),
      );
    }
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.dropTable('scraping_raw_results');
    await queryRunner.dropTable('scraping_jobs');
  }
}
