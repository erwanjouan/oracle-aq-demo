PROJ  := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
ZULU8 := /Library/Java/JavaVirtualMachines/zulu-8.jdk/Contents/Home
CP    := $(PROJ)java-consumer/target/classpath.txt

up:
	docker compose -f $(PROJ)docker/docker-compose.yml up

db:
	docker compose -f $(PROJ)docker/docker-compose.yml up -d oracle

consumer:
	cd $(PROJ)java-consumer && JAVA_HOME=$(ZULU8) mvn -q compile dependency:build-classpath -Dmdep.outputFile=target/classpath.txt && \
	$(ZULU8)/bin/java -cp "$(PROJ)java-consumer/target/classes:$$(cat $(CP))" com.demo.aq.OrderConsumer

down:
	docker compose -f $(PROJ)docker/docker-compose.yml down

insert-order:
	printf "INSERT INTO demo.orders (customer, product, quantity, status) VALUES ('Alice', 'Widget', 3, 'NEW');\nCOMMIT;\nEXIT;\n" | docker exec -i oracle-aq sqlplus -s demo/demo@//localhost:1521/FREEPDB1
