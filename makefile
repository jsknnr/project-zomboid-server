# This file is for local development of container and not for production/play
# Image Values
REGISTRY := localhost
IMAGE := project-zomboid-test
PROTON_IMAGE := project-zomboid-test
IMAGE_REF := $(REGISTRY)/$(IMAGE)
PROTON_IMAGE_REF := $(REGISTRY)/$(PROTON_IMAGE)

# Git commit hash
HASH := $(shell git rev-parse --short HEAD)

# Buildah/Podman/Docker Options
CONTAINER_NAME := project-zomboid-test
BUILDAH_BUILD_OPTS := --format docker -f ./container/Containerfile
PODMAN_RUN_OPTS := --name $(CONTAINER_NAME) -d --mount type=volume,source=zomboid-server,target=/home/steam/zomboid --mount type=volume,source=zomboid-data,target=/home/steam/zomboid_data --env=MAX_MEMORY=4g -p 16261:16261/udp -p 16262:16262/udp

# Makefile targets
.PHONY: build run cleanup

build:
	buildah build $(BUILDAH_BUILD_OPTS) -t $(IMAGE_REF):$(HASH) ./container

run:
	podman volume create zomboid-server
	podman volume create zomboid-data
	podman run $(PODMAN_RUN_OPTS) $(IMAGE_REF):$(HASH)

cleanup:
	podman rm -f $(CONTAINER_NAME)
	podman rmi -f $(IMAGE_REF):$(HASH)
	podman volume rm zomboid-server
	podman volume rm zomboid-data
