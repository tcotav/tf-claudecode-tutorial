# Exercise 03: Add a New Resource

**Goal:** Add a Cloud Storage bucket and IAM binding so the app can store files. Learn how to ask Claude about tradeoffs, not just implementations.

---

## Why This Matters

Adding a resource isn't just about writing the HCL. You also need to understand what access you're granting, what happens to the data if things change, and whether there are safer alternatives. Claude can surface these questions before you commit to an approach.

---

## Step 1: Ask Claude to add the resources

Paste this into Claude Code:

```
Add a Cloud Storage bucket for the app to store uploaded files. The Cloud Run service account should be able to read and write objects in this bucket, but not delete them or change bucket-level settings. Add everything needed in main.tf.
```

**What to look for:** Claude should add two resources:
1. `google_storage_bucket` — the bucket itself, likely with `uniform_bucket_level_access = true`
2. `google_storage_bucket_iam_member` — binding the service account to a role on the bucket

The role should be `roles/storage.objectCreator` or `roles/storage.objectUser` (not `roles/storage.objectAdmin`, which allows deletion). If Claude uses `objectAdmin`, ask it to reconsider based on your requirements.

---

## Step 2: Ask Claude to explain the IAM role it chose

```
What IAM role did you use for the bucket binding? Why that one and not roles/storage.objectAdmin or roles/storage.objectViewer?
```

**What to look for:** Claude should explain the difference:
- `roles/storage.objectViewer` — read only
- `roles/storage.objectCreator` — create/upload, no read after write
- `roles/storage.objectUser` — read and write objects, but no delete
- `roles/storage.objectAdmin` — full object control including delete

This is exactly the kind of question you should ask about every IAM binding. The right role is the one with the least access needed.

---

## Step 3: Ask about data persistence

```
What happens to the files in this bucket if someone runs terraform destroy?
```

**What to look for:** Claude should explain that by default, Terraform cannot destroy a non-empty GCS bucket — it will error. To allow destroy, you'd need `force_destroy = true` on the bucket resource. This is a useful safety behavior and worth understanding before you're in a situation where you need to clean up.

---

## Step 4: Ask about naming

```
How will this bucket be named? What are the constraints on GCS bucket names and could this name conflict with anything?
```

**What to look for:** GCS bucket names are globally unique across all GCP projects. Claude should explain this and show you how the name is constructed. If the name is derived from a local (e.g., `${local.service_name}-uploads`), ask whether that's unique enough for a real project.

---

## Step 5: Run terraform plan

```
Run /tf-plan. For each resource being added, explain what will be created and why the order matters.
```

**What to look for in the plan output:**
- `+` (plus) means new resources being added
- Two new resources: the bucket and the IAM binding
- "Plan: 2 to add, ..." — expected (plus the change from Exercise 02 if you haven't committed yet)
- The IAM binding references the bucket — they can be created in any order since Terraform handles dependencies

---

## Step 6: Sanity-check the full picture

```
Given everything in main.tf now, describe the complete access model. Who can invoke the Cloud Run service? What can the service account do? What can it not do?
```

**What to look for:** Claude should give you a clear summary:
- Anyone on the internet can invoke the service (via the IAM member granting `roles/run.invoker` to `allUsers`)
- The service account can read/write objects in the storage bucket
- The service account cannot access other GCP services, cannot delete bucket objects, cannot modify bucket-level settings

This is the kind of holistic question you should ask at the end of any infrastructure change session.

---

## Debrief

You added a storage bucket with scoped IAM access, learned why role selection matters, and got Claude to explain the full access model. You also learned something non-obvious: GCS bucket names are globally unique and Terraform won't destroy a non-empty bucket by default.

All of this before writing a single line of code yourself.

**Next:** Exercise 04 — experience the safety net firsthand.
