// TYPEBUILDER variant — @@dynamic enum populated at runtime.
// Used by main_typebuilder.py.

enum AvailableSkill {
  @@dynamic
}

function SelectSkillTB(query: string) -> AvailableSkill? {
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
