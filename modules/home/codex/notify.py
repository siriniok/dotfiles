"""A Codex hook for sending native notifications from vscode. Show full Codex requests and return decisions only after explicit user actions."""
import html
import json
import re
import subprocess
import sys
import tempfile
import time

APPROVAL_TIMEOUT = 120


def request_text(event):
    parts = [f"Tool: {event.get('tool_name', 'unknown')}",
             f"Directory: {event.get('cwd', 'unknown')}"]
    tool_input = event.get("tool_input", {})
    if isinstance(tool_input, dict):
        for key, value in tool_input.items():
            text = value if isinstance(value, str) else json.dumps(value, ensure_ascii=False, indent=2)
            parts.append(f"{key}:\n{text}")
    else:
        parts.append(json.dumps(tool_input, ensure_ascii=False, indent=2))
    return "\n\n".join(parts)


def close_notification(output):
    # --print-id precedes the selected action. Only accept a numeric D-Bus id.
    if isinstance(output, bytes):
        output = output.decode("utf-8", errors="replace")
    lines = (output or "").splitlines()
    if not lines or not re.fullmatch(r"[0-9]+", lines[0]):
        return
    try:
        subprocess.run(
            [sys.argv[3], "call", "--session", "--dest", "org.freedesktop.Notifications",
             "--object-path", "/org/freedesktop/Notifications", "--method",
             "org.freedesktop.Notifications.CloseNotification", lines[0]],
            stdin=subprocess.DEVNULL, stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL, timeout=2, check=False,
        )
    except (OSError, subprocess.TimeoutExpired):
        pass


def view_request(text, timeout):
    # Zenity's text view is scrollable and plain text; the temporary file is private.
    with tempfile.NamedTemporaryFile(mode="w", encoding="utf-8", suffix=".txt") as request:
        request.write(text)
        request.flush()
        result = subprocess.run(
            [sys.argv[2], "--text-info", f"--filename={request.name}",
             "--title=Codex: full approval request", "--width=900", "--height=650",
             "--ok-label=Approve once", "--cancel-label=Back to Codex", "--extra-button=Deny"],
            stdin=subprocess.DEVNULL, stdout=subprocess.PIPE,
            stderr=subprocess.DEVNULL, text=True, timeout=timeout, check=False,
        )
    if result.returncode in (0, 1) and result.stdout.strip() == "Deny":
        return "deny"
    if result.returncode == 0 and not result.stdout.strip():
        return "allow"
    return None


def approval(command, text):
    deadline = time.monotonic() + APPROVAL_TIMEOUT
    try:
        result = subprocess.run(
            [*command, "--print-id", "--action=approve=Approve once",
             "--action=deny=Deny", "--action=view=Full request…",
             "--", "Codex: approval required", html.escape(text)],
            stdin=subprocess.DEVNULL, stdout=subprocess.PIPE,
            stderr=subprocess.DEVNULL, text=True, timeout=APPROVAL_TIMEOUT, check=False,
        )
    except subprocess.TimeoutExpired as error:
        close_notification(error.stdout)
        return None
    close_notification(result.stdout)
    if result.returncode != 0:
        return None
    lines = result.stdout.splitlines()
    if len(lines) != 2 or not re.fullmatch(r"[0-9]+", lines[0]):
        return None
    action = lines[1]
    if action == "approve":
        return "allow"
    if action == "deny":
        return "deny"
    if action == "view":
        remaining = deadline - time.monotonic()
        if remaining > 0:
            return view_request(text, remaining)
    return None


def main():
    try:
        event = json.load(sys.stdin)
        if not isinstance(event, dict):
            return
        kind = event.get("hook_event_name")
        is_question = kind == "PreToolUse" and re.search(
            r"(^|.*[./])request_user_input(_async)?$", str(event.get("tool_name", ""))
        )
        if kind != "PermissionRequest" and not is_question:
            return
        text = request_text(event)
        command = [sys.argv[1], "--app-name=Codex", "--icon=dialog-question",
                   "--urgency=normal", "--expire-time=0"]
        if is_question:
            # Do not wait here: Codex still needs to open its question interface.
            subprocess.run(
                [*command, "--", "Codex: answer needed", html.escape(text)],
                stdin=subprocess.DEVNULL, stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL, timeout=3, check=False,
            )
            return
        decision = approval(command, text)
        if decision:
            response = {"behavior": decision}
            if decision == "deny":
                response["message"] = "Denied from the Codex desktop notification."
            print(json.dumps({"hookSpecificOutput": {
                "hookEventName": "PermissionRequest", "decision": response,
            }}))
    except (ValueError, OSError, subprocess.TimeoutExpired):
        # Missing desktop services or a timeout leave approval to Codex.
        pass


if __name__ == "__main__":
    main()
