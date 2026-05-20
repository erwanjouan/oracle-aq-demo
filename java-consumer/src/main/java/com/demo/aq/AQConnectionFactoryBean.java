package com.demo.aq;

import oracle.jms.AQjmsFactory;
import org.springframework.beans.factory.FactoryBean;

import javax.jms.QueueConnectionFactory;
import javax.sql.DataSource;

public class AQConnectionFactoryBean implements FactoryBean<QueueConnectionFactory> {

    private DataSource dataSource;

    public void setDataSource(DataSource dataSource) {
        this.dataSource = dataSource;
    }

    @Override
    public QueueConnectionFactory getObject() throws Exception {
        return AQjmsFactory.getQueueConnectionFactory(dataSource, false);
    }

    @Override
    public Class<?> getObjectType() {
        return QueueConnectionFactory.class;
    }

    @Override
    public boolean isSingleton() {
        return true;
    }
}
