import json

from helpers import StudioTestCase


class LeaseTests(StudioTestCase):
    def test_one_holder_per_instance(self) -> None:
        self.new_game()
        self.ok("lease", "acquire", "--agent", "engineer")
        code, out = self.run_cli("lease", "acquire", "--agent", "qa-tester")
        self.assertEqual(code, 3)
        self.assertIn("No Studio instance free", out)
        self.ok("lease", "release", "--agent", "engineer")
        self.ok("lease", "acquire", "--agent", "qa-tester")

    def test_two_instances_serve_two_agents(self) -> None:
        self.ok("init", "--studios", "2")
        self.ok("lease", "acquire", "--agent", "engineer")
        self.ok("lease", "acquire", "--agent", "qa-tester")
        self.assertEqual(sorted(self.state()["leases"]), ["studio-1", "studio-2"])

    def test_reacquire_extends_the_same_lease(self) -> None:
        self.new_game()
        self.ok("lease", "acquire", "--agent", "engineer")
        out = self.ok("lease", "acquire", "--agent", "engineer", "--minutes", "90")
        self.assertIn("already holds studio-1", out)

    def test_expired_leases_are_reclaimed(self) -> None:
        self.new_game()
        self.ok("lease", "acquire", "--agent", "engineer")
        path = self.root / "workspace" / "state.json"
        state = json.loads(path.read_text())
        state["leases"]["studio-1"]["expires"] = 0
        path.write_text(json.dumps(state))
        self.ok("lease", "acquire", "--agent", "qa-tester")
        self.assertEqual(self.state()["leases"]["studio-1"]["holder"], "qa-tester")

    def test_mapping_is_reported_on_acquire(self) -> None:
        self.new_game()
        self.ok("lease", "map", "studio-1", "--studio-id", "abc123", "--place", "Demo.rbxl")
        out = self.ok("--json", "lease", "acquire", "--agent", "worldbuilder")
        self.assertEqual(json.loads(out)["studioId"], "abc123")
