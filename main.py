"""
Jabberwocky Boathouse Agent — AgentSkills + BAML demo.

The boathouse has no digital systems. Every action goes through a staff
member who speaks their own dialect. This agent translates plain English
into messages for the right person, and executes actions when confirmed.

Demonstrates:
  - AgentSkills progressive disclosure (discover → activate → reference)
  - BAML structured routing and typed outputs
  - Confirmation flow: draft message → user confirms → action executes
"""

from __future__ import annotations

import re
import textwrap
from dataclasses import dataclass, field
from pathlib import Path

import yaml

from baml_client import b
from baml_client.types import ActionType, SkillOption

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
            self._body = raw[match.end() :].strip() if match else raw.strip()
        return self._body

    def load_references(self) -> str | None:
        """Load reference files (tier 3)."""
        refs_dir = self.base_dir / "references"
        if not refs_dir.is_dir():
            return None
        parts = []
        for ref_file in sorted(refs_dir.glob("*.md")):
            parts.append(f"## {ref_file.stem}\n\n{ref_file.read_text().strip()}")
        return "\n\n".join(parts) if parts else None


def discover_skills() -> dict[str, Skill]:
    """Scan .agents/skills/ for SKILL.md files — tier 1 discovery."""
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
            print(f"  [warn] Skipping {skill_dir.name}: no valid frontmatter")
            continue
        meta = yaml.safe_load(fm_match.group(1))
        name = meta.get("name", skill_dir.name)
        desc = meta.get("description", "")
        if not desc:
            print(f"  [warn] Skipping {name}: missing description")
            continue
        skills[name] = Skill(
            name=name, description=desc, skill_md_path=skill_md, base_dir=skill_dir
        )
    return skills


# ── Boat ledger (in-memory state) ──────────────────────────────────────────

BOATS: dict[str, dict] = {
    "TOV-001": {"name": "The Vorpal Queen", "type": "Tove", "status": "brillig", "checked_out": False},
    "TOV-002": {"name": "Midnight Gyre", "type": "Tove", "status": "outgrabe", "checked_out": False},
    "TOV-003": {"name": "Slithy Dancer", "type": "Tove", "status": "mimsy", "checked_out": False},
    "RTH-001": {"name": "Bandersnatch Express", "type": "Rath", "status": "brillig", "checked_out": False},
    "RTH-002": {"name": "The Tumtum Runner", "type": "Rath", "status": "outgrabe", "checked_out": False},
    "RTH-003": {"name": "Frabjous Day", "type": "Rath", "status": "galumphing", "checked_out": False},
    "MRT-001": {"name": "The Gentle Mome", "type": "Mome rath", "status": "brillig", "checked_out": False},
    "MRT-002": {"name": "Callooh Cruiser", "type": "Mome rath", "status": "brillig", "checked_out": False},
    "JJB-001": {"name": "Wee Gimble", "type": "Jubjub", "status": "brillig", "checked_out": False},
    "JJB-002": {"name": "Burble", "type": "Jubjub", "status": "outgrabe", "checked_out": False},
}


def execute_action(action_type: ActionType, item_id: str | None) -> str | None:
    """Execute a confirmed action against the boat ledger."""
    if action_type == ActionType.NoAction:
        return None

    if not item_id:
        return "Could not execute — no boat code specified."

    item_id = item_id.upper().strip()
    boat = BOATS.get(item_id)
    if boat is None:
        return f"Unknown boat '{item_id}'. Valid codes: {', '.join(sorted(BOATS))}"

    if action_type == ActionType.Checkout:
        if boat["checked_out"]:
            return f"REJECTED: {item_id} ({boat['name']}) is already checked out."
        if boat["status"] != "brillig":
            return (
                f"REJECTED: {item_id} ({boat['name']}) is not available — "
                f"status is '{boat['status']}' (must be 'brillig')."
            )
        boat["checked_out"] = True
        return f"DONE: {item_id} ({boat['name']}) checked out. Enjoy your galumphing!"

    elif action_type == ActionType.Return:
        if not boat["checked_out"]:
            return f"NOTE: {item_id} ({boat['name']}) wasn't checked out."
        boat["checked_out"] = False
        return f"DONE: {item_id} ({boat['name']}) returned. Welcome back from the mome rath sea!"

    elif action_type == ActionType.ReportDamage:
        boat["status"] = "outgrabe"
        return f"DONE: {item_id} ({boat['name']}) marked as outgrabe (needs repair)."

    return None


# ── Display helpers ─────────────────────────────────────────────────────────


def print_result(result) -> None:
    """Pretty-print a SkillResult."""
    print(f"\n{result.plain_summary}")

    if result.messages:
        for msg in result.messages:
            print(f"\n--- Message to {msg.recipient} ---")
            print(msg.message)
            print("---")

    if result.action != ActionType.NoAction and result.action_item_id:
        print(
            f"\n[action: {result.action.value} {result.action_item_id}]"
        )


# ── Main loop ───────────────────────────────────────────────────────────────

HELP_TEXT = textwrap.dedent("""\
    Jabberwocky Boathouse
    =====================
    Talk to me in plain English. I'll figure out who to contact
    at the boathouse and draft the message in their language.

    Try things like:
      "I want to take a sailboat out this afternoon"
      "The boat I rented has a cracked hull"
      "How much do I owe?"
      "What boats are available?"
      "I'm done with the pontoon, bringing it back"

    Commands:
      skills   -- Show available skills
      help     -- Show this message
      quit     -- Leave
""")


def run():
    print("Discovering skills...")
    skills = discover_skills()
    for s in skills.values():
        print(f"  [{s.name}] {s.description.strip()[:72]}...")
    print(f"Found {len(skills)} skill(s).\n")

    skill_options = [
        SkillOption(name=s.name, description=s.description) for s in skills.values()
    ]

    print(HELP_TEXT)

    while True:
        try:
            query = input("you> ").strip()
        except (EOFError, KeyboardInterrupt):
            print("\nCallooh! Callay! Farewell!")
            break

        if not query:
            continue
        if query.lower() in ("quit", "exit"):
            print("Callooh! Callay! Farewell!")
            break
        if query.lower() == "help":
            print(HELP_TEXT)
            continue
        if query.lower() == "skills":
            for s in skills.values():
                print(f"  {s.name}: {s.description.strip()}")
            continue

        # ── Route ───────────────────────────────────────────────────────
        print("\n[routing...]")
        selection = b.SelectSkill(query=query, skills=skill_options)

        if not (selection.selected_skill and selection.selected_skill in skills):
            print(f"[no skill matched — {selection.reasoning}]")
            result = b.GeneralAssist(query=query)
            print(f"\n{result}\n")
            continue

        skill = skills[selection.selected_skill]
        print(f"[activated: {skill.name}]")

        # ── Execute skill ───────────────────────────────────────────────
        instructions = skill.body
        references = skill.load_references()
        result = b.ExecuteSkill(
            query=query,
            skill_instructions=instructions,
            reference_material=references,
        )

        print_result(result)

        # ── Confirm & execute action ────────────────────────────────────
        if result.action != ActionType.NoAction and result.action_item_id:
            try:
                confirm = input("\nSend and execute? [y/n] ").strip().lower()
            except (EOFError, KeyboardInterrupt):
                print("\nCancelled.")
                continue

            if confirm in ("y", "yes"):
                outcome = execute_action(result.action, result.action_item_id)
                if outcome:
                    print(f"\n{outcome}")
            else:
                print("Cancelled — no message sent.")
        print()


if __name__ == "__main__":
    run()
