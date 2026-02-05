#!/usr/bin/env bash

zomboid_pid=""

# Quick function to generate a timestamp
timestamp () {
  date +"%Y-%m-%d %H:%M:%S,%3N"
}

# Function to gracefully shutdown the server either via RCON or SIGTERM
shutdown () {
    echo ""
    echo "$(timestamp) INFO: Shutting down gracefully"
    if [ -n "${RCON_PASSWORD}" ] && [ -n "${RCON_PORT}" ] && [ -z "${FIRST_RUN}" ]; then
      echo "$(timestamp) INFO: Sending shutdown command to RCON"
      rcon --address "${SERVER_IP}:${RCON_PORT}" --password "${RCON_PASSWORD}" quit 
    else
      echo "$(timestamp) INFO: Sending SIGTERM command to server for pid ${zomboid_pid}"
      kill -15 $zomboid_pid
    fi
}

# Function to start PZ server using updated Java
start_zomboid () {
    echo ""
    echo "$(timestamp) INFO: Starting Project Zomboid Dedicated Server"
    echo "$(timestamp) INFO: Shutting off the water immediately..."
    echo "$(timestamp) INFO: Just kidding, let's go!"
    cd "${ZOMBOID_PATH}" || exit 1
    export PATH="${JAVA_HOME}/bin:${PATH}"
    export LD_LIBRARY_PATH="${ZOMBOID_PATH}/linux64:${ZOMBOID_PATH}/natives:${ZOMBOID_PATH}:${JAVA_HOME}/lib/server:${LD_LIBRARY_PATH}"
    JSIG="${JAVA_HOME}/lib/libjsig.so"
    LD_PRELOAD="${LD_PRELOAD}:${JSIG}" "${ZOMBOID_PATH}/ProjectZomboid64" "$@" &
}

# Initialize server configuration if server.ini or sandboxvars.lua do not exist
init_server () {
  if [ ! -f "${SERVER_CONFIG}" ] || [ ! -f "${SANDBOX_CONFIG}" ]; then
    FIRST_RUN=true
    echo ""
    echo "$(timestamp) INFO: Initializing server configuration"
    echo "$(timestamp) INFO: Server will run for 60 seconds to generate configuration"
    start_zomboid "${LAUNCH_ARGS[@]}"
    zomboid_pid=$!
    sleep "$INIT_TIMEOUT"
    shutdown
    echo "$(timestamp) INFO: Initialization complete"
    unset FIRST_RUN
    # Give the init run some time to actually shutdown before continuing
    sleep 10
  fi
}

# Function to easily call the config editor
config_editor () {
  python3 /home/steam/config_editor.py "$@"
}

# Function to edit JVM configuration
modify_jvm_config () {
  echo ""
  echo "$(timestamp) INFO: Updating JVM configuration"
  config_editor --action update-jvm --memory "${MAX_MEMORY}" --config "${JVM_CONFIG}"
  echo "$(timestamp) INFO: JVM Xmx and Xms set to ${MAX_MEMORY}"
}

# Function to edit server configuration
modify_server_config () {
  echo ""
  echo "$(timestamp) INFO: Updating server configuration"
  config_editor --config "${SERVER_CONFIG}" --key SaveWorldEveryMinutes --value "${AUTOSAVE_INTERVAL}"
  echo "$(timestamp) INFO: SaveWorldEveryMinutes set to: ${AUTOSAVE_INTERVAL} minutes"
  config_editor --config "${SERVER_CONFIG}" --key BackupsCount --value "${BACKUPS_COUNT}"
  echo "$(timestamp) INFO: BackupsCount set to: ${BACKUPS_COUNT}"
  config_editor --config "${SERVER_CONFIG}" --key BackupsPeriod --value "${BACKUPS_PERIOD}"
  echo "$(timestamp) INFO: BackupsPeriod set to: ${BACKUPS_PERIOD}"
  config_editor --config "${SERVER_CONFIG}" --key UDPPort --value "${DIRECT_PORT}"
  echo "$(timestamp) INFO: UDPPort set to: ${DIRECT_PORT}"
  config_editor --config "${SERVER_CONFIG}" --key DefaultPort --value "${GAME_PORT}"
  echo "$(timestamp) INFO: DefaultPort set to: ${GAME_PORT}"
  config_editor --config "${SERVER_CONFIG}" --key Map --value "${MAP_NAMES}"
  echo "$(timestamp) INFO: Map set to: ${MAP_NAMES}"
  config_editor --config "${SERVER_CONFIG}" --key MaxPlayers --value "${MAX_PLAYERS}"
  echo "$(timestamp) INFO: MaxPlayers set to: ${MAX_PLAYERS}"
  config_editor --config "${SERVER_CONFIG}" --key PauseEmpty --value "${PAUSE_EMPTY}"
  echo "$(timestamp) INFO: PauseEmpty set to: ${PAUSE_EMPTY}"
  config_editor --config "${SERVER_CONFIG}" --key PingLimit --value "${PING_LIMIT}"
  echo "$(timestamp) INFO: PingLimit set to: ${PING_LIMIT}"
  config_editor --config "${SERVER_CONFIG}" --key PVP --value "${PVP}"
  echo "$(timestamp) INFO: PVP set to: ${PVP}"
  config_editor --config "${SERVER_CONFIG}" --key Public --value "${PUBLIC}"
  echo "$(timestamp) INFO: Public set to: ${PUBLIC}"
  config_editor --config "${SERVER_CONFIG}" --key PublicName --value "${SERVER_NAME}"
  echo "$(timestamp) INFO: PublicName set to: ${SERVER_NAME}"
  config_editor --config "${SERVER_CONFIG}" --key SteamVAC --value "${STEAM_VAC}"
  echo "$(timestamp) INFO: SteamVAC set to: ${STEAM_VAC}"
  config_editor --config "${SERVER_CONFIG}" --key AntiCheatProtectionType21 --value "${ANTI_CHEAT_TYPE21}"
  echo "$(timestamp) INFO: AntiCheatProtectionType21 set to: ${ANTI_CHEAT_TYPE21}"

  if [ -n "${MOD_IDS}" ]; then
    config_editor --config "${SERVER_CONFIG}" --key WorkshopItems --value "${MOD_IDS}"
    echo "$(timestamp) INFO: WorkshopItems set to: ${MOD_IDS}"
  fi

  if [ -n "${MOD_NAMES}" ]; then
    config_editor --config "${SERVER_CONFIG}" --key Mods --value "${MOD_NAMES}"
    echo "$(timestamp) INFO: Mods set to: ${MOD_NAMES}"
  fi

  if [ -n "${RCON_PASSWORD}" ]; then
    config_editor --config "${SERVER_CONFIG}" --key RCONPassword --value "${RCON_PASSWORD}"
    echo "$(timestamp) INFO: RCONPassword set"
  fi

  if [ -n "${RCON_PORT}" ]; then
    config_editor --config "${SERVER_CONFIG}" --key RCONPort --value "${RCON_PORT}"
    echo "$(timestamp) INFO: RCONPort set to: ${RCON_PORT}"
  fi

  if [ -n "${SERVER_PASSWORD}" ]; then
    config_editor --config "${SERVER_CONFIG}" --key Password --value "${SERVER_PASSWORD}"
    echo "$(timestamp) INFO: Server Password set"
  fi
}

