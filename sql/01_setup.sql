-- Run as SYS in FREEPDB1
ALTER SESSION SET CONTAINER = FREEPDB1;

-- 1. Create ORDERS table
CREATE TABLE demo.orders (
    id          NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer    VARCHAR2(100),
    product     VARCHAR2(100),
    quantity    NUMBER,
    status      VARCHAR2(20),
    created_at  TIMESTAMP DEFAULT SYSTIMESTAMP
);

-- 2. Create AQ queue table and queue
BEGIN
    DBMS_AQADM.CREATE_QUEUE_TABLE(
        queue_table        => 'demo.orders_qt',
        queue_payload_type => 'SYS.AQ$_JMS_TEXT_MESSAGE'
    );

    DBMS_AQADM.CREATE_QUEUE(
        queue_name  => 'demo.orders_queue',
        queue_table => 'demo.orders_qt'
    );

    DBMS_AQADM.START_QUEUE(queue_name => 'demo.orders_queue');
END;
/

-- 3. Grant AQ privileges to demo user
BEGIN
    DBMS_AQADM.GRANT_QUEUE_PRIVILEGE(
        privilege   => 'ENQUEUE',
        queue_name  => 'demo.orders_queue',
        grantee     => 'demo'
    );
    DBMS_AQADM.GRANT_QUEUE_PRIVILEGE(
        privilege   => 'DEQUEUE',
        queue_name  => 'demo.orders_queue',
        grantee     => 'demo'
    );
END;
/

-- 4. Trigger: enqueue a JSON message on every INSERT/UPDATE/DELETE
CREATE OR REPLACE TRIGGER demo.orders_aq_trigger
AFTER INSERT OR UPDATE OR DELETE ON demo.orders
FOR EACH ROW
DECLARE
    l_enqueue_options    DBMS_AQ.ENQUEUE_OPTIONS_T;
    l_message_properties DBMS_AQ.MESSAGE_PROPERTIES_T;
    l_message_handle     RAW(16);
    l_message            SYS.AQ$_JMS_TEXT_MESSAGE;
    l_payload            VARCHAR2(4000);
    l_op                 VARCHAR2(10);
BEGIN
    IF INSERTING THEN l_op := 'INSERT';
    ELSIF UPDATING THEN l_op := 'UPDATE';
    ELSE l_op := 'DELETE';
    END IF;

    l_payload := '{"op":"' || l_op || '",'
              || '"id":' || COALESCE(TO_CHAR(:NEW.id), TO_CHAR(:OLD.id)) || ','
              || '"customer":"' || COALESCE(:NEW.customer, :OLD.customer) || '",'
              || '"product":"' || COALESCE(:NEW.product, :OLD.product) || '",'
              || '"quantity":' || COALESCE(TO_CHAR(:NEW.quantity), TO_CHAR(:OLD.quantity)) || ','
              || '"status":"' || COALESCE(:NEW.status, :OLD.status) || '"}';

    l_message := SYS.AQ$_JMS_TEXT_MESSAGE.CONSTRUCT();
    l_message.SET_TEXT(l_payload);

    DBMS_AQ.ENQUEUE(
        queue_name         => 'demo.orders_queue',
        enqueue_options    => l_enqueue_options,
        message_properties => l_message_properties,
        payload            => l_message,
        msgid              => l_message_handle
    );
END;
/
