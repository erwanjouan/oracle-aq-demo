package com.demo.aq;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;

@Component
public class OrderLogger {

    private static final Logger log = LoggerFactory.getLogger(OrderLogger.class);

    public void log(String payload) {
        log.info("Order received: {}", payload);
    }
}