# Set our variables
JVM_CONFIG="${ZOMBOID_PATH}/ProjectZomboid64.json"
SERVER_CONFIG="${ZOMBOID_DATA_PATH}/Server/${SERVER_NAME}.ini"
SANDBOX_CONFIG="${ZOMBOID_DATA_PATH}/Server/${SERVER_NAME}_SandboxVars.lua"
LAUNCH_ARGS=(
  -cachedir="${ZOMBOID_DATA_PATH}"
  -ip "${SERVER_IP}"
  -port "${GAME_PORT}"
  -adminusername "${ADMIN_USERNAME}"
  -adminpassword "${ADMIN_PASSWORD}"
  -servername "${SERVER_NAME}"
)

# Intro
echo "$(timestamp) INFO: Starting Project Zomboid dedicated server container by jsknnr: https://github.com/jsknnr/project-zomboid-server"

# PZ will not bind to 0.0.0.0, so we need to use the container's IP
if [ "${SERVER_IP}" == "0.0.0.0" ] || [ -z "${SERVER_IP}" ]; then
  SERVER_IP=$(hostname -i)
  echo "$(timestamp) WARN: SERVER_IP unusable (e.g. 0.0.0.0) or not set, using container IP instead: ${SERVER_IP}"
fi

# Make sure MAX_MEMORY is set, exit 1 if not
if [ -z "${MAX_MEMORY}" ]; then
  echo "$(timestamp) ERROR: MAX_MEMORY must be set (e.g. MAX_MEMORY=8g)"
  exit 1
fi

# Set our variables
JVM_CONFIG="${ZOMBOID_PATH}/ProjectZomboid64.json"
SERVER_CONFIG="${ZOMBOID_DATA_PATH}/Server/${SERVER_NAME}.ini"
SANDBOX_CONFIG="${ZOMBOID_DATA_PATH}/Server/${SERVER_NAME}_SandboxVars.lua"
LAUNCH_ARGS=(
  -cachedir="${ZOMBOID_DATA_PATH}"
  -ip "${SERVER_IP}"
  -port "${GAME_PORT}"
  -adminusername "${ADMIN_USERNAME}"
  -adminpassword "${ADMIN_PASSWORD}"
  -servername "${SERVER_NAME}"
)

# Install/Update PZ
echo "$(timestamp) INFO: Updating Project Zomboid Dedicated Server"
STEAMCMD_ARGS=(
  +force_install_dir "${ZOMBOID_PATH}"
  +login anonymous
  +app_update "${STEAM_APP_ID}"
)
if [ -n "${BETA_BRANCH}" ]; then
  STEAMCMD_ARGS+=(-beta "${BETA_BRANCH}")
fi
STEAMCMD_ARGS+=(validate)
STEAMCMD_ARGS+=(+quit)
if ! "${STEAMCMD_PATH}/steamcmd.sh" "${STEAMCMD_ARGS[@]}"
then
  echo "$(timestamp) WARN: steamcmd update failed; removing appmanifest and retrying"
  rm -f "${ZOMBOID_PATH}/steamapps/appmanifest_${STEAM_APP_ID}.acf"
  if ! "${STEAMCMD_PATH}/steamcmd.sh" "${STEAMCMD_ARGS[@]}"
  then
    echo "$(timestamp) ERROR: steamcmd update failed twice; exiting"
    exit 1
  fi
fi

# Setup signal handler
trap 'shutdown' TERM

# Call to init and configuration
init_server
modify_jvm_config
modify_server_config

# Start the server and set process id
start_zomboid "${LAUNCH_ARGS[@]}"
zomboid_pid=$!

# Hold us open until we recieve a SIGTERM
wait $zomboid_pid

# Wait for the server to shutdown
tail --pid=$zomboid_pid -f /dev/null
