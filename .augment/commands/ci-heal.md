---
description: Self-healing CI - analyze failures and automatically fix when safe
argument-hint: [--dry-run] [--risk-threshold low|medium]
---

# CI Self-Healing Command

Analyze CI build failures and automatically apply fixes when safe to do so.

## First: Read Repository Configuration

**IMPORTANT**: Before analyzing, read the repository configuration file at `.augment/repo-config.yml` to understand:
- The project's language and tech stack
- Which commands to run for verification
- Any custom risk overrides

Use this configuration to tailor your analysis and verification steps.

## Workflow

### Step 1: Analyze the Failure

Classify the CI failure based on the error output:
- **failure_type**: type_error | lint_error | test_failure | build_error | import_error | infrastructure
- **risk_level**: low | medium | high
- **is_auto_fixable**: true | false
- **root_cause**: Brief description
- **file_path**: Which file needs fixing

### Step 2: Risk-Based Action

Check `repo-config.yml` for any `risk_overrides`, then apply defaults:

**LOW Risk** (auto-fix and push):
- Type errors with clear fixes
- Lint errors with auto-fix available
- Missing imports where target exists

**MEDIUM Risk** (fix but flag for review):
- Test assertion mismatches (could be intentional)
- Snapshot differences (needs visual check)
- Build errors that might have side effects

**HIGH Risk** (report only, never auto-fix):
- Infrastructure/network errors
- Flaky tests / race conditions
- Dependency conflicts
- Anything in `risk_overrides.high_risk`

### Step 3: Apply Fix (if appropriate)

When fixing:
1. Read the failing file to understand context
2. Make the **minimal** change needed
3. Do NOT add comments about the fix
4. Do NOT refactor surrounding code
5. Do NOT "improve" anything else

### Step 4: Verify

Run the verification command from `repo-config.yml`:
```
commands.verify_all
```

If not specified, try: typecheck → lint → test → build

### Step 5: Report Results

Output a summary:

```markdown
## CI Heal Results

**Status**: fixed | needs-review | manual-required
**Failure Type**: [type]
**Risk Level**: [level]
**Root Cause**: [description]

### Changes Made
- [file]: [what changed]

### Verification
✓ typecheck passed
✓ lint passed
✓ tests passed
✓ build passed

### Next Steps
[what happens next]
```

## Language-Specific Patterns

### TypeScript
- `TS2322: Type 'X' is not assignable` → Fix type annotation (LOW)
- `TS2339: Property 'X' does not exist` → Check import or typo (LOW)
- `Cannot find module` → Fix import path (LOW)

### JavaScript
- `ReferenceError: X is not defined` → Add import or declaration (LOW)
- `TypeError: X is not a function` → Check import/export (MEDIUM)

### Python
- `TypeError: missing required argument` → Fix function call (LOW)
- `ModuleNotFoundError` → Fix import (LOW)
- `AssertionError` → Test failure (MEDIUM)

### Go
- `cannot use X as Y` → Fix type (LOW)
- `undefined: X` → Fix import or declaration (LOW)

## Important Rules

1. **Always read `repo-config.yml` first** - it has project-specific settings
2. **Never fix HIGH risk issues** - report only
3. **Verify before declaring success** - run the verification command
4. **Minimal changes only** - don't refactor, don't add features
5. **When uncertain, escalate risk** - better to flag for review than break things

## Output Format

**CRITICAL**: Your final output MUST be a clean markdown summary starting with `## CI Heal Results`.
Do NOT include any tool call logs, task updates, or internal processing in the output.
The summary should be suitable for posting as a GitHub PR comment.
