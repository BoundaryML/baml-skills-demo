---
name: calculator
description: >
  Solve math problems accurately using the compute tool. Use when the user
  asks to calculate, compute, or figure out anything involving numbers,
  percentages, conversions, or arithmetic.
---

# Calculator

Solve math problems by using the `compute` tool rather than doing mental
math. This ensures accuracy for arithmetic, percentages, unit conversions,
and any numeric computation.

## How to use

1. Parse the user's question into a Python math expression.
2. Request a tool call: set `tool_request` with `tool: "compute"` and
   `input` as the Python expression string.
3. Your `response` should explain what you're computing and why, but
   leave the final numeric answer for after the tool returns.

## Expression format

The `compute` tool evaluates Python expressions. You can use:
- Basic arithmetic: `2 + 3`, `10 / 3`, `7 * 8`
- Exponents: `2 ** 10`
- Parentheses: `(100 - 15) / 3`
- Python's `math` module is available: `math.sqrt(144)`, `math.pi * 5**2`
- Multiple steps: `round(847.50 * 0.18, 2)`

## Rules

1. **Always use the tool.** Never estimate or do arithmetic yourself.
2. **One expression per request.** If the problem needs multiple steps,
   combine them into a single Python expression.
3. **Show the expression** you're computing so the user can verify it.
4. **Round currency to 2 decimal places** using `round(..., 2)`.
