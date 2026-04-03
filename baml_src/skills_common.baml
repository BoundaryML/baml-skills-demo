// Shared types and functions used by both routing variants.

// ── Tool types ─────────────────────────────────────────────────────────────

class Compute {
  tool "compute" @description("Must be the literal string 'compute'.")
  expression string @description("Python math expression, e.g. 'round(47.50 * 0.18, 2)'.")
}

type ToolRequest = Compute

class SkillResult {
  response string           @description("Response text for the user. If a tool is needed, explain what you're computing but don't guess the answer.")
  tool_request ToolRequest? @description("Optional tool call. Null if no tool is needed.")
}

// ── Skill execution ────────────────────────────────────────────────────────

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

test translate_to_jabberwocky {
  functions [ExecuteSkill]
  args {
    query "Translate to Jabberwocky: I went for a walk in the meadow at evening"
    skill_instructions "Translate English to Jabberwocky. Vocabulary: walk/wander->gyre, meadow/field->wabe, afternoon/evening->brillig. Keep grammar intact, only swap mapped words. Show which words were swapped."
  }
}

test compute_tip {
  functions [ExecuteSkill]
  args {
    query "What's 18% tip on a $47.50 bill?"
    skill_instructions "Solve math problems by using the compute tool. Parse the problem into a Python expression. Set tool_request with tool='compute' and input as the expression. Never do mental math."
  }
}
