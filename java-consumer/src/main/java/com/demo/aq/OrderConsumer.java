package com.demo.aq;

import org.springframework.context.support.ClassPathXmlApplicationContext;

public class OrderConsumer {

    public static void main(String[] args) {
        ClassPathXmlApplicationContext context = new ClassPathXmlApplicationContext("applicationContext.xml");
        context.registerShutdownHook();
    }
}
