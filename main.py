"""
AgentSkills + BAML demo — a chat agent that learns new tricks from skills.

Drop a skill folder into .agents/skills/ and the chatbot gains a new
capability. Skills can teach it new knowledge (like a translation dialect)
or new behaviors (like using a calculator tool for math).

Demonstrates:
  - AgentSkills progressive disclosure (name/description → full instructions)
  - BAML structured routing and typed outputs
  - Skills that direct tool use (calculator → compute tool)
"""

from __future__ import annotations

import math
import re
from dataclasses import dataclass, field
from pathlib import Path

import yaml

from baml_client import b
from baml_client.types import Compute, SkillOption

# ── Skill discovery & loading ───────────────────────────────────────────────

SKILLS_DIR = Path(__file__).parent / ".agents" / "skills"


@dataclass
class Skill:
    name: str
    description: str
    skill_md_path: Path
    base_dir: Path
    _body: str | None = field(default=None, repr=False)

    @property
    def body(self) -> str:
        """Lazy-load the SKILL.md body (tier 2)."""
        if self._body is None:
            raw = self.skill_md_path.read_text()
            match = re.match(r"^---\s*\n.*?\n---\s*\n", raw, re.DOTALL)
            self._body = raw[match.end():].strip() if match else raw.strip()
        return self._body


def discover_skills() -> dict[str, Skill]:
    """Scan .agents/skills/ for SKILL.md files — only loads name + description."""
    skills: dict[str, Skill] = {}
    if not SKILLS_DIR.is_dir():
        return skills
    for skill_dir in sorted(SKILLS_DIR.iterdir()):
        skill_md = skill_dir / "SKILL.md"
        if not skill_md.is_file():
            continue
        raw = skill_md.read_text()
        fm_match = re.match(r"^---\s*\n(.*?)\n---", raw, re.DOTALL)
        if not fm_match:
            continue
        meta = yaml.safe_load(fm_match.group(1))
        name = meta.get("name", skill_dir.name)
        desc = meta.get("description", "")
        if not desc:
            continue
        skills[name] = Skill(
            name=name, description=desc, skill_md_path=skill_md, base_dir=skill_dir
        )
    return skills


# ── Tools ───────────────────────────────────────────────────────────────────

def tool_compute(expression: str) -> str:
    """Evaluate a Python math expression safely."""
    allowed_names = {k: v for k, v in math.__dict__.items() if not k.startswith("_")}
    allowed_names["math"] = math
    allowed_names["round"] = round
    allowed_names["abs"] = abs
    try:
        result = eval(expression, {"__builtins__": {}}, allowed_names)
        return str(result)
    except Exception as e:
        return f"Error: {e}"


# ── Main loop ───────────────────────────────────────────────────────────────

def run():
    print("Discovering skills...")
    skills = discover_skills()
    for s in skills.values():
        print(f"  + {s.name}: {s.description.strip()[:72]}...")
    if not skills:
        print("  (none found)")
    print()

    skill_options = [
        SkillOption(name=s.name, description=s.description) for s in skills.values()
    ]
    print("Chat agent ready. Type 'quit' to exit, 'skills' to list skills.\n")

    while True:
        try:
            query = input("you> ").strip()
        except (EOFError, KeyboardInterrupt):
            print("\nBye!")
            break

        if not query:
            continue
        if query.lower() in ("quit", "exit"):
            print("Bye!")
            break
        if query.lower() == "skills":
            for s in skills.values():
                print(f"  {s.name}: {s.description.strip()}")
            if not skills:
                print("  (none)")
            print()
            continue

        # ── Route ───────────────────────────────────────────────────────
        selection = b.SelectSkill(query=query, skills=skill_options)

        if not (selection.selected_skill and selection.selected_skill in skills):
            # No skill matched — plain chat
            response = b.Chat(query=query)
            print(f"\n{response}\n")
            continue

        skill = skills[selection.selected_skill]
        print(f"  [skill: {skill.name}]")

        # ── Execute skill ───────────────────────────────────────────────
        result = b.ExecuteSkill(
            query=query,
            skill_instructions=skill.body,
        )

        if isinstance(result.tool_request, Compute):
            # Skill requested a compute tool call — execute it
            tr = result.tool_request
            print(f"  [tool: compute({tr.expression})]")
            tool_result = tool_compute(tr.expression)
            print(f"  [result: {tool_result}]")

            # Second LLM call with the tool result
            response = b.FinishWithToolResult(
                query=query,
                skill_instructions=skill.body,
                partial_response=result.response,
                tool_name="compute",
                tool_result=tool_result,
            )
            print(f"\n{response}\n")
        else:
            # No tool needed — skill produced the full response
            print(f"\n{result.response}\n")


if __name__ == "__main__":
    run()
