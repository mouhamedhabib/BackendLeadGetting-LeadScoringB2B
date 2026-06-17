import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { McpModule } from '@nestjs-mcp/server';
import { HealthResolver } from './mcp/health.resolver';

@Module({
  imports: [McpModule.forRoot({
      name: 'My MCP Server',
      version: '1.0.0',
    }),],
  controllers: [AppController],
  providers: [AppService ,HealthResolver],
})
export class AppModule {}
