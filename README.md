# Oracle AQ Demo

Table replication via Oracle Advanced Queuing (trigger-based) with a Java JMS consumer.

## Structure

```
oracle-aq-demo/
├── docker/docker-compose.yml   # Oracle Free 23c container
├── sql/00_sys_grants.sql       # AQ privileges granted to demo user (runs as SYS)
├── sql/01_setup.sql            # Table, AQ queue, trigger
└── java-consumer/              # Maven Java 17 consumer
```

## Run

### 1. Start Oracle
```bash
cd docker && docker compose up -d
# Wait ~2 min for Oracle to be ready
# Init scripts run automatically in order: 00_sys_grants.sql then 01_setup.sql
# To reset: docker compose down -v && docker compose up -d
```

### 2. Start Java consumer
```bash
cd java-consumer
mvn compile dependency:build-classpath -Dmdep.outputFile=/tmp/cp.txt -q
java -cp "target/classes:$(cat /tmp/cp.txt)" com.demo.aq.OrderConsumer
```

> Note: `mvn exec:java` does not work due to classloader isolation issues with Oracle AQ JMS inside Maven's JVM. Use the forked `java` command above instead.

### 3. Test — insert a row
```sql
-- connect as demo/demo to FREEPDB1
INSERT INTO demo.orders (customer, product, quantity, status)
VALUES ('Alice', 'Widget', 3, 'NEW');
COMMIT;
```

The Java consumer will print the JSON payload immediately.
# oracle-aq-demo
