SHELL=/usr/bin/env bash

IMAGE=doppler/laravel-app
CONTAINER=doppler-laravel

doppler-project-init:
	@./bin/doppler-project-init.sh

build:
	@./bin/docker-build.sh

run:
	doppler run -- docker compose up;doppler run -- docker compose down;

run-dev:
	doppler run -- docker compose -f docker-compose.yml -f docker-compose.dev.yml up; doppler run -- docker compose -f docker-compose.yml -f docker-compose.dev.yml down;

shell:
	docker exec -it laravel bash

auto-sync-secrets:
	@watch -n 5 docker exec laravel ./bin/sync-secrets.sh

cleanup:
	doppler run -- docker compose down
	rm -fr ./volumes
	docker image rm $(IMAGE)
	doppler projects delete laravel-sample-app -y