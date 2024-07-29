# Make all targets .PHONY
.PHONY: $(shell sed -n -e '/^$$/ { n ; /^[^ .\#][^ ]*:/ { s/:.*$$// ; p ; } ; }' $(MAKEFILE_LIST))

SHELL = /usr/bin/env bash
USER_NAME = $(shell whoami)

ifeq (, $(shell which docker-compose))
	DOCKER_COMPOSE_COMMAND = docker compose
else
	DOCKER_COMPOSE_COMMAND = docker-compose
endif

DIRS_TO_VALIDATE = cybulde
DOCKER_COMPOSE_RUN = $(DOCKER_COMPOSE_COMMAND) run --rm app
DOCKER_COMPOSE_EXEC = $(DOCKER_COMPOSE_COMMAND) exec app

# Returns true if the stem is a non-empty environment variable, or else raises an error.
guard-%:
	@#$(or ${$*}, $(error $* is not set))

## Starts jupyter lab
notebook: up
	$(DOCKER_COMPOSE_EXEC) jupyter-lab --ip 0.0.0.0 --port 8888 --no-browser

## Sort code using isort
sort: up
	$(DOCKER_COMPOSE_EXEC) isort --atomic $(DIRS_TO_VALIDATE)

## Check sorting using isort
sort-check: up
	$(DOCKER_COMPOSE_EXEC) isort --check-only --atomic $(DIRS_TO_VALIDATE)

## Format code using black
format: up
	$(DOCKER_COMPOSE_EXEC) black $(DIRS_TO_VALIDATE)

## Check format using black
format-check: up
	$(DOCKER_COMPOSE_EXEC)d black --check $(DIRS_TO_VALIDATE)

## Fomart and sort code using black and isort
format-and-sort: sort format

## Lint code using flake8
lint: up format-check sort-check
	$(DOCKER_COMPOSE_EXEC) flake8 $(DIRS_TO_VALIDATE)

## Check type annotations using mypy
check-type-annotations: up
	$(DOCKER_COMPOSE_EXEC) mypy $(DIRS_TO_VALIDATE)

## Run tests with pytest
test: up
	$(DOCKER_COMPOSE_EXEC) pytest

## Perform a full check
full-check: lint check-type-annotations
	$(DOCKER_COMPOSE_EXEC) pytest --cov --cov-report xml --verbose

## builds docker image

build:
	$(DOCKER_COMPOSE_COMMAND) build app

## Remove poetry.lock and build docker image
build-for-dependencies:
	rm -f *.lock
	$(DOCKER_COMPOSE_COMMAND) build app

## Lock dependencies with poetry
lock-dependencies: build-for-dependencies
	$(DOCKER_COMPOSE_RUN) bash -c "if [ -e /home/project-environment/pyproject.toml ]; then cp /home/project-environment/poetry.lock.build ./poetry.lock; else poetry lock; fi"



## Starts docker containers using "docker-compose up -d"
up:
	$(DOCKER_COMPOSE_COMMAND) up -d