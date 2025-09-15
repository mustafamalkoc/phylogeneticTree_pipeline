#!/usr/bin/env python3
"""
Script to parse ModelFinder output and extract thread and memory recommendations.

This script extracts:
1. BEST NUMBER OF THREADS from ModelFinder output
2. Required memory from ModelFinder output
3. Best-fit model for IQ-TREE

Author: Pipeline automation script
"""

import re
import sys
import argparse
import os


def parse_modelfinder_output(log_file):
    """Parse the .log file to extract essential information."""
    
    info = {
        'best_model': None,
        'recommended_threads': None,
        'ram_required_mb': 0
    }
    
    if not os.path.exists(log_file):
        print(f"Warning: .log file not found: {log_file}", file=sys.stderr)
        return info
    
    with open(log_file, 'r') as f:
        content = f.read()
    
    # Extract best model
    model_match = re.search(r'Best-fit model:\s+(.+?)\s+chosen according to', content)
    if model_match:
        info['best_model'] = model_match.group(1).strip()
    
    # Extract recommended thread count
    thread_match = re.search(r'BEST NUMBER OF THREADS:\s+(\d+)', content)
    if thread_match:
        info['recommended_threads'] = int(thread_match.group(1))
    
    # Extract RAM requirement
    ram_match = re.search(r'NOTE:\s+(\d+)\s+MB RAM.*is required', content)
    if ram_match:
        info['ram_required_mb'] = int(ram_match.group(1))
    
    return info


def write_resource_file(output_file, best_model, cpus, memory_gb):
    """Write the resource recommendations to a file."""
    
    with open(output_file, 'w') as f:
        f.write(f"BEST_MODEL={best_model}\n")
        f.write(f"ESTIMATED_CPUS={cpus}\n")
        f.write(f"ESTIMATED_MEMORY_GB={memory_gb}\n")


def main():
    parser = argparse.ArgumentParser(description='Parse ModelFinder output for threads and memory')
    parser.add_argument('log_file', help='ModelFinder .log file')
    parser.add_argument('output_file', nargs='?', help='Output resource file')
    parser.add_argument('--get-model', action='store_true', help='Just output the best model from resource file')
    
    args = parser.parse_args()
    
    # Handle --get-model option for reading existing resource file
    if args.get_model:
        if args.log_file and os.path.exists(args.log_file):
            # In this case, log_file is actually the resource file
            with open(args.log_file, 'r') as f:
                for line in f:
                    if line.startswith('BEST_MODEL='):
                        print(line.split('=', 1)[1].strip())
                        return
        print("LG+F+R4")  # Fallback model
        return
    
    if not args.output_file:
        parser.error("output_file is required unless using --get-model")
    
    # Parse the files
    info = parse_modelfinder_output(args.log_file)
    
    # Use parsed values or fallbacks
    best_model = info['best_model'] or 'LG+F+R4'
    cpus = info['recommended_threads'] or 6  # Default fallback
    memory_gb = max(10, int(info['ram_required_mb'] / 1024)) if info['ram_required_mb'] > 0 else 20
    
    # Write output
    write_resource_file(args.output_file, best_model, cpus, memory_gb)
    
    print(f"Parsed ModelFinder results:", file=sys.stderr)
    print(f"  Best model: {best_model}", file=sys.stderr)
    print(f"  Recommended threads: {info['recommended_threads']}", file=sys.stderr)
    print(f"  RAM required (MB): {info['ram_required_mb']}", file=sys.stderr)
    print(f"  Final CPUs: {cpus}", file=sys.stderr)
    print(f"  Final Memory: {memory_gb} GB", file=sys.stderr)


if __name__ == '__main__':
    main() 