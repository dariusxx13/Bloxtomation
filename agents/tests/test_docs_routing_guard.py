import json
import unittest

from helpers import BRIEF, HANDOFF, REPO  # noqa: F401  (sets sys.path)

from studio import docs, gates, routing
from studio.store import ROLES

sys_path_hooks = REPO / "agents" / "hooks"
import sys  # noqa: E402

sys.path.insert(0, str(sys_path_hooks))
import guard  # noqa: E402


class BriefTests(unittest.TestCase):
    def test_vault_template_form_is_valid(self) -> None:
        problems, sections = docs.validate_brief(BRIEF, gates.all_ids())
        self.assertEqual(problems, [])
        self.assertIn("Server-side prices", sections["Requirements"])

    def test_heading_form_is_valid(self) -> None:
        text = (
            "## Outcome\nsafety\n## Requirements\n1. validate remotes\n"
            "## Acceptance criteria\n- every remote rate limited (BUILD-04)\n## Evidence to return\ntest log\n"
        )
        self.assertEqual(docs.validate_brief(text, gates.all_ids())[0], [])

    def test_outcome_must_be_one_of_the_five(self) -> None:
        text = BRIEF.replace("Outcome: spend: players can buy upgrades", "Outcome: make it nicer")
        self.assertTrue(any("Outcome" in p for p in docs.validate_brief(text, gates.all_ids())[0]))

    def test_placeholders_do_not_count(self) -> None:
        text = BRIEF.replace("Evidence to return: test output", "Evidence to return: TBD")
        self.assertTrue(any("Evidence to return" in p for p in docs.validate_brief(text, gates.all_ids())[0]))

    def test_unknown_criterion_ids_are_reported(self) -> None:
        text = BRIEF.replace("(BUILD-05)", "(BUILD-99)")
        self.assertIn("unknown gate criterion BUILD-99", docs.validate_brief(text, gates.all_ids())[0])

    def test_handoff(self) -> None:
        self.assertEqual(docs.validate_handoff(HANDOFF, gates.all_ids())[0], [])
        broken = HANDOFF.replace("- tests passed: 47 passed, 0 failed", "")
        self.assertTrue(docs.validate_handoff(broken, gates.all_ids())[0])


class RoutingTests(unittest.TestCase):
    def test_table_roles_exist(self) -> None:
        table = routing.table()
        self.assertIn(table["default"], ROLES)
        for entry in table["roles"]:
            self.assertIn(entry["role"], ROLES)

    def test_examples(self) -> None:
        cases = {
            "Design three thumbnails and the icon": "storefront",
            "Balance the economy sheet pacing for zone 3": "economist",
            "Fix DataStore session locking bug in the server": "engineer",
            "Audit remotes for exploits before release": "security-reviewer",
            "Run the golden path playtest on phone": "qa-tester",
            "Price the starter pack and game passes": "monetization-designer",
            "Find breakout simulator trends in the charts": "scout",
            "Write the GDD core loop and onboarding": "designer",
            "Day-14 postmortem with retention metrics": "analyst",
            "Light the lobby and build the spawn area map": "worldbuilder",
            "Make hatch VFX particles and a pet animation": "artist",
            "Redesign the HUD buttons for mobile layout": "interface-designer",
            "Something vague": "director",
        }
        for text, expected in cases.items():
            self.assertEqual(routing.route(text), expected, text)


class GuardTests(unittest.TestCase):
    def bash(self, command: str):
        return guard.decide({"tool_name": "Bash", "tool_input": {"command": command}})

    def test_blocks_publishing(self) -> None:
        self.assertIsNotNone(self.bash('curl -X POST "https://apis.roblox.com/universes/v1/1/places/2/versions?versionType=Published"'))
        self.assertIsNotNone(self.bash("rojo upload --asset_id 123"))
        self.assertIsNotNone(self.bash("mantle deploy"))

    def test_allows_saved_uploads_and_normal_work(self) -> None:
        self.assertIsNone(self.bash("lune run scripts/upload-place build.rbxl"))
        self.assertIsNone(self.bash("bash scripts/check.sh"))
        self.assertIsNone(self.bash("python3 agents/studioctl.py task next --owner engineer"))

    def test_blocks_human_checkpoints(self) -> None:
        self.assertIsNotNone(self.bash("python3 agents/studioctl.py human approve demo"))
        self.assertIsNotNone(self.bash("python3 agents/studioctl.py --json human resolve E-0001 --note ok"))

    def test_blocks_hand_edits_to_state(self) -> None:
        self.assertIsNotNone(guard.decide({"tool_name": "Write", "tool_input": {"file_path": "/x/workspace/state.json"}}))
        self.assertIsNotNone(self.bash("echo {} > workspace/state.json"))
        self.assertIsNone(self.bash("cat workspace/state.json"))
        self.assertIsNone(guard.decide({"tool_name": "Write", "tool_input": {"file_path": "/x/games/demo/docs/gdd.md"}}))

    def test_bad_input_is_allowed(self) -> None:
        self.assertIsNone(guard.decide({}))


if __name__ == "__main__":
    unittest.main()
