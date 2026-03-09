# Exercise 01: Orient Yourself

**Goal:** Use Claude as a codebase reader before touching anything. This is how you should start every session in an unfamiliar terraform repo.

---

## Why This Matters

The instinct when working with an AI coding tool is to immediately ask it to make changes. Resist that. Claude can explain complex infrastructure relationships in plain English, which means you can understand what you're working with *before* you break anything.

---

## Step 1: Get the big picture

Paste this into Claude Code:

```
What does this repo manage? Give me a plain English summary of the infrastructure — what gets created, where it runs, and who can access it.
```

**What to look for:** Claude should describe the Cloud Run service, the service account, and the IAM policy. If it mentions GCS or databases, something's off — we haven't added those yet.

---

## Step 2: Inventory the resources

```
List every GCP resource that would be created if I ran terraform apply right now. For each one, tell me what it does and why it exists.
```

**What to look for:** Three resources — `google_service_account`, `google_cloud_run_v2_service`, and `google_cloud_run_v2_service_iam_member`. Claude should be able to explain the relationship between them (the service runs *as* the service account; the IAM member makes it publicly accessible).

---

## Step 3: Ask about the identity model

```
What is the service account for? What can it do right now, and what can't it do?
```

**What to look for:** Claude should explain that the service account is an identity (not a set of permissions), and that currently it has no IAM roles — it exists but can't access any GCP resources. This is intentional: you grant permissions when you need them.

---

## Step 4: Ask a "what if" question

```
What's the minimum I'd need to change in locals.tf to deploy my own container image instead of the hello-world default?
```

**What to look for:** Claude should point to the `image` local in `locals.tf` and explain the expected format (e.g., `us-central1-docker.pkg.dev/your-project/your-repo/your-image:tag`). It should not suggest changing any other files unless you have a reason to.

---

## Debrief

You just used Claude as a reader, not a writer. This is one of its most valuable uses — you can ask questions like these about any terraform repo and come away with a real understanding of what it does before you touch it.

Notice that Claude answered based on the actual code, not generic knowledge about Cloud Run. That's the point: it's reading your specific repo.

**Next:** Exercise 02 — make your first change.
