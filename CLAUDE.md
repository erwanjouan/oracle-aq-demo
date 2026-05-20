# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Demo of **table replication via Oracle Advanced Queuing (AQ)**. SQL triggers on the `ORDERS` table enqueue JSON change events to `demo.orders_queue`; a Java JMS consumer dequeues and prints them.

## Commands

```bash
# Start Oracle Free 23c + Java consumer (full Docker mode)
make up

# Start only Oracle in the background, then run consumer locally
make db
make consumer

# Stop and remove containers
make down

# Insert a test order (triggers the AQ trigger → consumer receives JSON)
make insert-order

# Connect manually via SQL*Plus
sqlplus demo/demo@//localhost:1521/FREEPDB1
```

## Architecture

### Data Flow

```
INSERT/UPDATE/DELETE on ORDERS
  → demo.orders_aq_trigger (AFTER trigger)
  → DBMS_AQ.ENQUEUE() → demo.orders_queue
  → Java QueueReceiver.receive() unblocks
  → JSON payload printed to stdout
```

### Components

**Docker** (`docker/docker-compose.yml`):
- `oracle-aq`: `gvenzl/oracle-free:23-slim`, port 1521, PDB `FREEPDB1`, user `demo/demo`
- `aq-consumer`: built from `java-consumer/`, starts only after Oracle health check passes

**SQL init scripts** (executed in order by the Oracle container on first boot):
- `sql/00_sys_grants.sql`: grants `ENQUEUE_ANY`, `DEQUEUE_ANY`, `MANAGE_ANY` to `demo` user
- `sql/01_setup.sql`: creates `ORDERS` table, AQ queue table (`orders_qt`), starts `orders_queue`, creates the AFTER INSERT/UPDATE/DELETE trigger

**Java consumer** (`java-consumer/src/main/java/com/demo/aq/OrderConsumer.java`):
- Wraps an Oracle JDBC connection in the AQ JMS API (`AQjmsQueueConnectionFactory`)
- Blocks on `QueueReceiver.receive()` — no polling, event-driven
- `AUTO_ACKNOWLEDGE` — messages are deleted from the queue after receipt
- Built via multi-stage Docker image: `maven:3.9-eclipse-temurin-8` build stage → `eclipse-temurin:8-jre` runtime stage

### Key identifiers

| Item | Value |
|------|-------|
| Queue | `demo.orders_queue` |
| Queue table | `demo.orders_qt` |
| Trigger | `demo.orders_aq_trigger` |
| DB URL env var | `DB_URL` (defaults to Oracle container hostname) |

### JSON message format

```json
{"op":"INSERT","id":1,"customer":"Alice","product":"Widget","quantity":3,"status":"NEW"}
```

`op` is one of `INSERT`, `UPDATE`, or `DELETE`. For `DELETE`, values come from `:OLD`; for others from `:NEW`.
