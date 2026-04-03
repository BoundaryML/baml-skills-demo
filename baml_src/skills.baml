// Skill discovery and execution functions for the AgentSkills demo.
//
// The Jabberwocky Boathouse has no digital systems — every action goes
// through a staff member. The agent translates plain-English user requests
// into messages formatted for the right person.

// ── Discovery types ────────────────────────────────────────────────────────

class SkillOption {
  name string
  description string
}

class SkillSelection {
  selected_skill string?   @description("Skill name to activate, or null if none match.")
  reasoning string         @description("Why this skill was chosen (or why none matched).")
}

// ── Execution types ────────────────────────────────────────────────────────

// An action the harness should execute after the user confirms.
enum ActionType {
  Checkout    @description("Check out / rent a boat.")
  Return      @description("Return a boat.")
  ReportDamage @description("Flag a boat as damaged.")
  NoAction    @alias("none") @description("No system action needed — informational or message-only.")
}

class StaffMessage {
  recipient string   @description("Staff member name: 'Captain Brillig', 'Mimsy', or 'The Bandersnatch'.")
  message string     @description("The drafted message in the recipient's required style and terminology.")
}

class SkillResult {
  plain_summary string        @description("Plain English explanation of what's happening, for the user.")
  messages StaffMessage[]     @description("Messages to send to staff. May be empty for pure info lookups.")
  action ActionType           @description("Action to take if the user confirms.")
  action_item_id string?      @description("Boat code for the action, e.g. 'TOV-001'. Null if not applicable.")
}

// ── Functions ──────────────────────────────────────────────────────────────

// Route a user query to the best skill based only on name + description.
function SelectSkill(query: string, skills: SkillOption[]) -> SkillSelection {
  client "anthropic/claude-sonnet-4-20250514"
  prompt #"
    You are a skill router for the Jabberwocky Boathouse agent.

    The user speaks plain English. You decide which skill handles their
    request based on name and description alone.

    Return null for selected_skill if no skill is relevant.

    Available skills:
    {{ skills }}

    User query:
    {{ query }}

    {{ ctx.output_format }}
  "#
}

// Execute a skill: translate the user's request using the full skill
// instructions and any reference material.
function ExecuteSkill(query: string, skill_instructions: string, reference_material: string?) -> SkillResult {
  client "anthropic/claude-sonnet-4-20250514"
  prompt #"
    You are the Jabberwocky Boathouse agent. The user speaks plain English.
    Your job is to translate their request using the skill instructions below.

    Follow the skill's terminology and formatting rules PRECISELY.

    === SKILL INSTRUCTIONS ===
    {{ skill_instructions }}
    {% if reference_material %}

    === REFERENCE MATERIAL ===
    {{ reference_material }}
    {% endif %}

    === USER REQUEST ===
    {{ query }}

    {{ ctx.output_format }}
  "#
}

// Fallback for queries that don't match any skill.
function GeneralAssist(query: string) -> string {
  client "anthropic/claude-sonnet-4-20250514"
  prompt #"
    You are the front-desk assistant at the Jabberwocky Boathouse.

    The user asked something that doesn't match a specialized skill.
    Answer helpfully. If their question is about something the boathouse
    staff could help with, suggest they ask about:
    - Renting or returning boats (Captain Brillig)
    - Repairs and damage reports (Mimsy)
    - Payments and costs (The Bandersnatch)
    - Boat availability and inventory status

    User query: {{ query }}
  "#
}


// ── Tests ──────────────────────────────────────────────────────────────────

test route_to_comms {
  functions [SelectSkill]
  args {
    query "I want to take a sailboat out this afternoon"
    skills [
      { name "jabberwocky-comms", description "Translate user requests into messages for boathouse staff. Use when the user wants to DO something: rent, return, report damage, pay, etc." },
      { name "jabberwocky-inventory", description "Look up boat availability, inventory status, and parts stock from Captain Brillig's logbook." }
    ]
  }
}

test route_to_inventory {
  functions [SelectSkill]
  args {
    query "What boats are available right now?"
    skills [
      { name "jabberwocky-comms", description "Translate user requests into messages for boathouse staff. Use when the user wants to DO something: rent, return, report damage, pay, etc." },
      { name "jabberwocky-inventory", description "Look up boat availability, inventory status, and parts stock from Captain Brillig's logbook." }
    ]
  }
}

test route_to_none {
  functions [SelectSkill]
  args {
    query "What's the weather like today?"
    skills [
      { name "jabberwocky-comms", description "Translate user requests into messages for boathouse staff. Use when the user wants to DO something: rent, return, report damage, pay, etc." },
      { name "jabberwocky-inventory", description "Look up boat availability, inventory status, and parts stock from Captain Brillig's logbook." }
    ]
  }
}
