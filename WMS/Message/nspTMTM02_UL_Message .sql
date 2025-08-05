--nsptmtm02_UL
--241401 - 241450

execute rdt.rdtdropmsg 241401, 241450

execute rdt.rdtAddMsg 241401, 10, '241401 UpdTaskDtlFail',     'us_english'

SELECT * FROM rdt.rdtMsg WHERE Message_ID BETWEEN 241401 AND 241450