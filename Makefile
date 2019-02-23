
default:
	docker build . -t docker-compose-aarch64-builder
	docker run --rm -v "$(pwd)":/dist docker-compose-aarch64-builder
	# this will generate a `docker-compose-Linux-aarch64` in "$(pwd)"