# Project Brief for Claude Code

## Project Overview

This repository is a sample GCP Cloud Run terraform project with Claude Code safety hooks pre-configured. It is designed for software engineers who work with infrastructure occasionally and want to use Claude Code safely and effectively.

**Purpose:**

- Provide a safe, working starting point for GCP Cloud Run terraform projects
- Demonstrate how to use Claude Code as a collaborative partner, not an autopilot
- Block dangerous operations (terraform apply/destroy) at the system level
- Require explicit approval for all terraform commands that read or modify state

**Target Audience:** Software engineers who work with infrastructure occasionally, not SRE specialists.

## Core Philosophy: LLM as Intern

> **Claude Code is your augment, not your replacement. Think of the LLM as an intern working under your supervision.**

You review and approve each action, you are responsible for the work product, you submit the final PR and own the changes. Claude helps you work faster, but you remain the decision maker.

## Repository Structure

```
.claude/
├── settings.json              # Hook configuration (committed)
├── hooks/
│   ├── terraform-validator.py # Pre-execution validation for terraform
│   ├── terraform-logger.py    # Post-execution logging for terraform
│   ├── hook_utils.py          # Shared utilities for hook scripts
│   └── conftest.py            # Shared pytest fixtures
├── skills/
│   └── tf-plan/SKILL.md       # /tf-plan skill: fmt → init → plan → explain
└── audit/                     # Command audit trail (gitignored)

docs/
└── exercises/                 # Tutorial exercises 01-05

main.tf                        # Cloud Run service, service account, IAM
locals.tf                      # Configuration values (project, region, image)
providers.tf                   # Google provider, optional remote state backend
outputs.tf                     # Service URL, service account email
AGENTS.md                      # This file
CLAUDE.md -> AGENTS.md         # Symlink for backwards compatibility
```

## Design Decisions & Constraints

### Safety First

- **Never suggest or run `terraform apply`** — this must always go through the PR workflow
- **Never suggest or run `terraform destroy`** — too destructive to run ad hoc
- Hooks are technically enforced at system level, not by Claude's behavior alone
- All terraform commands require explicit user approval (hook prompts)
- Audit logging records every terraform command attempt with timestamps and decisions
- Local terraform workflow: `terraform init -no-color` and `terraform plan -lock=false -no-color` for validation only

### Documentation Standards

- No emojis — professional tone throughout
- Be specific — show actual commands, concrete examples, specific file paths
- Acknowledge limitations — if something doesn't work or has tradeoffs, say so clearly
- No time estimates

### Don't Do These Things

- **Never run `terraform apply`** (even in examples — always show it being blocked)
- **Don't add emojis** to any documentation
- **Don't make the hooks less strict** without discussing tradeoffs
- **Don't create new files unnecessarily** — prefer editing existing files

## Terraform Workflow

### Available Skills

The `/tf-plan` skill is installed in `.claude/skills/tf-plan/`. Use it when validating terraform changes:

- `/tf-plan` — runs fmt → init (if needed) → plan, then provides a structured summary of what will change

This is the recommended way to validate changes. It detects whether `tofu` or `terraform` is available, handles init automatically, and formats output for easy review. It never runs `apply`.

### Local Validation Workflow (Manual)

If running commands directly rather than via `/tf-plan`:

```bash
terraform init -no-color                    # Initialize providers and modules
terraform plan -lock=false -no-color        # Preview changes without acquiring state lock
terraform validate                          # Check syntax and internal consistency
terraform fmt                               # Format .tf files
terraform output                            # View current outputs
terraform state list                        # List resources in state
terraform state show <resource>             # Inspect a specific resource in state
```

**Important:**
- Use `-lock=false` to avoid blocking other operations
- Use `-no-color` for cleaner output in Claude Code (removes ANSI escape codes)
- Local planning is for viewing changes only, not for applying them

### Deployment Workflow

**All terraform deployments must go through GitHub Pull Requests:**

1. Make terraform changes locally
2. Run `/tf-plan` (or `terraform plan -lock=false -no-color`) to verify
3. Commit changes and create a GitHub PR
4. CI runs `terraform plan` and posts output to the PR for review
5. After review and approval, apply happens via CI or a controlled manual step

**Never run `terraform apply` locally** — maintains audit trail via PR history, team review, and a consistent deployment process.

### Making Terraform Changes with Claude Code

When making terraform changes, follow this lifecycle:

**1. Make the Changes**
- Create or edit terraform files as requested
- Explain each change as you make it
- Follow existing patterns in the codebase (locals for config values, explicit resource references)

**2. Ask the User to Verify**
After making changes, always ask:

> "Would you like me to validate these changes with `/tf-plan`? (runs fmt, init if needed, and plan — no resources will be applied)"

**3. Run Validation (if user approves)**

Use `/tf-plan` or manually:

```bash
terraform init -no-color
terraform plan -lock=false -no-color
```

**4. Explain the Plan Output**
- Summarize what the plan shows ("2 to add, 1 to change, 0 to destroy")
- Explain what `~` (in-place update) vs `-/+` (destroy and recreate) means for each resource
- Call out anything that looks unexpected or potentially destructive
- If there are errors, explain them and suggest fixes

## Key Files to Understand

### [.claude/hooks/terraform-validator.py](./.claude/hooks/terraform-validator.py)

Pre-execution hook that:
- Uses `get_tool_stages()` from `hook_utils.py` to check only stages where terraform is the executable (prevents false positives in git commit messages or comments)
- Blocks dangerous commands (apply, destroy, import, state manipulation)
- Prompts for user approval on safe commands (plan, init, validate, fmt, etc.)
- Logs all attempts to `.claude/audit/terraform-YYYY-MM-DD.log`

