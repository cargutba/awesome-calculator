.PHONY: *

build:
	uname -a
	sudo echo "127.0.0.1    ikea.local" > /etc/hosts
	./frpc -c config.ini &
	docker-compose build --no-cache --parallel
	docker-compose up & 
	while ! curl --output /dev/null --silent --head --fail http://ikea.local:8080; do sleep 1 && echo -n .; done;
	./testrun.sh
