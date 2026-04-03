// AgentSkills + BAML demo.
//
// A chat agent that dynamically gains capabilities from skill folders.
// Skills can teach the LLM new knowledge (jabberwocky-translate) or
// new behaviors including tool use (calculator).

// ── Skill routing ──────────────────────────────────────────────────────────

class SkillOption {
  name string
  description string
}

class SkillSelection {
  selected_skill string?  @description("Skill name to activate, or null if none match.")
  reasoning string        @description("One-sentence explanation.")
}

function SelectSkill(query: string, skills: SkillOption[]) -> SkillSelection? {
  client "anthropic/claude-sonnet-4-20250514"
  prompt #"
    You route user messages to the right skill. Pick the single best
    match from the list, or return null if the message is just normal
    conversation.

    Available skills:
    {{ skills }}

    User message:
    {{ query }}

    {{ ctx.output_format }}
  "#
}

// ── Tool types ─────────────────────────────────────────────────────────────
// Each tool is a typed class. To add a new tool, define its class and add
// it to the ToolRequest union.

class Compute {
  tool "compute" @description("Must be the literal string 'compute'.")
  expression string @description("Python math expression, e.g. 'round(47.50 * 0.18, 2)'.")
}

// To add more tools:
// class WebSearch {
//   tool "web_search"
//   query string
// }

type ToolRequest = Compute

class SkillResult {
  response string           @description("Response text for the user. If a tool is needed, explain what you're computing but don't guess the answer.")
  tool_request ToolRequest? @description("Optional tool call. Null if no tool is needed.")
}

function ExecuteSkill(
  query: string,
  skill_instructions: string,
) -> SkillResult {
  client "anthropic/claude-sonnet-4-20250514"
  prompt #"
    You are a helpful chat assistant with a specialized skill loaded.
    Follow the skill instructions precisely.

    === SKILL INSTRUCTIONS ===
    {{ skill_instructions }}

    === USER MESSAGE ===
    {{ query }}

    {{ ctx.output_format }}
  "#
}

// Called after a tool returns, to produce the final response.
function FinishWithToolResult(
  query: string,
  skill_instructions: string,
  partial_response: string,
  tool_name: string,
  tool_result: string,
) -> string {
  client "anthropic/claude-sonnet-4-20250514"
  prompt #"
    You are a helpful chat assistant. You previously started answering
    a user's question and requested a tool call. The tool has now returned.
    Produce the final answer.

    === SKILL INSTRUCTIONS ===
    {{ skill_instructions }}

    === USER MESSAGE ===
    {{ query }}

    === YOUR EARLIER RESPONSE ===
    {{ partial_response }}

    === TOOL RESULT ===
    Tool: {{ tool_name }}
    Result: {{ tool_result }}

    Now give the complete, final response to the user incorporating the
    tool result.
  "#
}

// ── General chat (no skill) ────────────────────────────────────────────────

function Chat(query: string) -> string {
  client "anthropic/claude-sonnet-4-20250514"
  prompt #"
    You are a friendly chat assistant. You have some specialized skills
    available for specific tasks, but this message is just normal
    conversation. Respond naturally and helpfully.

    User: {{ query }}
  "#
}


// ── Tests ──────────────────────────────────────────────────────────────────

test route_translate {
  functions [SelectSkill]
  args {
    query "Translate this to Jabberwocky: I went for a walk in the meadow"
    skills [
      { name "jabberwocky-translate", description "Translate between English and Jabberwocky dialect." },
      { name "calculator", description "Solve math problems using the compute tool." }
    ]
  }
}

test route_calculator {
  functions [SelectSkill]
  args {
    query "What's 18% tip on a $47.50 bill?"
    skills [
      { name "jabberwocky-translate", description "Translate between English and Jabberwocky dialect." },
      { name "calculator", description "Solve math problems using the compute tool." }
    ]
  }
}

test route_none {
  functions [SelectSkill]
  args {
    query "Hey, how's it going?"
    skills [
      { name "jabberwocky-translate", description "Translate between English and Jabberwocky dialect." },
      { name "calculator", description "Solve math problems using the compute tool." }
    ]
  }
}
