#!/bin/python

import os
import re
import fnmatch
from pathlib import Path

def rename_modules_with_folder_suffix(folder_path):
    """
    Recursively process all Verilog/SystemVerilog files in the specified folder, 
    adding the folder name as a suffix to all module names.
    
    Parameters:
        folder_path: Path to the folder to be processed
    """
    # Get folder name and convert to valid identifier
    folder_name = Path(folder_path).name
    suffix = re.sub(r'[^\w]', '_', folder_name)  # Replace non-alphanumeric characters with underscores

    # Step 1: Collect all module definitions and their original names
    module_mapping = collect_module_definitions(folder_path, suffix)

    # Exit if no module definitions found
    if not module_mapping:
        print(f"Warning: No module definitions found in {folder_path}")
        return

    # Step 2: Perform replacements in all files
    process_files(folder_path, module_mapping)

def collect_module_definitions(folder_path, suffix):
    """Collect all module definitions and create mapping relationships"""
    module_mapping = {}

    # Recursively traverse all files
    for root, _, files in os.walk(folder_path):
        for filename in files:
            if not is_verilog_file(filename):
                continue

            filepath = os.path.join(root, filename)
            with open(filepath, 'r', encoding='utf-8') as f:
                content = f.read()

            # Find all module definitions
            module_names = find_module_definitions(content)

            # Create new names for each module and add to mapping
            for name in module_names:
                new_name = f"{name}_{suffix}"
                module_mapping[name] = new_name
                print(f"Detected module: {name} -> {new_name}")

    return module_mapping

def process_files(folder_path, module_mapping):
    """Process all files, performing module name replacements"""
    # Sort module names by length (descending) to avoid substring replacements
    sorted_modules = sorted(module_mapping.keys(), key=len, reverse=True)

    # Recursively traverse all files
    for root, _, files in os.walk(folder_path):
        for filename in files:
            if not is_verilog_file(filename):
                continue

            filepath = os.path.join(root, filename)
            print(f"Processing file: {filepath}")

            with open(filepath, 'r', encoding='utf-8') as f:
                content = f.read()

            # Perform replacement operations
            new_content = replace_module_names(content, sorted_modules, module_mapping)

            # Write back to file
            with open(filepath, 'w', encoding='utf-8') as f:
                f.write(new_content)

def is_verilog_file(filename):
    """Check if file is Verilog/SystemVerilog file"""
    return fnmatch.fnmatch(filename.lower(), '*.v') or fnmatch.fnmatch(filename.lower(), '*.sv')

def find_module_definitions(content):
    """Find all module definitions in file content"""
    # Use regex to match module definitions
    # Consider various possible formats: module name, module name #(params), module name;
    pattern = r'\bmodule\s+(\w+)\b'
    matches = re.findall(pattern, content)

    # Remove duplicates
    return list(set(matches))

def replace_module_names(content, sorted_modules, module_mapping):
    """Replace all module name references in content"""
    # Use regex for safe word-boundary matching of module names
    # Avoid replacing text in comments
    new_content = content

    # Use word boundaries to ensure only whole words are replaced
    for module_name in sorted_modules:
        new_name = module_mapping[module_name]
        pattern = r'\b' + re.escape(module_name) + r'\b'
        new_content = re.sub(pattern, new_name, new_content)

    return new_content
