#!/usr/bin/env python3
"""
Security Scan Results Parser - Day 27
Parse and summarize security scan results
"""

import json
import sys
from pathlib import Path

def parse_trivy_results(file_path):
    """Parse Trivy scan results"""
    try:
        with open(file_path) as f:
            data = json.load(f)
        
        vulnerabilities = {
            'CRITICAL': 0,
            'HIGH': 0,
            'MEDIUM': 0,
            'LOW': 0
        }
        
        for result in data.get('Results', []):
            for vuln in result.get('Vulnerabilities', []):
                severity = vuln.get('Severity', 'UNKNOWN')
                if severity in vulnerabilities:
                    vulnerabilities[severity] += 1
        
        return vulnerabilities
    except Exception as e:
        print(f"Error parsing Trivy results: {e}")
        return None

def parse_safety_results(file_path):
    """Parse Safety scan results"""
    try:
        with open(file_path) as f:
            data = json.load(f)
        
        vulnerabilities = len(data)
        return vulnerabilities
    except Exception as e:
        print(f"Error parsing Safety results: {e}")
        return None

def parse_bandit_results(file_path):
    """Parse Bandit scan results"""
    try:
        with open(file_path) as f:
            data = json.load(f)
        
        metrics = data.get('metrics', {}).get('_totals', {})
        
        issues = {
            'HIGH': metrics.get('SEVERITY.HIGH', 0),
            'MEDIUM': metrics.get('SEVERITY.MEDIUM', 0),
            'LOW': metrics.get('SEVERITY.LOW', 0)
        }
        
        return issues
    except Exception as e:
        print(f"Error parsing Bandit results: {e}")
        return None

def generate_summary_report():
    """Generate security scan summary"""
    print("="*70)
    print("Security Scan Summary Report - Day 27")
    print("="*70)
    print()
    
    # Trivy results
    trivy_file = Path('trivy-results.json')
    if trivy_file.exists():
        print("Container Vulnerability Scan (Trivy):")
        print("-" * 70)
        vulns = parse_trivy_results(trivy_file)
        if vulns:
            for severity, count in vulns.items():
                print(f"  {severity:8}: {count}")
        print()
    
    # Safety results
    safety_file = Path('safety-report.json')
    if safety_file.exists():
        print("Dependency Vulnerability Scan (Safety):")
        print("-" * 70)
        count = parse_safety_results(safety_file)
        if count is not None:
            print(f"  Vulnerabilities found: {count}")
        print()
    
    # Bandit results
    bandit_file = Path('bandit-report.json')
    if bandit_file.exists():
        print("SAST Scan (Bandit):")
        print("-" * 70)
        issues = parse_bandit_results(bandit_file)
        if issues:
            for severity, count in issues.items():
                print(f"  {severity:8}: {count}")
        print()
    
    print("="*70)
    print("Scan complete - Review results above")
    print("="*70)

if __name__ == '__main__':
    generate_summary_report()