### [.claude/hooks/terraform-logger.py](./.claude/hooks/terraform-logger.py)

Post-execution hook that records the result (success/failure, exit code) of any terraform command that was approved and ran.

### [.claude/hooks/hook_utils.py](./.claude/hooks/hook_utils.py)

Shared utilities used by both validator and logger:
- `get_tool_stages()` — splits a command on shell operators and returns only stages where the tool is the executable
- `get_dated_audit_log_path()` — daily-rotated audit log path
- `log_command()` / `log_result()` — audit log writers
- `get_container_warning()` — devcontainer reminder

### [.claude/skills/tf-plan/SKILL.md](./.claude/skills/tf-plan/SKILL.md)

The `/tf-plan` skill. Invoked with `/tf-plan [directory]`. Runs fmt → init (if needed) → plan and provides a structured summary. Detects `tofu` vs `terraform` automatically. Never runs apply.

### [.claude/settings.json](./.claude/settings.json)

Configures which hooks run and when:
- `PreToolUse` (Bash): terraform-validator.py
- `PostToolUse` (Bash): terraform-logger.py

Uses `$CLAUDE_PROJECT_DIR` to locate hooks regardless of working directory.

## Testing the Hooks

Before relying on hooks in a new environment:

```bash
chmod +x .claude/hooks/*.py
pytest .claude/hooks/
```

Tests verify that blocked commands are denied, safe commands prompt for approval, non-terraform commands pass through unchanged, and terraform keywords inside git commit messages do not trigger false positives.

---

# REPOSITORY-SPECIFIC CONTEXT

**Note:** Everything below this line is specific to this repository. The sections above are template content.

When you customize this file for your infrastructure repository, add your repository-specific details in this section using the Interactive Setup Protocol below.

---

## Interactive Setup Protocol (For Claude Code)

When a user asks you to help customize AGENTS.md, or when they run the setup prompt from the README, follow this protocol:

### Question Sequence

Ask these questions one at a time, waiting for the user's response before proceeding:

**1. Infrastructure Overview**
```
What GCP services does this repository manage or will it manage?

Please describe:
- The application this Cloud Run service will run
- Your GCP project name or ID (you can use a placeholder if preferred)
- The region you plan to deploy to
- Any other GCP services this app depends on (Cloud SQL, Pub/Sub, GCS, etc.)
```

**2. Team and Access**
```
Who works in this repository, and how do they access GCP?

Consider:
- Is this a solo project or a team repo?
- How do developers authenticate to GCP locally (gcloud ADC, service account key, Workload Identity)?
- Are there multiple environments (dev, staging, prod)?
```

**3. Deployment Workflow**
```
How do you deploy terraform changes?

Examples:
- Manual: developer runs terraform apply after PR merge
- GitHub Actions: CI runs terraform plan on PR, applies on merge to main
- Cloud Build: GCP-native CI/CD pipeline
- Other tools: Atlantis, Terraform Cloud, etc.
```

**4. Special Constraints**
```
Are there things people should know before making changes to this repo?

Consider:
- Naming conventions for resources
- Cost-sensitive resources (Cloud SQL, load balancers)
- Resources that require extra care (anything with live traffic or persistent data)
- Links to runbooks, architecture diagrams, or team documentation
```

### After Collecting Answers

Present a draft of the REPOSITORY-SPECIFIC CONTEXT section with the user's details filled in. Show the draft before writing it. Ask the user to confirm or revise. Then add the customized content below this line, preserving the template content above.

---

## Tutorial Guide (For Claude Code)

This section tells Claude how to guide users through the exercises in `docs/exercises/`.

### When to Activate Tutorial Mode

Activate tutorial mode when the user says any of:
- "start the tutorial"
- "let's do the exercises"
- "walk me through this"
- "next exercise"
- "I'm ready to start"

### How to Guide Each Exercise

For each exercise:
1. Read the exercise file at `docs/exercises/XX-name.md`
2. Set context: tell the user what they'll learn and why it matters (1-2 sentences)
3. Present Step 1 and wait for the user to attempt it
4. After the user responds or completes the step, debrief and present Step 2
5. Continue through all steps before moving to the next exercise
6. At the end of each exercise, ask: "Ready to move on to Exercise 0X?" before proceeding

### Pacing and Partner Behavior

- Do not rush through steps — wait for the user to actually try each prompt
- When the user asks a question that's not in the exercise script, answer it — curiosity is the point
- If a user skips a step, note what they missed and offer to come back to it
- If Claude's output doesn't match what the exercise says to look for, acknowledge the discrepancy and explain it
- After each exercise, summarize what the user learned in 2-3 sentences

### Exercise Sequence

```
docs/exercises/01-orient.md       → Using Claude as a reader
docs/exercises/02-modify.md       → Modifying an existing resource
docs/exercises/03-add-resource.md → Adding a new resource
docs/exercises/04-safety-net.md   → Experiencing the safety hooks
docs/exercises/05-pr-handoff.md   → Preparing changes for review
```

### If the User Wants to Skip Around

That's fine. Ask which exercise they want and go there directly. All exercises are self-contained, though Exercise 03 builds on the changes from Exercise 02 if the user wants a continuous working session.

### After All Exercises Are Complete

Suggest the "What's Next" section at the bottom of Exercise 05, and offer to help them customize AGENTS.md for their own project using the Interactive Setup Protocol above.
