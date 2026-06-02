-- 4. Trigger: enqueue a JSON message only when status='Rejected'
CREATE OR REPLACE TRIGGER demo.orders_aq_trigger
AFTER INSERT OR UPDATE OR DELETE ON demo.orders
FOR EACH ROW
DECLARE
  l_enqueue_options DBMS_AQ.ENQUEUE_OPTIONS_T;
    l_message_properties DBMS_AQ.MESSAGE_PROPERTIES_T;
      l_message_handle RAW(16);
        l_message SYS.AQ$_JMS_TEXT_MESSAGE;
          l_payload VARCHAR2(4000);
            l_op VARCHAR2(10);
              l_status VARCHAR2(20);
              BEGIN
                -- Determine operation
                  IF INSERTING THEN l_op := 'INSERT';
                    ELSIF UPDATING THEN l_op := 'UPDATE';
                      ELSE l_op := 'DELETE';
                        END IF;

                          -- Get the status value (use NEW for INSERT/UPDATE, OLD for DELETE)
                            IF DELETING THEN
                                l_status := :OLD.status;
                                  ELSE
                                      l_status := :NEW.status;
                                        END IF;

                                          -- Only enqueue if status is 'Rejected'
                                            IF l_status = 'Rejected' THEN
                                                l_payload := '{"op":"' || l_op || '",'
                                                      || '"id":' || COALESCE(TO_CHAR(:NEW.id), TO_CHAR(:OLD.id)) || ','
                                                            || '"customer":"' || COALESCE(:NEW.customer, :OLD.customer) || '",'
                                                                  || '"product":"' || COALESCE(:NEW.product, :OLD.product) || '",'
                                                                        || '"quantity":' || COALESCE(TO_CHAR(:NEW.quantity), TO_CHAR(:OLD.quantity)) || ','
                                                                              || '"status":"' || l_status || '"}';

                                                                                  l_message := SYS.AQ$_JMS_TEXT_MESSAGE.CONSTRUCT();
                                                                                      l_message.SET_TEXT(l_payload);

                                                                                          DBMS_AQ.ENQUEUE(
                                                                                                queue_name => 'demo.orders_queue',
                                                                                                      enqueue_options => l_enqueue_options,
                                                                                                            message_properties => l_message_properties,
                                                                                                                  payload => l_message,
                                                                                                                        msgid => l_message_handle
                                                                                                                            );
                                                                                                                              END IF;
                                                                                                                              END;
                                                                                                                              /
                                                                                                                              