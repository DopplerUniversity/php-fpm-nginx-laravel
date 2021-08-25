# Testing in Docker

docker:
	docker container run \
	-it \
	--rm \
	--name doppler-php \
	--workdir /usr/src/app \
	-v ${PWD}:/usr/src/app \
	-p 8080:80 \
	ubuntu bash

shell:
	docker container exec -it doppler-php
