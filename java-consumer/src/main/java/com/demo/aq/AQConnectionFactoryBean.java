package com.demo.aq;

import oracle.jms.AQjmsFactory;
import org.springframework.beans.factory.FactoryBean;

import javax.jms.XAQueueConnectionFactory;
import javax.sql.XADataSource;

public class AQConnectionFactoryBean implements FactoryBean<XAQueueConnectionFactory> {

    private XADataSource dataSource;

    public void setDataSource(XADataSource dataSource) {
        this.dataSource = dataSource;
    }

    @Override
    public XAQueueConnectionFactory getObject() throws Exception {
        return AQjmsFactory.getXAQueueConnectionFactory(dataSource, false);
    }

    @Override
    public Class<?> getObjectType() {
        return XAQueueConnectionFactory.class;
    }

    @Override
    public boolean isSingleton() {
        return true;
    }
}
