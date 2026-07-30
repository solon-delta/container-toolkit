#!/usr/bin/env node
'use strict';

// SubagentStart hook. It reads the Language Rule from SOUL.md.
// A subagent does not load SOUL.md on its own. This hook is its only source
// for the rule. SubagentStart drops plain stdout. It needs the
// hookSpecificOutput form instead.

const fs = require('fs');
const path = require('path');

const soulPath = path.join(__dirname, 'SOUL.md');

let rule = '';
try {
  rule = fs.readFileSync(soulPath, 'utf8').trim();
} catch (e) {
  process.exit(0);
}
if (!rule) process.exit(0);

const context = `\n${rule}\n`;
process.stdout.write(JSON.stringify({
  hookSpecificOutput: { hookEventName: 'SubagentStart', additionalContext: context },
}));
