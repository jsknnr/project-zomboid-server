#!/usr/bin/env python3
import yaml
import sys
import os

def generate_mod_id_list(file_path: str) -> None:
    """
    Load the mods list from a YAML file.
    :param file_path: The path to the mods list file
    :return: None
    """
    with open(file_path, 'r') as mods_file:
        mods_dict = yaml.safe_load(mods_file)
    
    mods = {
       "workshop_ids": [],
       "mod_ids": []
    }

    for key, value in mods_dict.items():
        mods["workshop_ids"].append(f"{value["workshop_id"]}")
        mods["mod_ids"].append(f"{value["mod_id"]}")

    delimiter = ";"
    print("Workshop IDs:")
    print (delimiter.join(mods["workshop_ids"]))
    print("")
    print("Mod IDs:")
    print (delimiter.join(mods["mod_ids"]))

if __name__ == '__main__':
    # Verify command line arg file path is correct and generate mod id lists
    if os.path.exists(sys.argv[1]):
        generate_mod_id_list(sys.argv[1])
    else:
        print(f"mods yaml file not found at: {sys.argv[1]}")
        sys.exit(1)
