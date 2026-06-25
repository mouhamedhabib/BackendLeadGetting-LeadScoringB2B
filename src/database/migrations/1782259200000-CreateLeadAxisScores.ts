import {
  MigrationInterface,
  QueryRunner,
  Table,
  TableForeignKey,
  TableIndex,
} from 'typeorm';

export class CreateLeadAxisScores1782259200000 implements MigrationInterface {
  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.createTable(
      new Table({
        name: 'lead_axis_scores',
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
          { name: 'axis', type: 'varchar' },
          { name: 'score', type: 'decimal', isNullable: true },
          { name: 'weight', type: 'decimal', isNullable: true },
          { name: 'weighted_score', type: 'decimal', isNullable: true },
          { name: 'is_available', type: 'boolean', default: true },
          { name: 'score_type', type: 'varchar' },
          { name: 'createdAt', type: 'timestamp', default: 'now()' },
        ],
        checks: [
          {
            name: 'CHK_lead_axis_scores_axis',
            expression: `"axis" IN ('GMB', 'WEBSITE', 'SEO', 'SOCIAL')`,
          },
          {
            name: 'CHK_lead_axis_scores_score_type',
            expression: `"score_type" IN ('digital_maturity', 'opportunity')`,
          },
        ],
      }),
    );

    await queryRunner.createForeignKey(
      'lead_axis_scores',
      new TableForeignKey({
        name: 'FK_lead_axis_scores_lead_id',
        columnNames: ['lead_id'],
        referencedTableName: 'leads',
        referencedColumnNames: ['google_place_id'],
      }),
    );
    await queryRunner.createForeignKey(
      'lead_axis_scores',
      new TableForeignKey({
        name: 'FK_lead_axis_scores_analysis_id',
        columnNames: ['analysis_id'],
        referencedTableName: 'lead_analysis',
        referencedColumnNames: ['id'],
      }),
    );

    for (const [name, columnName] of [
      ['IDX_lead_axis_scores_lead_id', 'lead_id'],
      ['IDX_lead_axis_scores_analysis_id', 'analysis_id'],
      ['IDX_lead_axis_scores_axis', 'axis'],
      ['IDX_lead_axis_scores_score_type', 'score_type'],
    ]) {
      await queryRunner.createIndex(
        'lead_axis_scores',
        new TableIndex({ name, columnNames: [columnName] }),
      );
    }
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.dropTable('lead_axis_scores');
  }
}
