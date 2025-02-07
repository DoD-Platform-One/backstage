.PHONY: default all build docker docker-build docker-build-multi docker-run run

default: all

all: build run

build:
	@echo "make building..."
	./scripts/build.sh

docker: build docker-build docker-run

docker-build:
	@echo "make docker building..."
	./scripts/docker-build.sh

docker-build-multi:
	@echo "make docker multi-stage building..."
	./scripts/docker-build-multi.sh

docker-run:
	@echo "make docker running..."
	./scripts/docker-run.sh

run:
	@echo "make running..."
	./scripts/run.sh
