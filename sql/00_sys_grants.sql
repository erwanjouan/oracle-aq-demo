-- Run as SYS: grants AQ admin privileges to demo user
ALTER SESSION SET CONTAINER = FREEPDB1;

BEGIN
    DBMS_AQADM.GRANT_SYSTEM_PRIVILEGE(
        privilege   => 'ENQUEUE_ANY',
        grantee     => 'demo',
        admin_option => FALSE
    );
    DBMS_AQADM.GRANT_SYSTEM_PRIVILEGE(
        privilege   => 'DEQUEUE_ANY',
        grantee     => 'demo',
        admin_option => FALSE
    );
    DBMS_AQADM.GRANT_SYSTEM_PRIVILEGE(
        privilege   => 'MANAGE_ANY',
        grantee     => 'demo',
        admin_option => FALSE
    );
END;
/

-- │ DBMS_AQ    │ Application / triggers           │ Enqueue & dequeue messages     │
GRANT EXECUTE ON SYS.DBMS_AQ TO demo;
-- │ DBMS_AQADM │ Setup scripts / DBAs             │ Create, start, drop queues     │
GRANT EXECUTE ON SYS.DBMS_AQADM TO demo;
--│ DBMS_AQIN  │ Oracle JDBC/AQ driver internally │ JMS message format translation │
GRANT EXECUTE ON SYS.DBMS_AQIN TO demo;
