# GCP Cloud Run Terraform Starter

A sample terraform project for deploying a Cloud Run service on GCP, pre-configured with Claude Code safety hooks.

This repo is designed to be used with [Claude Code](https://claude.ai/download). The README is intentionally short — the real onboarding happens inside Claude Code.

## What This Includes

- Minimal terraform for a Cloud Run service (service account, IAM, public access)
- Claude Code hooks that block `terraform apply`/`destroy` and prompt for approval on safe commands
- An audit log of every terraform command Claude attempts
- A set of guided exercises for learning to work with Claude on infrastructure changes

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/install) >= 1.0
- [gcloud CLI](https://cloud.google.com/sdk/docs/install) authenticated (`gcloud auth application-default login`)
- A GCP project with billing enabled
- [Claude Code](https://claude.ai/download)
- Python 3.x (for the safety hooks)

## Setup

**1. Clone the repo and make hooks executable:**

```bash
git clone <this-repo-url>
cd tftutorial
chmod +x .claude/hooks/*.py
```

**2. Verify the hooks work:**

```bash
pytest .claude/hooks/
```

**3. Set your GCP project in `locals.tf`:**

```hcl
locals {
  project_id = "your-actual-project-id"   # change this
  ...
}
```

**4. Open Claude Code:**

```bash
claude
```

**5. Paste this prompt to start:**

```
I've just set up this GCP Cloud Run terraform repo with Claude Code safety hooks.
Help me customize the AGENTS.md file for my project by asking me questions about:

- The application this Cloud Run service will run
- My GCP project and deployment setup
- Who works in this repo and how we deploy changes
- Any special conventions or constraints

Ask me one question at a time. After I answer each question, ask the next one.
When you have enough information, show me a draft of the customized AGENTS.md
sections for my review before making any changes.
```

## Running the Exercises

After setup, if you want a guided walkthrough of how to use Claude Code effectively with terraform:

```
Start the tutorial.
```

Claude will guide you through five exercises covering: reading the codebase, modifying resources, adding resources, understanding the safety hooks, and preparing changes for PR review.

## What Gets Blocked

Claude Code cannot run `terraform apply`, `terraform destroy`, or any state manipulation commands. These require your standard PR workflow.

All other terraform commands (`plan`, `init`, `validate`, `fmt`, `output`) prompt for your explicit approval before running.

## What Stays the Same

The hooks only affect Claude Code. You can still run any terraform command directly in your terminal.

## Credits

The Claude Code safety hooks (`.claude/hooks/`) and the `/tf-plan` skill (`.claude/skills/tf-plan/`) are sourced from [ccode_infra_starter](https://github.com/tcotav/ccode_infra_starter), a template for teams using Claude Code safely with terraform and Helm.
