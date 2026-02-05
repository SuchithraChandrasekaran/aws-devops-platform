#!/bin/bash

# Code Quality Check
# Reviews code quality metrics

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

echo "======================================"
echo "Code Quality Check"
echo "======================================"

# Check for TODO comments
echo ""
echo "Checking for TODO comments..."
TODO_COUNT=$(grep -r "TODO" ${PROJECT_ROOT}/applications ${PROJECT_ROOT}/scripts 2>/dev/null | wc -l)
echo "TODO comments found: ${TODO_COUNT}"

# Check for console.log in production code
echo ""
echo "Checking for console.log statements..."
CONSOLE_COUNT=$(grep -r "console.log" ${PROJECT_ROOT}/applications/sample-app/src 2>/dev/null | wc -l)
echo "console.log statements found: ${CONSOLE_COUNT}"

# Check file permissions
echo ""
echo "Checking script permissions..."
SCRIPTS=$(find ${PROJECT_ROOT}/scripts -name "*.sh" -not -executable 2>/dev/null | wc -l)
if [ $SCRIPTS -eq 0 ]; then
	    echo "PASS: All scripts are executable"
    else
	        echo "WARNING: ${SCRIPTS} scripts are not executable"
fi

# Check for large files
echo ""
echo "Checking for large files..."
LARGE_FILES=$(find ${PROJECT_ROOT} -type f -size +1M 2>/dev/null | wc -l)
echo "Large files (>1MB): ${LARGE_FILES}"

echo ""
echo "======================================"
echo "Quality Check Complete"
echo "======================================"
