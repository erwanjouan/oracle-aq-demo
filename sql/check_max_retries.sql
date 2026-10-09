SELECT name, max_retries, retry_delay, retention
FROM user_queues
WHERE queue_table = 'ACCNTEVNT_CLIENT_QT';