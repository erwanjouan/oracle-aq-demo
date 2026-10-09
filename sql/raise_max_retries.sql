BEGIN
    DBMS_AQADM.ALTER_QUEUE(
        queue_name  => 'EKBOA_ADM.ACCNTEVNT_CLIENT_QUEUE',
        max_retries => 50  -- generous margin for test iterations
    );
END;
/