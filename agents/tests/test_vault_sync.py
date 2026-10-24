"""The vault is the source of truth for gates and the roster; these tests fail when copies drift."""

import re
import unittest

from helpers import REPO

from studio import gates
from studio.store import ROLES

VAULT = REPO / "vault" / "16-ai-studio-operations"
AGENT_DIR = REPO / ".claude" / "agents" / "studio"

ROSTER_NAMES = {
    "Director": "director",
    "Scout": "scout",
    "Designer": "designer",
    "Economist": "economist",
    "Monetization Designer": "monetization-designer",
    "Engineer": "engineer",
    "Interface Designer": "interface-designer",
    "Worldbuilder": "worldbuilder",
    "Artist": "artist",
    "Storefront": "storefront",
    "QA Tester": "qa-tester",
    "Newcomer": "newcomer",
    "Security Reviewer": "security-reviewer",
    "Gatekeeper": "gatekeeper",
    "Analyst": "analyst",
}


class VaultSyncTests(unittest.TestCase):
    def test_gate_criteria_match_the_vault(self) -> None:
        text = (VAULT / "quality-gates.md").read_text()
        vault_rows = {
            m.group(1): re.sub(r"\[([^\]]+)\]\([^)]+\)", r"\1", m.group(2))
            for m in re.finditer(r"^\| ([A-Z]+-\d\d) \| (.+?) \|$", text, re.M)
        }
        machine = {c["id"]: c["text"] for c in gates.load()["criteria"]}
        self.assertEqual(sorted(vault_rows), sorted(machine))
        for cid, wording in vault_rows.items():
            self.assertEqual(machine[cid], wording, cid)

    def test_roster_matches_the_vault(self) -> None:
        text = (VAULT / "agent-team-workflow.md").read_text()
        names = re.findall(r"^\| \*\*([^*]+)\*\* \|", text, re.M)
        self.assertEqual(sorted(ROSTER_NAMES[n] for n in names), sorted(ROLES))

    def test_every_role_has_an_agent_definition(self) -> None:
        for role in ROLES:
            path = AGENT_DIR / f"{role}.md"
            self.assertTrue(path.exists(), f"missing {path}")
            head = path.read_text().split("---")[1]
            self.assertRegex(head, rf"(?m)^name: {re.escape(role)}$")
            self.assertRegex(head, r"(?m)^description: .{40,}")

    def test_agent_definitions_link_to_existing_vault_notes(self) -> None:
        for path in AGENT_DIR.glob("*.md"):
            for target in re.findall(r"vault/[\w./-]+\.md", path.read_text()):
                self.assertTrue((REPO / target).exists(), f"{path.name} links to missing {target}")


if __name__ == "__main__":
    unittest.main()
