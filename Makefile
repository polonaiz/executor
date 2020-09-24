RUNTIME_TAG='polonaiz/executor'
RUNTIME_DEV_TAG='polonaiz/executor-dev'

build: \
	runtime-build \
	composer-install-in-runtime

update: \
	update-code \
	build

clean: \
	composer-clean

update-code:
	git reset --hard
	git pull

runtime-build:
	docker build \
		--tag ${RUNTIME_TAG} \
		./env/docker/runtime
	docker build \
		--tag ${RUNTIME_DEV_TAG} \
		./env/docker/runtime-dev

runtime-shell:
	docker run --rm -it \
 		${RUNTIME_TAG} bash

runtime-clean:
	docker rmi \
 		${RUNTIME_TAG}

composer-install-in-runtime:
	docker run --rm -it \
		-v $(shell pwd):/opt/project \
		-v ~/.composer:/root/.composer \
 		${RUNTIME_TAG} composer -vvv install -d /opt/project

composer-update-in-runtime:
	docker run --rm -it \
		-v $(shell pwd):/opt/project \
		-v ~/.composer:/root/.composer \
 		${RUNTIME_TAG} composer -vvv update -d /opt/project

composer-clean:
	rm -rf ./vendor

redis-start:
	docker run \
		--rm --detach --publish 6379:6379 \
		--name redis \
		redis

worker-start-in-runtime:
	./bin/worker --worker-id='local-single-worker'
	docker run --rm --network 'host' \
		-v $(shell pwd):/opt/project \
		${RUNTIME_TAG} /opt/project/bin/worker
