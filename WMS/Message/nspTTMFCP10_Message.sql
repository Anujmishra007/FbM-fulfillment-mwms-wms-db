--nspTTMFCP10
execute rdt.rdtdropmsg 214051, 214100

execute rdt.rdtAddMsg 214051, 10, '121751UpdTaskDtlFail', 'us_english'
execute rdt.rdtAddMsg 214052, 10, '121751UpdTaskDtlFail', 'us_english'

SELECT * FROM rdt.rdtMsg WHERE Message_ID BETWEEN 214051 AND 214100