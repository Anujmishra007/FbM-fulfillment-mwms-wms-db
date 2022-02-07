-- rdt_1764GetTask06
execute rdt.rdtDropMsg 131101 , 131150	

execute rdt.rdtAddMsg 131101 , 10, '31101^NoTask.ClosePL', 'us_english', 1764
execute rdt.rdtAddMsg 131102 , 10, '31102^No more task  ', 'us_english', 1764
execute rdt.rdtAddMsg 131103 , 10, '31103^UpdTaskDtlFail', 'us_english', 1764

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 131101 AND 131150	

