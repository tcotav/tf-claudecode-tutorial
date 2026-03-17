#!/usr/bin/env bash
# check-hooks.sh — Preflight check for Claude Code hook configuration.
# Run this before starting the tutorial to confirm hooks are wired up correctly.
# Usage: ./check-hooks.sh

set -euo pipefail

HOOKS_DIR=".claude/hooks"
SETTINGS=".claude/settings.json"
PASS=0
FAIL=0

ok()   { echo "  [OK]  $*"; ((PASS++)) || true; }
fail() { echo "  [FAIL] $*"; ((FAIL++)) || true; }

echo ""
echo "=== Claude Code Hook Preflight Check ==="
echo ""

# 1. Python 3
echo "Checking Python 3..."
if command -v python3 &>/dev/null; then
    ok "python3 found: $(python3 --version)"
else
    fail "python3 not found — install Python 3.9+ before continuing"
fi

# 2. pytest (system or venv)
echo "Checking pytest..."
if python3 -m pytest --version &>/dev/null 2>&1; then
    ok "pytest found: $(python3 -m pytest --version 2>&1 | head -1)"
else
    fail "pytest not found — run: python3 -m venv .venv && source .venv/bin/activate && pip install -r requirements.txt"
fi

# 3. Hook scripts exist
echo "Checking hook scripts..."
for script in terraform-validator.py terraform-logger.py hook_utils.py; do
    if [[ -f "$HOOKS_DIR/$script" ]]; then
        ok "$script exists"
    else
        fail "$script missing from $HOOKS_DIR/"
    fi
done

# 4. Hook scripts are executable
echo "Checking hook script permissions..."
for script in terraform-validator.py terraform-logger.py; do
    if [[ -x "$HOOKS_DIR/$script" ]]; then
        ok "$script is executable"
    else
        fail "$script is not executable — run: chmod +x $HOOKS_DIR/$script"
    fi
done

# 5. settings.json is present and references the hooks
echo "Checking settings.json..."
if [[ -f "$SETTINGS" ]]; then
    ok "settings.json found"
    if grep -q "terraform-validator.py" "$SETTINGS" && grep -q "terraform-logger.py" "$SETTINGS"; then
        ok "hooks are registered in settings.json"
    else
        fail "hooks not registered in settings.json — check PreToolUse / PostToolUse configuration"
    fi
else
    fail "$SETTINGS not found"
fi

# 6. Smoke test: validator accepts valid JSON and exits cleanly
echo "Smoke testing terraform-validator.py..."
SMOKE_INPUT='{"tool_name":"Bash","tool_input":{"command":"terraform plan"},"cwd":"/tmp"}'
if echo "$SMOKE_INPUT" | python3 "$HOOKS_DIR/terraform-validator.py" &>/dev/null; then
    ok "terraform-validator.py smoke test passed (terraform plan — expected: ask)"
else
    fail "terraform-validator.py crashed on valid input"
fi

BLOCK_INPUT='{"tool_name":"Bash","tool_input":{"command":"terraform apply"},"cwd":"/tmp"}'
if echo "$BLOCK_INPUT" | python3 "$HOOKS_DIR/terraform-validator.py" &>/dev/null; then
    fail "terraform-validator.py did NOT block terraform apply — hook logic is broken"
else
    ok "terraform-validator.py correctly blocks terraform apply (exit 2)"
fi

# 7. pytest suite
echo "Running hook test suite..."
if python3 -m pytest "$HOOKS_DIR/" -q --tb=short 2>&1; then
    ok "all hook tests passed"
else
    fail "hook tests failed — fix errors above before starting the tutorial"
fi

# --- Summary ---
echo ""
echo "=== Results: $PASS passed, $FAIL failed ==="
echo ""

if [[ $FAIL -gt 0 ]]; then
    echo "Fix the failures above, then re-run this script before starting the tutorial."
    exit 1
else
    echo "All checks passed. Hooks are operational — you're ready to start the tutorial."
    echo ""
    echo "Open Claude Code in this directory and say: start the tutorial"
    exit 0
fi
