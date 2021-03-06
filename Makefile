VERSION=$(shell node -e "console.log(require('./package.json').version)")
REV=$(shell git rev-parse --revs-only --short --verify HEAD)
DATE=$(shell date +%Y-%m-%d)
TAG=$(VERSION)-$(DATE)-$(REV)

.PHONY: build
build:
	npm run compile


.PHONY: build-docker-image
build-docker-image:
	docker build --no-cache -t cloud-mirror .

.PHONY: push-docker-image
push-docker-image: #build-docker-image
	docker tag cloud-mirror:latest cloud-mirror:$(TAG)
	docker tag cloud-mirror:$(TAG) taskcluster/cloud-mirror:$(TAG)
	docker tag cloud-mirror:latest taskcluster/cloud-mirror:latest
	docker push taskcluster/cloud-mirror:latest
	docker push taskcluster/cloud-mirror:$(TAG)

.PHONY: clean-all-docker
clean-all-docker:
	docker rm $(shell docker ps -a -q) || true
	docker rmi --force $(shell docker images -q)

.PHONY: prod-logs
prod-logs:
	docker-cloud service logs -f cloud-mirror-copier
