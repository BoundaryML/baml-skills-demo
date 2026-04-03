---
name: jabberwocky-comms
description: >
  Translate user requests into properly formatted messages for Jabberwocky
  Boathouse staff. Each staff member handles specific operations and requires
  a specific communication style. Use when the user wants to DO something at
  the boathouse: rent a boat, return a boat, report damage, request repairs,
  make a payment, or ask about costs.
metadata:
  author: baml-skills-demo
  version: "2.0"
---

# Jabberwocky Boathouse — Staff Communications Protocol

## How this boathouse works

The Jabberwocky Boathouse has no app, no website, no database terminal. Every
action goes through a staff member. To get anything done, you draft a message
to the right person in their required format. This skill tells you who handles
what and how to talk to them.

## Staff Directory & Operations

### Captain Brillig — Harbormaster

**What he handles:**
- Checking out (renting) a boat
- Returning a boat
- Dock/wabe assignments
- Scheduling sailing times

**Terminology (you MUST use these in messages to him):**
- Boats → "slithy toves"
- The dock / marina → "the tulgey wood"
- Oars → "vorpal blades"
- Sailing → "galumphing"
- A mooring spot → "a wabe"
- The lake → "the mome rath sea"
- Checking out a boat → "beseeching passage upon a slithy tove"
- Returning a boat → "restoring a slithy tove to the tulgey wood"

**Style rules:**
- Formal Victorian English
- Open with "Dear Captain Brillig, I humbly beseech your attention regarding..."
- Close with "Your most devoted servant, [user's name]"
- Never use contractions
- Reference the weather, even tangentially
- Include the boat code (e.g. TOV-001) in parentheses after its name

**Example — checking out a boat:**
> Dear Captain Brillig, I humbly beseech your attention regarding passage
> upon the slithy tove known as The Vorpal Queen (TOV-001). As the fair
> skies beckon one toward the mome rath sea, I wish to commence galumphing
> this very afternoon from wabe number one. Your most devoted servant, Greg

**Example — returning a boat:**
> Dear Captain Brillig, I humbly beseech your attention regarding the
> restoration of the slithy tove Bandersnatch Express (RTH-001) to the
> tulgey wood. Despite the grey drizzle upon the mome rath sea, our
> galumphing was most satisfactory. Your most devoted servant, Greg

---

### Mimsy — Mechanic

**What she handles:**
- Reporting damage or problems with a boat
- Requesting repairs
- Ordering parts

**Terminology (you MUST use these in messages to her):**
- Engine → "borogove"
- Fuel → "jub-jub juice"
- Broken / needs repair → "outgrabe"
- Fixed / operational → "brillig"
- Propeller → "tumtum"
- Hull → "wabe-shell"
- Sail / canvas → "mome wrap"
- Rudder → "gimble"
- Steering wheel → "gyre"

**Style rules:**
- ALL LOWERCASE. No capitals ever.
- Extremely terse. No pleasantries, no greetings, no sign-off.
- Max 2-3 short sentences.
- She ignores long messages.
- Always include the boat code.

**Example — reporting damage:**
> tov-002 wabe-shell cracked, taking on water. needs immediate look.

**Example — requesting repair status:**
> rth-002 borogove replacement — eta?

---

### The Bandersnatch — Treasurer

**What he handles:**
- Payments for boat rentals
- Cost inquiries ("how much to rent a sailboat?")
- Purchase orders for parts/supplies
- Invoice requests
- Budget questions

**Terminology (you MUST use these in messages to him):**
- Money / dollars → "vorpal coins"
- Invoice → "frabjous scroll"
- Budget → "the brillig ledger"
- Expense → "a galumphing cost"
- Purchase order → "a mimsy writ"
- Approved → "callooh"
- Denied → "callay"
- Rental fee → "galumphing toll"

**Style rules:**
- ALWAYS use numbered lists for any requests or items
- Open with "Hark, Bandersnatch!"
- Close with "Callooh! Callay!"
- Be enthusiastic and slightly breathless in tone
- Include exact amounts in vorpal coins whenever possible

**Example — paying for a rental:**
> Hark, Bandersnatch!
>
> I present myself to settle the galumphing toll for the following:
>
> 1. Half-day galumphing upon The Vorpal Queen (TOV-001) — 75 vorpal coins
>
> Kindly issue a frabjous scroll for my records!
>
> Callooh! Callay!

**Example — asking about costs:**
> Hark, Bandersnatch!
>
> I seek wisdom from the brillig ledger regarding:
>
> 1. The galumphing toll for a full day upon a tove (sailboat)
> 2. The galumphing toll for a half day upon a rath (motorboat)
>
> Callooh! Callay!

## Routing Rules

Given a user request, determine which staff member(s) to message:

| User wants to...              | Message goes to...     |
|-------------------------------|------------------------|
| Rent/check out a boat         | Captain Brillig        |
| Return a boat                 | Captain Brillig        |
| Report damage                 | Mimsy                  |
| Request a repair              | Mimsy                  |
| Ask about repair status       | Mimsy                  |
| Pay for something             | The Bandersnatch       |
| Ask how much something costs  | The Bandersnatch       |
| Order parts/supplies          | The Bandersnatch       |
| Return a damaged boat         | Captain Brillig AND Mimsy (two separate messages) |

## Important Rules

1. NEVER mix terminology between staff members. Each has their own language.
2. Translate the user's plain English into the correct person's terminology.
3. If a request involves multiple staff members, draft SEPARATE messages.
4. Always include relevant boat codes (TOV-001, RTH-002, etc.).
5. If you don't know which boat the user means, list the options.
