import { Resolver, Tool } from '@nestjs-mcp/server';
import type { CallToolResult } from '@modelcontextprotocol/sdk/types';

@Resolver()
export class HealthResolver {
  @Tool({ name: 'server_health_check' })
  health(): CallToolResult {
    return {
      content: [
        {
          type: 'text',
          text: 'Server is OK 🚀',
        },
      ],
    };
  }
}
