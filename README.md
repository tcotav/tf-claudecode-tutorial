# GCP Cloud Run Terraform Starter

A sample terraform project for deploying a Cloud Run service on GCP, pre-configured with Claude Code safety hooks.

This repo is designed to be used with [Claude Code](https://claude.ai/download). The README is intentionally short — the real onboarding happens inside Claude Code.

## What This Includes

- Minimal terraform for a Cloud Run service (service account, IAM, public access)
- Claude Code hooks that block `terraform apply`/`destroy` and prompt for approval on safe commands
- An audit log of every terraform command Claude attempts
- A set of guided exercises for learning to work with Claude on infrastructure changes

## About AGENTS.md

`AGENTS.md` is a project context file that Claude Code reads automatically at the start of every session. It tells Claude how to behave in this repository — what commands are safe, what the deployment workflow is, and what to avoid.

This repo ships with a pre-written `AGENTS.md` covering the safety rules and terraform workflow. The setup step below customizes the `REPOSITORY-SPECIFIC CONTEXT` section with your project details, so Claude understands your setup without you re-explaining it each session.

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/install) >= 1.0
- [gcloud CLI](https://cloud.google.com/sdk/docs/install) authenticated (`gcloud auth application-default login`) — required so the terraform Google provider can authenticate during `terraform plan`; no gcloud commands are used directly in this tutorial
- A GCP project with billing enabled — if you don't have one, [create a project](https://cloud.google.com/resource-manager/docs/creating-managing-projects) and [enable billing](https://cloud.google.com/billing/docs/how-to/modify-project) before continuing
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
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
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

This repo already includes an `AGENTS.md` with template instructions for Claude. The prompt below tells Claude to customize the `REPOSITORY-SPECIFIC CONTEXT` section of that file with your project details — it does not replace the whole file.

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

Claude will ask you four questions, then show you a draft of the customized `AGENTS.md` section for your review before writing anything. Since this is a tutorial repo, you can use placeholder or example answers — the goal is to practice the workflow, not to configure a real deployment. Example answers:

- **Application:** "A simple web API that returns JSON — placeholder app for learning"
- **GCP project:** your actual project ID from step 3, or `my-tutorial-project` if using a placeholder
- **Team/access:** "Solo project, authenticating with gcloud ADC locally"
- **Deployment:** "No CI/CD yet — learning the workflow before setting up automation"

Once you approve the draft, Claude will write the customized content into the `AGENTS.md` file.

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
