package com.demo.aq;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import javax.jms.JMSException;
import javax.jms.Message;
import javax.jms.MessageListener;
import javax.jms.TextMessage;

public class OrderMessageListener implements MessageListener {

    private static final Logger log = LoggerFactory.getLogger(OrderMessageListener.class);

    @Override
    public void onMessage(Message message) {
        try {
            if (message instanceof TextMessage) {
                log.info("Received: {}", ((TextMessage) message).getText());
            }
        } catch (JMSException e) {
            throw new RuntimeException(e);
        }
    }
}
