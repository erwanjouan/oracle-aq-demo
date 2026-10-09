DECLARE
    v_enqueue_options     DBMS_AQ.ENQUEUE_OPTIONS_T;
    v_message_properties  DBMS_AQ.MESSAGE_PROPERTIES_T;
    v_msgid               RAW(16);
    v_count               PLS_INTEGER := 0;
BEGIN
    FOR rec IN (
        SELECT msgid, user_data, accounting_event_key, ts
        FROM (
            SELECT
                t.msgid,
                t.user_data,
                JSON_VALUE(t.user_data.text_vc, '$.ACCOUNTINGEVENTKEY') AS accounting_event_key,
                JSON_VALUE(t.user_data.text_vc, '$.TIMESTAMP')          AS ts,
                ROW_NUMBER() OVER (
                    PARTITION BY JSON_VALUE(t.user_data.text_vc, '$.ACCOUNTINGEVENTKEY')
                    ORDER BY JSON_VALUE(t.user_data.text_vc, '$.TIMESTAMP') DESC
                ) AS rn
            FROM EKBOA_ADM.ACCNTEVNT_CLIENT_QT t
            WHERE t.state = 3
        )
        WHERE rn = 1
    ) LOOP
        DBMS_AQ.ENQUEUE(
            queue_name          => 'EKBOA_ADM.ACCNTEVNT_CLIENT_QUEUE',
            enqueue_options      => v_enqueue_options,
            message_properties   => v_message_properties,
            payload              => rec.user_data,
            msgid                => v_msgid
        );
        v_count := v_count + 1;
        DBMS_OUTPUT.PUT_LINE('Re-enqueued key=' || rec.accounting_event_key
            || ' ts=' || rec.ts
            || ' old_msgid=' || RAWTOHEX(rec.msgid)
            || ' new_msgid=' || RAWTOHEX(v_msgid));
    END LOOP;

    COMMIT; -- enqueue is now durable

    -- purge only the OLD expired rows, never touch state=0 (the ones you just enqueued)
    DBMS_AQADM.PURGE_QUEUE_TABLE(
        queue_table     => 'EKBOA_ADM.ACCNTEVNT_CLIENT_QT',
        purge_condition => 'qtview.state = 3',
        purge_options   => DBMS_AQADM.AQ$_PURGE_OPTIONS_T(block => TRUE)
    );

    DBMS_OUTPUT.PUT_LINE('Total re-enqueued (deduped): ' || v_count);
END;
/