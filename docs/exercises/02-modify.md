# Exercise 02: Modify an Existing Resource

**Goal:** Make a targeted change to the Cloud Run service, review what Claude changed, and run terraform plan to understand the impact.

---

## Why This Matters

The workflow here — change, review, plan, understand — is what separates careful infrastructure work from "run it and hope." Claude writes the change; you review it and approve the plan before anything touches your infrastructure.

---

## Step 1: Ask Claude to make a change

Paste this into Claude Code:

```
Add the following to the Cloud Run service in main.tf:
- Memory limit of 512Mi
- CPU limit of 1
- Max concurrent requests of 80

Explain what each of these settings does as you make the changes.
```

**What to look for:** Claude should modify the `containers` block inside the `template` block in `main.tf`. It should add `resources` with `limits` and set `max_instance_request_concurrency` on the template. If it creates a new file or rewrites large parts of main.tf, ask it to be more targeted.

---

## Step 2: Review the diff before running anything

```
Show me exactly what you changed in main.tf. Walk me through each addition line by line.
```

**What to look for:** Claude should show the diff and explain what each new block does. If anything looks unexpected — extra resources added, values you didn't ask for — ask Claude to explain or revert the specific change.

---

## Step 3: Ask about the values

```
Why 512Mi memory and concurrency of 80 specifically? What would happen if the service gets more than 80 concurrent requests?
```

**What to look for:** Claude should explain that 80 is a Cloud Run default that balances throughput and cold starts, and that requests beyond the concurrency limit trigger new instances (not errors, assuming max_instance_count allows it). This is a good prompt to use any time Claude picks a value — make it justify the choice.

---

## Step 4: Run terraform plan

```
Run terraform plan and walk me through what it shows. I want to understand every line of the output.
```

**What happens:** You'll see a hook prompt asking for approval before `terraform plan` runs. This is the safety hook working as intended — approve it.

**What to look for in the plan output:**
- The resource type being modified: `google_cloud_run_v2_service.app`
- `~` (tilde) means an in-place update — no destroy/recreate
- The specific attributes being added (resources.limits, max_instance_request_concurrency)
- "Plan: 0 to add, 1 to change, 0 to destroy" — expected

---

## Step 5: Ask Claude to interpret the plan

```
Is there anything in this plan I should be concerned about? Are any of these changes potentially destructive or hard to reverse?
```

**What to look for:** Claude should confirm that resource limit and concurrency changes are non-destructive (they don't replace the service). It should flag anything unexpected if present.

---

## Debrief

You made a change, had Claude explain it, reviewed the diff, approved a plan, and had Claude interpret the output. That's the full loop for a safe infrastructure change.

The plan ran — but nothing was applied. Your infrastructure is unchanged. That's by design.

**Next:** Exercise 03 — add a brand new resource.
