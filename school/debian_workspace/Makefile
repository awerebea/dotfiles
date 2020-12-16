all: build run exec

build:
	docker build -t debian:workspace .

init_awerebea:
	mkdir -p ${HOME}/projects
	docker run -it -p 80:80 -p 443:443 -e TZ=Europe/Moscow -v ${HOME}/projects:/root/projects --name debian_workspace -d debian:workspace
	docker cp srcs/. debian_workspace:/
	docker exec -it debian_workspace bash workspace_init.sh

run:
	mkdir -p ${HOME}/projects
	docker run -it -p 80:80 -p 443:443 -e TZ=Europe/Moscow -v ${HOME}/projects:/root/projects --name debian_workspace -d debian:workspace
	docker exec -it debian_workspace zsh

start:
	docker container start debian_workspace
	docker exec -it debian_workspace zsh

exec:
	docker exec -it debian_workspace zsh

stop:
	docker stop debian_workspace

remove_container:
	docker rm debian_workspace

remove_image:
	docker rmi debian:workspace

clean_all: stop remove_container remove_image

.PHONY:	all \
		build \
		clean_all \
		exec \
		init_awerebea \
		remove_container \
		remove_image \
		run \
		start \
		stop
