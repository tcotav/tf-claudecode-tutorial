# Exercise 04: The Safety Net

**Goal:** Deliberately trigger the safety hooks so you understand what they protect against and why the PR workflow exists.

---

## Before You Start

This exercise depends on the safety hooks being active and working. If you skipped the hook verification step in setup, go back and run it now:

```bash
source .venv/bin/activate
pytest .claude/hooks/
```

All tests must pass. If any fail, the blocks in this exercise will not work as described.

---

## Why This Matters

The hooks aren't just a guardrail for Claude — they encode a workflow. Understanding what gets blocked, why, and what the correct alternative is will change how you think about infrastructure changes in general.

---

## Step 1: Try to apply

Paste this into Claude Code:

```
Run terraform apply to deploy all the changes we've made.
```

**What happens:** The terraform-validator hook intercepts the command before it runs and blocks it with an explanation. Claude Code will show you the hook's output.

**What to look for:** The hook message should tell you that `terraform apply` is blocked and why — it must go through your PR workflow. This is not Claude refusing; it's a system-level block that Claude cannot override.

---

## Step 2: Ask Claude to explain the block

```
Why was that blocked? Explain the difference between running terraform apply locally and going through a PR workflow.
```

**What to look for:** Claude should explain:
- Local `terraform apply` has no review step, no audit trail, and no way to catch mistakes before they hit your infrastructure
- A PR workflow runs `terraform plan` in CI, shows the plan to reviewers, and applies only after approval
- The hook enforces this workflow technically — it's not a suggestion

---

## Step 3: Ask what "should" happen instead

```
If I've finished my changes and I'm confident in the terraform plan output, what's the correct next step to actually deploy these changes?
```

**What to look for:** Claude should walk you through the intended workflow:
1. Commit your changes
2. Push to a branch and open a PR
3. CI runs `terraform plan` and posts the output to the PR
4. A teammate reviews the plan output
5. After approval and merge, CI runs `terraform apply` (or your team applies manually)

---

## Step 4: Ask about the manual escape hatch

```
Can I still run terraform apply myself in my terminal, outside of Claude Code?
```

**What to look for:** Claude should confirm that yes — the hooks only restrict what Claude Code runs on your behalf. You can always run commands directly in your terminal. The hooks are about keeping AI-assisted changes auditable and reviewed, not about restricting you.

---

## Step 5: Ask about the audit log

```
Is there a record of everything that was attempted and blocked during this session?
```

**What to look for:** Claude should point you to `.claude/audit/terraform-YYYY-MM-DD.log`. Look at it — you'll see JSON entries for every terraform command that was attempted, including the blocked `apply`, with timestamps and working directories.

You can view it with:

```
Show me the contents of the audit log for today.
```

---

## Debrief

The safety net isn't about distrust — it's about workflow. Local `terraform apply` is fast and convenient, which is exactly why it's dangerous in a team environment. A plan that looks correct to you might have side effects a second set of eyes would catch.

The hooks make the PR workflow the path of least resistance when working with Claude. That's intentional.

**Next:** Exercise 05 — prepare your changes for review.
