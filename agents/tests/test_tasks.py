from helpers import BRIEF, HANDOFF, StudioTestCase


class TaskQueueTests(StudioTestCase):
    def test_task_without_brief_is_a_draft_and_cannot_be_claimed(self) -> None:
        self.new_game()
        out = self.ok("task", "add", "--game", "demo", "--title", "Fix the remote validation", "--owner", "engineer")
        self.assertIn("draft", out)
        out = self.ok("task", "next", "--owner", "engineer")
        self.assertIn("No runnable tasks", out)

    def test_incomplete_brief_is_rejected(self) -> None:
        self.new_game()
        code, out = self.run_cli(
            "task", "add", "--game", "demo", "--title", "x", "--owner", "engineer", "--brief", "-", stdin="Outcome: spend\n"
        )
        self.assertEqual(code, 1)
        self.assertIn("Acceptance criteria", out)

    def test_brief_attaches_and_queues(self) -> None:
        self.new_game()
        self.ok("task", "add", "--game", "demo", "--title", "Build the shop", "--owner", "engineer")
        self.ok("task", "brief", "T-0001", "--brief", "-", stdin=BRIEF)
        task = self.state()["tasks"]["T-0001"]
        self.assertEqual(task["status"], "queued")
        self.assertEqual(task["gates"], ["BUILD-05"])
        self.assertTrue((self.root / "games" / "demo" / "tasks" / "T-0001.md").exists())

    def test_owner_is_routed_by_keywords_when_omitted(self) -> None:
        self.new_game()
        self.ok("task", "add", "--game", "demo", "--title", "Make the icon and three thumbnails")
        self.assertEqual(self.state()["tasks"]["T-0001"]["owner"], "storefront")

    def test_dependencies_block_until_done(self) -> None:
        self.new_game()
        first = self.queued_task("designer")
        second = self.queued_task("engineer", after=[first])
        self.assertIn("No runnable", self.ok("task", "next", "--owner", "engineer"))
        self.assertIn(f"Claimed {first}", self.ok("task", "next", "--owner", "designer"))
        self.ok("task", "submit", first, "--handoff", "-", stdin=HANDOFF)
        self.ok("task", "done", first)
        self.assertIn(f"Claimed {second}", self.ok("task", "next", "--owner", "engineer"))

    def test_one_task_at_a_time_per_role(self) -> None:
        self.new_game()
        first = self.queued_task()
        self.queued_task()
        self.ok("task", "next", "--owner", "engineer")
        out = self.ok("task", "next", "--owner", "engineer")
        self.assertIn(f"Finish {first} first", out)

    def test_handoff_needs_evidence(self) -> None:
        self.new_game()
        task = self.queued_task()
        self.ok("task", "next", "--owner", "engineer")
        code, out = self.run_cli("task", "submit", task, "--handoff", "-", stdin="## Summary\nDone\n## Next\nx\n")
        self.assertEqual(code, 1)
        self.assertIn("Evidence", out)
        self.ok("task", "submit", task, "--handoff", "-", stdin=HANDOFF)
        self.assertEqual(self.state()["tasks"][task]["status"], "needs_review")

    def test_return_puts_task_back_with_reason(self) -> None:
        self.new_game()
        task = self.queued_task()
        self.ok("task", "next", "--owner", "engineer")
        self.ok("task", "submit", task, "--handoff", "-", stdin=HANDOFF)
        self.ok("task", "return", task, "--reason", "BUILD-05 failed: price read from client")
        state = self.state()["tasks"][task]
        self.assertEqual(state["status"], "queued")
        self.assertIn("BUILD-05", state["notes"][-1]["text"])

    def test_done_requires_review_unless_forced(self) -> None:
        self.new_game()
        task = self.queued_task()
        self.ok("task", "next", "--owner", "engineer")
        code, _ = self.run_cli("task", "done", task)
        self.assertEqual(code, 1)
        self.ok("task", "done", task, "--force")

    def test_paused_games_hand_out_no_work(self) -> None:
        self.new_game()
        self.queued_task()
        self.ok("game", "status", "demo", "paused")
        self.assertIn("No runnable", self.ok("task", "next", "--owner", "engineer"))

    def test_unknown_role_is_an_error(self) -> None:
        self.new_game()
        code, out = self.run_cli("task", "next", "--owner", "wizard")
        self.assertEqual(code, 1)
        self.assertIn("Unknown role", out)

    def test_board_lists_needs_and_tasks(self) -> None:
        self.new_game()
        self.queued_task()
        self.ok("escalate", "--kind", "money", "--note", "Buy a sound pack?", "--game", "demo", "--by", "artist")
        board = (self.root / "workspace" / "BOARD.md").read_text()
        self.assertIn("Buy a sound pack?", board)
        self.assertIn("T-0001", board)
