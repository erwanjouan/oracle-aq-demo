up:
	docker compose -f docker/docker-compose.yml up

down:
	docker compose -f docker/docker-compose.yml down

insert-order:
	printf "INSERT INTO demo.orders (customer, product, quantity, status) VALUES ('Alice', 'Widget', 3, 'NEW');\nCOMMIT;\nEXIT;\n" | docker exec -i oracle-aq sqlplus -s demo/demo@//localhost:1521/FREEPDB1
