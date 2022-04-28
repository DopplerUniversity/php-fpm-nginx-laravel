SHELL=/usr/bin/env bash

IMAGE=doppler/laravel
CONTAINER=doppler-laravel
PORT=9090

docker-build:
	docker build -t $(IMAGE) .

docker-run:
	docker container run \
	-it \
	--rm \
	--name $(CONTAINER) \
	-e DOPPLER_TOKEN="$$(doppler configs tokens create dev --max-age 30m --plain)" \
	-p $(PORT):$(PORT) \
	$(IMAGE) \
	doppler run --mount .env -- php artisan serve --host 0.0.0.0 --port $(PORT)

docker-run-dev:
	docker container run \
	-it \
	--rm \
	--name $(CONTAINER) \
	-v ${PWD}/laravel:/usr/src/app \
	-e DOPPLER_TOKEN="$$(doppler configs tokens create dev --max-age 30m --plain)" \
	-p $(PORT):$(PORT) \
	$(IMAGE) \
	bash
# 
# doppler secrets download --no-file --format env > .env && php artisan config:cache && php artisan serve --host 0.0.0.0 --port 9090
# doppler secrets download --no-file --format env > .env && php artisan config:clear && php artisan config:cache && && rm .env && php artisan serve --host 0.0.0.0 --port 9090

docker-shell:
	docker exec -it $(CONTAINER) bash