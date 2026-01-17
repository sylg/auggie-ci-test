# Build Failure Analysis - Live Test Implementation

This folder contains everything needed to test the self-healing CI tutorial with a real GitHub repo.

## Quick Start

```bash
# 1. Create a new GitHub repo (or fork this test setup)
gh repo create auggie-ci-test --public --clone
cd auggie-ci-test

# 2. Copy all files from this folder
cp -r /path/to/test_implementation/* .

# 3. Push to GitHub
git add . && git commit -m "Initial setup" && git push

# 4. Add your AUGMENT_SESSION_AUTH secret
gh secret set AUGMENT_SESSION_AUTH

# 5. Create a branch with a bug and open a PR
git checkout -b test/introduce-bug
# Edit src/utils.ts to introduce a type error
git add . && git commit -m "Introduce bug for testing"
git push -u origin test/introduce-bug
gh pr create --title "Test: Introduce bug" --body "Testing build failure analysis"
```

## What's Included

```
test_implementation/
├── src/
│   ├── index.ts          # Main entry point
│   ├── utils.ts          # Utility functions (break these)
│   └── __tests__/
│       └── utils.test.ts # Tests
├── .github/
│   └── workflows/
│       ├── ci.yml                    # Standard CI
│       └── build-failure-analysis.yml # Auggie analysis
├── .augment/
│   └── build-analysis-config.yaml    # Safety config
├── package.json
├── tsconfig.json
└── jest.config.js
```

## Test Scenarios

### 1. Type Error
Edit `src/utils.ts`:
```typescript
// Change this:
export function add(a: number, b: number): number {
// To this (wrong return type):
export function add(a: number, b: number): string {
```

### 2. Test Failure
Edit `src/utils.ts`:
```typescript
// Change this:
export function multiply(a: number, b: number): number {
  return a * b;
}
// To this (wrong implementation):
export function multiply(a: number, b: number): number {
  return a + b;  // Bug: should be a * b
}
```

### 3. Lint Error
Edit `src/utils.ts`:
```typescript
// Add unused variable:
const unusedVar = "this will trigger lint error";
```

### 4. Import Error
Edit `src/index.ts`:
```typescript
// Add missing import:
import { nonExistentFunction } from './utils';
```

## Expected Results

When CI fails, you should see:
1. **PR Comment** with root cause analysis
2. **Structured JSON** with failure classification
3. **Suggested fix** with diff

If auto-fix is enabled:
1. New commit with fix applied
2. CI re-runs automatically
3. Success (for fixable issues)
