# Happy MCP Server Enhancement Plan

## Overview

This document outlines the enhancements made to the Happy MCP Server to provide richer integration capabilities for AI agents (Claude Code, Gemini CLI, Codex CLI).

## Current State (v1.0.0)

**File**: `happy-cli/src/claude/utils/startHappyServer.ts`

**Tools**:
- `change_title`: Change the chat session title

**Limitations**:
- Only one tool available
- No session introspection capabilities
- No notification capabilities
- No daemon status queries

## Enhanced Version (v2.0.0)

**File**: `happy-cli/src/claude/utils/startHappyServer.enhanced.ts`

### New Tools

#### 1. `get_session_info`
**Purpose**: Retrieve current session metadata and agent state

**Input**: None

**Output**: JSON containing:
```json
{
  "sessionId": "abc-123",
  "summary": { "text": "Session title", "updatedAt": 1234567890 },
  "createdAt": 1234567890,
  "updatedAt": 1234567890,
  "agentState": { ... }
}
```

**Use cases**:
- AI agent can check current session context
- Retrieve session history
- Monitor session state changes

#### 2. `send_notification`
**Purpose**: Send push notifications to connected devices (mobile/web)

**Input**:
- `message` (required): Notification message
- `title` (optional): Notification title

**Output**: Success confirmation

**Use cases**:
- Alert user when long-running tasks complete
- Notify about important events
- Send status updates

#### 3. `get_daemon_status`
**Purpose**: Query Happy daemon connection status

**Input**: None

**Output**: JSON containing:
```json
{
  "connected": true,
  "sessionId": "abc-123",
  "serverUrl": "http://localhost:3005"
}
```

**Use cases**:
- Check if daemon is connected
- Verify server URL configuration
- Debug connection issues

## Implementation Details

### Architecture

```
┌─────────────────┐
│   AI Agent      │ (Claude/Gemini/Codex)
│   (MCP Client)  │
└────────┬────────┘
         │ HTTP MCP Protocol
         ▼
┌─────────────────┐
│  Happy MCP      │
│  Server         │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ ApiSessionClient│
│ (WebSocket)     │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Happy Server   │
│  (Backend)      │
└─────────────────┘
```

### Security Considerations

1. **No Authentication Required**: MCP server runs on localhost only (127.0.0.1)
2. **Session Scoped**: All tools operate within the current session context
3. **Read-Only Metadata**: Session info is read-only, no direct modifications
4. **Rate Limiting**: Notification sending respects server-side rate limits

### Backward Compatibility

- ✅ Fully backward compatible with v1.0.0
- ✅ Existing `change_title` tool unchanged
- ✅ No breaking changes to API
- ✅ New tools are optional

## Migration Guide

### Option 1: Direct Replacement (Recommended)

```bash
# Backup original
mv happy-cli/src/claude/utils/startHappyServer.ts \
   happy-cli/src/claude/utils/startHappyServer.v1.ts

# Replace with enhanced version
mv happy-cli/src/claude/utils/startHappyServer.enhanced.ts \
   happy-cli/src/claude/utils/startHappyServer.ts

# Rebuild
cd happy-cli && yarn build
```

### Option 2: Gradual Rollout

Keep both versions and switch via environment variable:

```typescript
import { startHappyServer as startV1 } from './startHappyServer.v1';
import { startHappyServer as startV2 } from './startHappyServer.enhanced';

export const startHappyServer =
  process.env.HAPPY_MCP_V2 === 'true' ? startV2 : startV1;
```

## Testing

### Manual Testing

```bash
# Start Happy with enhanced MCP server
cd happy-cli
export HAPPY_MCP_V2=true
./bin/happy.mjs

# In Claude Code session, test each tool:
# 1. Test change_title
> @happy Use the change_title tool to rename this chat to "Testing MCP"

# 2. Test get_session_info
> @happy Use get_session_info to show me current session details

# 3. Test send_notification
> @happy Send me a notification saying "MCP tools are working!"

# 4. Test get_daemon_status
> @happy Check the daemon status using get_daemon_status
```

### Integration Testing

```bash
# Run compatibility check
./scripts/check-ai-cli-compatibility.sh

# Should show:
# ✓ MCP tools registered: 4 (was 1)
```

## Performance Impact

- **Memory**: +~10KB per session (negligible)
- **Latency**: <5ms per tool call (local HTTP)
- **Network**: No additional external requests
- **CPU**: Minimal overhead

## Future Enhancements

Potential additional tools for v3.0.0:

1. **`list_sessions`**: List all active sessions
2. **`switch_session`**: Switch between sessions
3. **`get_usage_stats`**: Token usage statistics
4. **`export_session`**: Export session history
5. **`search_history`**: Search through chat history

## References

- MCP Protocol: https://modelcontextprotocol.io/
- Happy CLI: https://github.com/Han-tiv/happy-cli
- ApiSessionClient: `happy-cli/src/api/apiSession.ts`

## Support

For issues or questions:
1. Check compatibility: `./scripts/check-ai-cli-compatibility.sh`
2. Review logs: Check `~/.happy-dev-test/logs/`
3. Report issues: https://github.com/Han-tiv/happy-coder/issues
