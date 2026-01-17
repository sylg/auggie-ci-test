---
description: Self-healing CI - analyze failures and automatically fix when safe
argument-hint: [--dry-run] [--risk-threshold low|medium]
---

# CI Self-Healing Command

Analyze CI build failures and automatically apply fixes when safe to do so.

## Workflow

### Step 1: Analyze the Failure

First, analyze the CI failure logs provided in the input. Classify the failure:

- **failure_type**: What kind of error is this?
- **risk_level**: How risky is an automated fix? (low/medium/high)
- **is_auto_fixable**: Can this be fixed automatically with confidence?
- **root_cause**: What's the actual problem?
- **file_path**: Which file needs to be fixed?

### Step 2: Decide Action Based on Risk

**LOW Risk** (type errors, lint errors, simple import fixes):
→ Apply the fix directly to the files
→ Verify the fix by running appropriate checks
→ Report success

**MEDIUM Risk** (test failures, compilation errors):
→ Apply the fix to files
→ Verify the fix
→ Report that changes need human review

**HIGH Risk** (infrastructure, flaky tests, dependency issues):
→ Do NOT attempt to fix
→ Report analysis only with suggested manual steps

### Step 3: Apply Fix (if appropriate)

When fixing:
1. Read the failing file to understand context
2. Make the minimal change needed to fix the issue
3. Do NOT add comments about the fix
4. Do NOT refactor or "improve" surrounding code
5. Keep the fix focused and surgical

### Step 4: Verify Fix

After applying changes, verify by running the appropriate check:
- Type errors → `npm run typecheck` or `tsc --noEmit`
- Lint errors → `npm run lint`
- Test failures → `npm test`
- Build errors → `npm run build`

### Step 5: Report Results

Output a summary:

```
## CI Heal Results

**Status**: fixed | needs-review | manual-required
**Failure Type**: [type]
**Risk Level**: [level]
**Root Cause**: [description]

### Changes Made
- [file]: [description of change]

### Verification
[verification command output summary]

### Next Steps
[what happens next - CI will re-run, PR created, or manual action needed]
```

## Important Rules

1. **Never fix HIGH risk issues** - always report only
2. **Verify before declaring success** - run the check command
3. **Minimal changes only** - don't refactor, don't add features
4. **When uncertain, don't fix** - escalate to medium/high risk
5. **One fix at a time** - if multiple errors, fix the first one

## Common Fixes by Type

### Type Errors
- Wrong return type → Change the type annotation
- Type mismatch in assignment → Fix the type or the value
- Missing property → Add the property or fix the type

### Lint Errors
- Missing semicolon → Add it
- Unused variable → Remove it or use it
- Import order → Reorder imports

### Import Errors
- Missing import → Add the import statement
- Wrong path → Fix the path

### Test Failures (MEDIUM - apply but flag for review)
- Assertion mismatch → Update expected value (might be intentional)
- Snapshot mismatch → Update snapshot (needs visual review)
