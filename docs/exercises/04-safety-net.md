# Exercise 04: The Safety Net

**Goal:** Deliberately trigger the safety hooks so you understand what they protect against and why the PR workflow exists.

---

## Before You Start

This exercise behaves differently depending on whether the safety hooks are active. Run the preflight check to confirm your status:

```bash
./check-hooks.sh
```

- **All checks passed** — hooks are active. You will see the hook intercept and block `terraform apply` in real time during Step 1.
- **Any check failed** — hooks are not active. Step 1 will explain what the hooks are, what they would have done, and why that matters before continuing with the theoretical path.

---

## Why This Matters

The hooks aren't just a guardrail for Claude — they encode a workflow. Understanding what gets blocked, why, and what the correct alternative is will change how you think about infrastructure changes in general.

---

## Step 1: Try to apply

Paste this into Claude Code:

```
Run terraform apply to deploy all the changes we've made.
```

**If hooks are active:** The `terraform-validator` hook intercepts the command before it runs and blocks it with exit code 2. Claude Code will show you the hook's output — it explains that `terraform apply` is blocked, why it must go through your PR workflow, and what safe alternatives exist. This is not Claude refusing; it is a system-level block that Claude cannot override. The attempt is also written to the audit log at `.claude/audit/terraform-YYYY-MM-DD.log`.

**If hooks are not active:** Before declining, Claude should surface the following so you understand what you're missing:

> The safety hooks are not active in this session. Here is what they would have done:
>
> - **terraform-validator.py** (PreToolUse hook) would have intercepted this command before execution, blocked it with a clear error message, and written a BLOCKED entry to the audit log. The hook exists because `terraform apply` run directly — without a plan review step, without a PR, and without an audit trail — is the most common source of unintended infrastructure changes in team environments.
>
> - **terraform-logger.py** (PostToolUse hook) would have recorded the result of every approved terraform command — exit code, working directory, and timestamp — so the team has a full record of what Claude ran on their behalf.
>
> Without the hooks, this constraint is enforced only by AGENTS.md and Claude's behavior — not at the system level. To activate the hooks, run `./check-hooks.sh` and fix any reported failures.

Claude should then decline the `terraform apply` request based on AGENTS.md. If it doesn't, ask:

```
Why shouldn't we run terraform apply directly, even to deploy changes we've already reviewed?
```

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

If your hooks are not active, the constraint still lives in AGENTS.md and Claude will respect it — but that is a softer guarantee. Hooks provide system-level enforcement that holds even under time pressure or when prompts are rushed. For a real team environment, run `./check-hooks.sh` and get them operational before using this workflow with production infrastructure.

**Next:** Exercise 05 — prepare your changes for review.
