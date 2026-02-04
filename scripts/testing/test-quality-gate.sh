#!/bin/bash
# Check if tests meet quality threshold

set -e

THRESHOLD=80
COVERAGE_FILE="coverage/coverage-summary.json"

echo "Checking quality gates..."
echo "========================="

cd ~/aws-devops-platform/applications/sample-app

# Run tests with coverage
npm test -- --coverage --silent

if [ ! -f "$COVERAGE_FILE" ]; then
	    echo "ERROR: Coverage file not found"
	        exit 1
fi

# Extract coverage percentages directly from the pct field
LINES=$(jq '.total.lines.pct' "$COVERAGE_FILE")
FUNCTIONS=$(jq '.total.functions.pct' "$COVERAGE_FILE")
BRANCHES=$(jq '.total.branches.pct' "$COVERAGE_FILE")
STATEMENTS=$(jq '.total.statements.pct' "$COVERAGE_FILE")

echo ""
echo "Coverage Results:"
echo "  Statements: $STATEMENTS%"
echo "  Lines:      $LINES%"
echo "  Functions:  $FUNCTIONS%"
echo "  Branches:   $BRANCHES%"
echo ""

# Check thresholds
FAIL=0

if (( $(echo "$LINES < $THRESHOLD" | bc -l) )); then
	    echo "FAIL: Line coverage below threshold ($LINES% < $THRESHOLD%)"
	        FAIL=1
fi

if (( $(echo "$FUNCTIONS < $THRESHOLD" | bc -l) )); then
	    echo "FAIL: Function coverage below threshold ($FUNCTIONS% < $THRESHOLD%)"
	        FAIL=1
fi

if (( $(echo "$BRANCHES < $THRESHOLD" | bc -l) )); then
	    echo "FAIL: Branch coverage below threshold ($BRANCHES% < $THRESHOLD%)"
	        FAIL=1
fi

if (( $(echo "$STATEMENTS < $THRESHOLD" | bc -l) )); then
	    echo "FAIL: Statement coverage below threshold ($STATEMENTS% < $THRESHOLD%)"
	        FAIL=1
fi

if [ $FAIL -eq 0 ]; then
	    echo "PASS: All quality gates met!"
	        exit 0
	else
		    echo "FAIL: Quality gates not met"
		        exit 1
fi
