// PLAIN DATA variant — skills passed as a SkillOption[] list.
// Used by main_plain.py.

class SkillOption {
  name string
  description string
}

class SkillSelection {
  selected_skill string?  @description("Skill name to activate, or null if none match.")
  reasoning string        @description("One-sentence explanation.")
}

function SelectSkillPlain(query: string, skills: SkillOption[]) -> SkillSelection {
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

// ── Tests ──────────────────────────────────────────────────────────────────

test plain_route_translate {
  functions [SelectSkillPlain]
  args {
    query "Translate this to Jabberwocky: I went for a walk in the meadow"
    skills [
      { name "jabberwocky-translate", description "Translate between English and Jabberwocky dialect." },
      { name "calculator", description "Solve math problems using the compute tool." }
    ]
  }
}

test plain_route_calculator {
  functions [SelectSkillPlain]
  args {
    query "What's 18% tip on a $47.50 bill?"
    skills [
      { name "jabberwocky-translate", description "Translate between English and Jabberwocky dialect." },
      { name "calculator", description "Solve math problems using the compute tool." }
    ]
  }
}

test plain_route_none {
  functions [SelectSkillPlain]
  args {
    query "Hey, how's it going?"
    skills [
      { name "jabberwocky-translate", description "Translate between English and Jabberwocky dialect." },
      { name "calculator", description "Solve math problems using the compute tool." }
    ]
  }
}
