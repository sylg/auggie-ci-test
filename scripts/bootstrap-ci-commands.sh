#!/bin/bash
# Bootstrap CI Commands for a Repository
# This script analyzes a repo and generates optimized Auggie commands

set -e

echo "🔍 Analyzing repository..."

# Create commands directory
mkdir -p .augment/commands

# Detect tech stack
detect_tech_stack() {
    local lang=""
    local test_framework=""
    local lint_tool=""
    local build_cmd=""
    local test_cmd=""
    local typecheck_cmd=""
    local lint_cmd=""

    # Node.js / TypeScript
    if [ -f "package.json" ]; then
        if [ -f "tsconfig.json" ]; then
            lang="typescript"
            typecheck_cmd="npm run typecheck"
        else
            lang="javascript"
        fi

        # Detect test framework
        if grep -q '"jest"' package.json 2>/dev/null; then
            test_framework="jest"
            test_cmd="npm test"
        elif grep -q '"vitest"' package.json 2>/dev/null; then
            test_framework="vitest"
            test_cmd="npm test"
        elif grep -q '"mocha"' package.json 2>/dev/null; then
            test_framework="mocha"
            test_cmd="npm test"
        fi

        # Detect linter
        if grep -q '"eslint"' package.json 2>/dev/null; then
            lint_tool="eslint"
            lint_cmd="npm run lint"
        elif grep -q '"biome"' package.json 2>/dev/null; then
            lint_tool="biome"
            lint_cmd="npm run lint"
        fi

        build_cmd="npm run build"
    fi

    # Python
    if [ -f "pyproject.toml" ] || [ -f "requirements.txt" ]; then
        lang="python"
        if [ -f "pyproject.toml" ] && grep -q "pytest" pyproject.toml 2>/dev/null; then
            test_framework="pytest"
            test_cmd="pytest"
        fi
        if grep -q "ruff" pyproject.toml 2>/dev/null || [ -f ".ruff.toml" ]; then
            lint_tool="ruff"
            lint_cmd="ruff check ."
        fi
    fi

    # Go
    if [ -f "go.mod" ]; then
        lang="go"
        test_framework="go test"
        test_cmd="go test ./..."
        lint_tool="golangci-lint"
        lint_cmd="golangci-lint run"
    fi

    echo "$lang|$test_framework|$lint_tool|$build_cmd|$test_cmd|$typecheck_cmd|$lint_cmd"
}

# Parse detected stack
IFS='|' read -r LANG TEST_FW LINT_TOOL BUILD_CMD TEST_CMD TYPECHECK_CMD LINT_CMD <<< "$(detect_tech_stack)"

echo "📦 Detected: $LANG with $TEST_FW testing, $LINT_TOOL linting"

# Build verification command
VERIFY_CMD=""
[ -n "$TYPECHECK_CMD" ] && VERIFY_CMD="$TYPECHECK_CMD"
[ -n "$LINT_CMD" ] && VERIFY_CMD="${VERIFY_CMD:+$VERIFY_CMD && }$LINT_CMD"
[ -n "$TEST_CMD" ] && VERIFY_CMD="${VERIFY_CMD:+$VERIFY_CMD && }$TEST_CMD"
[ -n "$BUILD_CMD" ] && VERIFY_CMD="${VERIFY_CMD:+$VERIFY_CMD && }$BUILD_CMD"

echo "✅ Verification: $VERIFY_CMD"

# Generate ci-heal command
cat > .augment/commands/ci-heal.md << HEREDOC
---
description: Self-healing CI optimized for this $LANG project
---

# CI Self-Healing Command

This command is optimized for a **$LANG** project using **$TEST_FW** for testing and **$LINT_TOOL** for linting.

## Workflow

### Step 1: Analyze the Failure

Classify the CI failure:
- **failure_type**: type_error | lint_error | test_failure | build_error | import_error | infrastructure
- **risk_level**: low | medium | high
- **is_auto_fixable**: true | false

### Step 2: Risk-Based Action

**LOW Risk** (type errors, lint errors, import fixes):
→ Apply fix directly, verify, report success

**MEDIUM Risk** (test failures, build errors):
→ Apply fix, verify, flag for human review

**HIGH Risk** (infrastructure, flaky tests):
→ Report analysis only, do not attempt fix

### Step 3: Apply Fix (if appropriate)

When fixing:
1. Read the failing file
2. Make the minimal change needed
3. Do NOT add comments or refactor

### Step 4: Verify

Run: \`$VERIFY_CMD\`

### Step 5: Report

Output results with status, changes made, and next steps.

## Tech Stack Context

- **Language**: $LANG
- **Testing**: $TEST_FW
- **Linting**: $LINT_TOOL
- **Verification**: \`$VERIFY_CMD\`

## Common Patterns for $LANG

HEREDOC

# Add language-specific patterns
if [ "$LANG" = "typescript" ]; then
cat >> .augment/commands/ci-heal.md << 'HEREDOC'

### TypeScript Errors
- `TS2322: Type 'X' is not assignable to type 'Y'` → Fix type annotation (LOW risk)
- `TS2339: Property 'X' does not exist` → Check import or add property (LOW risk)
- `TS2345: Argument type mismatch` → Fix argument type (LOW risk)
- `Cannot find module` → Fix import path (LOW risk)

### Jest Test Failures
- `Expected: X, Received: Y` → Check if intentional change (MEDIUM risk)
- `Snapshot does not match` → May need visual review (MEDIUM risk)
- `Timeout` → Async issue, investigate (HIGH risk)
HEREDOC
elif [ "$LANG" = "python" ]; then
cat >> .augment/commands/ci-heal.md << 'HEREDOC'

### Python Errors
- `TypeError: missing required argument` → Add argument or fix signature (LOW risk)
- `ModuleNotFoundError` → Fix import (LOW risk)
- `AssertionError` → Test failure, check logic (MEDIUM risk)
- `ConnectionError` → Infrastructure issue (HIGH risk)
HEREDOC
elif [ "$LANG" = "go" ]; then
cat >> .augment/commands/ci-heal.md << 'HEREDOC'

### Go Errors
- `cannot use X as Y` → Fix type (LOW risk)
- `undefined: X` → Fix import or declaration (LOW risk)
- `Test failed` → Check test logic (MEDIUM risk)
- `race detected` → Concurrency issue (HIGH risk)
HEREDOC
fi

echo "✨ Generated .augment/commands/ci-heal.md"

# Generate repo config
cat > .augment/repo-config.yml << HEREDOC
# Auto-generated repository configuration
# Edit this to customize CI healing behavior

project:
  language: $LANG
  test_framework: $TEST_FW
  lint_tool: $LINT_TOOL

commands:
  build: $BUILD_CMD
  test: $TEST_CMD
  typecheck: $TYPECHECK_CMD
  lint: $LINT_CMD
  verify_all: $VERIFY_CMD

risk_overrides:
  # Customize risk levels for specific error patterns
  # low_risk:
  #   - "specific pattern to always treat as low risk"
  # high_risk:
  #   - "specific pattern to never auto-fix"
HEREDOC

echo "✨ Generated .augment/repo-config.yml"
echo ""
echo "🎉 Bootstrap complete! Your CI commands are ready."
echo ""
echo "Usage:"
echo "  auggie /ci-heal              # Run in CI or locally"
echo "  cat logs.txt | auggie /ci-heal  # Pipe logs to analyze"
