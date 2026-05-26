#!/usr/bin/env python3
"""
tools/coverage-checker.py

Parses a coverage XML report (coverage.py or Cobertura) and enforces a minimum line coverage threshold.

Usage: python tools/coverage-checker.py --report coverage.xml --threshold 100
"""
import argparse
import sys
import xml.etree.ElementTree as ET

def parse_args():
    p = argparse.ArgumentParser()
    p.add_argument('--report', required=True, help='Path to coverage XML report')
    p.add_argument('--threshold', type=float, default=100.0, help='Minimum percent threshold (0-100)')
    return p.parse_args()

def main():
    args = parse_args()
    try:
        tree = ET.parse(args.report)
    except Exception as e:
        print(f'ERROR: Could not parse coverage report: {e}')
        return 2
    root = tree.getroot()

    # Try common attributes: coverage.py uses 'line-rate' or 'lines-valid/lines-covered' in packages
    line_rate = None
    if 'line-rate' in root.attrib:
        line_rate = float(root.attrib['line-rate'])
    elif 'lines-valid' in root.attrib and 'lines-covered' in root.attrib:
        valid = float(root.attrib['lines-valid'])
        covered = float(root.attrib['lines-covered'])
        line_rate = covered / valid if valid > 0 else 0.0
    else:
        # Attempt to find cobertura root attributes
        for elem in root.iter():
            if 'line-rate' in elem.attrib:
                line_rate = float(elem.attrib['line-rate'])
                break

    if line_rate is None:
        print('ERROR: Could not determine line-rate from coverage report.')
        return 2

    percent = line_rate * 100.0
    print(f'Coverage: {percent:.2f}% (threshold {args.threshold}%)')
    if percent + 1e-9 < args.threshold:
        print('Coverage threshold not met.')
        return 1
    print('Coverage threshold satisfied.')
    return 0

if __name__ == '__main__':
    sys.exit(main())
