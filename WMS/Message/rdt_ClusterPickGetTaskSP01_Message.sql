-- rdt_ClusterPickGetTaskSP01
-- FCR-1755
EXECUTE rdt.rdtDropMsg 231651, 231700

EXECUTE rdt.rdtAddMsg 231651, 10, '231651 No Task   ', 'us_english', 1855
EXECUTE rdt.rdtAddMsg 231652, 10, '231652 No Task   ', 'us_english', 1855

SELECT * FROM rdt.rdtmsg WITH(NOLOCK) WHERE message_id BETWEEN 231651 AND 231700