#!/bin/python

import os
import sys
import re
import fnmatch
from pathlib import Path

module_mapping = {}
include_mapping = {}
define_mapping = {}

disable_list = ['logic', 'assign', 'for']

def rename_contents_with_folder_suffix(folder_path):
    """
    Recursively process all Verilog/SystemVerilog files in the specified folder, 
    adding the folder name as a suffix to all contents.
    
    Parameters:
        folder_path: Path to the folder to be processed
    """
    # Get folder name and convert to valid identifier
    folder_name = Path(folder_path).name
    suffix = re.sub(r'[^\w]', '_', folder_name)  # Replace non-alphanumeric characters with underscores

    # Step 1: Collect all module definitions and their original names
    module_mapping.clear()
    include_mapping.clear()
    define_mapping.clear()
    collect_content(folder_path, suffix)

    # Exit if no module definitions found
    if not module_mapping:
        print(f"Warning: No module definitions found in {folder_path}")
        return

    # Step 2: Perform replacements in all files
    process_files(folder_path)


def check_disable_list(name):
    for vv in disable_list:
        if name in vv:
            return False
    return True


def collect_content(folder_path, suffix):
    """Collect all content definitions and create mapping relationships"""

    # Recursively traverse all files
    for root, _, files in os.walk(folder_path):
        for filename in files:
            if not is_design_file(filename):
                continue

            print(f'file name: {filename}')
            filepath = os.path.join(root, filename)
            with open(filepath, 'r', encoding='utf-8') as f:
                content = f.read()

            # Find all module definitions
            module_names = find_module_names(content)
            # Create new names for each module and add to mapping
            for name in module_names:
                new_name = f"{name}_{suffix}"
                if name in module_mapping:
                    pass
                    # print(f'ERROR module {name}')
                    # print(f'module_mapping: {module_mapping}')
                    # sys.exit(1)
                else:
                    if check_disable_list(name):
                        module_mapping[name] = new_name
                        print(f"Detected module: {name} -> {new_name}")


            # Find all include names
            include_names = find_include_names(content)
            print(f'include names: {include_names}')
            # Create new names for each module and add to mapping
            for name in include_names:
                if name == 'mmap_define.svh': continue
                if name == 'mdd_config.svh': continue
                tmp = name.split('.')
                new_name = f"{tmp[0]}_{suffix}.{tmp[1]}"
                if name in include_mapping:
                    pass
                    # print(f'ERROR include {name}')
                    # print(f'include_mapping: {include_mapping}')
                    # sys.exit(1)
                else:
                    if check_disable_list(name):
                        include_mapping[name] = new_name
                        print(f"Detected include: {name} -> {new_name}")


            # Find all define names
            define_names = find_define_names(content)
            print(f'define names: {define_names}')
            # Create new names for each module and add to mapping
            for name in define_names:
                new_name = f"{name}_{suffix}"
                if name in define_mapping:
                    pass
                    # print(f'ERROR define {name}')
                    # print(f'define_mapping: {define_mapping}')
                    # sys.exit(1)
                else:
                    if check_disable_list(name):
                        define_mapping[name] = new_name
                        print(f"Detected define: {name} -> {new_name}")

            print('\n')


def process_files(folder_path):
    """Process all files, performing name replacements"""
    # Sort module names by length (descending) to avoid substring replacements
    sorted_modules = sorted(module_mapping.keys(), key=len, reverse=True)
    sorted_includes = sorted(include_mapping.keys(), key=len, reverse=True)
    sorted_defines = sorted(define_mapping.keys(), key=len, reverse=True)

    # Recursively traverse all files
    for root, _, files in os.walk(folder_path):
        for filename in files:
            if not is_design_file(filename):
                continue

            filepath = os.path.join(root, filename)
            print(f"Processing file: {filepath}")

            if filename == 'serv_state.v':
                cmd = f"sed -i '223,224s/^/\/\//;96r /dev/stdin' {filepath} < <(sed -n '223,224p' {filepath})"
                os.system('bash -c "' + cmd.replace('"', '\\"') + '"')

            with open(filepath, 'r', encoding='utf-8') as f:
                content = f.read()

            # Perform replacement operations
            new_content = replace_names(content, sorted_modules, module_mapping)
            new_content = replace_names(new_content, sorted_includes, include_mapping)
            new_content = replace_names(new_content, sorted_defines, define_mapping)

            # Write back to file
            with open(filepath, 'w', encoding='utf-8') as f:
                f.write(new_content)


def is_design_file(filename):
    """Check if file is design file"""
    return fnmatch.fnmatch(filename.lower(), '*.v')  or fnmatch.fnmatch(filename.lower(), '*.sv') or fnmatch.fnmatch(filename.lower(), '*.vh') or fnmatch.fnmatch(filename.lower(), '*.svh')


def find_include_names(content):
    """Find all include names in file content"""
    # Use regex to match module definitions
    # Consider various possible formats: module name, module name #(params), module name;
    pattern = r'`include\s+"([^"]+)"'
    matches = re.findall(pattern, content)

    # Remove duplicates
    return list(set(matches))

def find_define_names(content):
    """Find all define names in file content"""
    # Use regex to match module definitions
    # Consider various possible formats: module name, module name #(params), module name;
    pattern = r'`define\s+(\w+)\s+'
    matches = re.findall(pattern, content)

    # Remove duplicates
    return list(set(matches))


def find_module_names(content):
    """Find all module names in file content"""
    # Use regex to match module definitions
    # Consider various possible formats: module name, module name #(params), module name;
    pattern = r'\bmodule\s+(\w+)\b'
    matches = re.findall(pattern, content)

    # Remove duplicates
    return list(set(matches))


def replace_names(content, sorted_content, content_mapping):
    """Replace all name references in content"""
    # Use regex for safe word-boundary matching of content names
    # Avoid replacing text in comments
    new_content = content

    # Use word boundaries to ensure only whole words are replaced
    for name in sorted_content:
        new_name = content_mapping[name]
        pattern = r'\b' + re.escape(name) + r'\b'
        new_content = re.sub(pattern, new_name, new_content)

    return new_content
