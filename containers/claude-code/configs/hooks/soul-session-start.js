#!/usr/bin/env node
'use strict';

// SessionStart hook. It reads the Language Rule from SOUL.md.
// It writes the rule to context on every startup, resume, clear, and compact event.
// Compaction can hide SOUL.md's prominence in a long session. This hook keeps
// the rule fresh. It mirrors the pattern the ponytail plugin uses for its own
// persona (see its hooks/ponytail-subagent.js).

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

process.stdout.write(`\n${rule}\n`);
