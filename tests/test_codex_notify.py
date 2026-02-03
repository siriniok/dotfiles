"""Validate notification decisions, complete request text, and safe fallbacks."""
import html
import importlib.util
import io
import json
from pathlib import Path
import subprocess
import sys
import unittest
from unittest.mock import patch

SOURCE = Path(sys.argv.pop(1)).resolve()
sys.dont_write_bytecode = True
spec = importlib.util.spec_from_file_location("codex_notify", SOURCE)
notify = importlib.util.module_from_spec(spec)
spec.loader.exec_module(notify)

APPROVAL = {
    "hook_event_name": "PermissionRequest", "cwd": "/tmp/<project>",
    "tool_name": "Bash", "tool_input": {
        "description": "May I run this exact command?", "command": "printf '<hello>\\n'",
    },
}


class NotificationTests(unittest.TestCase):
    def invoke(self, event, notification="17\n", returncode=0, viewer=(1, "")):
        payload = event if isinstance(event, str) else json.dumps(event)
        output = io.StringIO()
        calls = []
        views = []

        def run(argv, **kwargs):
            calls.append((argv, kwargs))
            if argv[0] == "/mock/gdbus":
                return subprocess.CompletedProcess(argv, 0, "")
            if argv[0] == "/mock/zenity":
                filename = Path(next(arg.split("=", 1)[1] for arg in argv if arg.startswith("--filename=")))
                views.append((filename, filename.read_text(), filename.stat().st_mode & 0o777))
                if isinstance(viewer, Exception):
                    raise viewer
                return subprocess.CompletedProcess(argv, viewer[0], viewer[1])
            if isinstance(notification, Exception):
                raise notification
            return subprocess.CompletedProcess(argv, returncode, notification)

        with patch.object(sys, "stdin", io.StringIO(payload)), \
             patch.object(sys, "stdout", output), \
             patch.object(sys, "argv", [str(SOURCE), "/mock/notify-send", "/mock/zenity", "/mock/gdbus"]), \
             patch.object(notify.subprocess, "run", side_effect=run):
            notify.main()
        for filename, _, _ in views:
            self.assertFalse(filename.exists(), "private request file must be cleaned up")
        return output.getvalue(), calls, views

    def decision(self, output):
        result = json.loads(output)["hookSpecificOutput"]
        self.assertEqual(result["hookEventName"], "PermissionRequest")
        return result["decision"]["behavior"]

    def test_approve_once_and_deny(self):
        for action, behavior in (("approve", "allow"), ("deny", "deny")):
            output, calls, _ = self.invoke(APPROVAL, f"17\n{action}\n")
            self.assertEqual(self.decision(output), behavior)
            argv = calls[0][0]
            self.assertIn("--action=approve=Approve once", argv)
            self.assertIn("--action=deny=Deny", argv)
            self.assertIn("--action=view=Full request…", argv)
            self.assertEqual(calls[1][0][-1], "17")

    def test_whole_request_is_escaped_without_truncation(self):
        event = {**APPROVAL, "tool_input": {
            "description": "a long prompt\n" * 1000 + "THE END <&>",
            "command": "echo hello\necho '<world>'", "other": {"value": 12},
        }}
        output, calls, _ = self.invoke(event)
        self.assertEqual(output, "")
        body = calls[0][0][-1]
        self.assertIn("&lt;project&gt;", body)
        self.assertIn("THE END &lt;&amp;&gt;", body)
        self.assertIn(event['tool_input']['description'], html.unescape(body))
        self.assertIn(event['tool_input']['command'], html.unescape(body))
        self.assertIn('"value": 12', html.unescape(body))
        self.assertNotIn("shell", calls[0][1])

    def test_question_tool_names_and_full_question_contents(self):
        for tool in ("request_user_input", "request_user_input_async",
                     "functions.request_user_input_async", "functions/request_user_input"):
            event = {"hook_event_name": "PreToolUse", "tool_name": tool,
                     "tool_input": {"questions": [{"question": "Which <option>?", "options": ["A", "B"]}]}}
            output, calls, _ = self.invoke(event)
            self.assertEqual(output, "")
            self.assertEqual(len(calls), 1)
            argv, kwargs = calls[0]
            self.assertIn("Codex: answer needed", argv)
            self.assertIn("Which <option>?", html.unescape(argv[-1]))
            self.assertFalse(any(arg.startswith('--action') for arg in argv))
            self.assertEqual(kwargs['timeout'], 3)

    def test_dismissal_unexpected_actions_and_failed_service_never_approve(self):
        for stdout, returncode in (("17\n", 0), ("", 0), ("17\nunknown\n", 0),
                                  ("17\napprove\nextra\n", 0), ("approve\n", 0),
                                  ("17\napprove\n", 1)):
            output, _, _ = self.invoke(APPROVAL, stdout, returncode)
            self.assertEqual(output, "")

    def test_timeout_closes_notification_and_never_approves(self):
        failure = subprocess.TimeoutExpired("notify-send", 120, output=b"17\n")
        output, calls, _ = self.invoke(APPROVAL, failure)
        self.assertEqual(output, "")
        self.assertEqual(calls[-1][0][0], "/mock/gdbus")
        self.assertEqual(calls[-1][0][-1], "17")

    def test_missing_desktop_service_never_approves(self):
        output, _, _ = self.invoke(APPROVAL, FileNotFoundError())
        self.assertEqual(output, "")

    def test_full_request_view_can_approve_deny_or_return_to_codex(self):
        for viewer, behavior in (((0, ""), "allow"), ((1, "Deny\n"), "deny"), ((1, ""), None)):
            output, _, views = self.invoke(APPROVAL, "17\nview\n", viewer=viewer)
            self.assertEqual(self.decision(output) if output else None, behavior)
            self.assertEqual(views[0][1], notify.request_text(APPROVAL))
            self.assertEqual(views[0][2], 0o600)

    def test_full_request_view_timeout_never_approves(self):
        output, _, views = self.invoke(APPROVAL, "17\nview\n", viewer=subprocess.TimeoutExpired("zenity", 1))
        self.assertEqual(output, "")
        self.assertEqual(len(views), 1)

    def test_unrelated_and_invalid_inputs_do_not_notify(self):
        for payload in ("bad json", "null", "[]", "{}", json.dumps({
            "hook_event_name": "PreToolUse", "tool_name": "Bash",
        })):
            output, calls, _ = self.invoke(payload)
            self.assertEqual(output, "")
            self.assertEqual(calls, [])


if __name__ == "__main__":
    unittest.main()
