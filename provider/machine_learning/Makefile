PWD:=$(dir $(abspath $(lastword $(MAKEFILE_LIST))))

REGISTRY_NAME:=dev-ml-template-registry
REGISTRY:=$(REGISTRY_NAME).azurecr.io

IMAGE_NAME:=lightgbm
IMAGE:=$(REGISTRY)/$(IMAGE_NAME)
VERSION:=$(shell poetry version -s)

.PHONY: isort
isort:
	poetry run isort src

.PHONY: black
black:
	poetry run black src

.PHONY: flake8
flake8:
	poetry run flake8 src

.PHONY: mypy
mypy:
	poetry run mypy src

.PHONY: vet
vet:
	poetry run isort --diff src
	poetry run black --diff src
	poetry run flake8 src
	poetry run mypy src

.PHONY: fmt
fmt: isort black

.PHONY: run
run:
	rm -rf ./tmp/*
	rm -rf ./mlruns
	poetry run python -m src preprocess data tmp/X_train.csv tmp/X_test.csv tmp/y_train.csv tmp/y_test.csv
	poetry run python -m src train tmp/model tmp/X_train.csv tmp/y_train.csv
	poetry run python -m src predict tmp/model tmp/X_test.csv tmp/y_test_pred.csv
	poetry run python -m src evaluate tmp/y_test.csv tmp/y_test_pred.csv

.PHONY: help
help:
	poetry run python -m src

.PHONY: docker_build
docker_build:
	docker build -t $(IMAGE):$(VERSION) .
	docker tag $(IMAGE):$(VERSION) $(IMAGE):latest

.PHONY: docker_run
docker_run:
	docker run -it --rm -v $(PWD):/app $(IMAGE):latest bash

.PHONY: acr_login
acr_login:
	az login
	az acr login --name $(REGISTRY_NAME)

.PHONY: acr_push
acr_push:
	docker push $(IMAGE):$(VERSION)
