import json

from helpers import StudioTestCase


class GateTests(StudioTestCase):
    def review(self, stage: str, verdict: str = "pass", build: str = "", overrides: dict = None) -> str:
        self.ok("gate", "template", "demo", "--stage", stage, "--build", build)
        path = self.root / "games" / "demo" / "gates" / f"{stage}-draft.json"
        data = json.loads(path.read_text())
        for entry in data["results"].values():
            entry["verdict"] = verdict
            entry["evidence"] = "games/demo/docs/notes.md"
            if verdict == "fail":
                entry["needed"] = "numbers with sources"
        for cid, entry in (overrides or {}).items():
            data["results"][cid] = entry
        path.write_text(json.dumps(data))
        return str(path)

    def stage(self) -> str:
        return self.state()["games"]["demo"]["stage"]

    def test_template_lists_every_criterion_of_the_stage(self) -> None:
        self.new_game()
        self.ok("gate", "template", "demo")
        data = json.loads((self.root / "games" / "demo" / "gates" / "pitch-draft.json").read_text())
        self.assertEqual(sorted(data["results"]), [f"PITCH-0{i}" for i in range(1, 9)])

    def test_failures_must_say_what_would_pass(self) -> None:
        self.new_game()
        path = self.review("pitch", overrides={"PITCH-05": {"verdict": "fail", "evidence": "x"}})
        code, out = self.run_cli("gate", "record", "demo", "--review", path)
        self.assertEqual(code, 1)
        self.assertIn("needed", out)

    def test_failed_gate_keeps_the_stage_and_counts(self) -> None:
        self.new_game()
        path = self.review("pitch", "fail")
        self.ok("gate", "record", "demo", "--review", path)
        self.assertEqual(self.stage(), "pitch")
        self.assertIn("PITCH-01", self.ok("gate", "stats"))

    def test_human_checkpoint_after_pitch(self) -> None:
        self.new_game()
        self.ok("gate", "record", "demo", "--review", self.review("pitch"))
        self.assertEqual(self.state()["games"]["demo"]["awaitingHuman"], "pitch")
        code, _ = self.run_cli("gate", "record", "demo", "--review", self.review("pitch"))
        self.assertEqual(code, 1, "no new gates while waiting for the human")
        self.ok("human", "approve", "demo")
        self.assertEqual(self.stage(), "design")

    def test_design_passes_straight_through(self) -> None:
        self.new_game()
        self.ok("gate", "record", "demo", "--review", self.review("pitch"))
        self.ok("human", "approve", "demo")
        self.ok("gate", "record", "demo", "--review", self.review("design"))
        self.assertEqual(self.stage(), "prototype")

    def test_prototype_decision(self) -> None:
        self.new_game()
        self.ok("gate", "record", "demo", "--review", self.review("pitch"))
        self.ok("human", "approve", "demo")
        self.ok("gate", "record", "demo", "--review", self.review("design"))
        self.ok("gate", "record", "demo", "--review", self.review("prototype"))
        code, _ = self.run_cli("human", "approve", "demo")
        self.assertEqual(code, 1, "prototype needs continue, pivot or stop")
        self.ok("human", "approve", "demo", "--decision", "pivot")
        self.assertEqual(self.stage(), "design")

    def test_wrong_stage_is_refused(self) -> None:
        self.new_game()
        code, out = self.run_cli("gate", "record", "demo", "--review", self.review("build", build="abc"))
        self.assertEqual(code, 1)
        self.assertIn("cannot record a build gate", out)

    def _to_build(self) -> None:
        self.new_game()
        self.ok("gate", "record", "demo", "--review", self.review("pitch"))
        self.ok("human", "approve", "demo")
        self.ok("gate", "record", "demo", "--review", self.review("design"))
        self.ok("gate", "record", "demo", "--review", self.review("prototype"))
        self.ok("human", "approve", "demo", "--decision", "continue")

    def _check_record(self, build: str, passed: bool = True, release: bool = False) -> str:
        checks = self.root / "games" / "demo" / "checks"
        checks.mkdir(parents=True, exist_ok=True)
        name = f"20261024T000000Z-{build}{'-r' if release else ''}.json"
        (checks / name).write_text(json.dumps({"build": build, "passed": passed, "release": release}))
        return f"games/demo/checks/{name}"

    def test_mechanical_criteria_need_a_passing_check_for_the_same_build(self) -> None:
        self._to_build()
        stale = self._check_record("oldbuild")
        evidence = {cid: {"verdict": "pass", "evidence": stale} for cid in ("BUILD-01", "BUILD-02", "BUILD-03")}
        code, out = self.run_cli("gate", "record", "demo", "--review", self.review("build", build="newbuild", overrides=evidence))
        self.assertEqual(code, 1)
        self.assertIn("BUILD-01", out)
        fresh = self._check_record("newbuild")
        evidence = {cid: {"verdict": "pass", "evidence": fresh} for cid in ("BUILD-01", "BUILD-02", "BUILD-03")}
        self.ok("gate", "record", "demo", "--review", self.review("build", build="newbuild", overrides=evidence))
        self.assertEqual(self.stage(), "polish")

    def test_failing_check_record_does_not_count(self) -> None:
        self._to_build()
        broken = self._check_record("b1", passed=False)
        evidence = {cid: {"verdict": "pass", "evidence": broken} for cid in ("BUILD-01", "BUILD-02", "BUILD-03")}
        code, _ = self.run_cli("gate", "record", "demo", "--review", self.review("build", build="b1", overrides=evidence))
        self.assertEqual(code, 1)

    def test_waivers_wait_for_the_human(self) -> None:
        self._to_build()
        fresh = self._check_record("b2")
        overrides = {cid: {"verdict": "pass", "evidence": fresh} for cid in ("BUILD-01", "BUILD-02", "BUILD-03")}
        overrides["BUILD-12"] = {"verdict": "waived", "evidence": "no assets", "reason": "placeholder parts only"}
        self.ok("gate", "record", "demo", "--review", self.review("build", build="b2", overrides=overrides))
        game = self.state()["games"]["demo"]
        self.assertEqual(game["awaitingHuman"], "build")
        self.assertEqual(game["stage"], "build")
        board = (self.root / "workspace" / "BOARD.md").read_text()
        self.assertIn("BUILD-12", board)

    def test_waiver_needs_a_reason(self) -> None:
        self.new_game()
        path = self.review("pitch", overrides={"PITCH-06": {"verdict": "waived", "evidence": "x"}})
        code, out = self.run_cli("gate", "record", "demo", "--review", path)
        self.assertEqual(code, 1)
        self.assertIn("reason", out)
