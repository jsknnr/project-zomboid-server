#!/usr/bin/env python3
# Quick helper script to edit the JVM configuration file and the server ini file

import json
import argparse

def update_config_file(file_path: str, key: str, new_value: str) -> None:
    """
    Update a key in a configuration file with a new value. If the key doesn't exist, it will be added to the end of the file.
    :param file_path: The path to the configuration file
    :param key: The key to update
    :param new_value: The new value for the key
    :return: None
    """
    # Read the existing configuration
    with open(file_path, 'r') as file:
        lines = file.readlines()

    # Update the configuration
    updated_lines = []
    key_found = False
    for line in lines:
        if line.startswith(f"{key}="):
            updated_lines.append(f"{key}={new_value}\n")
            key_found = True
        else:
            updated_lines.append(line)

    # If the key wasn't found, add it to the end
    if not key_found:
        updated_lines.append(f"{key}={new_value}\n")

    # Write the updated configuration back to the file
    with open(file_path, 'w') as file:
        file.writelines(updated_lines)

def update_jvm_config(file_path: str, max_memory: str) -> None:
    """
    Update the JVM configuration file with new memory and performance settings.
    :param file_path: The path to the JVM configuration file
    :param max_memory: The new value for the max memory setting - minimum will be set to the same
    :return: None
    """
    # Load JSON configuration
    with open(file_path, 'r') as config_file:
        config = json.load(config_file)

    # Remove original memory setting
    for item in config['vmArgs']:
        if item.startswith('-Xmx'):
            config['vmArgs'].remove(item)
        if item.startswith('-Xms'):
            config['vmArgs'].remove(item)
    
    # Add new settings
    config['vmArgs'].append(f'-Xmx{max_memory}')
    config['vmArgs'].append(f'-Xms{max_memory}')
    # Deprecated in Java 23, is default in Java 23
    if '-XX:+ZGenerational' not in config['vmArgs']:
        config['vmArgs'].append('-XX:+ZGenerational')
    if '-XX:+AlwaysPreTouch' not in config['vmArgs']:
        config['vmArgs'].append('-XX:+AlwaysPreTouch')
    if '-XX:+PerfDisableSharedMem' not in config['vmArgs']:
        config['vmArgs'].append('-XX:+PerfDisableSharedMem')
    if '-XX:+UseStringDeduplication' not in config['vmArgs']:
        config['vmArgs'].append('-XX:+UseStringDeduplication')
    if '-XX:+ParallelRefProcEnabled' not in config['vmArgs']:
        config['vmArgs'].append('-XX:+ParallelRefProcEnabled')

    # Write new JSON configuration
    with open(file_path, 'w') as config_file:
        json.dump(config, config_file, indent=4)

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Update configuration files')
    parser.add_argument('--config', type=str, required=True, help='The path to the configuration file')
    parser.add_argument('--key', type=str, nargs='?', help='The key to update')
    parser.add_argument('--value', type=str, nargs='?', help='The new value for the key')
    parser.add_argument('--memory', type=str, nargs='?', help='The new value for the max memory setting')
    parser.add_argument('--action', type=str, choices=['update-jvm', 'update-config'], default='update-config', help='The action to perform')
    args = parser.parse_args()

    if args.action == 'update-config':
        update_config_file(args.config, args.key, args.value)
    elif args.action == 'update-jvm':
        update_jvm_config(args.config, args.memory)
