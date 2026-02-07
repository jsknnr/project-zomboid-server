# project-zomboid-server

[![Static Badge](https://img.shields.io/badge/DockerHub-blue)](https://hub.docker.com/r/sknnr/zomboid-dedicated-server) ![Docker Pulls](https://img.shields.io/docker/pulls/sknnr/zomboid-dedicated-server) [![Static Badge](https://img.shields.io/badge/GitHub-green)](https://github.com/jsknnr/project-zomboid-server) ![GitHub Repo stars](https://img.shields.io/github/stars/jsknnr/project-zomboid-server)

Run Project Zomboid dedicated server in a container. Optionally includes helm chart for running in Kubernetes.

**Disclaimer:** This is not an official image. No support, implied or otherwise is offered to any end user by the author or anyone else. Feel free to do what you please with the contents of this repo.

## Ports

| Port                | Protocol | Default |
| ------------------- | -------- | ------- |
| Game Port           | UDP      | 16261   |
| Direct Connect Port | UDP      | 16262   |
| RCON                | TCP      | 27015   |

## Environment Variables

Defaults will be used if not specified. If the default is set to `None` this means it will not get set unless specified. The only required variable is `MAX_MEMORY`.

| Name              | Description                                                                             | Default                  | Required |
| ----------------- | --------------------------------------------------------------------------------------- | ------------------------ | -------- |
| ANTI_CHEAT_TYPE21 | This setting is a usual suspect of relentlessly kicking players when using mods.        | true                     | False    |
| ADMIN_PASSWORD    | Password for admin user.                                                                | AdminPleaseChangeMe      | False    |
| ADMIN_USERNAME    | Username for admin user.                                                                | admin                    | False    |
| AUTOSAVE_INTERVAL | Saves world every N minutes.                                                            | 15                       | False    |
| BACKUPS_COUNT     | Number of backups to keep.                                                              | 5                        | False    |
| BACKUPS_PERIOD    | Creates a backup every N minutes.                                                       | 120                      | False    |
| BETA_BRANCH       | Beta branch name to install (e.g. 'unstable').                                          | None                     | False    |
| DIRECT_PORT       | Direct connection port.                                                                 | 16262                    | False    |
| GAME_PORT         | Primary port for server.                                                                | 16261                    | False    |
| MAP_NAMES         | Semi-colon separated list of maps.                                                      | Muldraugh, KY            | False    |
| MAX_MEMORY        | The max amount of memory to allocate to the server (JVM) (example: "8g" to assign 8GB). | None                     | **True** |
| MAX_PLAYERS       | Max number of players to be on the server at once.                                      | 16                       | False    |
| MOD_IDS           | Semi-colon separated list of Workshop IDs to load.                                      | None                     | False    |
| MOD_NAMES         | Semi-colon separated list of Mod IDs to load.                                           | None                     | False    |
| PAUSE_EMPTY       | Game time stops when no players online.                                                 | true                     | False    |
| PING_LIMIT        | Players are kicked for exceeding latency (ping) in milliseconds.                        | 400                      | False    |
| PVP               | Players can hurt and kill other players if true.                                        | true                     | False    |
| PUBLIC            | Show server on in-game browser.                                                         | true                     | False    |
| RCON_PASSWORD     | Password for accessing RCON.                                                            | None                     | False    |
| RCON_PORT         | Port for RCON to listen on.                                                             | None                     | False    |
| SERVER_IP         | IP that server will listen on. If not specified, container IP is used.                  | None                     | False    |
| SERVER_NAME       | Name of server.                                                                         | Zomboid Containerized    | False    |
| SERVER_PASSWORD   | Set password for joining server.                                                        | None                     | False    |
| STEAM_VAC         | Enables the steam VAC anti-cheat system.                                                | true                     | False    |

## Usage

### Modifying Configuration

Project Zomboid has a lot of settings you can modify. I have included some basic ones (listed above) that you can set through environment variables, but there are just too many to do them all... not to mention mod configuration. This image does contain `vim` so you can exec into the container and manually change other settings.
Alternatively, you can modify the configs from the data volume that gets mounted into the container. Just make sure that the files maintain their 10000:10000 (4 zeros, not 3) ownership.

### Mods

To use mods, you need to supply the mod's Workshop ID and Mod ID in the environment variables `MOD_IDS` and `MOD_NAMES` respectively. This is a tedius task. There is a utility made by a real hero hosted [Here](https://www.pzutil.com/) that can help with this process. I have noticed that the utility is not perfect, some times it will double up IDs, some times it will miss part of the Mod ID if there is a space in it. So if you do use that utility, just note that you will likely have to do some hand edits. Alternatively, I wrote my own little utility under the `utils` directory that you can use to generate the ID lists as well.

### Docker

To run the container in Docker, run the following command:

```bash
docker volume create zomboid-data
docker volume create zomboid-server
docker run \
  --detach \
  --name zomboid-server \
  --mount type=volume,source=zomboid-server,target=/home/steam/zomboid \
  --mount type=volume,source=zomboid-data,target=/home/steam/zomboid_data \
  --publish 16261:16261/udp \
  --publish 16262:16262/udp \
  --publish 27015:27015/tcp \
  --env=SERVER_NAME='Zomboid Containerized' \
  --env=SERVER_PASSWORD='PleaseChangeMe' \
  --env=ADMIN_USERNAME='Bobette' \
  --env=ADMIN_PASSWORD='AdminPleaseChangeMe' \
  --env=RCON_PORT='27015' \
  --env=RCON_PASSWORD='RCONPleaseChangeMe' \
  sknnr/zomboid-dedicated-server:latest
```

### Docker Compose

To user Docker Compose to launch the container, review the following examples:

To bring the container up:

```bash
docker-compose up -d
```

To bring the container down:

```bash
docker-compose down
```

compose.yaml file:

```yaml
version: "3"
services:
  zomboid:
    image: sknnr/zomboid-dedicated-server:latest
    ports:
      - "16261:16261/udp"
      - "16262:16262/udp"
      - "27015:27015/tcp"
    environment:
      - SERVER_NAME='Zomboid Containerized'
      - SERVER_PASSWORD='PleaseChangeMe'
      - ADMIN_USERNAME='Bobette'
      - ADMIN_PASSWORD='AdminPleaseChangeMe'
      - RCON_PORT='27015'
      - RCON_PASSWORD='RCONPleaseChangeMe'
    volumes:
      - zomboid-server:/home/steam/zomboid
      - zomboid-data:/home/steam/zomboid_data

volumes:
  zomboid-server:
  zomboid-data:
```

### Podman

To run the container in Podman, run the following command:

```bash
podman volume create zomboid-data
podman volume create zomboid-server
podman run \
  --detach \
  --name zomboid-server \
  --mount type=volume,source=zomboid-server,target=/home/steam/zomboid \
  --mount type=volume,source=zomboid-data,target=/home/steam/zomboid_data \
  --publish 16261:16261/udp \
  --publish 16262:16262/udp \
  --publish 27015:27015/tcp \
  --env=SERVER_NAME='Zomboid Containerized' \
  --env=SERVER_PASSWORD='PleaseChangeMe' \
  --env=ADMIN_USERNAME='Bobette' \
  --env=ADMIN_PASSWORD='AdminPleaseChangeMe' \
  --env=RCON_PORT='27015' \
  --env=RCON_PASSWORD='RCONPleaseChangeMe' \
  docker.io/sknnr/zomboid-dedicated-server:latest
```

### Kubernetes

I've built a Helm chart and have included it in the `helm` directory within this repo. Modify the `values.yaml` file to your liking and install the chart into your cluster. Be sure to create and specify a namespace as I did not include a template for provisioning a namespace.

The chart in this repo is also hosted in my helm-charts repository [here](https://jsknnr.github.io/helm-charts)

To install this chart from my helm-charts repository:

```bash
helm repo add jsknnr https://jsknnr.github.io/helm-charts
helm repo update
```

To install the chart from the repo:

```bash
helm install zomboid jsknnr/zomboid-dedicated-server --values myvalues.yaml
# Where myvalues.yaml is your copy of the Values.yaml file with the settings that you want
```

## FAQ

**Q:** Can you change and or make the user and group IDs configurable? \
**A:** Short answer, no I will not. Longer answer, for security reasons it is best that containers have UID/GIDs at or above 10000 to avoid collision with container host UID/GIDs. To make this configurable, the container would have to start as root and then later change to the desired user... this is also a security concern. If you *really* need to change this, just take my repo and build your own image with IDs you prefer. Just change the build args in the Containerfile.

**Q:** Can you release an ARM64 based image? \
**A:** No. Until the devs release ARM compiled server binaries I won't do this (otherwise requires some sort of emulation, performance cost, what's the point).

**Q:** I can't connect to my server, what is wrong? \
**A:** This is no fault of my image. You need to double check settings on your router and on your container host. Check and then double check firewall rules, dnat/port forwarding rules, etc. If you are still having issues, it is possible that your internet provider (ISP) is using CGNAT (carrier-grade NAT) which can make it really hard if not impossible to host internet facing services from your local network. Call them and discuss.

**Q:** I don't see my server on the in-game browser, what is wrong? \
**A:** Check your network settings, as listed above. Make sure that you have `PUBLIC` set to `true`. If you have `MAX_PLAYERS` set to 32 or higher you need to tick the box on the bottom that says "Show higher player count servers". If you have `SERVER_PASSWORD` set, you need to also tick that box that says "Show password protected servers".
