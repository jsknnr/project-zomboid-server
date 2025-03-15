#!/usr/bin/env bash

echo "Setting up python environment.."
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
echo "Done."
echo ""
echo ""

python3 mods_list.py $1
deactivate
