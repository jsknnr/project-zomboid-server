# What is this?

This is a little python script I wrote that reads a config file (in yaml) and then generates a list of your workshop IDs and Mod IDs. This is what I use to make sure that both lists are in the correct load order and makes it really easy to add or remove mods from the list. I realize there are other ways to handle this, but this what I prefer as it gives complete control and no external dependencies (other than python to run script).

## How to use

1) First create a copy of the `mods.yaml.example` file and rename it to `mods.yaml`
2) Now the tedius part, enter all your mods into the file. Repsect the formatting of the example. The first line for each mod is arbitrary, call it what ever you want, I use the name of the mod. The next 2 lines are important, you have `workshop_id` and `mod_id`. Just copy and paste your IDs maintaing the `workshop_id: 123` and `mod_id: cool_mod` format. If the mod has multiple sub-mod IDs, just separate them with a semi-colon with no spaces between the multiple mod_ids.
3) Finally, run the script. Change directory into the `util` directory, and run `run.sh` with the name of your yaml file as the argument. Example:

```bash
cd util
./run.sh mods.yaml
```

## Requirements

The system you run this from should have python3 and python3-pip installed.
