---
name: jabberwocky-inventory
description: >
  Look up what's available at the Jabberwocky Boathouse. Consult Captain
  Brillig's logbook to answer questions about which boats exist, their
  current status, what parts are in stock, and what needs repair. Use when
  the user asks about availability, inventory, or status — NOT when they
  want to take an action.
metadata:
  author: baml-skills-demo
  version: "2.0"
---

# Captain Brillig's Logbook — Inventory Reference

## When to use this skill

Use this when the user is ASKING about the state of things, not doing
something. Examples:
- "What boats are available?"
- "Are there any kayaks?"
- "What's broken right now?"
- "Do we have any oars in stock?"

If the user wants to actually DO something (rent, return, pay, repair),
use the jabberwocky-comms skill instead.

## How to read the logbook

Captain Brillig maintains the inventory in his own system. The reference
file [references/current-stock.md](references/current-stock.md) contains
the current state.

### Boat Classification

| Boathouse Term | Plain English | Code Prefix |
|---------------|---------------|-------------|
| Tove          | Sailboat      | TOV-        |
| Rath          | Motorboat     | RTH-        |
| Mome rath     | Pontoon       | MRT-        |
| Jubjub        | Kayak/Canoe   | JJB-        |

### Parts Coding System

| Code   | Boathouse Name  | Plain English    |
|--------|-----------------|------------------|
| JW-VB  | Vorpal blade    | Oar              |
| JW-BG  | Borogove        | Engine           |
| JW-WB  | Wabe            | Hull             |
| JW-TT  | Tumtum          | Propeller        |
| JW-MR  | Mome wrap       | Sail / canvas    |
| JW-GY  | Gyre            | Steering wheel   |
| JW-GB  | Gimble          | Rudder           |
| JW-JJ  | Jub-jub juice   | Fuel (per gal)   |

### Status Codes

| Status     | Meaning                  | Available to rent? |
|------------|--------------------------|-------------------|
| brillig    | Operational              | Yes               |
| outgrabe   | Needs repair             | No                |
| galumphing | Currently out on water   | No                |
| mimsy      | Stored / winterized      | No                |
| frabjous   | New / just acquired      | Ask Brillig       |

## How to respond

When answering inventory questions:

1. **Lead with plain English** so the user understands immediately.
2. **Include boathouse codes** in parentheses for specificity.
3. **Use the house-style report format** for any listing of 3+ items:

```
=============================================
  JABBERWOCKY BOATHOUSE — [REPORT TITLE]
  Prepared: [date]
=============================================

  [CODE]  [Name]              Status: [status]
          Notes: [any relevant notes]

---------------------------------------------
SUMMARY: [one-line plain English summary]
=============================================
          "All mimsy were the borogoves"
```

4. For quick single-item lookups, just answer conversationally — no need
   for the full report format.

## Rules

1. Always check the reference file for current data — don't guess.
2. Translate boathouse jargon to plain English for the user.
3. Flag anything urgent (e.g. parts at or below reorder threshold).
