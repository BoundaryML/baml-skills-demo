// AgentSkills + BAML demo — TYPEBUILDER variant.
//
// AvailableSkill is a @@dynamic enum — the harness populates it at startup
// via TypeBuilder based on which skills are discovered on disk. The LLM
// can only return valid skill names (or null).

enum AvailableSkill {
  @@dynamic
}

function SelectSkill(query: string) -> AvailableSkill? {
  client "anthropic/claude-sonnet-4-20250514"
  prompt #"
    You route user messages to the right skill. Pick the single best
    match from the list, or return null if the message is just normal
    conversation.

    User message:
    {{ query }}

    {{ ctx.output_format }}
  "#
}
