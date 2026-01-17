---
description: Analyze CI build failures and output structured classification
argument-hint: [--format json|text]
---

# CI Failure Analysis

Analyze the CI build failure from the input and provide a structured classification.

## Output Format

Respond with ONLY a JSON object (no markdown, no explanation):

```json
{
  "failure_type": "test_failure|type_error|lint_error|compilation_error|dependency_issue|infrastructure|flaky_test|unknown",
  "is_auto_fixable": true|false,
  "risk_level": "low|medium|high",
  "confidence": "high|medium|low",
  "root_cause": "Brief description of why it failed",
  "file_path": "path/to/failing/file or null",
  "line_number": number or null,
  "suggested_fix": "Description of how to fix it",
  "verification_command": "Command to verify the fix (e.g., npm run typecheck)"
}
```

## Classification Rules

### LOW Risk (auto-fixable)
- **type_error**: TypeScript type mismatches, wrong return types, missing type annotations
- **lint_error**: ESLint/Prettier violations with clear fixes
- **import_error**: Missing imports, wrong import paths (when target exists)

### MEDIUM Risk (create PR for review)
- **test_failure**: Assertion mismatches - could be intentional change or real bug
- **compilation_error**: Build errors that might require architectural decisions
- **snapshot_mismatch**: UI changes that need visual review

### HIGH Risk (report only, no auto-fix)
- **dependency_issue**: Package conflicts, version mismatches
- **infrastructure**: Network errors, timeouts, service unavailable
- **flaky_test**: Intermittent failures, race conditions
- **unknown**: Cannot determine cause with confidence

## Analysis Guidelines

1. Read the full error output carefully
2. Identify the root error (not just symptoms)
3. Check if the fix is deterministic (same input = same fix)
4. Consider side effects of potential fixes
5. When uncertain, classify as higher risk

## Examples

**Type Error Example:**
```
error TS2322: Type 'number' is not assignable to type 'string'
```
→ `type_error`, `low` risk, auto-fixable

**Test Failure Example:**
```
Expected: "Hello World"
Received: "Hello Universe"
```
→ `test_failure`, `medium` risk (might be intentional change)

**Infrastructure Example:**
```
ECONNREFUSED 127.0.0.1:5432
```
→ `infrastructure`, `high` risk (external dependency)
