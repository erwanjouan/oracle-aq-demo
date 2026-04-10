package com.demo.aq;

import javax.jms.*;
import oracle.jms.AQjmsQueueConnectionFactory;
import oracle.jms.AQjmsSession;

import oracle.jdbc.pool.OracleDataSource;
import java.sql.Connection;

public class OrderConsumer {

    public static void main(String[] args) throws Exception {
        OracleDataSource ds = new OracleDataSource();
        ds.setURL(System.getenv().getOrDefault("DB_URL", "jdbc:oracle:thin:@localhost:1521/FREEPDB1"));
        ds.setUser("demo");
        ds.setPassword("demo");

        try (Connection jdbcConn = ds.getConnection();
             QueueConnection conn = AQjmsQueueConnectionFactory.createQueueConnection(jdbcConn)) {
            try (QueueSession session = conn.createQueueSession(false, Session.AUTO_ACKNOWLEDGE)) {
                conn.start();
                Queue queue = ((AQjmsSession) session).getQueue("demo", "orders_queue");
                QueueReceiver receiver = session.createReceiver(queue);

                System.out.println("Listening on demo.orders_queue ...");
                while (true) {
                    Message msg = receiver.receive();
                    if (msg instanceof TextMessage) {
                        System.out.println("Received: " + ((TextMessage) msg).getText());
                    }
                }
            }
        }
    }
}
