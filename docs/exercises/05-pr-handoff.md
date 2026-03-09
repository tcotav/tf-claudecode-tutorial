# Exercise 05: The PR Handoff

**Goal:** Use Claude to prepare your changes for review — commit message, PR description, and reviewer guidance.

---

## Why This Matters

The last step of working with Claude isn't merging or applying — it's handing off. Claude can help you write clear commit messages, explain the changes to reviewers who weren't part of your session, and call out the specific things that need human eyes before deployment.

---

## Step 1: Ask Claude for a commit message

Paste this into Claude Code:

```
Write a git commit message for the changes we made in these exercises: resource limits on the Cloud Run service, and a Cloud Storage bucket with read/write access for the service account.
```

**What to look for:** A good commit message from Claude should:
- Have a short subject line (under 72 characters) that says *what* changed
- Have a body that explains *why* — what problem this solves or what behavior it enables
- Not just be a list of files changed

If Claude produces something generic like "Update main.tf", ask it to be more specific:

```
That's too generic. The commit message should tell a reviewer what infrastructure changed and why, not just that files were modified.
```

---

## Step 2: Ask Claude to write a PR description

```
Write a PR description for these changes. Include: a summary of what changed, which GCP resources are affected, and what a reviewer should specifically look for in the terraform plan output.
```

**What to look for:** The PR description should have three clear sections:
1. **What changed** — plain English description of the infrastructure changes
2. **Resources affected** — the specific terraform resources being added or modified
3. **What to review in the plan** — concrete things the reviewer should verify (e.g., "confirm the IAM role is `storage.objectUser`, not `objectAdmin`", "confirm the service update is in-place, not a replace")

The third section is what separates a useful PR from one that just says "please review."

---

## Step 3: Ask what the reviewer should check in CI

```
When CI runs terraform plan on this PR, what specific things should a reviewer verify before approving?
```

**What to look for:** Claude should surface things like:
- The plan shows 2 to add, 1 to change, 0 to destroy (no unexpected destroys)
- The Cloud Run service update is `~` (in-place), not `-/+` (destroy and recreate)
- The IAM role on the bucket is scoped correctly
- The bucket name won't conflict with an existing globally-named bucket

This is useful prompt to include in your PR template if you're setting one up.

---

## Step 4: Stage and commit (you do this part)

Claude cannot run `git push` or create a PR on your behalf. That handoff is yours. But it can show you the exact commands:

```
Show me the git commands to stage these changes, commit with the message you wrote, and push to a new branch called feature/cloud-run-limits-and-storage.
```

Run those commands yourself in your terminal.

---

## Step 5: Reflect on the session

```
Looking at everything we did in this session — orient, modify, add a resource, understand the safety net, prepare the PR — what did you actually do autonomously versus what required my approval or judgment?
```

**What to look for:** Claude should be honest that it:
- Made code changes autonomously (you reviewed but Claude wrote the HCL)
- Could not run commands without your explicit approval (hook prompts)
- Could not deploy anything
- Could not push code or create a PR
- Made recommendations that you accepted or questioned

This is the intended relationship: Claude accelerates the work, you own the decisions.

---

## Debrief

The PR handoff is where the "LLM as intern" model becomes concrete. The intern wrote the code and explained the changes. You reviewed the plan, asked the hard questions, and signed off. The PR is yours — your name is on it, and you understand what it does.

That's the point.

---

## What's Next

These five exercises cover the core workflow. If you want to go further:

- Ask Claude to add a Cloud SQL instance and understand what that changes about the access model
- Ask Claude what it would take to make the Cloud Run service private (authenticated only)
- Ask Claude to explain what a Cloud Run revision is and how rollbacks work
- Explore the AGENTS.md interactive setup to customize this repo for your actual project
