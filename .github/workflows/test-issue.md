---
description: Test Copilot assignment

on:
  issues:
    types: [opened]

permissions:
  contents: read
  issues: read
  copilot-requests: write

safe-outputs:
  assign-to-agent:
---

Immediately assign the issue to Copilot.